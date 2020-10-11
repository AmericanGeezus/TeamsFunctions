# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardt
# Updated:  01-AUG-2020
# Status:   Live




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

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    try {
      $null = (Get-AzureADCurrentSessionInfo -WarningAction SilentlyContinue -ErrorAction STOP)
      return $true
    }
    catch {
      return $false
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #Test-AzureADConnection
