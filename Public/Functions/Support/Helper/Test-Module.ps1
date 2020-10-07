# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardtt
# Updated:  01-JUL-2020
# Status:   Live

function Test-Module {
  <#
	.SYNOPSIS
		Tests whether a Module is loaded
	.EXAMPLE
		Test-Module -Module ModuleName
		Will Return $TRUE if the Module 'ModuleName' is loaded
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory = $true, HelpMessage = "Module to test.")]
    [string]$Module
  )

  Write-Verbose -Message "Verifying if Module '$Module' is installed and available"
  Import-Module -Name $Module -ErrorAction SilentlyContinue
  if (Get-Module -Name $Module -WarningAction SilentlyContinue) {
    return $true
  }
  else {
    return $false
  } #end
} #Test-Module
