# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-DEC-2020
# Status:   Live

#CHECK Activation of Roles via PIM / reconnect Skype if it failed before?


function Connect-Me {
  <#
	.SYNOPSIS
		Connect to SkypeOnline and AzureActiveDirectory and optionally also to Teams and Exchange
	.DESCRIPTION
		One function to connect them all.
		This function solves the requirement for individual authentication prompts for
		SkypeOnline and AzureAD (and optionally also to MicrosoftTeams and ExchangeOnline) when multiple connections are required.
		For SkypeOnline, the Skype for Business Legacy Administrator Roles is required
		For AzureAD, no particular role is needed as GET-commands are available without a role.
		For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Service Administrator or Teams Communication Admin)
		Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
		Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
    By default SkypeOnline and AzureAD are selected (without parameters).
    Combine as desired, if Parameters are specified, only connections to these services are established.
    Available: SkypeOnline, AzureAD, MicrosoftTeams and ExchangeOnline
	.PARAMETER UserName
		Required. UserPrincipalName or LoginName of the Office365 Administrator
	.PARAMETER SkypeOnline
		Optional. Connects to SkypeOnline. Requires Office 365 Admin role Skype for Business Legacy Administrator
	.PARAMETER AzureAD
		Optional. Connects to Azure Active Directory (AAD). Requires no Office 365 Admin roles (Read-only access to AzureAD)
	.PARAMETER MicrosoftTeams
		Optional. Connects to MicrosoftTeams. Requires Office 365 Admin role for Teams, e.g. Microsoft Teams Service Administrator
	.PARAMETER ExchangeOnline
		Optional. Connects to Exchange Online Management. Requires Exchange Admin Role
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
    NOTE: The OverrideAdminDomain is handled by Connect-SkypeOnline (prompts if no connection can be established)
    Using the Parameter here is using it explicitly
	.PARAMETER Silent
		Optional. Suppresses output session information about established sessions. Used for calls by other functions
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com
		Connects to SkypeOnline & AzureAD prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -AzureAD -MicrosoftTeams
		Connects to SkypeOnline, AzureAD & MicrosoftTeams prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -ExchangeOnline
    Connects to SkypeOnline and ExchangeOnline prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -OverrideAdminDomain domain.co.uk
    Connects to SkypeOnline prompting ONCE for a Password for 'admin@domain.com' using the explicit OverrideAdminDomain domain.co.uk
  .FUNCTIONALITY
    Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  .NOTES
    The base command (without any )
  .LINK
    Connect-Me
    Connect-SkypeOnline
    Connect-AzureAD
    Connect-MicrosoftTeams
    Disconnect-Me
    Disconnect-SkypeOnline
    Disconnect-AzureAD
    Disconnect-MicrosoftTeams
	#>

  [CmdletBinding()]
  [Alias('con')]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
    [string]$UserName,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to SkypeOnline. Prompts for new credentials.')]
    [Alias('SfBO')]
    [switch]$SkypeOnline,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to Azure AD. Reuses credentials if authenticated already.')]
    [Alias('AAD')]
    [switch]$AzureAD,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to MicrosoftTeams. Reuses credentials if authenticated already.')]
    [Alias('Teams')]
    [switch]$MicrosoftTeams,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to Exchange Online. Reuses credentials if authenticated already.')]
    [Alias('Exchange')]
    [switch]$ExchangeOnline,

    [Parameter(Mandatory = $false, HelpMessage = 'Domain used to connect to for SkypeOnline if DNS points to OnPrem Skype')]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Mandatory = $false, HelpMessage = 'Suppresses Session Information output')]
    [switch]$NoFeedback

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $WarningPreference = "Continue"

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 0

    # Preparing variables
    if ($PSBoundParameters.ContainsKey('SkypeOnline') -or $PSBoundParameters.ContainsKey('AzureAD') -or $PSBoundParameters.ContainsKey('MicrosoftTeams') -or $PSBoundParameters.ContainsKey('ExchangeOnline')) {
      # No parameter provided. Assuming connection to both Skype and AzureAD!
      $ConnectDefault = $false
    }
    else {
      Write-Host "INFO:    No Parameters for individual Services provided. Connecting to SkypeOnline and AzureAD (default)" -ForegroundColor Cyan
      $ConnectDefault = $true
      $sMax = $sMax + 2
    }

    if ($PSBoundParameters.ContainsKey('SkypeOnline')) {
      $ConnectToSkype = $true
      $sMax++
    }
    if ($PSBoundParameters.ContainsKey('AzureAD')) {
      $ConnectToAAD = $true
      $sMax++
    }
    if ($PSBoundParameters.ContainsKey('MicrosoftTeams')) {
      $sMax++
    }
    if ($PSBoundParameters.ContainsKey('ExchangeOnline')) {
      $sMax++
    }
    if ( -not $NoFeedback ) {
      $sMax = $sMax + 2
    }

    [System.Collections.ArrayList]$ConnectedTo = @()

    # Cleaning up existing sessions
    $Status = "Preparation"
    $Operation = "Cleaning up existing Sessions"
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation" -Verbose
    $null = (Disconnect-Me -ErrorAction SilentlyContinue)

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Connections
    #region SkypeOnline
    if ($ConnectDefault -or $ConnectToSkype) {
      $Status = "Establishing Connection"
      $step++
      $Operation = "SkypeOnline"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status to $Operation" -Verbose
      try {
        if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
          $null = (Connect-SkypeOnline -UserName $Username -OverrideAdminDomain $OverrideAdminDomain -ErrorAction STOP)
        }
        else {
          $null = (Connect-SkypeOnline -UserName $Username -ErrorAction STOP)
        }
      }
      catch {
        Write-Host "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain, Admin Role Activation (PIM) and Session Exhaustion (2 max!)" -ForegroundColor Red
        Write-ErrorRecord $_ #This handles the error message in human readable format.
      }

      Start-Sleep 1
      if (Test-SkypeOnlineConnection) {
        $ConnectedTo += "SkypeOnline"

        if ( -not $NoFeedback) {
          $Status = "Providing Feedback"
          $step++
          $Operation = "Displaying Tenant Information"
          Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
          Write-Verbose -Message "$Status - $Operation"

          $PSSkypeOnlineSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available" } -WarningAction STOP -ErrorAction STOP
          $TenantInformation = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction STOP
          $TenantDomain = $TenantInformation.Domains | Select-Object -Last 1
          $Timeout = $PSSkypeOnlineSession.IdleTimeout / 3600000

          $PSSkypeOnlineSessionInfo = [PSCustomObject][ordered]@{
            Account                   = $UserName
            Environment               = 'SfBPowerShellSession'
            Tenant                    = $TenantInformation.DisplayName
            TenantId                  = $TenantInformation.TenantId
            TenantDomain              = $TenantDomain
            ComputerName              = $PSSkypeOnlineSession.ComputerName
            IdleTimeoutInHours        = $Timeout
            TeamsUpgradeEffectiveMode = $TenantInformation.TeamsUpgradeEffectiveMode
          }

          $PSSkypeOnlineSessionInfo
        }
      }
    }
    #endregion

    #region AzureAD
    if ($ConnectDefault -or $ConnectToAAD) {
      $Status = "Establishing Connection"
      $step++
      $Operation = "AzureAd"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status to $Operation" -Verbose
      try {
        if ( -not (Test-AzureADConnection)) {
          $ConnectedTo += "AzureAd"
          $null = (Connect-AzureAD -AccountId $Username)
          if ( -not $NoFeedback ) {
            Start-Sleep -Seconds 1
            Get-AzureADCurrentSessionInfo
          }
        }
        else {
          Write-Verbose "Already Connected to AzureAd, if reconnect is desired, please disconnect this seesion first!" -Verbose
        }
      }
      catch {
        Write-Host "Could not establish Connection to AzureAD, please verify Module and run Connect-AzureAD manually" -ForegroundColor Red
      }
    }
    #endregion


    #region MicrosoftTeams
    if ($PSBoundParameters.ContainsKey('MicrosoftTeams')) {
      $Status = "Establishing Connection"
      $step++
      $Operation = "MicrosoftTeams"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status to $Operation" -Verbose
      try {
        if ( -not (Test-Module MicrosoftTeams)) {
          Import-Module MicrosoftTeams -Force -ErrorAction SilentlyContinue
        }
        if ( -not (Test-MicrosoftTeamsConnection)) {
          if ( -not $NoFeedback ) {
            Connect-MicrosoftTeams -AccountId $Username
          }
          else {
            $null = (Connect-MicrosoftTeams -AccountId $Username)
          }
        }
        else {
          Write-Verbose "Already Connected to MicrosoftTeams, if reconnect is desired, please disconnect this seesion first!" -Verbose
        }
      }
      catch {
        Write-Host "Could not establish Connection to MicrosoftTeams, please verify Module and run Connect-MicrosoftTeams manually" -ForegroundColor Red
      }
    }

    if (Test-MicrosoftTeamsConnection) {
      $ConnectedTo += "Microsoft Teams"
    }
    #endregion

    #region ExchangeOnline
    if ($PSBoundParameters.ContainsKey('ExchangeOnline')) {
      $Status = "Establishing Connection"
      $step++
      $Operation = "ExchangeOnline"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status to $Operation" -Verbose
      try {
        if ( -not (Test-Module ExchangeOnlineManagement)) {
          Import-Module ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue
        }
        if ( -not (Test-ExchangeOnlineConnection)) {
          if ( -not $NoFeedback) {
            Connect-ExchangeOnline -UserPrincipalName $Username -ShowProgress:$true -ShowBanner:$false
          }
          else {
            $null = (Connect-ExchangeOnline -UserPrincipalName $Username -ShowProgress:$true -ShowBanner:$false)
          }
        }
        else {
          Write-Verbose "Already Connected to ExchangeOnlineManagement, if reconnect is desired, please disconnect this seesion first!" -Verbose
        }
      }
      catch {
        Write-Host "Could not establish Connection to ExchangeOnlineManagement, please verify Module and run Connect-ExchangeOnline manually" -ForegroundColor Red
      }
    }

    if (Test-ExchangeOnlineConnection) {
      $ConnectedTo += "Exchange"
    }
    #endregion
    #endregion


    #region Display Admin Roles
    if ( ("AzureAd" -in $ConnectedTo) -and -not $NoFeedback ) {
      $Status = "Providing Feedback"
      $step++
      $Operation = "Displaying assigned Admin Roles"
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"
      Write-Host "Displaying assigned Admin Roles for Account: " -ForegroundColor Magenta -NoNewline
      Write-Host "$Username"
      Get-AzureAdAssignedAdminRoles (Get-AzureADCurrentSessionInfo).Account | Select-Object DisplayName, Description | Format-Table -AutoSize
    }
    #endregion

    Write-Progress -Id 0 -Status "Complete" -Activity $MyInvocation.MyCommand -Completed

    #Output
    Write-Host "$(Get-Date -Format 'dd MMM yyyy HH:mm') | Connected to: " -ForegroundColor Green -NoNewline
    Write-Host "$ConnectedTo"

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Connect-Me
