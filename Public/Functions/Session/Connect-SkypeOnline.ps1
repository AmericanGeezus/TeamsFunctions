# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




function Connect-SkypeOnline {
  <#
	.SYNOPSIS
		Creates a remote PowerShell session to Skype for Business Online and Teams
	.DESCRIPTION
		Connecting to a remote PowerShell session to Skype for Business Online requires several components
		and steps. This function consolidates those activities by
		- verifying the SkypeOnlineConnector is installed and imported
    - prompting for Username and password (once) to establish the session
    - prompting for MFA if required (once)
    - prompting for OverrideAdminDomain if connection fails to establish and retries connection attempt
		- extending the session time-out limit beyond 60mins (SkypeOnlineConnector v7 or higher only!)
    A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect
    To execute commands against Teams, one of the Teams Admin roles is required.
	.PARAMETER Username
		Optional String. The Username or sign-in address to use when making the remote PowerShell session connection.
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
	.PARAMETER IdleTimeout
		Optional. Defines the IdleTimeout of the session in full hours between 1 and 8. Default is 4 hrs.
		Note, by default, creating a session with New-CsOnlineSession results in a Timeout of 15mins!
	.EXAMPLE
		Connect-SkypeOnline
    Example 1 will prompt for the Username and password of an administrator with permissions to connect to Skype for Business Online.
    Additional prompts for Multi Factor Authentication are displayed as required
	.EXAMPLE
		Connect-SkypeOnline -Username admin@contoso.com
		Example 2 will pre-fill the authentication prompt with admin@contoso.com and only ask for the password for the account to connect out to Skype for Business Online.
    Additional prompts for Multi Factor Authentication are displayed as required
	.NOTES
		Requires that the Skype Online Connector PowerShell module be installed.
		If the PowerShell Module SkypeOnlineConnector is v7 or higher, the Session TimeOut of 60min can be circumvented.
		Enable-CsOnlineSessionForReconnection is run.
		Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
		The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
		To manage Teams, Channels, etc. within Microsoft Teams, use Connect-MicrosoftTeams
		Connect-MicrosoftTeams requires a Teams Admin role and is part of the PowerShell Module MicrosoftTeams
    https://www.powershellgallery.com/packages/MicrosoftTeams
    Please note, that the session timeout is broken and does currently not work as intended
    To help reconnect sessions, Assert-SkypeOnlineConnection can be used (Alias: pol) which runs Get-CsTenant to trigger the reconnect
    This will require additional authentication.
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
    [Parameter()]
    [string]$Username,

    [Parameter()]
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

    # Generating Session Options (Timeout) based on input
    $IdleTimeoutInMS = $IdleTimeout * 3600000
    if ($PSBoundParameters.ContainsKey('IdleTimeout')) {
      $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutInMS
    }
    else {
      $SessionOption = New-PSSessionOption -IdleTimeout 14400000
    }
    $Parameters += @{ 'SessionOption' = $SessionOption }
    Write-Verbose -Message "Idle Timeout for session established: $IdleTimeout hours"

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
      if ( $Username) {
        Write-Verbose -Message "Module SkypeOnlineConnector supports 'Username'. Using '$Username'" -Verbose
      }
      else {
        Write-Verbose -Message "Module SkypeOnlineConnector supports 'Username'. Please provide Username" -Verbose
        $Username = Read-Host "Enter the sign-in address of a Skype for Business Admin"
      }
      $Parameters += @{ 'Username' = $Username }
    }
    else {
      if ($Username) {
        Write-Verbose -Message "Module SkypeOnlineConnector does not support 'Username'. To be able to support MFA, it will not be passed as a Credential. Please select Account manually" -Verbose
      }
    }

    # OverrideAdminDomain
    if ( $OverrideAdminDomain) {
      Write-Verbose -Message "OverrideAdminDomain provided. Used: $OverrideAdminDomain"
      $Parameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }

    }
    elseif ( $Username ) {
      $OverrideAdminDomain = $Username.Split('@')[1]
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

    }

    <##############
    # Testing existing Module and Connection
    $moduleVersion = (Get-Module -Name SkypeOnlineConnector -WarningAction SilentlyContinue).Version
    Write-Verbose -Message "Module SkypeOnlineConnector installed in Version: $moduleVersion"
    if ($moduleVersion.Major -le "6") {
      # Version 6 and lower do not support MFA authentication for Skype Module PowerShell; also allows use of older PSCredential objects
      try {
        $SkypeOnlineSession = New-CsOnlineSession -Credential (Get-Credential $Username -Message "Enter the sign-in address and password of a Global or Skype for Business Admin") -ErrorAction STOP
        Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
      }
      catch {
        $errorMessage = $_
        if ($errorMessage -like "*Making sure that you have used the correct user name and password*") {
          Write-Warning -Message "Logon failed. Please try again and make sure that you have used the correct user name and password."
        }
        elseif ($errorMessage -like "*Please create a new credential object*") {
          Write-Warning -Message "Logon failed. This may be due to multi-factor being enabled for the user account and not using the latest Skype for Business Online PowerShell module."
        }
        else {
          Write-Warning -Message $_
        }
      }
    }
    else {
      # This should be all newer version than 6; does not support PSCredential objects but supports MFA
      try {
        # Constructing Parameters to be passed to New-CsOnlineSession
        Write-Verbose -Message "Constructing parameter list to be passed on to New-CsOnlineSession"
        $Parameters = $null
        if ($PSBoundParameters.ContainsKey("Username")) {
          #TODO Check whether New-CsOnlineSession has a Parameter called Username. What to do if not!
          Write-Verbose -Message "Adding: Username: $Username"
          $Parameters += @{'Username' = $Username }
        }
        if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
          Write-Verbose -Message "OverrideAdminDomain: Provided: $OverrideAdminDomain"
          $Parameters += @{'OverrideAdminDomain' = $OverrideAdminDomain }
        }
        else {
          $UsernameDomain = $Username.Split('@')[1]
          $Parameters += @{'OverrideAdminDomain' = $UsernameDomain }

        }
        Write-Verbose -Message "Adding: SessionOption with IdleTimeout $IdleTimeout (hrs)"
        $Parameters += @{'SessionOption' = $SessionOption }
        Write-Verbose -Message "Adding: Common Parameters"
        $Parameters += @{'ErrorAction' = 'STOP' }
        $Parameters += @{'WarningAction' = 'Continue' }

        # Creating Session
        Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
        $SkypeOnlineSession = New-CsOnlineSession @Parameters
      }
      catch [System.Net.WebException] {
        try {
          Write-Warning -Message "Session could not be created. Maybe missing OverrideAdminDomain to connect?"
          $Domain = Read-Host "Please enter an OverrideAdminDomain for this Tenant"
          # $Parameters +=@{'OverrideAdminDomain' = $Domain} # This works only if no OverrideAdminDomain is yet in the $Parameters Array. Current config means it will be there!
          $Parameters.OverrideAdminDomain = $Domain
          # Creating Session (again)
          Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
          $SkypeOnlineSession = New-CsOnlineSession @Parameters
        }
        catch {
          Write-Error -Message "Session creation failed: $($_.Exception.Message)" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
        }
      }
      catch {
        Write-Error -Message "Session creation failed: $($_.Exception.Message)" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Management Role activation"
      }

      # Separated session creation from Import for better troubleshooting
      if ($Null -ne $SkypeOnlineSession) {
        try {
          Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
          $null = Enable-CsOnlineSessionForReconnection
        }
        catch {
          Write-Verbose -Message "Session import failed - Error for troubleshooting" -Verbose
          Write-Debug $_
        }

        #region For v7 and higher: run Enable-CsOnlineSessionForReconnection
        if (Test-SkypeOnlineConnection) {
          $moduleVersion = (Get-Module -Name SkypeOnlineConnector -WarningAction SilentlyContinue).Version
          Write-Verbose -Message "SkypeOnlineConnector Module is installed in Version $ModuleVersion" -Verbose
          Write-Verbose -Message "Your Session will time out after $IdleTimeout hours" -Verbose
          if ($moduleVersion.Major -ge "7") {
            # v7 and higher can run Session Limit Extension
            try {
              Enable-CsOnlineSessionForReconnection -WarningAction SilentlyContinue -ErrorAction STOP
              Write-Verbose -Message "Enable-CsOnlineSessionForReconnection was run; The session should reconnect, allowing it to be re-used without having to launch a new instance to reconnect." -Verbose
            }
            catch {
              Write-Verbose -Message "Enable-CsOnlineSessionForReconnection was run, but failed." -Verbose
              Write-Debug $_
            }
          }
          else {
            Write-Verbose -Message "Enable-CsOnlineSessionForReconnection is unavailable; To prevent having to re-authenticate, Update this module to v7 or higher" -Verbose
            Write-Verbose -Message "You can download the Module here: https://www.microsoft.com/download/details.aspx?id=39366" -Verbose
          }
        }
        #endregion
      }
      #>

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Connect-SkypeOnline
