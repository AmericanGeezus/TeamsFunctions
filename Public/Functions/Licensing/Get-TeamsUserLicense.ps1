# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

function Get-TeamsUserLicense {
  <#
	.SYNOPSIS
    Returns License information for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related Licenses found for a specific Object
		This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License
	.PARAMETER Identity
		The Identity/UPN/sign-in address for the user entered in the format <name>@<domain>.
    Aliases include: "UPN","UserPrincipalName","Username"
  .PARAMETER DisplayAll
    Displays all ServicePlans, not only relevant Teams Plans
	.EXAMPLE
		Get-TeamsUserLicense -Identity John@domain.com
		Displays all licenses assigned to User John@domain.com
	.EXAMPLE
		Get-TeamsUserLicense -Identity John@domain.com,Jane@domain.com
		Displays all licenses assigned to Users John@domain.com and Jane@domain.com
	.EXAMPLE
		Import-Csv User.csv | Get-TeamsUserLicense
    Displays all licenses assigned to Users from User.csv, Column Identity.
    The input file must have a single column heading of "Identity" with properly formatted UPNs.
	.NOTES
		Requires a connection to Azure Active Directory
  .FUNCTIONALITY
		Returns a list of Licenses assigned to a specific User depending on input
  .LINK
    Get-TeamsTenantLicense
    Set-TeamsUserLicense
    Test-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)

  #>

  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true,
      HelpMessage = "Enter the UPN or login name of the user account, typically <user>@<domain>.")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory = $false, HelpMessage = "Displays all ServicePlans")]
    [switch]$DisplayAll
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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

    # preparing Output Field Separator
    $OFS = ", "

    # Loading License Array
    $AllLicenses = $null
    $AllLicenses = $TeamsLicenses
    $AllServicePlans = $null
    $AllServicePlans = $TeamsServicePlans

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    foreach ($User in $Identity) {
      try {
        Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP | Out-Null
      }
      catch {
        throw $_
        continue
      }

      $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue
      $UserLicenseDetail = Get-AzureADUserLicenseDetail -ObjectId $User -WarningAction SilentlyContinue
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
      $UserLicensesSorted = $UserLicenses | Sort-Object IncludesTeams, IncludesPhoneSystem, FriendlyName
      [string]$LicensesFriendlyNames = ($UserLicensesSorted | Where-Object FriendlyName -NE $null).FriendlyName

      # Querying Service Plans
      $assignedServicePlans = $UserLicenseDetail.ServicePlans | Sort-Object ServicePlanName
      [System.Collections.ArrayList]$UserServicePlans = @()
      foreach ($ServicePlan in $assignedServicePlans) {
        $Lic = $null
        $Lic = $AllServicePlans | Where-Object ServicePlanName -EQ $ServicePlan.ServicePlanName
        if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          $LicObj = [PSCustomObject][ordered]@{
            FriendlyName       = $Lic.FriendlyName
            ServicePlanName    = $ServicePlan.ServicePlanName
            ProvisioningStatus = $ServicePlan.ProvisioningStatus
          }
          [void]$UserServicePlans.Add($LicObj)
        }
      }
      $UserServicePlansSorted = $UserServicePlans | Sort-Object Friendlyname, ProvisioningStatus, ServicePlanName
      [string]$ServicePlansFriendlyNames = ($UserServicePlansSorted | Where-Object FriendlyName -NE $null).FriendlyName

      $PhoneSystemLicense = ("MCOEV" -in $UserServicePlans.ServicePlanName)
      $AudioConfLicense = ("MCOMEETADV" -in $UserServicePlans.ServicePlanName)
      $PhoneSystemVirtual = ("MCOEV_VIRTUALUSER" -in $UserServicePlans.ServicePlanName)
      $CommonAreaPhoneLic = ("MCOCAP" -in $UserServicePlans.ServicePlanName)
      $CommunicationCreds = ("MCOPSTNC" -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom = ("MCOPSTN1" -in $UserServicePlans.ServicePlanName)
      $CallingPlanInt = ("MCOPSTN2" -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom120 = ("MCOPSTN5" -in $UserServicePlans.ServicePlanName)

      if ($CallingPlanDom120) {
        $currentCallingPlan = $AllLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN5"
      }
      elseif ($CallingPlanDom) {
        $currentCallingPlan = $AllLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN1"
      }
      elseif ($CallingPlanInt) {
        $currentCallingPlan = $AllLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN2"
      }
      else {
        [string]$currentCallingPlan = $null
      }

      $output = [PSCustomObject][ordered]@{
        UserPrincipalName         = $User
        DisplayName               = $DisplayName
        UsageLocation             = $UserObject.UsageLocation
        LicensesFriendlyNames     = $LicensesFriendlyNames
        ServicePlansFriendlyNames = $ServicePlansFriendlyNames
        AudioConferencing         = $AudioConfLicense
        CommoneAreaPhoneLicense   = $CommonAreaPhoneLic
        PhoneSystemVirtualUser    = $PhoneSystemVirtual
        PhoneSystem               = $PhoneSystemLicense
        CallingPlanDomestic120    = $CallingPlanDom120
        CallingPlanDomestic       = $CallingPlanDom
        CallingPlanInternational  = $CallingPlanInt
        CommunicationsCredits     = $CommunicationCreds
        CallingPlan               = $currentCallingPlan
        Licenses                  = $UserLicensesSorted
        ServicePlans              = $UserServicePlansSorted
      }

      Write-Output $output
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Get-TeamsUserLicense
