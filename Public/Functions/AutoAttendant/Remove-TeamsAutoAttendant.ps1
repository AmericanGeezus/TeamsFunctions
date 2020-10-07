# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   BETA

function Remove-TeamsAutoAttendant {
  <#
	.SYNOPSIS
		Removes an Auto Attendant
	.DESCRIPTION
		Remove-CsAutoAttendant for friendly Names
	.PARAMETER Name
		DisplayName of the Auto Attendant
	.EXAMPLE
		Remove-TeamsAutoAttendant -Name "My AutoAttendant"
    Prompts for removal for all Auto Attendant found with the string "My AutoAttendant"
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.LINK
		New-TeamsCallQueue
		Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
    New-TeamsAutoAttendant
    Get-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Remove-TeamsAutoAttendant
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the Auto Attendant")]
    [string]$Name
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
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
    foreach ($DN in $Name) {
      Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand) - '$DN'"
      try {
        Write-Verbose -Message "The listed AAs are being removed:" -Verbose
        $AAToRemove = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue
        foreach ($AA in $AAToRemove) {
          Write-Verbose -Message "Removing: '$($AA.Name)'"
          if ($PSCmdlet.ShouldProcess("$($AA.Name)", 'Remove-CsAutoAttendant')) {
            Remove-CsAutoAttendant -Identity $($AA.Identity) -ErrorAction STOP
          }
        }
      }
      catch {
        Write-Error -Message "Removal of Auto Attendant '$DN' failed" -Category OperationStopped
        Write-ErrorRecord $_ #This handles the error message in human readable format.
        return
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"

  } #end
} #Remove-TeamsAutoAttendant
