﻿# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  14-NOV-2020
# Status:   Live




function Test-TeamsUser {
  <#
	.SYNOPSIS
		Tests whether an Object exists in Teams (record found)
	.DESCRIPTION
		Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to modify.
	.EXAMPLE
		Test-TeamsUser -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to MicrosoftTeams!
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Find-AzureAdGroup
  .LINK
    Find-AzureAdUser
  .LINK
    Test-AzureAdGroup
  .LINK
    Test-AzureAdUser
  .LINK
    Test-TeamsUser
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('UserPrincipalName')]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $CsOnlineUser = Get-CsOnlineUser -Identity "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP
      if ( $null -ne $CsOnlineUser ) {
        return $true
      }
      else {
        return $false
      }
    }
    catch [System.Exception] {
      return $false
    }
    catch {
      return $false
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUser
