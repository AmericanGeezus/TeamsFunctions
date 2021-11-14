# Module:   TeamsFunctions
# Function: Lookup
# Author:	  David Eberhardt
# Updated:  19-DEC-2020
# Status:   Live




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
  #Show-FunctionStatus -Level Live

  foreach ($M in $Module) {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand) - Processing Module: '$M'"
    $MyModule = Get-Module "$M" -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

    Write-Output $MyModule

  }
}
