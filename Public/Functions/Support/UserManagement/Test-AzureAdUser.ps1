# Module:   TeamsFunctions
# Function: Support
# Author:		David Eberhardt
# Updated:  14-NOV-2020
# Status:   Live




function Test-AzureAdUser {
  <#
	.SYNOPSIS
		Tests whether a User exists in Azure AD (record found)
	.DESCRIPTION
		Simple lookup - does the User Object exist - to avoid TRY/CATCH statements for processing
	.PARAMETER UserPrincipalName
		Mandatory. The sign-in address, User Principal Name or Object Id of the Object.
	.EXAMPLE
		Test-AzureADUser -UserPrincipalName "$UPN"
		Will Return $TRUE only if the object $UPN is found.
		Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    x
  .COMPONENT
    SupportingFunction
		UserManagement
	.FUNCTIONALITY
    Tests whether an Azure Ad User exists in AzureAd
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    about_UserManagement
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
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $UserPrincipalName) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
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
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-AzureAdUser
