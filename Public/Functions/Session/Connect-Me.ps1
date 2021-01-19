# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Connect-Me {
  <#
	.SYNOPSIS
		Connect to AzureAd, Teams and SkypeOnline and optionally also to Exchange
	.DESCRIPTION
		One function to connect them all.
    This function solves the requirement for individual authentication prompts for
    AzureAD and MicrosoftTeams, SkypeOnline (and optionally also to ExchangeOnline) when multiple connections are required.
		For AzureAD, no particular role is needed as GET-commands are available without a role.
		For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Service Administrator or Teams Communication Admin)
		For SkypeOnline, the Skype for Business Legacy Administrator Roles is required
		Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
		Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
    By default SkypeOnline and AzureAD are selected (without parameters).
    Combine as desired, if Parameters are specified, only connections to these services are established.
    Available: AzureAD, MicrosoftTeams, SkypeOnline and ExchangeOnline
    Without parameters, connections are established to AzureAd and SkypeOnline/MicrosoftTeams
	.PARAMETER AccountId
		Required. UserPrincipalName or LoginName of the Office365 Administrator
	.PARAMETER AzureAD
		Optional. Connects to Azure Active Directory (AAD). Requires no Office 365 Admin roles (Read-only access to AzureAD)
	.PARAMETER MicrosoftTeams
		Optional. Connects to MicrosoftTeams. Requires Office 365 Admin role for Teams, e.g. Microsoft Teams Service Administrator
	.PARAMETER SkypeOnline
		Optional. Connects to SkypeOnline. Requires Office 365 Admin role Skype for Business Legacy Administrator
	.PARAMETER ExchangeOnline
		Optional. Connects to Exchange Online Management. Requires Exchange Admin Role
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
    NOTE: The OverrideAdminDomain is handled by Connect-SkypeOnline (prompts if no connection can be established)
    Using the Parameter here is using it explicitly
	.PARAMETER NoFeedback
		Optional. Suppresses output session information about established sessions. Used for calls by other functions
	.EXAMPLE
		Connect-Me admin@domain.com
    Connects to AzureAD and Teams (SkypeOnline) prompting ONCE for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -SkypeOnline -AzureAD -MicrosoftTeams
		Connects to AzureAD and Teams (SkypeOnline) & MicrosoftTeams prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -SkypeOnline -ExchangeOnline
    Connects to Teams (SkypeOnline) and ExchangeOnline prompting ONCE for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -SkypeOnline -OverrideAdminDomain domain.co.uk
    Connects to Teams (SkypeOnline) prompting ONCE for a Password for 'admin@domain.com' using the explicit OverrideAdminDomain domain.co.uk
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
  .FUNCTIONALITY
    Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  .NOTES
    The base command (without any )
  .EXTERNALHELP
    https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml
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
    Disconnect-Me
	.LINK
    Disconnect-SkypeOnline
	.LINK
    Disconnect-AzureAD
	.LINK
    Disconnect-MicrosoftTeams
	#>

  [CmdletBinding()]
  [Alias('con')]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
    [Alias('Username')]
    [string]$AccountId,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to Azure AD. Reuses credentials if authenticated already.')]
    [Alias('AAD')]
    [switch]$AzureAD,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to MicrosoftTeams. Reuses credentials if authenticated already.')]
    [Alias('Teams')]
    [switch]$MicrosoftTeams,

    [Parameter(Mandatory = $false, HelpMessage = 'Establishes a connection to SkypeOnline. Reuses credentials if authenticated already, otherwise prompts for credentials.')]
    [Alias('SfBO')]
    [switch]$SkypeOnline,

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

    $WarningPreference = 'Continue'

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 2


    #region Preparation
    # Cleaning up existing sessions
    $Status = 'Preparation'
    $Operation = 'Verifying Parameters'
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    $null = (Disconnect-Me -ErrorAction SilentlyContinue)

    #region Parameter validation
    # Preparing variables
    if ( $PSBoundParameters.ContainsKey('AzureAD') -or $PSBoundParameters.ContainsKey('MicrosoftTeams') -or $PSBoundParameters.ContainsKey('SkypeOnline') -or $PSBoundParameters.ContainsKey('ExchangeOnline')) {
      # No parameter provided. Assuming connection to AzureAD and Skype or Teams & Skype!
      $ConnectDefault = $false
    }
    else {
      #Write-Host "No Parameters for individual Services provided. Connecting to SkypeOnline and AzureAD (default)" -ForegroundColor Cyan
      $ConnectDefault = $true
      $sMax = $sMax + 2
    }

    if ($PSBoundParameters.ContainsKey('AzureAD')) {
      $ConnectToAAD = $true
      $sMax++
    }

    if ($PSBoundParameters.ContainsKey('MicrosoftTeams')) {
      #$ConnectToTeams is set once $CsOnlineUsername is determined
      $sMax++
    }

    if ($PSBoundParameters.ContainsKey('SkypeOnline')) {
      $ConnectToSkype = $true
      $sMax++
    }

    if ($PSBoundParameters.ContainsKey('ExchangeOnline')) {
      $sMax++
    }

    if ( -not $NoFeedback ) {
      $sMax = $sMax + 3
    }
    #endregion

    #Loading Modules
    $Operation = 'Loading Modules'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation" -Verbose
    $AzureAdModule, $AzureAdPreviewModule, $TeamsModule, $SkypeModule = Get-NewestModule AzureAd, AzureAdPreview, MicrosoftTeams, SkypeOnlineConnector
    if ( $AzureAdModule -and -not $AzureAdPreviewModule ) {
      Import-Module AzureAd -Force -ErrorAction SilentlyContinue
    }
    if ( $AzureAdPreviewModule ) {
      Import-Module AzureAdPreview -Force -ErrorAction SilentlyContinue
    }

    #Determining Capabilities
    $Operation = 'Determining Capabilities'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation" -Verbose

    if ( -not $TeamsModule -and -not $SkypeModule ) {
      Write-Verbose -Message 'Module SkypeOnlineConnector not installed. Module is deprecated, but can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366'
      Write-Verbose -Message 'Module MicrosoftTeams not installed. Please install v1.1.6 or higher' -Verbose
      Write-Error -Message 'Module missing. Please install MicrosoftTeams or SkypeOnlineConnector' -Category ObjectNotFound -ErrorAction Stop
    }
    elseif ( $TeamsModule.Version -lt '1.1.6' -and -not $SkypeModule ) {
      try {
        Write-Verbose -Message 'Module MicrosoftTeams is outdated, trying to update to v1.1.6' -Verbose
        Update-Module MicrosoftTeams -Force -ErrorAction Stop
        $TeamsModule = Get-NewestModule MicrosoftTeams
        Import-Module MicrosoftTeams -MinimumVersion 1.1.6 -Force -Global
      }
      catch {
        Write-Verbose -Message 'Module MicrosoftTeams could not be updated. Please install v1.1.6 or higher' -Verbose
        Write-Error -Message 'Module outdated. Please update Module MicrosoftTeams or install SkypeOnlineConnector' -Category ObjectNotFound -ErrorAction Stop
      }
    }
    elseif ( $TeamsModule.Version -ge '1.1.6' -and -not $SkypeModule ) {
      Import-Module MicrosoftTeams -Force -Global
    }
    elseif ( $SkypeModule ) {
      if ($SkypeModule.Version.Major -ne 7) {
        Write-Error -Message 'Module SkypeOnlineConnector outdated. Version 7 is required. Please switch to Module MicrosoftTeams or update SkypeOnlineConnector to Version 7' -Category ObjectNotFound -ErrorAction Stop
      }
      else {
        Write-Warning -Message 'Module SkypeOnlineConnector is deprecated. Please switch to using MicrosoftTeams soon'
        Import-Module SkypeOnlineConnector -Force -Global
        Remove-Module MicrosoftTeams -Force -ErrorAction SilentlyContinue
      }
    }

    # Determining capabilities of New-CsOnlineSession
    $Command = 'New-CsOnlineSession'
    try {
      $CsOnlineSessionCommand = Get-Command -Name $Command -ErrorAction Stop
      $CsOnlineUsername = $CsOnlineSessionCommand.Parameters.Keys.Contains('Username')
      if ( $CsOnlineUsername ) {
        Write-Host 'Sessions are established with Module SkypeOnlineConnector: Single-Sign-on is available with Connection to Skype established first' -ForegroundColor Cyan
        $sMax++
      }
      else {
        Write-Host 'Sessions are established with Module MicrosoftTeams: Seamless Single-Sign-on is not (yet) available.' -ForegroundColor Cyan
        $ConnectToTeams = $true
      }
    }
    catch {
      Write-Error -Message "Command '$Command' not available. Please validate Modules MicrosoftTeams or SkypeOnlineConnector" -Category ObjectNotFound -ErrorAction Stop
    }

    # Privileged Identity Management
    # Determining options
    $Command = 'Get-AzureADMSPrivilegedRoleAssignment'
    try {
      $PIMavailable = Get-Command -Name $Command -ErrorAction Stop
      if ( $PIMavailable ) { $sMax++ }
    }
    catch {
      Write-Warning -Message "Command '$Command' not available. Privileged Identity Management functions cannot be executed"
      Write-Verbose -Message 'AzureAd & MicrosoftTeams: Establishing a connection will work, though only GET-commands will be able to be executed' -Verbose
      Write-Verbose -Message "SkypeOnline: Establishing a connection will fail if the 'Lync Administrator' ('Skype for Busines Legacy Administrator' in the Admin Center) role is not activated" -Verbose
    }
    #endregion

    $MeToTheO365ServiceParams = $null
    $MeToTheO365ServiceParams += @{ 'AccountId' = $AccountId }
    $MeToTheO365ServiceParams += @{ 'Service' = '' }
    $MeToTheO365ServiceParams += @{ 'ErrorAction' = 'Stop' }

    if ($PSBoundParameters.ContainsKey('Verbose')) {
      $MeToTheO365ServiceParams += @{ 'Verbose' = $true }
    }
    if ($PSBoundParameters.ContainsKey('Debug')) {
      $MeToTheO365ServiceParams += @{ 'Debug' = $true }
    }

    # Cleanup of global Variables set
    Remove-TeamsFunctionsGlobalVariable

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Connections
    $Status = 'Establishing Connection'
    if ($CsOnlineUsername) {
      #Employing old method - Connecting to Skype first, then to all other Services

      #region SkypeOnline
      if ($ConnectDefault -or $ConnectToSkype) {
        $Service = 'SkypeOnline'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        try {
          $MeToTheO365ServiceParams.Service = $Service
          if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
            $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams -OverrideAdminDomain $OverrideAdminDomain
          }
          else {
            $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
          }
        }
        catch {
          if ( -not $_.Exception.Message.Contains('does not have permission to manage this tenant') ) {
            Write-Host "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain and Session Exhaustion (2 max!). Exception: $($_.Exception.Message)" -ForegroundColor Red
          }
          else {
            if ($PIMavailable) {
              Write-Host 'User does not have permission to manage this tenant. Please activate your Admin Roles in Privileged Identity Management. Trying to activate after connecting to AzureAd' -ForegroundColor Cyan
              $RetrySkypeConnection = $true
            }
            else {
              Write-Error -Message 'User does not have permission to manage this tenant. Module AzureAdPreview is not installed. Please activate your Admin Roles in Privileged Identity Management'
            }
          }
        }
      }
      #endregion

      #region AzureAD
      if ($ConnectDefault -or $ConnectToAAD) {
        $Service = 'AzureAd'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        $MeToTheO365ServiceParams.Service = $Service
        try {
          $AzureAdFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
        }
        catch {
          Write-Error -Message "$($_.Exception.Message)"
        }

      }
      #endregion

      #region MicrosoftTeams
      if ($ConnectToTeams -or $PSBoundParameters.ContainsKey('MicrosoftTeams')) {
        $Service = 'MicrosoftTeams'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        $MeToTheO365ServiceParams.Service = $Service
        try {
          $MicrosoftTeamsFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
        }
        catch {
          Write-Error -Message "$($_.Exception.Message)"
        }
      }
      #endregion

      #region Activating Admin Roles & Re-trying connection to SkypeOnline
      if ( $PIMavailable -and $(Test-AzureAdConnection)) {
        $step++
        $Operation = 'Enabling eligible Admin Roles'
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose

        try {
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AccountId -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
        }
        catch {
          if ($_.Exception.Message.Contains('The tenant needs an AAD Premium 2 license')) {
            Write-Verbose -Message 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM' -Verbose
          }
          else {
            Write-Error -Message "$_"
          }
          $PIMavailable = $false
        }

        if ( -not (Test-SkypeOnlineConnection)) {
          #retrying connection
          if ($ActivatedRoles) {
            Write-Host "Enable-AzureAdAdminrole - $($ActivatedRoles.Count) Roles activated. Retrying connection to SkypeOnline now." -ForegroundColor Cyan
            if ($RetrySkypeConnection) {
              $Service = 'SkypeOnline'
              $step++
              $Operation = 'SkypeOnline - Retrying Connection'
              Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
              Write-Verbose -Message "$Status - $Operation" -Verbose

              try {
                $MeToTheO365ServiceParams.Service = $Service
                if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
                  $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams -OverrideAdminDomain $OverrideAdminDomain
                }
                else {
                  $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
                }
              }
              catch {
                Write-Host "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain and Session Exhaustion (2 max!). Exception: $($_.Exception.Message)" -ForegroundColor Red
              }
            }
          }
          else {
            Write-Host "Could not enable Admin Roles and therefore not establish Connection to SkypeOnline, please enable them manually and try again. Exception: $($_.Exception.Message)" -ForegroundColor Red
          }
        }
      }
      else {
        Write-Verbose -Message 'Module AzureAdPreview not installed. Privileged Identity Management functions not available'
      }
      #endregion

    }
    else {
      # Connecting to AzureAd first, then validating Admin Roles, then to all other Services
      #region AzureAD
      if ($ConnectDefault -or $ConnectToAAD) {
        $Service = 'AzureAd'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        $MeToTheO365ServiceParams.Service = $Service
        try {
          $AzureAdFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
        }
        catch {
          Write-Error -Message "$($_.Exception.Message)"
        }
      }
      #endregion

      #region Activating Admin Roles
      if ( $PIMavailable -and $(Test-AzureAdConnection) ) {
        $step++
        $Operation = 'Enabling eligible Admin Roles'
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        try {
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AccountId -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
          Write-Verbose "Enable-AzureAdAdminrole - $($ActivatedRoles.Count) Roles activated." -Verbose
        }
        catch {
          Write-Verbose -Message 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM' -Verbose
          $PIMavailable = $false
        }
      }
      else {
        Write-Verbose -Message 'Enable-AzureAdAdminrole - Module AzureAdPreview not installed. Privileged Identity Management functions not available'
      }
      #endregion

      #region MicrosoftTeams
      if ($ConnectToTeams -or $PSBoundParameters.ContainsKey('MicrosoftTeams')) {
        $Service = 'MicrosoftTeams'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        $MeToTheO365ServiceParams.Service = $Service
        try {
          $MicrosoftTeamsFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
        }
        catch {
          Write-Error -Message "$($_.Exception.Message)"
        }
      }
      #endregion

      #region SkypeOnline
      if ($ConnectDefault -or $ConnectToSkype) {
        $Service = 'SkypeOnline'
        $step++
        $Operation = $Service
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose

        try {
          #This should work without the Username even!
          $MeToTheO365ServiceParams.Service = $Service
          if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
            $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams -OverrideAdminDomain $OverrideAdminDomain
          }
          else {
            $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
          }
        }
        catch {
          if ( -not $_.Exception.Message.Contains('does not have permission to manage this tenant') ) {
            Write-Host "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain and Session Exhaustion (2 max!). Exception: $($_.Exception.Message)" -ForegroundColor Red
          }
          else {
            Write-Host 'User does not have permission to manage this tenant. Please activate your Admin Roles in Privileged Identity Management' -ForegroundColor Red
            Write-Verbose 'With a connection to AzureAd and the AzureAdPreview Module, Enable-AzureAdAdminRole can help. Otherwise please use the Azure Ad Admin Center' -Verbose
          }
        }
      }
      #endregion

    }

    #region ExchangeOnline
    if ($PSBoundParameters.ContainsKey('ExchangeOnline')) {
      $Service = 'ExchangeOnlineManagement'
      $step++
      $Operation = $Service
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation" -Verbose
      try {
        $ExchangeOnlineFeedback = (Connect-MeToTheO365Service -AccountId $AccountId -Service $Service -ErrorAction STOP)
      }
      catch {
        Write-Error -Message "$($_.Exception.Message)"
      }
    }
    #endregion
    #endregion


    #region Feedback
    if ( -not $NoFeedback ) {
      $Status = 'Providing Feedback'
      $step++
      $Operation = 'Querying information about established sessions'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation" -Verbose

      # Preparing Output Object
      $SessionInfo = [PSCustomObject][ordered]@{
        Account          = $AccountId
        AdminRoles       = $ActivatedRoles.RoleName -join ', '
        Tenant           = ''
        TenantDomain     = ''
        TenantId         = ''
        ConnectedTo      = [System.Collections.ArrayList]@()
        AzureEnvironment = ''
        SkypeEnvironment = ''
      }

      #AzureAd SessionInfo
      if ( Test-AzureADConnection ) {
        $SessionInfo.ConnectedTo += 'AzureAd'
        $AzureAdFeedback = Get-AzureADCurrentSessionInfo

        $SessionInfo.Tenant = $AccountId.split('@')[1]
        $SessionInfo.TenantDomain = $AzureAdFeedback.TenantDomain
        $SessionInfo.TenantId = $AzureAdFeedback.TenantId
        $SessionInfo.AzureEnvironment = $AzureAdFeedback.Environment
      }

      #MicrosoftTeams SessionInfo
      if ( Test-MicrosoftTeamsConnection ) {
        $SessionInfo.ConnectedTo += 'MicrosoftTeams'
        $SessionInfo.Tenant = $MicrosoftTeamsFeedback.Tenant
        $SessionInfo.TenantId = $MicrosoftTeamsFeedback.TenantId
      }

      #SkypeOnline SessionInfo
      if ( Test-SkypeOnlineConnection ) {
        $SessionInfo.ConnectedTo += 'SkypeOnline'

        if ( -not $SessionInfo.TenantDomain ) {
          $SessionInfo.TenantDomain = $SkypeOnlineFeedback.TenantDomain
        }
        $SessionInfo.Tenant = $SkypeOnlineFeedback.Tenant
        $SessionInfo.TenantId = $SkypeOnlineFeedback.TenantId
        $SessionInfo.SkypeEnvironment = $SkypeOnlineFeedback.Environment
        $SessionInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $SkypeOnlineFeedback.ComputerName
        $SessionInfo | Add-Member -MemberType NoteProperty -Name TeamsUpgradeEffectiveMode -Value $SkypeOnlineFeedback.TeamsUpgradeEffectiveMode
      }

      #Exchange SessionInfo
      if ( Test-ExchangeOnlineConnection ) {
        $SessionInfo.ConnectedTo += 'ExchangeOnline'
        #What to add?
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name): ExchangeOnlineFeedback:", ($ExchangeOnlineFeedback | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
        }
      }


      #Querying Admin Roles
      if ( -not $SessionInfo.AdminRoles ) {
        #AdminRoles is already populated if they have been activated with PIM (though only with eligible ones) this overwrites the previous set of roles
        $step++
        $Operation = 'Querying assigned Admin Roles'
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose

        if ( Test-AzureADConnection) {
          if ( $AzureAdPreviewModule ) {
            $Roles = $(Get-AzureAdAdminRole (Get-AzureADCurrentSessionInfo).Account).RoleName -join ', '
          }
          else {
            $Roles = $(Get-AzureAdAssignedAdminRoles (Get-AzureADCurrentSessionInfo).Account).DisplayName -join ', '

          }
          $SessionInfo.AdminRoles = $Roles
        }
      }

      #Output
      Write-Output $SessionInfo


      Write-Host "$(Get-Date -Format 'dd MMM yyyy HH:mm') | Ready" -ForegroundColor Green
      Get-RandomQuote
    }

    Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Connect-Me
