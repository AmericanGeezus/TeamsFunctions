# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     Live




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
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [Alias('pol')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {

    if (Test-MicrosoftTeamsConnection) {
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Connected!'
      }
      return $(if ($Called) { $true })
    }
    else {
      $Sessions = Get-PSSession -WarningAction SilentlyContinue | Where-Object { $_.ComputerName -eq 'api.interfaces.records.teams.microsoft.com' }
      if ($Sessions.Count -ge 1) {
        #FIXME Doesn't work
        if (Use-MicrosoftTeamsConnection) {
          if ($stack.length -lt 3) {
            Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Reconnected!'
          }
          return $(if ($Called) { $true })
        }
      }
      else {
        Write-Host '[ASSERT] ERROR: Seemless reconnect unsuccessful (Admin Roles are maybe timed out) - trying to re-enable' -ForegroundColor Red
        if (Enable-MyAzureAdAdminRole) {
          if (Use-MicrosoftTeamsConnection) {
            if ($stack.length -lt 3) {
              Write-Verbose -Message '[ASSERT] MicrosoftTeams Session Reconnected!'
            }
            return $(if ($Called) { $true })
          }
        }

        # Assuming Connection is bugged - trying to reconnect
        Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful - Trying to re-connect' -ForegroundColor Red
        try {
          $null = Connect-MicrosoftTeams -ErrorAction Stop
          Start-Sleep -Seconds 2
          $SessionStatus = Connect-MicrosoftTeamsSession
          if ($SessionStatus) {
            if ($stack.length -lt 3) {
              Write-Verbose -Message '[ASSERT] MicrosoftTeams Session Reconnected!'
            }
            return $(if ($Called) { $true })
          }
          elseif ($false -eq $Sessionstatus) {
            #not reconnected
            return $(if ($Called) { $false })
          }
          else {
            #doesn't exist
            return $(if ($Called) { $false })
          }
        }
        catch {
          $AzureAdFeedback = Get-AzureADCurrentSessionInfo
          if ($AzureAdFeedback) {
            Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful - Trying to disconnect and reconnect you (Connect-Me)' -ForegroundColor Red
            $ConnectionOutput = Connect-Me -AccountId $AzureAdFeedback.Account -NoFeedback
            if ($ConnectionOutput.ConnectedTo -contains 'MicrosoftTeams') {
              return $(if ($Called) { $true })
            }
            else {
              return $(if ($Called) { $false } else {
                  Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful. Connect-Me could not connect you. Please investigate and try again' -ForegroundColor Red
                })
            }
          }
          else {
            Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful. Connect-MicrosoftTeams failed and no Session to AzureAd exists. Please validate your Admin roles, disconnect and reconnect' -ForegroundColor Red
            return $(if ($Called) { $false })
          }
        }
      }
    }
  } #process

  end {

  } #end
} #Assert-MicrosoftTeamsConnection
