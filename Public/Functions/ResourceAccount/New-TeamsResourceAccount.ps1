# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function New-TeamsResourceAccount {
  <#
  .SYNOPSIS
    Creates a new Resource Account
  .DESCRIPTION
    Teams Call Queues and Auto Attendants require a resource account.
    It can carry a license and optionally also a phone number.
    This Function was designed to create the ApplicationInstance in AD,
    apply a UsageLocation to the corresponding AzureAD User,
    license the User and subsequently apply a phone number, all with one Command.
  .PARAMETER UserPrincipalName
    Required. The UPN for the new ResourceAccount. Invalid characters are stripped from the provided string
  .PARAMETER DisplayName
    Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
  .PARAMETER ApplicationType
    Required. CallQueue or AutoAttendant. Determines the association the account can have:
    A resource Account of the type "CallQueue" can only be associated with to a Call Queue
    A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
    The type can be switched later (this is supported and worked flawlessly when testing, but not recommended by Microsoft).
  .PARAMETER UsageLocation
    Required. Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
    Before a License can be assigned, the account needs a Usage Location populated.
  .PARAMETER License
    Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
    If not provided, will default to PhoneSystem_VirtualUser
    Unlicensed Objects can exist, but cannot be assigned a phone number
    PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
  .PARAMETER PhoneNumber
    Optional. Adds a Microsoft or Direct Routing Number to the Resource Account.
    Requires the Resource Account to be licensed (License Switch)
    Required format is E.164, starting with a '+' and 10-15 digits long.
  .PARAMETER OnlineVoiceRoutingPolicy
    Optional. Required for DirectRouting. Assigns an Online Voice Routing Policy to the Account
  .EXAMPLE
    New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -ApplicationType CallQueue -UsageLocation US
    Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
    User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
    DisplayName will be taken from the User PrincipalName and normalised to "ResourceAccount"
  .EXAMPLE
    New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -Displayname "My {ResourceAccount}" -ApplicationType CallQueue -UsageLocation US
    Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
    User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
    DisplayName will be normalised to "My ResourceAccount"
  .EXAMPLE
    New-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -Displayname "Mainline" -ApplicationType AutoAttendant -UsageLocation US -License PhoneSystem -PhoneNumber +1555123456
    Creates a Resource Account for Auto Attendants with a Usage Location for 'US'
    Applies the specified PhoneSystem License (if available in the Tenant)
    Assigns the Telephone Number if object could be licensed correctly.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
  .NOTES
    Execution requires User Admin Role in Azure AD
    Assigning the PhoneSystem license has been deactivated as it is an add-on license and cannot be assigned on its own.
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
  .FUNCTIONALITY
    Creates a resource Account in AzureAD for use in Teams
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'UPN of the Object to create.')]
    [ValidateScript( {
        If ($_ -match '@') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Parameter UserPrincipalName must be a valid UPN'
          $false
        }
      })]
    [Alias('Identity')]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = 'Display Name for this Object')]
    [string]$DisplayName,

    [Parameter(Mandatory = $true, HelpMessage = 'CallQueue or AutoAttendant')]
    [ValidateSet('CallQueue', 'AutoAttendant', 'CQ', 'AA')]
    [Alias('Type')]
    [string]$ApplicationType,

    [Parameter(Mandatory = $true, HelpMessage = 'Usage Location to assign')]
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
        $LicenseParams | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "$($LicenseParams.Count) records available")
        }
      })]
    [string[]]$License,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Telephone Number to assign')]
    [ValidateScript( {
        If ($_ -match '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9]{4})|[0-9]{8,15})((;ext=)([0-9]{3,8}))?$') { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Not a valid phone number. Must start with a + and 8 to 15 digits long'
          $false
        }
      })]
    [Alias('Tel', 'Number', 'TelephoneNumber')]
    [string]$PhoneNumber,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Name of the Online Voice Routing Policy')]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy

  ) #param

  begin {
    Show-FunctionStatus -Level Live
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

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 10
    if ( $License ) { $sMax = $sMax + 4 }
    if ( $License -and $PhoneNumber ) { $sMax++ }
    if ( $PhoneNumber ) { $sMax = $sMax + 2 }

    #region Validating Licenses to be applied result in correct Licensing (contain PhoneSystem)
    $PlansToTest = 'MCOEV_VIRTUALUSER', 'MCOEV'
    if ( $PSBoundParameters.ContainsKey('License') ) {
      $Status = 'Verifying input'
      $Operation = 'Validating Licenses to be applied result in correct Licensing'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $step++
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
    #region PREPARATION
    $Status = 'Verifying input'
    #region Normalising $UserPrincipalname
    $Operation = 'Normalising UserPrincipalName'
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $UPN = Format-StringForUse -InputString $UserPrincipalName -As UserPrincipalName
    Write-Verbose -Message "UserPrincipalName normalised to: '$UPN'"
    #endregion

    #region Normalising $DisplayName
    $Operation = 'Normalising DisplayName'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ($PSBoundParameters.ContainsKey('DisplayName')) {
      $Name = Format-StringForUse -InputString $DisplayName -As DisplayName
    }
    else {
      $Name = Format-StringForUse -InputString $($UserPrincipalName.Split('@')[0]) -As DisplayName
    }
    Write-Verbose -Message "DisplayName normalised to: '$Name'"
    #endregion

    #region ApplicationType
    $Operation = 'Parsing ApplicationType'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    # Translating $ApplicationType (Name) to ID used by Commands.
    $AppId = GetAppIdFromApplicationType $ApplicationType
    Write-Verbose -Message "'$Name' ApplicationType parsed"
    #endregion

    #region PhoneNumbers
    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      $Operation = 'Parsing Online Telephone Numbers (validating Number against Microsoft Calling Plan Numbers)'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $MSNumber = $null
      $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
      $PhoneNumberIsMSNumber = Get-CsOnlineTelephoneNumber -TelephoneNumber $MSNumber -WarningAction SilentlyContinue
      Write-Verbose -Message "'$Name' PhoneNumber parsed"
    }
    #endregion

    #region UsageLocation
    $Operation = 'Parsing UsageLocation'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ($PSBoundParameters.ContainsKey('UsageLocation')) {
      Write-Verbose -Message "'$Name' UsageLocation parsed: Using '$UsageLocation'"
    }
    else {
      # Querying Tenant Country as basis for Usage Location
      # This is never triggered as UsageLocation is mandatory! Remaining here regardless
      $Tenant = Get-CsTenant -WarningAction SilentlyContinue
      if ($null -ne $Tenant.CountryAbbreviation) {
        $UsageLocation = $Tenant.CountryAbbreviation
        Write-Warning -Message "'$Name' UsageLocation not provided. Defaulting to: $UsageLocation. - Please verify and change if needed!"
      }
      else {
        Write-Error -Message "'$Name' Usage Location not provided and Country not found in the Tenant!" -Category ObjectNotFound -RecommendedAction 'Please run command again and specify -UsageLocation' -ErrorAction Stop
      }
    }
    #endregion
    #endregion


    #region ACTION
    $Status = 'Creating Object'
    #region Creating Account
    $Operation = 'Creating Resource Account'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    try {
      #Trying to create the Resource Account
      Write-Verbose -Message "'$Name' Creating Resource Account with New-CsOnlineApplicationInstance..."
      if ($PSCmdlet.ShouldProcess("$UPN", 'New-CsOnlineApplicationInstance')) {
        $null = (New-CsOnlineApplicationInstance -UserPrincipalName $UPN -ApplicationId $AppId -DisplayName $Name -ErrorAction STOP)
        $i = 0
        $iMax = 45
        Write-Information "INFO:    Resource Account '$Name' ($ApplicationType) created; Waiting for AzureAd to write object ($iMax s)"
        $Status = 'Querying User'
        $Operation = 'Waiting for Get-AzureAdUser to return a Result'
        Write-Verbose -Message "$Status - $Operation"
        do {
          if ($i -gt $iMax) {
            Write-Error -Message "Could not find Object in AzureAD in the last $iMax Seconds" -Category ObjectNotFound -RecommendedAction 'Please verify Object has been created (UserPrincipalName); Continue with Set-TeamsResourceAccount'
            return
          }
          Write-Progress -Id 1 -Activity 'Azure Active Directory is propagating Object. Please wait' `
            -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

          Start-Sleep -Milliseconds 1000
          $i++

          $UserCreated = Test-AzureADUser "$UPN"
        }
        while ( -not $UserCreated )
        Write-Progress -Id 1 -Activity 'Azure Active Directory is propagating Object. Please wait' -Status $Status -Completed

        $ResourceAccountCreated = Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue
        if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
          "Function: $($MyInvocation.MyCommand.Name)", ($ResourceAccountCreated | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
      }
      else {
        return
      }
    }
    catch {
      # Catching anything
      throw "Resource Account '$Name' - Creation failed: $($_.Exception.Message)"
    }
    #endregion

    $Status = 'Applying Settings'
    #region UsageLocation
    $Operation = 'Setting Usage Location'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    try {
      if ($PSCmdlet.ShouldProcess("$UPN", "Set-AzureADUser -UsageLocation $UsageLocation")) {
        Set-AzureADUser -ObjectId $UPN -UsageLocation $UsageLocation -ErrorAction STOP
        Write-Verbose -Message "'$Name' SUCCESS - Usage Location set to: $UsageLocation"
      }
    }
    catch {
      if ($PSBoundParameters.ContainsKey('License')) {
        Write-Error -Message "'$Name' Usage Location could not be set. Please apply manually before applying license" -Category NotSpecified -RecommendedAction 'Apply manually, then run Set-TeamsResourceAccount to apply license and phone number'
      }
      else {
        Write-Warning -Message "'$Name' Usage Location cannot be set. If a license is needed, please assign UsageLocation manually beforehand"
      }
    }
    #endregion

    #region Licensing
    if ($PSBoundParameters.ContainsKey('License')) {
      $Operation = 'Processing License assignment'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
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
    #endregion

    #region Waiting for License Application
    if ($PSBoundParameters.ContainsKey('License') -and $PSBoundParameters.ContainsKey('PhoneNumber')) {
      $Operation = 'Waiting for AzureAd to write Object'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $i = 0
      $iMax = 600
      Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
      Write-Verbose -Message "License '$License'- Expecting one of the corresponding ServicePlans '$PlansToTest'"
      do {
        if ($i -gt $iMax) {
          Write-Error -Message "Could not find Successful Provisioning Status of ServicePlan '$PlansToTest' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction 'Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount' -ErrorAction Stop
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

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      $Operation = 'Applying Phone Number'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      # Assigning Telephone Number
      Write-Verbose -Message "'$Name' Processing Phone Number"
      Write-Information 'INFO: Assigning a phone number might fail if the Object is not yet replicated'
      if (-not $IsLicensed) {
        Write-Error -Message 'A Phone Number can only be assigned to licensed objects. Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both'
      }
      else {
        # Processing paths for Telephone Numbers depending on Type
        $E164Number = Format-StringForUse $PhoneNumber -As E164

        if ($PhoneNumberIsMSNumber) {
          # Set in VoiceApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' found in Tenant, provisioning for: Microsoft Calling Plans"
          try {
            if ($PSCmdlet.ShouldProcess("$($ResourceAccountCreated.UserPrincipalName)", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $PhoneNumber")) {
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity "$($ResourceAccountCreated.UserPrincipalName)" -TelephoneNumber $E164Number -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message 'Phone number could not be assigned! Please run Set-TeamsResourceAccount manually'
          }
        }
        else {
          # Set in ApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' not found in Tenant, provisioning for: Direct Routing"
          try {
            if ($PSCmdlet.ShouldProcess("$($ResourceAccountCreated.UserPrincipalName)", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $PhoneNumber")) {
              $null = (Set-CsOnlineApplicationInstance -Identity "$($ResourceAccountCreated.UserPrincipalName)" -OnpremPhoneNumber $E164Number -Force -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message "'$Name' Number '$PhoneNumber' not assigned! Please run Set-TeamsResourceAccount manually"
          }
        }
      }
    }

    #  Wating for AAD to write the PhoneNumber so that it may be queried correctly
    $Operation = 'Waiting for AzureAd to write Object (2s)'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    Start-Sleep -Seconds 2
    #endregion

    #region OnlineVoiceRoutingPolicy
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
    #endregion


    #region OUTPUT
    #Creating new PS Object
    try {
      # Data
      $Status = 'Validation'
      $Operation = 'Querying Object'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $ResourceAccount = Get-CsOnlineApplicationInstance -Identity "$UPN" -WarningAction SilentlyContinue -ErrorAction STOP

      $Operation = 'Querying Object License'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $ResourceAccountLicense = Get-AzureAdUserLicense -Identity "$UPN"

      # readable Application type
      $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId

      # Resource Account License
      if ($IsLicensed) {
        if ($null -ne $ResourceAccount.PhoneNumber) {
          # Phone Number Type
          if ($PhoneNumberIsMSNumber) {
            $ResourceAccountPhoneNumberType = 'Microsoft Number'
          }
          else {
            $ResourceAccountPhoneNumberType = 'Direct Routing Number'
          }
        }
        else {
          $ResourceAccountPhoneNumberType = $null
        }

        # Phone Number is taken from Original Object and should be populated correctly

      }
      else {
        $ResourceAccountPhoneNumberType = $null
        # Phone Number is taken from Original Object and should be empty at this point
      }

      # creating new PS Object (synchronous with Get and Set)
      $ResourceAccountObject = [PSCustomObject][ordered]@{
        UserPrincipalName = $ResourceAccount.UserPrincipalName
        DisplayName       = $ResourceAccount.DisplayName
        ApplicationType   = $ResourceAccountApplicationType
        UsageLocation     = $UsageLocation
        License           = $ResourceAccountLicense.Licenses
        PhoneNumberType   = $ResourceAccountPhoneNumberType
        PhoneNumber       = $ResourceAccount.PhoneNumber
      }

      Write-Information "Resource Account '$($ResourceAccountObject.UserPrincipalName)' created"
      if ($PSBoundParameters.ContainsKey('PhoneNumber') -and $IsLicensed -and $ResourceAccount.PhoneNumber -eq '') {
        Write-Warning -Message 'Object replication pending, Phone Number does not show yet. Run Get-TeamsResourceAccount to verify'
      }

      Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed
      Write-Output $ResourceAccountObject

    }
    catch {
      Write-Warning -Message 'Object Output could not be verified. Please verify manually with Get-CsOnlineApplicationInstance'
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #New-TeamsResourceAccount
