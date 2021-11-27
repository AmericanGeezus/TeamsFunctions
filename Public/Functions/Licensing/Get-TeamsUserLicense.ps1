# Module:   TeamsFunctions
# Function: Licensing
# Author:   David Eberhardt
# Updated:  01-APR-2020
# Status:   Live




function Get-TeamsUserLicense {
  <#
  .SYNOPSIS
    Returns Teams License information for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related Licenses found for a specific Object
    Licenses and ServicePlans are nested in the respective parameters for further investigation
  .PARAMETER UserPrincipalName
    The UserPrincipalName, ObjectId or Identity of the Object.
  .PARAMETER DisplayAll
    Displays all Licenses, not only identified or relevant Teams Licenses
  .EXAMPLE
    Get-TeamsUserLicense [-UserPrincipalName] John@domain.com
    Displays all licenses assigned to User John@domain.com
  .EXAMPLE
    Get-TeamsUserLicense -UserPrincipalName John@domain.com,Jane@domain.com
    Displays all licenses assigned to Users John@domain.com and Jane@domain.com
  .EXAMPLE
    Import-Csv User.csv | Get-TeamsUserLicense
    Displays all licenses assigned to Users from User.csv, Column UserPrincipalName.
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
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsUserLicense.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Required for performance. Removed with Disconnect-Me')]
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Enter the UPN or login name of the user account, typically <user>@<domain>.')]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Displays all Licenses, not only Teams relevant')]
    [switch]$DisplayAll
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

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
    foreach ($User in $UserPrincipalName) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
        $UserLicenseDetail = Get-AzureADUserLicenseDetail -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
      }
      catch {
        if ($_.Exception.Message.Contains('does not exist')) {
          Write-Error -Message "User '$User' - Account not valid" -Category ObjectNotFound -RecommendedAction 'Verify UserPrincipalName'
        }
        else {
          Write-Error "User '$User' - Exception Message: $($_.Exception.Message)"
        }
        continue
      }

      [string]$DisplayName = $UserObject.DisplayName

      # Querying Licenses
      $assignedSkuPartNumbers = $UserLicenseDetail.SkuPartNumber
      [System.Collections.ArrayList]$UserLicenses = @()
      foreach ($PartNumber in $assignedSkuPartNumbers) {
        $Lic = $null
        $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ $Partnumber
        if ($null -ne $Lic -or $Lic.IncludesTeams -or $Lic.IncludesPhoneSystem -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "  Function: $($MyInvocation.MyCommand.Name) - License:", ($Lic | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
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
        if (($null -ne $Lic -and $Lic.RelevantForTeams) -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "  Function: $($MyInvocation.MyCommand.Name) - License:", ($Lic | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "  Function: $($MyInvocation.MyCommand.Name) - ServicePlan:", ($ServicePlan | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
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
      $CommonAreaPhoneLic = ('MCOCAP' -in $UserLicenses.SkuPartNumber)
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
        CommonAreaPhoneLicense   = $CommonAreaPhoneLic
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
