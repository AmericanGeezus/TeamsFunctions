# Module:   TeamsFunctions
# Function: Session
# Author:		David Eberhardt
# Updated:  01-JAN-2021
# Status:   Live




function Connect-Me {
  <#
	.SYNOPSIS
		Connect to AzureAd, MicrosoftTeams and optionally also to Exchange
	.DESCRIPTION
		One function to connect them all.
    This CmdLet solves the requirement for individual authentication prompts for AzureAD and MicrosoftTeams
    (and optionally also to ExchangeOnline) when multiple connections are required.
	.PARAMETER AccountId
		Required. UserPrincipalName or LoginName of the Office365 Administrator
	.PARAMETER ExchangeOnline
		Optional. Connects to Exchange Online Management. Requires Exchange Admin Role
	.PARAMETER UseV1Module
		Optional. Instructs Connect-Me to use MicrosoftTeams v1.x instead of the newer v2.x
    This is a temporary measure to circumvent reported performance issues when connecting with v2 of the module.
    Please note, that since publishing v2.3.0 connections with New-CsOnlineSession may produce Warnings and errors.
    Handle with care.
	.PARAMETER NoFeedback
		Optional. Suppresses output session information about established sessions. Used for calls by other functions
	.EXAMPLE
		Connect-Me [-AccountId] admin@domain.com
    Creates a session to AzureAD prompting for a Password for 'admin@domain.com'
    If AzureAdPreview is loaded, tries to enable eligible Admin roles in Privileged Identity Management
    Creates a session to MicrosoftTeams with the AzureAd Session details
    If unsuccessful, prompting for selection of the authenticated User only (no additional authentication needed)
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -NoFeedBack
    If AzureAdPreview is loaded, tries to enable eligible Admin roles in Privileged Identity Management
    Creates a session to MicrosoftTeams with the AzureAd Session details
    If unsuccessful, prompting for selection of the authenticated User only (no additional authentication needed)
    Does not display Session Information Object at the end - This is useful if called by other functions.
	.EXAMPLE
		Connect-Me -AccountId admin@domain.com -ExchangeOnline
    If AzureAdPreview is loaded, tries to enable eligible Admin roles in Privileged Identity Management
    Creates a session to MicrosoftTeams with the AzureAd Session details
    If unsuccessful, prompting for selection of the authenticated User only (no additional authentication needed)
    Also connects to ExchangeOnline
  .INPUTS
    System.String
  .OUTPUTS
    System.Object - Default Behavior, incl. on-screen feedback about performed tasks
    System.Object - Reduced information, no on-screen output
  .NOTES
    This CmdLet can be used to establish a session to: AzureAD, MicrosoftTeams and ExchangeOnline
    Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
		For AzureAD, no particular role is needed for connection and query. Get-CmdLets are available without an Admin-role.
		For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Communication or Service Administrator)
		Module MicrosoftTeams v2.0.0 now provides the CmdLets that required a Session to SkypeOnline.
    The Skype for Business Legacy Administrator Roles are still required to create the PsSession.
		Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
		Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_TeamsSession
  .LINK
    Connect-Me
	.LINK
    Connect-AzureAD
	.LINK
    Connect-MicrosoftTeams
	.LINK
    Disconnect-Me
	.LINK
    Disconnect-AzureAD
	.LINK
    Disconnect-MicrosoftTeams
	#>

  [CmdletBinding()]
  [Alias('con')]
  param(
    [Parameter(Mandatory, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
    [Alias('UserPrincipalName', 'Username')]
    [string]$AccountId,

    [Parameter(HelpMessage = 'Establishes a connection to Exchange Online. Reuses credentials if authenticated already.')]
    [Alias('Exchange')]
    [switch]$ExchangeOnline,

    [Parameter(HelpMessage = 'Establishes a connection to MicrosoftTeams with the v1 Module.')]
    [Alias('v1')]
    [switch]$UseV1Module,

    [Parameter(HelpMessage = 'Suppresses Session Information output')]
    [switch]$NoFeedback

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    # Required as Warnings on the OriginalRegistrarPool somehow may halt Script execution
    $WarningPreference = 'Continue'
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Debug')) {
      $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference')
    }
    else {
      $DebugPreference = 'Continue'
    }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) {
      $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction')
    }
    else {
      $InformationPreference = 'Continue'
    }

    # Initialising counters for Progress bars
    [int]$step = 0
    [int]$sMax = 6

    #region Preparation
    # Preparing environment
    #Persist Stored Credentials on local machine - Value is unclear as they don't seem to be needed anymore now that New-CsOnlineSession is gone
    if (!$PSDefaultParameterValues.'Parameters:Processed') {
      $PSDefaultParameterValues.add('New-StoredCredential:Persist', 'LocalMachine')
      $PSDefaultParameterValues.add('Parameters:Processed', $true)
    }

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
      Write-Warning -Message "Module 'SkypeOnlineConnector' detected. This module is deprecated and no longer required. If it remains on the system, it could interfere in execution of Connection Commands. Removing Module from Session - Please uninstall SkypeOnlineConnector (MSI)!"
      Remove-Module SkypeOnlineConnector -Verbose:$false -Force -ErrorAction SilentlyContinue
    }
    Write-Verbose -Message "Importing Module 'MicrosoftTeams'"
    $TeamsModuleVersion = (Get-Module MicrosoftTeams).Version
    $SaveVerbosePreference = $global:VerbosePreference;
    $global:VerbosePreference = 'SilentlyContinue';
    if ( $UseV1Module -and $($TeamsModuleVersion.Major) -ge 2 ) {
      Remove-Module MicrosoftTeams -Force -Verbose:$false -ErrorAction SilentlyContinue
      try {
        Import-Module MicrosoftTeams -MaximumVersion 1.1.11 -MinimumVersion 1.1.10 -Force -Global -Verbose:$false -ErrorAction Stop
      }
      catch {
        throw 'MicrosoftTeams Module not installed in v1.1.10-preview or v1.1.11-preview!'
      }
    }
    else {
      #Import-Module MicrosoftTeams -MinimumVersion 2.0.0 -Force -Global -Verbose:$false
      if ( -not (Get-Module MicrosoftTeams) ) {
        try {
          Import-Module MicrosoftTeams -RequiredVersion 2.0.0 -Force -Global -Verbose:$false -ErrorAction Stop
        }
        catch {
          throw 'MicrosoftTeams Module not installed in v2.0.0 - Please verify Module!'
        }
      }
    }
    $global:VerbosePreference = $SaveVerbosePreference

    # Determine Module Version loaded
    if ( $($TeamsModuleVersion.Major) -lt 2 ) {
      try {
        $null = Get-Command New-CsOnlineSession -ErrorAction Stop
      }
      catch {
        throw "Command 'New-CsOnlineSession' not available. Please ensure MicrosoftTeams is installed with v1.1.10 or higher."
      }
      Write-Verbose "Module MicrosoftTeams v1 is used ('New-CsOnlineSession'). Please note, that due to recent changes by Microsoft, session connection may fail" -Verbose
    }


    if ( $AzureAdPreviewModule ) {
      Remove-Module AzureAd -Verbose:$false -ErrorAction SilentlyContinue
      Import-Module AzureAdPreview -Force -Global -Verbose:$false

      if ( -not (Assert-Module AzureAdPreview )) {
        if ( -not (Assert-Module AzureAd) ) {
          throw 'Error importing Module: Neither AzureAd nor AzureAdPreview are available'
        }
      }
    }

    # Privileged Identity Management
    # Determining options
    $Command = 'Get-AzureADMSPrivilegedRoleAssignment'
    try {
      $PIMavailable = Get-Command -Name $Command -ErrorAction Stop
      if ( $PIMavailable ) {
        $sMax++
      }
    }
    catch {
      Write-Information "Command '$Command' not available. Privileged Identity Management role activation cannot be used. Please ensure admin roles are activated prior to running this command"
      Write-Verbose -Message 'AzureAd & MicrosoftTeams: Establishing a connection will work, though only GET-commands will be able to be executed'
      Write-Verbose -Message "MicrosoftTeams: Executing SkypeOnline CmdLets requires the 'Lync Administrator' ('Skype for Busines Legacy Administrator' in the Admin Center) role is not activated"
    }
    #endregion

    # Defining Connection Parameters (baseline)
    $ConnectionParameters = $null
    $ConnectionParameters += @{ 'ErrorAction' = 'Stop' }

    if ($PSBoundParameters.ContainsKey('Verbose')) {
      $ConnectionParameters += @{ 'Verbose' = $true }
    }
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
      $ConnectionParameters += @{ 'Debug' = $true }
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"

    #region Connections
    $Status = 'Establishing Connection'
    Write-Information "Establishing Connection to Tenant: $($($AccountId -split '@')[1])"
    $ConnectionOrder = @('AzureAd')
    if ( $PIMavailable ) {
      $ConnectionOrder += 'Enabling eligible Admin Roles'
    }
    else {
      Write-Verbose 'Enable-AzureAdAdminrole - Privileged Identity Management functions are not available' -Verbose
    }
    if ($UseV1Module -and $($TeamsModuleVersion.Major) -lt 2) {
      $ConnectionOrder += 'SkypeOnline'
    }
    else {
      $ConnectionOrder += 'MicrosoftTeams'
    }
    if ($ExchangeOnline) {
      $ConnectionOrder += 'ExchangeOnline'
    }

    foreach ($Connection in $ConnectionOrder) {
      $Service = $Connection
      $step++
      $Operation = $Service
      Write-Progress -Id 0 -Status $Status -CurrentOperation "$Operation - Please see Authentication dialog" -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation" #-Verbose

      try {
        switch ($Connection) {
          'AzureAd' {
            $AzureAdParameters = $ConnectionParameters
            $AzureAdParameters += @{ 'AccountId' = $AccountId }
            $AzureAdFeedback = Connect-AzureAD @AzureAdParameters
          }
          'Enabling eligible Admin Roles' {
            try {
              $ActivatedRoles = Enable-AzureAdAdminRole -Identity $AccountId -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
              if ( $ActivatedRoles.Count -gt 0 ) {
                Write-Verbose "Enable-AzureAdAdminrole - $($ActivatedRoles.Count) Roles activated. Waiting for AzureAd to propagate (8s)" -Verbose
                Start-Sleep -Seconds 8
              }
            }
            catch {
              if ($_.Exception.Message -contains 'The following policy rules failed: ["MfaRule"') {
                Write-Warning 'Enable-AzureAdAdminrole - No valid authentication via MFA is present. Please authenticate again and retry'
              }
              else {
                Write-Verbose 'Enable-AzureAdAdminrole - Tenant is not enabled for PIM' -Verbose
              }
              $PIMavailable = $false
            }
          }
          'SkypeOnline' {
            $SkypeOnlineParameters = $ConnectionParameters
            $SkypeOnlineParameters += @{ 'AccountId' = $AccountId }
            try {
              try {
                if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
                  $TeamsConnection = Connect-SkypeOnline @SkypeOnlineParameters -OverrideAdminDomain $OverrideAdminDomain
                }
                else {
                  $TeamsConnection = Connect-SkypeOnline @SkypeOnlineParameters
                }
              }
              catch {
                Write-Verbose -Message "$Status - $Operation - Try `#2 - Please confirm Account" -Verbose
                $TeamsConnection = Connect-SkypeOnline -ErrorAction Stop
              }
              if (-not (Use-MicrosoftTeamsConnection) -and $TeamsConnection) {
                # order is important here!
                throw 'SkypeOnline - Connection to SkypeOnline not able to establish. Please run Connect-SkypeOnline manually'
              }
            }
            catch {
              if ( $_.Exception.Message.Contains('does not have permission to manage this tenant') -or $_.Exception.Message.Contains('403')) {
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
            $MicrosoftTeamsParameters = $ConnectionParameters
            $MicrosoftTeamsParameters += @{ 'AccountId' = $AccountId }
            if ($AzureAdFeedback) {
              $MicrosoftTeamsParameters += @{ 'TenantId' = $AzureAdFeedback.TenantId }
            }
            try {
              $TeamsConnection = Connect-MicrosoftTeams @MicrosoftTeamsParameters
            }
            catch {
              Write-Verbose -Message "$Status - $Operation - Try `#2 - Please confirm Account" -Verbose
              if ($AzureAdFeedback) {
                $TeamsConnection = Connect-MicrosoftTeams -TenantId $AzureAdFeedback.TenantId
              }
              else {
                $TeamsConnection = Connect-MicrosoftTeams
              }
            }
            #$null = Use-MicrosoftTeamsConnection
            if (-not (Use-MicrosoftTeamsConnection) -and $TeamsConnection) {
              # order is important here!
              throw 'MicrosoftTeams - Connection to MicrosoftTeams established, but SkypeOnline Cmdlets not able to run. Please verify'
            }
          }
          'ExchangeOnline' {
            $ExchangeOnlineParameters = $ConnectionParameters
            $ExchangeOnlineParameters += @{ 'UserPrincipalName' = $AccountId }
            $ExchangeOnlineParameters += @{ 'ShowProgress' = $true }
            $ExchangeOnlineParameters += @{ 'ShowBanner' = $false }
            $null = Connect-ExchangeOnline @ExchangeOnlineParameters
          }
        }
        Write-Information "SUCCESS: $Status - $Operation"
      }
      catch {
        Write-Error -Message "$($_.Exception.Message)"
      }
    }

    if ( -not $NoFeedback ) {
      $Status = 'Providing Feedback'
      $step++
      $Operation = 'Querying information about established sessions'
      Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
      Write-Verbose -Message "$Status - $Operation"

      $SessionInfo = Get-CurrentConnectionInfo
      $SessionInfo | Add-Member -MemberType NoteProperty -Name AdminRoles -Value ''

      #Querying Admin Roles
      if ( $ActivatedRoles -and $ActivatedRoles.RoleName -gt 0 ) {
        $SessionInfo.AdminRoles = $($ActivatedRoles.RoleName -join ', ')
      }
      else {
        #AdminRoles is already populated if they have been activated with PIM (though only with eligible ones) this overwrites the previous set of roles
        $step++
        $Operation = 'Querying assigned Admin Roles'
        Write-Progress -Id 0 -Status $Status -CurrentOperation $Operation -Activity $MyInvocation.MyCommand -PercentComplete ($step / $sMax * 100)
        Write-Verbose -Message "$Status - $Operation"
        if ( Test-AzureADConnection) {
          try {
            $Roles = $(Get-AzureAdAdminRole (Get-AzureADCurrentSessionInfo).Account -ErrorAction Stop).RoleName -join ', '
            $SessionInfo.AdminRoles = $Roles
          }
          catch {
            Write-Warning -Message 'Module AzureAdPreview not present. Admin Roles cannot be enumerated.'
          }
        }
      }

      #Output
      Write-Output $SessionInfo


      Write-Host "$(Get-Date -Format 'dd MMM yyyy HH:mm') | Ready" -ForegroundColor Green
      Get-RandomQuote
    }
    else {
      return $(if ($Called) {
          # Returning basic connection information
          $SessionInfo = Get-CurrentConnectionInfo
          Write-Output $SessionInfo | Select-Object Account, ConnectedTo, TeamsUpgradeEffectiveMode
        })
    }

    Write-Progress -Id 0 -Status 'Complete' -Activity $MyInvocation.MyCommand -Completed
    #endregion

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} # Connect-Me
