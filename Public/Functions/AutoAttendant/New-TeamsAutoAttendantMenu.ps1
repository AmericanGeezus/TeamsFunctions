# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  12-DEC-2020
# Status:   ALPHA




function New-TeamsAutoAttendantMenu {
  <#
  .SYNOPSIS
    Creates a Menu Object to be used in Auto Attendants
  .DESCRIPTION
    Creates a Menu Object with Prompt and/or MenuOptions to be used in Auto Attendants
    Wrapper for New-CsAutoAttendantMenu with friendly names
  .PARAMETER Name
    Optional. Name of the Menu if desired. Otherwise generated automatically.
  .PARAMETER MenuOptions
    Required for Action "Menu" only. Hashtable of Routing Targets.
    DTMF tones are assigned in order with 0 being TransferToOperator
  .EXAMPLE
    New-TeamsAutoAttendantMenu
    Creates Menu based on decisions. MenuOptions provided as a Hashtable of Routing Targets.
    Note: This does not support Voicemail Dial Scope for "My Group"
  .EXAMPLE
    New-TeamsAutoAttendantMenu -GroupName "My Group","My other Group"
    Creates a Dial Scope including "My Group" and "My other Group"
  .NOTES
    Limitations: MenuOptions are integrated and type is parsed with Get-TeamsCallableEntity
    This provides the following limitations:
    1) Operator can only be specified as a redirection target, not as a MenuOption
    2) Provided UPNs that are found to be AzureAdUsers are limited to be used as
    "Person in the Organisation". If "Voicemail" is required, please change this in the Admin Center afterwards

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

    $CsAutoAttendantMenu = $null
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"





    # Create Call Flow
    Write-Verbose -Message "[PROCESS] Creating Dial Scope"
    if ($PSCmdlet.ShouldProcess("$($Menu.Name)", "New-CsAutoAttendantMenu")) {
      $Menu = New-CsAutoAttendantMenu @CsAutoAttendantMenu
    }

    # Output
    return $Menu
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantMenu
