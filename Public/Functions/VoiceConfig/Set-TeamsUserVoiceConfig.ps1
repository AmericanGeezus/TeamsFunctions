# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardt
# Updated:  07-NOV-2020
# Status:   RC


#TODO Add Status bar detailing the progress? Max is depending on Scope (DR: x steps, CP: y steps, Add for TDP and CallingPlanLicense)

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
    Suppresses confirmation inputs except when $Confirm is explicitly specified
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
    [Parameter(Mandatory = $true, HelpMessage = "UserPrincipalName of the User")]
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #TODO Capture running this command against a Resource Account and stop there? Is a RA EV-enabled?
    # Are RAs automatically EV-Enabled when querying?
    Write-Debug -Message "This script is geared towards User Objects, not Resource Accounts. Please use Set-TeamsResourceAccount for them."

    Write-Verbose -Message "[PROCESS] Processing '$Identity'"
    #region Information Gathering and Verification
    # Querying Identity
    try {
      Write-Verbose -Message "User '$Identity' - Querying User Account"
      $CsUser = Get-CsOnlineUser "$Identity" -WarningAction SilentlyContinue -ErrorAction Stop
      $IsEVenabled = $CsUser.EnterpriseVoiceEnabled
    }
    catch {
      Write-Error "User '$Identity' not queryied: $($_.Exception.Message)" -Category ObjectNotFound
      $ErrorLog += $_.Exception.Message
      return $ErrorLog
    }

    # Querying User Licenses
    try {
      Write-Verbose -Message "User '$Identity' - Querying User License"
      $CsUserLicense = Get-TeamsUserLicense $Identity
      #TEST Get-TeamsUserLicense was only recently expanded to include the PhoneSystemStatus. This needs testing
      if ( $CsUserLicense.PhoneSystemStatus.Count -gt 1 ) {
        Write-Verbose -Message "License Status:" -Verbose
        $CsUserLicense.Licenses
        $CsUserLicense.ServicePlans
      }

      if ( "Success" -notin $CsUserLicense.PhoneSystemStatus ) {
        throw "User '$Identity' is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status  must be 'Success'"
      }
      <# Alternative with Get-TeamsUserVoiceConfig
      if ( -not (Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV) ) {
        throw "User '$Identity' is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status  must be 'Success'"
      }
      #>
    }
    catch {
      # Unlicensed
      Write-Warning -Message "User '$Identity' is not licensed correctly. Please check License assignment. PhoneSystem Service Plan status  must be 'Success'. Assignment will continue, though be only partially successful. "
      Write-Verbose -Message "License Status:" -Verbose
      $CsUserLicense.Licenses
      #Write-Error -Message "User '$Identity' is not licensed (PhoneSystem). Please assign a license" -Category ResourceUnavailable -RecommendedAction "Please assign a license that contains Phone System" -ErrorAction Stop
      $ErrorLog += $_.Exception.Message
      #return $ErrorLog
    }

    # Enable if not Enabled for EnterpriseVoice
    if ( -not $IsEVenabled) {
      #Write-Verbose -Message "User '$Identity' Enterprise Voice Status: Not enabled, trying to Enable user." -Verbose
      if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Set-CsUser -EnterpriseVoiceEnabled $TRUE")) {
        $IsEVenabled = Enable-TeamsUserForEnterpriseVoice -Identity $Identity -Force
      }
    }

    if ( -not $IsEVenabled) {
      Write-Error -Message "User '$Identity' Enterprise Voice Status: Not enabled"
      return
    }

    # Calling Plans - Number verification
    if ( $PSCmdlet.ParameterSetName -eq "CallingPlans" ) {
      # Validating License assignment
      try {
        if ( -not $CallingPlanLicense ) {
          Write-Verbose -Message "User '$Identity' Parameter CallingPlanLicense not specified. Testing for existing licenses"
          if ( $null -eq $CsUserLicense.CallingPlanDomestic120 -and $null -eq $CsUserLicense.CallingPlanDomestic -and $null -eq $CsUserLicense.CallingPlanInternational ) {
            throw "User '$Identity' is not licensed correctly. Please check License assignment. A Calling Plan License is required"
          }
        }
      }
      catch {
        # Unlicensed
        Write-Error -Message "User '$Identity' is not licensed (CallingPlan). Please assign a Calling Plan license" -Category ResourceUnavailable -RecommendedAction "Please assign a Calling Plan license" -ErrorAction Stop
        $ErrorLog += $_.Exception.Message
        return $ErrorLog
      }

      # Validating Number
      Write-Verbose -Message "Querying Microsoft Phone Numbers"
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
      if ( $PhoneNumberIsMSNumber ) {
        Write-Verbose -Message "Phone Number '$PhoneNumber' found in the Tenant."
      }
      else {
        if ( -not $Silent ) {
          Write-Error -Message "Phone Number '$PhoneNumber' is not found in the Tenant. Please provide an available number" -Category NotImplemented -RecommendedAction "Please provide an available number"
        }
        $ErrorLog += $_.Exception.Message
      }
    }
    #endregion


    #region Apply Voice Config
    if ($Force -or $PSCmdlet.ShouldProcess("$Identity", "Apply Voice Configuration")) {
      #region Generic Configuration
      # Enable HostedVoicemail
      try {
        Write-Verbose -Message "User '$Identity' Enabling user for Hosted Voicemail"
        $CsUser | Set-CsUser -HostedVoicemail $TRUE -ErrorAction Stop
      }
      catch {
        if ( -not $Silent ) {
          Write-Error -Message "User '$Identity' Enabling user for Hosted Voicemail failed: '$($_.Exception.Message)'"
        }
        $ErrorLog += $_.Exception.Message
      }

      # Apply $TenantDialPlan if provided
      if ( $TenantDialPlan ) {
        try {
          Write-Verbose -Message "User '$Identity' Applying Tenant Dial Plan"
          $CsUser | Grant-CsTenantDialPlan -PolicyName $TenantDialPlan -ErrorAction Stop
        }
        catch {
          if ( -not $Silent ) {
            Write-Error -Message "User '$Identity' Applying Tenant Dial Plan failed: '$($_.Exception.Message)'"
          }
          $ErrorLog += $_.Exception.Message
        }

      }
      else {
        Write-Verbose -Message "User '$Identity' Applying Tenant Dial Plan: Not provided"
      }
      #endregion

      #region Specific Configuration
      switch ($PSCmdlet.ParameterSetName) {
        "DirectRouting" {
          Write-Verbose -Message "[PROCESS] DirectRouting"
          # Apply $OnlineVoiceRoutingPolicy
          try {
            Write-Verbose -Message "User '$Identity' Applying Online Voice Routing Policy"
            $CsUser | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $OnlineVoiceRoutingPolicy -ErrorAction Stop
          }
          catch {
            if ( -not $Silent ) {
              Write-Error -Message "User '$Identity' Applying Online Voice Routing Policy failed: '$($_.Exception.Message)'"
            }
            $ErrorLog += $_.Exception.Message
          }

          # Apply $PhoneNumber as OnPremLineUri
          try {
            Write-Verbose -Message "User '$Identity' Applying Phone Number"
            $CsUser | Set-CsUser -OnPremLineUri $PhoneNumber -ErrorAction Stop
          }
          catch {
            if ( -not $Silent ) {
              Write-Error -Message "User '$Identity' Applying Phone Number failed: '$($_.Exception.Message)'"
            }
            $ErrorLog += $_.Exception.Message
          }
        }

        "CallingPlans" {
          Write-Verbose -Message "[PROCESS] CallingPlans"
          # Apply $CallingPlanLicense
          try {
            Write-Verbose -Message "User '$Identity' Applying CallingPlan License '$CallingPlanLicense'"
            $null = Set-TeamsUserLicense -Identity $Identity -Add $CallingPlanLicense -ErrorAction Stop
          }
          catch {
            if ( -not $Silent ) {
              Write-Error -Message "User '$Identity' Applying CallingPlan License '$CallingPlanLicense' failed: '$($_.Exception.Message)'"
            }
            $ErrorLog += $_.Exception.Message
          }

          #CHECK Waiting period after applying a Calling Plan license? Will Phone Number assignment succeed right away?
          Write-Debug -Message "No waiting period has been implemented yet after applying a license. Applying a Phone Number may fail"

          # Apply $PhoneNumber as TelephoneNumber
          try {
            Write-Verbose -Message "User '$Identity' Applying Phone Number"
            # Pipe should work but was not yet tested.
            #$CsUser | Set-CsOnlineVoiceUser -TelephoneNumber $PhoneNumber -ErrorAction Stop
            $null = Set-CsOnlineVoiceUser -Identity $($CsUser.ObjectId) -TelephoneNumber $PhoneNumber -ErrorAction Stop
          }
          catch {
            if ( -not $Silent ) {
              Write-Error -Message "User '$Identity' Applying Phone Number failed: '$($_.Exception.Message)'"
            }
            $ErrorLog += $_.Exception.Message
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
      $Filename = "$($MyInvocation.MyCommand) for User $Identity - ERROR.log"
      $LogPath = "$Path\$Filename"
      Write-Verbose -Message "User '$Identity' - Errors encountered are written to '$Path'"

      # Write log entry to $Path
      $errorLog | Out-File -FilePath $LogPath -Append

    }
    else {
      Write-Verbose -Message "User '$Identity' - No errors encountered! No log file written."
    }


    # Output
    if ( $Silent ) {
      return
    }
    else {
      # Re-Query Object
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

      return $UserObjectPost
    }
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Set-TeamsUserVoiceConfig
