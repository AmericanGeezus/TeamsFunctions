# Module:     TeamsFunctions
# Function:   Session
# Author: David Eberhardt
# Updated:    01-OCT-2020
# Status:     PreLive

function Assert-AzureADConnection {
  <#
	.SYNOPSIS
		Asserts an established Connection to AzureAD
	.DESCRIPTION
		Tests a connection to SkypeOnline is established.
	.EXAMPLE
		Assert-AzureADConnection
    Will run Test-AzureADConnection and, if successful, stops.
    If unsuccessful, displays request to create a new session and stops.
  #>

  [CmdletBinding()]
  param() #param

  if (Test-AzureADConnection) {
    $TenantDomain = $((Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue).TenantDomain)
    Write-Verbose -Message "[ASSERT ] AzureAD(v2): Valid session found - Tenant: $TenantDomain"
    return $true
  }
  else {
    Write-Host "[ASSERT ] ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "[ASSERT ] INFO:  Connect-Me can be used to disconnect, then connect to SkypeOnline, AzureAD & MicrosoftTeams and in one step!" -ForegroundColor DarkCyan
    return $false
  } #end
} #Assert-AzureADConnection
