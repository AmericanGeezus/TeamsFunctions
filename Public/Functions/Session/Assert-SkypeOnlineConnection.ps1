# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
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

  begin {
    $Stack = Get-PSCallStack

  } #begin

  process {

    if (Test-SkypeOnlineConnection) {
      if ($stack.length -ge 3) {
        return $true
      }
      else {
        try {
          $null = Get-CsTenant -ErrorAction STOP -WarningAction SilentlyContinue
          Write-Verbose -Message "[ASSERT ] SkypeOnline: Connected (and session is valid)"
          return $true
        }
        catch {
          Write-Host "[ASSERT ] ERROR: Session is available, but timed out. Please disconnect and create a new session with Connect-SkypeOnline or Connect-Me." -ForegroundColor Red
          Write-Verbose "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to multiple Services at once (SkypeOnline, AzureAD & MicrosoftTeams)!"
          return $false
        }
      }
    }
    else {
      $Sessions = Get-PSSession -WarningAction SilentlyContinue
      $SkypeSession = $Sessions | Where-Object { $_.Computername -match "online.lync.com" }
      if ( $SkypeSession ) {
        Write-Verbose "[ASSERT ] SkypeOnline: Session found. Trying to reconnect... (authentication required)" -Verbose
        try {
          $null = Get-CsTenant -ErrorAction STOP -WarningAction SilentlyContinue
          return $true
        }
        catch {
          Write-Host "[ASSERT ] ERROR: Reconnect unsuccessful. Please disconnect and create a new session with Connect-SkypeOnline or Connect-Me." -ForegroundColor Red
          return $false
        }
      }
      else {
        $TeamsSession = $Sessions | Where-Object { $_.Computername -eq "api.interfaces.records.teams.microsoft.com" }
        if ( $TeamsSession ) {
          Write-Verbose "[ASSERT ] SkypeOnline: Session found. Trying to reconnect... (authentication required)" -Verbose
          Connect-SkypeOnline
          if ( Test-SkypeOnlineConnection ) {
            return $true
          }
          else {
            return $false
          }
        }
        else {
          Write-Host "[ASSERT ] ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) " -ForegroundColor Red
          return $false
        }
      }
    }

  } #process

  end {

  } #end

} #Assert-SkypeOnlineConnection
