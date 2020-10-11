# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    01-SEP-2020
# Status:     PreLive

function New-AzureAdLicenseObject {
  <#
	.SYNOPSIS
		Creates a new License Object for processing
	.DESCRIPTION
		Helper function to create a new License Object
	.PARAMETER SkuId
		SkuId(s) of the License to be added
	.PARAMETER RemoveSkuId
		SkuId(s) of the License to be removed
	.EXAMPLE
		New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd
		Will create a license Object for the MCOEV license .
	.EXAMPLE
		New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd -RemoveSkuId 440eaaa8-b3e0-484b-a8be-62870b9ba70a
		Will create a license Object based on the existing users License
    Adding the MCOEV license, removing the MCOEV_VIRTUALUSER license.
  .INPUTS
    System.String
  .OUTPUTS
    Microsoft.Open.AzureAD.Model.AssignedLicenses
  .NOTES
    This function does not require any connections to AzureAD.
    However, applying the output of this Function does.
    Used in Set-TeamsUserLicense and Add-TeamsUserLicense
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [OutputType([Microsoft.Open.AzureAD.Model.AssignedLicenses])] #LicenseObject
  param(
    [Parameter(Mandatory = $false, Position = 0, HelpMessage = "SkuId of the license to Add")]
    [Alias('AddSkuId')]
    [string[]]$SkuId,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "SkuId of the license to Remove")]
    [string[]]$RemoveSkuId
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"


    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    $newLicensesObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

    # Creating AddLicenses
    if ($PSBoundParameters.ContainsKey('SkuId')) {
      $AddLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      foreach ($Sku in $SkuId) {
        $AddLicenseObj.SkuId += $Sku
      }

      if ($PSCmdlet.ShouldProcess("New License Object: Microsoft.Open.AzureAD.Model.AssignedLicenses", "AddLicenses")) {
        $newLicensesObj.AddLicenses = $AddLicenseObj
      }
    }
    else {
      $newLicensesObj.AddLicenses = @()
    }

    # Creating RemoveLicenses
    if ($PSBoundParameters.ContainsKey('RemoveSkuId')) {
      $RemoveLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      foreach ($Sku in $RemoveSkuId) {
        $RemoveLicenseObj.SkuId += $Sku
      }

      if ($PSCmdlet.ShouldProcess("New License Object: Microsoft.Open.AzureAD.Model.AssignedLicenses", "RemoveLicenses")) {
        $newLicensesObj.RemoveLicenses += $RemoveLicenseObj
      }

    }

    return $newLicensesObj
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #New-AzureAdLicenseObject
