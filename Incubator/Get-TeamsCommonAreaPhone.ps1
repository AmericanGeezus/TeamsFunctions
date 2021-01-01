# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   ALPHA

#TODO Build


function Get-TeamsCommonAreaPhone {
  <#
	.SYNOPSIS
		Returns Common Area Phones from AzureAD
	.DESCRIPTION
    Returns one or more AzureAdUser Accounts that are Common Area Phones
    Accounts returned are strictly limited to having to have the Common Area Phone License assigned.
  .PARAMETER Identity
    Default and positional. One or more UserPrincipalNames to be queried
  .PARAMETER DisplayName
		Optional. Search parameter.
		Use Find-TeamsUserVoiceConfig for more search options
  .PARAMETER PhoneNumber
		Optional. Returns all Common Area Phones with a specific string in the PhoneNumber
	.EXAMPLE
		Get-TeamsCommonAreaPhone
		Returns all Common Area Phones.
		NOTE: Depending on size of the Tenant, this might take a while.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -Identity MyCAP@TenantName.onmicrosoft.com
		Returns the Common Area Phone with the Identity specified, if found.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -DisplayName "Lobby"
		Returns all Common Area Phones with "Lobby" as part of their Display Name.
	.EXAMPLE
		Get-TeamsCommonAreaPhone -PhoneNumber +1555123456
		Returns the Resource Account with the Phone Number specified, if found.
  .INPUTS
    System.String
  .OUTPUTS
    System.Object
	.NOTES
    Without input, returns all UserPrincipalNames of all found Common Area Phones (by License assigned)
    Displays similar output as Get-TeamsUserVoiceConfig, but more tailored to Common Area Phones
	.FUNCTIONALITY
		TeamsUserVoiceConfig
  .LINK
    Get-TeamsCommonAreaPhone
    New-TeamsCommonAreaPhone
    Set-TeamsCommonAreaPhone
    Remove-TeamsCommonAreaPhone
    Find-TeamsUserVoiceConfig
    Get-TeamsTenantVoiceConfig
    Get-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('Get-TeamsCAP')]
  [OutputType([System.Object])]
  param(
    [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "UserPrincipalName of the User")]
    [string]$Identity,

    [Parameter(ParameterSetName = "DisplayName", ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Searches for AzureAD Object with this Name")]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = "Number", ValueFromPipelineByPropertyName, HelpMessage = "Telephone Number of the Object")]
    [ValidateScript( {
        If ($_ -match "^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{4,15}))?((;( |-)?ext=[0-9]{3,8}))?$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. E.164 format expected, min 4 digits, but multiple formats accepted." -ForegroundColor Red
          $false
        }
      })]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  ) #param

  begin {
    Show-FunctionStatus -Level ALPHA
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
    [int]$sMax = 4

    <#
    [int]$sMax = switch ($PsCmdlet.ParameterSetName) {
      "DirectRouting" { 8 }
      "CallingPlans" { if ( -not $CallingPlanLicense ) { 10 } else { 9 } }
    }
    if ( $TenantDialPlan ) { $sMax++ }
    if ( $WriteErrorLog ) { $sMax++ }
    if ( $PassThru ) { $sMax++ }
    #>
  } #begin

  process {
    return "This function is not yet built, sorry!"

    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"



    <# Design
    Wrap for Get-AzureAdUser with display like Get-TeamsUserVoiceConfig and CAP specific policies.
    Analog to Get-TeamsResourceAccount, but with CAP License
    Input
    0 Identities (Lookup with Foreach)
    1 DisplayName (Search)
    2 PhoneNumber (Search)

    Filter
    Common Area Phone License, IPPHone Policy set?

    ValueAdd
    Warning if CAP license is not assigned (and found via IP Phone Policy - If Used with NEW command - Departmentname (like RA?))
    Pipelining to SET-TeamsCommonAreaPhone for provisioning (Policy? could also be simply be piped to Grant-CsTeamsIpPhonePolicy...) or
    Pipelining to Set-TeamsUserVoiceConfig?
    Pipelining to Set-TeamsUserLicense? (Probably not as these are already Licensed with CAP)
    Output: Like Get-TeamsUserVoiceConfig with added IPPhone and other relevant policies depending on
    Add Nested signinmode? or Nest the whole IpPHonePolicy like with AAs?
    http://blog.schertz.name/2019/11/managing-microsoft-teams-phone-policies/
    Also Call Park Policy, Calling Policy (CsTeamsIPPhonePolicy, CsTeamsCallingPolicy, CsTeamsCallParkPolicy)




New-AzureAdUser -UserPrincipalName $UserPrincipalName001 -MailNickName $MailNickName001 -DisplayName "$DisplayName001" -UsageLocation US -AccountEnabled $false -PasswordProfile $PasswordProfile;
# Wait 10-20s
Set-TeamsUserLicense -Identity $UserPrincipalName001 -Add CommonAreaPhone;
# Wait 5-10mins
Set-TeamsUserVoiceConfig -DirectRouting -Identity $UserPrincipalName001 -PhoneNumber "tel:+12038163105;ext=3105" -OVP "OVP-AMER-GSIP" -TDP "DP-US-DDI" -PassThru


    #>

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
      Write-Error "User '$Identity' not found: $($_.Exception.Message)" -Category ObjectNotFound
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
      if (-not $global:MSTelephoneNumbers) {
        $global:MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      }
      $MSNumber = Format-StringRemoveSpecialCharacter $PhoneNumber | Format-StringForUse -SpecialChars "tel"
      if ($MSNumber -in $global:MSTelephoneNumbers.Id) {
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
    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Apply Voice Configuration")) {
      #region Generic Configuration
      # Enable HostedVoicemail
      $step++
      Write-Progress -Id 0 -Status "Provisioning" -CurrentOperation "Enabling user for Hosted Voicemail" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "Enabling user for Hosted Voicemail"
      if ( $Force -or -not $CsUser.HostedVoicemail) {
        try {
          $CsUser | Set-CsUser -HostedVoicemail $TRUE -ErrorAction Stop
          Write-Verbose -Message "Enabling user for Hosted Voicemail: OK" -Verbose
        }
        catch {
          $ErrorLogMessage = "Enabling user for Hosted Voicemail: Failed: '$($_.Exception.Message)'"
          Write-Error -Message $ErrorLogMessage
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
            Write-Error -Message $ErrorLogMessage
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
              Write-Error -Message $ErrorLogMessage
              $ErrorLog += $ErrorLogMessage
            }
          }
          else {
            Write-Verbose -Message "Applying Online Voice Routing Policy: Already assigned" -Verbose
          }

          # Apply $PhoneNumber as OnPremLineUri
          $Number = Format-StringForUse -InputString $PhoneNumber -As LineURI #CHECK LineURI or E164 probably both/either!
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
              Write-Error -Message $ErrorLogMessage
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
              Write-Error -Message $ErrorLogMessage
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
              Write-Error -Message $ErrorLogMessage
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
    if ( $WriteErrorLog ) {
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
    if ( $PassThru ) {
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
    else {
      Write-Progress -Id 0 -Status "Provisioning" -Activity $MyInvocation.MyCommand -Completed
      return
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsCommonAreaPhone
