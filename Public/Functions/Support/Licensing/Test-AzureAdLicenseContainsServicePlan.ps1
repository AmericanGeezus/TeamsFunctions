# Module:   TeamsFunctions
# Function: Testing
# Author:   David Eberhardt
# Updated:  18-JUL-2021
# Status:   Live




function Test-AzureAdLicenseContainsServicePlan {
  <#
  .SYNOPSIS
    Tests whether a specific ServicePlan is included in an AzureAd License
  .DESCRIPTION
    If an AzureAd License contains a specific Service Plan thi function will return $TRUE, otherwise $FALSE
  .PARAMETER License
    Mandatory. The License to test
  .PARAMETER -ServicePlan
    Mandatory. The ServicePlan to query
  .EXAMPLE
    Test-AzureAdLicenseContainsServicePlan -License Office365E5 -ServicePlan MCOEV
    Will Return $TRUE only if the ServicePlan is part of the License 'Office365E5'
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    This CmdLet is a helper function to delegate validation tasks
  .FUNCTIONALITY
    Returns a boolean value for the presence of a ServicePlan in an AzureAd License
  .COMPONENT
    SupportingFunction
    Licensing
  .FUNCTIONALITY
    Tests whether the ServicePlan is included in the specified Plan License
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdLicenseContainsServicePlan.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, HelpMessage = 'License to be tested')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Intellisense or Get-AzureAdLicense"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $LicenseParams | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($LicenseParams.Count) records available")
        }
      })]
    [string]$License,

    [Parameter(Mandatory, HelpMessage = 'AzureAd Service Plan')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $ServicePlanNames) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'ServicePlan' - Invalid ServicePlan string. Supported Parameternames can be found with Intellisense or Get-AzureAdLicenseServicePlan (ServicePlanName)"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $ServicePlanNames | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($ServicePlanNames.Count) records available")
        }
      })]
    [string]$ServicePlan
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Lic = $AllLicenses | Where-Object ParameterName -EQ "$License"
    if ($ServicePlan -in $Lic.ServicePlans.ServicePlanName) {
      Write-Verbose -Message "License '$($Lic.ParameterName)'' ServicePlan '$ServicePlan' - Included"
      return $true
    }
    else {
      Write-Verbose -Message "License '$($Lic.ParameterName)'' ServicePlan '$ServicePlan' - NOT included"
      return $false
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-AzureAdLicenseContainsServicePlan
