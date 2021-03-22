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
  .LINK
    Assert-AzureAdConnection
  .LINK
    Get-CurrentConnectionInfo
  #>

  [CmdletBinding()]
  [Alias('pol')]
  [OutputType([Boolean])]
  param() #param

  begin {
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if (Test-MicrosoftTeamsConnection) {
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Connected!'
      }
      return $(if ($Called) { $true })
    }
    elseif (Use-MicrosoftTeamsConnection) {
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Reconnected!' -Verbose
      }
      return $(if ($Called) { $true })
    }
    else {
      Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful - Please validate your Admin roles, disconnect and reconnect' -ForegroundColor Red
      return $(if ($Called) { $false })
    }
    <# Commented out as the behaviour doesn't work flawlessly. To be tested
    #CHECK alternatives for Assertion that involve reconnecting
    else {
      Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Seemless reconnect unsuccessful - Trying to re-connect MicrosoftTeams' -ForegroundColor Red
      try {
        Connect-MicrosoftTeams -ErrorAction Stop
        if (Use-MicrosoftTeamsConnection) {
          if ($stack.length -lt 3) {
            Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Reconnected!'
          }
          return $(if ($Called) { $true })
        }
        else {
          if ($stack.length -lt 3) {
            Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful - Please validate your Admin roles, disconnect and reconnect' -ForegroundColor Red
          }
          return $(if ($Called) { $false })
        }
      }
      catch {
        $AzureAd = Get-AzureADCurrentSessionInfo
        if ($AzureAd) {
          Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful - Trying to disconnect and reconnect you (Connect-Me)' -ForegroundColor Red
          $ConnectionOutput = Connect-Me -AccountId $AzureAd.Account -NoFeedback
          if ($ConnectionOutput.ConnectedTo -contains 'MicrosoftTeams' -and ($null -ne $ConnectionOutput.TeamsUpgradeEffectiveMode)) {
            return $(if ($Called) { $true })
          }
          else {
            return $(if ($Called) { $false } else {
                Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful. Please investigate' -ForegroundColor Red
              })
          }
        }
        else {
          Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - Reconnect unsuccessful. Connect-MicrosoftTeams failed and no Session to AzureAd exists. Please validate your Admin roles, disconnect and reconnect' -ForegroundColor Red
          return $(if ($Called) { $false })
        }
      }
    }
    #>
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
    if (-not $Called) {
      Get-CurrentConnectionInfo
    }
  } #end
} #Assert-MicrosoftTeamsConnection
