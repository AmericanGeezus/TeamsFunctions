# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   RC




function New-TeamsAutoAttendantDialScope {
  <#
  .SYNOPSIS
    Creates a Dial Scope to be used in Auto Attendants
  .DESCRIPTION
    Wrapper for New-CsAutoAttendantDialScope with friendly names
  .PARAMETER GroupName
    Required. Name of one or more Office 365 groups to create a Dial Scope for
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -GroupName "My Group"
    Creates a Dial Scope for "My Group"
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -GroupName "My Group","My other Group"
    Creates a Dial Scope including "My Group" and "My other Group"
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    TeamsAutoAttendant
	.LINK
    New-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    Get-TeamsCallableEntity
    Find-TeamsCallableEntity
    New-TeamsCallableEntity
    New-TeamsAutoAttendantCallFlow
    New-TeamsAutoAttendantMenu
    New-TeamsAutoAttendantMenuOption
    New-TeamsAutoAttendantPrompt
    New-TeamsAutoAttendantSchedule
    New-TeamsAutoAttendantDialScope
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAScope')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Auto Attendant")]
    [string[]]$GroupName

  ) #param

  begin {
    Show-FunctionStatus -Level RC
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
    foreach ($Group in $GroupName) {
      Write-Verbose -Message "[PROCESS] Processing '$Group'"
      $Object = $null
      $Object = Find-AzureADGroup "$Group" -Exact
      if ($Object) {

        $GroupIds += $Object.ObjectId
      }
      else {
        Write-Warning -Message "Group not found: '$Group' - Skipping"
      }

    }

    # Create dial Scope
    Write-Verbose -Message "[PROCESS] Creating Dial Scope"
    if ($PSBoundParameters.ContainsKey('Debug')) {
      Write-Debug "$groupIds"
    }

    if ($PSCmdlet.ShouldProcess("$groupIds", "New-CsAutoAttendantDialScope")) {
      New-CsAutoAttendantDialScope -GroupScope -GroupIds $groupIds
    }
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantDialScope
