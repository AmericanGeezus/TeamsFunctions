# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
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

  begin {

  } #begin

  process {

    if (Test-MicrosoftTeamsConnection) {
      Write-Verbose -Message "[ASSERT ] MicrosoftTeams: Connected"
      return $true
    }
    else {
      Write-Host "[ASSERT ] ERROR: You must call the Connect-MicrosoftTeams cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) " -ForegroundColor Red
      return $false
    }

  } #process

  end {

  } #end


} #Assert-MicrosoftTeamsConnection
