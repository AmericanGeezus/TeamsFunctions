# Module:   TeamsFunctions
# Function: CallQueue
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive

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
  [Alias('Remove-TeamsCQ')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = "Name of the Call Queue")]
    [string[]]$Name
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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
    foreach ($DN in $Name) {
      Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - '$DN'"
      try {
        Write-Verbose -Message "The listed Queues are being removed:" -Verbose
        $QueueToRemove = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue
        foreach ($Q in $QueueToRemove) {
          Write-Verbose -Message "Removing: '$($Q.Name)'"
          if ($PSCmdlet.ShouldProcess("$($Q.Identity)", 'Remove-CsCallQueue')) {
            Remove-CsCallQueue -Identity $($Q.Identity) -ErrorAction STOP
          }
        }
      }
      catch {
        Write-Error -Message "Removal of Call Queue '$DN' failed" -Category OperationStopped
        Write-ErrorRecord $_ #This handles the error message in human readable format.
        return
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsCallQueue
