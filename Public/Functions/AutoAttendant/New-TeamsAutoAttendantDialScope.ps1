# Module:   TeamsFunctions
# Function: AutoAttendant
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

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
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('New-TeamsAAScope')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Auto Attendant")]
    [string[]]$GroupName
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
    foreach ($Group in $GroupName) {
      Write-Verbose -Message "[PROCESS] Processing '$Group'"
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
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #New-TeamsAutoAttendantDialScope
