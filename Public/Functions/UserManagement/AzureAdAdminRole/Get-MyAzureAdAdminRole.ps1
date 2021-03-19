# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    01-SEP-2020
# Status:     Live




function Get-MyAzureAdAdminRole {
  <#
	.SYNOPSIS
		Queries Admin Roles assigned to the currently connected User
	.DESCRIPTION
		Azure Active Directory Admin Roles assigned to the currently connected User
		Requires a Connection to AzureAd
    Querying '-Type Elibile' requires the Module AzureAdPreview installed
	.PARAMETER Type
		Optional. Switches query to Active (Default) or Eligible Admin Roles
    Eligibility can only be queried with Module AzureAdPreview installed
	.EXAMPLE
		Get-AzureAdAdminRole [-Type Active]
		Returns all active Admin Roles for the currently connected User
	.EXAMPLE
		Get-AzureAdAdminRole -Type Eligible
		Returns all eligible Admin Roles for the currently connected User
	.INPUTS
		System.String
	.OUTPUTS
		PSCustomObject
	.NOTES
    This is a wrapper for Get-AzureAdAdminRole targeting the currently connected User
  .COMPONENT
    UserAdmin
  .ROLE
    Activating Admin Roles
  .FUNCTIONALITY
    Queries active or eligible Privileged Identity roles for Administration of Teams for the currently connected User
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Enable-AzureAdAdminRole
  .LINK
    Enable-MyAzureAdAdminRole
  .LINK
    Get-AzureAdAdminRole
  .LINK
    Get-MyAzureAdAdminRole
  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(HelpMessage = 'Active, Eligible')]
    [ValidateSet('Active', 'Eligible')]
    #[ValidateSet('Active', 'Eligible','Group')]
    [string]$Type = 'Active'

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    Get-AzureAdAdminRole -Identity $(Get-AzureADCurrentSessionInfo).Account.Id -Type $Type

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-MyAzureAdAdminRole
