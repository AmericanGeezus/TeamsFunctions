# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    01-SEP-2020
# Status:     Live




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
  .COMPONENT
    SupportingFunction
    Licensing
  .FUNCTIONALITY
    Creates a new License Object to be applied with Set-AzureAdUserLicense
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    Set-TeamsUserLicense
  #>

  [CmdletBinding(ConfirmImpact = 'Low')]
  [OutputType([Microsoft.Open.AzureAD.Model.AssignedLicenses])] #LicenseObject
  param(
    [Parameter(Mandatory = $false, Position = 0, HelpMessage = 'SkuId of the license to Add')]
    [Alias('AddSkuId')]
    [string[]]$SkuId,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = 'SkuId of the license to Remove')]
    [string[]]$RemoveSkuId
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    #Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Adding Types
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client

  } #begin

  process {
    #Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $newLicensesObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

    # Creating AddLicenses
    if ($PSBoundParameters.ContainsKey('SkuId')) {
      foreach ($Sku in $SkuId) {
        $AddLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $AddLicenseObj.SkuId += $Sku

        $newLicensesObj.AddLicenses += $AddLicenseObj
      }
    }
    else {
      $newLicensesObj.AddLicenses = @()
    }

    # Creating RemoveLicenses
    if ($PSBoundParameters.ContainsKey('RemoveSkuId')) {
      $newLicensesObj.RemoveLicenses = $RemoveSkuId

    }

    return $newLicensesObj
  } #process

  end {
    #Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-AzureAdLicenseObject
