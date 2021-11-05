# Module:   TeamsFunctions
# Function: CallQueue
# Author:   David Eberhardt
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
  .NOTES
    None
  .COMPONENT
    TeamsCallQueue
  .FUNCTIONALITY
    Removes a Call Queue Object from the Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsCQ')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'Name of the Call Queue')]
    [string[]]$Name
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
    [int] $script:CountID0 = [int] $script:CountID1 = 1

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($DN in $Name) {
      [int] $script:CountID0 = 1
      [int] $script:StepsID0 = $Name.Count
      $StatusID0 = "Processing '$DN'"
      $CurrentOperationID0 = 'Querying Object'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        Write-Information 'INFO:    The listed Queues are being removed:'
        if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
          $QueueToRemove = Get-CsCallQueue -Identity "$DN" -WarningAction SilentlyContinue
        }
        else {
          $QueueToRemove = Get-CsCallQueue -NameFilter "$DN" -WarningAction SilentlyContinue
          $QueueToRemove = $QueueToRemove | Where-Object Name -EQ "$DN"
        }

        if ( $QueueToRemove ) {
          $StatusID0 = "Removing $($AAToRemove.Count) Objects"
          $script:StepsID1 = if ($QueueToRemove -is [Array]) { $QueueToRemove.Count } else { 1 }
          foreach ($Q in $QueueToRemove) {
            $ActivityID1 = "Removing Call Queue '$($Q.Name)'"
            $StatusID1 = $CurrentOperationID1 = ''
            Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
            Write-Information "INFO:    $ActivityID1"
            if ($PSCmdlet.ShouldProcess("$($Q.Name)", 'Remove-CsCallQueue')) {
              Remove-CsCallQueue -Identity "$($Q.Identity)" -ErrorAction STOP
            }
            Write-Progress -Id 1 -Activity $ActivityID1 -Completed
          }
        }
        else {
          Write-Warning -Message "No Call Queue found matching '$DN'"
        }
      }
      catch {
        Write-Error -Message "Removal of Call Queue '$DN' failed with Exception: $($_.Exception.Message)" -Category OperationStopped
        return
      }
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsCallQueue
