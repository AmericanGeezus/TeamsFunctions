# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  15-NOV-2020
# Status:   Live




function Remove-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Removes existing Voice Configuration for one or more Users
	.DESCRIPTION
		De-provisions a user from Enterprise Voice, removes the Telephone Number, Tenant Dial Plan and Voice Routing Policy
	.PARAMETER UserPrincipalName
		Required. UserPrincipalName of the User.
	.PARAMETER Scope
    Optional. Default is "All". Definition of Scope for removal of Voice Configuration.
    Allowed Values are: All, DirectRouting, CallingPlans
	.PARAMETER DisableEV
    Optional. Instructs the Script to also disable the Enterprise Voice enablement of the User
    By default the switch EnterpriseVoiceEnabled is left as-is. Replication applies when re-enabling EnterPriseVoice.
    This is useful for migrating already licensed Users between Voice Configurations as it does not impact the User Experience (Dial Pad)
    EnterpriseVoiceEnabled will be disabled automatically if the PhoneSystem license is removed
    NOTE: If enabled, but no valid Voice Configuration is applied, the User will have a dial pad, but will not have an option to use the PhoneSystem.
	.PARAMETER PassThru
		Optional. Displays Object after action.
	.PARAMETER Force
		Optional. Suppresses Confirmation for license Removal unless -Confirm is specified explicitly.
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com [-Scope All]
		Disables John for Enterprise Voice, then removes all Phone Numbers, Voice Routing Policy, Tenant Dial Plan and Call Plan licenses
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope DirectRouting
		Disables John for Enterprise Voice, Removes Phone Number, Voice Routing Policy and Tenant Dial Plan if assigned
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope CallingPlans [-Confirm]
    Disables John for Enterprise Voice, Removes Phone Number and subsequently removes all Call Plan Licenses assigned
    Prompts for Confirmation before removing Call Plan licenses
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope CallingPlans -Force
    Disables John for Enterprise Voice, Removes Phone Number and subsequently removes all Call Plan Licenses assigned
    Does not prompt for Confirmation (unless -Confirm is specified explicitly)
  .INPUTS
    System.String
  .OUTPUTS
    None
  .NOTES
    Prompting for Confirmation for disabling of EnterpriseVoice
    For DirectRouting, this Script does not remove any licenses.
    For CallingPlans it will prompt for Calling Plan licenses to be removed.
	.FUNCTIONALITY
    Removes a Users Voice Configuration (through Microsoft Call Plans or Direct Routing)
    This will leave the users in a clean and un-provisioned state and enables them to receive a new Configuration Set
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Assert-TeamsUserVoiceConfig
	.LINK
    Find-TeamsUserVoiceConfig
	.LINK
    Get-TeamsTenantVoiceConfig
	.LINK
    Get-TeamsUserVoiceConfig
	.LINK
    Set-TeamsUserVoiceConfig
	.LINK
    Remove-TeamsUserVoiceConfig
	.LINK
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
  [Alias('Remove-TeamsUVC')]
  [OutputType([System.Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Defines Type of Voice Configuration to remove')]
    [ValidateSet('All', 'DirectRouting', 'CallingPlans')]
    [string]$Scope = 'All',

    [Parameter(HelpMessage = 'Instructs the Script to forego the disablement for EnterpriseVoice')]
    [Alias('DisableEnterpriseVoice')]
    [switch]$DisableEV,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force

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

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $UserCounter = 0
    foreach ($User in $UserPrincipalName) {
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      Write-Progress -Id 0 -Status "User '$User'" -Activity $MyInvocation.MyCommand -PercentComplete ($UserCounter / $($UserPrincipalName.Count) * 100)
      $UserCounter++
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = switch ($Scope) {
        'All' { 7 }
        'CallingPlans' { 4 }
        'DirectRouting' { 4 }
      }
      if ( $DisableEV ) { $sMax++ }

      #region Information Gathering
      $Operation = 'Querying User Account'
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      # Querying Identity
      try {
        Write-Verbose -Message "User '$User' - Querying User Account"
        $CsUser = Get-CsOnlineUser "$User" -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found: $($_.Exception.Message)" -Category ObjectNotFound
        continue
      }
      #endregion

      #region Call Plan Configuration
      if ($Scope -eq 'All' -or $Scope -eq 'CallingPlans') {
        # Querying User Licenses
        $Operation = 'Calling Plans - Querying User Licenses'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation
        $CsUserLicense = Get-AzureAdUserLicense $User

        if ($null -ne $CsUserLicense.Licenses) {
          # Determine Call Plan Licenses - Building Scope
          [System.Collections.ArrayList]$RemoveLicenses = @()
          if ($CsUserLicense.CallingPlanInternational) {
            $RemoveLicenses.Add('InternationalCallingPlan')
          }
          if ($CsUserLicense.CallingPlanDomestic) {
            $RemoveLicenses.Add('DomesticCallingPlan')
          }
          if ($CsUserLicense.CallingPlanDomestic120) {
            $RemoveLicenses.Add('DomesticCallingPlan120')
          }
          if ($CsUserLicense.CommunicationsCredits) {
            $RemoveLicenses.Add('CommunicationCredits')
          }

          # Action only if Call Plan licenses found
          if ($Force -or $RemoveLicenses.Count -gt 0) {
            # Removing TelephoneNumber
            $Operation = 'Calling Plans - Removing Telephone Number'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            if ( $Force -or $CsUser.TelephoneNumber ) {
              try {
                Set-CsOnlineVoiceUser -Identity $User -TelephoneNumber $Null -ErrorAction Stop
                Write-Information "User '$User' - Removing TelephoneNumber: OK"
              }
              catch {
                if ( 'Your tenant is Disabled for this service. You are not permitted to use this cmdlet.' -in $_.Exception.Message) {
                  Write-Verbose -Message "User '$User' - Removing TelephoneNumber: OK (Service Disabled)"
                }
                else {
                  Write-Verbose -Message "User '$User' - Removing TelephoneNumber: Failed" -Verbose
                  Write-Error -Message "Error:  $($_.Exception.Message)"
                }
              }
            }
            else {
              Write-Verbose -Message "User '$User' - Removing TelephoneNumber: Not assigned"
            }

            # Removing Call Plan Licenses (with Confirmation)
            $Operation = 'Calling Plans - Removing Calling Plan Licenses'
            $step++
            Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message $Operation
            try {
              if ( $Force -or $PSCmdlet.ShouldProcess("$User", "Removing Licenses: $RemoveLicenses")) {
                if ( $RemoveLicenses.Count -gt 0 ) {
                  Set-TeamsUserLicense -Identity $User -RemoveLicenses $RemoveLicenses
                  Write-Information "User '$User' - Removing Call Plan Licenses: OK"
                }
                else {
                  Write-Verbose -Message "User '$User' - Removing Call Plan Licenses: None assigned"
                }
              }
            }
            catch {
              Write-Verbose -Message "User '$User' - Removing Call Plan Licenses: Failed" -Verbose
              Write-Error -Message "Error:  $($_.Exception.Message)"
            }
          }
          else {
            $step++
            Write-Verbose -Message "User '$User' - Removing Call Plan Licenses: None assigned"
          }

        }
        else {
          if ( $CsUser.TelephoneNumber ) {
            Write-Error -Message "User '$User' - Removing Call Plan Licenses: No licenses found on User. Cannot action removal of PhoneNumber" -Category PermissionDenied
          }
          else {
            Write-Verbose -Message "User '$User' - Removing TelephoneNumber: Not assigned"
            Write-Verbose -Message "User '$User' - Removing Call Plan Licenses: None assigned"
          }
        }
      }
      #endregion

      #region Direct Routing Configuration
      if ($Scope -eq 'All' -or $Scope -eq 'DirectRouting') {
        #region Removing OnPremLineURI
        $Operation = 'Direct Routing - Removing OnPremLineURI'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation
        if ( $Force -or $CsUser.OnPremLineURI ) {
          try {
            $CsUser | Set-CsUser -OnPremLineURI $Null
            Write-Information "User '$User' - Removing OnPremLineURI: OK"
          }
          catch {
            Write-Verbose -Message "User '$User' - Removing OnPremLineURI: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - Removing OnPremLineURI: Not assigned"
        }
        #endregion

        #region Removing Online Voice Routing Policy
        $Operation = 'Direct Routing - Removing Online Voice Routing Policy'
        $step++
        Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message $Operation
        if ( $Force -or $CsUser.OnlineVoiceRoutingPolicy ) {
          try {
            $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $Null
            Write-Information "User '$User' - Removing Online Voice Routing Policy: OK"
          }
          catch {
            Write-Verbose -Message "User '$User' - Removing Online Voice Routing Policy: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - Removing Online Voice Routing Policy: Not assigned"
        }
        #endregion
      }
      #endregion

      #region Generic/shared Configuration
      #region Removing Tenant DialPlan
      $Operation = 'Generic - Removing Tenant Dial Plan'
      $step++
      Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message $Operation
      if ( $Force -or $CsUser.TenantDialPlan ) {
        try {
          $CsUser | Grant-CsTenantDialPlan -PolicyName $Null
          Write-Information "User '$User' - Removing Tenant Dial Plan: OK"
        }
        catch {
          Write-Verbose -Message "User '$User' - Removing Tenant Dial Plan: Failed" -Verbose
          Write-Error -Message "Error:  $($error.Exception.Message)"
        }
      }
      else {
        Write-Verbose -Message "User '$User' - Removing Tenant Dial Plan: Not assigned"
      }
      #endregion

      #region Disabling EnterpriseVoice
      #CHECK whether to remove -DisableEV (and merge it with Force) - there might be a reason for it
      if ( $Force -or $CsUser.EnterpriseVoiceEnabled ) {
        if ($PSBoundParameters.ContainsKey('DisableEV')) {
          $Operation = 'Generic - Disabling Enterprise Voice'
          $step++
          Write-Progress -Id 1 -Status "User '$User'" -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message $Operation
          try {
            if ($Force -or $PSCmdlet.ShouldProcess("$User", 'Disabling EnterpriseVoice')) {
              $CsUser | Set-CsUser -EnterpriseVoiceEnabled $false
              Write-Information "User '$User' - Disabling EnterpriseVoice: OK"
            }
            else {
              Write-Verbose -Message "User '$User' - Disabling EnterpriseVoice: Skipped (Not confirmed)"
            }
          }
          catch {
            Write-Verbose -Message "User '$User' - Disabling EnterpriseVoice: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - Disabling EnterpriseVoice: Skipped (Current Status is: Enabled)" -Verbose
        }
      }
      else {
        Write-Verbose -Message "User '$User' - Disabling EnterpriseVoice: Skipped (Not enabled)"
      }
      #endregion
      #endregion


      Write-Progress -Id 1 -Status "User '$User'" -Activity $MyInvocation.MyCommand -Completed

      # Output
      if ( $PassThru ) {
        Get-TeamsUserVoiceConfig -UserPrincipalName "$User"
      }

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Remove-TeamsUserVoiceConfig
