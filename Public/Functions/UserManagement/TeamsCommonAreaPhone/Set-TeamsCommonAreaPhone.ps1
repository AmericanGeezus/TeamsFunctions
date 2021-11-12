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
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not $script:TFPSST) { $script:TFPSST = Assert-MicrosoftTeamsConnection; if ( -not $script:TFPSST ) { break } }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

    $StatusID0 = 'Verifying input'
    #region Validating Licenses to be applied result in correct Licensing (contains Teams & PhoneSystem)
    $PlansToTest = 'TEAMS1', 'MCOEV'
    if ( $PSBoundParameters.ContainsKey('License') ) {
      $CurrentOperationID0 = 'Validating Licenses to be applied result in correct Licensing'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
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
    [int] $private:CountID0 = 1
    [int] $private:StepsID0 = $private:CountID0 + $UserPrincipalName.Count
    ForEach ($UPN in $UserPrincipalName) {
      $StatusID0 = $CurrentOperationID0 = ''
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $ActivityID1 = "'$UPN'"
      $StatusID1 = 'Verifying input'
      #region PREPARATION
      #region Lookup of UserPrincipalName
      $CurrentOperationID1 = 'Querying User Account'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      try {
        #NOTE Call placed without the Identity Switch to make remoting call and receive object in tested format (v2.5.0 and higher)
        #$CsOnlineUser = Get-CsOnlineUser -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
        $CsOnlineUser = Get-CsOnlineUser "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP
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
          Write-Progress -Id 1 -Activity $ActivityID1 -Completed
          continue
        }
        catch {
          Write-Error -Message "'$UPN' not found. Error encountered: $($_.Exception.Message)" -Category ObjectNotFound
          Write-Progress -Id 1 -Activity $ActivityID1 -Completed
          continue
        }
      }
      #endregion

      #region Normalising $DisplayName
      $CurrentOperationID1 = 'DisplayName'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      if ($PSBoundParameters.ContainsKey('DisplayName')) {
        if ($UPN.IsArray) {
          Write-Warning -Message "'$UPN' Changing DisplayName for Array input disabled to avoid accidents."
        }
        else {
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
      $CurrentOperationID1 = 'UsageLocation'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $CurrentUsageLocation = $CsOnlineUser.UsageLocation
      if ($PSBoundParameters.ContainsKey('UsageLocation')) {
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
      $CurrentOperationID1 = 'Querying current License and Testing Licensing Scope (Should contain Teams and PhoneSystem)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
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

      $StatusID1 = 'Changing Common Area Phone'
      #region ACTION
      #region Setting Object
      $CurrentOperationID1 = 'Applying Settings'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      try {
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
      $CurrentOperationID1 = 'Processing License assignment'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      if ($PSBoundParameters.ContainsKey('License')) {
        if ( $License -in $UserLicense.Licenses.ParameterName -and $IsLicensed ) {
          # No action required
          Write-Information "INFO:    User '$Name ($UPN)' License '$License' already assigned."
          $IsLicensed = $true
        }
        else {
          try {
            if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add $License")) {
              $null = (Set-TeamsUserLicense -Identity "$UPN" -Add $License -ErrorAction STOP)
              Write-Information "INFO:    User '$Name' License assignment - '$License' SUCCESS"
              $IsLicensed = $true
            }
          }
          catch {
            Write-Error -Message "'$Name' License assignment failed for '$License' with Exception: '$($_.Exception.Message)'"
          }
        }
      }
      #endregion

      #region Policies
      $CurrentOperationID1 = 'Processing Policy assignments'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
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
      Write-Progress -Id 1 -Activity $ActivityID1 -Completed

      #region OUTPUT
      $CurrentOperationID0 = 'Validation & Output'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $CommonAreaPhone = $null
      if ($PassThru) {
        $CommonAreaPhone = Get-TeamsCommonAreaPhone -Identity "$UPN"
      }
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      Write-Output $CommonAreaPhone
      #endregion
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsCommonAreaPhone
