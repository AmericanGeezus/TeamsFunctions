# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Connect-SkypeOnline {
  <#
	.SYNOPSIS
		Creates a remote PowerShell session to Teams (SkypeOnline)
	.DESCRIPTION
    The Connect-SkypeOnline cmdlet connects an authenticated account to use for Microsoft Teams (SkypeOnline) cmdlet requests.
    Establishing a remote PowerShell session to Microsoft Teams (SkypeOnline)
    A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect
    To execute commands against Teams, one of the Teams Admin roles is required.
	.PARAMETER AccountId
		Optional String. The Username or sign-in address to use when making the remote PowerShell session connection.
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
	.PARAMETER IdleTimeout
		Optional. Defines the IdleTimeout of the session in full hours between 1 and 8. Default is 4 hrs.
		Note, by default, creating a session with New-CsOnlineSession results in a Timeout of 15mins!
	.EXAMPLE
		Connect-SkypeOnline
    Prompt for the Username and password of an administrator with permissions to connect to Microsoft Teams (SkypeOnline).
    Additional prompts for Multi Factor Authentication are displayed as required
	.EXAMPLE
		Connect-SkypeOnline -AccountId admin@contoso.com
    If supported, will pre-fill the authentication prompt with admin@contoso.com and only ask for the password for the account
    to connect out to Microsoft Teams (SkypeOnline). Additional prompts for Multi Factor Authentication are displayed as required.
	.NOTES
    Requires that the Module Microoft Teams (v1.1.6) or Skype Online Connector PowerShell module (v7.0.0.0 or higher) to be installed.
    If the SkypeOnlineConnector is used, the Username can be passed to along and the Session can be reconnected (Enable-CsOnlineSessionForReconnection is run).
    The following Tasks are preformed by this cmdlet:
		- Verifying Module MicrosoftTeams or SkypeOnlineConnector are installed and imported
    - Prompting for Username and password to establish the session
    - Prompting for MFA if required
    - Prompting for OverrideAdminDomain if connection fails to establish and retries connection attempt
		- Extending the session time-out limit beyond 60mins (SkypeOnlineConnector only!)

		Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
		The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
    Note: A separate connection to MicrosoftTeams must be established when using SkypeOnlineConnector.

    To manage Teams, Channels, etc. within Microsoft Teams, use Connect-MicrosoftTeams
		Connect-MicrosoftTeams requires a Teams Admin role and is part of the PowerShell Module MicrosoftTeams
    https://www.powershellgallery.com/packages/MicrosoftTeams

    Please note, that the session timeout is broken and does currently not work as intended
    To help reconnect sessions, Assert-SkypeOnlineConnection can be used (Alias: pol) which runs Get-CsTenant to trigger the reconnect
    This will require re-authentication and its success is dependent on the Tenant settings.
    To reconnect fully, please re-run Connect-SkypeOnline to recreate the session cleanly.
    Please note that hanging sessions can cause lockout (session exhaustion)
  .LINK
    Connect-Me
    Connect-SkypeOnline
    Connect-AzureAD
    Connect-MicrosoftTeams
    Assert-SkypeOnlineConnection
    Disconnect-Me
    Disconnect-SkypeOnline
    Disconnect-AzureAD
    Disconnect-MicrosoftTeams
  #>

  [CmdletBinding()]
  param(
    [Parameter(Helpmessage = "Sign-in address of a 'Skype for Business Legacy Administrator' (Lync Administrator)")]
    [Alias('Username')]
    [string]$AccountId,

    [Parameter(Helpmessage = "Required only if the Administrators domain is not set up to allow sign-in")]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Helpmessage = "Idle Timeout of the session in hours between 1 and 8; Default is 4")]
    [ValidateRange(1, 8)]
    [int]$IdleTimeout = 4
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    #Activate 01-FEB 2021
    #R#equires -Modules @{ ModuleName="MicrosoftTeams"; ModuleVersion="1.1.6" }

    # Required as Warnings on the OriginalRegistrarPool may halt Script execution
    $WarningPreference = "Continue"

    $Parameters = $null
    $Parameters += @{'ErrorAction' = 'STOP' }
    $Parameters += @{'WarningAction' = 'Continue' }

    #region Module Prerequisites
    # Loading modules and determining available options
    $TeamsModule, $SkypeModule = Get-NewestModule MicrosoftTeams, SkypeOnlineConnector

    if ( -not $TeamsModule -and -not $SkypeModule ) {
      Write-Verbose -Message "Module SkypeOnlineConnector not installed. Module is deprecated, but can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366"
      Write-Verbose -Message "Module MicrosoftTeams not installed. Please install v1.1.6 or higher" -Verbose
      Write-Error -Message "Module missing. Please install MicrosoftTeams or SkypeOnlineConnector" -Category ObjectNotFound -ErrorAction Stop

    }
    elseif ( $TeamsModule.Version -lt "1.1.6" -and -not $SkypeModule ) {
      try {
        Write-Verbose -Message "Module MicrosoftTeams is outdated, trying to update to v1.1.6" -Verbose
        Update-Module MicrosoftTeams -Force -ErrorAction Stop
        $TeamsModule = Get-NewestModule MicrosoftTeams
        Import-Module MicrosoftTeams -MinimumVersion 1.1.6 -Force -Global
      }
      catch {
        Write-Verbose -Message "Module MicrosoftTeams could not be updated. Please install v1.1.6 or higher" -Verbose
        Write-Error -Message "Module outdated. Please update Module MicrosoftTeams or install SkypeOnlineConnector" -Category ObjectNotFound -ErrorAction Stop
      }
    }
    elseif ( $TeamsModule.Version -ge "1.1.6" -and -not $SkypeModule ) {
      Import-Module MicrosoftTeams -Force -Global
    }
    elseif ( $SkypeModule ) {
      if ($SkypeModule.Version.Major -ne 7) {
        Write-Error -Message "Module SkypeOnlineConnector outdated. Version 7 is required. Please switch to Module MicrosoftTeams or update SkypeOnlineConnector to Version 7" -Category ObjectNotFound -ErrorAction Stop
      }
      else {
        Import-Module SkypeOnlineConnector -Force -Global
      }
    }

    # Verifying Module is loaded correctly
    if ( $TeamsModule.Version -ge "1.1.6" -and -not (Get-Module MicrosoftTeams)) {
      Write-Host "Module 'MicrosoftTeams' - import failed. Trying to import again!"
      Import-Module MicrosoftTeams -Force -Global
    }
    #endregion

    #region CsOnlineSession, CsOnlineSessionForReconnection, SessionOptions
    # Determining capabilities of New-CsOnlineSession
    $Command = "New-CsOnlineSession"
    try {
      $CsOnlineSessionCommand = Get-Command -Name $Command -ErrorAction Stop
      $CsOnlineUsername = $CsOnlineSessionCommand.Parameters.Keys.Contains('Username')

    }
    catch {
      Write-Error -Message "Command '$Command' not available. Please validate Modules MicrosoftTeams or SkypeOnlineConnector" -Category ObjectNotFound -ErrorAction Stop
    }

    $Command = "Enable-CsOnlineSessionForReconnection"
    try {
      $ReconnectionPossible = Get-Command -Name $Command -ErrorAction Stop
    }
    catch {
      Write-Verbose -Message "Command '$Command' not available. Session cannot reconnect. Please disconnect session cleanly before trying to reconnect!"
    }

    # Generating Session Options (IdleTimeout, OperationTimeout and CancelTimeout; default is 4 hours)
    $IdleTimeoutMS = (New-TimeSpan -Hours $IdleTimeout).TotalMilliseconds
    $OperationTimeout = $IdleTimeoutMS - (New-TimeSpan -Minutes 15).TotalMilliseconds
    $CancelTimeout = (New-TimeSpan -Seconds 30).TotalMilliseconds
    $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutMS -CancelTimeout $CancelTimeout -OperationTimeout $OperationTimeout
    Write-Verbose -Message "Idle Timeout for session established: $IdleTimeout hours"

    $Parameters += @{ 'SessionOption' = $SessionOption }
    #endregion

    # Existing Session
    if (Test-SkypeOnlineConnection) {
      Write-Error -Message "A valid Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again." -ErrorAction Stop
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region preparing $Parameters
    # UserName
    if ($CsOnlineUsername) {
      if ( $AccountId) {
        Write-Verbose -Message "Module SkypeOnlineConnector supports 'Username'. Using '$AccountId'" -Verbose
      }
      else {
        if (Test-AzureADConnection) {
          $AccountId = (Get-AzureADCurrentSessionInfo).Account
          Write-Verbose -Message "Module SkypeOnlineConnector supports 'Username'. Using '$AccountId' (connected to AzureAd)" -Verbose
        }
        else {
          Write-Verbose -Message "Module SkypeOnlineConnector supports 'Username'. Please provide Username" -Verbose
          $AccountId = Read-Host "Enter the sign-in address of a Skype for Business Admin"
        }
      }
      $Parameters += @{ 'Username' = $AccountId }
    }
    else {
      if ($AccountId) {
        Write-Verbose -Message "Module SkypeOnlineConnector does not support 'Username'. To be able to support MFA, it will not be passed as a Credential. Please select Account manually" -Verbose
      }
    }

    # OverrideAdminDomain
    if ( $OverrideAdminDomain) {
      Write-Verbose -Message "OverrideAdminDomain provided. Used: $OverrideAdminDomain"
      $Parameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }

    }
    elseif ( $AccountId ) {
      $OverrideAdminDomain = $AccountId.Split('@')[1]
      Write-Verbose -Message "OverrideAdminDomain taken from Username. Used: $OverrideAdminDomain"
      $Parameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }
    }
    else {
      Write-Verbose -Message "OverrideAdminDomain not used!"
    }
    #endregion

    # Creating Session
    if ($PSBoundParameters.ContainsKey("Debug")) {
      "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

    try {
      Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
      $SkypeOnlineSession = New-CsOnlineSession @Parameters
    }
    catch [System.Net.WebException] {
      try {
        Write-Warning -Message "Session could not be created. Maybe missing OverrideAdminDomain to connect?"
        $Domain = Read-Host "Please enter an OverrideAdminDomain for this Tenant"
        if ( $Parameters.OverrideAdminDomain ) {
          $Parameters.OverrideAdminDomain = $Domain
        }
        else {
          $Parameters += @{'OverrideAdminDomain' = $Domain }
        }

        # Creating Session (again)
        Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
        $SkypeOnlineSession = New-CsOnlineSession @Parameters
      }
      catch {
        #TODO Catch "not allowed for PIM!"
        #CHECK Change error to THROW with custom Exception? Or just catch as is in Connect-Me? (Need 'not allowed' this for PIM activation!)
        Write-Error -Message "Session creation failed: $($_.Exception.Message)" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
      }
    }
    catch {
      #CHECK Change error to THROW with custom Exception? Or just catch as is in Connect-Me? (Need 'not allowed' this for PIM activation!)
      Write-Error -Message "Session creation failed: $($_.Exception.Message)" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
    }

    if ( $SkypeOnlineSession ) {
      try {
        Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
        if ( $ReconnectionPossible ) {
          $null = Enable-CsOnlineSessionForReconnection
          Write-Verbose -Message "Session is enabled for reconnection, allowing it to be re-used! (Use 'PoL' or Get-TeamsTenant to reconnect) - Note: This setting depends on the Tenants Security settings" -Verbose
        }
        else {
          Write-Verbose -Message "Session cannot be enabled for reconnection. Please disconnect cleanly before connecting anew" -Verbose
        }
      }
      catch {
        Write-Verbose -Message "Session import failed - Error for troubleshooting: $($_.Exception.Message)" -Verbose
      }

      $PSSkypeOnlineSession = Get-PSSession | Where-Object { ($_.ComputerName -like "*.online.lync.com" -or $_.Computername -eq "api.interfaces.records.teams.microsoft.com") -and $_.State -eq "Opened" -and $_.Availability -eq "Available" } -WarningAction STOP -ErrorAction STOP
      $TenantInformation = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction STOP
      $TenantDomain = $TenantInformation.Domains | Select-Object -Last 1
      $Timeout = New-TimeSpan -Hours $($PSSkypeOnlineSession.IdleTimeout / 3600000)
      $Environment = $PSSkypeOnlineSession.Name.split('_')[0]
      if (-not $Environment) {
        $Environment = 'SfBPowerShellSession'
      }

    }

    $PSSkypeOnlineSessionInfo = [PSCustomObject][ordered]@{
      Account                   = $AccountId
      Environment               = $Environment
      Tenant                    = $TenantInformation.DisplayName
      TenantId                  = $TenantInformation.TenantId
      TenantDomain              = $TenantDomain
      ComputerName              = $PSSkypeOnlineSession.ComputerName
      IdleTimeout               = $Timeout
      TeamsUpgradeEffectiveMode = $TenantInformation.TeamsUpgradeEffectiveMode
    }

    return $PSSkypeOnlineSessionInfo

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Connect-SkypeOnline
