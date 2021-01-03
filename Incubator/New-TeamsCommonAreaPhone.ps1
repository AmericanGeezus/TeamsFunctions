# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-JAN-2020
# Status:   ALPHA

#TODO Build


function New-TeamsCommonAreaPhone {
  <#
	.SYNOPSIS
		Creates a new Common Area Phone
	.DESCRIPTION
		Teams Call Queues and Auto Attendants require a Common Area Phone.
		It can carry a license and optionally also a phone number.
		This Function was designed to create the ApplicationInstance in AD,
		apply a UsageLocation to the corresponding AzureAD User,
		license the User and subsequently apply a phone number, all with one Command.
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
		NOTE: PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
	.PARAMETER PhoneNumber
		Optional. Adds a Microsoft or Direct Routing Number to the Common Area Phone.
		Requires the Common Area Phone to be licensed (License Switch)
		Required format is E.164, starting with a '+' and 10-15 digits long.
	.EXAMPLE
		New-TeamsCommonAreaPhone -UserPrincipalName "Common Area Phone@TenantName.onmicrosoft.com" -ApplicationType CallQueue -UsageLocation US
		Will create a CommonAreaPhone of the type CallQueue with a Usage Location for 'US'
		User Principal Name will be normalised to: CommonAreaPhone@TenantName.onmicrosoft.com
		DisplayName will be taken from the User PrincipalName and normalised to "CommonAreaPhone"
	.EXAMPLE
		New-TeamsCommonAreaPhone -UserPrincipalName "Common Area Phone@TenantName.onmicrosoft.com" -Displayname "My {CommonAreaPhone}" -ApplicationType CallQueue -UsageLocation US
		Will create a CommonAreaPhone of the type CallQueue with a Usage Location for 'US'
		User Principal Name will be normalised to: CommonAreaPhone@TenantName.onmicrosoft.com
		DisplayName will be normalised to "My CommonAreaPhone"
	.EXAMPLE
		New-TeamsCommonAreaPhone -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -Displayname "Mainline" -ApplicationType AutoAttendant -UsageLocation US -License PhoneSystem -PhoneNumber +1555123456
		Creates a Common Area Phone for Auto Attendants with a Usage Location for 'US'
		Applies the specified PhoneSystem License (if available in the Tenant)
		Assigns the Telephone Number if object could be licensed correctly.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
		Execution requires User Admin Role in Azure AD
	.FUNCTIONALITY
		Creates a Common Area Phone in AzureAD for use in Teams
  .COMPONENT
    TeamsAutoAttendant
    TeamsCallQueue
	.LINK
    New-TeamsCommonAreaPhone
    Get-TeamsCommonAreaPhone
    Find-TeamsCommonAreaPhone
    Set-TeamsCommonAreaPhone
    Remove-TeamsCommonAreaPhone
    #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('New-TeamsRA')]
  [OutputType([System.Object])]
  param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = "UPN of the Object to create.")]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForegroundColor Red
          $false
        }
      })]
    [Alias("Identity")]
    [string]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName, HelpMessage = "Display Name for this Object")]
    [string]$DisplayName,

    [Parameter(Mandatory = $true, HelpMessage = "Usage Location to assign")]
    [string]$UsageLocation,

    [Parameter(HelpMessage = "License to be assigned")]
    [ValidateScript( {
        $LicenseParams = (Get-TeamsLicense).ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $LicenseParams) {
          return $true
        }
        else {
          Write-Host "Parameter 'License' - Invalid license string. Supported Parameternames can be found with Get-TeamsLicense" -ForegroundColor Red
          return $false
        }
      })]
    [string]$License,

    [Parameter(HelpMessage = "Telephone Number to assign")]
    [ValidateScript( {
        If ($_ -match "^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{7,15}))?((;( |-)?ext=[0-9]{3,8}))?$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. Must start with a + and 8 to 15 digits long" -ForegroundColor Red
          $false
        }
      })]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

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

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 10
    if ( $License ) { $sMax = $sMax + 2 }
    if ( $License -and $PhoneNumber ) { $sMax++ }
    if ( $PhoneNumber ) { $sMax = $sMax + 2 }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region PREPARATION
    $Status = "Verifying input"
    #region Normalising $UserPrincipalname
    $Operation = "Normalising UserPrincipalName"
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $UPN = Format-StringForUse -InputString $UserPrincipalName -As UserPrincipalName
    Write-Verbose -Message "UserPrincipalName normalised to: '$UPN'"
    #endregion

    #region Normalising $DisplayName
    $Operation = "Normalising DisplayName"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      $Name = Format-StringForUse -InputString $DisplayName -As DisplayName
    }
    else {
      $Name = Format-StringForUse -InputString $($UserPrincipalName.Split('@')[0]) -As DisplayName
    }
    Write-Verbose -Message "DisplayName normalised to: '$Name'"
    #endregion

    #region PhoneNumbers
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      $Operation = "Parsing PhoneNumbers from the Tenant"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      # Loading all Microsoft Telephone Numbers
      if (-not $global:MSTelephoneNumbers) {
        $global:MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      }
      $MSNumber = Format-StringRemoveSpecialCharacter $PhoneNumber | Format-StringForUse -SpecialChars "tel"
      $PhoneNumberIsMSNumber = ($MSNumber -in $global:MSTelephoneNumbers.Id)
      Write-Verbose -Message "'$Name' PhoneNumber parsed"
    }
    #endregion

    #region UsageLocation
    $Operation = "Parsing UsageLocation"
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
        Write-Error -Message "'$Name' Usage Location not provided and Country not found in the Tenant!" -Category ObjectNotFound -RecommendedAction "Please run command again and specify -UsageLocation" -ErrorAction Stop
      }
    }
    #endregion
    #endregion


    #region ACTION
    $Status = "Creating Object"
    #region Creating Account
    $Operation = "Creating Common Area Phone"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    try {
      #Trying to create the Common Area Phone
      Write-Verbose -Message "'$Name' Creating Common Area Phone with New-AzureAdUser..."
      if ($PSCmdlet.ShouldProcess("$UPN", "New-AzureAdUser")) {
        #TODO Add all requirements for the AzureAdUser
        $null = (New-AzureADUser -UserPrincipalName $UPN -ApplicationId $AppId -DisplayName $Name -ErrorAction STOP)
        $i = 0
        $iMax = 20
        Write-Verbose -Message "Common Area Phone '$Name' created; Please be patient while we wait ($iMax s) to be able to parse the Object." -Verbose
        $Status = "Querying User"
        $Operation = "Waiting for Get-AzureAdUser to return a Result"
        Write-Verbose -Message "$Status - $Operation"
        while ( -not (Test-AzureADUser $UPN)) {
          if ($i -gt $iMax) {
            Write-Error -Message "Could not find Object in AzureAD in the last $iMax Seconds" -Category ObjectNotFound -RecommendedAction "Please verify Object has been created (UserPrincipalName); Continue with Set-TeamsCommonAreaPhone"
            return
          }
          Write-Progress -Id 1 -Activity "Azure Active Directory is applying License. Please wait" `
            -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

          Start-Sleep -Milliseconds 1000
          $i++
        }
        Write-Progress -Id 1 -Activity "Azure Active Directory is applying License. Please wait" -Status $Status -Completed

        $CommonAreaPhoneCreated = Get-AzureADUser -ObjectId "$UPN" -WarningAction SilentlyContinue
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name)", ($CommonAreaPhoneCreated | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
      }
      else {
        return
      }
    }
    catch {
      # Catching anything
      Write-Host "ERROR:   Creation failed: $($_.Exception.Message)" -ForegroundColor Red
      return
    }
    #endregion

    $Status = "Applying Settings"
    #region UsageLocation
    #CHECK Integrate into Creation itself?
    $Operation = "Setting Usage Location"
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
      if ($PSBoundParameters.ContainsKey("License")) {
        Write-Error -Message "'$Name' Usage Location could not be set. Please apply manually before applying license" -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsCommonAreaPhone to apply license and phone number"
      }
      else {
        Write-Warning -Message "'$Name' Usage Location cannot be set. If a license is needed, please assign UsageLocation manually beforehand"
      }
    }
    #endregion

    #region Licensing
    # Determining available Licenses from Tenant
    $Operation = "Querying Tenant Licenses"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $TenantLicenses = Get-TeamsTenantLicense

    # Setting License to Common Area Phone if not provided
    if ( -not $PSBoundParameters.ContainsKey("License")) {
      $License = "CommonAreaPhone"
    }

    # Verifying License is available
    $Operation = "Verifying License is available"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ($License -eq "CommonAreaPhone") {
      $RemainingCAPLicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "MCOCAP" }).Remaining
      Write-Verbose -Message "INFO: $RemainingCAPLicenses Common Area Phone Licenses still available"
      if ($RemainingCAPLicenses -lt 1) {
        Write-Error -Message "ERROR: No free PhoneSystem Virtual User License remaining in the Tenant." -ErrorAction Stop
      }
      else {
        try {
          if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add CommonAreaPhone")) {
            $null = (Set-TeamsUserLicense -Identity $UPN -Add $License -ErrorAction STOP)
            Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'"
            $IsLicensed = $true
          }
        }
        catch {
          Write-Error -Message "'$Name' License assignment failed for '$License'"
        }
      }
    }
    else {
      try {
        if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -Add $License")) {
          $null = (Set-TeamsUserLicense -Identity $UPN -Add $License -ErrorAction STOP)
          Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'" -Verbose
          $IsLicensed = $true
        }
      }
      catch {
        Write-Error -Message "'$Name' License assignment failed for '$License'"
      }
    }
    #endregion

    #TODO: Remove License application and Phone Number section completely, delegating Phone Number application to Set-TeamsUserVoiceConfig or Set-TeamsCommonAreaPhone
    # More likely, replace with Policies relevant for CAPS: IP Phone, Calling, CallPark
    #region Waiting for License Application
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      $Operation = "Waiting for AzureAd to write Object"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $ServicePlanName = "MCOEV"
      $i = 0
      $iMax = 600
      Write-Warning -Message "Applying a License may take longer than provisioned for ($($iMax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsCommonAreaPhone"

      $Status = "Applying License"
      $Operation = "Waiting for Get-AzureAdUserLicenseDetail to return a Result"
      Write-Verbose -Message "$Status - $Operation"
      while (-not (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan $ServicePlanName)) {
        if ($i -gt $iMax) {
          Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $iMax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsCommonAreaPhone); Continue with Set-TeamsCommonAreaPhone" -ErrorAction Stop
        }
        Write-Progress -Id 1 -Activity "Azure Active Directory is applying License. Please wait" `
          -Status $Status -SecondsRemaining $($iMax - $i) -CurrentOperation $Operation -PercentComplete (($i * 100) / $iMax)

        Start-Sleep -Milliseconds 1000
        $i++
      }
    }
    #endregion

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      $Operation = "Applying Phone Number"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      # Assigning Telephone Number
      Write-Verbose -Message "'$Name' Processing Phone Number"
      Write-Verbose -Message "NOTE: Assigning a phone number might fail if the Object is not yet replicated" -Verbose
      if (-not $IsLicensed) {
        Write-Host "ERROR: A Phone Number can only be assigned to licensed objects." -ForegroundColor Red
        Write-Host "Please apply a license before assigning the number. Set-TeamsCommonAreaPhone can be used to do both"
      }
      else {
        # Processing paths for Telephone Numbers depending on Type
        $E164Number = Format-StringForUse $PhoneNumber -As E164

        if ($PhoneNumberIsMSNumber) {
          # Set in VoiceApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' found in Tenant, assuming provisioning for: Microsoft Calling Plans"
          try {
            if ($PSCmdlet.ShouldProcess("$($CommonAreaPhoneCreated.UserPrincipalName)", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $PhoneNumber")) {
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity $CommonAreaPhoneCreated.UserPrincipalName -Telephonenumber $E164Number -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsCommonAreaPhone manually"
          }
        }
        else {
          # Set in ApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' not found in Tenant, assuming provisioning for: Direct Routing"
          try {
            if ($PSCmdlet.ShouldProcess("$($CommonAreaPhoneCreated.UserPrincipalName)", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $PhoneNumber")) {
              $null = (Set-CsOnlineApplicationInstance -Identity $CommonAreaPhoneCreated.UserPrincipalName -OnPremPhoneNumber $E164Number -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message "'$Name' Number '$PhoneNumber' not assigned! Please run Set-TeamsCommonAreaPhone manually"
          }
        }
      }
    }
    #  Wating for AAD to write the PhoneNumber so that it may be queried correctly
    $Operation = "Waiting for AzureAd to write Object (2s)"
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    Start-Sleep -Seconds 2
    #endregion
    #endregion

    #region OUTPUT
    #Creating new PS Object
    try {
      # Data
      $Status = "Validation"
      $Operation = "Querying Object"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $CommonAreaPhone = Get-CsOnlineApplicationInstance -Identity $UPN -WarningAction SilentlyContinue -ErrorAction STOP

      $Operation = "Querying Object License"
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $CommonAreaPhoneLicense = Get-TeamsUserLicense -Identity $UPN

      # readable Application type
      $CommonAreaPhoneApplicationType = GetApplicationTypeFromAppId $CommonAreaPhone.ApplicationId

      # Common Area Phone License
      if ($IsLicensed) {
        if ($null -ne $CommonAreaPhone.PhoneNumber) {
          # Phone Number Type
          if ($PhoneNumberIsMSNumber) {
            $CommonAreaPhonePhoneNumberType = "Microsoft Number"
          }
          else {
            $CommonAreaPhonePhoneNumberType = "Direct Routing Number"
          }
        }
        else {
          $CommonAreaPhonePhoneNumberType = $null
        }

        # Phone Number is taken from Original Object and should be populated correctly

      }
      else {
        $CommonAreaPhonePhoneNumberType = $null
        # Phone Number is taken from Original Object and should be empty at this point
      }

      # creating new PS Object (synchronous with Get and Set)
      $CommonAreaPhoneObject = [PSCustomObject][ordered]@{
        UserPrincipalName = $CommonAreaPhone.UserPrincipalName
        DisplayName       = $CommonAreaPhone.DisplayName
        ApplicationType   = $CommonAreaPhoneApplicationType
        UsageLocation     = $UsageLocation
        License           = $CommonAreaPhoneLicense.LicensesFriendlyNames
        PhoneNumberType   = $CommonAreaPhonePhoneNumberType
        PhoneNumber       = $CommonAreaPhone.PhoneNumber
      }

      Write-Verbose -Message "Common Area Phone Created:" -Verbose
      if ($PSBoundParameters.ContainsKey("PhoneNumber") -and $IsLicensed -and $CommonAreaPhone.PhoneNumber -eq "") {
        Write-Warning -Message "Object replication pending, Phone Number does not show yet. Run Get-TeamsCommonAreaPhone to verify"
      }

      Write-Progress -Id 0 -Status "Complete" -Activity $MyInvocation.MyCommand -Completed
      Write-Output $CommonAreaPhoneObject

    }
    catch {
      Write-Warning -Message "Object Output could not be verified. Please verify manually with Get-CsOnlineApplicationInstance"
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #New-TeamsCommonAreaPhone
