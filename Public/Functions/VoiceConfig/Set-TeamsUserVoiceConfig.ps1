# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   ALPHA




function Set-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Enables a User to consume Voice services in Teams (Pstn breakout)
	.DESCRIPTION
    Enables a User for Direct Routing, Microsoft Callings or for use in Call Queues (EvOnly)
    User requires a Phone System License in any case.
  .PARAMETER Identity
    UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER DirectRouting
    Optional (Default). Limits the Scope to enable an Object for DirectRouting
  .PARAMETER CallingPlans
    Required for CallingPlans. Limits the Scope to enable an Object for CallingPlans
  .PARAMETER OnlineVoiceRoutingPolicy
    Required for DirectRouting. Assigns an Online Voice Routing Policy to the User
  .PARAMETER TenantDialPlan
    Optional for DirectRouting. Assigns a Tenant Dial Plan to the User
  .PARAMETER PhoneNumber
    Required. Phone Number in E.164 format to be assigned to the User.
    For DirectRouting, will populate the OnPremLineUri
    For CallingPlans, will populate the TelephoneNumber (must be present in the Tenant)
	.PARAMETER Force
    Suppresses confirmation inputs except when $Confirm is explicitly specified
	.EXAMPLE
		C:\PS>
		Example of how to use this cmdlet
	.EXAMPLE
		C:\PS>
		Another example of how to use this cmdlet
	.EXAMPLE
		Set-TeamsUserVoiceConfig -Identity John@domain.com -EvOnly
    Another example of how to use this cmdlet
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    ParameterSet 'DirectRouting' will provision a User to use DirectRouting. Enables User for Enterprise Voice,
    assigns a Number and an Online Voice Routing Policy and optionally also a Tenant Dial Plan
    ParameterSet 'CallingPlans' will provision a User to use Microsoft CallingPlans.
    Enables User for Enterprise Voice and assegns a Microsoft Number (must be found in the Tenant!)
    Optionally can also assign a Calling Plan license prior.
	.COMPONENT
		The component this cmdlet belongs to
	.ROLE
		The role this cmdlet belongs to
	.FUNCTIONALITY
		The functionality that best describes this cmdlet
  .LINK
    Get-TeamsUserVoiceConfig
    Find-TeamsUserVoiceConfig
    New-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "DirectRouting", ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "UserPrincipalName of the User")]
    [string]$Identity,

    [Parameter(ParameterSetName = "DirectRouting", HelpMessage = "Enables an Object for Direct Routing")]
    [switch]$DirectRouting,

    [Parameter(ParameterSetName = "DirectRouting", Mandatory, HelpMessage = "Name of the Online Voice Routing Policy")]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(ParameterSetName = "DirectRouting", HelpMessage = "Name of the Tenant Dial Plan")]
    [Alias('TDP')]
    [string]$TenantDialPlan,

    [Parameter(ParameterSetName = "DirectRouting", Mandatory, HelpMessage = "E.164 Number to assign to the Object")]
    [Parameter(ParameterSetName = "CallingPlans", Mandatory, HelpMessage = "E.164 Number to assign to the Object")]
    [Alias('Number', 'LineURI')]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = "CallingPlans", Mandatory, HelpMessage = "Enables an Object for Microsoft Calling Plans")]
    [switch]$CallingPlan,

    [Parameter(ParameterSetName = "CallingPlans", HelpMessage = "Calling Plan License to assign to the Object")]
    [string]$CallingPlanLicense,

    [Parameter(HelpMessage = "Suppresses confirmation prompt unless -Confirm is used explicitly")]
    [switch]$Force,

    [Parameter(HelpMessage = "Suppresses object output")]
    [switch]$Silent
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Debug"
    Show-FunctionStatus -Level ALPHA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

    # Setting Preference Variables according to Uestream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.Sessionetate.PSVariable.GetValue('WhatIfPreference')
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ( Test-AzureADUser $Identity ) {
      $UserObject = Get-CsOnlineUser $Identity -WarningAction SilentlyContinue
      $IsEVenabled = $UserObject.EnterpriseVoiceEnabled
      $IsLicensed = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
    }
    else {
      Write-Error -Message "User '$Identity' not found" -Category ObjectNotFound -ErrorAction Stop
      return
    }

    if ( -not $IsLicensed  ) {
      Write-Error -Message "User '$Identity' is not licensed (PhoneSystem). Please assign a license" -Category ResourceUnavailable -RecommendedAction "Please assign a license that contains Phone System" -ErrorAction Stop
      return
    }

    if ( -not $IsEVenabled) {
      Write-Verbose -Message "User '$Identity' Enterprise Voice Status: Not enabled" -Verbose
      if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
        $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
      }
    }


    switch ($PSCmdlet.ParameterSetName) {
      "DirectRouting" {
        Write-Verbose -Message "[PROCESS] DirectRouting"
        Write-Warning -Message "This Function is not yet implemented, sorry!"
        return

        if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Do")) {
          # do harm
        }

      }
      "CallingPlans" {
        Write-Verbose -Message "[PROCESS] CallingPlans"
        Write-Warning -Message "This Function is not yet implemented, sorry!"
        return

        if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Do")) {
          # do harm
        }

      }
    }

    # OUTPUT
    if ($Silent) {
      return
    }
    else {
      # Re-Query Object
      $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $Identity -DiagnosticLevel 1
      return $UserObjectPost
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceConfig
