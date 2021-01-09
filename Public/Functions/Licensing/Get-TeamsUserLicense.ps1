# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




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
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = "Enter the UPN or login name of the user account, typically <user>@<domain>.")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory = $false, HelpMessage = "Displays all ServicePlans")]
    [switch]$DisplayAll
  ) #param

  begin {
    Show-FunctionStatus -Level Live
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

    # preparing Output Field Separator
    $OFS = ", "

    # Loading License Array
    $AllLicenses = $null
    $AllLicenses = Get-TeamsLicense
    $AllServicePlans = $null
    $AllServicePlans = Get-TeamsLicenseServicePlan

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $Identity) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP | Select-Object UsageLocation, DisplayName
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
      $CommunicationCredits = ("MCOPSTNC" -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom = ("MCOPSTN1" -in $UserServicePlans.ServicePlanName)
      $CallingPlanInt = ("MCOPSTN2" -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom120 = ("MCOPSTN5" -in $UserServicePlans.ServicePlanName)

      # Phone System
      if ( $PhoneSystemLicense ) {
        $PhoneSystemProvisioningStatus = $UserServicePlans | Where-Object ServicePlanName -EQ "MCOEV"
        if ( $PhoneSystemProvisioningStatus.Count -gt 1 ) {
          # PhoneSystem assigned more than once!
          Write-Warning -Message "User '$User' Multiple assignments found for PhoneSystem. Please verify License assignment."
          $PhoneSystemStatus = ($PhoneSystemProvisioningStatus | Select-Object -ExpandProperty ProvisioningStatus) -join ", "

        }
        else {
          $PhoneSystemStatus = $PhoneSystemProvisioningStatus.ProvisioningStatus
        }

      }
      elseif ( $PhoneSystemVirtual ) {
        $PhoneSystemStatus = ($UserServicePlans | Where-Object ServicePlanName -EQ "MCOEV_VIRTUALUSER").ProvisioningStatus
      }
      else {
        $PhoneSystemStatus = "Unassigned"
      }

      # Calling Plans
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
        PhoneSystemStatus         = $PhoneSystemStatus
        CallingPlanDomestic120    = $CallingPlanDom120
        CallingPlanDomestic       = $CallingPlanDom
        CallingPlanInternational  = $CallingPlanInt
        CommunicationsCredits     = $CommunicationCredits
        CallingPlan               = $currentCallingPlan
        Licenses                  = $UserLicensesSorted
        ServicePlans              = $UserServicePlansSorted
      }

      Write-Output $output
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicense
