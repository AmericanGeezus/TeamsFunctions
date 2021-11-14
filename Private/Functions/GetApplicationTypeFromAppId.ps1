# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    29-JUN-2020
# Status:     Live

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
    #Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing CsAppId '$CsAppId'"

    switch ($CsAppId) {
      "11cd3e2e-fccb-42ad-ad00-878b93575e07" { $CsApplicationType = "CallQueue" }
      "ce933385-9390-45d1-9512-c8d228074e07" { $CsApplicationType = "AutoAttendant" }
      Default { }
    }
    return $CsApplicationType

  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end

} #GetApplicationTypeFromAppId
