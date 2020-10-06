# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author: David Eberhardtt
# Updated:    29-JUN-2020
# Status:     PreLive

function GetAppIdFromApplicationType ($CsApplicationType) {
  <#
	.SYNOPSIS
		AppId for ApplicationType
	.DESCRIPTION
		Translates a given friendly ApplicationType (Name) into an AppId used by MS commands
	#>

  switch ($CsApplicationType) {
    "CallQueue" { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07" }
    "CQ" { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07" }
    "AutoAttendant" { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07" }
    "AA" { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07" }
    Default { }
  }
  return $CsAppId
} #GetAppIdFromApplicationType
