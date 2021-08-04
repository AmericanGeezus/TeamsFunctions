# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  24-MAY-2021
# Status:   RC




function Set-TeamsCommonAreaPhone {
  <#
  .SYNOPSIS
    Changes settings for a Common Area Phone
  .DESCRIPTION
    Applies settings relevant to a Common Area Phone.
    This includes DisplayName, UsageLocation, License, IP Phone Policy, Calling Policy and Call Park Policy can be applied.
  .PARAMETER UserPrincipalName
    Required. The UPN for the new CommonAreaPhone. Invalid characters are stripped from the provided string
  .PARAMETER DisplayName
    Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
  .PARAMETER UsageLocation
    Required. Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
    Before a License can be assigned, the account needs a Usage Location populated.
  .PARAMETER License
    Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
    If not provided, will default to PhoneSystem_VirtualUser
    Unlicensed Objects can exist, but cannot be assigned a phone number
    PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
  .PARAMETER IPPhonePolicy
    Optional. Adds an IP Phone Policy to the User
  .PARAMETER TeamsCallingPolicy
    Optional. Adds a Calling Policy to the User
  .PARAMETER TeamsCallParkPolicy
    Optional. Adds a Call Park Policy to the User
  .PARAMETER PassThru
    Optional. Displays the Object after execution.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -Displayname "Lobby {Phone}"
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. DisplayName will be normalised to "Lobby Phone" and applied.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -UsageLocation US -License CommonAreaPhone
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. Usage Location is set to 'US' and the CommonAreaPhone License is assigned.
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -License Office365E3,PhoneSystem
    Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com. Usage Location is required to be set. Assigns the Office 365 E3 License as well as PhoneSystem
  .EXAMPLE
    Set-TeamsCommonAreaPhone -UserPrincipalName "MyLobbyPhone@TenantName.onmicrosoft.com" -IPPhonePolicy "My IPP" -TeamsCallingPolicy "CallP" -TeamsCallParkPolicy "CallPark" -PassThru
    Applies IPPhonePolicy, TeamsCallingPolicy and TeamsCallParkPolicy to the Common Area Phone
    Displays the Common Area Phone Object afterwards
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Execution requires User Admin Role in Azure AD
    This CmdLet deliberately does not apply a Phone Number to the Object. To do so, please run New-TeamsUserVoiceConfig
    or Set-TeamsUserVoiceConfig. For a full Voice Configuration apply a Calling Plan or Online Voice Routing Policy
    a Phone Number and optionally a Tenant Dial Plan.
    This Script only covers relevant elements for Common Area Phones themselves.
  .COMPONENT
    UserManagement
  .FUNCTIONALITY
    Changes a Common Area Phone in AzureAD for use in Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsCommonAreaPhone.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('Set-TeamsCAP')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to query.')]
    [ValidateScript( {
        If ($_ -match '@') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN'
          $false
        }
      })]
    [Alias('ObjectId', 'Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Display Name for this Object')]
    [string]$DisplayName,

    [Parameter(HelpMessage = 'Usage Location to assign')]
    [string]$UsageLocation,

    [Parameter(HelpMessage = 'License to be assigned')]
    [ValidateScript( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Intellisense or Get-AzureAdLicense"
        }
      })]
    [ArgumentCompleter( {
        if (-not $global:TeamsFunctionsMSAzureAdLicenses) { $global:TeamsFunctionsMSAzureAdLicenses = Get-AzureAdLicense -WarningAction SilentlyContinue }
        $LicenseParams = ($global:TeamsFunctionsMSAzureAdLicenses).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        $LicenseParams | Sort-Object | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($LicenseParams.Count) records available")
        }
      })]
    [string[]]$License,

    [Parameter(HelpMessage = 'IP Phone Policy')]
    [string]$IPPhonePolicy,

    [Parameter(HelpMessage = 'Teams Calling Policy')]
    [string]$TeamsCallingPolicy,

    [Parameter(HelpMessage = 'Teams Call Park Policy')]
    [string]$TeamsCallParkPolicy,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru

  ) #param

  begin {
    Show-FunctionStatus -Level RC
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #region Validating Licenses to be applied result in correct Licensing (contains Teams & PhoneSystem)
    $PlansToTest = 'TEAMS1', 'MCOEV'
    if ( $PSBoundParameters.ContainsKey('License') ) {
      $Status = 'Verifying input'
      $Operation = 'Validating Licenses to be applied result in correct Licensing'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $IncludesTeams = 0
      $IncludesPhoneSystem = 0
      foreach ($L in $License) {
        if (Test-AzureAdLicenseContainsServicePlan -License "$L" -ServicePlan $PlansToTest[0]) {
          $IncludesTeams++
          Write-Verbose -Message "License '$L' ServicePlan '$($PlansToTest[0])' - Included: OK"
        }
        else {
          Write-Verbose -Message "License '$L' ServicePlan '$($PlansToTest[0])' - NOT included"
        }
        if (Test-AzureAdLicenseContainsServicePlan -License "$L" -ServicePlan $PlansToTest[1]) {
          $IncludesPhoneSystem++
          Write-Verbose -Message "License '$L' ServicePlan '$($PlansToTest[1])' - Included: OK"
        }
        else {
          Write-Verbose -Message "License '$L' ServicePlan '$($PlansToTest[1])' - NOT included"
        }
      }
      if ( $IncludesTeams -lt 1 -and $IncludesPhoneSystem -lt 1 ) {
        Write-Warning -Message "ServicePlan validation - None of the Licenses include both of the required ServicePlans '$PlansToTest' - Account may not be operational!"
      }
    }
    #endregion
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    $Parameters = @{}

    ForEach ($UPN in $UserPrincipalName) {
      # Initialising counters for Progress bars
      [int]$step = 0
      [int]$sMax = 2
      if ( $DisplayName ) { $sMax++ }
      if ( $UsageLocation ) { $sMax++ }
      if ( $License ) { $sMax = $sMax + 2 }
      if ( $PassThru ) { $sMax++ }

      #region PREPARATION
      $Status = 'Verifying input'
      #region Lookup of UserPrincipalName
      $Operation = 'Querying Object'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      try {
        #Trying to query the Account
        $CsOnlineUser = (Get-CsOnlineUser -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP)
        $CurrentDisplayName = $CsOnlineUser.DisplayName
        Write-Verbose -Message "'$UPN' Teams Object found: '$CurrentDisplayName'"
        $Parameters += @{ 'ObjectId' = $CsOnlineUser.ObjectId }
      }
      catch {
        # If CsOnlineUser not found, trying AzureAdUser
        try {
          Write-Verbose -Message "'$UPN' - Querying User Account (AzureAdUser)"
          $AdUser = Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
          $CsOnlineUser = $AdUser
          $CurrentDisplayName = $AdUser.DisplayName
          Write-Warning -Message "'$UPN' - found in AzureAd but not in Teams (CsOnlineUser)!"
        }
        catch [Microsoft.Open.AzureAD16.Client.ApiException] {
          Write-Error -Message "'$UPN' not found in Teams (CsOnlineUser) nor in Azure Ad (AzureAdUser). Please validate UserPrincipalName. Exception message: Resource '$UPN' does not exist or one of its queried reference-property objects are not present." -Category ObjectNotFound
          continue
        }
        catch {
          Write-Error -Message "'$UPN' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
          continue
        }
      }
      #endregion

      #region Normalising $DisplayName
      if ($PSBoundParameters.ContainsKey('DisplayName')) {
        if ($UPN.IsArray) {
          Write-Warning -Message "'$UPN' Changing DisplayName for Array input disabled to avoid accidents."
        }
        else {
          $Operation = 'Normalising DisplayName'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          $Name = Format-StringForUse -InputString $DisplayName -As DisplayName
          Write-Verbose -Message "DisplayName normalised to: '$Name'"
          $Parameters += @{ 'DisplayName' = "$Name" }
        }
      }
      else {
        $Name = $CurrentDisplayName
      }
      #endregion

      #region UsageLocation
      $CurrentUsageLocation = $CsOnlineUser.UsageLocation
      if ($PSBoundParameters.ContainsKey('UsageLocation')) {
        $Operation = 'Parsing UsageLocation'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        if ($Usagelocation -eq $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name' Usage Location already set to: $CurrentUsageLocation"
        }
        else {
          Write-Verbose -Message "'$Name' Usage Location will be set to: $Usagelocation"
          $Parameters += @{ 'UsageLocation' = "$UsageLocation" }
        }
      }
      else {
        if ($null -ne $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name' Usage Location currently set to: $CurrentUsageLocation"
        }
        else {
          if ($PSBoundParameters.ContainsKey('License')) {
            Write-Error -Message "'$Name' Usage Location not set!" -Category ObjectNotFound -RecommendedAction 'Please run command again and specify -UsageLocation'# -ErrorAction Stop
            return
          }
          else {
            Write-Warning -Message "'$Name' Usage Location not set! This is a requirement for License assignment and Phone Number"
          }
        }
      }
      #endregion

      #region Current License
      $Operation = 'Querying current License and Testing Licensing Scope (Should contain Teams and PhoneSystem)'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      $IsLicensed = $false
      # Determining license Status of Object
      $UserLicense = Get-AzureAdUserLicense -Identity "$UPN"
      if ( $UserLicense ) {
        $ServicePlan1 = $UserLicense.ServicePlans | Where-Object ServicePlanName -EQ "$($PlansToTest[0])"
        $ServicePlan2 = $UserLicense.ServicePlans | Where-Object ServicePlanName -EQ "$($PlansToTest[1])"
        if ($ServicePlan1.Provisioningstatus -eq 'Success' -and $ServicePlan2.Provisioningstatus -eq 'Success' ) {
          Write-Verbose -Message "'$Name ($UPN)' Service Plans for Teams & PhoneSystem are enabled successfully"
          $IsLicensed = $true
        }
      }
      else {
        Write-Verbose -Message "'$Name ($UPN)' Current License assigned: NONE"
      }
      #endregion

      #Common Parameters
      $Parameters += @{ 'ErrorAction' = 'STOP' }
      #endregion


      #region ACTION
      $Status = 'Azure Ad User'
      #region Setting Object
      $Operation = 'Applying Settings'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      try {
        #Trying to create the Common Area Phone
        Write-Verbose -Message "'$Name' Creating Common Area Phone with New-AzureAdUser..."
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name) - Parameters", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
        if ($PSCmdlet.ShouldProcess("$UPN", 'Set-AzureAdUser')) {
          $null = Set-AzureADUser @Parameters
          $AzureAdUser = Get-AzureADUser -ObjectId $Parameters.ObjectId
        }
        else {
          return
        }
      }
      catch {
        # Catching anything
        throw [System.Management.Automation.SetValueException] "Application of settings failed: $($_.Exception.Message)"
        return
      }
      #endregion

      #region Licensing
      if ($PSBoundParameters.ContainsKey('License')) {
        $Operation = 'Processing License assignment'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        if ( $License -in $UserLicense.Licenses.ParameterName -and $IsLicensed ) {
          # No action required
          Write-Information "'$Name ($UPN)' License '$License' already assigned."
          $IsLicensed = $true
        }
        else {
          try {
            if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add $License")) {
              $null = (Set-TeamsUserLicense -Identity "$UPN" -Add $License -ErrorAction STOP)
              Write-Information "'$Name' License assignment - '$License' SUCCESS"
              $IsLicensed = $true
            }
          }
          catch {
            Write-Error -Message "'$Name' License assignment failed for '$License' with Exception: '$($_.Exception.Message)'"
          }
        }
      }
      #endregion

      <# Commented out as it will currently never be executed as PhoneNumber is not a parameter on the CmdLet - left here for future expansion
      #region Waiting for License Application
      if ($PSBoundParameters.ContainsKey('License') -and $PSBoundParameters.ContainsKey('PhoneNumber')) {
        $Operation = 'Waiting for AzureAd to write Object'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        $i = 0
        $iMax = 600
        Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
        Write-Verbose -Message "License '$License'- Expecting corresponding ServicePlan '$PlanToTest'"
        do {
          if ($i -gt $iMax) {
            Write-Error -Message "Could not find Successful Provisioning Status of ServicePlan '$PlanToTest' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction 'Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount' -ErrorAction Stop
          }
          Write-Progress -Id 1 -Activity 'Azure Active Directory is applying License. Please wait' `
            -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

          Start-Sleep -Milliseconds 1000
          $i++

          $AllTests = $false
          $AllTests = foreach ($PlanToTest in $PlansToTest) { Test-TeamsUserLicense -Identity "$UPN" -ServicePlan "$PlanToTest" }
          $TeamsUserLicenseNotYetAssigned = if ( $AllTests ) { $true } else { $false }
        }
        while (-not $TeamsUserLicenseNotYetAssigned)
        Write-Progress -Id 1 -Activity 'Azure Active Directory is applying License. Please wait' -Status $Status -Completed
      }
      #endregion
      #>

      #region Policies
      $Operation = 'Applying Policies'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      if ( -not $IsLicensed ) {
        Write-Error -Message 'Policies can only be assigned to licensed objects. Please wait for propagation or apply a license before assigning policies.' -Category ResourceUnavailable -RecommendedAction 'Please apply a license before assigning any Policy.'
      }
      else {
        #IP Phone Policy
        if ($PSBoundParameters.ContainsKey('IPPhonePolicy')) {
          Grant-CsTeamsIPPhonePolicy -Identity $AzureAdUser.ObjectId -PolicyName $IPPhonePolicy
        }
        elseif ( $CsOnlineUser.TeamsIPPhonePolicy ) {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - IP Phone Policy '$($CsOnlineUser.TeamsIPPhonePolicy)' is assigned!"
        }
        else {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - IP Phone Policy 'Global' is in effect!"
        }
        #Teams Calling Policy
        if ($PSBoundParameters.ContainsKey('TeamsCallingPolicy')) {
          Grant-CsTeamsCallingPolicy -Identity $AzureAdUser.ObjectId -PolicyName $TeamsCallingPolicy
        }
        elseif ( $CsOnlineUser.TeamsCallingPolicy ) {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - Calling Policy '$($CsOnlineUser.TeamsCallingPolicy)' is assigned!"
        }
        else {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - Calling Policy 'Global' is in effect!"
        }
        #Teams Call Park Policy
        if ($PSBoundParameters.ContainsKey('TeamsCallParkPolicy')) {
          Grant-CsTeamsCallParkPolicy -Identity $AzureAdUser.ObjectId -PolicyName $TeamsCallParkPolicy
        }
        elseif ( $CsOnlineUser.TeamsCallParkPolicy ) {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - Call Park Policy '$($CsOnlineUser.TeamsCallParkPolicy)' is assigned!"
        }
        else {
          Write-Verbose -Message "Object '$($CsOnlineUser.UserPrincipalName)' - Call Park Policy 'Global' is in effect!"
        }
      }
      #endregion
      #endregion

      #region OUTPUT
      if ($PassThru) {
        $Status = 'Validation'
        $Operation = 'Querying Object'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        $CommonAreaPhone = $null
        $CommonAreaPhone = Get-TeamsCommonAreaPhone -Identity "$UPN"
        Write-Output $CommonAreaPhone
      }

      Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed
      #endregion

    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsCommonAreaPhone
