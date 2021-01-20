# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  14-NOV-2020
# Status:   PreLive




function Test-AzureAdUser {
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
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    try {
      $UserObject = Get-AzureADUser -ObjectId "$Identity" -WarningAction SilentlyContinue -ErrorAction STOP
      if ( $null -ne $UserObject ) {
        return $true
      }
      else {
        return $false
      }
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException] {
      return $false
    }
    catch {
      return $false
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-AzureAdUser
