# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function Get-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Displays Voice Configuration Parameters for one or more Users
	.DESCRIPTION
    Displays Voice Configuration Parameters with different Diagnostic Levels
    ranging from basic Voice Configuration up to Policies, Account Status & DirSync Information
  .PARAMETER Identity
    Required. UserPrincipalName (UPN) of the User
	.PARAMETER DiagnosticLevel
    Optional. Value from 1 to 4. Higher values will display more parameters
    See NOTES below for details.
  .PARAMETER SkipLicenseCheck
    Optional. Will not perform queries against User Licensing to improve performance
  .EXAMPLE
    Get-TeamsUserVoiceConfig -Identity John@domain.com
    Shows Voice Configuration for John with a concise view of Parameters
	.EXAMPLE
    Get-TeamsUserVoiceConfig -Identity John@domain.com -DiagnosticLevel 2
    Shows Voice Configuration for John with a extended list of Parameters (see NOTES)
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
    - for AzureAD:    "Find-AzureAdUser $Identity | FL"
    - for Licensing:  "Get-TeamsUserLicense $Identity"
    - for Teams:      "Get-CsOnlineUser $Identity"
	.FUNCTIONALITY
		The functionality that best describes this cmdlet
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsTenantVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
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
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Defines level of Diagnostic Data that are added to the output object')]
    [Alias('DiagLevel', 'Level', 'DL')]
    [ValidateRange(1, 4)]
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

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $UserCounter = 0
    foreach ($User in $Identity) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 6
      if ( $DiagnosticLevel ) { $sMax = $sMax + $DiagnosticLevel }
      if ( $DiagnosticLevel -gt 3 ) { $sMax++ }
      if ( -not $SkipLicenseCheck ) { $sMax++ }

      #region Information Gathering
      Write-Progress -Id 0 -Status "User '$User'" -CurrentOperation 'Querying User Account' -Activity $MyInvocation.MyCommand -PercentComplete ($UserCounter / $($Identity.Count) * 100)
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      # Querying Identity
      try {
        Write-Verbose -Message "User '$User' - Querying User Account"
        $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error -Message "User '$User' not found: $($_.Exception.Message)" -Category ObjectNotFound
        continue
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
      #$ObjectType = Get-TeamsObjectType $CsUser.UserPrincipalName
      $ObjectType = (Get-TeamsCallableEntity -Identity $CsUser.UserPrincipalName).ObjectType
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
        $CsUserLicense = Get-TeamsUserLicense -Identity "$($CsUser.UserPrincipalName)"

        # Adding Parameters
        $Operation = 'Adding Parameters: Licensing Configuration'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation
        $UserObject | Add-Member -MemberType NoteProperty -Name LicensesAssigned -Value $CsUserLicense.Licenses
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
            try {
              $AdUser = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction Stop
            }
            catch {
              Write-Warning -Message "User '$User' not found in AzureAD. Some data will not be available"
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
