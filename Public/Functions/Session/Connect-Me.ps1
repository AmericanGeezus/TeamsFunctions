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
    This CmdLet solves the requirement for individual authentication prompts for AzureAD, MicrosoftTeams, SkypeOnline
    (and optionally also to ExchangeOnline) when multiple connections are required.
	.PARAMETER AccountId
		Required. UserPrincipalName or LoginName of the Office365 Administrator
	.PARAMETER ExchangeOnline
		Optional. Connects to Exchange Online Management. Requires Exchange Admin Role
	.PARAMETER OverrideAdminDomain
    Optional. Only required if managing multiple Tenants or Skype On-Premesis Hybrid configuration uses DNS records.
	.PARAMETER NoFeedback
		Optional. Suppresses output session information about established sessions. Used for calls by other functions
	.EXAMPLE
		Connect-Me [-AccountId] admin@domain.com
    Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -NoFeedBack
    Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
    Does not display Session Information Object at the end - This is useful if called by other functions.
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -ExchangeOnline
    Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
    Also connects to ExchangeOnline
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -OverrideAdminDomain tenantdomain.onmicrosoft.com
    Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
    If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
    The OverrideAdminDomin is queried from the AzureAd Tenant once the connection has been established.
    If used explicitly, this will use the provided OverrideAdminDomain
  .FUNCTIONALITY
    Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  .NOTES
    This CmdLet can be used to establish a session to: AzureAD, MicrosoftTeams, SkypeOnline and ExchangeOnline
    Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
		For AzureAD, no particular role is needed for connection and query. Get-CmdLets are available without an Admin-role.
		For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Communication or Service Administrator)
		For SkypeOnline, the Skype for Business Legacy Administrator Roles is required to connect, a Teams Admin role to action.
		Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
		Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
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
    [Parameter(Mandatory, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
    [Alias('Username')]
    [string]$AccountId,

    <#
    [Parameter(HelpMessage = 'Establishes a connection to Azure AD. Reuses credentials if authenticated already.')]
    [Alias('AAD')]
    [switch]$AzureAD,

    [Parameter(HelpMessage = 'Establishes a connection to MicrosoftTeams. Reuses credentials if authenticated already.')]
    [Alias('Teams')]
    [switch]$MicrosoftTeams,

    [Parameter(HelpMessage = 'Establishes a connection to SkypeOnline. Reuses credentials if authenticated already, otherwise prompts for credentials.')]
    [Alias('SfBO')]
    [switch]$SkypeOnline,
#>
    [Parameter(HelpMessage = 'Establishes a connection to Exchange Online. Reuses credentials if authenticated already.')]
    [Alias('Exchange')]
    [switch]$ExchangeOnline,

    [Parameter(HelpMessage = 'Domain used to connect to for SkypeOnline if DNS points to OnPrem Skype')]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(HelpMessage = 'Suppresses Session Information output')]
    [switch]$NoFeedback

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Required as Warnings on the OriginalRegistrarPool somehow may halt Script execution
    $WarningPreference = 'Continue'
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 7
    #[int]$sMax = 2 # Parameters are removed, so can this.


    #region Preparation
    # Cleaning up existing sessions
    $Status = 'Preparation'
    $Operation = 'Verifying Parameters'
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"
    #Reconnection is handled within the function. No need to disconnect
    #$null = (Disconnect-Me -ErrorAction SilentlyContinue)

    #region Parameter validation
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

    # Modules
    try {
      if ( -not (Assert-Module MicrosoftTeams) ) {
        $SOCimported = Import-Module SkypeOnlineConnector -Verbose:$false -ErrorAction SilentlyContinue #-Force -Global
        if (-not $SOCimported) { throw }
      }
      if ( -not (Assert-Module AzureAdPreview) ) {
        if ( -not (Assert-Module AzureAd) ) {
          throw
        }
      }
    }
    catch {
      throw "$Service - Error importing Module: $($_.Exception.Message)"
    }

    #Determining Capabilities
    $Operation = 'Determining Capabilities'
    $step++
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation" -Verbose

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
          Import-Module SkypeOnlineConnector -Verbose:$false -ErrorAction Stop
        }
      }
    }

    # Determining capabilities of New-CsOnlineSession
    $Command = 'New-CsOnlineSession'
    try {
      $CsOnlineSessionCommand = Get-Command -Name $Command -ErrorAction Stop
      $CsOnlineUsername = $CsOnlineSessionCommand.Parameters.Keys.Contains('Username')
      if ( $CsOnlineUsername ) {
        Write-Information 'Command '$Command' - Sessions are established with Module SkypeOnlineConnector: Single-Sign-on is available with Connection to Skype established first'
      }
      else {
        Write-Information 'Command '$Command' - Sessions are established with Module MicrosoftTeams: Seamless Single-Sign-on is not (yet) available.'
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
      Write-Information "Command '$Command' not available. Privileged Identity Management role activation cannot be used. Please ensure admin roles are activated prior to running this command"
      Write-Verbose -Message 'AzureAd & MicrosoftTeams: Establishing a connection will work, though only GET-commands will be able to be executed'
      Write-Verbose -Message "SkypeOnline: Establishing a connection will fail if the 'Lync Administrator' ('Skype for Busines Legacy Administrator' in the Admin Center) role is not activated"
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

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Connections
    $Status = 'Establishing Connection'
    Write-Information "Establishing Connection to Tenant: $($($AccountId -split '@')[1])"
    if (-not $CsOnlineUsername) {
      # Employing new method - Connecting to AzureAd first, then validating Admin Roles, then to all other Services
      $ConnectionOrder = @('AzureAd', 'SkypeOnline') # , 'MicrosoftTeams')
      # Connection to MicrosoftTeams is disabled as it is established automatically with SkypeOnline
    }
    else {
      # Employing old method - Connecting to Skype first, then to all other Services
      $ConnectionOrder = @('SkypeOnline', 'AzureAd', 'MicrosoftTeams')
    }
    if ($ExchangeOnline) { $ConnectionOrder += 'ExchangeOnline' }

    foreach ($Connection in $ConnectionOrder) {
      $Service = $Connection
      $step++
      $Operation = $Service
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation" -Verbose

      $MeToTheO365ServiceParams.Service = $Service
      try {
        switch ($Connection) {
          'AzureAd' {
            $AzureAdFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
          }
          'SkypeOnline' {
            try {
              if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
                $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams -OverrideAdminDomain $OverrideAdminDomain
              }
              else {
                $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
              }
            }
            catch {
              if ( -not $_.Exception.Message.Contains('does not have permission to manage this tenant') ) {
                Write-Error -Message "Could not establish Connection to SkypeOnline, please verify Username, Password, `
                  OverrideAdminDomain and Session Exhaustion (2 max!). Exception: $($_.Exception.Message)"
              }
              else {
                if ($CsOnlineUsername -and $PIMavailable) {
                  Write-Host 'INFO: User does not have permission to manage this tenant. Connection is first established to AzureAd, then Admin Roles are tried in Privileged Identity Management.' -ForegroundColor Cyan
                  $RetrySkypeConnection = $true
                }
                else {
                  Write-Error -Message 'User does not have permission to manage this tenant. Module AzureAdPreview is not installed. Please activate your Admin Roles in Privileged Identity Management'
                }
              }
            }
          }
          'MicrosoftTeams' {
            $MicrosoftTeamsFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
          }
          'ExchangeOnline' {
            $ExchangeOnlineFeedback = Connect-MeToTheO365Service -AccountId $AccountId -Service $Service -ErrorAction Stop
          }
        }
      }
      catch {
        Write-Error -Message "$($_.Exception.Message)"
      }

      #region Activating Admin Roles
      if ( $Service = 'AzureAd' -and $(Test-AzureAdConnection) -and $PIMavailable ) {
        $step++
        $Operation = 'Enabling eligible Admin Roles'
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation" -Verbose
        try {
          $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AccountId -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
          Write-Verbose "Enable-AzureAdAdminrole - $($ActivatedRoles.Count) Roles activated." -Verbose
        }
        catch {
          Write-Information 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM'
          $PIMavailable = $false
        }
      }
      else {
        Write-Information 'Enable-AzureAdAdminrole - Module AzureAdPreview not installed. Privileged Identity Management functions not available'
      }
      #endregion
    }

    #region RetrySkypeConnection
    if ($PIMavailable -and -not (Test-SkypeOnlineConnection)) {
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
            Write-Error -Message "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain and Session Exhaustion (2 max!). Exception: $($_.Exception.Message)"
          }
        }
      }
      else {
        Write-Error -Message "Could not enable Admin Roles and therefore not establish Connection to SkypeOnline, ´
        please enable them manually and try again. Exception: $($_.Exception.Message)"
      }
    }
    #endregion


    # LEGACY New model

    <#   # Connecting to AzureAd first, then validating Admin Roles, then to all other Services
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
        Write-Information 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM'
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
    #>
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
} # Connect-Me
