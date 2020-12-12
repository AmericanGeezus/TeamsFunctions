# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  12-DEC-2020
# Status:   ALPHA




function New-TeamsAutoAttendantRoute {
  <#
  .SYNOPSIS
    Creates a Menu to be used in Auto Attendants
  .DESCRIPTION
    Creates a Routing target or Menu with Prompt and/or MenuOptions to be used in Auto Attendants
    Wrapper for New-CsAutoAttendantMenu with friendly names
    Combines New-CsAutoAttendantMenu, New-CsAutoAttendantPrompt and New-CsAutoAttendantMenuOptions
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
    New-TeamsAutoAttendantDialScope
    New-TeamsAutoAttendantPrompt
    New-TeamsAutoAttendantSchedule
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
      #TODO - Apply new SCript (check all that query AzureAdGroup)
      try {
        $Object = Get-AzureADGroup $Group -WarningAction SilentlyContinue -ErrorAction Stop
        $GroupIds += $Object.ObjectId
      }
      catch {
        Write-Error -Message "Group not found" -Category ObjectNotFound -ErrorAction Stop
      }

    }

    # Create dial Scope
    Write-Verbose -Message "[PROCESS] Creating Dial Scope"
    if ($PSCmdlet.ShouldProcess("$groupIds", "New-CsAutoAttendantDialScope")) {
      $dialScope = New-CsAutoAttendantDialScope -GroupScope -GroupIds $groupIds
    }

    # Output
    return $dialScope
  }

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsAutoAttendantDialScope
