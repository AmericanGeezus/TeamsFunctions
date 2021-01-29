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
    The OverrideAdminDomain is queried from the AzureAd Tenant once the connection has been established.
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
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 6

    #region Preparation
    # Cleaning up existing sessions
    $Status = 'Preparation'
    $Operation = 'Verifying Parameters'
    Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
    Write-Verbose -Message "$Status - $Operation"

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
    Write-Verbose -Message "$Status - $Operation"
    $AzureAdModule, $AzureAdPreviewModule, $TeamsModule, $SkypeModule = Get-NewestModule AzureAd, AzureAdPreview, MicrosoftTeams, SkypeOnlineConnector
    if ( $SkypeModule ) {
      Write-Warning -Message "Module 'SkypeOnlineConnector' detected. This module is deprecated and no longer required. If it remains on the system, it may interfere in execution of Connection Commands. Removing Module from Session - Please uninstall SkypeOnlineConnector (MSI)!"
      Remove-Module SkypeOnlineConnector -Verbose:$false -ErrorAction SilentlyContinue
    }
    Import-Module MicrosoftTeams -Global -Force -Verbose:$false

    if ( $AzureAdPreviewModule -and -not (Assert-Module AzureAdPreview )) {
      if ( -not (Assert-Module AzureAd) ) {
        throw 'Error importing Module: Neither AzureAd nor AzureAdPreview are available'
      }
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
    #$ConnectionOrder = @('AzureAd', 'MicrosoftTeams', 'SkypeOnline')
    $ConnectionOrder = @('AzureAd', 'SkypeOnline') # testing this order for more stability

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

            #region Activating Admin Roles
            if ( $PIMavailable ) {
              $step++
              $Operation = 'Enabling eligible Admin Roles'
              Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
              Write-Verbose -Message "$Status - $Operation" -Verbose
              try {
                $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AccountId -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
                Start-Sleep -Seconds 2
                Write-Verbose "Enable-AzureAdAdminrole - $($ActivatedRoles.Count) Roles activated." -Verbose
              }
              catch {
                Write-Verbose 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM' -Verbose
                $PIMavailable = $false
              }
            }
            else {
              Write-Verbose 'Enable-AzureAdAdminrole - Privileged Identity Management functions are not available'
            }
          }
          'SkypeOnline' {
            try {
              if (-not $CsOnlineUsername) {
                [void]$MeToTheO365ServiceParams.Remove('AccountId')
              }

              if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
                $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams -OverrideAdminDomain $OverrideAdminDomain
              }
              else {
                $SkypeOnlineFeedback = Connect-MeToTheO365Service @MeToTheO365ServiceParams
              }
            }
            catch {
              if ( $_.Exception.Message.Contains('does not have permission to manage this tenant') ) {
                if ( -not $_.Exception.Message.Contains("$AccountId") -and $_.Exception.Message -match "'(?<content>.*)'") {
                  Write-Error -Message "Establishing Connection to SkypeOnline failed. Connection attempted with a Username that is not authorised for this Tenant: $($matches.content) "
                  Write-Debug "This happens, if connections are established to different tenants and a session token is from the previous connection is still lingering in the session. This is a bug in the 'New-CsOnlineSession' CmdLet (The Session token from a previous session is not removed correctly). The only way to currently overcome this is to close your PowerShell Session and start a fresh session!" -Debug
                }
                else {
                  Write-Error -Message 'User does not have permission to manage this tenant. If Privileged Identity Management is used please validate Admin Roles being activated'
                }
              }
              else {
                Write-Error -Message "Establishing Connection to SkypeOnline failed: $($_.Exception.Message)"
                Write-Verbose -Message 'Please verify Username, Password, OverrideAdminDomain and Session Exhaustion (maximum two concurrent sessions)'
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
          Write-Information "$Status - $Operation"
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

    #region Feedback
    if ( -not $NoFeedback ) {
      $Status = 'Providing Feedback'
      $step++
      $Operation = 'Querying information about established sessions'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

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
        Write-Verbose -Message "$Status - $Operation"

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
