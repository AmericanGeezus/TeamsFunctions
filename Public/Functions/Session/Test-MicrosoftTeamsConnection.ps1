# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardtt
# Updated:  01-AUG-2020
# Status:   PreLive

function Test-MicrosoftTeamsConnection {
  <#
	.SYNOPSIS
		Tests whether a valid PS Session exists for MicrosoftTeams
	.DESCRIPTION
		A connection established via Connect-MicrosoftTeams is parsed.
	.EXAMPLE
		Test-MicrosoftTeamsConnection
		Will Return $TRUE only if a session is found.
	#>
  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  try {
    $null = (Get-CsPolicyPackage -WarningAction SilentlyContinue | Select-Object -First 1 -ErrorAction STOP)
    return $true
  }
  catch {
    return $false
  } #end
} #Test-MicrosoftTeamsConnection
