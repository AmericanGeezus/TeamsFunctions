# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   ALPHA

function New-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Short description
	.DESCRIPTION
		Long description
  .PARAMETER Identity
    UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER TBA
    To be decided
	.PARAMETER Force
    Suppresses confirmation inputs except when $Confirm is explicitly specified
	.EXAMPLE
		C:\PS>
		Example of how to use this cmdlet
	.EXAMPLE
		C:\PS>
		Another example of how to use this cmdlet
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		General notes
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

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    $User = Get-CsOnlineUser $Identity -WarningAction SilentlyContinue
    $User

    #Snippet for ShouldProcess:
    if ($Force -or $PSCmdlet.ShouldProcess("$User", "Enabling User for EnterpriseVoice")) {
      # do harm
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #New-TeamsUserVoiceConfig
