﻿# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Set-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Changes a new Resource Account
  .DESCRIPTION
    This function allows you to update Resource accounts for Teams Call Queues and Auto Attendants.
    It can carry a license and optionally also a phone number.
    This Function was designed to service the ApplicationInstance in AD,
    the corresponding AzureAD User and its license and enable use of a phone number, all with one Command.
  .PARAMETER UserPrincipalName
    Required. Identifies the Object being changed
  .PARAMETER DisplayName
    Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
  .PARAMETER ApplicationType
    CallQueue or AutoAttendant. Determines the association the account can have:
    A resource Account of the type "CallQueue" can only be associated with to a Call Queue
    A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
    The type can be switched later (this is supported and worked flawlessly when testing, but not recommended by Microsoft).
  .PARAMETER UsageLocation
    Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
    Before a License can be assigned, the account needs a Usage Location populated.
  .PARAMETER License
    Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
    If not provided, will default to PhoneSystem_VirtualUser
    Unlicensed Objects can exist, but cannot be assigned a phone number
    If a license already exists, it will try to swap the license to the specified one.
    PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
  .PARAMETER PhoneNumber
    Changes the Phone Number of the object.
    Can either be a Microsoft Number or a Direct Routing Number.
    Requires the Resource Account to be licensed correctly
    Required format is E.164, starting with a '+' and 10-15 digits long.
  .PARAMETER OnlineVoiceRoutingPolicy
    Optional. Required for DirectRouting. Assigns an Online Voice Routing Policy to the Account
  .PARAMETER Sync
    Calls Sync-CsOnlineApplicationInstance cmdlet after applying settings synchronizing the application instances
    from Azure Active Directory into Agent Provisioning Service.
  .PARAMETER PassThru
    By default, no output is generated, PassThru will display the Object changed
  .PARAMETER Force
    Optional. If parameter PhoneNumber is provided, will always remove the PhoneNumber from the object
    If PhoneNumber is not Null or Empty, will reapply the PhoneNumber
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName ResourceAccount@TenantName.onmicrosoft.com -Displayname "My {ResourceAccount}"
    Will normalize the Display Name (i.E. remove special characters), then set it as "My ResourceAccount"
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -UsageLocation US
    Sets the UsageLocation for the Account in AzureAD to US.
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -License PhoneSystem_VirtualUser
    Requires the Account to have a UsageLocation populated. Applies the License to Resource Account AA-Mainline.
    If no license is assigned, will try to assign. If the license is already applied, no action is currently taken.
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber +1555123456
    Changes the Phone number of the Object. Will cleanly remove the Phone Number first before reapplying it.
    This will only succeed if the object is licensed correctly!
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber $Null
    Removes the Phone number from the Object
  .EXAMPLE
    Set-TeamsResourceAccount -UserPrincipalName MyRessourceAccount@TenantName.onmicrosoft.com -ApplicationType AutoAttendant
    Switches MyResourceAccount to the Type AutoAttendant
    Though working correctly in all tests, please handle with care
  .INPUTS
    System.String
  .OUTPUTS
    System.Void - Default Behavior
    System.Object - With Switch PassThru
  .NOTES
    Though working correctly in all tests, please handle with care when changing Application Types
    Existing Application Instance Objects may get corrupted when treated as a User.
    If in doubt, please recreate the Resource Account and retire the old object.
    At the moment, swapping licenses is not possible/implemented. Please address manually in the Admin Center
  .COMPONENT
    TeamsResourceAccount
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Changes a resource Account in AzureAD for use in Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsRA')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to change')]
    [ValidateScript( {
        if ($_ -match '@' -or $_ -match '^[0-9a-f]{8}-([0-9a-f]{4}\-){3}[0-9a-f]{12}$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN or ObjectId.'
        }
      })]
    [Alias('ObjectId', 'Identity')]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = 'Display Name is shown in Teams')]
    [string]$DisplayName,

    [Parameter(HelpMessage = 'CallQueue or AutoAttendant')]
    [ValidateSet('CallQueue', 'AutoAttendant', 'CQ', 'AA')]
    [Alias('Type')]
    [string]$ApplicationType,

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

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Telephone Number to assign')]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$PhoneNumber,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Routing Policy')]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(HelpMessage = 'By default, no output is generated, PassThru will display the Object changed')]
    [switch]$PassThru,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Synchronizes Resource Account with the Agent Provisioning Service')]
    [switch]$Sync,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

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

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

    #region Validating Licenses to be applied result in correct Licensing (contain PhoneSystem)
    $PlansToTest = 'MCOEV_VIRTUALUSER', 'MCOEV'
    if ( $PSBoundParameters.ContainsKey('License') ) {
      $ActivityID0 = 'Preparation'
      $StatusID0 = 'Verifying input'
      $CurrentOperationID0 = 'Validating Licenses to be applied result in correct Licensing'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $IncludesPlan = 0
      foreach ($L in $License) {
        foreach ($PlanToTest in $PlansToTest) {
          $Included = Test-AzureAdLicenseContainsServicePlan -License "$L" -ServicePlan "$PlanToTest"
          if ($Included) {
            $IncludesPlan++
            Write-Verbose -Message "License '$L' ServicePlan '$PlanToTest' - Included: OK"
          }
          else {
            Write-Verbose -Message "License '$L' ServicePlan '$PlanToTest' - NOT included"
          }
        }
      }
      if ( $IncludesPlan -lt 1 ) {
        Write-Warning -Message "ServicePlan validation - None of the Licenses include any of the required ServicePlans '$PlansToTest' - Account may not be operational!"
      }
    }
    #endregion
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($UPN in $UserPrincipalName) {
      $ActivityID0 = "'$UPN'"
      #region PREPARATION
      $StatusID0 = 'Verifying input'
      #region Lookup of UserPrincipalName
      $CurrentOperationID0 = 'Querying Object'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      try {
        #TEST Piping with UserPrincipalName, Identity from Get-CsOnlineApplicationInstance AND Get-TeamsRA
        #Trying to query the Resource Account
        $Object = (Get-CsOnlineApplicationInstance -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP)
        $CurrentDisplayName = $Object.DisplayName
        Write-Verbose -Message "'$UPN' OnlineApplicationInstance found: '$CurrentDisplayName'"
      }
      catch {
        # Catching anything
        Write-Error -Message "'$UPN' OnlineApplicationInstance not found!" -Category ObjectNotFound -RecommendedAction 'Please provide a valid UserPrincipalName of an existing Resource Account' #-ErrorAction Stop
        return
      }
      #endregion

      #region Normalising $DisplayName
      $CurrentOperationID0 = 'Processing DisplayName'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      if ($PSBoundParameters.ContainsKey('DisplayName')) {
        $DisplayNameNormalised = Format-StringForUse -InputString $DisplayName -As DisplayName
        $Name = $DisplayNameNormalised
        Write-Verbose -Message "DisplayName normalised to: '$Name'"
      }
      else {
        $Name = $CurrentDisplayName
      }
      #endregion

      #region ApplicationType and Associations
      $CurrentOperationID0 = 'Parsing Application Type'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      if ($PSBoundParameters.ContainsKey('ApplicationType')) {
        # Translating $ApplicationType (Name) to ID used by Commands.
        $AppId = GetAppIdFromApplicationType $ApplicationType
        $CurrentAppId = $Object.ApplicationId
        # Does the ApplicationType differ? Does it have to be changed?
        if ($AppId -eq $CurrentAppId) {
          # Application IDs match - Type does not need to be changed
          Write-Verbose -Message "'$Name ($UPN)' Application Type already set to: $ApplicationType"
        }
        else {
          # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
          $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction Ignore
          if ($Associations.count -gt 0) {
            # Associations found. Aborting
            Write-Error -Message "'$Name ($UPN)' ApplicationType cannot be changed! Object is associated with Call Queue or AutoAttendant." -Category OperationStopped -RecommendedAction 'Remove Associations with Remove-CsOnlineApplicationInstanceAssociation manually' -ErrorAction Stop
          }
          else {
            Write-Verbose -Message "'$Name ($UPN)' Application Type will be changed to: $ApplicationType"
          }
        }
      }
      #endregion

      #region PhoneNumber
      $CurrentOperationID0 = 'Parsing Phone Number'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      # Querying CurrentPhoneNumber
      try {
        $CurrentPhoneNumber = $Object.PhoneNumber.Replace('tel:', '')
        Write-Verbose -Message "'$Name ($UPN)' Phone Number assigned currently: '$CurrentPhoneNumber'"
      }
      catch {
        $CurrentPhoneNumber = $null
        Write-Verbose -Message "'$Name ($UPN)' Phone Number assigned currently: NONE"
      }

      if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        $CurrentOperationID0 = 'Applying Phone Number'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        # Applying Phone Number with Set-TeamsPhoneNumber
        #TEST integration of Set-TeamsPhoneNumber
        try {
          $PhoneNumberExecResult = $null
          $PhoneNumberExecResult = Set-TeamsPhoneNumber -UserPrincipalName "$UPN" -PhoneNumber $PhoneNumber -WarningAction SilentlyContinue -ErrorAction Stop
          if ( $PhoneNumberExecResult ) {
            $StatusMessage = "$(if ($PhoneNumberIsMSNumber) { 'Calling Plan' } else { 'Direct Routing'}) Number assigned to $ObjectType`: '$PhoneNumber'"
            Write-Information "SUCCESS: '$UPN' - $CurrentOperationID0`: OK - $StatusMessage"
          }
          else {
            throw
          }
        }
        catch {
          $ErrorLogMessage = "'$UPN' - $CurrentOperationID0`: Failed: '$($_.Exception.Message)'"
          Write-Error -Message $ErrorLogMessage
        }
      }
      else {
        #PhoneNumber is not provided
        if ( -not $CurrentPhoneNumber ) {
          Write-Verbose -Message "'$Name ($UPN)' Phone Number not provided or present. Resource Account will only be able to be called internally"
        }
      }
      #endregion

      #region UsageLocation
      $CurrentOperationID0 = 'Parsing Usage Location'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $CurrentUsageLocation = (Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue).UsageLocation
      if ($PSBoundParameters.ContainsKey('UsageLocation')) {
        if ($Usagelocation -eq $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name ($UPN)' Usage Location already set to: $CurrentUsageLocation"
        }
        else {
          Write-Verbose -Message "'$Name ($UPN)' Usage Location will be set to: $Usagelocation"
        }
      }
      else {
        if ($null -ne $CurrentUsageLocation) {
          Write-Verbose -Message "'$Name ($UPN)' Usage Location currently set to: $CurrentUsageLocation"
          $UsageLocation = $CurrentUsageLocation
        }
        else {
          if (($PSBoundParameters.ContainsKey('License')) -or ($PSBoundParameters.ContainsKey('PhoneNumber'))) {
            Write-Error -Message "'$Name ($UPN)' Usage Location not set!" -Category ObjectNotFound -RecommendedAction 'Please run command again and specify -UsageLocation'# -ErrorAction Stop
            return
          }
          else {
            Write-Warning -Message "'$Name ($UPN)' Usage Location not set! This is a requirement for License assignment and Phone Number"
          }
        }
      }
      #endregion

      #region Current License
      $CurrentOperationID0 = 'Querying current License and Testing Licensing Scope (Should contain PhoneSystem or PhoneSystemVirtualUser)'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      $IsLicensed = $false
      # Determining license Status of Object
      $UserLicense = Get-AzureAdUserLicense -Identity "$UPN"
      if ( $UserLicense.PhoneSystem -or $UserLicense.PhoneSystemVirtualUser ) {
        if ( $UserLicense.PhoneSystemStatus -eq 'Success' ) {
          Write-Verbose -Message "'$Name ($UPN)' PhoneSystem is assigned and enabled successfully"
          $IsLicensed = $true
        }
      }
      else {
        Write-Verbose -Message "'$Name ($UPN)' PhoneSystem present: NONE"
      }
      #endregion


      #region ACTION
      $StatusID0 = 'Applying Settings'
      #region DisplayName
      if ($PSBoundParameters.ContainsKey('DisplayName')) {
        $CurrentOperationID0 = 'Setting Display Name'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        try {
          if ($PSCmdlet.ShouldProcess("$UPN", "Set-CsOnlineApplicationInstance -Displayname `"$DisplayNameNormalised`"")) {
            Write-Verbose -Message "'$CurrentDisplayName' Changing DisplayName to: $DisplayNameNormalised"
            $null = (Set-CsOnlineApplicationInstance -Identity "$UPN" -DisplayName "$DisplayNameNormalised" -ErrorAction STOP)
            Write-Information "SUCCESS: Displayname changed to '$DisplayName'"
            $CurrentDisplayName = $Object.DisplayName
          }
        }
        catch {
          Write-Verbose -Message 'FAILED - Error encountered changing DisplayName'
          Write-Error -Message 'Problem encountered with changing DisplayName' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Set-CsOnlineApplicationInstance'
          Write-Debug $_
        }
      }
      #endregion

      #region Application Type
      if ($PSBoundParameters.ContainsKey('ApplicationType')) {
        $CurrentOperationID0 = 'Checking Application Type is correct'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        # Application Type Change?
        if ($AppId -ne $CurrentAppId) {
          try {
            if ($PSCmdlet.ShouldProcess("$UPN", "Set-CsOnlineApplicationInstance -ApplicationId $AppId")) {
              Write-Verbose -Message "'$Name ($UPN)' Setting Application Type to: $ApplicationType"
              $null = (Set-CsOnlineApplicationInstance -Identity "$UPN" -ApplicationId $AppId -ErrorAction STOP)
              Write-Verbose -Message 'SUCCESS'
            }
          }
          catch {
            Write-Error -Message 'Problem encountered changing Application Type' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Set-CsOnlineApplicationInstance'
            Write-Debug $_
          }
        }
      }
      #endregion

      #region UsageLocation
      if ($PSBoundParameters.ContainsKey('UsageLocation')) {
        $CurrentOperationID0 = 'Setting Usage Location'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        if ($PSCmdlet.ShouldProcess("$UPN", "Set-AzureADUser -UsageLocation $UsageLocation")) {
          try {
            Set-AzureADUser -ObjectId "$UPN" -UsageLocation $UsageLocation -ErrorAction STOP
            Write-Verbose -Message "'$Name ($UPN)' SUCCESS - Usage Location set to: $UsageLocation"
          }
          catch {
            if ($PSBoundParameters.ContainsKey('License')) {
              Write-Error -Message "'$Name ($UPN)' Usage Location could not be set. Please apply before applying license" -Category NotSpecified -RecommendedAction 'Apply manually, then run Set-TeamsResourceAccount to apply license and phone number'
            }
            else {
              Write-Warning -Message "'$Name ($UPN)' Usage Location cannot be set. If a license is needed, please assign UsageLocation beforehand"
            }
          }
        }
      }
      #endregion

      #region Licensing
      $StatusID0 = 'Applying Settings - License'
      if ($PSBoundParameters.ContainsKey('License')) {
        $CurrentOperationID0 = 'Processing License assignment'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        if ( $License -in $UserLicense.Licenses.ParameterName -and $IsLicensed ) {
          # No action required
          Write-Information "INFO:    Resource Account '$Name ($UPN)' License '$License' already assigned."
          $IsLicensed = $true
        }
        else {
          try {
            if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add $License")) {
              $null = (Set-TeamsUserLicense -Identity "$UPN" -Add $License -ErrorAction STOP)
              Write-Information "INFO:    Resource Account '$Name' License assignment - '$License' SUCCESS"
              $IsLicensed = $true
            }
          }
          catch {
            Write-Error -Message "'$Name' License assignment failed for '$License' with Exception: '$($_.Exception.Message)'"
          }
        }
      }
      #endregion

      #region Waiting for License Application
      if ($PSBoundParameters.ContainsKey('License') -and $PSBoundParameters.ContainsKey('PhoneNumber')) {
        $CurrentOperationID0 = $StatusID0 = ''
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        $i = 0
        $iMax = 600
        Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
        Write-Verbose -Message "License '$License'- Expecting one of the corresponding ServicePlans '$PlansToTest'"
        $ActivityID1 = 'Checking License propagation as a requirement before applying Phone Number'
        $StatusID1 = 'Azure Active Directory is propagating Object. Please wait'
        $CurrentOperationID1 = 'Waiting for Test-TeamsUserLicense to return a positive Result'
        do {
          if ($i -gt $iMax) {
            Write-Error -Message "Could not find Successful Provisioning Status of ServicePlan '$PlansToTest' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction 'Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount' -ErrorAction Stop
          }
          Write-Progress -Id 1 -ParentId 0 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -SecondsRemaining $($iMax - $i) -PercentComplete (($i * 100) / $iMax)
          Start-Sleep -Milliseconds 1000
          $i++

          $AllTests = $false
          $AllTests = foreach ($PlanToTest in $PlansToTest) { Test-TeamsUserLicense -Identity "$UPN" -ServicePlan "$PlanToTest" }
          $TeamsUserLicenseAssigned = if ( ($AllTests) -contains $true ) { $true } else { $false }
        }
        while (-not $TeamsUserLicenseAssigned)
        Write-Progress -Id 1 -Activity $ActivityID1 -Completed
      }
      #endregion

      #region PhoneNumber
      $StatusID0 = 'Applying Settings - Phone Number'
      if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        $CurrentOperationID0 = 'Checking Previous assignment of Phone Number'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        if ( $Force -and $PhoneNumber -and $UserWithThisNumber ) {
          # Removing number from previous Object
          try {
            foreach ($UserWTN in $UserWithThisNumber) {
              if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                "  Function: $($MyInvocation.MyCommand.Name) - InterpretedUserType:", ($($UserWTN.InterpretedUserType) | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
              }
              Write-Verbose -Message "'$Name ($UPN)' ACTION: $Operation FROM '$($UserWTN.UserPrincipalName)'"
              if ($UserWTN.InterpretedUserType.Contains('ApplicationInstance')) {
                if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                  if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                    "Running: 'Set-TeamsResourceAccount -UserPrincipalName $($UserWTN.UserPrincipalName) -PhoneNumber `$Null -ErrorAction Stop'" | Write-Debug
                  }
                  Set-TeamsResourceAccount -UserPrincipalName $($UserWTN.UserPrincipalName) -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                  Write-Information "SUCCESS: Resource Account '$($UserWTN.UserPrincipalName)' - Phone Number removed: OK"
                }
              }
              elseif ($UserWTN.InterpretedUserType.Contains('User')) {
                if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                  if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                    "Running: '$UserWTN | Set-TeamsUserVoiceConfig -PhoneNumber `$Null -ErrorAction Stop'" | Write-Debug
                  }
                  $UserWTN | Set-TeamsUserVoiceConfig -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                  Write-Information "SUCCESS: User '$($UserWTN.UserPrincipalName)' - Phone Number removed: OK"
                }
              }
              else {
                Write-Error -Message "$Operation from '$($UserWTN.UserPrincipalName)' failed. Object is not a User or a ResourceAccount" -ErrorAction Stop
              }
            }
          }
          catch {
            Write-Error -Message "$Operation from '$($UserWTN.UserPrincipalName)' failed with Exception: $($_.Exception.Message)" -ErrorAction Stop
          }
        }

        # Removing old Number (if $null or different to current)
        if ($null -eq $PhoneNumber -or $force -or $CurrentPhoneNumber -ne $PhoneNumber) {
          $CurrentOperationID0 = 'Removing Phone Number'
          Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
          Write-Verbose -Message "'$Name ($UPN)' ACTION: Removing Phone Number"
          try {
            $UVCObject = Get-TeamsUserVoiceConfig -UserPrincipalName "$UPN" -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorVariable Stop
            if ($null -ne ($UVCObject.TelephoneNumber)) {
              # Remove from VoiceApplicationInstance
              Write-Verbose -Message "'$Name ($UPN)' Removing Microsoft Number"
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity "$UPN" -TelephoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
              Write-Verbose -Message 'SUCCESS'
            }
            if ($null -ne ($UVCObject.OnPremLineURI)) {
              # Remove from ApplicationInstance
              Write-Verbose -Message "'$Name ($UPN)' Removing Direct Routing Number"
              #Switch -OnPremPhoneNumber requires -Force - Reason unknown
              $null = (Set-CsOnlineApplicationInstance -Identity "$UPN" -OnpremPhoneNumber $null -Force -WarningAction SilentlyContinue -ErrorAction STOP)
              Write-Verbose -Message 'SUCCESS'
            }
          }
          catch {
            Write-Error -Message 'Removal of Number failed' -Category NotImplemented -Exception $_.Exception -RecommendedAction 'Try manually with Remove-AzureAdUser'
            Write-Debug $_
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name)", (Get-CsOnlineApplicationInstance -Identity "$UPN" | Select-Object UserPrincipalName, DisplayName, PhoneNumber | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }
        }
        else {
          Write-Verbose -Message "'$Name ($UPN)' No Number assigned"
        }

        # Assigning Telephone Number
        $CurrentOperationID0 = 'Applying Phone Number'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        if ($PhoneNumber) {
          if ( -not $IsLicensed ) {
            Write-Error -Message 'A Phone Number can only be assigned to licensed objects.' -Category ResourceUnavailable -RecommendedAction 'Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both'
          }
          else {
            Write-Verbose -Message "'$Name ($UPN)' ACTION: Assigning Phone Number"
            # Assigning new Number
            # Processing paths for Telephone Numbers depending on Type
            try {
              $MSNumber = $null
              $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
              $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
              if ($PhoneNumberIsMSNumber) {
                # Set in VoiceApplicationInstance
                if ($force -or $PSCmdlet.ShouldProcess("$UPN", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $E164Number")) {
                  Write-Information "INFO:    Resource Account '$Name ($UPN)' Number '$Number' found in Tenant, provisioning Microsoft for: Microsoft Calling Plans"
                  $null = (Set-CsOnlineVoiceApplicationInstance -Identity "$UPN" -TelephoneNumber $E164Number -ErrorAction STOP)
                }
              }
              else {
                # Set in ApplicationInstance
                if ($force -or $PSCmdlet.ShouldProcess("$UPN", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $E164Number")) {
                  Write-Information "INFO:    Resource Account '$Name ($UPN)' Number '$E164Number' not found in Tenant, provisioning for: Direct Routing"
                  $null = (Set-CsOnlineApplicationInstance -Identity "$UPN" -OnpremPhoneNumber $E164Number -Force -ErrorAction STOP)
                }
              }
            }
            catch {
              Write-Error -Message "'$Name ($UPN)' Number '$PhoneNumber' not assigned! Exception: $($_.Exception.Message)" -Category NotImplemented -RecommendedAction 'Please run Set-TeamsResourceAccount manually'
              if ($_.Exception.Message -eq 'The application instance does not have a valid license.' ) {
                Write-Warning -Message 'If a license was assigned recently, please allow for propagation in O365, then try this command again'
              }
            }
          }
          if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
            "Function: $($MyInvocation.MyCommand.Name)", (Get-CsOnlineApplicationInstance -Identity "$UPN" | Select-Object UserPrincipalName, DisplayName, PhoneNumber | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
          }
        }
      }
      #endregion

      #region OnlineVoiceRoutingPolicy
      $CurrentOperationID0 = 'Applying Online Voice Routing Policy'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      if ( $OnlineVoiceRoutingPolicy ) {
        try {
          Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
          Write-Information "SUCCESS: '$Name ($UPN)' Assigning OnlineVoiceRoutingPolicy: OK: '$OnlineVoiceRoutingPolicy'"
        }
        catch {
          $ErrorLogMessage = "User '$Name ($UPN)' Assigning OnlineVoiceRoutingPolicy`: Failed: '$($_.Exception.Message)'"
          Write-Error -Message $ErrorLogMessage
        }
      }
      #endregion

      # Synchronisation
      if ( $PSBoundParameters.ContainsKey('Sync') ) {
        Write-Verbose -Message "Switch 'Sync' - Resource Account is synchronised with Agent Provisioning Service"
        $null = Sync-CsOnlineApplicationInstance -ObjectId $ResourceAccount.ObjectId #-Force
        Write-Information 'SUCCESS: Synchronising Resource Account with Agent Provisioning Service'
      }
      #endregion


      if ( $PassThru ) {
        $StatusID0 = 'Output'
        $CurrentOperationID0 = 'Querying Object'
        Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
        $RAObject = Get-TeamsResourceAccount -Identity "$UPN"
      }
      else {
        $RAObject = $null
      }
      Write-Progress -Id 0 -Activity $ActivityID0 -Completed
      Write-Output $RAObject
    }
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Set-TeamsResourceAccount
