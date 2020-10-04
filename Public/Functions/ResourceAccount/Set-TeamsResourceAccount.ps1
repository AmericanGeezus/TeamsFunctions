# Module:   TeamsFunctions
# Function: ResourceAccount
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   BETA

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
		NOTE: Though switching the account type is possible, this is currently untested: Handle with Care!
	.PARAMETER UsageLocation
		Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
		Before a License can be assigned, the account needs a Usage Location populated.
	.PARAMETER License
		Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
		If not provided, will default to PhoneSystem_VirtualUser
		Unlicensed Objects can exist, but cannot be assigned a phone number
		If a license already exists, it will try to swap the license to the specified one.
		NOTE: PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
	.PARAMETER PhoneNumber
		Changes the Phone Number of the object.
		Can either be a Microsoft Number or a Direct Routing Number.
		Requires the Resource Account to be licensed correctly
		Required format is E.164, starting with a '+' and 10-15 digits long.
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName ResourceAccount@TenantName.onmicrosoft.com -Displayname "My {ResourceAccount}"
		Will normalize the Display Name (i.E. remove special characters), then set it as "My ResourceAccount"
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -UsageLocation US
		Sets the UsageLocation for the Account in AzureAD to US.
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -License PhoneSystem_VirtualUser
		Requires the Account to have a UsageLocation populated. Applies the License to Resource Account AA-Mainline.
		If no license is assigned, will try to assign. If the license is already applied, no action is taken.
		NOTE: Swapping licenses is currently not possible.
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
		NOTE: This is currently untested, errors might occur simply because not all caveats could be captured.
		Handle with care!
  .INPUTS
    System.String
  .OUTPUTS
    None
	.NOTES
		CmdLet currently in testing.
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Changes a resource Account in AzureAD for use in Teams
	.LINK
    Get-TeamsResourceAccountAssociation
    New-TeamsResourceAccountAssociation
		Remove-TeamsResourceAccountAssociation
    New-TeamsResourceAccount
    Get-TeamsResourceAccount
    Find-TeamsResourceAccount
    Set-TeamsResourceAccount
    Remove-TeamsResourceAccount
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsRA')]
  [OutputType([System.Void])]
  param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to change")]
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

    [Parameter(HelpMessage = "Display Name is shown in Teams")]
    [string]$DisplayName,

    [Parameter(HelpMessage = "CallQueue or AutoAttendant")]
    [ValidateSet("CallQueue", "AutoAttendant", "CQ", "AA")]
    [Alias("Type")]
    [string]$ApplicationType,

    [Parameter(HelpMessage = "Usage Location to assign")]
    [string]$UsageLocation,

    [Parameter(HelpMessage = "License to be assigned")]
    [ValidateScript( {
        if ($_ -in $TeamsLicenses.ParameterName) {
          return $true
        }
        else {
          Write-Host "Parameter 'License' - Invalid license string. Please specify a ParameterName from `$TeamsLicenses:" -ForegroundColor Red
          Write-Host "$($TeamsLicenses.ParameterName)"
          return $false
        }
      })]
    [string]$License,

    [Parameter(HelpMessage = "Telephone Number to assign")]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$PhoneNumber
  ) #param

  begin {
    # Caveat - Script in Development
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Show-FunctionStatus -Level BETA
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    #region PREPARATION
    Write-Verbose -Message "Verifying input"
    #region Lookup of UserPrincipalName
    try {
      #Trying to query the Resource Account
      $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -WarningAction SilentlyContinue -ErrorAction STOP)
      $CurrentDisplayName = $Object.DisplayName
      Write-Verbose -Message "'$UserPrincipalName' OnlineApplicationInstance found: '$CurrentDisplayName'"
    }
    catch {
      # Catching anything
      Write-Error -Message "'$UserPrincipalName' OnlineApplicationInstance not found!" -Category ObjectNotFound -RecommendedAction "Please provide a valid UserPrincipalName of an existing Resource Account" -ErrorAction Stop
    }
    #endregion

    #region Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      $DisplayNameNormalised = Format-StringForUse -InputString $DisplayName -As DisplayName
      $Name = $DisplayNameNormalised
      Write-Verbose -Message "DisplayName normalised to: '$Name'"
    }
    else {
      $Name = $CurrentDisplayName
    }
    #endregion

    #region ApplicationType and Associations
    if ($PSBoundParameters.ContainsKey("ApplicationType")) {
      # Translating $ApplicationType (Name) to ID used by Commands.
      $AppId = GetAppIdFromApplicationType $ApplicationType
      $CurrentAppId = $Object.ApplicationId
      # Does the ApplicationType differ? Does it have to be changed?
      if ($AppId -eq $CurrentAppId) {
        # Application IDs match - Type does not need to be changed
        Write-Verbose -Message "'$Name' Application Type already set to: $ApplicationType"
      }
      else {
        # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
        $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -WarningAction SilentlyContinue -ErrorAction Ignore
        if ($Associations.count -gt 0) {
          # Associations found. Aborting
          Write-Error -Message "'$Name' ApplicationType cannot be changed! Object is associated with Call Queue or AutoAttendant." -Category OperationStopped -RecommendedAction "Remove Associations with Remove-CsOnlineApplicationInstanceAssociation manually" -ErrorAction Stop
        }
        else {
          Write-Verbose -Message "'$Name' Application Type will be changed to: $ApplicationType"
        }
      }
    }
    #endregion

    #region PhoneNumber
    # Querying CurrentPhoneNumber
    try {
      $CurrentPhoneNumber = $Object.PhoneNumber.Replace('tel:', '')
      Write-Verbose -Message "'$Name' Phone Number assigned currently: $CurrentPhoneNumber"
    }
    catch {
      $CurrentPhoneNumber = $null
      Write-Verbose -Message "'$Name' Phone Number assigned currently: NONE"
    }

    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      #Validating Phone Number
      if ($PhoneNumber -eq "" -or $null -eq $PhoneNumber) {
        if ($CurrentPhoneNumber) {
          Write-Warning -Message "PhoneNumber is NULL or Empty. The Existing Number '$CurrentPhoneNumber' will be removed"
        }
        else {
          Write-Verbose -Message "PhoneNumber is NULL or Empty, but no Number is currently assigned.No Action taken"
        }
        $PhoneNumber = $null
      }
      elseif ($_ -match "^\+[0-9]{10,15}$") {
        Write-Verbose -Message "PhoneNumber '$PhoneNumber' is valid and will be applied"
        # Checking number is free
        Write-Verbose -Message "PhoneNumber - Finding Number assignments"
        $UserWithThisNumber = Find-TeamsUserVoiceConfig -PhoneNumber $PhoneNumber
        if ($UserWithThisNumber) {
          Write-Error -Message "'$Name' Number '$PhoneNumber' is already assigned to another User" -Category NotImplemented -RecommendedAction "Please specify a different Number " -ErrorAction Stop
        }

        # Loading all Microsoft Telephone Numbers
        $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
        $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
      }
      else {
        Write-Error -Message "PhoneNumber '$PhoneNumber' - Not a valid Phone number. Please provide a number starting with a + and 10 to 15 digits long" -ErrorAction Stop
      }
    }
    #endregion

    #region UsageLocation
    $CurrentUsageLocation = (Get-AzureADUser -ObjectId "$UserPrincipalName" -WarningAction SilentlyContinue).UsageLocation
    if ($PSBoundParameters.ContainsKey('UsageLocation')) {
      if ($Usagelocation -eq $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location already set to: $CurrentUsageLocation"
      }
      elseif ($null -eq $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location not set! Will be set to: $Usagelocation"
      }
    }
    else {
      if ($null -ne $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location currently set to: $CurrentUsageLocation"
        $UsageLocation = $CurrentUsageLocation
      }
      else {
        if (($PSBoundParameters.ContainsKey('License')) -or ($PSBoundParameters.ContainsKey('PhoneNumber'))) {
          Write-Error -Message "'$Name' Usage Location not set!" -Category ObjectNotFound -RecommendedAction "Please run command again and specify -UsageLocation" -ErrorAction Stop
        }
        else {
          Write-Warning -Message "'$Name' Usage Location not set! This is a requirement for License assignment and Phone Number"
        }
      }
    }
    #endregion

    #region Current License
    if ($PSBoundParameters.ContainsKey("License") -or $PSBoundParameters.ContainsKey("PhoneNumber")) {
      $CurrentLicense = $null
      # Determining license Status of Object
      if (Test-TeamsUserLicense -Identity $UserPrincipalName -License PhoneSystem) {
        $CurrentLicense = "PhoneSystem"
      }
      elseif (Test-TeamsUserLicense -Identity $UserPrincipalName -License PhoneSystemVirtualUser) {
        $CurrentLicense = "PhoneSystemVirtualUser"
      }
      if ($null -ne $CurrentLicense) {
        Write-Verbose -Message "'$Name' Current License assigned: $CurrentLicense"
      }
      else {
        Write-Verbose -Message "'$Name' Current License assigned: NONE"
      }
    }
    #endregion
    #endregion


    #region ACTION
    Write-Verbose -Message "Applying Settings"
    #region DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      try {
        if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -Displayname `"$DisplayNameNormalised`"")) {
          Write-Verbose -Message "'$CurrentDisplayName' Changing DisplayName to: $DisplayNameNormalised"
          $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -Displayname "$DisplayNameNormalised" -ErrorAction STOP)
          Write-Verbose "SUCCESS: Displayname changed to '$DisplayName'" -Verbose
          $CurrentDisplayName = $Object.DisplayName
        }
      }
      catch {
        Write-Verbose -Message "FAILED - Error encountered changing DisplayName"
        Write-Error -Message "Problem encountered with changing DisplayName" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
        Write-ErrorRecord $_ #This handles the error message in human readable format.
      }
    }
    #endregion

    #region Application Type
    if ($PSBoundParameters.ContainsKey("ApplicationType")) {
      # Application Type Change?
      if ($AppId -ne $CurrentAppId) {
        try {
          if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -ApplicationId $AppId")) {
            Write-Verbose -Message "'$Name' Setting Application Type to: $ApplicationType"
            $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -ApplicationId $AppId -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS"
          }
        }
        catch {
          Write-Error -Message "Problem encountered changing Application Type" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
          Write-ErrorRecord $_ #This handles the error message in human readable format.
        }
      }
    }
    #endregion

    #region UsageLocation
    if ($PSBoundParameters.ContainsKey("UsageLocation")) {
      if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-AzureADUser -UsageLocation $UsageLocation")) {
        try {
          Set-AzureADUser -ObjectId $UserPrincipalName -UsageLocation $UsageLocation -ErrorAction STOP
          Write-Verbose -Message "'$Name' SUCCESS - Usage Location set to: $UsageLocation"
        }
        catch {
          if ($PSBoundParameters.ContainsKey("License")) {
            Write-Error -Message "'$Name' Usage Location could not be set. Please apply manually before applying license" -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount to apply license and phone number"
          }
          else {
            Write-Warning -Message "'$Name' Usage Location cannot be set. If a license is needed, please assign UsageLocation manually beforehand"
          }
        }
      }
    }
    #endregion

    #region Licensing
    if ($PSBoundParameters.ContainsKey("License")) {
      # Verifying License is available to be assigned
      # Determining available Licenses from Tenant
      Write-Verbose -Message "'$Name' Querying Licenses..."
      $TenantLicenses = Get-TeamsTenantLicense

      # Changing License only if required
      if ($License -eq $CurrentLicense) {
        # No action required
        Write-Verbose -Message "'$Name' License '$License' already assigned." -Verbose
        $IsLicensed = $true
      }
      # Verifying License is available
      elseif ($License -eq "PhoneSystemVirtualUser") {
        $RemainingPSVULicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "PHONESYSTEM_VIRTUALUSER" }).Remaining
        Write-Verbose -Message "INFO: $RemainingPSVULicenses remaining Phone System Virtual User Licenses"
        if ($RemainingPSVULicenses -lt 1) {
          Write-Error -Message "ERROR: No free PhoneSystem Virtual User License remaining in the Tenant."
        }
        else {
          try {
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-TeamsUserLicense -AddLicenses PhoneSystemVirtualUser")) {
              $null = (Set-TeamsUserLicense -Identity $UserPrincipalName -AddLicenses $License -ErrorAction STOP)
              Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'"
              $IsLicensed = $true
            }
          }
          catch {
            Write-Error -Message "'$Name' License assignment failed for '$License'"
            Write-ErrorRecord $_ #This handles the error message in human readable format.
          }
        }
      }
      else {
        try {
          if ($PSCmdlet.ShouldProcess("$UPN", "Set-TeamsUserLicense -AddLicenses $License")) {
            $null = (Set-TeamsUserLicense -Identity $UPN -AddLicenses $License -ErrorAction STOP)
            Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'"
            $IsLicensed = $true
          }
        }
        catch {
          Write-Error -Message "'$Name' License assignment failed for '$License'"
          Write-ErrorRecord $_ #This handles the error message in human readable format.
        }
      }
    }
    #endregion

    #region Waiting for License Application
    if ($PSBoundParameters.ContainsKey("License") -and $PSBoundParameters.ContainsKey("PhoneNumber")) {
      if ($License -eq "PhoneSystemVirtualUser") {
        $ServicePlanName = "MCOEV_VIRTUALUSER"
      }
      else {
        $ServicePlanName = "MCOEV"
      }
      $i = 0
      $imax = 360
      Write-Warning -Message "Applying a License may take longer than provisioned for ($($imax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
      Write-Verbose -Message "Waiting for Get-AzureAdUserLicenseDetail to return a Result..."
      while (-not (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan $ServicePlanName)) {
        if ($i -gt $imax) {
          Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $imax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount"
          return
        }
        Write-Progress -Activity "'$Name' Azure Active Directory is applying License. Please wait" `
          -PercentComplete (($i * 100) / $imax) `
          -Status "$(([math]::Round((($i)/$imax * 100),0))) %"

        Start-Sleep -Milliseconds 1000
        $i++
      }
    }
    #endregion

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      if ($null -eq $CurrentLicense -and -not $IsLicensed) {
        Write-Error -Message "A Phone Number can only be assigned to licensed objects." -Category ResourceUnavailable -RecommendedAction "Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both"
      }
      else {
        # Removing old Number (if $null or different to current)
        if ($null -eq $PhoneNumber -or $CurrentPhoneNumber -ne $PhoneNumber) {
          Write-Verbose -Message "'$Name' ACTION: Removing Phone Number"
          try {
            if ($null -ne ($Object.TelephoneNumber)) {
              # Remove from VoiceApplicationInstance
              Write-Verbose -Message "'$Name' Removing Microsoft Number"
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
              Write-Verbose -Message "SUCCESS"
            }
            if ($null -ne ($Object.OnPremLineURI)) {
              # Remove from ApplicationInstance
              Write-Verbose -Message "'$Name' Removing Direct Routing Number"
              $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
              Write-Verbose -Message "SUCCESS"
            }
          }
          catch {
            Write-Error -Message "Removal of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
            Write-ErrorRecord $_ #This handles the error message in human readable format.
          }
        }
        else {


        }
        # Assigning Telephone Number
        if ($null -ne $PhoneNumber) {
          Write-Verbose -Message "'$Name' ACTION: Assigning Phone Number"
          # Assigning new Number
          # Processing paths for Telephone Numbers depending on Type
          try {
            if ($PhoneNumberIsMSNumber) {
              # Set in VoiceApplicationInstance
              if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $PhoneNumber")) {
                Write-Verbose -Message "'$Name' Number '$PhoneNumber' found in Tenant, assuming provisioning Microsoft for: Microsoft Calling Plans" -Verbose
                $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $PhoneNumber -ErrorAction STOP)
              }
            }
            else {
              # Set in ApplicationInstance
              if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $PhoneNumber")) {
                Write-Verbose -Message "'$Name' Number '$PhoneNumber' not found in Tenant, assuming provisioning for: Direct Routing" -Verbose
                $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $PhoneNumber -ErrorAction STOP)
              }
            }
          }
          catch [ApplicationInstanceManagementException] {
            Write-Error -Message "'$Name' Number '$PhoneNumber' not assigned! Number is already assigned to another User" -Category NotImplemented -RecommendedAction "Please specify a different Number "
          }
          catch {
            Write-Error -Message "'$Name' Number '$PhoneNumber' not assigned!" -Category NotImplemented -RecommendedAction "Please run Set-TeamsResourceAccount manually"
            Write-ErrorRecord $_ #This handles the error message in human readable format.
          }

        }
      }
    }
    #endregion
    #endregion
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"

  } #end
} #Set-TeamsResourceAccount
