# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   ALPHA

function Remove-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Removes existing Voice Configuration for one or more Users
	.DESCRIPTION
		De-provisions a user from Enterprise Voice, removes the Telephone Number, Tenant Dial Plan and Voice Routing Policy
	.PARAMETER Identity
		Required. UserPrincipalName of the User.
	.PARAMETER Scope
    Optional. Default is "All". Definition of Scope for removal of Voice Configuration.
    Allowed Values are: All, DirectRouting, CallPlans
	.PARAMETER DoNotDisableEV
    Optional. Instructs the Script to leave the parameter EnterpriseVoiceEnabled as it is
    This is useful for migrating Users between Voice Configuration as it retains the users DialPad in Teams.
    NOTE: The User will be Enabled, but will not have an option to use the PhoneSystem as no valid Voice Configuration is in place.
	.PARAMETER Force
		Optional. Suppresses Confirmation for license Removal unless -Confirm is specified explicitly.
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -Identity John@domain.com [-Scope All]
		Disables John for Enterprise Voice, then removes all Phone Numbers, Voice Routing Policy, Tenant Dial Plan and Call Plan licenses
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -Identity John@domain.com -Scope DirectRouting
		Disables John for Enterprise Voice, Removes Phone Number, Voice Routing Policy and Tenant Dial Plan if assigned
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -Identity John@domain.com -Scope CallingPlans [-Confirm]
    Disables John for Enterprise Voice, Removes Phone Number and subsequently removes all Call Plan Licenses assigned
    Prompts for Confirmation before removing Call Plan licenses
	.EXAMPLE
		Remove-TeamsUserVoiceConfig -Identity John@domain.com -Scope CallingPlans -Force
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
    Get-TeamsUserVoiceConfig
    Find-TeamsUserVoiceConfig
    New-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
  [Alias('Remove-TeamsUVC')]
  [OutputType([System.Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$Identity,

    [Parameter(HelpMessage = "Defines Scope to remove Voice Configuration")]
    [ValidateSet('All', 'DirectRouting', 'CallPlans')]
    [string]$Scope = "All",

    [Parameter(HelpMessage = "Instructs the Script to forego the disablement for EnterpriseVoice")]
    [Alias('DoNotDisableEnterpriseVoice')]
    [switch]$DoNotDisableEV,

    [Parameter(HelpMessage = "Suppresses confirmation prompt unless -Confirm is used explicitly")]
    [switch]$Force

  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Debug"
    Show-FunctionStatus -Level ALPHA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    foreach ($User in $Identity) {
      Write-Verbose -Message "[PROCESS] Processing '$User'"
      #region Information Gathering
      # Querying Identity
      try {
        $CsUser = Get-CsOnlineUser $User -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Error "User '$User' not found" -Category ObjectNotFound -ErrorAction Stop
      }

      # Querying User Licenses
      $CsUserLicense = Get-TeamsUserLicense $User
      #endregion


      #region Generic/shared Configuration
      # Disabling EnterpriseVoice
      Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice"
      if ($CsUser.EnterpriseVoiceEnabled) {
        if ($PSBoundParameters.ContainsKey('DoNotDisableEV')) {
          Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice: Skipped (Current Status is: Enabled)" -Verbose
        }
        else {
          try {
            if ($Force -or $PSCmdlet.ShouldProcess("$User", "Disabling EnterpriseVoice")) {
              $CsUser | Set-CsUser -EnterpriseVoiceEnabled $false
              Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice: OK"
            }
            else {
              Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice: Skipped (Not confirmed)"
            }
          }
          catch {
            Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
      }
      else {
        Write-Verbose -Message "User '$User' - Disabling: EnterpriseVoice: Skipped (Not enabled)" -Verbose
      }


      # Removing Tenant DialPlan
      Write-Verbose -Message "User '$User' - Removing: Tenant Dial Plan"
      if ($null -ne $CsUser.TenantDialPlan) {
        try {
          $CsUser | Grant-CsTenantDialPlan -PolicyName $Null
          Write-Verbose -Message "User '$User' - Removing: Tenant Dial Plan: OK"
        }
        catch {
          Write-Verbose -Message "User '$User' - Removing: Tenant Dial Plan: Failed" -Verbose
          Write-Error -Message "Error:  $($error.Exception.Message)"
        }
      }
      else {
        Write-Verbose -Message "User '$User' - Removing: Tenant Dial Plan: Not assigned"
      }
      #endregion


      #region Direct Routing Configuration
      if ($Scope -eq "All" -or $Scope -eq "DirectRouting") {
        # Removing Online Voice Routing Policy
        Write-Verbose -Message "User '$User' - Removing: Online Voice Routing Policy"
        if ($null -ne $CsUser.OnlineVoiceRoutingPolicy) {
          try {
            $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $Null
            Write-Verbose -Message "User '$User' - Removing: Online Voice Routing Policy: OK"
          }
          catch {
            Write-Verbose -Message "User '$User' - Removing: Online Voice Routing Policy: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - Removing: Online Voice Routing Policy: Not assigned"
        }
        # Removing OnPremLineURI
        Write-Verbose -Message "User '$User' - Removing: OnPremLineURI"
        if ($null -ne $CsUser.OnPremLineURI) {
          try {
            $CsUser | Set-CsUser -OnPremLineURI $Null
            Write-Verbose -Message "User '$User' - Removing: OnPremLineURI: OK"
          }
          catch {
            Write-Verbose -Message "User '$User' - Removing: OnPremLineURI: Failed" -Verbose
            Write-Error -Message "Error:  $($error.Exception.Message)"
          }
        }
        else {
          Write-Verbose -Message "User '$User' - Removing: OnPremLineURI: Not assigned"
        }
      }
      #endregion


      #region Call Plan Configuration
      if ($Scope -eq "All" -or $Scope -eq "CallPlans") {
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
          if ($null -ne $RemoveLicenses) {
            # Removing TelephoneNumber
            Write-Verbose -Message "User '$User' - Removing: TelephoneNumber"
            if ($null -ne $CsUser.TelephoneNumber) {
              try {
                $CsUser | Set-CsUser -TelephoneNumber $Null
                Write-Verbose -Message "User '$User' - Removing: TelephoneNumber: OK"
              }
              catch {
                Write-Verbose -Message "User '$User' - Removing: TelephoneNumber: Failed" -Verbose
                Write-Error -Message "Error:  $($error.Exception.Message)"
              }
            }
            else {
              Write-Verbose -Message "User '$User' - Removing: TelephoneNumber: Not assigned"
            }

            # Removing Call Plan Licenses (with Confirmation)
            Write-Verbose -Message "User '$User' - Removing: Call Plan Licenses"
            try {
              if ($Force -or $PSCmdlet.ShouldProcess("$User", "Removing Licenses: $RemoveLicenses")) {
                Set-TeamsUserLicense -Identity $User -RemoveLicenses $RemoveLicenses
                Write-Verbose -Message "User '$User' - Removing: Call Plan Licenses: OK"
              }
            }
            catch {
              Write-Verbose -Message "User '$User' - Removing: Call Plan Licenses: Failed" -Verbose
              Write-Error -Message "Error:  $($error.Exception.Message)"
            }
          }
          else {
            Write-Verbose -Message "User '$User' - Removing: Call Plan Licenses: None assigned"
          }

        }
        else {
          Write-Error -Message "User '$User' - Removing: Call Plan Licenses: No licenses found on User. Cannot action removal of PhoneNumber" -Category PermissionDenied
        }
      }
      #endregion

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Remove-TeamsUserVoiceConfig