# Module:     TeamsFunctions
# Function:   Lookup
# Author:     David Eberhardt
# Updated:    14-NOV-2020
# Status:     PreLive


#TODO - Develop better - but adhere to use (or change that)

function Find-AzureAdUser {
  <#
	.SYNOPSIS
		Returns User Objects from Azure AD based on a search string or UserPrincipalName
	.DESCRIPTION
    Simplifies lookups with Get-AzureAdUser by using and combining -SearchString and -ObjectId Parameters.
    CmdLet can find uses by either query, if nothing is found with the Searchstring, another search is done via the ObjectId
    This simplifies the query without having to rely multiple queries with Get-AzureAdUser
	.PARAMETER SearchString
		Required for ParameterSet Search: A 3-255 digit string to be found on any Object.
	.PARAMETER Identity
		Required for ParameterSet Id: The sign-in address or User Principal Name of the user account to query.
	.EXAMPLE
		Find-AzureAdUser [-Search] "John"
    Will search for the string "John" and return all Azure AD Objects found
    If nothing has been found, will try to search for by identity
	.EXAMPLE
		Find-AzureAdUser [-Search] "John@domain.com"
		Will search for the string "John@domain.com" and return all Azure AD Objects found
    If nothing has been found, will try to search for by identity
	.EXAMPLE
		Find-AzureAdUser -Identity John@domain.com,Mary@domain.com
		Will search for the string "John@domain.com" and return all Azure AD Objects found
  .INPUTS
    System.String
  .OUTPUTS
    Microsoft.Open.AzureAD.Model.User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Find-AzureAdGroup
  .LINK
    Get-AzureAdUser
  #>

  [CmdletBinding(DefaultParameterSetName = 'Search')]
  [OutputType([Microsoft.Open.AzureAD.Model.User])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Search', ValueFromPipeline, HelpMessage = 'Search string')]
    [ValidateLength(3, 255)]
    [string]$SearchString,

    [Parameter(Mandatory, Position = 0, ParameterSetName = 'Id', ValueFromPipelineByPropertyName, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('UserPrincipalName', 'Id')]
    [string[]]$Identity

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
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


    foreach ($Id in $Identity) {

      switch ($PsCmdlet.ParameterSetName) {
        'Search' {
          $User = Get-AzureADUser -All:$true -SearchString "$SearchString" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
          if ( $User ) {
            return $User
          }
          else {
            if ($Searchstring -contains ' ') {
              $SearchString2 = $SearchString.split(' ') | Select-Object -Last 1
              Get-AzureADUser -All:$true -SearchString "$SearchString2" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            }
            elseif ($Searchstring -contains '.') {
              $SearchString2 = $SearchString.split('.') | Select-Object -Last 1
              Get-AzureADUser -All:$true -SearchString "$SearchString2" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            }
            else {
              Find-AzureAdUser -Identity "$SearchString"
            }
          }
        }

        'Id' {
          foreach ($Id in $Identity) {
            try {
              $User = Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction STOP
              Write-Output $User
            }
            catch [Microsoft.Open.AzureAD16.Client.ApiException] {
              Write-Verbose -Message "User '$Id' not found"
              continue
            }
            catch {
              Write-Verbose -Message "User '$Id' not found"
              continue
            }
          }

        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-AzureAdUser
