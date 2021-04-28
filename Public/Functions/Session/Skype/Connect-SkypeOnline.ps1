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
    If a Session to AzureAd exists, the TenantDomain will be used as the OverrideAdminDomain. Please see notes for details
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
    now deprecated and no longer actively supported. This CmdLet uses the Command from the Module MicrosoftTeams,
    which always establishes a connection to both Teams and SkypeOnline!

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
    AccountId John@domain.com -
    If a Session to AzureAd is already established, the TenantDomain from Get-AzureAdCurrentSessionInfo is used.
    If no Session to AzureAd exists, 'Domain.com' is tried first as the OverrideAdminDomain
    If unsuccessful, 'domain.onmicrosoft.com' is tried.
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
    Show-FunctionStatus -Level Live
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
    $Parameters += @{ 'ErrorAction' = 'Stop' }
    $Parameters += @{ 'WarningAction' = 'Continue' }

<#  Disabled as handled by Connect-Me
    # Module Prerequisites
    Write-Verbose -Message "Importing Module 'MicrosoftTeams'"
    $SaveVerbosePreference = $global:VerbosePreference;
    $global:VerbosePreference = 'SilentlyContinue';
    Remove-Module SkypeOnlineConnector -Verbose:$false -ErrorAction SilentlyContinue
    Import-Module MicrosoftTeams -MaximumVersion 1.1.11 -Global -Force -Verbose:$false
    $global:VerbosePreference = $SaveVerbosePreference
#>

    # Validating existing Connection to AzureAd
    $AzureAdConnection = Test-AzureADConnection
    if ($AzureAdConnection) {
      $AzureSessionInfo = Get-AzureADCurrentSessionInfo
      $TenantDomain = $AzureSessionInfo.TenantDomain
      if ( $AzureSessionInfo.Account ) {
        if ( $AccountId -ne $AzureSessionInfo.Account ) {
          Write-Warning "$($MyInvocation.MyCommand) - AzureAd: Connected with '$($AzureSessionInfo.Account)'. - '$AccountId' is ignored"
          $AccountId = $AzureSessionInfo.Account
        }
        else {
          Write-Information "$($MyInvocation.MyCommand) - AzureAd: Connected with '$($AzureSessionInfo.Account)'"
          $AccountId = $AzureSessionInfo.Account
        }
      }
      else {
        Write-Information "$($MyInvocation.MyCommand) - AzureAd: Not Connected"
        $AccountId = ""
      }

      # Existing Session
      if (Test-SkypeOnlineConnection) {
        Write-Warning -Message "$($MyInvocation.MyCommand) - A valid Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again."
        break
      }
      else {
      }
    }
    <# Disabled as handled by Connect-Me now
    elseif (Test-SkypeOnlineConnection) {
      # Cleanup of global Variables set
      Write-Verbose -Message 'Cleaning up Global Variables'
      Remove-TeamsFunctionsGlobalVariable
    }
    #>

    # OverrideAdminDomain
    if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
      Write-Information "$($MyInvocation.MyCommand) - OverrideAdminDomain provided. Using Domain '$OverrideAdminDomain'"
      $Parameters += @{ 'OverrideAdminDomain' = $OverrideAdminDomain }
    }
    else {
      if ($AzureAdConnection) {
        Write-Verbose -Message "$($MyInvocation.MyCommand) - OverrideAdminDomain from AzureAd. Using Domain '$TenantDomain'"
        $Parameters += @{ 'OverrideAdminDomain' = $TenantDomain }
      }
      else {
        Write-Information "$($MyInvocation.MyCommand) - OverrideAdminDomain not used. If prompted, please provide."
      }
    }
    <#CHECK Applying any session Options will result in 15mins timeouts - able to reconnect, but still, not good.
    # Generating Session Options (IdleTimeout, OperationTimeout and CancelTimeout; default is 4 hours)
    $IdleTimeoutMS = (New-TimeSpan -Hours $IdleTimeout).TotalMilliseconds
    $CancelTimeout = (New-TimeSpan -Seconds 30).TotalMilliseconds
    $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutMS -CancelTimeout $CancelTimeout -OperationTimeout $IdleTimeoutMS
    Write-Information "$($MyInvocation.MyCommand) - Session Options: Idle Timeout set to: $IdleTimeout hours"
    if ($PSBoundParameters.ContainsKey('Debug')) {
      "Function: $($MyInvocation.MyCommand.Name): Session Options:", ($SessionOption | Format-List | Out-String).Trim() | Write-Debug
    }
    $Parameters += @{ 'SessionOption' = $SessionOption }
    #>
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    # Creating Session
    try {
      # Debug information on Parameters
      if ($PSBoundParameters.ContainsKey('Debug')) {
        "Function: $($MyInvocation.MyCommand.Name): Connection `#1: Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
      Write-Host 'INFORMATION: AccountId cannot be pre-selected - Please select Account manually!' -ForegroundColor Magenta
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
          $Parameters += @{ 'OverrideAdminDomain' = $Domain }
        }
        # Creating Session (again)
        # Debug information on Parameters
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name): Connection `#2: Parameters:", ($Parameters | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
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
        Write-Verbose -Message 'Importing temporary Module from Import-PSSession'
        Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global -Verbose:$false
        $null = Enable-CsOnlineSessionForReconnection
        Write-Information "$($MyInvocation.MyCommand) - Session is enabled for reconnection! You are prompted to reconnect, if possible."
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
