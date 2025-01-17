﻿# Module:     TeamsFunctions
# Function:   Session
# Author:    David Eberhardt
# Updated:    01-OCT-2020
# Status:     Live

#TEST Returns TRUE (Object) if Connected but RBAC Roles have timed out - must capture PermissionDenied errors for GET-CmdLets


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
  .INPUTS
    None
  .OUTPUTS
    System.Void - If called directly; On-Screen output only
    Boolean - If called by other CmdLets, On-Screen output for the first call only
  .NOTES
    None
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Verifies a Connection to AzureAd is established
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-MicrosoftTeamsConnection.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colourful feedback required to emphasise feedback for script executors')]
  [CmdletBinding()]
  [Alias('pol')]
  [OutputType([Boolean])]
  param() #param

  begin {
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    if ( -not $global:TeamsFunctionsMSTeamsModule) { $global:TeamsFunctionsMSTeamsModule = Get-Module MicrosoftTeams }

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    if ( $TeamsFunctionsMSTeamsModule.Version -lt 2.3.1 ) {
      throw [System.NotImplementedException]::New('TeamsFunctions only supports connections with MicrosoftTeams v2.3.1 or higher.')
    }
    else {
      if (Test-MicrosoftTeamsConnection) {
        if ($stack.length -lt 3) {
          Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Connected!'
        }
        return $(if ($Called) { $true })
      }
      else {
        try {
          $null = Get-CsCallingLineIdentity -Identity Global -WarningAction SilentlyContinue -ErrorAction Stop
          if ($stack.length -lt 3) {
            Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Reconnected!' -Verbose
          }
          return $(if ($Called) { $true })
        }
        catch {
          if ( $_.Exception.Message -match 'Run Connect-MicrosoftTeams before running cmdlets' ) {
            Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Not connected - trying to connect!' -Verbose
            $null = Connect-MicrosoftTeams
          }
          elseif ( $_.Exception.Message -match 'The WinRM client received an HTTP status code of 403' ) {
            if ($stack.length -lt 4) {
              Write-Verbose -Message '[ASSERT] MicrosoftTeams Session - Timed out - trying to reconnect!' -Verbose
              $null = Connect-MicrosoftTeams
              return ( Assert-MicrosoftTeamsConnection )
            }
            else {
              Write-Error -Message '[ASSERT] MicrosoftTeams Session - Connection Denied - Please check your Admin Roles before trying to reconnect!' -Verbose
              return $(if ($Called) { $false })
            }
          }
          else {
            Write-Host '[ASSERT] ERROR: MicrosoftTeams Session - No connection established or reconnect unsuccessful' -ForegroundColor Red
            return $(if ($Called) { $false })
          }
        }
      }
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
    if (-not $Called) {
      Get-CurrentConnectionInfo
    }
  } #end
} #Assert-MicrosoftTeamsConnection
