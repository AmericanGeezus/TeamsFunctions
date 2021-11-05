# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




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
  .EXAMPLE
    Remove-TeamsAutoAttendant -Name 00000000-0000-0000-0000-000000000000
    Prompts for removal for all Auto Attendant found with the ObjectId 00000000-0000-0000-0000-000000000000
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    None
  .COMPONENT
    TeamsAutoAttendant
  .FUNCTIONALITY
    Removes Auto Attendant Objects from the Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  [Alias('Remove-TeamsAA')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Auto Attendant')]
    [Alias('Identity')]
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
    [int]$script:CountID0 = [int]$script:CountID1 = 1

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($DN in $Name) {
      [int]$script:CountID0 = 1
      [int]$script:StepsID0 = $Name.Count
      $StatusID0 = "Processing '$DN'"
      $CurrentOperationID0 = "Querying Object"
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($script:CountID0++) -Of $script:StepsID0
      try {
        Write-Information 'INFO:    The listed Auto Attendants are being removed:'
        if ( $DN -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$' ) {
          $AAToRemove = Get-CsAutoAttendant -Identity "$DN" -WarningAction SilentlyContinue
        }
        else {
          $AAToRemove = Get-CsAutoAttendant -NameFilter "$DN" -WarningAction SilentlyContinue
          $AAToRemove = $AAToRemove | Where-Object Name -EQ "$DN"
        }

        if ( $AAToRemove ) {
          $StatusID0 = "Removing $($AAToRemove.Count) Objects"
          $script:StepsID0 = if ($AAToRemove -is [Array]) { $AAToRemove.Count } else { 1 }
          foreach ($AA in $AAToRemove) {
            $ActivityID1 = "'$($AA.Name)'"
            $StatusID1 = $CurrentOperationID1 = ''
            Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($script:CountID1++) -Of $script:StepsID1
            Write-Information "INFO:    $ActivityID1"
            if ($PSCmdlet.ShouldProcess("$($AA.Name)", 'Remove-CsAutoAttendant')) {
              Remove-CsAutoAttendant -Identity "$($AA.Identity)" -ErrorAction STOP
            }
            Write-Progress -Id 1 -Activity $ActivityID1 -Completed
          }
        }
        else {
          Write-Warning -Message "No Auto Attendant found matching '$DN'"
        }
      }
      catch {
        Write-Error -Message "Removal of Auto Attendant '$DN' failed" -Category OperationStopped
        return
      }
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Remove-TeamsAutoAttendant
