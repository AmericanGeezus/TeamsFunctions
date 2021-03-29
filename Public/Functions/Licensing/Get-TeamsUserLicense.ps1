﻿# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-APR-2020
# Status:   Live


#CHECK whether to add Identity? (enables it to be piped) Enable to find it with Get-TeamsUserVoiceConfig?

function Get-TeamsUserLicense {
  <#
	.SYNOPSIS
    Returns Teams License information for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related Licenses found for a specific Object
    Licenses and ServicePlans are nested in the respective parameters for further investigation
	.PARAMETER Identity
		The Identity, UserPrincipalname or UserName for the user.
  .PARAMETER DisplayAll
    Displays all Licenses, not only identified or relevant Teams Licenses
	.EXAMPLE
		Get-TeamsUserLicense [-Identity] John@domain.com
		Displays all licenses assigned to User John@domain.com
	.EXAMPLE
		Get-TeamsUserLicense -Identity John@domain.com,Jane@domain.com
		Displays all licenses assigned to Users John@domain.com and Jane@domain.com
	.EXAMPLE
		Import-Csv User.csv | Get-TeamsUserLicense
    Displays all licenses assigned to Users from User.csv, Column Identity.
    The input file must have a single column heading of "Identity" with properly formatted UPNs.
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
    [Alias('UserPrincipalName')]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Displays all Licenses, not only Teams relevant')]
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

    if ($PSBoundParameters.ContainsKey('DisplayAll')) {
      $previousFEL = $global:FormatEnumerationLimit
      $global:FormatEnumerationLimit = -1
    }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $Identity) {
      try {
        #CHECK Piping with UserPrincipalName, Identity from Get-CsOnlineUser
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
        #VALIDATE filter RelevantForTeams directly here since Get-AzureAdUserLicense will do "all" anyway
        if ($null -ne $Lic -or $Lic.IncludesTeams -or $Lic.IncludesPhoneSystem -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name): License:", ($Lic | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }

          [void]$UserLicenses.Add($Lic)
        }
      }
      $UserLicensesSorted = $UserLicenses | Sort-Object IncludesTeams, IncludesPhoneSystem, ProductName

      # Querying Service Plans
      $assignedServicePlans = $UserLicenseDetail.ServicePlans | Sort-Object ServicePlanName
      [System.Collections.ArrayList]$UserServicePlans = @()
      foreach ($ServicePlan in $assignedServicePlans) {
        $Lic = $null
        $Lic = $AllServicePlans | Where-Object ServicePlanName -EQ $ServicePlan.ServicePlanName
        #VALIDATE filter RelevantForTeams directly here since Get-AzureAdUserLicense will do "all" anyway
        #if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
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

      # Adding Boolean results
      $PhoneSystemLicense = ('MCOEV' -in $UserServicePlans.ServicePlanName)
      $AudioConfLicense = ('MCOMEETADV' -in $UserServicePlans.ServicePlanName)
      $PhoneSystemVirtual = ('MCOEV_VIRTUALUSER' -in $UserServicePlans.ServicePlanName)
      $CommonAreaPhoneLic = ('MCOCAP' -in $UserServicePlans.ServicePlanName)
      $CommunicationCredits = ('MCOPSTNC' -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom = ('MCOPSTN1' -in $UserServicePlans.ServicePlanName)
      $CallingPlanInt = ('MCOPSTN2' -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom120 = ('MCOPSTN5' -in $UserServicePlans.ServicePlanName)

      # Phone System
      if ( $PhoneSystemLicense ) {
        $PhoneSystemProvisioningStatus = $UserServicePlans | Where-Object ServicePlanName -EQ 'MCOEV'
        if ( $PhoneSystemProvisioningStatus.Count -gt 1 ) {
          # PhoneSystem assigned more than once!
          Write-Warning -Message "User '$User' Multiple assignments found for PhoneSystem. Please verify License assignment."
          $PhoneSystemStatus = ($PhoneSystemProvisioningStatus | Select-Object -ExpandProperty ProvisioningStatus) -join ', '

        }
        else {
          $PhoneSystemStatus = $PhoneSystemProvisioningStatus.ProvisioningStatus
        }

      }
      elseif ( $PhoneSystemVirtual ) {
        $PhoneSystemStatus = ($UserServicePlans | Where-Object ServicePlanName -EQ 'MCOEV_VIRTUALUSER').ProvisioningStatus
      }
      else {
        $PhoneSystemStatus = 'Unassigned'
      }

      # Calling Plans
      if ($CallingPlanDom120) {
        $currentCallingPlan = ($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN5').ProductName
      }
      elseif ($CallingPlanDom) {
        $currentCallingPlan = ($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN1').ProductName
      }
      elseif ($CallingPlanInt) {
        $currentCallingPlan = ($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN2').ProductName
      }
      else {
        [string]$currentCallingPlan = $null
      }


      $output = [PSCustomObject][ordered]@{
        UserPrincipalName        = $User
        DisplayName              = $DisplayName
        ObjectId                 = $UserObject.ObjectId
        UsageLocation            = $UserObject.UsageLocation
        Licenses                 = $UserLicensesSorted
        ServicePlans             = $UserServicePlansSorted
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

      #Adding Script Method to Licenses and ServicePlans
      $output.Licenses | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.ProductName } -Force
      $output.ServicePlans | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.ProductName } -Force

      Write-Output $output
    }
  } #process

  end {
    if ($PSBoundParameters.ContainsKey('DisplayAll')) {
      $global:FormatEnumerationLimit = $previousFEL
    }

    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicense
