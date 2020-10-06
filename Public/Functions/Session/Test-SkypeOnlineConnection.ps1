# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardtt
# Updated:  01-SEP-2020
# Status:   PreLive

function Test-SkypeOnlineConnection {
  <#
	.SYNOPSIS
		Tests whether a valid PS Session exists for SkypeOnline (Teams)
	.DESCRIPTION
		A connection established via Connect-SkypeOnline is parsed.
		This connection must be valid (Available and Opened)
	.EXAMPLE
		Test-SkypeOnlineConnection
		Will Return $TRUE only if a valid and open session is found.
	.NOTES
		Added check for Open Session to err on the side of caution.
		Use with Disconnect-SkypeOnline when tested negative, then Connect-SkypeOnline
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  $Sessions = Get-PSSession -WarningAction SilentlyContinue
  if ([bool]($Sessions.Computername -match "online.lync.com")) {
    $PSSkypeOnlineSession = $Sessions | Where-Object { $_.Computername -match "online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available" }
    if ($PSSkypeOnlineSession.Count -ge 1) {
      return $true
    }
    else {
      return $false
    }
  }
  else {
    return $false
  } #end
} #Test-SkypeOnlineConnection
