# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
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
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    $Sessions = Get-PSSession -WarningAction SilentlyContinue
    if ($null -eq $Sessions) {
      $null = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false
      $Sessions = Get-PSSession -WarningAction SilentlyContinue
    }
    $Sessions = $Sessions | Where-Object { $_.ComputerName -eq 'api.interfaces.records.teams.microsoft.com' }
    if ($Sessions.Count -ge 1) {
      #Write-Verbose "Teams Session found"
      $Sessions = $Sessions | Where-Object { $_.State -eq 'Opened' -and $_.Availability -eq 'Available' }
      if ($Sessions.Count -ge 1) {
        #Write-Verbose "Teams Session found, open and valid"
        return $true
      }
      else {
        return $false
      }
    }
    else {
      return $false
    }

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} #Test-MicrosoftTeamsConnection
