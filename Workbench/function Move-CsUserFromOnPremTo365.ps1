function Move-CsUserFromOnPremTo365 {
  <#
      .SYNOPSIS
      Moves a User to Skype Online and logs evidence
      .DESCRIPTION
      Applicable Skype Migration Script  with Applicable Logging wrap
      Requires an Enabled and Licensed AzureAd Object (for SkypeOnline)
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .PARAMETER Check
      Default. Runs Verification checks only. No changes are made to object provided
      .PARAMETER Move
      Moves the object to Skype Online (not Teams!)
      .PARAMETER Silent
      Optional switch for silent execution.
      Used for CSV processing. Will write verbose, but no visual output
      .PARAMETER ForceUserMove
      Uses -Force
      .PARAMETER UseOauth
      Uses -Oauth - Can only be used for Skype On-Prem environments with CU8 or higher installed
      .PARAMETER Credential
      Uses -Credential - A valid PS Credential is expected (Non-MFA)
      .PARAMETER UseOverrideURL
      Uses -HostedMigrationOverrideURL - URL is constructed from (Get-PSSession -Select First 1).Computername
      .PARAMETER WriteLog
      Optional switch to trigger Output as Log and Evidence files for all tests done on an Object
      .PARAMETER Path
      Optional Path to location to store Log and Evidence files.
      If nothing is provided, C:\Temp\ will be used as a default path
      The Log File will be created with the current date and the Method used:
      Script execution Logs:  "2020-04-25 093311 SkypeUser Move LOG.log"
      Pre/Post Evidence Logs: "2020-04-25 093311 SkypeUser Move PostChange.txt"
      .EXAMPLE
      Move-CsUserFromOnPremTo365 -Identity user@domain.com
      Executes a Check against the provided UserPrincipalName 'user@domain.com'
      Any combination of Parameters will:
      - Verify a valid Session exists for AzureAD as well as for SkypeOnline
      - Prompts for credentials if a new Session needs to be established
      - Verify license assigned to the Object (MCOSTANDARD)
      Parameter -Check is the default, it can be omitted
      .EXAMPLE
      Move-CsUserFromOnPremTo365 -Identity user@domain.com -Move
      Moves the Object 'user@domain.com' to Skype Online
      Consent is asked before execution (unlesss -Silent is also specified)
      .EXAMPLE
      Move-CsUserFromOnPremTo365 -Identity user@domain.com -Move -Silent -WriteLog -Path $LogPath
      Moves the Object 'user@domain.com' to Skype Online and writes Output Log to $LogPath
      No visual output is presented. Verbose Log will be written
  #>

  #region Params
  [CmdletBinding(DefaultParameterSetName = "Check")]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "Move", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Parameter(Mandatory = $true, ParameterSetName = "Check", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity,

    [Parameter(ParameterSetName = "Check")]
    [Parameter(ParameterSetName = "Move")]
    [switch]$NoAD,

    [Parameter(ParameterSetName = "Move")]
    [switch]$Move,

    [Parameter(ParameterSetName = "Check")]
    [switch]$Check,

    [Parameter(ParameterSetName = "Move")]
    [Parameter(ParameterSetName = "Check")]
    [switch]$Silent,

    [Parameter(ParameterSetName = "Move")]
    [switch]$ForceUserMove,

    [Parameter(ParameterSetName = "Move", HelpMessage = "This will use Oauth instead of DCOM (use only for environments with Skype CU8 installed")]
    [switch]$UseOauth,

    [Parameter(ParameterSetName = "Move", HelpMessage = "This will use the Computername from the PSSsession and construct the HostedMigrationOverrideUrl")]
    [switch]$UseOverrideURL,

    [Parameter(ParameterSetName = "Move")]
    [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty,

    [Parameter(ParameterSetName = "Move")]
    [Parameter(ParameterSetName = "Check")]
    [Alias("Log")]
    [switch]$WriteLog,

    [Parameter(ParameterSetName = "Move")]
    [Parameter(ParameterSetName = "Check")]
    [Alias("LogPath")]
    [string]$Path = "C:\Temp\"
  )
  #endregion

  BEGIN {
    #region Defining Global Variables
    # Defining $Action as it is used throughout and was a variable prior but could not be reconciled with a Parameterset without using dynparams
    IF ($Move) { $Action = "Move" }
    ELSEIF ($Check) { $Action = "Check" }
    ELSE { $Action = "Check" }

    #endregion

    #region preparing environment
    $SignInService = "msoidsvc"
    $SignInServiceRunning = (Get-Service $SignInService).Status -eq "Running"
    if (-not $SignInServiceRunning) {
      Start-Service $SignInService
    }
    #endservice

    <#creating Credential - THIS IS CHEATING, I KNOW
    $password = ConvertTo-SecureString "5=9s2humJx" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ("svc.BTusercreation@coffeeandtea.onmicrosoft.com", $password)
    #>

    #region Preparing Log File Path
    if ($WriteLog) {
      #Test Path ends in Backslash to form proper folder path
      if ($Path.Chars($Path.Length - 1) -ne '\') {
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
        IF (-not (Test-Path ($LogPath))) {
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

    $TaskName = "SkypeUser " + $Action
    $LogFileName = $LogPath + $DateApplicableLogFile + " " + $TaskName + ".log"

    Write-Host ""
    #endregion

    #region TestingConnection
    if ($NoAD) {
      $message = "'$Identity': No Connection to AzureAD - no AD checks done!"
      $Level = "Warning"
    }
    else {
      $message = "'$Identity': Testing Connection to AzureAD"
      IF (-not (Test-AzureADConnection)) {
        $Level = "Info"
        Connect-AzureAD
      }
      else {
        $Level = "Success"
      }
    }
    Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

    $message = "'$Identity': Testing Connection to SkypeOnline"
    IF (-not (Test-SkypeOnlineConnection)) {
      $Level = "Info"
      Disconnect-SkypeOnline -WarningAction SilentlyContinue
      Connect-SkypeOnline
    }
    else {
      $Level = "Success"
    }
    Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
    #endregion
  }

  PROCESS {
    try {
      #region TESTS
      #region     '$Identity': START: Performing Tests
      $message = "'$Identity': START: Performing Tests"
      $Level = "Warning"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #region Performing Tests for $Identity against AzureAD
      if (-not $NoAD) {
        #region Test '$Identity': Test: AzureAD Object EXISTS
        $Message = "'$Identity': Test: AzureAD Object EXISTS"
        $Level = "Error"
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
        $Message = "'$Identity': Test: AzureAD Object is ENABLED"
        #Test
        $ADAccountEnabled = $AzureADUser.AccountEnabled
        if ($ADAccountEnabled) {
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

        #region Output: Object Record in Azure AD
        if (-not $Silent) {
          Write-Host "Output: Object Record in Azure AD" -ForegroundColor Yellow
          Write-Host "Identify potential issues for TDR - Verify: Enabled (in AD), DirSync issues, Usage Location"
          #$AzureADuser is populated directly after testing
          $AzureADUser | Select-Object `
            DisplayName, UserPrincipalName, ObjectType, AccountEnabled, `
            DirSyncEnabled, LastDirSyncTime, Country, UsageLocation |`
            Format-List
        }
        #endregion

        #region Test '$Identity': Test: AzureAD Object has MCOSTANDARD License assigned
        $Message = "'$Identity': Test: AzureAD Object has MCOSTANDARD License assigned"
        #Test
        $MCOSTANDARDpresent = Test-TeamsUserLicense -Identity $Identity -ServicePlan MCOSTANDARD
        if ($MCOSTANDARDpresent) {
          #Output for SUCCESS
          $Level = "Success"
          #Tasks

        }
        else {
          #Output for FAILED
          $Message += " - FAILED: A license is required!"
          $Level = "Error"
        }
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
      }

      #endregion

      #region Performing Tests for $Identity against Skype
      #region Test '$Identity': Test: Skype Object EXISTS
      $Message = "'$Identity': Test: Skype Object EXISTS"
      try {
        #Test
        $SkypeUser = Get-CsUser $Identity
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

      #region Test '$Identity': Test: Skype Object is ENABLED
      $Message = "'$Identity': Test: Skype Object is ENABLED"
      #Test
      $SkypeObjectEnabled = $SkypeUser.Enabled
      if ($SkypeObjectEnabled) {
        #Output for SUCCESS
        $Level = "Success"
        #Tasks

      }
      else {
        #Output for FAILED
        $Message += " - FAILED: A license is required!"
        $Level = "Error"
      }
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion

      #endregion
      #endregion


      #region OUTPUT: Object Record in Skype
      if (-not $Silent) {
        #region Check: Object Record in Skype
        Write-Host "Output: Object Record in Skype" -ForegroundColor Yellow
        $SkypeUser | Select-Object `
          UserPrincipalName, SipAddress, Enabled, HostedVoiceMail, EnterpriseVoiceEnabled, LineUri, DialPlan, VoicePolicy, HostingProvider, RegistrarPool | `
          Format-List

        #endregion
      }
      #endregion


      #region EVIDENCE: PreChange Log
      IF ($WriteLog -and $Move) {
        #region Preparing Evidence File
        $Step = "PreChange"
        $EvidenceLogName = "SkypeUser " + $Action
        [system.string]$EvidenceLogFileIs = Write-ApplicbleEvidenceLog -Step $Step -LogName $EvidenceLogName -Path $LogPath
        $EvidenceLogFile = $EvidenceLogFileIs.Trim()
        #endregion

        #region Writing Content to File
        #region AzureAD Information
        $InfoByte = "AzureAD Object"
        "'$Identity' - $InfoByte" | Out-File -FilePath $("$EvidenceLogFile") -Append

        $AzureADUser | Select-Object `
          DisplayName, UserPrincipalName, ObjectType, AccountEnabled, `
          DirSyncEnabled, LastDirSyncTime, Country, UsageLocation |`
          Out-File -FilePath $("$EvidenceLogFile") -Append

        $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #region Skype Information
        $InfoByte = "Skype Object Information"
        "'$Identity' - $InfoByte" | Out-File -FilePath $("$EvidenceLogFile") -Append

        $SkypeUser | Select-Object `
          UserPrincipalName, SipAddress, Enabled, HostedVoiceMail, EnterpriseVoiceEnabled, LineUri, DialPlan, VoicePolicy, HostingProvider, RegistrarPool, TargetRegistrarPool | `
          Out-File -FilePath $("$EvidenceLogFile") -Append

        $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        #endregion
        #endregion
      }
      #endregion


      #region PAYLOAD
      $message = "'$Identity': ##### START: Processing Changes to Object"
      $Level = "Info"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

      IF ($Action -eq "Move") {
        #region Gaining Consent for Action
        $Message = "'$Identity': Action: $Action`: Gaining Consent"
        #Test
        if ($Silent) { $ExecuteMoveAction = $true }
        else { $ExecuteMoveAction = Get-Consent }
        if ($ExecuteMoveAction) {
          #Output for SUCCESS
          if ($Silent) { $Message += " - GAINED SILENTLTY" }
          else { $Message += " - GAINED" }
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        else {
          #Output for FAILED
          $Message += " - NOT GAINED"
          $Level = "Warning"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion

        #region Payload for Action Move
        if ($ExecuteMoveAction) {
          #Gathering information
          if ($SkypeUser.RegistrarPool -like "%fepool01%") {
            $ProxyPool = $SkypeUser.RegistrarPool
            $Message = "User is proxied through $ProxyPool"
            $Level = "Info"
          }
          else {
            $Message = "User is not on one of Applicable Pools"
            $Level = "Error"
          }
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent

          #Creationg HostingMigrationOverrideURL
          $O365FQDN = (Get-PSSession | Select-Object -First 1).Computername
          $URLprefix = "https://"
          $URLsuffix = "/HostedMigration/hostedmigrationservice.svc"
          $HostedMigrationOverrideURL = $UrlPrefix + $O365FQDN + $URLSuffix


          #region Test '$Identity': $Action`: Activity: Moving User to Office 365
          $Message = "'$Identity': $Action`: Activity: Moving User to Office 365"
          try {
            #Test

            #region Test
            if ($Credential.Gettype().Name -eq "PSCredential") {
              if ($UseOauth) {
                if ($UseOverrideURL) {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Oauth -Force:$ForceUserMove -ProxyPool $ProxyPool -Credential $Credential -HostedMigrationOverrideUrl $HostedMigrationOverrideURL -ErrorAction Stop -Verbose -Confirm:$False
                }
                else {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Oauth -Force:$ForceUserMove -ProxyPool $ProxyPool -Credential $Credential -ErrorAction Stop -Verbose -Confirm:$False
                }
              }
              else {
                if ($UseOverrideURL) {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Force:$ForceUserMove -ProxyPool $ProxyPool -Credential $Credential -HostedMigrationOverrideUrl $HostedMigrationOverrideURL -ErrorAction Stop -Verbose -Confirm:$False
                }
                else {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Force:$ForceUserMove -ProxyPool $ProxyPool -Credential $Credential -ErrorAction Stop -Verbose -Confirm:$False
                }
              }
            }
            else {
              if ($UseOauth) {
                if ($UseOverrideURL) {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Oauth -Force:$ForceUserMove -ProxyPool $ProxyPool -HostedMigrationOverrideUrl $HostedMigrationOverrideURL -ErrorAction Stop -Verbose -Confirm:$False
                }
                else {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Oauth -Force:$ForceUserMove -ProxyPool $ProxyPool -ErrorAction Stop -Verbose -Confirm:$False
                }
              }
              else {
                if ($UseOverrideURL) {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Force:$ForceUserMove -ProxyPool $ProxyPool -HostedMigrationOverrideUrl $HostedMigrationOverrideURL -ErrorAction Stop -Verbose -Confirm:$False
                }
                else {
                  Move-CsUser -Identity $Identity -Target "sipfed.online.lync.com" -Force:$ForceUserMove -ProxyPool $ProxyPool -ErrorAction Stop -Verbose -Confirm:$False
                }
              }
            }
            #endregion

            #Output for SUCCESS
            $message += " - SUCCESS"
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
        else {
          $Message = "'$Identity': Action: $Action`: No Consent given - Object not changed"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
        }
        #endregion
      }
      ELSEIF ($Action -eq "Check") {
        $message = "'$Identity': Action: $Action`: No Action taken"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }
      ELSE {
        $message = "'$Identity': Action: $Action`: No Action taken"
        $Level = "Info"
        Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      }

      $message = "'$Identity': ##### END: Processing Changes to Object"
      $Level = "Info"
      Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
      #endregion


      #region OUTPUT: Object Record in Skype
      if (-not $Silent) {
        if ($Move) {
          #region Check: Object Record in Skype
          Write-Host "Output: Object Record in Skype" -ForegroundColor Yellow
          $SkypeUser | Select-Object `
            UserPrincipalName, SipAddress, Enabled, HostedVoiceMail, EnterpriseVoiceEnabled, LineUri, DialPlan, VoicePolicy, HostingProvider, RegistrarPool | `
            Format-List
          #endregion
        }
      }
      #endregion

      #region EVIDENCE: PostChange Log
      if ($Action -eq "Move") {
        IF ($WriteLog) {
          #Re-query Object
          $SkypeUser = Get-CsUser $Identity -ErrorAction SilentlyContinue

          #region Preparing Evidence File
          $Step = "PostChange"
          $EvidenceLogName = "SkypeUser " + $Action
          [system.string]$EvidenceLogFileIs = Write-ApplicbleEvidenceLog -Step $Step -LogName $EvidenceLogName -Path $LogPath
          $EvidenceLogFile = $EvidenceLogFileIs.Trim()
          #endregion

          #region Writing Content to File
          #region AzureAD Information
          $InfoByte = "AzureAD Object"
          "'$Identity' - $InfoByte" | Out-File -FilePath $("$EvidenceLogFile") -Append

          $AzureADUser | Select-Object `
            DisplayName, UserPrincipalName, ObjectType, AccountEnabled, `
            DirSyncEnabled, LastDirSyncTime, Country, UsageLocation |`
            Out-File -FilePath $("$EvidenceLogFile") -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          #endregion
          #region Skype Information
          $InfoByte = "Skype Object Information"
          "'$Identity' - $InfoByte" | Out-File -FilePath $("$EvidenceLogFile") -Append

          $SkypeUser | Select-Object `
            UserPrincipalName, SipAddress, Enabled, HostedVoiceMail, EnterpriseVoiceEnabled, LineUri, DialPlan, VoicePolicy, HostingProvider, RegistrarPool, TargetRegistrarPool | `
            Out-File -FilePath $("$EvidenceLogFile") -Append

          $message = "'$Identity': Evidence Log $Step - $InfoByte - written to $EvidenceLogFile"
          $Level = "Info"
          Write-ApplicableLog -Message $Message -Level $Level -Log $LogFileName -Visible $Silent
          #endregion
          #endregion
        }
      }
      #endregion
    }
    #region CATCH

    # NOTE: When you use a SPECIFIC catch block, exceptions thrown by -ErrorAction Stop MAY LACK
    # some InvocationInfo details such as ScriptLineNumber.
    # REMEDY: If that affects you, remove the SPECIFIC exception type [System.Management.Automation.RuntimeException] in the code below
    # and use ONE generic catch block instead. Such a catch block then handles ALL error types, so you would need to
    # add the logic to handle different error types differently by yourself.
    catch [System.Management.Automation.RuntimeException] {
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