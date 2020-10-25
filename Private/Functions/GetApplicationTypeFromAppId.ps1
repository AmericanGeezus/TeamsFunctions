# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    29-JUN-2020
# Status:     PreLive

function GetApplicationTypeFromAppId {
  <#
	.SYNOPSIS
		ApplicationType for AppId
	.DESCRIPTION
		Translates a given AppId into a friendly ApplicationType (Name)
	#>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [string]$CsAppId

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    switch ($CsAppId) {
      "11cd3e2e-fccb-42ad-ad00-878b93575e07" { $CsApplicationType = "CallQueue" }
      "ce933385-9390-45d1-9512-c8d228074e07" { $CsApplicationType = "AutoAttendant" }
      Default { }
    }
    return $CsApplicationType

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #GetApplicationTypeFromAppId
