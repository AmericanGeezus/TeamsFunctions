# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  13-MAR-2021
# Status:   Live




function Use-MicrosoftTeamsConnection {
  <#
	.SYNOPSIS
		Attempts to reconnect an existing SkypeOnline Session for MicrosoftTeams
	.DESCRIPTION
		A connection established via Connect-MicrosoftTeams is parsed and if it exists will be attempted to reconnected to.
	.EXAMPLE
		Use-MicrosoftTeamsConnection
    Runs Get-CsTeamsUpgradeConfiguration to open or reconnect the established PowerShell Session for SkypeOnline commands
		Will Return $TRUE only if a valid session is found.
  .INPUTS
    None
  .OUTPUTS
    Boolean
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Connect-Me
  .LINK
    Assert-MicrosoftTeamsConnection
  .LINK
    Test-MicrosoftTeamsConnection
	#>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    $TeamsModuleVersionMajor = (Get-Module MicrosoftTeams).Version.Major

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      if ($TeamsModuleVersionMajor -lt 2) {
        if (Test-SkypeOnlineConnection) {
          return $true
        }
        else {
          return $false
        }
      }
      else {
        # MEASUREMENTS This currently takes about half a second (486ms on average)
        $null = Get-CsPresencePolicy -Identity Global -WarningAction SilentlyContinue -ErrorAction Stop
        #Write-Verbose -Message "$($MyInvocation.MyCommand) - No Teams session found"
        #Start-Sleep -Seconds 1
        if (Test-MicrosoftTeamsConnection) {
          return $true
        }
        else {
          return $false
        }
      }
    }
    catch {
      return $false
    }
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Use-MicrosoftTeamsConnection
