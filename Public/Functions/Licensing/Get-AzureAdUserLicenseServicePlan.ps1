# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-APR-2020
# Status:   RC


#CHECK whether to add Identity? (enables it to be piped) Enable to find it with Get-TeamsUserVoiceConfig?

function Get-AzureAdUserLicenseServicePlan {
  <#
	.SYNOPSIS
    Returns License information (ServicePlans) for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all ServicePlans (for Licenses assigned) for a specific Object
	.PARAMETER Identity
		The Identity, UserPrincipalname or UserName for the user.
  .PARAMETER FilterRelevantForTeams
    Filters the output and displays only Licenses relevant Teams Service Plans
  .PARAMETER FilterUnsuccessful
    Filters the output and displays only ServicePlans that don't have the ProvisioningStatus "Success"
	.EXAMPLE
		Get-AzureAdUserLicenseServicePlan [-Identity] John@domain.com
		Displays all Service Plans assigned through Licenses to User John@domain.com
	.EXAMPLE
		Get-AzureAdUserLicenseServicePlan -Identity John@domain.com,Jane@domain.com
		Displays all Service Plans assigned through Licenses to Users John@domain.com and Jane@domain.com
	.EXAMPLE
		Get-AzureAdUserLicenseServicePlan -Identity Jane@domain.com -FilterRelevantForTeams
		Displays all relevant Teams Service Plans assigned through Licenses to Jane@domain.com
	.EXAMPLE
		Get-AzureAdUserLicenseServicePlan -Identity Jane@domain.com -FilterUnsuccessful
		Displays all Service Plans assigned through Licenses to Jane@domain.com that are not provisioned successfully
	.EXAMPLE
		Import-Csv User.csv | Get-AzureAdUserLicenseServicePlan
    Displays all Service Plans assigned through Licenses to Users from User.csv, Column Identity.
    The input file must have a single column heading of "Identity" with properly formatted UPNs.
	.NOTES
		Requires a connection to Azure Active Directory
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
		Returns a list of Licenses assigned to a specific User depending on input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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
    [Alias('UserPrincipalName', 'Username', 'UPN')]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Displays only Service Plans relevant to Teams')]
    [switch]$FilterRelevantForTeams,

    [Parameter(HelpMessage = 'Displays only Service Plans that are not successfully provisioned')]
    [switch]$FilterUnsuccessful
  ) #param

  begin {
    Show-FunctionStatus -Level RC
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $Identity) {
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
        if ($null -ne $Lic) {
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): License:", ($Lic | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): ServicePlan:", ($ServicePlan | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }

          if ($PSBoundParameters.ContainsKey('FilterRelevantForTeams') -and -not $Lic.RelevantForTeams) {
            Write-Verbose -Message "Switch FilterRelevantForTeams: ServicePlan marked not relevant for Teams: '$($ServicePlan.ServicePlanName)'"
          }
          elseif ($PSBoundParameters.ContainsKey('FilterUnsuccessful') -and $ServicePlan.ProvisioningStatus -eq 'Success') {
            Write-Verbose -Message "Switch FilterUnsuccessful: ServicePlan successfully provisioned: '$($ServicePlan.ServicePlanName)'"
          }
          else {
            $LicObj = [PSCustomObject][ordered]@{
              ProductName        = if ($Lic.ProductName) { $Lic.ProductName } else { $ServicePlan.ServicePlanName }
              ServicePlanName    = $ServicePlan.ServicePlanName
              ProvisioningStatus = $ServicePlan.ProvisioningStatus
              RelevantForTeams   = $Lic.RelevantForTeams
            }
            [void]$UserServicePlans.Add($LicObj)
          }
        }
      }
      $UserServicePlansSorted = $UserServicePlans | Sort-Object ProductName, ProvisioningStatus, ServicePlanName

      Write-Information "'$User' - Service Plans for User '$DisplayName':"
      Write-Output $UserServicePlansSorted
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicenseServicePlan
