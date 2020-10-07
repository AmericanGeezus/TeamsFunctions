# Module:   TeamsFunctions
# Function: Testing
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

function Test-TeamsUserHasCallPlan {
  <#
	.SYNOPSIS
		Tests an AzureAD-Object for a CallingPlan License
	.DESCRIPTION
    Any assigned Calling Plan found on the User (with exception of the Communication Credits license, which is add-on)
    will let this function return $TRUE
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to modify.
	.EXAMPLE
		Test-TeamsUserHasCallPlan -Identity User@domain.com -ServicePlan MCOEV
		Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
		This can be a part of a License.
	.EXAMPLE
		Test-TeamsUserHasCallPlan -Identity User@domain.com
    Will Return $TRUE only if one of the following license Packages are assigned:
    InternationalCallingPlan, DomesticCallingPlan, DomesticCallingPlan120, DomesticCallingPlan120b
	.NOTES
		This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
  .FUNCTIONALITY
    Returns a boolean value for when any of the Calling Plan licenses are found assigned to a specific user.
  .LINK
    Test-TeamsUserLicense
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity
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
    $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId) -WarningAction SilentlyContinue
    $UserLicenseSKU = $UserLicenseObject.SkuPartNumber

    $DOM120b = (($TeamsLicenses | Where-Object ParameterName -EQ DomesticCallingPlan120b).SkuPartNumber -in $UserLicenseSKU)
    $DOM120 = (($TeamsLicenses | Where-Object ParameterName -EQ DomesticCallingPlan120).SkuPartNumber -in $UserLicenseSKU)
    $DOM = (($TeamsLicenses | Where-Object ParameterName -EQ DomesticCallingPlan).SkuPartNumber -in $UserLicenseSKU)
    $INT = (($TeamsLicenses | Where-Object ParameterName -EQ InternationalCallingPlan).SkuPartNumber -in $UserLicenseSKU)

    if ($INT -or - $DOM -or $DOM120 -or $DOM120b) {
      return $true
    }
    else {
      return $false
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Test-TeamsUserCallPlan
