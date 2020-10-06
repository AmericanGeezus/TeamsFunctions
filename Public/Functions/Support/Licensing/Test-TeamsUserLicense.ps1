# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

function Test-TeamsUserLicense {
  <#
	.SYNOPSIS
		Tests a License or License Package assignment against an AzureAD-Object
	.DESCRIPTION
		Teams requires a specific License combination (LicensePackage) for a User.
		Teams Direct Routing requires a specific License (ServicePlan), namely 'Phone System'
		to enable a User for Enterprise Voice
		This Script can be used to ascertain either.
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to modify.
	.PARAMETER ServicePlan
		Defined and descriptive Name of the Service Plan to test.
		Only ServicePlanNames pertaining to Teams are tested.
		Returns $TRUE only if the ServicePlanName was found and the ProvisioningStatus is "Success"
		NOTE: ServicePlans can be part of a license, for Example MCOEV (PhoneSystem) is part of an E5 license.
		For Testing against a full License Package, please use Parameter LicensePackage
	.PARAMETER LicensePackage
		Defined and descriptive Name of the License Combination to test.
		This will test whether one more more individual Service Plans are present on the Identity
	.EXAMPLE
		Test-TeamsUserLicense -Identity User@domain.com -ServicePlan MCOEV
		Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
		This can be a part of a License.
	.EXAMPLE
		Test-TeamsUserLicense -Identity User@domain.com -LicensePackage Microsoft365E5
		Will Return $TRUE only if the license Package is assigned.
		Specific Names have been assigned to these LicensePackages
	.NOTES
		This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
  .FUNCTIONALITY
    Returns a boolean value for LicensePackage or Serviceplan for a specific user.
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
  #>

  [CmdletBinding(DefaultParameterSetName = "ServicePlan")]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity,

    [Parameter(Mandatory = $true, ParameterSetName = "ServicePlan", HelpMessage = "AzureAd Service Plan")]
    [string]$ServicePlan,

    [Parameter(Mandatory = $true, ParameterSetName = "LicensePackage", HelpMessage = "Teams License Package: E5,E3,S2")]
    [ValidateScript( {
        if ($_ -in $TeamsLicenses.ParameterName) {
          return $true
        }
        else {
          Write-Host "Parameter 'LicensePackage' - Invalid license string. Please specify a ParameterName from `$TeamsLicenses:" -ForegroundColor Red
          Write-Host "$($TeamsLicenses.ParameterName)"
          return $false
        }
      })]
    [string]$LicensePackage

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    # Query User
    $UserObject = Get-AzureADUser -ObjectId "$Identity" -WarningAction SilentlyContinue
    $DisplayName = $UserObject.DisplayName
    $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId) -WarningAction SilentlyContinue

    # ParameterSetName ServicePlan VS LicensePackage
    switch ($PsCmdlet.ParameterSetName) {
      "ServicePlan" {
        Write-Verbose -Message "'$DisplayName' Testing against '$ServicePlan'"
        if ($ServicePlan -in $UserLicenseObject.ServicePlans.ServicePlanName) {
          Write-Verbose -Message "Service Plan found. Testing for ProvisioningStatus"
          #Checks if the Provisioning Status is also "Success"
          $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object -Property ServicePlanName -EQ -Value $ServicePlan)
          Write-Verbose -Message "ServicePlan: $ServicePlanStatus"
          if ('Success' -eq $ServicePlanStatus.ProvisioningStatus) {
            Write-Verbose -Message "Service Plan found and provisioned successfully."
            return $true
          }
          else {
            Write-Verbose -Message "Service Plan found, but not provisioned successful."
            return $false
          }
        }
        else {
          Write-Verbose -Message "Service Plan not found."
          return $false
        }
      }
      "LicensePackage" {
        Write-Verbose -Message "'$DisplayName' Testing against '$LicensePackage'"
        $UserLicenseSKU = $UserLicenseObject.SkuPartNumber
        $Sku = ($TeamsLicenses | Where-Object ParameterName -EQ $LicensePackage).SkuPartNumber
        if ($Sku -in $UserLicenseSKU) {
          return $true
        }
        else {
          return $false
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Test-TeamsUserLicense
