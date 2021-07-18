# Module:   TeamsFunctions
# Function: Licensing
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Get-TeamsTenantLicense {
  <#
  .SYNOPSIS
    Returns one or all Teams Tenant licenses from a Tenant
  .DESCRIPTION
    Returns an Object containing Teams related Licenses found in the Tenant
    Teams services can be provisioned through several different combinations of individual
    plans as well as add-on and grouped license SKUs. This command displays these license SKUs in a more friendly
    format with descriptive names, SkuPartNumber, active, consumed, remaining, and expiring licenses.
  .PARAMETER License
    Optional. Limits the Output to one license.
    Accepted Values can be retrieved with Get-AzureAdLicense (Column ParameterName)
  .PARAMETER Detailed
    Displays all Parameters.
    By default, only Parameters relevant to determine License availability are shown.
  .PARAMETER DisplayAll
    Displays all Licenses, not only relevant Teams Licenses
  .EXAMPLE
    Get-TeamsTenantLicense
    Displays detailed information about all Teams related licenses found on the tenant.
  .EXAMPLE
    Get-TeamsTenantLicense -License PhoneSystem
    Displays detailed information about the PhoneSystem license found on the tenant.
  .EXAMPLE
    Get-TeamsTenantLicense -ConciseView
    Displays all Teams Licenses found on the tenant, but only Name and counters.
  .EXAMPLE
    Get-TeamsTenantLicense -DisplayAll
    Displays detailed information about all licenses found on the tenant.
  .EXAMPLE
    Get-TeamsTenantLicense -ConciseView -DisplayAll
    Displays a concise view of all licenses found on the tenant.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Requires a connection to Azure Active Directory
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    Returns a list of Licenses on the Tenant depending on input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTenantLicense.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding()]
  [Alias('Get-TeamsTenantLicence')]
  [OutputType([Object[]])]
  param(
    [Parameter(Mandatory = $false, HelpMessage = 'Displays all Parameters')]
    [switch]$Detailed,

    [Parameter(Mandatory = $false, HelpMessage = 'Displays all ServicePlans')]
    [switch]$DisplayAll,

    [Parameter(Mandatory = $false, HelpMessage = 'License to be queried from the Tenant')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Get-AzureAdLicense"
          return $false
        }
      })]
    [string]$License

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Loading License Array
    if (-not $global:TeamsFunctionsMSAzureAdLicenses) {
      $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue
    }

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses

    try {
      if ($PSBoundParameters.ContainsKey('License')) {
        $SkuPartNumber = ($AllLicenses | Where-Object ParameterName -EQ $License).SkuPartNumber
        $tenantSKUs = Get-AzureADSubscribedSku | Where-Object SkuPartNumber -EQ $SkuPartNumber -ErrorAction STOP
      }
      else {
        $tenantSKUs = Get-AzureADSubscribedSku -ErrorAction STOP
      }
    }
    catch {
      Write-Error $_
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$TenantLicenses = @()
    foreach ($tenantSKU in $tenantSKUs) {
      $Lic = $null
      $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ "$($tenantSKU.SkuPartNumber)"

      if ($PSBoundParameters.ContainsKey('Debug')) {
        "Function: $($MyInvocation.MyCommand.Name): SkuPartNumber: $($tenantSKU.SkuPartNumber)" | Write-Debug
        "Function: $($MyInvocation.MyCommand.Name): tenantSKU", $tenantSKU | Write-Debug
      }

      # Current segmentation: Available = Enabled + Warning?; understand Suspended
      $LicUnitsAvailable = $tenantSKU.PrepaidUnits.Enabled + $tenantSKU.PrepaidUnits.Warning # + $tenantSKU.PrepaidUnits.Suspended # Omitted Suspended ones for now
      $LicUnitsConsumed = $tenantSKU.ConsumedUnits
      $LicUnitsRemaining = $LicUnitsAvailable - $LicUnitsConsumed
      $LicUnitsExpiring = $tenantSKU.PrepaidUnits.Warning

      if ($null -ne $Lic) {
        [void]$TenantLicenses.Add([TFTeamsTenantLicense]::new("$($Lic.ProductName)", "$($Lic.SkuPartNumber)", "$($Lic.LicenseType)", $Lic.ParameterName, $Lic.IncludesTeams, $Lic.IncludesPhoneSystem, $($Lic.SkuId), $Lic.ServicePlans, $LicUnitsAvailable, $LicUnitsConsumed, $LicUnitsRemaining, $LicUnitsExpiring))
      }
      else {
        Write-Verbose "No published License (Get-AzureAdLicense) found for SkuId '$($tenantSKU.SkuId)', SkuPartNumber '$($tenantSKU.SkuPartNumber)'"
        if ($PSBoundParameters.ContainsKey('DisplayAll')) {
          [void]$TenantLicenses.Add([TFTeamsTenantLicense]::new('Unknown', "$($tenantSKU.SkuPartNumber)", 'Unknown', $null, $null, $null, $($tenantSKU.SkuId), 'Unknown', $LicUnitsAvailable, $LicUnitsConsumed, $LicUnitsRemaining, $LicUnitsExpiring))
        }
      }
    }

    # Output
    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Output $TenantLicenses | Sort-Object ProductName
    }
    else {
      Write-Output $TenantLicenses | Sort-Object ProductName | Select-Object Available, Consumed, Remaining, ProductName, SkuPartNumber, LicenseType, ParameterName
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsTenantLicense
