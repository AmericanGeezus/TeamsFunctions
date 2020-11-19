# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   RC




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
	.PARAMETER Silent
    Suppresses Output object for verification and On-Screen Errors. Useful for Bulk-Application
    If errors are encountered, these will be logged in a file to C:\Temp
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
    Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER" -Silent
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided.
    If Errors are encountered, they are written to C:\Temp
  .EXAMPLE
    Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER" -WriteErrorLog
    Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided.
    If Errors are encountered, they are written to C:\Temp as well as on screen
  .INPUTS
    System.String
  .OUTPUTS
    System.Void (with Switch Silent and without Switch WriteErrorLog)
    System.File (with Switch WriteErrorLog)
    System.Object (without Switch Silent)
	.NOTES
    ParameterSet 'DirectRouting' will provision a User to use DirectRouting. Enables User for Enterprise Voice,
    assigns a Number and an Online Voice Routing Policy and optionally also a Tenant Dial Plan. This is the default.
    ParameterSet 'CallingPlans' will provision a User to use Microsoft CallingPlans.
    Enables User for Enterprise Voice and assigns a Microsoft Number (must be found in the Tenant!)
    Optionally can also assign a Calling Plan license prior.
	.FUNCTIONALITY
		TeamsUserVoiceConfig
  .LINK
    Get-TeamsUserVoiceConfig
    Get-TeamsUserVoiceConfig
    Find-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "DirectRouting", ConfirmImpact = 'Medium')]
  [Alias('Set-TeamsUVC')]
  [OutputType([System.Object])]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "UserPrincipalName of the User")]
    [string]$Identity,

    [Parameter(ParameterSetName = "DirectRouting", HelpMessage = "Enables an Object for Direct Routing")]
    [switch]$DirectRouting,

    [Parameter(ParameterSetName = "DirectRouting", Mandatory, HelpMessage = "Name of the Online Voice Routing Policy")]
    [Alias('OVP')]
    [string]$OnlineVoiceRoutingPolicy,

    [Parameter(HelpMessage = "Name of the Tenant Dial Plan")]
    [Alias('TDP')]
    [string]$TenantDialPlan,

    [Parameter(Mandatory, HelpMessage = "E.164 Number to assign to the Object")]
    [ValidateScript( {
        If ($_ -match "^\+[0-9]{10,15}$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. Must start with a + and 10 to 15 digits long" -ForegroundColor Red
          $false
        }
      })]
    [Alias('Number', 'LineURI')]
    [string]$PhoneNumber,

    [Parameter(ParameterSetName = "CallingPlans", Mandatory, HelpMessage = "Enables an Object for Microsoft Calling Plans")]
    [switch]$CallingPlan,

    [Parameter(ParameterSetName = "CallingPlans", HelpMessage = "Calling Plan License to assign to the Object")]
    [ValidateScript( {
        #CHECK Application of this. Replicate for other instances where $TeamsLicenses or $TeamsServicePlans are used!
        $CallingPlanLicenseValues = ($TeamsLicenses | Where-Object LicenseType -EQ "CallingPlan").ParameterName.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($_ -in $CallingPlanLicenseValues) {
          $True
        }
        else {
          Write-Host "Parameter 'CallingPlanLicense' must be of the set: $CallingPlanLicenseValues"
        }
      })]
    [string[]]$CallingPlanLicense,

    [Parameter(HelpMessage = "Suppresses confirmation prompt unless -Confirm is used explicitly")]
    [switch]$Force,

    [Parameter(HelpMessage = "Suppresses object output")]
    [switch]$Silent,

    [Parameter(HelpMessage = "Writes a Log File to C:\Temp")]
    [switch]$WriteErrorLog
  ) #param

  begin {
    Show-FunctionStatus -Level RC
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

    # Initialising $ErrorLog
    [System.Collections.ArrayList]$ErrorLog = @()

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = switch ($PsCmdlet.ParameterSetName) {
      "DirectRouting" { 8 }
      "CallingPlans" { if ($CallingPlanLicense) { 10 } else { 9 } }
    }
    if ($TenantDialPlan) { $sMax++ }
    if ($WriteErrorLog) { $sMax++ }
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "[PROCESS] Processing '$Identity'"
    #region Information Gathering and Verification
    # Excluding Resource Accounts
    Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Querying Account Type is not a Resource Account" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "Querying Account Type"
    $ResourceAccounts = (Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue).UserPrincipalName
    if ( $Identity -in $ResourceAccounts) {
      Write-Error -Message "Resource Account specified! Please use Set-TeamsResourceAccount to provision Resource Accounts" -Category InvalidType -RecommendedAction "Please use Set-TeamsResourceAccount to provision Resource Accounts"
      return
    }

    # Querying Identity
    try {
      $step++
      Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Querying User Account" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Querying User Account"
      $CsUser = Get-TeamsUserVoiceConfig "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      $IsEVenabled = $CsUser.EnterpriseVoiceEnabled
    }
    catch {
      Write-Error "User '$Identity' not queryied: $($_.Exception.Message)" -Category ObjectNotFound
      $ErrorLog += $_.Exception.Message
      return $ErrorLog
    }

    # Querying User Licenses
    try {
      $step++
      Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Querying User License" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Querying User License"
      if ( $CsUser.PhoneSystemStatus.Count -gt 1 ) {
        Write-Verbose -Message "License Status:" -Verbose
        $CsUser.Licenses
        $CsUser.ServicePlans
      }

      if ( "Success" -notin $CsUser.PhoneSystemStatus ) {
        throw "User is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status  must be 'Success'"
      }

    }
    catch {
      # Unlicensed
      Write-Warning -Message "User is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status  must be 'Success'. Assignment will continue, though be only partially successful. "
      Write-Verbose -Message "License Status:" -Verbose
      $CsUser.Licenses
      $ErrorLog += $_.Exception.Message
      return
    }

    # Enable if not Enabled for EnterpriseVoice
    $step++
    Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Enterprise Voice Enablement" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "Enterprise Voice Enablement"
    if ( -not $IsEVenabled) {
      #Write-Verbose -Message "Enterprise Voice Status: Not enabled, trying to Enable user." -Verbose
      if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
        $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
      }
    }

    if ( -not $IsEVenabled) {
      Write-Error -Message "Enterprise Voice Status: Not enabled - Could not enable Object. Please investigate"
      return
    }

    # Calling Plans - Number verification
    if ( $PSCmdlet.ParameterSetName -eq "CallingPlans" ) {
      # Validating License assignment
      try {
        if ( -not $CallingPlanLicense ) {
          $step++
          Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Testing Calling Plan License" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "Parameter CallingPlanLicense not specified. Testing for existing licenses"
          if ( -not $CsUser.LicensesAssigned.Contains('Calling')) {
            throw "User is not licensed correctly. Please check License assignment. A Calling Plan License is required"
          }
        }
      }
      catch {
        # Unlicensed
        $ErrorLogMessage = "User is not licensed (CallingPlan). Please assign a Calling Plan license"
        Write-Error -Message $ErrorLogMessage -Category ResourceUnavailable -RecommendedAction "Please assign a Calling Plan license" -ErrorAction Stop
        $ErrorLog += $ErrorLogMessage
        $ErrorLog += $_.Exception.Message
        return $ErrorLog
      }

      # Validating Number
      $step++
      Write-Progress -Id 0 -Status "Verifying Object" -CurrentOperation "Querying Microsoft Phone Numbers from Tenant" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Querying Microsoft Phone Numbers from Tenant"
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
      if ( $PhoneNumberIsMSNumber ) {
        Write-Verbose -Message "Phone Number '$PhoneNumber' found in the Tenant."
      }
      else {
        $ErrorLogMessage = "Phone Number '$PhoneNumber' is not found in the Tenant. Please provide an available number"
        if ( -not $Silent ) {
          Write-Error -Message $ErrorLogMessage
        }
        $ErrorLog += $ErrorLogMessage
      }
    }
    #endregion


    #region Apply Voice Config
    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Apply Voice Configuration")) {
      #region Generic Configuration
      # Enable HostedVoicemail
      $step++
      Write-Progress -Id 0 -Status "Provisioning" -CurrentOperation "Enabling user for Hosted Voicemail" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Enabling user for Hosted Voicemail"
      if ( $Force -or -not $CsUser.HostedVoicemail) {
        try {
          $CsUser | Set-CsUser -HostedVoicemail $TRUE -ErrorAction Stop
          Write-Verbose -Message "Enabling user for Hosted Voicemail: OK - '$TenantDialPlan'" -Verbose
        }
        catch {
          $ErrorLogMessage = "Enabling user for Hosted Voicemail: Failed: '$($_.Exception.Message)'"
          if ( -not $Silent ) {
            Write-Error -Message $ErrorLogMessage
          }
          $ErrorLog += $ErrorLogMessage
        }
      }
      else {
        Write-Verbose -Message "Enabling user for Hosted Voicemail: Already enabled" -Verbose
      }

      # Apply $TenantDialPlan if provided
      if ( $TenantDialPlan ) {
        $step++
        Write-Progress -Id 0 -Status "Provisioning" -CurrentOperation "Applying Tenant Dial Plan" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "Applying Tenant Dial Plan"
        if ( $Force -or $CsUser.TenantDialPlan -ne $TenantDialPlan) {
          try {
            $CsUser | Grant-CsTenantDialPlan -PolicyName $TenantDialPlan -ErrorAction Stop
            Write-Verbose -Message "Applying Tenant Dial Plan: OK - '$TenantDialPlan'" -Verbose
          }
          catch {
            $ErrorLogMessage = "Applying Tenant Dial Plan: Failed: '$($_.Exception.Message)'"
            if ( -not $Silent ) {
              Write-Error -Message $ErrorLogMessage
            }
            $ErrorLog += $ErrorLogMessage
          }
        }
        else {
          Write-Verbose -Message "Applying Tenant Dial Plan: Already assigned" -Verbose
        }
      }
      else {
        Write-Verbose -Message "Applying Tenant Dial Plan: Not provided"
      }
      #endregion

      #region Specific Configuration
      switch ($PSCmdlet.ParameterSetName) {
        "DirectRouting" {
          Write-Verbose -Message "[PROCESS] DirectRouting"
          # Apply $OnlineVoiceRoutingPolicy
          $step++
          Write-Progress -Id 0 -Status "Provisioning for Direct Routing" -CurrentOperation "Applying Online Voice Routing Policy" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "Applying Online Voice Routing Policy"
          if ( $Force -or $CsUser.OnlineVoiceRoutingPolicy -ne $OnlineVoiceRoutingPolicy) {
            try {
              $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
              Write-Verbose -Message "Applying Online Voice Routing Policy: OK - '$OnlineVoiceRoutingPolicy'" -Verbose
            }
            catch {
              $ErrorLogMessage = "Applying Online Voice Routing Policy: Failed: '$($_.Exception.Message)'"
              if ( -not $Silent ) {
                Write-Error -Message $ErrorLogMessage
              }
              $ErrorLog += $ErrorLogMessage
            }
          }
          else {
            Write-Verbose -Message "Applying Online Voice Routing Policy: Already assigned" -Verbose
          }

          # Apply $PhoneNumber as OnPremLineUri
          $Number = Format-StringForUse -InputString $PhoneNumber -As LineURI
          $step++
          Write-Progress -Id 0 -Status "Provisioning for Direct Routing" -CurrentOperation "Applying Phone Number" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "Applying Phone Number as '$Number'"
          if ( $Force -or $CsUser.OnPremLineURI -ne $Number) {
            try {
              $CsUser | Set-CsUser -OnPremLineUri $Number -ErrorAction Stop
              Write-Verbose -Message "Applying Phone Number: OK - '$Number'" -Verbose
            }
            catch {
              $ErrorLogMessage = "Applying Phone Number: Failed: '$($_.Exception.Message)'"
              if ( -not $Silent ) {
                Write-Error -Message $ErrorLogMessage
              }
              $ErrorLog += $ErrorLogMessage
            }
          }
          else {
            Write-Verbose -Message "Applying Phone Number: Already assigned" -Verbose
          }
        }

        "CallingPlans" {
          Write-Verbose -Message "[PROCESS] CallingPlans"
          # Apply $CallingPlanLicense
          if ($CallingPlanLicense) {
            try {
              $step++
              Write-Progress -Id 0 -Status "Provisioning for Calling Plans" -CurrentOperation "Applying CallingPlan License" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
              Write-Verbose -Message "Applying CallingPlan License '$CallingPlanLicense'"
              $null = Set-TeamsUserLicense -Identity $Identity -Add $CallingPlanLicense -ErrorAction Stop
            }
            catch {
              $ErrorLogMessage = "Applying CallingPlan License '$CallingPlanLicense' failed: '$($_.Exception.Message)'"
              if ( -not $Silent ) {
                Write-Error -Message $ErrorLogMessage
              }
              $ErrorLog += $ErrorLogMessage
            }

            #CHECK Waiting period after applying a Calling Plan license? Will Phone Number assignment succeed right away?
            Write-Verbose -Message "No waiting period has been implemented yet after applying a license. Applying a Phone Number may fail. If so, please run command again." -Verbose
          }

          # Apply $PhoneNumber as TelephoneNumber
          $step++
          Write-Progress -Id 0 -Status "Provisioning for Calling Plans" -CurrentOperation "Applying Phone Number" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "Applying Phone Number"
          if ( $Force -or $CsUser.TelephoneNumber -ne $PhoneNumber) {
            try {
              # Pipe should work but was not yet tested.
              #$CsUser | Set-CsOnlineVoiceUser -TelephoneNumber $PhoneNumber -ErrorAction Stop
              $null = Set-CsOnlineVoiceUser -Identity $($CsUser.ObjectId) -TelephoneNumber $PhoneNumber -ErrorAction Stop
            }
            catch {
              $ErrorLogMessage = "Applying Phone Number failed: '$($_.Exception.Message)'"
              if ( -not $Silent ) {
                Write-Error -Message $ErrorLogMessage
              }
              $ErrorLog += $ErrorLogMessage
            }
          }
          else {
            Write-Verbose -Message "Applying Phone Number: Already assigned" -Verbose
          }
        }
      }
      #endregion

    }
    #endregion


    #region Log & Output
    # Write $ErrorLog
    if ( $errorLog -and ($Silent -or $WriteErrorLog) ) {
      $Path = "C:\Temp"
      $Filename = "$($MyInvocation.MyCommand) - $Identity - ERROR.log"
      $LogPath = "$Path\$Filename"
      $step++
      Write-Progress -Id 0 -Status "Output" -CurrentOperation "Writing ErrorLog" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Errors encountered are written to '$Path'"

      # Write log entry to $Path
      $(Get-Date -Format "yyyy-MM-dd HH:mm:ss K") | Out-File -FilePath $LogPath -Append
      $errorLog | Out-File -FilePath $LogPath -Append

    }
    else {
      Write-Verbose -Message "No errors encountered! No log file written."
    }


    # Output
    if ( $Silent ) {
      return
    }
    else {
      # Re-Query Object
      $step++
      Write-Progress -Id 0 -Status "Output" -CurrentOperation "Waiting for Office 365 to write the Object" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Waiting 3-5s for Office 365 to write changes to User Object (Policies might not show up yet)" -Verbose
      Start-Sleep -Seconds 3
      $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $Identity
      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Start-Sleep -Seconds 2
        $UserObjectPost = Get-TeamsUserVoiceConfig -Identity $Identity
      }

      if ( $PsCmdlet.ParameterSetName -eq 'DirectRouting' -and $null -eq $UserObjectPost.OnlineVoiceRoutingPolicy) {
        Write-Warning -Message "Applied Policies take some time to show up on the object. Please verify again with Get-TeamsUserVoiceConfig"
      }
      Write-Progress -Id 0 -Status "Provisioning" -Activity $MyInvocation.MyCommand -Completed

      return $UserObjectPost
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceConfig
