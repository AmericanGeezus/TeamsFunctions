# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  01-AUG-2020
# Status:   Live




function Test-MicrosoftTeamsConnection {
  <#
  .SYNOPSIS
    Tests whether a valid PS Session exists for MicrosoftTeams
  .DESCRIPTION
    A connection established via Connect-MicrosoftTeams is parsed.
  .EXAMPLE
    Test-MicrosoftTeamsConnection
    Will Return $TRUE only if a session is found.
  .INPUTS
    System.Void
  .OUTPUTS
    System.Boolean
  .NOTES
    Calls Get-PsSession to determine whether a Connection to MicrosoftTeams (SkypeOnline) exists
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Tests the connection to MicrosoftTeams (SkypeOnline)
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-MicrosoftTeamsConnection.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    $script:TeamsModuleVersion = (Get-Module MicrosoftTeams).Version
  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      Write-Debug -Message 'This CmdLet is trained on detecting a PSSession being created to be usable for Teams. As Microsoft updates more and more CmdLets not requiring this (moving them to an AutoREST function, this Cmdlet may become obsolete'
      <#
      # Retained for later, as the CmdLets requiring/creating a PsSession are getting less and less
      if ($TeamsModuleVersion -gt 2.3.1) {
        $VerbosePreference = 'SilentlyContinue'
        $DebugPreference = 'Continue'
        $Tenant = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction Stop
        if ( $Tenant ) { return $true } else { return $false }
      }
      else {
        #>
      $Sessions = Get-PSSession -WarningAction SilentlyContinue | Where-Object { $_.ComputerName -eq 'api.interfaces.records.teams.microsoft.com' }
      if ($Sessions.Count -lt 1) {
        Write-Verbose 'No Teams Session found, not assuming a connection to MicrosoftTeams has been established.'
        return $false
      }
      if ($Sessions.Count -ge 1) {
        if (-not $Called) {
          Write-Verbose 'Teams Session found'
        }
        $Sessions = $Sessions | Where-Object { $_.State -eq 'Opened' -and $_.Availability -eq 'Available' }
        if ($Sessions.Count -ge 1) {
          if (-not $Called) {
            Write-Verbose 'Teams Session found, open and valid'
          }
          return $true
        }
        else {
          Write-Verbose 'Teams Session found, but not open and valid'
          return $false
        }
      }
      #}
      else {
        return $false
      }
      #<#
    }
    catch {
      return $false
    }
    #>
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Test-MicrosoftTeamsConnection
