# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   PreLive




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
    Accepted Values can be retrieved with Get-TeamsLicense (Column ParameterName)
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
  .NOTES
    Requires a connection to Azure Active Directory
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
		Returns a list of Licenses on the Tenant depending on input
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Test-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Get-TeamsLicense
    Get-TeamsLicenseServicePlan
    Get-AzureAdLicense
    Get-AzureAdLicenseServicePlan
  #>

  [CmdletBinding()]
  [Alias('Get-TeamsTenantLicence')]
  [OutputType([Object[]])]
  param(
    [Parameter(Mandatory = $false, HelpMessage = "Displays all Parameters")]
    [switch]$Detailed,

    [Parameter(Mandatory = $false, HelpMessage = "Displays all ServicePlans")]
    [switch]$DisplayAll,

    [Parameter(Mandatory = $false, HelpMessage = 'License to be queried from the Tenant')]
    [ValidateScript( {
        $LicenseParams = (Get-TeamsLicense).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) {
          return $true
        }
        else {
          Write-Host "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Get-TeamsLicense" -ForegroundColor Red
          return $false
        }
      })]
    [string]$License

  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    #Loading License Array
    $AllLicenses = $null
    $AllLicenses = Get-TeamsLicense

    $AllLicenses | Add-Member -NotePropertyName Available -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Consumed -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Remaining -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Expiring -NotePropertyValue 0 -Force


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
      Write-Warning $_
      return
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    [System.Collections.ArrayList]$TenantLicenses = @()
    foreach ($tenantSKU in $tenantSKUs) {
      $Lic = $null
      $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ "$($tenantSKU.SkuPartNumber)"

      if ($null -ne $Lic) {
        $Lic.Available = $($tenantSKU.PrepaidUnits.Enabled)
        $Lic.Consumed = $($tenantSKU.ConsumedUnits)
        $Lic.Remaining = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
        $Lic.Expiring = $($tenantSKU.PrepaidUnits.Warning)

        [void]$TenantLicenses.Add($Lic)
      }
      else {
        if ($PSBoundParameters.ContainsKey('DisplayAll')) {
          $NewLic = [PSCustomObject][ordered]@{
            FriendlyName        = $null
            ProductName         = "Unknown"
            SkuPartNumber       = $tenantSKU.SkuPartNumber
            SkuId               = $tenantSKU.SkuId
            LicenseType         = "Unknown"
            ParameterName       = $null
            IncludesTeams       = $null
            IncludesPhoneSystem = $null
            Available           = $($tenantSKU.PrepaidUnits.Enabled)
            Consumed            = $($tenantSKU.ConsumedUnits)
            Remaining           = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
            Expiring            = $($tenantSKU.PrepaidUnits.Warning)
          }
          [void]$TenantLicenses.Add($NewLic)

        }
        else {
          if (!$PSBoundParameters.ContainsKey('Detailed')) {
            Write-Verbose "No entry found for '$($tenantSKU.SkuId)'"
          }
        }
      }

    }

    # Output
    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Output $TenantLicenses
    }
    else {
      Write-Output $TenantLicenses | Select-Object FriendlyName, SkuPartNumber, LicenseType, Available, Consumed, Remaining, Expiring
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-TeamsTenantLicense
