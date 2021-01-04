# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function Remove-TeamsCallQueue {
  <#
	.SYNOPSIS
		Removes a Call Queue
	.DESCRIPTION
		Remove-CsCallQueue for friendly Names
	.PARAMETER Name
		DisplayName of the Call Queue
	.EXAMPLE
		Remove-TeamsCallQueue -Name "My Queue"
    Prompts for removal for all queues found with the string "My Queue"
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.LINK
		Get-TeamsCallQueue
    Set-TeamsCallQueue
		New-TeamsCallQueue
    Remove-TeamsCallQueue
    Remove-TeamsAutoAttendant
		Remove-TeamsResourceAccount
		Remove-TeamsResourceAccountAssociation
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsCQ')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = "Name of the Call Queue")]
    [string[]]$Name
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

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
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $DNCounter = 0
    foreach ($DN in $Name) {
      Write-Progress -Id 0 -Status "Processing '$DN'" -CurrentOperation "Querying CsCallQueue" -Activity $MyInvocation.MyCommand -PercentComplete ($DNCounter / $($Name.Count) * 100)
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
      $DNCounter++
      try {
        Write-Verbose -Message "The listed Queues are being removed:" -Verbose
        $QueueToRemove = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue
        $QueueToRemove = $QueueToRemove | Where-Object Name -EQ "$DN"

        if ( $QueueToRemove ) {
          $QueueCounter = 0
          foreach ($Q in $QueueToRemove) {
            Write-Progress -Id 1 -Status "Removing Queue '$($Q.Name)'" -Activity $MyInvocation.MyCommand -PercentComplete ($QueueCounter / $($QueueToRemove.Count) * 100)
            Write-Verbose -Message "Removing: '$($Q.Name)'"
            $QueueCounter++
            if ($PSCmdlet.ShouldProcess("$($Q.Identity)", 'Remove-CsCallQueue')) {
              Remove-CsCallQueue -Identity $($Q.Identity) -ErrorAction STOP
            }
          }
        }
        else {
          Write-Warning -Message "No Groups found matching '$DN'"
        }
      }
      catch {
        Write-Error -Message "Removal of Call Queue '$DN' failed" -Category OperationStopped
        return
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsCallQueue
