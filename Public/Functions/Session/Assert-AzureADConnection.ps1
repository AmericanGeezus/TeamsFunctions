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
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  begin {
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

  } #begin

  process {
    if (Test-AzureADConnection) {
      #$TenantDomain = $((Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue).TenantDomain)
      #Write-Verbose -Message "[ASSERT] AzureAD(v2): Valid session found - Tenant: $TenantDomain"
      if ($stack.length -lt 3) {
        Write-Verbose -Message '[ASSERT] AzureAD(v2) Session Connected'
      }
      return $(if ($Called) { $true })
    }
    else {
      Write-Host '[ASSERT] ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets. (Connect-Me can be used for multiple connections) ' -ForegroundColor Red
      return $(if ($Called) { $false })
    }
  } #process

  end {

  } #end

} #Assert-AzureADConnection
