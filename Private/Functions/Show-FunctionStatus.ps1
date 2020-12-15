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
  .NOTES
    This will only ever show the status of the first Command in the Stack (i.E. when called from a function).
    It will not display the same information for any nested commands.
	.EXAMPLE
		Show-FunctionStatus -Level PreLive
  #>

  [CmdletBinding()]
  param(
    [Validateset("Alpha", "Beta", "RC", "PreLive", "Live", "Unmanaged", "Deprectated")]
    $Level
  ) #param

  $Stack = Get-PSCallStack
  if ($stack.length -ge 3) {
    return
  }
  else {
    $Function = ($Stack | Select-Object -First 2).Command[1]

    switch ($Level) {
      "Alpha" {
        $DebugPreference = "Inquire"
        $VerbosePreference = "Continue"
        Write-Debug -Message "$Function has [ALPHA] Status: It may not work as intended or contain serious gaps in functionality. Please handle with care" -Debug
      }
      "Beta" {
        $DebugPreference = "Continue"
        $VerbosePreference = "Continue"
        Write-Debug -Message "$Function has [BETA] Status: Build is not completed, functionality missing or parts untested. Please report issues via GitHub"
      }
      "RC" {
        Write-Verbose -Message "$Function has [RC] Status: Functional, but still being tested. Please report issues via GitHub" -Verbose
      }
      "PreLive" {
        Write-Verbose -Message "$Function has [PreLIVE] Status. Should you encounter issues, please get in touch via GitHub or 'TeamsFunctions@outlook.com'"
      }
      "Live" {
        Write-Verbose -Message "$Function is [LIVE]. Should you encounter issues, please get in touch via GitHub or 'TeamsFunctions@outlook.com'"
      }
      "Unmanaged" {
        Write-Verbose -Message "$Function is [LIVE] but [UNMANAGED] and comes as-is."
      }
      "Deprecated" {
        Write-Verbose -Message "$Function is [LIVE] but [DEPRECATED]!" -Verbose
      }

    }

  }
} #Show-FunctionStatus
