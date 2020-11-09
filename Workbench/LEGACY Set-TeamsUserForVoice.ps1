function Set-TeamsUserForVoice
{
  <#
      .SYNOPSIS
      Assigning, amending or removing Voice Configuration for Teams Direct Routing
      .DESCRIPTION
      Applicable TMS Configuration Script for basic Voice Configuration for TDR
      Verification for input every step of the way.
      Requires an Enabled and Licensed AzureAd Object
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .PARAMETER Tel
      Required for Assign or Amend only.
      Telephone Number to be assigned to the Object in E.164 format
      .PARAMETER Check
      Default. Runs Verifications checks only. No changes are made to object provided
      .PARAMETER Assign
      Enables Enterprise Voice for the Object
      Assigns the LineUri (based on the provided Telephone Number (-Tel)),
      Grants Online Voice Routing Policy (Populated from -Region)
      Grants Tenant Dial Plan (Populated from -Country) - Optional
      .PARAMETER Amend
      Enables Enterprise Voice for the Object
      Assigns the LineUri (based on the provided Telephone Number (-Tel)),
      Grants Online Voice Routing Policy (Populated from -Region)
      Grants Tenant Dial Plan (Populated from -Country) - Optional
      .PARAMETER Remove
      Disables Enterprise Voice for the Object, removes the LineUri
      Removes the Online Voice Routing Policy (if populated)
      Removes the Tenant Dial Plan (if populated)
      .PARAMETER DetailedVoice
      Optional switch to display more Voice Parameters.
      By Default only required values for TDR are shown.
      .PARAMETER IncludePolicies
      Optional switch to display User Policy assignments (long list of all Policies).
      Use for more complex voice deployments (OPCH, Hybrid, etc.) or to troubleshoot
      .PARAMETER FullLicenseQuery
      Optional switch to do a full query against the Object
      By default, only PhoneSystem License is queried
      .PARAMETER Silent
      Optional switch for silent execution.
      Used for CSV processing. Will write verbose, but no visual output
      .PARAMETER WriteLog
      Optional switch to trigger Output as Log and Evidence files for all tests done on an Object
      .PARAMETER Path
      Optional Path to location to store Log and Evidence files.
      If nothing is provided, C:\Temp\ will be used as a default path
      The Log File will be created with the current date and the Method used:
      Script execution Logs:  "2020-04-25 093311 TMS Remove LOG.log"
      Pre/Post Evidence Logs: "2020-04-25 093311 TMS Remove PostChange.txt"
      .EXAMPLE
      Set-TeamsObjectForVoice -Identity user@domain.com
      Executes a Check against the provided UserPrincipalName 'user@domain.com'
      Any combination of Parameters will:
      - Verify a valid Session exists for AzureAD as well as for SkypeOnline
      - Prompts for credentials if a new Session needs to be established
      - Verify the Object exists in AzureAD and in SkypeOnline respectively
      - Verify license assigned to the Object
      Parameter -Check is the default, it can be omitted
      .EXAMPLE
      Set-TeamsObjectForVoice -Identity user@domain.com -Remove
      Executes a Check against the provided UserPrincipalName 'user@domain.com'
      Voice Configuration is removed afterwards
      Action taken by -Remove:
      - Consent is asked for each individual step
      - Disables Object for Enterprise Voice, Removes the OnPremLineUri
      - Revokes grant for Online Voice Routing Policy and Tenant Dial Plan
      - Displays Post-Change Output
      .EXAMPLE
      Set-TeamsObjectForVoice -Identity user@domain.com -Assign -Tel +44123123456 [-AssignTenantDialPlan]
      Executes a Check against the provided UserPrincipalName 'user@domain.com'
      Voice Configuration is applied afterwards (Configuration required for TDR)
      In addition to Verification as outlined in Example #1, it verifies:
      - Verifies enumerated Tenant Dial Plan Name.
      The Naming Standard is applied in the form "DP-GB" (ISO3166-alpha 2)
      The Users UsageLocation or Country are used to query the CountryCode
      - Verifies enumerated Online Voice Routing Policy.
      The Naming Standard is applied in the form "O_VP_EMEA"
      The Users UsageLocation or Country are used to query the Region
      A static table is used to find the Region based on Country.
      Action taken by -Assign or -Amend (switches are interchangable):
      - Enables Object for Enterprise Voice, Sets the OnPremLineUri
      - Grants Online Voice Routing Policy
      - Optional Switch -AssignTenantDialPlan also Grants a Tenant Dial Plan
      - Displays Post-Change Output
      .EXAMPLE
      Set-TeamsObjectForVoice -Identity user@domain.com -Check -DetailedVoice -FullLicenseQuery
      Executes a Check against the provided UserPrincipalName 'user@domain.com'
      In addition to Verification as outlined in Example #1, it verifies:
      - A Detailed Voice Configuration can be displayed (instead of simple set)
      using the optional switch -DetailedVoice
      - All User Policies on the Teams Object can be displayed
      using the optional switch -IncludePolicies
      - A more detailed look at assigned licenses can be displayed
      using the optional switch -FullLicenseQuery
      This will give individual Found/Not Found reporting for every single License Package
      .NOTES
      Currently only Usable for Single-Object input but will be expanded upon to support CSV input.
      V20.03 - MAR-2020 - User Input with manually defining variables
      V20.04 - APR-2020 - Sturdy and reusable script for 90% of all provisioning
                          Errors should be investigated by UC
      Coming soon:      - Adding functionality for importing via CSV
                          Requirement for VST and UC
  #>

  #region Params
  [CmdletBinding(DefaultParameterSetName="Check")]
  param(
    [Parameter(Mandatory = $true, ParameterSetName="Assign", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Parameter(Mandatory = $true, ParameterSetName="Amend", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Parameter(Mandatory = $true, ParameterSetName="Remove", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Parameter(Mandatory = $true, ParameterSetName="Check", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity,

    [Parameter(Mandatory=$true, ParameterSetName="Assign", ValueFromPipelineByPropertyName = $true, HelpMessage = "Please provide Number in E.164 format")]
    [Parameter(Mandatory=$true, ParameterSetName="Amend", ValueFromPipelineByPropertyName = $true, HelpMessage = "Please provide Number in E.164 format")]
    [Alias("Number","TelephoneNumber")]
    [string]$Tel,

    [Parameter(ParameterSetName="Assign")]
    [switch]$Assign,

    [Parameter(ParameterSetName="Amend")]
    [switch]$Amend,

    [Parameter(ParameterSetName="Remove")]
    [switch]$Remove,

    [Parameter(ParameterSetName="Check")]
    [switch]$Check,

    # need to integrate these two parameters properly
    # Replace $AssignTenantDialPlan with $TDP (change mechanic!) if not provided, will guess based on Country
    # Same for $OVR, if not provided, will guess based on Region
    # Do nothing if the switch is not provided (must allow NullOrEmpty)
    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [Alias("TenantDialPlan","DialPlan")]
    [string]$TDP,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [Alias("OnlineVoiceRoutingPolicy","VoicePolicy")]
    [string]$OVP,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Alias("AssignTDP")]
    [switch]$AssignTenantDialPlan,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [switch]$Silent,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [Alias("DisplayAllVoiceParams","FullVoice","FullVoiceConfig")]
    [switch]$DetailedVoice,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [switch]$IncludePolicies,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [switch]$FullLicenseQuery,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [Alias("Log")]
    [switch]$WriteLog,

    [Parameter(ParameterSetName="Assign")]
    [Parameter(ParameterSetName="Amend")]
    [Parameter(ParameterSetName="Remove")]
    [Parameter(ParameterSetName="Check")]
    [Alias("LogPath")]
    [string]$Path = "C:\Temp\"
  )
  #endregion

  BEGIN
  {
    #region Defining Global Variables
    # Defining $Action as it is used throughout and was a variable prior but could not be reconciled with a Parameterset without using DynParams
    IF    ($Assign) {$Action = "Assign"}
    ELSEIF($Amend)  {$Action = "Amend"}
    ELSEIF($Remove) {$Action = "Remove"}
    ELSEIF($Check)  {$Action = "Check"}
    ELSE            {$Action = "Check"}
    #endregion

    #region Header
    if (-not $Silent) {
      Clear-Host
      Write-Host "Applicable Teams Scripts:`t" -ForegroundColor Green -NoNewline
      Write-Host "Teams Direct Routing (TDR) and Teams Managed Service (TMS)"
      Write-Host "Teams Managed Service - Assign/Amend/Remove (Process 5491)" -ForegroundColor Yellow
      Write-Host ""
      Write-Host "Chosen Action: " -ForegroundColor Cyan -NoNewline
      Write-Host "$Action" -ForegroundColor Magenta
      IF(-not $DetailedVoice) {Write-Host "+ Default Setting: Showing simple Voice Configuration (for TDR)"}
      ELSE {Write-Host "+ Switch -DetailedVoice: Showing detailed Voice Configuration"}
      IF($IncludePolicies) {Write-Host "+ Switch -IncludePolicies: Showing all Teams User Policies"}
      IF($FullLicenseQuery) {Write-Host "+ Switch -FullLicenseQuery: Showing detailed License Query"}
    }
    #endregion

    #region Preparing Log File Path
    if ($WriteLog) {
      #Test Path ends in Backslash to form proper folder path
      if ($Path.Chars($Path.Length - 1) -ne '\')
      {
          $Path = ($Path + '\')
      }
      #Test Path exists
      try {
        Write-Host "+ Switch -WriteLog: Writing Output as Log files to Folder: " -NoNewline
        Test-Path ($Path) -ErrorAction Stop | Out-Null
        $LogPath = $Path
        Write-Host "'$LogPath'"
      }
      catch {
          Write-Warning "Log File Path '$Path' could not be found. C:\Temp\ will be used!"
          $LogPath = "C:\temp\"
          IF(-not (Test-Path ($LogPath))) {
            New-Item -Name "temp" -Path C:\ -ItemType Directory
          }
          Write-Host "'$LogPath' ('$Path' could not be found!)"

      }

    }

    # Preparing for Logging
    #Filling Date Variables based on required format (using ISO 8061 basic notation with hyphens for date and space separator for readability)
    #not used currently - $DateApplicableDisplay = Get-Date -Format "dd-MMM-yyyy"
    #not used currently - $DateApplicableLog = Get-Date -Format "yyyy-MM-dd HH:mm K"
    $DateApplicableLogFile = Get-Date -Format "yyyy-MM-dd HHmmss"

    $TaskName = "TMS " + $Action
    $LogFileName = $LogPath + $DateApplicableLogFile + " " + $TaskName + ".log"

    Write-Host ""
    #endregion

    #region TestingConnection
    $message = "'$Identity': Testing Connection to AzureAD"
    IF(-not (Test-AzureADConnection))
    {
      $Level = "Info"
      try {
        Connect-AzureAD
      }
      catch {
          throw
      }
    }
    else {
      $Level = "Success"
    }
    Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

    $message = "'$Identity': Testing Connection to SkypeOnline"
    IF(-not (Test-SkypeOnlineConnection))
    {
      $Level = "Info"
      try {
        Disconnect-SkypeOnline -WarningAction SilentlyContinue
        Connect-SkypeOnline
      }
      catch {
          throw
      }
    }
    else {
        $Level = "Success"
    }
    Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
    #endregion
  }

  PROCESS
  {
    try
    {
      #region TESTS
      #region     '$Identity': START: Performing Tests
      $message = "'$Identity': START: Performing Tests"
      $Level = "Info"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Performing Tests for $Identity against AzureAD
      #region Test '$Identity': Test: AzureAD Object EXISTS
      $Message  = "'$Identity': Test: AzureAD Object EXISTS"
      try {
        #Test
        $AzureADUser = Get-AzureADUser -ObjectId $Identity -ErrorAction STOP
        #Output for SUCCESS
        $Level = "Success"
      }
      catch {
        #Output for FAILED
        $Message += " - FAILED"
        $Level = "Error"
      }
      finally {
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }
      #endregion

      #region Test '$Identity': Test: AzureAD Object is ENABLED
      $Message  = "'$Identity': Test: AzureAD Object is ENABLED"
      #Test
      $ADAccountEnabled = $AzureADUser.AccountEnabled
      if($ADAccountEnabled) {
          #Output for SUCCESS
          $Level = "Success"
          #Tasks

      }
      else {
          #Output for FAILED
          $Message += " - FAILED"
          $Level = "Warning"
      }
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Test '$Identity': Test: AzureAD Object has UsageLocation set
      $Message  = "'$Identity': Test: AzureAD Object has UsageLocation set"
      #Test
      $UsageLocation = $AzureADUser.UsageLocation
      if($UsageLocation -ne "") {
          #Output for SUCCESS
          $message += " - Found: $UsageLocation"
          $Level = "Success"
          #Tasks
          $CountryCode = $AzureAdUser.UsageLocation
      }
      else {
          #Output for FAILED
          $Message += " - FAILED"
          $Level = "Error"
      }
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Output: Object Record in Azure AD
      #TODO Rework like other output sections.
      if(-not $Silent) {
        Write-Host "Output: Object Record in Azure AD" -ForegroundColor Yellow
        Write-Host "Identify potential issues for TDR - Verify: Enabled (in AD), DirSync issues, Usage Location"
        #$AzureAdUser is populated directly after testing
        $AzureAdUser | Select-Object `
        DisplayName,UserPrincipalName,ObjectType,AccountEnabled,`
        DirSyncEnabled,LastDirSyncTime,Country,UsageLocation |`
        Format-List
      }
      #endregion

      #region Test '$Identity': Test: AzureAD Object has PhoneSystem License assigned
      $Message  = "'$Identity': Test: AzureAD Object has PhoneSystem License assigned"
      #Test
      $MCOEVPresent = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOEV
      if ($MCOEVPresent) {
          #Output for SUCCESS
          $message += " - License found: Phone System"
          $Level = "Success"
          #Tasks

      }
      else {
          #Output for FAILED
          $Message += " - License not found: Assign Phone System License through a License Package or directly!"
          $Level = "Error"
      }
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Full License Query (Checking User against Licensing Package)
      IF($FullLicenseQuery)
      {
        #Testing all $Licenses
        $Licenses = @("Microsoft 365 E5", "Microsoft 365 E3 and PhoneSystem", "Office 365 E5", "Office 365 E3 and PhoneSystem", "SfBO Plan 2 and Advanced Meeting and PhoneSystem", "Common Area Phone License")
        FOREACH ($L in $Licenses)
        {
          #region Test '$Identity': Test: AzureAD Object has License Package $L `tassigned
          $Message  = "'$Identity': Test: AzureAD Object has License Package $L `tassigned"
          #Test
          $Lic = $L -replace ' '
          $LicenseIsPresent = Test-TeamsUserLicense -Identity $Identity -LicensePackage $Lic
          if($LicenseIsPresent) {
            #Output for SUCCESS
            $Level = "Success"
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
            #Tasks
            #Setting variables to determine validity
            switch ($L)
            {
              "Microsoft 365 E5"                      {$MS365E5 = $true}
              "Office 365 E5"                         {$O365E5  = $true}
              "Microsoft 365 E3 and PhoneSystem"      {$MS365E3 = $true}
              "Office 365 E3 and PhoneSystem"         {$O365E3  = $true}
              "SfBO Plan 2 and Advanced Meeting and PhoneSystem" {
                $SfBO2 = $true
                $Message = "This license is valid but not officially endorsed by Microsoft"
                $Level = "Warning"
                Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
              }
              "Common Area Phone License" {
                $CAP = $true
                $Message = "This license is only valid for Common Area Phones"
                $Level = "Info"
                Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
              }
              Default {}
            }
          }
          else {
              #Output for FAILED
              $Message += " - FAILED"
              $Level = "Warning"
              Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
            }

          #endregion
        }
        #Determining validity of tested license based on set variables in foreach/switch

        #region Test '$Identity': Test: License package is valid/invalid
        $Message  = "'$Identity': Test: License package is "
        #Test
        #VALID is if $MS365E5, $O365E5, $MS365E3, $O365E3, $SfBO2, $CAP
        if ($MS365E5 -or $O365E5 -or $MS365E3 -or $O365E3 -or $SfBO2 -or $CAP) {
            #Output for SUCCESS
            $Message += "VALID"
            $Level = "Success"
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        else {
            #Output for FAILED
            $Message += "INVALID - A License is required!"
            $Level = "Error"
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

            if(-not $silent) {
              # Showing licenses assigned - Failsafe, just in case the enumeration goes wrong
              Write-Host "Visible output only: Displaying all Licenses currently assigned to the user:"
              Write-Host "## Start of List ##"
              $UserLicenses = (Get-AzureADUserLicenseDetail -ObjectId $Identity).SkuPartNumber
              $UserLicenses
              Write-Host "### End of List ###"
          }
        }
        #endregion
      }
      #endregion
      #endregion

      #region Performing Tests for $Identity against Teams
      #region Test '$Identity': Test: Teams Object EXISTS
      $Message  = "'$Identity': Test: Teams Object EXISTS"
      try {
        #Test
        $SkypeOnlineUser = Get-CsOnlineUser $Identity
        #Output for SUCCESS
        $Level = "Success"
      }
      catch {
        #Output for FAILED
        $Message += " - FAILED"
        $Level = "Error"
      }
      finally {
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }
      #endregion

      #region Test '$Identity': Test: Teams Object is ENABLED
      $Message  = "'$Identity': Test: Teams Object is ENABLED"
      #Test
      $TeamsObjectEnabled = $SkypeOnlineUser.Enabled
      if($TeamsObjectEnabled) {
          #Output for SUCCESS
          $Level = "Success"
          #Tasks

      }
      else {
          #Output for FAILED
          $Message += " - FAILED: Object must be enabled"
          $Level = "Error"
      }
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Test '$Identity': Test: Teams Object has Country assigned
      # Only tested if $CountryCode was not populated with UsageLocation already
      if($CountryCode -eq "") {
        $Message  = "'$Identity': Test: Teams Object has Country assigned"
        #Test
        $CountryAbbreviation = $SkypeOnlineUser.CountryAbbreviation
        if($CountryAbbreviation -ne "") {
            #Tasks
            $CountryCode = $SkypeOnlineUser.CountryAbbreviation
            #Output for SUCCESS
            $message += " - $CountryCode found!"
            $Level = "Success"
        }
        else {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
        }
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }
      #endregion

      #region Tests dependent on Action
      IF($Assign -or $Amend)
      {
        #region Testing input and preparing Variables
        #Testing LineURI starts with a +
        if ($tel.Chars(0) -ne '+')
        {
            $tel = ('+' + $tel)
        }
        $OnPremLineURI = "tel:"+$tel

        #Applicable Naming Standard - If Policies with this name are not found, input is requested (Silent behavior will error instead)
        $OVPPrefix = "O_VP_" # Suffix is $Region
        $TDPPrefix = "DP-" # Suffix is 2-digit Country Code $Country or later ($SkypeOnlineUser.UsageLocation)
        #endregion

        #region Online Voice Routing Policy
        #region Test '$Identity': Test: Enumerating Global Region
        $Message  = "'$Identity': Test: Enumerating Global Region"
        try {
          #Test
          $Region = Get-RegionFromCountryCode -CountryCode $CountryCode -ErrorAction STOP
          #Output for SUCCESS
          $Level = "Success"
        }
        catch {
          #Output for FAILED
          $Message += " - FAILED"
          If ($Silent) {
            $Level = "Error"
          }
          else {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
            #Mitigation - Manual input!
            do {
              #[ValidateSet("AMER","EMEA","APAC")] # Couldn't make it behave - throws error
              $RegionAnyCase = Read-Host "Manual entry: Region (AMER, EMEA or APAC)"
              $Region = $RegionAnyCase.ToUpper()
              IF (-not ($Region -eq "AMER" -or $Region -eq "EMEA" -or $Region -eq "APAC"))
              {
                Write-Host "ERROR:  Region: $Region is not recognised. Please select AMER, EMEA or APAC" -ForegroundColor Red
              }
            }
            until ($Region -eq "AMER" -or $Region -eq "EMEA" -or $Region -eq "APAC")
            $Message = "'$Identity': Region: $Region manually selected"
            $Level = "Success"
          }
        }
        finally {
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion

        # Creating Online Voice Routing Policy Name from Naming Standard
        $OVP = $OVPPrefix + $Region

        #region Test TENANT: Test: Online Voice Routing Policy EXISTS
        $Message  = "TENANT: Test: Online Voice Routing Policy EXISTS"
        #Test
        $OVPExists = Test-TeamsTenantPolicy -Policy "CsOnlineVoiceRoutingPolicy" -PolicyName $OVP
        if ($OVPExists) {
            #Output for SUCCESS
            $Level = "Success"
            #Tasks
        }
        else {
            #Output for FAILED
            $Message += " - FAILED"
            If ($Silent) {
              $Level = "Error"
            }
            else {
              Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
              #Mitigation - Manual input!
              do {
                $OVP = Read-Host "Manual entry: Online Voice Routing Policy Name: "
                $OVPExists = Test-TeamsTenantPolicy -Policy "CsOnlineVoiceRoutingPolicy" -PolicyName $OVP
                if($OVPExists) {
                  Write-Host "ERROR:  Online Voice Routing Policy: $OVP not found!" -ForegroundColor Red
                }
              }
              until ($OVPExists)
              $Message = "'$Identity': Online Voice Routing Policy: $OVP manually provided!"
              $Level = "Success"
            }
        }
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #endregion

        #region Tenant Dial Plan
        if($AssignTenantDialPlan) {
          $TDP = $TDPPrefix + $CountryCode
          #region Test TENANT: Test: Teams Tenant Dial Plan EXISTS
          $Message  = "TENANT: Test: Teams Tenant Dial Plan EXISTS"
          #Test
          $TDPExists = Test-TeamsTenantPolicy -Policy "TenantDialPlan" -PolicyName $TDP
          if ($TDPExists) {
            #Output for SUCCESS
            $Level = "Success"
            #Tasks
          }
          else {
            #Output for FAILED
            $Message += " - FAILED"
            If ($Silent) {
              $Level = "Error"
            }
            else {
              Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
              #Mitigation - Manual input!
              do {
                $TDP = Read-Host "Manual entry: Tenant Dial Plan Name: "
                $TDPExists = Test-TeamsTenantPolicy -Policy "TenantDialPlan" -PolicyName $TDP
                if ($TDPExists) {
                  Write-Host "ERROR:  Tenant Dial Plan: $TDP not found" -ForegroundColor Red
                }
              }
              until ($TDPExists)
              $Message = "'$Identity': Tenant Dial Plan: $TDP manually provided!"
              $Level = "Success"
            }
          }
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          #endregion
        }
        #endregion
      }
      #endregion
      #endregion
      #endregion


      #region OUTPUT: Object Record in Teams
      if(-not $Silent) {
        #region Check: Object Record in Teams - Voice Status
        Write-Host "Output: Object Record in Teams - Voice Status" -ForegroundColor Yellow
        If(-not $DetailedVoice)
        {
          Write-Host "Only Parameters needed to configure a Teams Object for TDR are shown (use -DetailedVoice for more)" -ForegroundColor DarkYellow
          Write-Host "Identify potential issues for Teams Direct Routing (TDR) - Verify: Enabled, existing configuration"
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,`
          OnPremLineUri,DialPlan,TenantDialPlan,OnlineVoiceRoutingPolicy | `
          Format-List
        }
        ELSE
        {
          Write-Host "Displaying all necessary Voice related Parameters" -ForegroundColor DarkYellow
          Write-Host "Identify potential issues for any Voice Configuration - Verify: Enabled, existing configuration"
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,OnPremEnterpriseVoiceEnabled,`
          TelephoneNumber,LineUri,OnPremLineUri,OnPremLineURIManuallySet,DialPlan,TenantDialPlan,VoicePolicy,VoiceRoutingPolicy,OnlineVoiceRoutingPolicy,TeamsVoiceRoute | `
          Format-List
        }
        #endregion

        #region Check: Object Record in Teams - Policies
        If($IncludePolicies)
        {
          Write-Host "Check: Object Record in Teams - Policies" -ForegroundColor Yellow
          Write-Host "NOTE: This provides for a more granular look at Policies for the User Object"
          Write-Host "Policy assignment, not required for standard TDR MACDs"
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,*Policy* | `
          Format-List
        }
        #endregion
      }
      #endregion


      #region EVIDENCE: PreChange Log
      IF($WriteLog -and ($Assign -or $Amend -or $Remove)) {
        #region Preparing Evidence File
        $Step = "PreChange"
        $EvidenceLogName = "TMS " + $Action
        [system.string]$EvidenceLogFileIs = Write-ApplicableEvidenceLog -Step $Step -LogName $EvidenceLogName -Path $LogPath
        $EvidenceLogFile = $EvidenceLogFileIs.Trim()
        #endregion

        #region Writing Content to File
        #region AzureAD Information
        $InfoByte = "AzureAD Object"
        "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

        $AzureADUser | Select-Object `
        DisplayName,UserPrincipalName,ObjectType,AccountEnabled,`
        DirSyncEnabled,LastDirSyncTime,Country,UsageLocation |`
        Out-File -FilePath "$EvidenceLogFile" -Append

        $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #region Teams Voice Information
        IF(-not $DetailedVoice) {
          $InfoByte = "Teams Object - TDR Voice Config"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,`
          OnPremLineUri,DialPlan,TenantDialPlan,OnlineVoiceRoutingPolicy | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        }
        else {
          $InfoByte = "Teams Object - DetailedVoice"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,OnPremEnterpriseVoiceEnabled,`
          TelephoneNumber,LineUri,OnPremLineUri,OnPremLineURIManuallySet,DialPlan,TenantDialPlan,VoicePolicy,VoiceRoutingPolicy,OnlineVoiceRoutingPolicy,TeamsVoiceRoute | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        }
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #region Teams Policy Information
        IF($IncludePolicies) {
          $InfoByte = "Teams Object - Policies"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,*Policy* | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }

        #endregion
        #endregion
      }
      #endregion


      #region PAYLOAD
      $message = "'$Identity': ##### START: Processing Changes to Object"
      $Level = "Info"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

      IF($Action -eq "Assign" -or $Action -eq "Amend")
      {
        #region Gaining Consent for Action
        $Message  = "'$Identity': Action: $Action`: Gaining Consent"
        $Level = "Info"
        #Test
        if ($Silent)  {$ExecuteAssignAction = $true}
        else          {$ExecuteAssignAction = Get-Consent}
        if($ExecuteAssignAction) {
            #Output for SUCCESS
            if ($Silent)    {$Message += " - GAINED SILENTLY"}
            else            {$Message += " - GAINED"}
        }
        else {
            #Output for FAILED
            $Message += " - NOT GAINED"
        }
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion

        #region Payload for Action Assign or Amend
        if($ExecuteAssignAction)
        {
          #region Test '$Identity': Action: $Action`: Activity: Enabling for Enterprise Voice
          $Message  = "'$Identity': Action: $Action`: Activity: Enabling for Enterprise Voice"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -EnterpriseVoiceEnabled $TRUE -ErrorAction STOP
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          #endregion

          #region Test '$Identity': Action: $Action`: Activity: Enabling HostedVoiceMail
          $Message  = "'$Identity': Action: $Action`: Activity: Enabling HostedVoiceMail"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -HostedVoiceMail $TRUE -ErrorAction STOP
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': Action: $Action`: Activity: Assigning LineURI
          $Message  = "'$Identity': Action: $Action`: Activity: Assigning LineURI"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -OnPremLineURI $OnPremLineURI -ErrorAction STOP
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Granting Voice Routing Policy
          $Message  = "'$Identity': $Action`: Activity: Enabling for Enterprise Voice"
          try {
            #Test
            Get-CsOnlineUser $Identity | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $OVP -ErrorAction STOP
            #Output for SUCCESS
            $message += " - Granted: $OVP"
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Granting Tenant Dial Plan
          # Situational - ONLY used with Switch $AssignTenantDialPlan
          IF($AssignTenantDialPlan)
          {
            $Message  = "'$Identity': $Action`: Activity: Enabling for Enterprise Voice"
            try {
              #Test
              Get-CsOnlineUser $Identity | Grant-CsTenantDialPlan -PolicyName $TDP -ErrorAction STOP
              #Output for SUCCESS
              $message += " - Granted: $TDP"
              $Level = "Success"
            }
            catch {
              #Output for FAILED
              $Message += " - FAILED"
              $Level = "Error"
            }
            finally {
              Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
            }
          }
          #endregion
        }
        Else
        {
          $Message = "'$Identity': Action: $Action`: No Action taken"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion
      }
      ELSEIF ($Action -eq "Remove")
      {
        #region Gaining Consent for Action
        $Message  = "'$Identity': Action: $Action`: Gaining Consent"
        $Level = "Info"
        #Test
        if ($Silent)  {$ExecuteRemoveAction = $true}
        else          {$ExecuteRemoveAction = Get-Consent}
        if($ExecuteRemoveAction) {
            #Output for SUCCESS
            $Message += " - GAINED"
            if ($Silent)    {
              $Message += " (silently)"
            }
        }
        else {
            #Output for FAILED
            $Message += " - NOT GAINED"
        }
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion

        #region Payload for Action Remove
        if($ExecuteRemoveAction)
        {
          #region Test '$Identity': $Action`: Activity: Disabling User for Enterprise Voice
          $Message  = "'$Identity': $Action`: Activity: Disabling User for Enterprise Voice"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -EnterpriseVoiceEnabled $FALSE -ErrorAction STOP | Out-Null
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Disabling HostedVoiceMail
          $Message  = "'$Identity': $Action`: Activity: Disabling HostedVoiceMail"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -HostedVoiceMail $FALSE -ErrorAction STOP | Out-Null
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Removing LineUri
          $Message  = "'$Identity': $Action`: Activity: Removing LineUri"
          try {
            #Test
            Set-CsUser -Identity "$Identity" -OnPremLineURI $NULL -ErrorAction STOP | Out-Null
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Removing Online Voice Routing Policy
          $Message  = "'$Identity': $Action`: Activity: Removing Online Voice Routing Policy"
          try {
            #Test
            Get-CsOnlineUser -Identity "$Identity" | Grant-CsOnlineVoiceRoutingPolicy -PolicyName $NULL -ErrorAction STOP | Out-Null
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion

          #region Test '$Identity': $Action`: Activity: Removing Tenant Dial Plan
          $Message  = "'$Identity': $Action`: Activity: Removing Tenant Dial Plan"
          try {
            #Test
            Get-CsOnlineUser -Identity "$Identity" | Grant-CsTenantDialPlan -PolicyName $NULL -ErrorAction STOP | Out-Null
            #Output for SUCCESS
            $Level = "Success"
          }
          catch {
            #Output for FAILED
            $Message += " - FAILED"
            $Level = "Error"
          }
          finally {
            Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          }
          #endregion
        }
        else
        {
          $Message = "'$Identity': Action: $Action`: No Consent given - Object not changed"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion
      }
      ELSEIF ($Action -eq "Check")
      {
        $message = "'$Identity': Action: $Action`: No Action taken"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }
      ELSE
      {
        $message = "'$Identity': Action: $Action`: No Action taken"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }

      $message = "'$Identity': ##### END: Processing Changes to Object"
      $Level = "Info"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion


      #region OUTPUT: Object Record in Teams (Verification)
      if(-not $Silent -and ($Assign -or $Amend -or $Remove)) {
        #region Check: Object Record in Teams - Voice Status
        Write-Host "Output: Object Record in Teams - Voice Status (Verification)" -ForegroundColor Yellow
        If(-not $DetailedVoice)
        {
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,`
          OnPremLineUri,DialPlan,TenantDialPlan,OnlineVoiceRoutingPolicy | `
          Format-List
        }
        ELSE
        {
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,OnPremEnterpriseVoiceEnabled,`
          TelephoneNumber,LineUri,OnPremLineUri,OnPremLineURIManuallySet,DialPlan,TenantDialPlan,VoicePolicy,VoiceRoutingPolicy,OnlineVoiceRoutingPolicy,TeamsVoiceRoute | `
          Format-List
        }
        #endregion

        #region Check: Object Record in Teams - Policies
        If($IncludePolicies)
        {
          Write-Host "Check: Object Record in Teams - Policies" -ForegroundColor Yellow
          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,*Policy* | `
          Format-List
        }
        #endregion
      }
      #endregion

      #region EVIDENCE: PostChange Log
      IF($WriteLog -and ($Assign -or $Amend -or $Remove)) {
        #Re-query Object
        $SkypeOnlineUser = Get-CsOnlineUser $Identity -ErrorAction SilentlyContinue

        #region Preparing Evidence File
        $Step = "PostChange"
        $EvidenceLogName = "TMS " + $Action
        [system.string]$EvidenceLogFileIs = Write-ApplicableEvidenceLog -Step $Step -LogName $EvidenceLogName -Path $LogPath
        $EvidenceLogFile = $EvidenceLogFileIs.Trim()
        #endregion

        #region Writing Content to File
        #region AzureAD Information
        $InfoByte = "AzureAD Object"
        "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

        $AzureADUser | Select-Object `
        DisplayName,UserPrincipalName,ObjectType,AccountEnabled,`
        DirSyncEnabled,LastDirSyncTime,Country,UsageLocation |`
        Out-File -FilePath "$EvidenceLogFile" -Append

        $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #region Teams Voice Information
        IF(-not $DetailedVoice) {
          $InfoByte = "Teams Object - TDR Voice Config"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,`
          OnPremLineUri,DialPlan,TenantDialPlan,OnlineVoiceRoutingPolicy | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        }
        else {
          $InfoByte = "Teams Object - DetailedVoice"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,SipAddress,Enabled,TeamsUpgradeEffectiveMode,TeamsUpgradePolicy,HostedVoiceMail,EnterpriseVoiceEnabled,OnPremEnterpriseVoiceEnabled,`
          TelephoneNumber,LineUri,OnPremLineUri,OnPremLineURIManuallySet,DialPlan,TenantDialPlan,VoicePolicy,VoiceRoutingPolicy,OnlineVoiceRoutingPolicy,TeamsVoiceRoute | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        }
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #region Teams Policy Information
        IF($IncludePolicies) {
          $InfoByte = "Teams Object - Policies"
          "'$Identity' - $InfoByte" | Out-File -FilePath "$EvidenceLogFile" -Append

          $SkypeOnlineUser | Select-Object `
          UserPrincipalName,*Policy* | `
          Out-File -FilePath "$EvidenceLogFile" -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion
        #endregion
      }
      #endregion
    }
    #region CATCH

    # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
    # some InvocationInfo details such as ScriptLineNumber.
    # REMEDY: If that affects you, remove the SPECIFIC exception type [System.Management.Automation.RuntimeException] in the code below
    # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
    # add the logic to handle different error types differently by yourself.
    catch [System.Management.Automation.RuntimeException]
    {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }

      # output Info. Post-process collected info, and log info (optional)
      $info
    }

    #endregion
  }

}
#end