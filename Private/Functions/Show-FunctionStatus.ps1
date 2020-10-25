# Module:     TeamsFunctions
# Function:   Assertion
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     PreLive

function Show-FunctionStatus {
  <#
	.SYNOPSIS
		Gives Feedback of FunctionStatus
	.DESCRIPTION
    On-Screen Output depends on Parameter Level
  .PARAMETER Level
    Level of Detail
	.EXAMPLE
		Show-FunctionStatus -Level PreLive
  #>

  [CmdletBinding()]
  param(
    [Validateset("Alpha", "Beta", "RC", "PreLive", "Live", "Unmanaged", "Deprectated")]
    $Level
  ) #param

  $Function = (Get-PSCallStack | Select-Object -First 2).Command[1]

  #CHECK evaluate whether $NestedPromptLevel or $ExecutionContext can be used to determine that this command is only executed once.
  switch ($Level) {
    "Alpha" {
      Write-Debug -Message "$Function has [ALPHA] Status. It may not work as intended or contain serious gaps in functionality. Please handle with care" -Debug
    }
    "Beta" {
      Write-Debug -Message "$Function has [BETA] Status. Build is not completed. Please report issues to 'TeamsFunctions@outlook.com'"
    }
    "RC" {
      Write-Verbose -Message "$Function has [RC] Status. Functional, but still being tested. Please report issues to 'TeamsFunctions@outlook.com' or via GitHub" -Verbose
    }
    "PreLive" {
      Write-Verbose -Message "$Function has [PreLIVE] Status. Functional, but still being tested. Please report issues to 'TeamsFunctions@outlook.com' or via GitHub"
    }
    "Live" {
      Write-Verbose -Message "$Function is [LIVE]. Should you encounter issues, please get in touch! 'TeamsFunctions@outlook.com' or via GitHub"
    }
    "Unmanaged" {
      Write-Verbose -Message "$Function is [LIVE] but [UNMANAGED] and comes as-is."
    }
    "Deprecated" {
      Write-Verbose -Message "$Function is [LIVE] but [DEPRECATED]!" -Verbose
    }
  }
} #Show-FunctionStatus
