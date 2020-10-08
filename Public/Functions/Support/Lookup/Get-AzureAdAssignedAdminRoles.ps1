﻿# Module:     TeamsFunctions
# Function:   Lookup
# Author: David Eberhardtt
# Updated:    01-SEP-2020
# Status:     Live

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
	#>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the identity of the User to Query")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    #Querying Admin Rights of authenticated Administator
    $AssignedRoles = @()
    $Roles = Get-AzureADDirectoryRole
    FOREACH ($R in $Roles) {
      $Members = (Get-AzureADDirectoryRoleMember -ObjectId $R.ObjectId).UserprincipalName
      IF ($Identity -in $Members) {
        #Builing list of Roles assigned to $AdminUPN
        $AssignedRoles += $R
      }
    }

    #Output
    Write-Output $AssignedRoles
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Get-AzureAdAssignedAdminRoles