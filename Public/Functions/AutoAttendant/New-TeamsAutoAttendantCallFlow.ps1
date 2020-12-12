# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  12-DEC-2020
# Status:   ALPHA




function New-TeamsAutoAttendantCallFlow {
  <#
  .SYNOPSIS
    Creates a Call Flow Object to be used in Auto Attendants
  .DESCRIPTION
    Creates a Call Flow with optional Prompt and Menu to be used in Auto Attendants
    Wrapper for New-CsAutoAttendantCallFlow with friendly names
    Combines New-CsAutoAttendantMenu, New-CsAutoAttendantPrompt
  .PARAMETER Name
    Required. Name of the Menu?
  .PARAMETER Prompt
    Optional. String or Filename of a greeting message to be played before action is taken
  .PARAMETER
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -GroupName "My Group"
    Creates a Dial Scope for "My Group"
  .EXAMPLE
    New-TeamsAutoAttendantDialScope -GroupName "My Group","My other Group"
    Creates a Dial Scope including "My Group" and "My other Group"
  .NOTES
    Limitations: DialByName
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .COMPONENT
    TeamsAutoAttendant
	.LINK
    New-TeamsAutoAttendant
    Set-TeamsAutoAttendant
    New-TeamsCallableEntity
    New-TeamsAutoAttendantCallFlow
    New-TeamsAutoAttendantMenu
    New-TeamsAutoAttendantPrompt
    New-TeamsAutoAttendantSchedule
    New-TeamsAutoAttendantDialScope

  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAFlow')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Auto Attendant")]
    [string[]]$GroupName
  ) #param

  begin {
    Show-FunctionStatus -Level Alpha
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

    $CsAutoAttendantCallFlow = $null
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"




    # Create Call Flow
    Write-Verbose -Message "[PROCESS] Creating Dial Scope"
    if ($PSCmdlet.ShouldProcess("$($CsAutoAttendantCallFlow.Name)", "New-CsAutoAttendantCallFlow")) {
      $CallFlow = New-CsAutoAttendantCallFlow @CsAutoAttendantCallFlow
    }

    # Output
    return $CallFlow
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantCallFlow
