# Module:   TeamsFunctions
# Function: Licensing
# Author:    David Eberhardt
# Updated:  01-APR-2020
# Status:   Live




function Get-TeamsUserLicenseServicePlan {
  <#
  .SYNOPSIS
    Returns License information (ServicePlans) for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related ServicePlans (for Licenses assigned) for a specific Object
  .PARAMETER UserPrincipalName
    The UserPrincipalName, ObjectId or Identity of the Object.
  .PARAMETER DisplayAll
    Displays all ServicePlans, not only relevant Teams Service Plans
    Also displays AllLicenses and AllServicePlans object for further processing
  .EXAMPLE
    Get-TeamsUserLicenseServicePlan [-UserPrincipalName] John@domain.com
    Displays all licenses assigned to User John@domain.com
  .EXAMPLE
    Get-TeamsUserLicenseServicePlan -UserPrincipalName John@domain.com,Jane@domain.com
    Displays all licenses assigned to Users John@domain.com and Jane@domain.com
  .EXAMPLE
    Import-Csv User.csv | Get-TeamsUserLicenseServicePlan
    Displays all licenses assigned to Users from User.csv, Column UserPrincipalName, ObjectId or Identity.
    The input file must have a single column heading of "UserPrincipalName" with properly formatted UPNs.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Requires a connection to Azure Active Directory
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    Returns a list of Licenses assigned to a specific User depending on input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_Licensing
  .LINK
    about_UserManagement
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Get-TeamsUserLicenseServicePlan
  .LINK
    Set-TeamsUserLicense
  .LINK
    Test-TeamsUserLicense
  .LINK
    Get-AzureAdUserLicense
  .LINK
    Get-AzureAdUserLicenseServicePlan
  .LINK
    Get-AzureAdLicense
  .LINK
    Get-AzureAdLicenseServicePlan
  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the UPN or login name of the user account, typically <user>@<domain>.')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Displays all ServicePlans, not only Teams relevant ones')]
    [switch]$DisplayAll
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

    # preparing Output Field Separator
    $OFS = ', ' # do not remove - Automatic variable, used to separate elements!

    # Loading License Array
    if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) {
      $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue
    }

    $AllServicePlans = $null
    $AllServicePlans = $global:TeamsFunctionsMSAzureAdLicenseServicePlans

    if ($PSBoundParameters.ContainsKey('DisplayAll')) {
      $previousFEL = $global:FormatEnumerationLimit
      $global:FormatEnumerationLimit = -1
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $UserPrincipalName) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
        $UserLicenseDetail = Get-AzureADUserLicenseDetail -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
      }
      catch {
        #Write-Error -Message "Error ocurred for User '$User': $($_.Exception.Message)" -Category InvalidResult
        throw $_
        continue
      }

      [string]$DisplayName = $UserObject.DisplayName

      # Querying Service Plans
      $assignedServicePlans = $UserLicenseDetail.ServicePlans | Sort-Object ServicePlanName
      [System.Collections.ArrayList]$UserServicePlans = @()
      foreach ($ServicePlan in $assignedServicePlans) {
        $Lic = $null
        $Lic = $AllServicePlans | Where-Object ServicePlanName -EQ $ServicePlan.ServicePlanName
        if (($null -ne $Lic -and $Lic.RelevantForTeams) -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): License:", ($Lic | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): ServicePlan:", ($ServicePlan | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }

          $LicObj = [PSCustomObject][ordered]@{
            ProductName        = if ($Lic.ProductName) { $Lic.ProductName } else { $ServicePlan.ServicePlanName }
            ServicePlanName    = $ServicePlan.ServicePlanName
            ProvisioningStatus = $ServicePlan.ProvisioningStatus
            RelevantForTeams   = $Lic.RelevantForTeams
          }
          [void]$UserServicePlans.Add($LicObj)
        }
      }
      $UserServicePlansSorted = $UserServicePlans | Sort-Object ProductName, ProvisioningStatus, ServicePlanName

      Write-Information "'$User' - Service Plans for User '$DisplayName':"
      Write-Output $UserServicePlansSorted
    }
  } #process

  end {
    if ($PSBoundParameters.ContainsKey('DisplayAll')) {
      $global:FormatEnumerationLimit = $previousFEL
    }

    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicenseServicePlan
