# Module:   TeamsFunctions
# Function: Licensing
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live


#TODO Add Identity? Enable to pipe? Enable to find it with Get-TeamsUserVoiceConfig?

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
    Also displays AllLicenses and AllServicePlans object for further processing
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
  .LINK
    Get-TeamsUserLicense
  .LINK
    Set-TeamsUserLicense
  .LINK
    Test-TeamsUserLicense
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($User in $Identity) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP
        $UserLicenseDetail = Get-AzureADUserLicenseDetail -ObjectId "$User" -WarningAction SilentlyContinue -ErrorAction STOP

        $UserLicenseObject = $null
        $UserLicenseObject = [TFTeamsUserLicense]::New()

        $UserLicenseObject.ObjectId = $UserObject.ObjectId
        $UserLicenseObject.UserPrincipalName = $User
        $UserLicenseObject.DisplayName = $UserObject.DisplayName
        $UserLicenseObject.UsageLocation = $UserObject.UsageLocation

      }
      catch {
        #Write-Error -Message "Error ocurred for User '$User': $($_.Exception.Message)" -Category InvalidResult
        throw $_
        continue
      }

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
      $UserLicenseObject.Licenses = $(
        if ($PSBoundParameters.ContainsKey('DisplayAll')) {
          $UserLicensesSorted.ProductName
        }
        else {
          $(($UserLicensesSorted | Where-Object { $_.IncludesTeams -or $_.IncludesPhoneSystem } ).ProductName)
        }
      )


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
      $UserLicenseObject.ServicePlans = $(
        if ($PSBoundParameters.ContainsKey('DisplayAll')) {
          $UserServicePlansSorted.ProductName
        }
        else {
          $(($UserServicePlansSorted | Where-Object RelevantForTeams).ProductName)
        }
      )

      $UserLicenseObject.AudioConferencing = ('MCOMEETADV' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.CommoneAreaPhoneLicense = ('MCOCAP' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.PhoneSystemVirtualUser = ('MCOEV_VIRTUALUSER' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.PhoneSystem = ('MCOEV' -in $UserServicePlans.ServicePlanName)

      $UserLicenseObject.CallingPlanDomestic120 = ('MCOPSTN5' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.CallingPlanDomestic = ('MCOPSTN1' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.CallingPlanInternational = ('MCOPSTN2' -in $UserServicePlans.ServicePlanName)
      $UserLicenseObject.CommunicationsCredits = ('MCOPSTNC' -in $UserServicePlans.ServicePlanName)

      # Phone System
      $UserLicenseObject.PhoneSystemStatus = $(
        if ( $UserLicenseObject.PhoneSystem ) {
          $PhoneSystemProvisioningStatus = $UserServicePlans | Where-Object ServicePlanName -EQ 'MCOEV'
          if ( $PhoneSystemProvisioningStatus.Count -gt 1 ) {
            # PhoneSystem assigned more than once!
            Write-Warning -Message "User '$User' Multiple assignments found for PhoneSystem. Please verify License assignment."
            $(($PhoneSystemProvisioningStatus | Select-Object -ExpandProperty ProvisioningStatus) -join ', ')
          }
          else {
            $PhoneSystemProvisioningStatus.ProvisioningStatus
          }
        }
        elseif ( $UserLicenseObject.PhoneSystemVirtualUser ) {
          $(($UserServicePlans | Where-Object ServicePlanName -EQ 'MCOEV_VIRTUALUSER').ProvisioningStatus)
        }
        else {
          'Unassigned'
        }
      )


      # Calling Plans
      $UserLicenseObject.CallingPlan = $(
        if ($UserLicenseObject.CallingPlanDomestic120) {
          $(($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN5').ProductName)
        }
        elseif ($UserLicenseObject.CallingPlanDomestic) {
          $(($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN1').ProductName)
        }
        elseif ($UserLicenseObject.CallingPlanInternational) {
          $(($AllLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN2').ProductName)
        }
        else {
          $null
        }
      )

      # DisplayAll
      if ($PSBoundParameters.ContainsKey('DisplayAll')) {
        $UserLicenseObject | Add-Member -MemberType NoteProperty -Name AllLicenses -Value $($UserLicensesSorted | Select-Object *)
        $UserLicenseObject | Add-Member -MemberType NoteProperty -Name AllServicePlans -Value $UserServicePlansSorted -
      }

      <#
      $UserLicenseObject.PSTypeNames.Add('TeamsUserLicense')
      Update-TypeData -TypeName TeamsUserLicense -DefaultDisplayPropertySet 'UserPrincipalName', 'DisplayName', 'UsageLocation', 'Licenses', 'ServicePlans', 'AudioConferencing', 'CommoneAreaPhoneLicense', 'PhoneSystemVirtualUser', 'PhoneSystem', 'PhoneSystemStatus', 'CallingPlanDomestic120', 'CallingPlanDomestic', 'CallingPlanInternational', 'CommunicationsCredits', 'CallingPlan'
      $UserLicenseObject.PSTypeNames.Add('TeamsUserLicenseFull')
      Update-TypeData -TypeName TeamsUserLicenseFull -DefaultDisplayPropertySet 'UserPrincipalName', 'DisplayName', 'UsageLocation', 'Licenses', 'ServicePlans', 'AudioConferencing', 'CommoneAreaPhoneLicense', 'PhoneSystemVirtualUser', 'PhoneSystem', 'PhoneSystemStatus', 'CallingPlanDomestic120', 'CallingPlanDomestic', 'CallingPlanInternational', 'CommunicationsCredits', 'CallingPlan', 'Identity'
      #>

      Write-Output $UserLicenseObject
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsUserLicense
