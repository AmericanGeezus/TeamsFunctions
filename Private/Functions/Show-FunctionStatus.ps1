# Module:     TeamsFunctions
# Function:   Assertion
# Author:     David Eberhardt
# Updated:    15-DEC-2020
# Status:     Live




function Show-FunctionStatus {
  <#
	.SYNOPSIS
		Gives Feedback of FunctionStatus
	.DESCRIPTION
    On-Screen Output depends on Parameter Level
  .PARAMETER Level
    Level of Detail
	.EXAMPLE
    Show-FunctionStatus -Level <Level>
    "<Level>" may be Live, RC, Beta, Alpha, Unmanaged, Deprecated, Archived
  .NOTES
    This will only ever show the status of the first Command in the Stack (i.E. when called from a function).
    It will not display the same information for any nested commands.
    Available options are:
    Alpha:      Function in development. No guarantee of functionality. Here be dragons.
    Beta:       Function in development. No guarantee of functionality
    RC:         Release Candidate. Functionality is built
    Prelive:    Live function that is only lacking Pester tests.
    Live:       Live function that has proven with tests or without that it delivers.

    Unmanaged:  Legacy Function from SkypeFunctions, not managed
    Deprecated: Function flagged for removal/replacement
    Archived:   Function is archived
  #>

  [CmdletBinding()]
  param(
    [Validateset('Alpha', 'Beta', 'RC', 'Live', 'Unmanaged', 'Deprecated', 'Archived')]
    $Level
  ) #param

  #Show-FunctionStatus -Level Live

  # Setting Preference Variables according to Upstream settings
  if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
  if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
  if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

  $Stack = Get-PSCallStack
  if ($stack.length -gt 3) {
    return
  }
  else {
    $Function = ($Stack | Select-Object -First 2).Command[1]

    switch ($Level) {
      'Alpha' {
        $DebugPreference = 'Inquire'
        $VerbosePreference = 'Continue'
        Write-Debug -Message "$Function has [ALPHA] Status: It may not work as intended or contain serious gaps in functionality. Please handle with care" -Debug
      }
      'Beta' {
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
        Write-Debug -Message "$Function has [BETA] Status: Build is not completed, functionality may be missing. Please report issues via GitHub"
      }
      'RC' {
        Write-Verbose -Message "$Function has [RC] Status: Testing still commences. Please report issues via GitHub" -Verbose
      }
      'Live' {
        Write-Verbose -Message "$Function is [LIVE]. Please report issues via GitHub or 'TeamsFunctions@outlook.com'"
      }
      'Unmanaged' {
        Write-Verbose -Message "$Function is [LIVE] but [UNMANAGED] and comes as-is."
      }
      'Deprecated' {
        Write-Information "$Function is [LIVE] but [DEPRECATED]!"
      }
      'Archived' {
        Write-Information "$Function is [ARCHIVED]!"
      }
    }

  }
} #Show-FunctionStatus
