# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function Get-TeamsUserVoiceConfig {
  <#
  .SYNOPSIS
    Displays Voice Configuration Parameters for one or more Users
  .DESCRIPTION
    Displays Voice Configuration Parameters with different Diagnostic Levels
    ranging from basic Voice Configuration up to Policies, Account Status & DirSync Information
  .PARAMETER UserPrincipalName
    Required. UserPrincipalName (UPN) of the User
  .PARAMETER DiagnosticLevel
    Optional. Value from 0 to 4. Higher values will display more parameters
    If not provided (and not suppressed with SkipLicenseCheck), will change the output of LicensesAssigned to ProductNames only
    See NOTES below for details.
  .PARAMETER SkipLicenseCheck
    Optional. Will not perform queries against User Licensing to improve performance
  .EXAMPLE
    Get-TeamsUserVoiceConfig -UserPrincipalName John@domain.com
    Shows Voice Configuration for John with a concise view of Parameters
  .EXAMPLE
    Get-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -DiagnosticLevel 2
    Shows Voice Configuration for John with a extended list of Parameters (see NOTES)
  .EXAMPLE
    "John@domain.com" | Get-TeamsUserVoiceConfig -SkipLicenseCheck
    Shows Voice Configuration for John with a concise view of Parameters and skips validation of Licensing for this User.
  .EXAMPLE
    Get-CsOnlineUser | Where-Object UsageLocation -eq "BE" | Get-TeamsUserVoiceConfig
    Shows Voice Configuration for all CsOnlineUsers with a UsageLocation set to Belgium. Returns concise view of Parameters
    For best results, please filter the Users first and add Diagnostic Levels at your discretion
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    DiagnosticLevel details:
    0 Same output as without the Parameter, though LicensesAssigned are nested in as an Object rather than names only.
    1 Basic diagnostics for Hybrid Configuration or when moving users from On-prem Skype
    2 Extended diagnostics displaying additional Voice-related Policies
    3 Basic troubleshooting parameters from AzureAD like AccountEnabled, etc.
    4 Extended troubleshooting parameters from AzureAD like LastDirSyncTime
    Parameters are additive, meaning with each DiagnosticLevel more information is displayed

    This script takes a select set of Parameters from AzureAD, Teams & Licensing. For a full parameterset, please run:
    - for AzureAD:    "Find-AzureAdUser $UserPrincipalName | FL"
    - for Licensing:  "Get-AzureAdUserLicense $UserPrincipalName"
    - for Teams:      "Get-CsOnlineUser $UserPrincipalName"

    Exporting PowerShell Objects that contain Nested Objects as CSV results in this parameter being shown as "System.Object[]".
    The nested Object itself however enables a more in-depth view of Licensing for this Object.
    The introduction of Diagnostic Level 0 tries to bridge two seemingly contradicting requirements.
    Using any diagnostic level gives the flexibly to drill-down into Licensing.
    Omitting it allows for visible data when exporting as a CSV.
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Returns an Object to validate the Voice Configuration for an Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsUserVoiceConfiguration
  .LINK
    about_UserManagement
  .LINK
    Assert-TeamsUserVoiceConfig
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsTenantVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    New-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
  .LINK
    Remove-TeamsUserVoiceConfig
  .LINK
    Test-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsUVC')]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Defines level of Diagnostic Data that are added to the output object')]
    [Alias('DiagLevel', 'Level', 'DL')]
    [ValidateRange(0, 4)]
    [int32]$DiagnosticLevel,

    [Parameter(HelpMessage = 'Improves performance by not performing a License Check on the User')]
    [Alias('SkipLicense', 'SkipLic')]
    [switch]$SkipLicenseCheck

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary

    # preparing Output Field Separator
    $OFS = ', ' # do not remove - Automatic variable, used to separate elements!

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $UserCounter = 0
    foreach ($User in $UserPrincipalName) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 7
      if ( $DiagnosticLevel ) { $sMax = $sMax + $DiagnosticLevel }
      if ( $DiagnosticLevel -ge 3 ) { $sMax++ }
      if ( -not $SkipLicenseCheck ) { $sMax++ }

      #region Information Gathering
      Write-Progress -Id 0 -Status "User '$User'" -CurrentOperation 'Querying User Account' -Activity $MyInvocation.MyCommand -PercentComplete ($UserCounter / $($UserPrincipalName.Count) * 100)
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      # Querying Identity
      try {
        Write-Verbose -Message "User '$User' - Querying User Account (CsOnlineUser)"
        $CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        # If CsOnlineUser not found, trying AzureAdUser
        try {
          Write-Verbose -Message "User '$User' - Querying User Account (AzureAdUser)"
          $AdUser = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
          $CsUser = $AdUser
          Write-Warning -Message "User '$User' - found in AzureAd but not in Teams (CsOnlineUser)!"
          Write-Verbose -Message 'You receive this message if no License containing Teams is assigned or the Teams ServicePlan (TEAMS1) is disabled! Please validate the User License. No further validation is performed. The Object returned only contains data from AzureAd' -Verbose
        }
        catch [Microsoft.Open.AzureAD16.Client.ApiException] {
          Write-Error -Message "User '$User' not found in Teams (CsOnlineUser) nor in Azure Ad (AzureAdUser). Please validate UserPrincipalName. Exception message: Resource '$User' does not exist or one of its queried reference-property objects are not present." -Category ObjectNotFound
          continue
        }
        catch {
          Write-Error -Message "User '$User' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
          continue
        }
      }

      # Constructing InterpretedVoiceConfigType
      $Operation = 'Verification, Testing InterpretedVoiceConfigType'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ($CsUser.VoicePolicy -eq 'BusinessVoice') {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'CallingPlans' (VoicePolicy found as 'BusinessVoice')"
        $InterpretedVoiceConfigType = 'CallingPlans'
      }
      elseif ($CsUser.VoicePolicy -eq 'HybridVoice') {
        Write-Verbose -Message "VoicePolicy found as 'HybridVoice'"
        if ($null -ne $CsUser.VoiceRoutingPolicy -and $null -eq $CsUser.OnlineVoiceRoutingPolicy) {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'SkypeHybridPSTN' (VoiceRoutingPolicy assigned and no OnlineVoiceRoutingPolicy found)"
          $InterpretedVoiceConfigType = 'SkypeHybridPSTN'
        }
        else {
          Write-Verbose -Message "InterpretedVoiceConfigType is 'DirectRouting' (VoiceRoutingPolicy not assigned)"
          $InterpretedVoiceConfigType = 'DirectRouting'
        }
      }
      else {
        Write-Verbose -Message "InterpretedVoiceConfigType is 'Unknown' (undetermined)"
        $InterpretedVoiceConfigType = 'Unknown'
      }

      # Testing ObjectType
      $Operation = 'Verification, Testing ObjectType'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      #Performance of lookup for Get-TeamsCallableEntity  meant that it takes another Get-CsUser Lookup longer
      #$ObjectType = (Get-TeamsCallableEntity -Identity "$($CsUser.UserPrincipalName)").ObjectType
      $ObjectType = Get-TeamsObjectType $CsUser.UserPrincipalName

      # Testing for Misconfiguration
      $Operation = 'Testing for Misconfiguration'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $null = Test-TeamsUserVoiceConfig -UserPrincipalName "$User" -ErrorAction SilentlyContinue

      #Info about unassigned Dial Plan (suppressing feedback if AzureAdUser is already populated)
      #TEST Application for normal operations ('' -eq $CsUser.TenantDialPlan -and -not $AdUser) results in $TRUE when CsUser found!
      if ( $CsUser.SipAddress -and -not $CsUser.TenantDialPlan ) {
        Write-Information -MessageData "User '$User' - No Dial Plan is assigned"
      }
      #endregion

      #region Creating Base Custom Object
      $Operation = 'Preparing Output Object'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      # Adding Basic parameters
      $UserObject = $null
      $UserObject = [PSCustomObject][ordered]@{
        UserPrincipalName          = $CsUser.UserPrincipalName
        SipAddress                 = $CsUser.SipAddress
        DisplayName                = $CsUser.DisplayName
        ObjectId                   = $CsUser.ObjectId
        Identity                   = $CsUser.Identity
        HostingProvider            = $CsUser.HostingProvider
        ObjectType                 = $ObjectType
        InterpretedUserType        = $CsUser.InterpretedUserType
        InterpretedVoiceConfigType = $InterpretedVoiceConfigType
        TeamsUpgradeEffectiveMode  = $CsUser.TeamsUpgradeEffectiveMode
        VoicePolicy                = $CsUser.VoicePolicy
        UsageLocation              = $CsUser.UsageLocation
      }

      # Adding Licensing Parameters if not skipped
      if (-not $PSBoundParameters.ContainsKey('SkipLicenseCheck')) {
        # Querying User Licenses
        $Operation = 'Querying User Licenses'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation
        $CsUserLicense = Get-AzureAdUserLicense -Identity "$($CsUser.UserPrincipalName)" -FilterRelevantForTeams

        # Adding Parameters
        $Operation = 'Adding Parameters: Licensing Configuration'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation

        if ( $PSBoundParameters.ContainsKey('DiagnosticLevel') ) {
          $UserObject | Add-Member -MemberType NoteProperty -Name LicensesAssigned -Value $CsUserLicense.Licenses
          if ($CsUserLicense.Licenses) {
            $UserObject.LicensesAssigned | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.ProductName } -Force
          }
        }
        else {
          $UserObject | Add-Member -MemberType NoteProperty -Name LicensesAssigned -Value $($CsUserLicense.Licenses.ProductName -join ', ')
        }

        #Info about PhoneSystemStatus (suppressing feedback if AzureAdUser is already populated)
        if ( -not $CsUserLicense.PhoneSystemStatus.Contains('Success') -and -not $AdUser) {
          Write-Warning -Message "User '$User' - PhoneSystemStatus is not Success. User cannot be configured for Voice"
        }
        $UserObject | Add-Member -MemberType NoteProperty -Name CurrentCallingPlan -Value $CsUserLicense.CallingPlan
        $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystemStatus -Value $CsUserLicense.PhoneSystemStatus
        $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystem -Value $CsUserLicense.PhoneSystem
      }

      # Adding Provisioning Parameters
      $Operation = 'Adding Parameters: Voice Configuration'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      $UserObject | Add-Member -MemberType NoteProperty -Name EnterpriseVoiceEnabled -Value $CsUser.EnterpriseVoiceEnabled
      $UserObject | Add-Member -MemberType NoteProperty -Name HostedVoiceMail -Value $CsUser.HostedVoiceMail
      $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradePolicy -Value $CsUser.TeamsUpgradePolicy
      $UserObject | Add-Member -MemberType NoteProperty -Name OnlineVoiceRoutingPolicy -Value $CsUser.OnlineVoiceRoutingPolicy
      $UserObject | Add-Member -MemberType NoteProperty -Name TenantDialPlan -Value $CsUser.TenantDialPlan
      $UserObject | Add-Member -MemberType NoteProperty -Name TelephoneNumber -Value $CsUser.TelephoneNumber
      $UserObject | Add-Member -MemberType NoteProperty -Name LineURI -Value $CsUser.LineURI
      $UserObject | Add-Member -MemberType NoteProperty -Name OnPremLineURI -Value $CsUser.OnPremLineURI
      #endregion

      #region Adding Diagnostic Parameters
      if ($PSBoundParameters.ContainsKey('DiagnosticLevel')) {
        switch ($DiagnosticLevel) {
          { $PSItem -ge 1 } {
            # Displaying basic diagnostic parameters (Hybrid)
            $Operation = 'Adding Parameters: Voice Configuration, DiagnosticLevel 1 - Voice related Parameters'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremLineURIManuallySet -Value $CsUser.OnPremLineURIManuallySet
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremEnterPriseVoiceEnabled -Value $CsUser.OnPremEnterPriseVoiceEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name PrivateLine -Value $CsUser.PrivateLine
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsVoiceRoute -Value $CsUser.TeamsVoiceRoute
            $UserObject | Add-Member -MemberType NoteProperty -Name VoiceRoutingPolicy -Value $CsUser.VoiceRoutingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsEmergencyCallRoutingPolicy -Value $CsUser.TeamsEmergencyCallRoutingPolicy
          }

          { $PSItem -ge 2 } {
            # Displaying extended diagnostic parameters
            $Operation = 'Adding Parameters: Voice Configuration, DiagnosticLevel 2 - Voice related Policies'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsEmergencyCallingPolicy -Value $CsUser.TeamsEmergencyCallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsCallingPolicy -Value $CsUser.TeamsCallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name CallerIdPolicy -Value $CsUser.CallerIdPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsIPPhonePolicy -Value $CsUser.TeamsIPPhonePolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsVdiPolicy -Value $CsUser.TeamsVdiPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineDialOutPolicy -Value $CsUser.OnlineDialOutPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineVoicemailPolicy -Value $CsUser.OnlineVoicemailPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineAudioConferencingRoutingPolicy -Value $CsUser.OnlineAudioConferencingRoutingPolicy
          }

          { $PSItem -ge 3 } {
            # Querying AD Object (if Diagnostic Level is 3 or higher)
            $Operation = 'Querying AzureAd User'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            if ( -not $AdUser ) {
              try {
                $AdUser = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction Stop
              }
              catch {
                Write-Warning -Message "User '$User' not found in AzureAD. Some data will not be available"
              }
            }

            # Displaying advanced diagnostic parameters
            $Operation = 'Adding Parameters: Voice Configuration, DiagnosticLevel 3 - AzureAd Parameters, Status'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            $UserObject | Add-Member -MemberType NoteProperty -Name AdAccountEnabled -Value $AdUser.AccountEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountEnabled -Value $CsUser.Enabled
            $UserObject | Add-Member -MemberType NoteProperty -Name CsAccountIsValid -Value $CsUser.IsValid
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenCreated -Value $CsUser.WhenCreated
            $UserObject | Add-Member -MemberType NoteProperty -Name CsWhenChanged -Value $CsUser.WhenChanged
            $UserObject | Add-Member -MemberType NoteProperty -Name AdObjectType -Value $AdUser.ObjectType
            $UserObject | Add-Member -MemberType NoteProperty -Name AdObjectClass -Value $CsUser.ObjectClass

          }
          { $PSItem -ge 4 } {
            # Displaying all of CsOnlineUser (previously omitted)
            $Operation = 'Adding Parameters: Voice Configuration, DiagnosticLevel 3 - AzureAd Parameters, DirSync'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            $UserObject | Add-Member -MemberType NoteProperty -Name DirSyncEnabled -Value $AdUser.DirSyncEnabled
            $UserObject | Add-Member -MemberType NoteProperty -Name LastDirSyncTime -Value $AdUser.LastDirSyncTime
            $UserObject | Add-Member -MemberType NoteProperty -Name AdDeletionTimestamp -Value $AdUser.DeletionTimestamp
            $UserObject | Add-Member -MemberType NoteProperty -Name CsSoftDeletionTimestamp -Value $CsUser.SoftDeletionTimestamp
            $UserObject | Add-Member -MemberType NoteProperty -Name CsPendingDeletion -Value $CsUser.PendingDeletion
            $UserObject | Add-Member -MemberType NoteProperty -Name HideFromAddressLists -Value $CsUser.HideFromAddressLists
            $UserObject | Add-Member -MemberType NoteProperty -Name OnPremHideFromAddressLists -Value $CsUser.OnPremHideFromAddressLists
            $UserObject | Add-Member -MemberType NoteProperty -Name OriginatingServer -Value $CsUser.OriginatingServer
            $UserObject | Add-Member -MemberType NoteProperty -Name ServiceInstance -Value $CsUser.ServiceInstance
            $UserObject | Add-Member -MemberType NoteProperty -Name SipProxyAddress -Value $CsUser.SipProxyAddress
          }
        }
      }
      #endregion

      # Output
      Write-Progress -Id 1 -Status "User '$User'" -Activity $MyInvocation.MyCommand -Completed
      Write-Output $UserObject

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserVoiceConfig
