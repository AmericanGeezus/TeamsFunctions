# Module:   TeamsFunctions
# Function: Testing
# Author:    David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Test-TeamsUserLicense {
  <#
  .SYNOPSIS
    Tests a License or License Package assignment against an AzureAD-Object
  .DESCRIPTION
    Teams requires a specific License combination (License) for a User.
    Teams Direct Routing requires a specific License (ServicePlan), namely 'Phone System'
    to enable a User for Enterprise Voice
    This Script can be used to ascertain either.
  .PARAMETER UserPrincipalName
    Mandatory. The sign-in address, User Principal Name or Object Id of the Object.
  .PARAMETER ServicePlan
    Defined and descriptive Name of the Service Plan to test.
    Only ServicePlanNames pertaining to Teams are tested.
    Returns $TRUE only if the ServicePlanName was found and the ProvisioningStatus is "Success" at least once.
    ServicePlans can be part of multiple licenses, for Example MCOEV (PhoneSystem) is part of any E5 license.
    For Testing against a full License Package, please use Parameter License
  .PARAMETER License
    Defined and descriptive Name of the License Combination to test.
    This will test whether one more more individual Service Plans are present on the Identity
  .EXAMPLE
    Test-TeamsUserLicense -Identity User@domain.com -ServicePlan MCOEV
    Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
    This can be a part of a License.
  .EXAMPLE
    Test-TeamsUserLicense -Identity User@domain.com -License Microsoft365E5
    Will Return $TRUE only if the license Package is assigned.
    Specific Names have been assigned to these Licenses
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
    ServicePlans can be part of multiple licenses, for Example MCOEV (PhoneSystem) is part of any E5 license.
  .COMPONENT
    SupportingFunction
    Licensing
  .FUNCTIONALITY
    Returns a boolean value for License or Serviceplan for a specific user.
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Get-TeamsUserLicenseServicePlan
  .LINK
    Set-TeamsUserLicense
  #>

  [CmdletBinding(DefaultParameterSetName = 'ServicePlan')]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'This is the UserID (UPN)')]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName,

    [Parameter(Mandatory, ParameterSetName = 'ServicePlan', HelpMessage = 'AzureAd Service Plan')]
    [string]$ServicePlan,

    [Parameter(Mandatory, ParameterSetName = 'License', HelpMessage = 'Teams License Package: E5,E3,S2')]
    [ValidateScript( {
        $LicenseParams = (Get-AzureAdLicense -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) {
          return $true
        }
        else {
          Write-Host "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Get-AzureAdLicense" -ForegroundColor Red
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

    # Loading License Array
    if (-not $global:TeamsFunctionsMSAzureAdLicenses) {
      $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue
    }

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses


  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($ID in $UserPrincipalName) {
      # Query User
      $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue
      $DisplayName = $UserObject.DisplayName
      $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId) -WarningAction SilentlyContinue
      # ParameterSetName ServicePlan VS License
      switch ($PsCmdlet.ParameterSetName) {
        'ServicePlan' {
          Write-Verbose -Message "'$DisplayName' Testing against '$ServicePlan'"
          if ($ServicePlan -in $UserLicenseObject.ServicePlans.ServicePlanName) {
            Write-Verbose -Message 'Service Plan found. Testing for ProvisioningStatus'
            #Checks if the Provisioning Status is also "Success"
            $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object -Property ServicePlanName -EQ -Value $ServicePlan)
            Write-Verbose -Message "ServicePlan: $ServicePlanStatus"
            if ('Success' -in $ServicePlanStatus.ProvisioningStatus) {
              Write-Verbose -Message 'Service Plan found and provisioned successfully.'
              if ( $ServicePlanStatus.ProvisioningStatus.Count -gt 1 ) {
                Write-Warning -Message 'Multiple assignments found for PhoneSystem. Please verify License assignment!'
              }
              return $true
            }
            else {
              Write-Verbose -Message 'Service Plan found, but not provisioned successfully.'
              return $false
            }
          }
          else {
            Write-Verbose -Message 'Service Plan not found.'
            return $false
          }
        }
        'License' {
          Write-Verbose -Message "'$DisplayName' Testing against '$License'"
          $UserLicenseSKU = $UserLicenseObject.SkuPartNumber
          $Sku = ($AllLicenses | Where-Object ParameterName -EQ $License).SkuPartNumber
          if ($Sku -in $UserLicenseSKU) {
            return $true
          }
          else {
            return $false
          }
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Test-TeamsUserLicense
