# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author: David Eberhardtt
# Updated:    29-JUN-2020
# Status:     PreLive

function GetApplicationTypeFromAppId ($CsAppId) {
  <#
	.SYNOPSIS
		ApplicationType for AppId
	.DESCRIPTION
		Translates a given AppId into a friendly ApplicationType (Name)
	#>

  switch ($CsAppId) {
    "11cd3e2e-fccb-42ad-ad00-878b93575e07" { $CsApplicationType = "CallQueue" }
    "ce933385-9390-45d1-9512-c8d228074e07" { $CsApplicationType = "AutoAttendant" }
    Default { }
  }
  return $CsApplicationType
} #GetApplicationTypeFromAppId
