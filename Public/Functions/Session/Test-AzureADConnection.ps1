# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardtt
# Updated:  01-AUG-2020
# Status:   PreLive

function Test-AzureADConnection {
  <#
	.SYNOPSIS
		Tests whether a valid PS Session exists for Azure Active Directory (v2)
	.DESCRIPTION
		A connection established via Connect-AzureAD is parsed.
	.EXAMPLE
		Test-AzureADConnection
		Will Return $TRUE only if a session is found.
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param() #param

  try {
    $null = (Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue -ErrorAction STOP)
    return $true
  }
  catch {
    return $false
  } #end
} #Test-AzureADConnection
