# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  22-JAN-2021
# Status:   Live




function Connect-SkypeOnline {
  <#
	.SYNOPSIS
		Creates a remote PowerShell session to Teams (SkypeOnline)
	.DESCRIPTION
    The Connect-SkypeOnline cmdlet connects an account to use for Microsoft Teams (SkypeOnline) cmdlet requests.
    Establishing a remote PowerShell session to Microsoft Teams (SkypeOnline)
    A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect and execute GET-commands.
    To execute other commands against Teams, a Teams Admin roles with appropriate rights is required.
	.PARAMETER AccountId
		Optional String. The Username or sign-in address to use when making the remote PowerShell session connection.
    If the AccountId is provided, the OverrideAdminDomain is constructed from the domain part of the AccountId.
    Please see Notes for a detailed example
	.PARAMETER OverrideAdminDomain
    Optional. Only required if managing multiple Tenants or Skype On-Premesis Hybrid configuration uses DNS records.
    If an AccountId is provided, the Domain is constructed from the domain part and only queried from the User if needed.
	.PARAMETER IdleTimeout
		Optional. Defines the IdleTimeout of the session in full hours between 1 and 8. Default is 4 hrs.
    By default, creating a session with New-CsOnlineSession results in a Timeout of 15mins!
    Please note that this setting could not be verified working. SessionOptions seem to be ignored by the CmdLet.
	.EXAMPLE
		Connect-SkypeOnline
    Prompt for the Username and password of an administrator with permissions to connect to Microsoft Teams (SkypeOnline).
    Additional prompts for Multi Factor Authentication are displayed as required
	.EXAMPLE
		Connect-SkypeOnline -AccountId admin@contoso.com
    When using the Module SkypeOnlineConnector, will pre-fill the authentication prompt with admin@contoso.com
    and only ask for the password for the account to connect out to Microsoft Teams (SkypeOnline).
    When using the Module MicrosoftTeams, the Username cannot be passed on and has to be entered manually.
    The OverrideAdminDomain is not provided, so it is constructed from the domain part. Please see Notes for details.
    Additional prompts for Multi Factor Authentication are displayed as required.
	.EXAMPLE
		Connect-SkypeOnline -AccountId admin@contoso.com -OverrideAdminDomain contoso.onmicrosoft.com
    When using the Module SkypeOnlineConnector, will pre-fill the authentication prompt with admin@contoso.com
    and only ask for the password for the account to connect out to Microsoft Teams (SkypeOnline).
    When using the Module MicrosoftTeams, the Username cannot be passed on and has to be entered manually.
    The provided OverrideAdminDomain will be used to establish the connection. If not provided, it is constructed.
	.NOTES
    Connection to SkypeOnline is done by creating a Session with New-CsOnlineSession, which later needs to be imported.
    A temporary Module "tmp_*" will be loaded, importing all CmdLets to administer the Teams Tenant (i.E. SkypeOnline)

    New-CsOnlineSession is available in the Module MicrosoftTeams or the MSI-Installer SkypeOnlineConnector which is
    now deprecated and no longer actively supported. When using the SkypeOnlineConnector, a separate connection
    to MicrosoftTeams must be established to also manage Teams and Channels use Connect-MicrosoftTeams to connect.
    When using the Module MicrosoftTeams, a connection is always established to both!

    Background:
    In order to retire the SkypeOnlineConnector, the CmdLet New-CsOnlineSession was ported to MicrosoftTeams (in v1.1.6)
    However, not all functionality was made available:
    The Parameter Username has been retired, resulting in seamless single-sign-on currently not being available.
    Multiple connection prompts will be displayed, but already signed-in accounts can be used (Password required only once)
    Enable-CsOnlineSessionForReconnection is not available in MicrosoftTeams either, but thanks to the original author
    Andrés Gorzelany, the command is now offered with this module and is available consistently.
    Established Sessions will now always be enabled for reconnection.
    The ability to reconnect a session depends on the settings in the Tenant. Re-Authentication may be required.

    OverrideAdminDomain Handling and Example:
    AccountId John@domain.com - Domain.com is first used as the OverrideAdminDomain
    If unsuccessful, "domain.onmicrosoft.com" is tried.
    If this too is unsuccessful, the OverrideAdminDomain is queried from the User for input.

    Session Timeout & Reconnection:
    The session timeout is currently not adhered to correctly and does not work as intended!
    It has therefore been disabled. The parameter IdleTimeout is without effect.

    To help reconnect sessions, Assert-SkypeOnlineConnection is integrated into every CmdLet in the module.
    It can be triggered manually as well, with the alias 'pol' (Ping-of-life) to trigger the reconnection.
    This will require re-authentication and its success is dependent on the Tenant settings.
    Sometimes even the reconnection fails, if so, please disconnect the current session (Disconnect-SkypeOnline) and
    re-run Connect-SkypeOnline to recreate the session cleanly.
    Please note that hanging sessions can cause lockout (session exhaustion)

    This CmdLet is preforming the following Tasks:
    - Verifying Module MicrosoftTeams or SkypeOnlineConnector are installed and imported
    - Prompting for Username and password to establish the session
    - Prompting for MFA if required
    - Prompting for OverrideAdminDomain ONLY if connection fails to establish (connection attempt is retried afterwards)
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Connect-Me
	.LINK
    Connect-SkypeOnline
	.LINK
    Connect-AzureAD
	.LINK
    Connect-MicrosoftTeams
	.LINK
    Assert-SkypeOnlineConnection
	.LINK
    Disconnect-Me
	.LINK
    Disconnect-SkypeOnline
	.LINK
    Disconnect-AzureAD
	.LINK
    Disconnect-MicrosoftTeams
  #>

  [CmdletBinding()]
  param(
    [Parameter(Helpmessage = "Sign-in address of a 'Skype for Business Legacy Administrator' (Lync Administrator)")]
    [Alias('Username')]
    [string]$AccountId,

    [Parameter(Helpmessage = 'Required only if the Administrators domain is not set up to allow sign-in')]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Helpmessage = 'Idle Timeout of the session in hours between 1 and 8; Default is 4')]
    [ValidateRange(1, 8)]
    [int]$IdleTimeout = 4
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Required as Warnings on the OriginalRegistrarPool somehow may halt Script execution
    $WarningPreference = 'Continue'
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    $Parameters = $null
    $Parameters += @{'ErrorAction' = 'Stop' }
    $Parameters += @{'WarningAction' = 'Continue' }

    #region Module Prerequisites
    # Loading modules and determining available options
    $TeamsModule, $SkypeModule = Get-NewestModule MicrosoftTeams, SkypeOnlineConnector

    if ( -not $TeamsModule -and -not $SkypeModule ) {
      Write-Verbose -Message 'Module SkypeOnlineConnector not installed. Module is deprecated, but can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366'
      Write-Information 'Module MicrosoftTeams not installed. Please install v1.1.6 or higher'
      Write-Error -Message 'Module missing. Please install MicrosoftTeams or SkypeOnlineConnector' -Category ObjectNotFound -ErrorAction Stop
    }
    elseif ( $TeamsModule.Version -lt '1.1.6' -and -not $SkypeModule ) {
      try {
        Write-Warning -Message 'Module MicrosoftTeams is outdated, trying to update to v1.1.6'
        Update-Module MicrosoftTeams -Force -ErrorAction Stop
        $TeamsModule = Get-NewestModule MicrosoftTeams
        Assert-Module MicrosoftTeams
      }
      catch {
        Write-Information 'Module MicrosoftTeams could not be updated. Please install v1.1.6 or higher'
        Write-Error -Message 'Module outdated. Please update Module MicrosoftTeams or install SkypeOnlineConnector' -Category ObjectNotFound -ErrorAction Stop
      }
    }
    elseif ( $TeamsModule.Version -ge '1.1.6' -and -not $SkypeModule ) {
      Remove-Module SkypeOnlineConnector -Verbose:$false -ErrorAction SilentlyContinue
      Assert-Module MicrosoftTeams
    }
    elseif ( $SkypeModule ) {
      if ($SkypeModule.Version.Major -ne 7) {
        Write-Error -Message 'Module SkypeOnlineConnector outdated. Version 7 is required. Please switch to Module MicrosoftTeams or update SkypeOnlineConnector to Version 7' -Category ObjectNotFound -ErrorAction Stop
      }
      else {
        Write-Warning -Message 'Module SkypeOnlineConnector is deprecated. Please switch to using MicrosoftTeams soon'
        Remove-Module MicrosoftTeams -ErrorAction SilentlyContinue -Verbose:$false
        if (-not (Get-Module SkypeOnlineConnector)) {
          Import-Module SkypeOnlineConnector -Global -Verbose:$false -ErrorAction Stop
        }
      }
    }

    # Verifying Module is loaded correctly
    if ( $TeamsModule.Version -ge '1.1.6' -and -not (Get-Module MicrosoftTeams)) {
      Write-Verbose "Module 'MicrosoftTeams' - import failed. Trying to import again (forcefully)!"
      Import-Module MicrosoftTeams -Global -Force
    }
    #endregion

    #region CsOnlineSession, CsOnlineSessionForReconnection, SessionOptions
    # Determining capabilities of New-CsOnlineSession
    $Command = 'New-CsOnlineSession'
    try {
      $CsOnlineSessionCommand = Get-Command -Name $Command -ErrorAction Stop
      $CsOnlineUsername = $CsOnlineSessionCommand.Parameters.Keys.Contains('Username')
    }
    catch {
      Write-Error -Message "Command '$Command' not available. Please validate Modules MicrosoftTeams or SkypeOnlineConnector" -Category ObjectNotFound -ErrorAction Stop
    }

    <# Generating Session Options (IdleTimeout, OperationTimeout and CancelTimeout; default is 4 hours)
    $IdleTimeoutMS = (New-TimeSpan -Hours $IdleTimeout).TotalMilliseconds
    $OperationTimeout = $IdleTimeoutMS - (New-TimeSpan -Minutes 15).TotalMilliseconds
    $CancelTimeout = (New-TimeSpan -Seconds 30).TotalMilliseconds
    $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutMS -CancelTimeout $CancelTimeout -OperationTimeout $OperationTimeout
    Write-Verbose -Message "Idle Timeout for session established: $IdleTimeout hours"

    $Parameters += @{ 'SessionOption' = $SessionOption }
    #>
    #endregion

    # Existing Session
    if (Test-SkypeOnlineConnection) {
      Write-Warning -Message "$($MyInvocation.MyCommand) - A valid Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again."
      break
    }
    else {
      # Cleanup of global Variables set
      Remove-TeamsFunctionsGlobalVariable
    }

    # Validating existing Connection to AzureAd
    $AzureAdConnection = Test-AzureADConnection
    if ($AzureAdConnection) {
      $AzureSessionInfo = Get-AzureADCurrentSessionInfo
      $AccountId = $AzureSessionInfo.Account
      $TenantDomain = $AzureSessionInfo.TenantDomain
      Write-Information "$($MyInvocation.MyCommand) - AzureAd: Connected. Using Account '$AccountId'"
    }
    else {
      if ($CsOnlineUsername) {
        if ( -not $PSBoundParameters.ContainsKey('AccountId')) {
          $AccountId = Read-Host 'Enter the sign-in address of a Skype for Business Admin'
        }
        Write-Information "$($MyInvocation.MyCommand) - AzureAd: Not connected. Using Account '$AccountId'"
      }
      else {
        if ( -not $PSBoundParameters.ContainsKey('AccountId')) {
          Write-Information "$($MyInvocation.MyCommand) - AzureAd: Not connected. Not using AccountId. Please provide when prompted!"
        }
      }
    }

    # Parameters Username and OverrideAdminDomain
    if ($CsOnlineUsername) {
      $Parameters += @{ 'Username' = $AccountId }
    }

    if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
      Write-Information "$($MyInvocation.MyCommand) - OverrideAdminDomain provided. Using Domain '$OverrideAdminDomain'"
      $Parameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }
    }
    else {
      if ($AzureAdConnection) {
        Write-Information "$($MyInvocation.MyCommand) - OverrideAdminDomain from AzureAd. Using Domain '$TenantDomain'"
        $Parameters += @{ 'OverrideAdminDomain' = $TenantDomain }
      }
      else {
        Write-Information "$($MyInvocation.MyCommand) - OverrideAdminDomain not used. If prompted, please provide."
      }
    }

    # Debug information on Parameters
    if ($PSBoundParameters.ContainsKey('Debug')) {
      "Function: $($MyInvocation.MyCommand.Name): Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Creating Session
    try {
      Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
      $SkypeOnlineSession = New-CsOnlineSession @Parameters
    }
    catch [System.Net.WebException] {
      try {
        if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
          Write-Error -Message "Session could not be created with OverrideAdminDomain '$OverrideAdminDomain'. Please verify Domain Name"
        }
        else {
          Write-Warning -Message 'Session could not be created. Maybe missing OverrideAdminDomain to connect?'
        }
        $Domain = Read-Host 'Please enter an OverrideAdminDomain for this Tenant'
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
        # Catching 403 (not allowed) and general Session error
        if ( $_.Exception.Message.Contains('not allowed to manage')) {
          throw [System.Management.Automation.SessionStateUnauthorizedAccessException]::New("Session creation failed: $($_.Exception.Message)")
        }
        else {
          throw [System.Management.Automation.SessionStateException]::New("Session creation failed: $($_.Exception.Message)")
        }
      }
    }
    catch {
      # Catching 403 (not allowed) and general Session error
      if ( $_.Exception.Message.Contains('not allowed to manage')) {
        throw [System.Management.Automation.SessionStateUnauthorizedAccessException]::New("Session creation failed: $($_.Exception.Message)")
      }
      else {
        throw [System.Management.Automation.SessionStateException]::New("Session creation failed: $($_.Exception.Message)")
      }
    }

    if ( $SkypeOnlineSession ) {
      try {
        Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global -Verbose:$false
        $null = Enable-CsOnlineSessionForReconnection
        Write-Information "$($MyInvocation.MyCommand) - Session is enabled for reconnection! You are prompted to reconnect if possible."
        Write-Verbose -Message 'The success of reconnection attempts depends on a few factors, including the Tenants Security settings' -Verbose
      }
      catch {
        Write-Error -Message "EXCEPTION: $($.Exception.Message)"
      }

      $PSSkypeOnlineSession = Get-PSSession | Where-Object { ($_.ComputerName -like '*.online.lync.com' -or $_.Computername -eq 'api.interfaces.records.teams.microsoft.com') -and $_.State -eq 'Opened' -and $_.Availability -eq 'Available' } -WarningAction STOP -ErrorAction STOP
      $TenantInformation = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction STOP
      if (-not $TenantDomain) { $TenantDomain = $TenantInformation.Domains | Select-Object -Last 1 }
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
