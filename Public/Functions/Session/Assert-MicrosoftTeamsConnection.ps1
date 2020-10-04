# Module:     TeamsFunctions
# Function:   Session
# Created by: David Eberhardt
# Updated:    01-OCT-2020
# Status:     PreLive

function Assert-MicrosoftTeamsConnection {
  <#
	.SYNOPSIS
		Asserts an established Connection to MicrosoftTeams
	.DESCRIPTION
		Tests a connection to MicrosoftTeams is established.
	.EXAMPLE
		Assert-MicrosoftTeamsConnection
    Will run Test-MicrosoftTeamsConnection and, if successful, stops.
    If unsuccessful, displays request to create a new session and stops.
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  if (Test-MicrosoftTeamsConnection) {
    Write-Verbose -Message "[ASSERT ] Microsoft Teams: Valid session found"
    return $true
  }
  else {
    Write-Host "[ASSERT ] ERROR: You must call the Connect-MicrosoftTeams cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to SkypeOnline, AzureAD & MicrosoftTeams and in one step!" -ForegroundColor DarkCyan
    return $false
  } #end
} #Assert-MicrosoftTeamsConnection
