# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardtt
# Updated:  01-JUL-2020
# Status:   PreLive

function Test-AzureADUser {
  <#
	.SYNOPSIS
		Tests whether a User exists in Azure AD (record found)
	.DESCRIPTION
		Simple lookup - does the User Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to test.
	.EXAMPLE
		Test-AzureADUser -Identity $UPN
		Will Return $TRUE only if the object $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    try {
      $null = Get-AzureADUser -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP
      return $true
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException] {
      return $False
    }
    catch {
      return $False
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Test-AzureADUser
