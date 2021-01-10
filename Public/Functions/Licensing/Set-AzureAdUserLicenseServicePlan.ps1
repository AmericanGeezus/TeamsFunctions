# Module:   TeamsFunctions
# Function: VoiceConfig/Licensing
# Author:		David Eberhardt
# Updated:  10-JAN-2021
# Status:   BETA




function Set-AzureAdUserLicenseServicePlan {
  <#
  .SYNOPSIS
    Changes one or more Service Plans for Licenses assigned to an AzureAD Object
  .DESCRIPTION
    Enables or disables a ServicePlan from all assigned Licenses to an AzureAD Object
    Supports all Service Plans listed in Get-AzureAdLicenseServicePlan
  .PARAMETER Identity
    Required. UserPrincipalName of the Object to be manipulated
  .PARAMETER Enable
    Optional. Service Plans to be enabled (main function)
    Accepted Values can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
    No action is taken for any Licenses not containing this Service Plan
  .PARAMETER Disable
    Optional. Service Plans to be disabled (alternative function)
    Accepted Values can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
    No action is taken for any Licenses not containing this Service Plan
	.PARAMETER PassThru
		Optional. Displays User License Object after action.
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Enable MCOEV
    Enables the Service Plan Phone System (MCOEV) on all Licenses assigned to Name@domain.com
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Disable MCOEV,TEAMS1
    Disables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Enable MCOEV,TEAMS1 -PassThru
    Enables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com
    Displays User License Object after application
  .NOTES
    Data in Get-AzureAdLicenseServicePlan as per Microsoft Docs Article: Published Service Plan IDs for Licensing
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
    This script changes the AzureAD Object provided by enabling or disabling Service Plans on all Licenses assigned to an AzureAd Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Set-TeamsUserLicense
  .LINK
    Get-AzureAdLicense
  .LINK
    Get-AzureAdLicenseServicePlan
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias("Set-ServicePlan")]
  [OutputType([Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(HelpMessage = 'Service Plan(s) to be enabled on this Object')]
    [ValidateScript( {
        $ServicePlanNamesEnable = (Get-AzureAdLicenseServicePlan).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $ServicePlanNamesEnable) {
          return $true
        }
        else {
          Write-Host "Parameter 'Enable' - Invalid Service Plan name. Supported Values can be found with Get-AzureAdLicenseServicePlan (Column ServicePlanName)" -ForegroundColor Red
          return $false
        }
      })]
    [string[]]$Enable,

    [Parameter(HelpMessage = 'Service Plan(s) to be disabled on this Object')]
    [ValidateScript( {
        $ServicePlanNamesDisable = (Get-AzureAdLicenseServicePlan).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $ServicePlanNamesDisable) {
          return $true
        }
        else {
          Write-Host "Parameter 'Disable' - Invalid Service Plan name. Supported Values can be found with Get-AzureAdLicenseServicePlan (Column ServicePlanName)" -ForegroundColor Red
          return $false
        }
      })]
    [string[]]$Disable,

    [Parameter(Mandatory = $false)]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    #Loading Service Plan data
    if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) {
      $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue
    }

    if ($PSBoundParameters.ContainsKey('Enable') -and $PSBoundParameters.ContainsKey('Disable')) {
      # Check if any are listed in both!
      Write-Verbose -Message "Validating input for Enable and Disable (identifying inconsistencies)"

      foreach ($Lic in $Enable) {
        if ($Lic -in $Disable) {
          Write-Error -Message "Invalid combination. '$Lic' cannot be enabled AND disabled" -Category LimitsExceeded -RecommendedAction "Please specify only once!" -ErrorAction Stop
        }
      }
    }

    #endregion

    #region Queries
    # Querying licenses in the Tenant to compare SKUs
    #CHECK Still needed?
    try {
      Write-Verbose -Message "Querying Licenses from the Tenant"
      $TenantLicenses = Get-TeamsTenantLicense -Detailed -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }
    #endregion

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region ForEach Identity
    foreach ($ID in $Identity) {
      #region Object Verification
      # Querying User
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction STOP
        Write-Verbose -Message "[PROCESS] $($UserObject.UserPrincipalName)"
      }
      catch {
        Write-Error -Message "User '$ID' - Account not valid" -Category ObjectNotFound -RecommendedAction "Verify UserPrincipalName"
        continue
      }

      # License Query from Object
      $ObjectAssignedLicenses = Get-AzureADUserLicenseDetail -ObjectId $UserObject.ObjectId -WarningAction SilentlyContinue

      # Creating new License Object
      $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      #endregion

      Write-Verbose -Message "Processing Service Plans"

      # iterating each License assigned to this Object
      foreach ($L in $ObjectAssignedLicenses) {
        # Determine License Name
        $LicenseName = ($TenantLicenses | Where-Object SkuPartNumber -EQ $L.SkuPartNumber).FriendlyName
        Write-Verbose -Message "License '$LicenseName'"

        # Verifying the License is still available in the Tenant
        $StandardLicense = Get-AzureADSubscribedSku | Where-Object { $_.SkuId -eq $L.SkuId }
        if ( -not $StandardLicense) {
          Write-Warning -Message "License '$LicenseName' - License not found in the Tenant!?"
          continue
        }

        Write-Verbose -Message "StandardLicense: $StandardLicense"
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name): StandardLicense:", ($StandardLicense | Out-String).Trim() | Write-Debug
        }

        # Creating a new License Object
        $License = New-AzureAdLicenseObject -AddSkuId $L.SkuId
        $DisabledPlans = $null
        $DisabledPlans = $L.ServicePlans | Where-Object ProvisioningStatus -EQ "Disabled" | Select-Object ServicePlanId -ExpandProperty ServicePlanId

        Write-Verbose -Message "Disabled Plans for Lic: $DisabledPlans"
        $($License.AddLicenses).DisabledPlans = $DisabledPlans

        Write-Verbose -Message "AddLicenses: $($License.AddLicenses)"
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name): License Object:", ($License.AddLicenses | Out-String).Trim() | Write-Debug
          "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($License.AddLicenses.DisabledPlans | Out-String).Trim() | Write-Debug
        }

        try {
          #region Enable - Iterating all provided Service Plans to enable
          if ($PSBoundParameters.ContainsKey('Enable')) {
            foreach ($S in $Enable) {
              # Checking Service Plan is valid
              Write-Verbose -Message "User '$Identity' - Enable Service Plan: '$S'"
              $ServicePlanToEnable = $null
              $ServicePlanToEnable = $TeamsFunctionsMSAzureAdLicenseServicePlans | Where-Object ServicePlanName -EQ "$S"
              if ( -not $ServicePlanToEnable) {
                Write-Error -Message "User '$Identity' - Enable Service Plan: '$S' not a valid Service Plan Name"
                continue
              }

              if ($PSBoundParameters.ContainsKey('Debug')) {
                "Function: $($MyInvocation.MyCommand.Name): ServicePlanToEnable:", ($ServicePlanToEnable | Out-String).Trim() | Write-Debug
              }

              # Checking whether Service Plan is disabled
              if ( $ServicePlanToEnable.ServicePlanId -in $License.DisabledPlans ) {
                $($License.AddLicenses).DisabledPlans -= $ServicePlanToEnable.ServicePlanId

                if ($PSBoundParameters.ContainsKey('Debug')) {
                  "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($($License.AddLicenses).DisabledPlans | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
                }
              }
              else {
                Write-Verbose -Message "User '$Identity' - License '$LicenseName' - Service Plan '$S' already enabled, skipping"
                continue
              }
            }

            if ( $L.DisabledPlans.Count -gt $License.DisabledPlans.Count) {
              Write-Verbose -Message "User '$Identity' - License '$LicenseName' - No Service Plans to enable"
              continue
            }
            else {
              $LicensesToAssign.AddLicenses += $License
            }

          }
          #endregion

          #region Disable - Iterating all provided Service Plans to disable
          if ($PSBoundParameters.ContainsKey('Disable')) {
            foreach ($S in $Disable) {
              # Checking Service Plan is valid
              Write-Verbose -Message "User '$Identity' - Disable Service Plan: '$S'"
              $ServicePlanToDisable = $null
              $ServicePlanToDisable = $TeamsFunctionsMSAzureAdLicenseServicePlans | Where-Object ServicePlanName -EQ "$S"
              if ( -not $ServicePlanToDisable) {
                Write-Error -Message "User '$Identity' - Disable Service Plan: '$S' not a valid Service Plan Name"
                continue
              }

              if ($PSBoundParameters.ContainsKey('Debug')) {
                "Function: $($MyInvocation.MyCommand.Name): ServicePlanToDisable:", ($ServicePlanToDisable | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
              }

              # Checking whether Service Plan is disabled
              if (-not ($ServicePlanToDisable.ServicePlanId -in $License.DisabledPlans)) {
                $($License.AddLicenses).DisabledPlans += $ServicePlanToDisable.ServicePlanId

                if ($PSBoundParameters.ContainsKey('Debug')) {
                  "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($($License.AddLicenses).DisabledPlans | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
                }
              }
              else {
                Write-Verbose -Message "User '$Identity' - License '$LicenseName' - Service Plan '$S' already deactivated, skipping"
                continue
              }
            }

            if ( $L.DisabledPlans.Count -eq $License.DisabledPlans.Count) {
              Write-Verbose -Message "User '$Identity' - License '$LicenseName' - No Service Plans to disable"
              continue
            }
            else {
              $LicensesToAssign.AddLicenses = $License
            }
          }
          #endregion
        }
        catch {
          throw
        }

        #CHECK this does not use New-AzureAdLicenseObject, but does it need to?
        Write-Verbose -Message "License '$LicenseName' - Adding to list"
        [void]$LicensesToAssign.AddLicenses.Add($License)

      }
      #endregion

      "Function: $($MyInvocation.MyCommand.Name): LicensesToAssign:", ($LicensesToAssign.AddLicenses | Out-String).Trim() | Write-Debug
      "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($LicensesToAssign.AddLicenses.DisabledPlans | Out-String).Trim() | Write-Debug

      # Executing Assignment
      if ($PSCmdlet.ShouldProcess("$ID", "Set-AzureADUserLicense")) {
        #Assign $LicenseObject to each User
        Write-Verbose -Message "'$ID' - Setting Licenses"
        Set-AzureADUserLicense -ObjectId $ID -AssignedLicenses $LicensesToAssign
        Write-Verbose -Message "'$ID' - Setting Licenses: Done"
      }

      # Output
      if ($PassThru) {
        Get-TeamsUserLicense -Identity $Identity
      }

    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-AzureAdUserLicenseServicePlan
