function Get-NewestModule {
  <#
  .SYNOPSIS
    Returns newest version of a Module, if found
  .DESCRIPTION
    Returns newest version of a Module, if found
  .PARAMETER Module
    One or more modules to Check
  .EXAMPLE
    Get-NewestModule AzureAd, AzureAdPreview
    Returns the newest version of the Modules AzureAd and AzureAdPreview if found
  .INPUTS
    System.String
  .OUTPUTS
    PSModuleInfo
  .FUNCTIONALITY
    Helper Function
  #>

  param (
    [string[]]$Module
  )

  $Modules = Get-Module -ListAvailable

  foreach ($M in $Module) {
    $MyModule = $Modules | Where-Object Name -EQ $M
    if ($MyModule) {
      $MyModule = $($MyModule | Sort-Object Version -Descending)[0]
    }
    Write-Output $MyModule

  }
}
