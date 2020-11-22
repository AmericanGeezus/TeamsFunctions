# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
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
  [OutputType([Boolean])]
  param() #param

  begin {

  } #begin

  process {
    if (Test-AzureADConnection) {
      #$TenantDomain = $((Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue).TenantDomain)
      #Write-Verbose -Message "[ASSERT ] AzureAD(v2): Valid session found - Tenant: $TenantDomain"
      Write-Verbose -Message "[ASSERT ] AzureAD(v2): Connected"
      return $true
    }
    else {
      Write-Host "[ASSERT ] ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) " -ForegroundColor Red
      return $false
    }
  } #process

  end {

  } #end

} #Assert-AzureADConnection
