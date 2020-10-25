# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author: Jeff Brown
# Updated:    29-JUN-2020
# Status:     Deprecated

function ProcessLicense {
  <#
    .SYNOPSIS
    Processes one License against a user account.
    .DESCRIPTION
    Helper function for Add-TeamsUserLicense
    Teams services are available through assignment of different types of licenses.
    This command allows assigning one Skype related Office 365 licenses to a user account.
    .PARAMETER UserID
    The sign-in address or User Principal Name of the user account to modify.
    .PARAMETER LicenseSkuID
    The SkuID for the License to assign.
    .PARAMETER ReplaceLicense
    The SkuID for the License to replace (Resource Accounts only).
    .NOTES
    Uses Microsoft List for Licenses in SWITCH statement, update periodically or switch to lookup from DB(CSV or XLSX)
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$UserID,

    [Parameter(Mandatory = $true, HelpMessage = "SkuID of the License")]
    #[AllowEmptyString()] #unknown why this is there
    [string]$LicenseSkuID,

    [Parameter(Mandatory = $false, HelpMessage = "Replaces all Licenses currently assigned. Handle with Care!")]
    [switch]$ReplaceLicense

  )

  # Query currently assigned Licenses (SkuID) for User ($UserID)
  $ObjectId = (Get-AzureADUser -ObjectId "$UserID" -WarningAction SilentlyContinue).ObjectId
  $UserLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ObjectId -WarningAction SilentlyContinue).SkuId
  $SkuPartNumber = Get-SkuPartNumberfromSkuID -SkuID "$LicenseSkuID"

  # Checking if the Tenant has a License of that SkuID
  if ($LicenseSkuID -ne "") {
    # Checking whether the User already has this license assigned
    if ($UserLicenses -notcontains $LicenseSkuID) {
      # Trying to assign License, SUCCESS if so, ERROR if not.
      try {
        if ($PSBoundParameters.ContainsKey('ReplaceLicense')) {
          if ($PSCmdlet.ShouldProcess("'Replace all assigned Licenses on Object '$UserID' with provided License: '$SkuPartNumber'", 'New-AzureAdLicenseObject')) {
            Write-Warning -Message "Replace License is removing all licenses from the Object. Only the License specified through -LicenseSkuID will remain on the Object"
            $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID -RemoveSkuId $UserLicenses
          }
          else {
            Write-Verbose -Message "Licenses not replaced. Specified SkuId is added regardless" -Verbose
            $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
          }
        }
        else {
          $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
        }
        Set-AzureADUserLicense -ObjectId $UserID -AssignedLicenses $license -ErrorAction STOP
        $Result = GetActionOutputObject2 -Name $UserID -Result "SUCCESS: $SkuPartNumber assigned"
      }
      catch {
        #$Result = GetActionOutputObject2 -Name $UserID -Result "ERROR: Unable to assign $SkuPartNumber`: $_"
        Write-ErrorRecord $_ #This handles the error message in human readable format.
      }
    }
    else {
      $Result = GetActionOutputObject2 -Name $UserID -Result "INFO: User already has '$SkuPartNumber' assigned"
    }
  }
  else {
    $Result = GetActionOutputObject2 -Name $UserID -Result "WARNING: License '$SkuPartNumber' not found in tenant"
  }

  RETURN $Result
} #ProcessLicense
