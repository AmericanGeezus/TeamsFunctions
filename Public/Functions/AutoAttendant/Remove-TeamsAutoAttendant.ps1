# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live


#TODO enable lookup with identity (ObjectId) as well! (enabling Pipeline Input) - Add Regex Validation to ObjectId format to change how it is looked up!

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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	.LINK
    Get-TeamsAutoAttendant
	.LINK
    Set-TeamsAutoAttendant
	.LINK
    New-TeamsAutoAttendant
	.LINK
    Remove-TeamsAutoAttendant
	.LINK
    Remove-TeamsCallQueue
	.LINK
		Remove-TeamsResourceAccount
	.LINK
		Remove-TeamsResourceAccountAssociation
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Auto Attendant')]
    [string]$Name
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $DNCounter = 0
    foreach ($DN in $Name) {
      Write-Progress -Id 0 -Status "Processing '$DN'" -CurrentOperation 'Querying CsAutoAttendant' -Activity $MyInvocation.MyCommand -PercentComplete ($DNCounter / $($Name.Count) * 100)
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
      $DNCounter++
      try {
        Write-Information 'INFO: The listed Auto Attendants are being removed:'
        $AAToRemove = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue
        $AAToRemove = $AAToRemove | Where-Object Name -EQ "$DN"

        if ( $AAToRemove ) {
          $AACounter = 0
          $AAs = if ($AAToRemove -is [Array]) { $AAToRemove.Count } else { 1 }
          foreach ($AA in $AAToRemove) {
            Write-Progress -Id 1 -Status "Removing Auto Attendant '$($AA.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($AACounter / $AAs * 100)
            Write-Information "Removing Auto Attendant: '$($AA.Name)'"
            $AACounter++
            if ($PSCmdlet.ShouldProcess("$($AA.Name)", 'Remove-CsAutoAttendant')) {
              Remove-CsAutoAttendant -Identity $($AA.Identity) -ErrorAction STOP
            }
          }
        }
        else {
          Write-Warning -Message "No Groups found matching '$DN'"
        }
      }
      catch {
        Write-Error -Message "Removal of Auto Attendant '$DN' failed" -Category OperationStopped
        return
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsAutoAttendant
