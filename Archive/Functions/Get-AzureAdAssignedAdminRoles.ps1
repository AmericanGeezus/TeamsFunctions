# Module:     TeamsFunctions
# Function:   UserAdmin
# Author:     David Eberhardt
# Updated:    01-SEP-2020
# Status:     Deprecated




function Get-AzureAdAssignedAdminRoles {
  <#
	.SYNOPSIS
		Queries Admin Roles assigned to an Object
	.DESCRIPTION
		Azure Active Directory Admin Roles assigned to an Object
		Requires a Connection to AzureAd
	.EXAMPLE
		Get-AzureAdAssignedAdminRoles user@domain.com
		Returns an Object for all Admin Roles assigned
	.INPUTS
		System.String
	.OUTPUTS
		PSCustomObject
	.NOTES
    Returns an Object containing all Admin Roles assigned to a User.
    This is intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
    The Output can be used as baseline for other functions (-contains "Teams Service Admin")
  .COMPONENT
    UserAdmin
  .ROLE
    Activating Admin Roles
  .FUNCTIONALITY
    Enables eligible Privileged Identity roles for Administration of Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Enable-AzureAdAdminRole
  .LINK
    Get-AzureAdAssignedAdminRoles
  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the identity of the User to Query')]
    [Alias('UPN', 'UserPrincipalName', 'Username')]
    [string]$Identity

  ) #param

  begin {
    Show-FunctionStatus -Level Deprecated
    Write-Verbose -Message "Please use 'Get-AzureAdAdminRole' instead" -Verbose
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #Querying Admin Rights of authenticated Administrator
    $AssignedRoles = @()
    $RoleCounter = 0
    $Roles = Get-AzureADDirectoryRole
    FOREACH ($R in $Roles) {
      Write-Progress -Status 'Querying Members for Roles' -CurrentOperation "Role: '$($R.DisplayName)'" -Activity $MyInvocation.MyCommand -PercentComplete ($RoleCounter / $($Roles.Count) * 100)
      $RoleCounter++

      $Members = (Get-AzureADDirectoryRoleMember -ObjectId $R.ObjectId).UserprincipalName
      IF ($Identity -in $Members) {
        #Building list of Roles assigned to $Identity
        $AssignedRoles += $R
      }
    }

    #Output
    if ( -not $AssignedRoles ) {
      Write-Warning -Message 'No direct assignments found. This user may have Admin Role access through Group assignment or Privileged Admin Groups'
    }

    Write-Verbose -Message "Membership of Group assignments or Privileged Admin Groups is currently not queried by $($MyInvocation.MyCommand)" -Verbose
    Write-Output $AssignedRoles

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-AzureAdAssignedAdminRoles
