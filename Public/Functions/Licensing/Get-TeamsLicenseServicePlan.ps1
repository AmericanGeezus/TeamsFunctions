# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Deprecated




function Get-TeamsLicenseServicePlan {
  <#
	.SYNOPSIS
    License information for AzureAD Service Plans related to Teams
  .DESCRIPTION
    Returns an Object containing all Teams related License Service Plans
  .EXAMPLE
    Get-TeamsLicense
    Returns 39 Azure AD Licenses that relate to Teams for use in other commands
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
		Returns a list of License Service Plans
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Test-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Get-TeamsLicense
    Get-TeamsLicenseServicePlan
    Get-AzureAdLicense
    Get-AzureAdLicenseServicePlan
  #>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
  ) #param

  begin {
    Show-FunctionStatus -Level Deprecated
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    class ServicePlan {
      [string]$ProductName
      [ValidateNotNullOrEmpty()][string]$ServicePlanName
      [ValidatePattern("^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$")]
      [string]$ServicePlanId

      ServicePlan(
        [string]$ProductName,
        [string]$ServicePlanName,
        [string]$ServicePlanId
      ) {
        $this.ProductName = $ProductName
        $this.ServicePlanName = $ServicePlanName
        $this.ServicePlanId = $ServicePlanId
      }
    }

    class TeamsServicePlan : ServicePlan {
      [ValidateNotNullOrEmpty()][string]$FriendlyName
      [bool]$RelevantForTeams

      TeamsServicePlan(
        [string]$FriendlyName,
        [string]$ProductName,
        [string]$ServicePlanName,
        [string]$ServicePlanId,
        [bool]$RelevantForTeams
      ) : Base (
        [string]$ProductName,
        [string]$ServicePlanName,
        [string]$ServicePlanId
      ) {
        $this.FriendlyName = $FriendlyName
        $this.RelevantForTeams = $RelevantForTeams
      }
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    [System.Collections.ArrayList]$ServicePlans = @()

    # Main Service Plans
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Teams", "Teams", "TEAMS1", "57ff2da0-773e-42df-b2af-ffb7a2317929", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Teams AR DoD", "Teams AR DoD", "TEAMS_AR_DOD", "fd500458-c24c-478e-856c-a6067a8376cd", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Teams AR GCC High", "Teams AR GCC High", "TEAMS_AR_GCCHIGH", "9953b155-8aef-4c56-92f3-72b0487fce41", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Skype Online", "Skype for Business Online", "MCOSTANDARD", "0feaeb32-d00e-4d66-bd5a-43b5b83db82c", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Audio Conferencing", "Audio Conferencing", "MCOMEETADV", "3e26ee1f-8a5f-4d52-aee2-b81ce45c8f40", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Phone System", "Phone System", "MCOEV", "4828c8ec-dc2e-4779-b502-87ac9ce28ab7", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Phone System - Virtual User", "Phone System - Virtual User", "MCOEV_VIRTUALUSER", "f47330e9-c134-43b3-9993-e7f004506889", $true))

    # Additional Service Plans
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Skype Online (Midmarket)", "Skype for Business Online (Plan 2)", "MCOSTANDARD_MIDMARKET", "b2669e95-76ef-4e7e-a367-002f60a39f3e", $true))

    # Calling Plans
    [void]$ServicePlans.Add([TeamsServicePlan]::new("International Calling Plan", "International Calling Plan", "MCOPSTN2", "5a10155d-f5c1-411a-a8ec-e99aae125390", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Domestic Calling Plan", "Domestic Calling Plan (3000 min US / 1200 min EU plans)", "MCOPSTN1", "4ed3ff63-69d7-4fb7-b984-5aec7f605ca8", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Domestic Calling Plan (120 min calling plan)", "Domestic Calling Plan (120 min calling plan)", "MCOPSTN5", "54a152dc-90de-4996-93d2-bc47e670fc06", $true))
    [void]$ServicePlans.Add([TeamsServicePlan]::new("Communications Credits", "Communications Credits", "MCOPSTNC", "505e180f-f7e0-4b65-91d4-00d670bbd18c", $true))
    # No public ServicePlanId found
    #[void]$ServicePlans.Add([TeamsServicePlan]::new("Domestic Calling Plan (240 min calling plan)", "Domestic Calling Plan (240 min calling plan)", "MCOPSTN6", "", $false))

    #Template
    #[void]$ServicePlans.Add([TeamsServicePlan]::new("", "", "", "", $true))

    Write-Output $ServicePlans

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsLicenseServicePlan
