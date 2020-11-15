# Module:     TeamsFunctions
# Function:   Lookup
# Author:     David Eberhardt
# Updated:    14-NOV-2020
# Status:     PreLive




function Find-AzureAdUser {
  <#
	.SYNOPSIS
		Returns User Object in Azure AD from a provided UPN
	.DESCRIPTION
    Enables UPN lookup for AzureAD users
    This simplifies the query without having to rely on -ObjectId or -SearchString parameters in Get-AzureAdUser
	.PARAMETER Identity
		Required. The sign-in address or User Principal Name of the user account to query.
	.EXAMPLE
		Find-AzureAdUser John@domain.com
		Will Return the Azure AD Object for John@domain.com, otherwise returns error message from Get-AzureAdUser
  .INPUTS
    System.String
  .OUTPUTS
    Microsoft.Open.AzureAD.Model.User
	#>

  [CmdletBinding(DefaultParameterSetName = "Id")]
  [OutputType([Microsoft.Open.AzureAD.Model.User])]
  param(
    [Parameter(Mandatory, Position = 0, ParameterSetName = "Id", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "This is the UserID (UPN)")]
    [Alias('UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(Mandatory, Position = 0, ParameterSetName = "Search", HelpMessage = "This is the UserID (UPN)")]
    [ValidateLength(3, 255)]
    [string]$SearchString

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
    switch ($PsCmdlet.ParameterSetName) {
      "Id" {
        foreach ($Id in $Identity) {
          try {
            $User = Get-AzureADUser -ObjectId "$Id" -WarningAction SilentlyContinue -ErrorAction STOP
            Write-Output $User
          }
          catch [Microsoft.Open.AzureAD16.Client.ApiException] {
            Write-Verbose -Message "User '$Id' not found"
            return $null
          }
          catch {
            Write-Verbose -Message "User '$Id' not found"
            return $null
          }
        }
      }
      "Search" {
        Get-AzureADUser -All:$true -SearchString $SearchString -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      }
    }


  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Find-AzureAdUser
