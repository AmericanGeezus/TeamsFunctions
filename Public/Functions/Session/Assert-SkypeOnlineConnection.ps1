# Module:     TeamsFunctions
# Function:   Session
# Author: David Eberhardtt
# Updated:    01-OCT-2020
# Status:     PreLive

function Assert-SkypeOnlineConnection {
  <#
	.SYNOPSIS
		Asserts an established Connection to SkypeOnline
	.DESCRIPTION
		Tests and tries to reconnect to a SkypeOnline connection already established.
	.EXAMPLE
		Assert-SkypeOnlineConnection
    Will run Test-SkypeOnlineConnection and, if successful, stops.
    If unsuccessful, tries to reconnect by running Get-CsTenant to prompt for reconnection.
    If that too is unsuccessful, displays request to reconnect with Connect-Me.
  #>

  [CmdletBinding()]
  [Alias('PoL')]
  [OutputType([Boolean])]
  param() #param

  if (Test-SkypeOnlineConnection) {
    try {
      $null = Get-CsTenant -ErrorAction STOP -WarningAction SilentlyContinue
      Write-Verbose -Message "[ASSERT ] SkypeOnline: Valid session found"
      return $true
    }
    catch {
      Write-Host "[ASSERT ] ERROR: Session is available, but assertion is not within its valid time range. Please disconnect and create a new session with Connect-SkypeOnline." -ForegroundColor Red
      Write-Host "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to SkypeOnline, MicrosoftTeams and AzureAD in one step!" -ForegroundColor DarkCyan
      return $false
    }
  }
  else {
    if ([bool]((Get-PSSession -WarningAction SilentlyContinue).Computername -match "online.lync.com")) {
      Write-Host "[ASSERT ] SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
      try {
        $null = Get-CsTenant -ErrorAction STOP -WarningAction SilentlyContinue
        return $true
      }
      catch {
        Write-Host "[ASSERT ] ERROR: Reconnect unsuccessful. Please disconnect and create a new session with Connect-SkypeOnline." -ForegroundColor Red
        Write-Host "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to SkypeOnline, MicrosoftTeams and AzureAD in one step!" -ForegroundColor DarkCyan
        return $false
      }
    }
    else {
      Write-Host "[ASSERT ] ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to SkypeOnline, AzureAD & MicrosoftTeams and in one step!" -ForegroundColor DarkCyan
      return $false
    }
  } #end
} #Assert-SkypeOnlineConnection
