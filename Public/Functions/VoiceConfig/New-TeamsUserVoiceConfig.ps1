# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live




function New-TeamsUserVoiceConfig {
  <#
	.SYNOPSIS
		Enables a User to consume Voice services in Teams (Pstn breakout)
	.DESCRIPTION
    Enables a User for Direct Routing, Microsoft Callings or for use in Call Queues (EvOnly)
    User requires a Phone System License in any case.
    Applies full configuration
  .PARAMETER Identity
    UserPrincipalName (UPN) of the User to change the configuration for
  .PARAMETER DirectRouting
    Optional (Default). Limits the Scope to enable an Object for DirectRouting
  .PARAMETER CallingPlans
    Required for CallingPlans. Limits the Scope to enable an Object for CallingPlans
  .PARAMETER PhoneNumber
    Required. Phone Number in E.164 format to be assigned to the User.
    For DirectRouting, will populate the OnPremLineUri
    For CallingPlans, will populate the TelephoneNumber (must be present in the Tenant)
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
    New-TeamsUserVoiceConfig
  .LINK
    Set-TeamsUserVoiceConfig
  .LINK
    Remove-TeamsUserVoiceConfig
  .LINK
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'DirectRouting', ConfirmImpact = 'Medium')]
  [Alias('New-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, HelpMessage = 'UserPrincipalName of the User')]
    [Alias('UserPrincipalName')]
    [string]$Identity,

    [Parameter(ParameterSetName = 'DirectRouting', HelpMessage = 'Enables an Object for Direct Routing')]
    [switch]$DirectRouting,

    [Parameter(ParameterSetName = 'DirectRouting', HelpMessage = 'Name of the Online Voice Routing Policy')]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(HelpMessage = 'Name of the Tenant Dial Plan')]
    [Alias('TDP')]
    [string]$TenantDialPlan,

    [Parameter(Mandatory, HelpMessage = 'E.164 Number to assign to the Object')]
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
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

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
    [int]$sMax = switch ($PsCmdlet.ParameterSetName) {
      'DirectRouting' { 8 }
      'CallingPlans' { if ( -not $CallingPlanLicense ) { 10 } else { 9 } }
    }
    if ( $TenantDialPlan ) { $sMax++ }
    if ( $WriteErrorLog ) { $sMax++ }
    if ( $PassThru ) { $sMax++ }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "[PROCESS] Processing '$Identity'"
    #region Information Gathering and Verification
    # Excluding Resource Accounts
    Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Querying Account Type is not a Resource Account' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message 'Querying Account Type'
    $ResourceAccounts = (Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue).UserPrincipalName
    if ( $Identity -in $ResourceAccounts) {
      Write-Error -Message 'Resource Account specified! Please use Set-TeamsResourceAccount to provision Resource Accounts' -Category InvalidType -RecommendedAction 'Please use Set-TeamsResourceAccount to provision Resource Accounts'
      return
    }

    # Querying Identity
    try {
      $step++
      Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Querying User Account' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Querying User Account'
      $CsUser = Get-TeamsUserVoiceConfig "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      $UserLic = Get-TeamsUserLicense -Identity "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      $IsEVenabled = $CsUser.EnterpriseVoiceEnabled
    }
    catch {
      Write-Error "User '$Identity' not found: $($_.Exception.Message)" -Category ObjectNotFound
      $ErrorLog += $_.Exception.Message
      return $ErrorLog
    }

    # Querying User Licenses
    #TODO Check whether to replace this with Assert-TeamsCallableEntity - Does check license AND to be extended for PhoneSystemStatus too
    try {
      $step++
      Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Querying User License' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Querying User License'
      if ( $CsUser.PhoneSystem ) {
        Write-Verbose -Message "User '$Identity' - PhoneSystem License is assigned - Validating PhoneSystemStatus"
        if ( -not $CsUser.PhoneSystemStatus.Contains('Success')) {
          try {
            Write-Information "TRYING:  User '$Identity' - PhoneSystem License is assigned - ServicePlan PhoneSystem disabled - Trying to activate"
            Set-AzureAdLicenseServicePlan -Identity $CsUser.UserPrincipalName -Enable MCOEV -ErrorAction Stop
            if (-not (Get-TeamsUserLicense -Identity "$Identity").PhoneSystemStatus.Contains('Success')) {
              throw
            }
          }
          catch {
            throw "User '$Identity' - is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status must be 'Success'"
          }
        }

        if ( $CsUser.PhoneSystemStatus.Contains(',')) {
          Write-Warning -Message "User '$Identity' - PhoneSystem License: Multiple assignments found. Please verify License assignment."
          Write-Verbose -Message 'All licenses assigned to the User:' -Verbose
          Write-Output $UserLic.Licenses
        }
      }
      else {
        throw "User '$Identity' - PhoneSystem License is not assigned"
      }
    }
    catch {
      # Unlicensed
      Write-Warning -Message "User '$Identity' - PhoneSystem License is not assigned. User is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status must be 'Success'. Assignment will continue, though be only partially successful."
      Write-Verbose -Message 'License Status:' -Verbose
      $UserLic.Licenses
      $ErrorLog += $_.Exception.Message
      return
    }

    # Enable if not Enabled for EnterpriseVoice
    $step++
    Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Enterprise Voice Enablement' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message 'Enterprise Voice Enablement'
    if ( -not $IsEVenabled) {
      Write-Information "TRYING:  User '$Identity' - Enterprise Voice Status: Not enabled, trying to Enable"
      if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
        $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
      }
    }

    if ( -not $IsEVenabled) {
      Write-Error -Message 'Enterprise Voice Status: Not enabled - Could not enable Object. Please investigate'
      return
    }

    # Calling Plans - Number verification
    if ( $PSCmdlet.ParameterSetName -eq 'CallingPlans' ) {
      # Validating License assignment
      try {
        if ( -not $CallingPlanLicense ) {
          $step++
          Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Testing Calling Plan License' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message 'Parameter CallingPlanLicense not specified. Testing for existing licenses'
          if ( -not $CsUser.LicensesAssigned.Contains('Calling')) {
            throw "User '$Identity' - User is not licensed correctly. Please check License assignment. A Calling Plan License is required"
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

      # Validating Number
      $step++
      Write-Progress -Id 0 -Status 'Verifying Object' -CurrentOperation 'Querying Microsoft Phone Numbers from Tenant' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Querying Microsoft Phone Numbers from Tenant'
      if (-not $global:TeamsFunctionsMSTelephoneNumbers) {
        $global:TeamsFunctionsMSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      }
      $MSNumber = ((Format-StringForUse -InputString "$PhoneNumber" -SpecialChars 'tel:+') -split ';')[0]
      if ($MSNumber -in $global:TeamsFunctionsMSTelephoneNumbers.Id) {
        Write-Verbose -Message "Phone Number '$PhoneNumber' found in the Tenant."
      }
      else {
        $ErrorLogMessage = "Phone Number '$PhoneNumber' is not found in the Tenant. Please provide an available number"
        Write-Error -Message $ErrorLogMessage
        $ErrorLog += $ErrorLogMessage
      }
    }
    #endregion


    #region Apply Voice Config
    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", 'Apply Voice Configuration')) {
      #region Generic Configuration
      # Enable HostedVoicemail
      $step++
      Write-Progress -Id 0 -Status 'Provisioning' -CurrentOperation 'Enabling user for Hosted Voicemail' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Enabling user for Hosted Voicemail'
      if ( $Force -or -not $CsUser.HostedVoicemail) {
        try {
          $CsUser | Set-CsUser -HostedVoicemail $TRUE -ErrorAction Stop
          Write-Information "SUCCESS: User '$Identity' - Enabling user for Hosted Voicemail: OK"
        }
        catch {
          $ErrorLogMessage = "User '$Identity' - Enabling user for Hosted Voicemail: Failed: '$($_.Exception.Message)'"
          Write-Error -Message $ErrorLogMessage
          $ErrorLog += $ErrorLogMessage
        }
      }
      else {
        Write-Verbose -Message "User '$Identity' - Enabling user for Hosted Voicemail: Already enabled" -Verbose
      }

      # Apply $TenantDialPlan if provided
      if ( $TenantDialPlan ) {
        $step++
        Write-Progress -Id 0 -Status 'Provisioning' -CurrentOperation 'Applying Tenant Dial Plan' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message 'Applying Tenant Dial Plan'
        if ( $Force -or $CsUser.TenantDialPlan -ne $TenantDialPlan) {
          try {
            $CsUser | Grant-CsTenantDialPlan -PolicyName $TenantDialPlan -ErrorAction Stop
            Write-Information "SUCCESS: User '$Identity' - Applying Tenant Dial Plan: OK - '$TenantDialPlan'"
          }
          catch {
            $ErrorLogMessage = "User '$Identity' - Applying Tenant Dial Plan: Failed: '$($_.Exception.Message)'"
            Write-Error -Message $ErrorLogMessage
            $ErrorLog += $ErrorLogMessage
          }
        }
        else {
          Write-Verbose -Message "User '$Identity' - Applying Tenant Dial Plan: Already assigned" -Verbose
        }
      }
      else {
        Write-Verbose -Message "User '$Identity' - Applying Tenant Dial Plan: Not provided"
      }
      #endregion

      #region Specific Configuration
      switch ($PSCmdlet.ParameterSetName) {
        'DirectRouting' {
          Write-Verbose -Message '[PROCESS] DirectRouting'
          # Apply $OnlineVoiceRoutingPolicy
          if ( $OnlineVoiceRoutingPolicy ) {
            $step++
            Write-Progress -Id 0 -Status 'Provisioning for Direct Routing' -CurrentOperation 'Applying Online Voice Routing Policy' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
            Write-Verbose -Message 'Applying Online Voice Routing Policy'
            if ( $Force -or -not $CsUser.OnlineVoiceRoutingPolicy ) {
              try {
                $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
                Write-Information "SUCCESS: User '$Identity' - Applying Online Voice Routing Policy: OK - '$OnlineVoiceRoutingPolicy'"
              }
              catch {
                $ErrorLogMessage = "User '$Identity' - Applying Online Voice Routing Policy: Failed: '$($_.Exception.Message)'"
                Write-Error -Message $ErrorLogMessage
                $ErrorLog += $ErrorLogMessage
              }
            }
            else {
              Write-Verbose -Message "User '$Identity' - Applying Online Voice Routing Policy: Already assigned" -Verbose
            }
          }
          else {
            if ( $CsUser.OnlineVoiceRoutingPolicy ) {
              Write-Information "CURRENT:  User '$Identity' - Online Voice Routing Policy '$($CsUser.OnlineVoiceRoutingPolicy)' assigned currently"
            }
            else {
              Write-Warning -Message "User '$Identity' - Online Voice Routing Policy not assigned. User will be able to receive inbound calls, but not place them!'"
            }
          }

          # Apply or Remove $PhoneNumber as OnPremLineUri
          $step++
          Write-Progress -Id 0 -Status 'Provisioning for Direct Routing' -CurrentOperation 'Applying Phone Number' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message 'Applying Phone Number'
          if ( -not [String]::IsNullOrEmpty($PhoneNumber) ) {
            If ($PhoneNumber -notmatch '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{7,15}))?((;( |-)?ext=[0-9]{3,8}))?$') {
              Write-Error -Message 'PhoneNumber is not in an acceptable format. Multiple formats are expected, but preferred is E.164, with a minimum of 8 digits. Extensions will be stripped' -Category InvalidFormat
              return
            }
            else {
              $Number = Format-StringForUse -InputString $PhoneNumber -As LineURI
              if ( $Force -or $CsUser.OnPremLineURI -ne $Number) {
                try {
                  $CsUser | Set-CsUser -OnPremLineUri $Number -ErrorAction Stop
                  Write-Information "SUCCESS: User '$Identity' - Applying Phone Number: OK - '$Number'"
                }
                catch {
                  $ErrorLogMessage = "User '$Identity' - Applying Phone Number: Failed: '$($_.Exception.Message)'"
                  Write-Error -Message $ErrorLogMessage
                  $ErrorLog += $ErrorLogMessage
                }
              }
              else {
                Write-Verbose -Message "User '$Identity' - Applying Phone Number: Already assigned" -Verbose
              }
            }
          }
          else {
            Write-Warning -Message "User '$Identity' - PhoneNumber is empty and will be removed. The User will not be able to use PhoneSystem!"
            $CsUser | Set-CsUser -OnPremLineUri $null
            Write-Information "SUCCESS: User '$Identity' - Removing Phone Number: OK"
          }
        }

        'CallingPlans' {
          Write-Verbose -Message '[PROCESS] CallingPlans'
          # Apply $CallingPlanLicense
          if ($CallingPlanLicense) {
            try {
              $step++
              Write-Progress -Id 0 -Status 'Provisioning for Calling Plans' -CurrentOperation 'Applying CallingPlan License' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
              Write-Verbose -Message "User '$Identity' - Applying CallingPlan License '$CallingPlanLicense'"
              $null = Set-TeamsUserLicense -Identity $Identity -Add $CallingPlanLicense -ErrorAction Stop
            }
            catch {
              $ErrorLogMessage = "User '$Identity' - Applying CallingPlan License '$CallingPlanLicense' failed: '$($_.Exception.Message)'"
              Write-Error -Message $ErrorLogMessage
              $ErrorLog += $ErrorLogMessage
            }
            #CHECK Waiting period after applying a Calling Plan license? Will Phone Number assignment succeed right away?
            Write-Information 'No waiting period has been implemented yet after applying a license. Applying a Phone Number may fail. If so, please run command again after a few minutes.'
          }

          # Apply or Remove $PhoneNumber as TelephoneNumber
          $step++
          Write-Progress -Id 0 -Status 'Provisioning for Calling Plans' -CurrentOperation 'Applying Phone Number' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message 'Applying Phone Number'
          if ( -not [String]::IsNullOrEmpty($PhoneNumber) ) {
            If ($PhoneNumber -notmatch '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{7,15}))?((;( |-)?ext=[0-9]{3,8}))?$') {
              Write-Error -Message 'PhoneNumber is not in an acceptable format. Multiple formats are expected, but preferred is E.164, with a minimum of 8 digits. Extensions will be stripped' -Category InvalidFormat
              return
            }
            else {
              $Number = Format-StringForUse -InputString $PhoneNumber -As E164
              if ( $Force -or $CsUser.TelephoneNumber -ne $Number) {
                try {
                  # Pipe should work but was not yet tested.
                  #$CsUser | Set-CsOnlineVoiceUser -TelephoneNumber $PhoneNumber -ErrorAction Stop
                  $null = Set-CsOnlineVoiceUser -Identity $($CsUser.ObjectId) -TelephoneNumber $PhoneNumber -ErrorAction Stop
                }
                catch {
                  $ErrorLogMessage = "User '$Identity' - Applying Phone Number failed: '$($_.Exception.Message)'"
                  Write-Error -Message $ErrorLogMessage
                  $ErrorLog += $ErrorLogMessage
                }
              }
              else {
                Write-Verbose -Message "User '$Identity' - Applying Phone Number: Already assigned" -Verbose
              }
            }
          }
          else {
            Write-Warning -Message "User '$Identity' - PhoneNumber is empty and will be removed. The User will not be able to use PhoneSystem!"
            $CsUser | Set-CsUser -OnPremLineUri $null
            Write-Verbose -Message "User '$Identity' - Removing Phone Number: OK" -Verbose
          }
        }
      }
      #endregion

    }
    #endregion


    #region Log & Output
    # Write $ErrorLog
    if ( $WriteErrorLog ) {
      $Path = 'C:\Temp'
      $Filename = "$($MyInvocation.MyCommand) - $Identity - ERROR.log"
      $LogPath = "$Path\$Filename"
      $step++
      Write-Progress -Id 0 -Status 'Output' -CurrentOperation 'Writing ErrorLog' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Identity - Errors encountered are written to '$Path'"

      # Write log entry to $Path
      $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K') | Out-File -FilePath $LogPath -Append
      $errorLog | Out-File -FilePath $LogPath -Append

    }
    else {
      Write-Verbose -Message "$Identity - No errors encountered! No log file written."
    }


    # Output
    if ( $PassThru ) {
      # Re-Query Object
      $step++
      Write-Progress -Id 0 -Status 'Output' -CurrentOperation 'Waiting for Office 365 to write the Object' -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message 'Waiting 3-5s for Office 365 to write changes to User Object (Policies might not show up yet)'
      Start-Sleep -Seconds 3
      $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $Identity
      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Start-Sleep -Seconds 2
        $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $Identity
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
