# Module:   TeamsFunctions
# Function: VoiceConfig/Licensing
# Author:   David Eberhardt
# Updated:  10-JAN-2021
# Status:   Live




function Set-AzureAdUserLicenseServicePlan {
  <#
  .SYNOPSIS
    Changes one or more Service Plans for Licenses assigned to an AzureAD Object
  .DESCRIPTION
    Enables or disables a ServicePlan from all assigned Licenses to an AzureAD Object
    Supports all Service Plans listed in Get-AzureAdLicenseServicePlan
  .PARAMETER UserPrincipalName
    The UserPrincipalName, ObjectId or Identity of the Object.
  .PARAMETER Enable
    Optional. Service Plans to be enabled (main function)
    Accepted Values are available with Intellisense and can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
    No action is taken for any Licenses not containing this Service Plan
  .PARAMETER Disable
    Optional. Service Plans to be disabled (alternative function)
    Accepted Values are available with Intellisense and can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
    No action is taken for any Licenses not containing this Service Plan
  .PARAMETER PassThru
    Optional. Displays User License Object after action.
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan [-UserPrincipalName] Name@domain.com -Enable MCOEV
    Enables the Service Plan Phone System (MCOEV) on all Licenses assigned to Name@domain.com
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan -UserPrincipalName Name@domain.com -Disable MCOEV,TEAMS1
    Disables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com
  .EXAMPLE
    Set-AzureAdUserLicenseServicePlan -UserPrincipalName Name@domain.com -Enable MCOEV,TEAMS1 -PassThru
    Enables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com
    Displays User License Object after application
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .NOTES
    Data in Get-AzureAdLicenseServicePlan as per Microsoft Docs Article: Published Service Plan IDs for Licensing
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    Changes the AzureAD Object provided by enabling or disabling Service Plans on each License assigned (if present) to an AzureAd Object
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-AzureAdUserLicenseServicePlan.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Set-ServicePlan')]
  [OutputType([Void])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(HelpMessage = 'Service Plan(s) to be enabled on this Object')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $ServicePlanNames) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'ServicePlan' - Invalid ServicePlan string. Supported Parameternames can be found with Intellisense or Get-AzureAdLicenseServicePlan (ServicePlanName)"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $ServicePlanNames | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($ServicePlanNames.Count) records available")
        }
      })]
    [string[]]$Enable,

    [Parameter(HelpMessage = 'Service Plan(s) to be disabled on this Object')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $ServicePlanNames) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'ServicePlan' - Invalid ServicePlan string. Supported Parameternames can be found with Intellisense or Get-AzureAdLicenseServicePlan (ServicePlanName)"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenseServicePlans) { $global:TeamsFunctionsMSAzureAdLicenseServicePlans = Get-AzureAdLicenseServicePlan -WarningAction SilentlyContinue }
        $ServicePlanNames = ($global:TeamsFunctionsMSAzureAdLicenseServicePlans).ServicePlanName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $ServicePlanNames | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($ServicePlanNames.Count) records available")
        }
      })]
    [string[]]$Disable,

    [Parameter(Mandatory = $false)]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Validating input
    if ($PSBoundParameters.ContainsKey('Enable') -and $PSBoundParameters.ContainsKey('Disable')) {
      # Check if any are listed in both!
      Write-Verbose -Message 'Validating input for Enable and Disable (identifying inconsistencies)'

      foreach ($Lic in $Enable) {
        if ($Lic -in $Disable) {
          Write-Error -Message "Invalid combination. '$Lic' cannot be enabled AND disabled" -Category LimitsExceeded -RecommendedAction 'Please specify only once!' -ErrorAction Stop
        }
      }
    }

    # Querying licenses in the Tenant to compare SKUs
    try {
      Write-Verbose -Message 'Querying Licenses from the Tenant'
      $TenantLicenses = Get-TeamsTenantLicense -Detailed -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region ForEach Identity
    foreach ($ID in $UserPrincipalName) {
      #region Object Verification
      # Querying User
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction STOP
        Write-Verbose -Message "Processing Object '$($UserObject.UserPrincipalName)'"
      }
      catch {
        Write-Error -Message "User '$ID' - Account not valid" -Category ObjectNotFound -RecommendedAction 'Verify UserPrincipalName'
        continue
      }
      # License Query from Object
      $ObjectAssignedLicenses = Get-AzureADUserLicenseDetail -ObjectId $UserObject.ObjectId -WarningAction SilentlyContinue
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): ServicePlanStatus (not 'Success') for License:", ($ObjectAssignedLicenses.ServicePlans | Where-Object ProvisioningStatus -NE 'Success' | Sort-Object ProvisioningStatus | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      #endregion

      Write-Verbose -Message "Processing Object '$($UserObject.UserPrincipalName)' - Processing Licenses"
      # Iterating each License assigned to this Object
      [int]$ActionedPlansToNotChange = $ActionedPlansToEnable = $ActionedPlansToDisable = 0
      foreach ($L in $ObjectAssignedLicenses) {
        # Determine License Name
        $LicenseName = $null
        $LicenseName = ($TenantLicenses | Where-Object SkuPartNumber -EQ $L.SkuPartNumber).ProductName
        if ( -not $LicenseName ) {
          $LicenseName = ($TenantLicenses | Where-Object SkuPartNumber -EQ $L.SkuPartNumber).SkuPartNumber
        }
        Write-Verbose -Message "'$ID' - License '$LicenseName'"
        # Verifying the License is still available in the Tenant
        $StandardLicense = $null
        $StandardLicense = Get-AzureADSubscribedSku | Where-Object { $_.SkuId -eq $L.SkuId }
        if ( -not $StandardLicense) {
          Write-Warning -Message "User '$ID' - License '$LicenseName' - License not found in the Tenant!?"
          continue
        }

        # Creating a new License Object
        $License = $DisabledPlanToProcess = $DisabledPlanObject = $null
        $License = New-AzureAdLicenseObject -AddSkuId $L.SkuId
        try {
          $DisabledPlanObject = $L.ServicePlans | Where-Object ProvisioningStatus -EQ 'Disabled' -ErrorAction Stop

          if ( $DisabledPlanObject ) {
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
              "Function: $($MyInvocation.MyCommand.Name): DisabledPlanObject:", ( $DisabledPlanObject | Format-List | Out-String).Trim() | Write-Debug
            }

            $DisabledPlanToProcess = $DisabledPlanObject | Select-Object ServicePlanId -ExpandProperty ServicePlanId
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
              "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ( $DisabledPlanToProcess | Format-List | Out-String).Trim() | Write-Debug
            }
            $($License.AddLicenses).DisabledPlans = $DisabledPlanToProcess
            if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
              "Function: $($MyInvocation.MyCommand.Name): DisabledPlans recorded:", ( $($License.AddLicenses).DisabledPlans | Format-List | Out-String).Trim() | Write-Debug
            }
          }
          else {
            $ActionedPlansToNotChange++
            Write-Verbose -Message "'$ID' - License '$LicenseName' - No disabled plans recorded!"
            continue
          }
        }
        catch {
          Write-Error "User '$ID' - License '$LicenseName' - Error encountered during population of disabled plans!"
          $DisabledPlanToProcess = $null
        }

        try {
          #region Enable - Iterating all provided Service Plans to enable
          if ($PSBoundParameters.ContainsKey('Enable')) {
            foreach ($S in $Enable) {
              # Checking Service Plan is valid
              Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' (checking status)"
              $ServicePlanToEnable = $null
              $ServicePlanToEnable = $StandardLicense.ServicePlans | Where-Object ServicePlanName -EQ "$S"
              if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                "Function: $($MyInvocation.MyCommand.Name): Service Plan '$S':", ( $ServicePlanToEnable | Format-Table | Out-String).Trim() | Write-Debug
              }

              if ( $ServicePlanToEnable) {
                Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' (Flagging for enablement)"
                # Checking whether Service Plan is disabled
                if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                  "Function: $($MyInvocation.MyCommand.Name): Service Plan '$S': Status", "ServicePlanToEnable: $($ServicePlanToEnable.ServicePlanId)" | Write-Debug
                  'List of Disabled Plan (to match against):', ( $License.AddLicenses.DisabledPlans | Format-List | Out-String).Trim() | Write-Debug
                  "Matching Status $( $ServicePlanToEnable.ServicePlanId -in $($License.AddLicenses).DisabledPlans )" | Write-Debug
                }
                if ( $ServicePlanToEnable.ServicePlanId -in $($License.AddLicenses).DisabledPlans ) {
                  Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' - Enabling Service Plan: '$($ServicePlanToEnable.ServicePlanId)'"
                  $null = $($License.AddLicenses).DisabledPlans.Remove($ServicePlanToEnable.ServicePlanId)
                  $ActionedPlansToEnable++
                  if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                    "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ( $License.AddLicenses.DisabledPlans | Format-List | Out-String).Trim() | Write-Debug
                  }
                }
                else {
                  Write-Information "INFO:    User '$ID' - License '$LicenseName' - Service Plan '$S' is already enabled"
                  continue
                }
              }
              else {
                Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' not present"
                continue
              }
            }
            if ( $ActionedPlansToEnable -eq 0 ) {
              Write-Verbose -Message "'$ID' - License '$LicenseName' - No Service Plans to enable"
              #continue
            }
          }
          #endregion

          #region Disable - Iterating all provided Service Plans to disable
          if ($PSBoundParameters.ContainsKey('Disable')) {
            foreach ($S in $Disable) {
              # Checking Service Plan is valid
              Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' (checking status)"
              $ServicePlanToDisable = $null
              $ServicePlanToDisable = $StandardLicense.ServicePlans | Where-Object ServicePlanName -EQ "$S"
              if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                "Function: $($MyInvocation.MyCommand.Name): Service Plan '$S':", ( $ServicePlanToDisable | Format-Table | Out-String).Trim() | Write-Debug
              }

              if ( $ServicePlanToDisable) {
                Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' (Flagging for Disablement)"
                # Checking whether Service Plan is disabled
                if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                  Write-Verbose "User '$ID' - License '$LicenseName' - Service Plan: '$S' - Status $( $ServicePlanToEnable.ServicePlanId -in $($License.AddLicenses).DisabledPlans )"
                  "Function: $($MyInvocation.MyCommand.Name): Service Plan '$S': Status", "ServicePlanToEnable: $($ServicePlanToEnable.ServicePlanId)" | Write-Debug
                  "List of Disabled Plan (to match against): $($($License.AddLicenses).DisabledPlans)" | Write-Debug
                }
                if (-not ($ServicePlanToDisable.ServicePlanId -in $($License.AddLicenses).DisabledPlans)) {
                  Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' - Disabling Service Plan: '$($ServicePlanToDisable.ServicePlanId)'"
                  $($License.AddLicenses).DisabledPlans += $ServicePlanToDisable.ServicePlanId
                  $ActionedPlansToDisable++
                  if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                    "Function: $($MyInvocation.MyCommand.Name): LicenseObject:", ( $License | Format-List | Out-String).Trim() | Write-Debug
                    "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($($License.AddLicenses).DisabledPlans | Format-List | Out-String).Trim() | Write-Debug
                  }
                }
                else {
                  Write-Information "INFO:    User '$ID' - License '$LicenseName' - Service Plan '$S' is already disabled"
                  continue
                }
              }
              else {
                Write-Verbose -Message "'$ID' - License '$LicenseName' - Service Plan: '$S' not present"
                continue
              }
            }
            if ( $ActionedPlansToDisable -eq 0 ) {
              Write-Verbose -Message "'$ID' - License '$LicenseName' - No Service Plans to disable"
              #continue
            }
          }
          #endregion
        }
        catch {
          throw
        }

        # Catching non-assignments
        if ( $ActionedPlansToEnable -eq 0 -and $ActionedPlansToDisable -eq 0 ) {
          $ActionedPlansToNotChange++
          Write-Verbose -Message "'$ID' - License '$LicenseName' - No Service Plans to toggle."
          continue
        }
        # Executing Assignment
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name): LicensesToAssign:", ($License.AddLicenses | Format-List | Out-String).Trim() | Write-Debug
          "Function: $($MyInvocation.MyCommand.Name): DisabledPlans:", ($($License.AddLicenses).DisabledPlans | Format-List | Out-String).Trim() | Write-Debug
        }
        if ($PSCmdlet.ShouldProcess("$ID", 'Set-AzureADUserLicense')) {
          #Assign $LicenseObject to each User
          Write-Verbose -Message "'$ID' - Setting Licenses"
          Set-AzureADUserLicense -ObjectId "$ID" -AssignedLicenses $License
          Write-Verbose -Message "'$ID' - Setting Licenses: Done"
        }
      }

      #Feedback of operation for this Object
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): EnabledPlans:  $ActionedPlansToEnable" | Write-Debug
        "Function: $($MyInvocation.MyCommand.Name): DisabledPlans: $ActionedPlansToDisable" | Write-Debug
        "Function: $($MyInvocation.MyCommand.Name): NoChanges:     $ActionedPlansToNotChange" | Write-Debug
      }
      [int]$ChangedLicenses = $ObjectAssignedLicenses.Count - $ActionedPlansToNotChange
      if ( $ChangedLicenses -gt 0 ) {
        Write-Information "SUCCESS: '$ID' - Operation performed: $ChangedLicenses Licenses changed and ServicePlans enabled/disabled"
      }
      else {
        Write-Warning -Message "'$ID' - No Licenses changed. Please validate License Assignments with Get-TeamsUserLicense or use switch PassThru"
      }

      #endregion

      # Output
      if ($PassThru) {
        Get-AzureAdUserLicenseServicePlan -Identity "$Identity"
      }
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-AzureAdUserLicenseServicePlan
