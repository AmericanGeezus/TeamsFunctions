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
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    try {
      $null = (Get-CsPolicyPackage -WarningAction SilentlyContinue | Select-Object -First 1 -ErrorAction STOP)
      return $true
    }
    catch {
      return $false
    }

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #Test-MicrosoftTeamsConnection
