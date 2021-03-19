# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live


#TODO Add Identity? Enable to pipe? Enable to find it with Get-TeamsUserVoiceConfig?

function Get-TeamsUserLicenseServicePlan {
  <#
	.SYNOPSIS
    Returns License information for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related ServicePlans (for Licenses assigned) for a specific Object
		This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License
	.PARAMETER Identity
		The Identity/UPN/sign-in address for the user entered in the format <name>@<domain>.
    Aliases include: "UPN","UserPrincipalName","Username"
  .PARAMETER DisplayAll
    Displays all ServicePlans, not only relevant Teams Plans
    Also displays AllLicenses and AllServicePlans object for further processing
	.EXAMPLE
		Get-TeamsUserLicenseServicePlan -Identity John@domain.com
		Displays all licenses assigned to User John@domain.com
	.EXAMPLE
		Get-TeamsUserLicenseServicePlan -Identity John@domain.com,Jane@domain.com
		Displays all licenses assigned to Users John@domain.com and Jane@domain.com
	.EXAMPLE
		Import-Csv User.csv | Get-TeamsUserLicenseServicePlan
    Displays all licenses assigned to Users from User.csv, Column Identity.
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
    [Alias('UPN', 'UserPrincipalName', 'Username')]
    [string[]]$Identity,

    [Parameter(Mandatory = $false, HelpMessage = 'Displays all ServicePlans')]
    [switch]$DisplayAll
  ) #param

  begin {
    Show-FunctionStatus -Level BETA
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
    if (-not $global:TeamsFunctionsMSAzureAdLicenses) {
      $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue
    }

    $AllLicenses = $null
    $AllLicenses = $global:TeamsFunctionsMSAzureAdLicenses

    if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) {
      $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue
    }

    $AllServicePlans = $null
    $AllServicePlans = $global:TeamsFunctionsMSAzureAdLicenseServicePlans


    #Idea: Get-TeamsUserLicenseServicePlan
    # Input: UPN, ServicePlan to filter (optional)
    # Output: Object (as table?) List of assigned Service Plans (license, Plan, status)

    (get-TeamsUserLicense -Identity x -DisplayAll).allserviceplans | Where-Object { $_.provisioningstatus -NE 'success' -and $_.RelevantForTeams -eq $true } | Select-Object ServicePlanName

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

      # Querying Licenses
      $assignedSkuPartNumbers = $UserLicenseDetail.SkuPartNumber
      [System.Collections.ArrayList]$UserLicenses = @()
      foreach ($PartNumber in $assignedSkuPartNumbers) {
        $Lic = $null
        $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ $Partnumber
        if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          [void]$UserLicenses.Add($Lic)
        }
      }
      $UserLicensesSorted = $UserLicenses | Sort-Object IncludesTeams, IncludesPhoneSystem, ProductName
      if ($PSBoundParameters.ContainsKey('DisplayAll')) {
        [string]$LicensesProductNames = $UserLicensesSorted.ProductName
      }
      else {
        [string]$LicensesProductNames = ($UserLicensesSorted | Where-Object { $_.IncludesTeams -or $_.IncludesPhoneSystem } ).ProductName
      }

      # Querying Service Plans
      $assignedServicePlans = $UserLicenseDetail.ServicePlans | Sort-Object ServicePlanName
      [System.Collections.ArrayList]$UserServicePlans = @()
      foreach ($ServicePlan in $assignedServicePlans) {
        $Lic = $null
        $Lic = $AllServicePlans | Where-Object ServicePlanName -EQ $ServicePlan.ServicePlanName
        if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
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
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): UserServicePlans:", ($UserServicePlans | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): UserServicePlansSorted:", ($UserServicePlansSorted | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }

      #TODO Keep but output relevant stuff
      if ($PSBoundParameters.ContainsKey('DisplayAll')) {
        [string]$ServicePlansProductNames = $UserServicePlansSorted.ProductName
      }
      else {
        #[string]$ServicePlansProductNames = ($UserServicePlansSorted | Where-Object { $_.RelevantForTeams }).ProductName
        [string]$ServicePlansProductNames = ($UserServicePlansSorted | Where-Object RelevantForTeams).ProductName
      }


      $output = [PSCustomObject][ordered]@{
        UserPrincipalName        = $User
        DisplayName              = $DisplayName
        ObjectId                 = $UserObject.ObjectId
        UsageLocation            = $UserObject.UsageLocation
        Licenses                 = $LicensesProductNames
        ServicePlans             = $ServicePlansProductNames
        AudioConferencing        = $AudioConfLicense
        CommoneAreaPhoneLicense  = $CommonAreaPhoneLic
        PhoneSystemVirtualUser   = $PhoneSystemVirtual
        PhoneSystem              = $PhoneSystemLicense
        PhoneSystemStatus        = $PhoneSystemStatus
        CallingPlanDomestic120   = $CallingPlanDom120
        CallingPlanDomestic      = $CallingPlanDom
        CallingPlanInternational = $CallingPlanInt
        CommunicationsCredits    = $CommunicationCredits
        CallingPlan              = $currentCallingPlan
      }

      Write-Information "Service Plans for User '$User':"
      Write-Output $output
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicenseServicePlan
