# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live
#TODO if Connected but RBAC Roles have timed out does not trigger on POL - must capture PermissionDenied error on query
#TODO Check output for Diagnosticlevel 1-4 to ascertain removed output if CsOnlineObject is called with -Identity Switch!
#TODO Check output for Policies - Add all relevant Policies to Level 2? (all Policies to Level 3? (move 3/4 to 4/5?))
#TODO Add Address information (from Get-CsOnlineVoiceUser & Translate LocationId to Address name - nest Object?)
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
    Using any diagnostic level higher than 3 adds Parameter LicenseObject allowing to drill-down into Licensing
    Omitting it allows for visible data when exporting as a CSV.
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Returns an Object to validate the Voice Configuration for an Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsUserVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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

    #Initialising Counters
    $script:StepsID0, $script:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $script:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int]$script:CountID0 = [int]$script:CountID1 = 0

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary

    # preparing Output Field Separator
    $OFS = ', ' # do not remove - Automatic variable, used to separate elements!

    # Querying Teams Module Version
    #$TeamsModuleVersion = (Get-Module MicrosoftTeams -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).Version

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
      $StatusID0 = "Processing '$User'"
      $Operation = 'Querying User Account'
      Write-Progress -Id 0 -Status $StatusID0 -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($UserCounter / $($UserPrincipalName.Count) * 100)
      Write-Verbose -Message "[PROCESS] $StatusID0"
      #region Querying Identity
      try {
        $Operation = 'Querying User Account (CsOnlineUser)'
        Write-Verbose -Message "$StatusID0 - $Operation"
        #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
        #$CsUser = Get-CsOnlineUser -Identity "$User" -WarningAction SilentlyContinue -ErrorAction Stop
        $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        # If CsOnlineUser not found, trying AzureAdUser
        try {
          $Operation = 'Querying User Account (AzureAdUser)'
          Write-Verbose -Message "$StatusID0 - $Operation"
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
      #endregion

      #CHECK v2.6.0 has reverted a change introduced with v2.5.0 - Output object now identical to v2.3.1...
      #region Constructing InterpretedVoiceConfigType
      $Status = "User '$User'"
      $Operation = 'Verification, Testing InterpretedVoiceConfigType'
      $step++
      Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
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
      #endregion

      #region Testing ObjectType
      $Operation = 'Verification, Testing ObjectType'
      $step++
      Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      #Performance of lookup for Get-TeamsCallableEntity  meant that it takes another Get-CsUser Lookup longer
      #$ObjectType = (Get-TeamsCallableEntity -Identity "$($CsUser.UserPrincipalName)").ObjectType
      $ObjectType = Get-TeamsObjectType $CsUser.UserPrincipalName

      #endregion

      #region Testing for Misconfiguration
      $Operation = 'Testing for Misconfiguration'
      $step++
      Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      #$null = Test-TeamsUserVoiceConfig -UserPrincipalName "$User" -ErrorAction SilentlyContinue
      if ( $AdUser -ne $CsUser ) {
        # Necessary as Test-TeamsUserVoiceConfig expects a CsOnlineUser Object
        $null = Test-TeamsUserVoiceConfig -Object $CsUser -ErrorAction SilentlyContinue
      }
      else {
        Write-Verbose -Message 'No validation can be performed for the Object as CsOnlineUser Object not found!'
      }


      #Info about unassigned Dial Plan (suppressing feedback if AzureAdUser is already populated)
      if ( $CsUser.SipAddress -and -not $CsUser.TenantDialPlan -and $ObjectType -ne 'ApplicationEndpoint' ) {
        Write-Information "INFO:    User '$User' - No Dial Plan is assigned"
      }
      #endregion
      #endregion

      #TEST rework based on Identity (needed for v2.5.0) - Parameter ObjectId seems to be removed?
      #region Refactoring ObjectId for v2.5.0 for backward compatibility
      "Function: $($MyInvocation.MyCommand.Name): ObjectId:", ($CsUser.ObjectId | Format-Table -AutoSize | Out-String).Trim() | Write-Debug

      if ( $CsUser.ObjectId -is [object] ) {
        #$UserObjectId = $CsUser.ObjectId.Guid
        $CsUser.Identity -match 'CN=(?<Guid>[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}),*' | Out-Null
        $UserObjectId = $matches.Guid
      }
      else {
        $UserObjectId = $CsUser.ObjectId
      }
      #endregion

      #region Creating Base Custom Object
      $Operation = 'Preparing Output Object'
      $step++
      Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      # Adding Basic parameters
      $UserObject = $null
      $UserObject = [PSCustomObject][ordered]@{
        UserPrincipalName          = $CsUser.UserPrincipalName
        SipAddress                 = $CsUser.SipAddress
        DisplayName                = $CsUser.DisplayName
        #<# Available until switch to new query method
        ObjectId                   = $UserObjectId
        Identity                   = $CsUser.Identity
        HostingProvider            = $CsUser.HostingProvider
        ObjectType                 = $ObjectType
        InterpretedUserType        = $CsUser.InterpretedUserType
        InterpretedVoiceConfigType = $InterpretedVoiceConfigType
        TeamsUpgradeEffectiveMode  = $CsUser.TeamsUpgradeEffectiveMode
        VoicePolicy                = $CsUser.VoicePolicy
        UsageLocation              = $CsUser.UsageLocation
        #>
      }

      <# When switching to new Query method
      #TEST Performance of Add-Member in comparison (100x?) and output for v2.5.x - Can InterpretedVoiceConfigType be salvaged somehow?
      if ($TeamsModuleVersion -lt 2.5.0) {
        $UserObject | Add-Member -MemberType NoteProperty -Name ObjectId -Value $UserObjectId
        $UserObject | Add-Member -MemberType NoteProperty -Name Identity -Value $Identity
      }
      else {
        $UserObject | Add-Member -MemberType NoteProperty -Name Identity -Value $Identity
        $UserObject | Add-Member -MemberType AliasProperty -Name ObjectId -Value $Identity
      }

      $UserObject | Add-Member -MemberType NoteProperty -Name HostingProvider -Value $CsUser.HostingProvider
      $UserObject | Add-Member -MemberType NoteProperty -Name ObjectType -Value $ObjectType
      $UserObject | Add-Member -MemberType NoteProperty -Name InterpretedUserType -Value $CsUser.InterpretedUserType

      if ($TeamsModuleVersion -lt 2.5.0) {
        $UserObject | Add-Member -MemberType NoteProperty -Name InterpretedVoiceConfigType -Value $InterpretedVoiceConfigType
        $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradeEffectiveMode -Value $CsUser.TeamsUpgradeEffectiveMode
        $UserObject | Add-Member -MemberType NoteProperty -Name VoicePolicy -Value $CsUser.VoicePolicy
      }
      else {
        $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradeEffectiveMode -Value $CsUser.TeamsUpgradeEffectiveMode
      }

      $UserObject | Add-Member -MemberType NoteProperty -Name UsageLocation -Value $CsUser.UsageLocation
      #>

      # Adding Licensing Parameters if not skipped
      if (-not $PSBoundParameters.ContainsKey('SkipLicenseCheck')) {
        # Querying User Licenses
        $Operation = 'Querying User Licenses'
        $step++
        Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        $CsUserLicense = Get-AzureAdUserLicense -Identity "$($CsUser.UserPrincipalName)" -FilterRelevantForTeams

        # Adding Parameters
        $Operation = 'Adding Parameters: Licensing Configuration'
        $step++
        Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        $UserObject | Add-Member -MemberType NoteProperty -Name LicensesAssigned -Value $($CsUserLicense.Licenses.ProductName -join ', ')


        #FIXME - Limited to Diagnostic Level itself.
        #Maybe introduce a separate parameter to flatten all nested objects in order to allow export independent of DiagnosticLevel
        if ( $DiagnosticLevel -ge 3 ) {
          $UserObject | Add-Member -MemberType NoteProperty -Name LicenseObject -Value $CsUserLicense.Licenses
          if ($CsUserLicense.Licenses) {
            $UserObject.LicenseObject | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.ProductName } -Force
          }
        }
        else {
          #TODO Think how best to display this - Hidden in Verbose output may be a bit too hidden. INFO is a bit too "always"
          Write-Verbose -Message "Parameter LicenseObject omitted. To receive this parameter with their nested licenses, please use DiagnosticLevel 3 or higher"
        }

        #Info about PhoneSystemStatus (suppressing feedback if AzureAdUser is already populated)
        if ( -not $CsUserLicense.PhoneSystemStatus.Contains('Success') -and -not $AdUser) {
          Write-Warning -Message "User '$User' - PhoneSystemStatus is not Success. User cannot be configured for Voice"
        }
        $UserObject | Add-Member -MemberType NoteProperty -Name CurrentCallingPlan -Value $CsUserLicense.CallingPlan
        $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystemStatus -Value $CsUserLicense.PhoneSystemStatus
        #Alternative: If PhoneSystemStatus -contains "Success", TRUE, FALSE - too imprecise?
        if ( $CsUserLicense.PhoneSystem ) {
          $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystem -Value $CsUserLicense.PhoneSystem
        }
        elseif ( $CsUserLicense.PhoneSystemVirtualUser ) {
          $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystem -Value $CsUserLicense.PhoneSystemVirtualUser
        }
        else {
          $UserObject | Add-Member -MemberType NoteProperty -Name PhoneSystem -Value $false
        }
      }

      # Adding Provisioning Parameters
      $Operation = 'Adding Parameters: Voice Configuration'
      $step++
      Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $UserObject | Add-Member -MemberType NoteProperty -Name EnterpriseVoiceEnabled -Value $CsUser.EnterpriseVoiceEnabled
      $UserObject | Add-Member -MemberType NoteProperty -Name HostedVoiceMail -Value $CsUser.HostedVoiceMail
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
            Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message "$Status - $Operation"
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
            Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message "$Status - $Operation"
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsEmergencyCallingPolicy -Value $CsUser.TeamsEmergencyCallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsCallingPolicy -Value $CsUser.TeamsCallingPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name CallingLineIdentity -Value $CsUser.CallingLineIdentity
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsIPPhonePolicy -Value $CsUser.TeamsIPPhonePolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsVdiPolicy -Value $CsUser.TeamsVdiPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name TeamsUpgradePolicy -Value $CsUser.TeamsUpgradePolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineDialOutPolicy -Value $CsUser.OnlineDialOutPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineVoicemailPolicy -Value $CsUser.OnlineVoicemailPolicy
            $UserObject | Add-Member -MemberType NoteProperty -Name OnlineAudioConferencingRoutingPolicy -Value $CsUser.OnlineAudioConferencingRoutingPolicy
          }

          { $PSItem -ge 3 } {
            # Querying AD Object (if Diagnostic Level is 3 or higher)
            $Operation = 'Querying AzureAd User'
            $step++
            Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message "$Status - $Operation"
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
            Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message "$Status - $Operation"
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
            Write-Progress -Id 1 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message "$Status - $Operation"
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
      Write-Progress -Id 1 -Status $Status -Activity $MyInvocation.MyCommand -Completed
      Write-Progress -Id 0 -Status $StatusID0 -Activity $MyInvocation.MyCommand -Completed
      Write-Output $UserObject
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserVoiceConfig
