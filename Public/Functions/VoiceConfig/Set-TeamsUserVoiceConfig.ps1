# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function Set-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Enables a User to consume Voice services in Teams (Pstn breakout)
	.DESCRIPTION
    Enables a User for Direct Routing, Microsoft Callings or for use in Call Queues (EvOnly)
    User requires a Phone System License in any case.
  .PARAMETER Identity
    UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER DirectRouting
    Optional (Default). Limits the Scope to enable an Object for DirectRouting
  .PARAMETER CallingPlans
    Required for CallingPlans. Limits the Scope to enable an Object for CallingPlans
  .PARAMETER PhoneNumber
    Optional. Phone Number in E.164 format to be assigned to the User.
    For DirectRouting, will populate the OnPremLineUri
    For CallingPlans, will populate the TelephoneNumber (must be present in the Tenant)
    NOTE: Without a Phone Number, the User will not be able to make or receive calls.
    NOTE: This script cannot apply PhoneNumbers for OperatorConnect yet!
  .PARAMETER OnlineVoiceRoutingPolicy
    Required for DirectRouting. Assigns an Online Voice Routing Policy to the User
  .PARAMETER TenantDialPlan
    Optional for DirectRouting. Assigns a Tenant Dial Plan to the User
  .PARAMETER CallingPlanLicense
    Optional for CallingPlans. Assigns a Calling Plan License to the User.
    Must be one of the set: InternationalCallingPlan DomesticCallingPlan DomesticCallingPlan120 CommunicationCredits DomesticCallingPlan120b
	.PARAMETER PassThru
    Optional. Displays Object after action.
  .PARAMETER Force
    By default, this script only applies changed elements. Force overwrites configuration regardless of current status.
    Additionally Suppresses confirmation inputs except when $Confirm is explicitly specified
	.PARAMETER WriteErrorLog
    If Errors are encountered, writes log to C:\Temp
  .EXAMPLE
		Set-TeamsUserVoiceConfig -Identity John@domain.com -CallingPlans -PhoneNumber "+15551234567" -CallingPlanLicense DomesticCallingPlan
    Provisions John@domain.com for Calling Plans with the Calling Plan License and Phone Number provided
  .EXAMPLE
		Set-TeamsUserVoiceConfig -Identity John@domain.com -CallingPlans -PhoneNumber "+15551234567" -WriteErrorLog
    Provisions John@domain.com for Calling Plans with the Phone Number provided (requires Calling Plan License to be assigned already)
    If Errors are encountered, they are written to C:\Temp as well as on screen
  .EXAMPLE
    Set-TeamsUserVoiceConfig -Identity John@domain.com -DirectRouting -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided
	.EXAMPLE
    Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER" -TenantDialPlan "DP-US"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy, Tenant Dial Plan and Phone Number provided
  .EXAMPLE
    Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided.
  .INPUTS
    System.String
  .OUTPUTS
    System.Void (without Switch PassThru)
    System.Object (with Switch PassThru)
    System.File (with Switch WriteErrorLog)
	.NOTES
    ParameterSet 'DirectRouting' will provision a User to use DirectRouting. Enables User for Enterprise Voice,
    assigns a Number and an Online Voice Routing Policy and optionally also a Tenant Dial Plan. This is the default.
    ParameterSet 'CallingPlans' will provision a User to use Microsoft CallingPlans.
    Enables User for Enterprise Voice and assigns a Microsoft Number (must be found in the Tenant!)
    Optionally can also assign a Calling Plan license prior.
    This script does not allow Pipeline input
	.FUNCTIONALITY
		TeamsUserVoiceConfig
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Find-TeamsUserVoiceConfig
  .LINK
    Get-TeamsTenantVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
  .LINK
    Remove-TeamsUserVoiceConfig
  .LINK
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DirectRouting', ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ValueFromPipeline, HelpMessage = 'UserPrincipalName of the User')]
    #[Alias('Identity')]
    [string]$UserPrincipalName,

    [Parameter(ParameterSetName = 'DirectRouting', HelpMessage = 'Enables an Object for Direct Routing')]
    [switch]$DirectRouting,

    [Parameter(ParameterSetName = 'DirectRouting', HelpMessage = 'Name of the Online Voice Routing Policy')]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(HelpMessage = 'Name of the Tenant Dial Plan')]
    [Alias('TDP')]
    [string]$TenantDialPlan,

    [Parameter(HelpMessage = 'E.164 Number to assign to the Object')]
    [AllowNull()]
    [AllowEmptyString()]
    [Alias('Number', 'LineURI')]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = 'CallingPlans', Mandatory, HelpMessage = 'Enables an Object for Microsoft Calling Plans')]
    [switch]$CallingPlan,

    [Parameter(ParameterSetName = 'CallingPlans', HelpMessage = 'Calling Plan License to assign to the Object')]
    [ValidateScript( {
        $CallingPlanLicenseValues = (Get-AzureAdLicense | Where-Object LicenseType -EQ 'CallingPlan').ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $CallingPlanLicenseValues) {
          $True
        }
        else {
          Write-Host "Parameter 'CallingPlanLicense' must be of the set: $CallingPlanLicenseValues"
        }
      })]
    [string[]]$CallingPlanLicense,

    [Parameter(HelpMessage = 'Suppresses confirmation prompt unless -Confirm is used explicitly')]
    [switch]$Force,

    [Parameter(HelpMessage = 'No output is written by default, Switch PassThru will return changed object')]
    [switch]$PassThru,

    [Parameter(HelpMessage = 'Writes a Log File to C:\Temp')]
    [switch]$WriteErrorLog
  ) #param

  begin {
    #break
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

    # Initialising $ErrorLog
    [System.Collections.ArrayList]$ErrorLog = @()

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 7 #+2 correct?
    switch ($PsCmdlet.ParameterSetName) {
      'DirectRouting' {
        $sMax++
      }
      'OperatorConnect' {
        #$sMax++
      }
      'CallingPlans' {
        $sMax++
        if ( $PhoneNumber ) { $sMax++ }
        if ( -not $CallingPlanLicense ) { $sMax++ }
      }
    }
    if ( $TenantDialPlan ) { $sMax++ }
    if ( $Force ) { $sMax = $sMax + 2 }
    if ( $PhoneNumber ) { $sMax = $sMax + 2 } #+1 correct?

    if ( $WriteErrorLog ) { $sMax++ }
    if ( $PassThru ) { $sMax++ }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "[PROCESS] Processing '$UserPrincipalName'"
    #region Information Gathering and Verification
    $Status = 'Information Gathering and Verification'
    Write-Verbose -Message "[PROCESS] $Status"
    #region Excluding Resource Accounts
    $Operation = 'Querying Account Type is not a Resource Account'
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $ResourceAccounts = (Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue).UserPrincipalName
    if ( $UserPrincipalName -in $ResourceAccounts) {
      Write-Error -Message 'Resource Account specified! Please use Set-TeamsResourceAccount to provision Resource Accounts' -Category InvalidType -RecommendedAction 'Please use Set-TeamsResourceAccount to provision Resource Accounts'
      return
    }
    #endregion

    #region Querying Identity
    try {
      $Operation = 'Querying User Account'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      $CsUser = Get-TeamsUserVoiceConfig "$UserPrincipalName" -WarningAction SilentlyContinue -ErrorAction Stop
      $UserLic = Get-AzureAdUserLicense -Identity "$UserPrincipalName" -WarningAction SilentlyContinue -ErrorAction Stop
      $IsEVenabled = $CsUser.EnterpriseVoiceEnabled
    }
    catch {
      Write-Error "User '$UserPrincipalName' not found: $($_.Exception.Message)" -Category ObjectNotFound
      $ErrorLog += $_.Exception.Message
      return $ErrorLog
    }
    #endregion

    #region Querying User Licenses
    #TODO This works (don't change?) - But could be replaced with Assert-TeamsCallableEntity - Does check license AND to be extended for PhoneSystemStatus too
    try {
      $Operation = 'Querying User License'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      if ( $CsUser.PhoneSystem ) {
        Write-Verbose -Message "User '$UserPrincipalName' - PhoneSystem License is assigned - Validating PhoneSystemStatus"
        if ( -not $CsUser.PhoneSystemStatus.Contains('Success')) {
          try {
            if ( $CsUser.PhoneSystemStatus.Contains('Disabled')) {
              Write-Information "TRYING:  User '$UserPrincipalName' - PhoneSystem License is assigned - ServicePlan PhoneSystem is Disabled - Trying to activate"
              Set-AzureAdLicenseServicePlan -Identity $CsUser.UserPrincipalName -Enable MCOEV -ErrorAction Stop
              if (-not (Get-AzureAdUserLicense -Identity "$UserPrincipalName").PhoneSystemStatus.Contains('Success')) {
                throw
              }
            }
            else {
              Write-Information "TRYING:  User '$UserPrincipalName' - PhoneSystem License is assigned - ServicePlan is: $($CsUser.PhoneSystemStatus)"
            }
          }
          catch {
            throw "User '$UserPrincipalName' - is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status must be 'Success'"
          }
        }

        if ( $CsUser.PhoneSystemStatus.Contains(',')) {
          Write-Warning -Message "User '$UserPrincipalName' - PhoneSystem License: Multiple assignments found. Please verify License assignment."
          Write-Verbose -Message 'All licenses assigned to the User:' -Verbose
          Write-Output $UserLic.Licenses
        }
      }
      else {
        throw "User '$UserPrincipalName' - PhoneSystem License is not assigned"
      }
    }
    catch {
      # Unlicensed
      if ($force) {
        Write-Warning -Message "User '$UserPrincipalName' - PhoneSystem License is not correctly licensed. PhoneSystem Service Plan status must be 'Success'. Assignment will continue, though will be only partially successful."
      }
      else {
        Write-Verbose -Message 'License Status:' -Verbose
        $UserLic.Licenses
        Write-Verbose -Message 'Service Plan Status (PhoneSystem):' -Verbose
        $UserLic.ServicePlans | Where-Object ServicePlanName -EQ 'MCOEV'
        $ErrorLog += $_.Exception.Message
        Write-Error -Message "User '$UserPrincipalName' - PhoneSystem License is not correctly licensed. Please check License assignment. PhoneSystem Service Plan status must be 'Success'."
        return
        #throw "User '$UserPrincipalName' - PhoneSystem License is not correctly licensed. Please check License assignment. PhoneSystem Service Plan status must be 'Success'."
      }
    }
    #endregion

    #region Calling Plans - Number verification
    if ( $PSCmdlet.ParameterSetName -eq 'CallingPlans' ) {
      # Validating License assignment
      try {
        if ( -not $CallingPlanLicense ) {
          $Operation = 'Testing Object for Calling Plan License'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          if ( -not $CsUser.LicensesAssigned.Contains('Calling')) {
            throw "User '$UserPrincipalName' - User is not licensed correctly. Please check License assignment. A Calling Plan License is required"
          }
        }
      }
      catch {
        # Unlicensed
        $ErrorLogMessage = 'User is not licensed (CallingPlan). Please assign a Calling Plan license'
        Write-Error -Message $ErrorLogMessage -Category ResourceUnavailable -RecommendedAction 'Please assign a Calling Plan license' -ErrorAction Stop
        $ErrorLog += $ErrorLogMessage
        $ErrorLog += $_.Exception.Message
        return $ErrorLog
      }

      if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        # Validating Microsoft Number
        $Operation = 'Querying Microsoft Phone Numbers from Tenant'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"

        if (-not $global:TeamsFunctionsMSTelephoneNumbers) {
          $global:TeamsFunctionsMSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
        }
        $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
        $PhoneNumberIsMSNumber = ($MSNumber -in $global:TeamsFunctionsMSTelephoneNumbers.Id)
        if ($PhoneNumberIsMSNumber) {
          Write-Verbose -Message "Phone Number '$PhoneNumber' found in the Tenant."
        }
        else {
          $ErrorLogMessage = "Phone Number '$PhoneNumber' is not found in the Tenant. Please provide an available number"
          Write-Error -Message $ErrorLogMessage
          $ErrorLog += $ErrorLogMessage
        }
      }
    }
    #endregion

    #region Validating Phone Number Format
    $Operation = 'Querying current Phone Number'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    # Querying CurrentPhoneNumber
    try {
      $CurrentPhoneNumber = $CsUser.LineUri
      Write-Verbose -Message "User '$UserPrincipalName' - Phone Number assigned currently: $CurrentPhoneNumber"
    }
    catch {
      $CurrentPhoneNumber = $null
      Write-Verbose -Message "User '$UserPrincipalName' - Phone Number assigned currently: NONE"
    }

    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      $Operation = 'Validating Phone Number format'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      if ( [String]::IsNullOrEmpty($PhoneNumber) ) {
        #TEST this. Was prior: if ($PhoneNumber -eq '' -or $null -eq $PhoneNumber) {
        if ($CurrentPhoneNumber) {
          Write-Warning -Message "User '$UserPrincipalName' - PhoneNumber is NULL or Empty. The Existing Number '$CurrentPhoneNumber' will be removed"
        }
        else {
          Write-Verbose -Message "User '$UserPrincipalName' - PhoneNumber is NULL or Empty, but no Number is currently assigned. No Action taken"
        }
        $PhoneNumber = $null
      }
      else {
        if ($PhoneNumber -match '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{7,15}))?((;( |-)?ext=[0-9]{3,8}))?$') {
          $E164Number = Format-StringForUse $PhoneNumber -As E164
          $LineUri = Format-StringForUse $PhoneNumber -As LineUri
          if ($CurrentPhoneNumber -eq $LineUri -and -not $force) {
            Write-Verbose -Message "User '$UserPrincipalName' - PhoneNumber '$LineUri' is already applied"
          }
          else {
            Write-Verbose -Message "User '$UserPrincipalName' - PhoneNumber '$LineUri' is in a usable format and will be applied"
            # Checking number is free
            Write-Verbose -Message "User '$UserPrincipalName' - PhoneNumber - Finding Number assignments"
            $UserWithThisNumber = Find-TeamsUserVoiceConfig -PhoneNumber $E164Number
            if ($UserWithThisNumber) {
              if ($Force) {
                Write-Warning -Message "User '$UserPrincipalName' - Number '$LineUri' is currently assigned to User '$($UserWithThisNumber.UserPrincipalName)'. This assignment will be removed!"
              }
              else {
                Write-Error -Message "User '$UserPrincipalName' - Number '$LineUri' is already assigned to another Object: '$($UserWithThisNumber.UserPrincipalName)'" -Category NotImplemented -RecommendedAction 'Please specify a different Number or use -Force to re-assign' -ErrorAction Stop
              }
            }
          }
        }
        else {
          Write-Error -Message 'PhoneNumber '$LineUri' is not in an acceptable format. Multiple formats are expected, but preferred is E.164 or LineURI format, with a minimum of 8 digits.' -Category InvalidFormat
        }
      }
    }
    else {
      #PhoneNumber is not provided
      if ( -not $CurrentPhoneNumber -and -not $(Format-StringForUse $PhoneNumber -As LineUri) ) {
        Write-Warning -Message "User '$UserPrincipalName' - Phone Number not provided or present. User will not be able to use PhoneSystem"
      }
    }
    #endregion

    #region Enable if not Enabled for EnterpriseVoice
    $Operation = 'Enterprise Voice'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    if ( -not $IsEVenabled) {
      Write-Verbose "User '$UserPrincipalName' - $Operation`: Not enabled, trying to Enable"
      if ($Force -or $PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
        $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $UserPrincipalName -Force
        if ($IsEVenabled) {
          Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK"
        }
      }
    }
    else {
      Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Already enabled" -Verbose
    }

    if ( -not $IsEVenabled) {
      Write-Error -Message "User '$UserPrincipalName' - $Operation`: Could not enable Object. Please investigate"
      return
    }
    #endregion

    #endregion


    #region Apply Voice Config
    if ($Force -or $PSCmdlet.ShouldProcess("$UserPrincipalName", 'Apply Voice Configuration')) {
      #region Generic Configuration
      $Status = 'Applying Voice Configuration: Generic'
      #region Enable HostedVoicemail
      $Operation = 'Hosted Voicemail'
      $step++
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      if ( $Force -or -not $CsUser.HostedVoicemail) {
        try {
          $CsUser | Set-CsUser -HostedVoiceMail $TRUE -ErrorAction Stop
          Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK"
        }
        catch {
          $ErrorLogMessage = "User '$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
          Write-Error -Message $ErrorLogMessage
          $ErrorLog += $ErrorLogMessage
        }
      }
      else {
        Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Already enabled" -Verbose
      }
      #endregion

      #region Tenant Dial Plan
      $Operation = 'Tenant Dial Plan'
      Write-Verbose -Message "$Status - $Operation"
      if ( $TenantDialPlan ) {
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        if ( $Force -or $CsUser.TenantDialPlan -ne $TenantDialPlan) {
          try {
            $CsUser | Grant-CsTenantDialPlan -PolicyName $TenantDialPlan -ErrorAction Stop
            Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - '$TenantDialPlan'"
          }
          catch {
            $ErrorLogMessage = "User '$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
            Write-Error -Message $ErrorLogMessage
            $ErrorLog += $ErrorLogMessage
          }
        }
        else {
          Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Already assigned" -Verbose
        }
      }
      else {
        if ($CsUser.TenantDialPlan) {
          Write-Information "CURRENT: User '$UserPrincipalName' - $Operation`: '$($CsUser.TenantDialPlan)' assigned currently"
        }
        else {
          Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Not provided"
        }
      }
      #endregion
      #endregion

      #region Specific Configuration 1
      switch ($PSCmdlet.ParameterSetName) {
        'DirectRouting' {
          $Status = 'Applying Voice Configuration: Provisioning for Direct Routing'
          Write-Verbose -Message "[PROCESS] $Status"
          $Operation = 'Online Voice Routing Policy'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          # Apply $OnlineVoiceRoutingPolicy
          if ( $OnlineVoiceRoutingPolicy ) {
            if ( $Force -or ($CsUser.OnlineVoiceRoutingPolicy -ne $OnlineVoiceRoutingPolicy) ) {
              try {
                $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
                Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - '$OnlineVoiceRoutingPolicy'"
              }
              catch {
                $ErrorLogMessage = "User '$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
                Write-Error -Message $ErrorLogMessage
                $ErrorLog += $ErrorLogMessage
              }
            }
            else {
              Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Already assigned" -Verbose
            }
          }
          else {
            if ( $CsUser.OnlineVoiceRoutingPolicy ) {
              Write-Information "CURRENT: User '$UserPrincipalName' - $Operation`: $($CsUser.OnlineVoiceRoutingPolicy)' assigned currently"
            }
            else {
              Write-Warning -Message "User '$UserPrincipalName' - $Operation`: Not assigned. User will be able to receive inbound calls, but not place them!'"
            }
          }
        }
        'OperatorConnect' {
          $Status = 'Applying Voice Configuration: Provisioning for Operator Connect'
          Write-Verbose -Message "[PROCESS] $Status"
          #TODO prepare for OperatorConnect - how?
          <#
          $Operation = 'TBC'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          #>
        }
        'CallingPlans' {
          $Status = 'Applying Voice Configuration: Provisioning for Calling Plans'
          Write-Verbose -Message "[PROCESS] $Status"
          $Operation = 'Calling Plan License'
          $step++
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"
          # Apply $CallingPlanLicense
          if ($CallingPlanLicense) {
            try {
              $null = Set-TeamsUserLicense -Identity $UserPrincipalName -Add $CallingPlanLicense -ErrorAction Stop
              Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - '$CallingPlanLicense'"
            }
            catch {
              $ErrorLogMessage = "User '$UserPrincipalName' - $Operation`: Failed for '$CallingPlanLicense' with Exception: '$($_.Exception.Message)'"
              Write-Error -Message $ErrorLogMessage
              $ErrorLog += $ErrorLogMessage
            }
            #CHECK Waiting period after applying a Calling Plan license? Will Phone Number assignment succeed right away?
            Write-Verbose -Message 'Calling Plan License has been applied, but replication time has not been factored in or tested. Applying a Phone Number may fail. If so, please run command again after a few minutes and feed back duration to TeamsFunctions@outlook.com or via GitHub!' -Verbose
          }
        }
      }
      #endregion

      #region Specific Configuration 2 - Phone Number

      #region Removing number from OTHER Object
      if ( $Force -and $PhoneNumber -and $UserWithThisNumber ) {
        $Operation = 'Scavenging Phone Number'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        #TEST ForEach Loop - for $UserWithThisNumber
        foreach ($UserWTN in $UserWithThisNumber) {
          try {
            Write-Verbose -Message "User '$UserPrincipalName' - $Operation FROM '$($UserWTN.UserPrincipalName)'"
            if ($UserWTN.InterpretedUserType.Contains('ApplicationInstance')) {
              if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                Set-TeamsResourceAccount -UserPrincipalName $($UserWTN.UserPrincipalName) -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Information "SUCCESS: Resource Account '$($UserWTN.UserPrincipalName)' - $Operation`: OK"
              }
            }
            elseif ($UserWTN.InterpretedUserType.Contains('User')) {
              if ($PSCmdlet.ShouldProcess("$($UserWTN.UserPrincipalName)", 'Set-TeamsUserVoiceConfig')) {
                $UserWTN | Set-TeamsUserVoiceConfig -PhoneNumber $Null -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Information "SUCCESS: User '$($UserWTN.UserPrincipalName)' - $Operation`: OK"
              }
            }
            else {
              Write-Error -Message "Scavenging Phone Number from $($UserWTN.UserPrincipalName) failed. Object is not a User or a ResourceAccount" -ErrorAction Stop
            }
          }
          catch {
            Write-Error -Message "Scavenging Phone Number from $($UserWTN.UserPrincipalName) failed with Exception: $($_.Exception.Message)" -ErrorAction Stop
          }
        }
      }
      #endregion

      #region Remove Number from current Object
      if ( $force -or [String]::IsNullOrEmpty($PhoneNumber) ) {
        if ([String]::IsNullOrEmpty($PhoneNumber)) {
          Write-Warning -Message "User '$UserPrincipalName' - PhoneNumber is empty and will be removed. The User will not be able to use PhoneSystem!"
        }
        $Operation = 'Removing Phone Number'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        try {
          if ($PhoneNumberIsMSNumber) {
            # Remove MS Number
            $CsUser | Set-CsUser -TelephoneNumber $null -ErrorAction Stop
            Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - Calling Plan number removed"
          }
          else {
            # Remove Direct Routing Number
            $CsUser | Set-CsUser -OnPremLineURI $null -ErrorAction Stop
            Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - Direct Routing number removed"
          }
        }
        catch {
          if ($_.Exception.Message.Contains('dirsync')) {
            Write-Warning -Message "User '$UserPrincipalName' - $Operation`: Failed: Object needs to be changed in Skype OnPrem. Please run the following CmdLet against Skype"
            Write-Host "Set-CsUser -Identity $UserPrincipalName -HostedVoiceMail $null -LineUri $null" -ForegroundColor Magenta
          }
          else {
            Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'" -Verbose
          }
        }
      }
      #endregion

      #region Applying Phone Number
      if ( -not [String]::IsNullOrEmpty($PhoneNumber) ) {
        $Operation = 'Applying Phone Number'
        $step++
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        switch ($PSCmdlet.ParameterSetName) {
          'DirectRouting' {
            # Apply or Remove $PhoneNumber as OnPremLineUri
            if ( $Force -or $CsUser.OnPremLineURI -ne $LineUri) {
              #TODO Add Catch that uses FORCE to remove PhoneNumber first (from Object it is assigned to!)
              #CHECK this: Set-TeamsRA removes first (if Force or Empty), then applies anew (if force or not empty) - replicate?
              #Error Message: Filter failed to return unique result"
              try {
                $CsUser | Set-CsUser -OnPremLineURI $LineUri -ErrorAction Stop
                Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - '$LineUri'"
              }
              catch {
                if ($_.Exception.Message.Contains('dirsync')) {
                  Write-Warning -Message "User '$UserPrincipalName' - $Operation`: Failed: Object needs to be changed in Skype OnPrem. Please run the following CmdLet against Skype"
                  Write-Host "Set-CsUser -Identity $UserPrincipalName -LineUri '$LineUri'" -ForegroundColor Magenta
                }
                else {
                  $ErrorLogMessage = "User '$UserPrincipalName' - $Operation`: Failed: '$($_.Exception.Message)'"
                  Write-Error -Message $ErrorLogMessage
                }
                $ErrorLog += $ErrorLogMessage
              }
            }
            else {
              Write-Verbose -Message "User '$UserPrincipalName' - $Operation`: Already assigned" -Verbose
            }

          }
          'OperatorConnect' {
            #TODO prepare for OperatorConnect - how?
          }
          'CallingPlans' {
            # Apply or Remove $PhoneNumber as TelephoneNumber
            if ( $Force -or $CsUser.TelephoneNumber -ne $E164Number) {
              try {
                # Pipe should work but was not yet tested.
                #$CsUser | Set-CsOnlineVoiceUser -TelephoneNumber $PhoneNumber -ErrorAction Stop
                $null = Set-CsOnlineVoiceUser -Identity $($CsUser.ObjectId) -TelephoneNumber $E164Number -ErrorAction Stop
                Write-Information "SUCCESS: User '$UserPrincipalName' - $Operation`: OK - '$E164Number' (Calling Plan Number)"
              }
              catch {
                $ErrorLogMessage = "User '$UserPrincipalName' - Applying Phone Number failed: '$($_.Exception.Message)'"
                Write-Error -Message $ErrorLogMessage
                $ErrorLog += $ErrorLogMessage
              }
            }
            else {
              Write-Verbose -Message "User '$UserPrincipalName' - Applying Phone Number: Already assigned" -Verbose
            }

          }
        }
      }
      #endregion
      #endregion
    }
    #endregion
    #endregion


    #region Log & Output
    # Write $ErrorLog
    if ( $WriteErrorLog ) {
      $Path = 'C:\Temp'
      $Filename = "$($MyInvocation.MyCommand) - $UserPrincipalName - ERROR.log"
      $LogPath = "$Path\$Filename"
      $step++
      Write-Progress -Id 0 -Status 'Output' -CurrentOperation 'Writing ErrorLog' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$UserPrincipalName - Errors encountered are written to '$Path'"

      # Write log entry to $Path
      $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K') | Out-File -FilePath $LogPath -Append
      $errorLog | Out-File -FilePath $LogPath -Append

    }
    else {
      Write-Verbose -Message "$UserPrincipalName - No errors encountered! No log file written."
    }


    # Output
    if ( $PassThru ) {
      # Re-Query Object
      $step++
      Write-Progress -Id 0 -Status 'Output' -CurrentOperation 'Waiting for Office 365 to write the Object' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Waiting 3-5s for Office 365 to write changes to User Object (Policies might not show up yet)'
      Start-Sleep -Seconds 3
      $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $UserPrincipalName
      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Start-Sleep -Seconds 2
        $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $UserPrincipalName
      }

      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Write-Warning -Message 'Applied Policies take some time to show up on the object. Please verify again with Get-TeamsUserVoiceConfig'
      }

      Write-Progress -Id 0 -Status 'Provisioning' -Activity $MyInvocation.MyCommand -Completed
      return $UserObjectPost
    }
    else {
      Write-Progress -Id 0 -Status 'Provisioning' -Activity $MyInvocation.MyCommand -Completed
      return
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceConfig
