# Module:   TeamsFunctions
# Function: Session
# Author:   David Eberhardt
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
    Module MicrosoftTeams v2.3.1 now fully supercedes previous connection methods. The Legcay role
    'Skype for Business Legacy Administrator' is no longer required if connected via MicrosoftTeams v2.3.1 or higher.
    Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
    Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Connect-Me.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colourful feedback required to emphasise feedback for script executors')]
  [CmdletBinding()]
  [Alias('con')]
  param(
    [Parameter(Mandatory, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
    [Alias('UserPrincipalName', 'Username')]
    [string]$AccountId,

    [Parameter(HelpMessage = 'Establishes a connection to Exchange Online. Reuses credentials if authenticated already.')]
    [Alias('Exchange')]
    [switch]$ExchangeOnline,

    [Parameter(HelpMessage = 'Suppresses Session Information output')]
    [switch]$NoFeedback

  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Required as Warnings on the OriginalRegistrarPool somehow may halt Script execution
    $WarningPreference = 'Continue'

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
    $AzureAdModule, $AzureAdPreviewModule, $TeamsModule = Get-NewestModule AzureAd, AzureAdPreview, MicrosoftTeams

    Write-Verbose -Message "Importing Module 'MicrosoftTeams'"
    $SaveVerbosePreference = $global:VerbosePreference;
    $global:VerbosePreference = 'SilentlyContinue';
    if ( -not $TeamsModule -or $TeamsModule.Version -lt '2.3.1' ) {
      throw [System.Activities.VersionMismatchException]::New('MicrosoftTeams Module not installed in v2.3.1 or higher - Please verify Module!')
    }

    #Import-Module MicrosoftTeams -MinimumVersion 2.3.1 -Force -Global -Verbose:$false
    if ( -not (Get-Module MicrosoftTeams) ) {
      try {
        Import-Module MicrosoftTeams -MinimumVersion 2.3.1 -Force -Global -Verbose:$false -ErrorAction Stop
      }
      catch {
        throw [System.Activities.VersionMismatchException]::New('MicrosoftTeams Module not available in v2.3.1 or higher - Please verify Module!')
      }
    }

    $global:VerbosePreference = $SaveVerbosePreference

    # Determine Module Version loaded
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
    }
    #endregion

    # Defining Connection Parameters (baseline)
    $ConnectionParameters = $null
    $ConnectionParameters += @{ 'ErrorAction' = 'Stop' }

    if ($PSBoundParameters.ContainsKey('Verbose')) { $ConnectionParameters += @{ 'Verbose' = $true } }
    if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') { $ConnectionParameters += @{ 'Debug' = $true } }

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
    $ConnectionOrder += 'MicrosoftTeams'

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
            Write-Information "SUCCESS: $Status - $Operation"
          }
          'Enabling eligible Admin Roles' {
            try {
              $ActivatedRoles = Enable-AzureAdAdminRole -Identity "$AccountId" -PassThru -Force -ErrorAction Stop #(default should only enable the Teams ones? switch?)
              $NrOfRoles = if ($ActivatedRoles.Count -gt 0) { $ActivatedRoles.Count } else { if ( $ActivatedRoles ) { 1 } else { 0 } }
              if ( $NrOfRoles -gt 0 ) {
                $Seconds = 10
                Write-Verbose "Enable-AzureAdAdminrole - $NrOfRoles Role(s) activated. Waiting for AzureAd to propagate ($Seconds`s)" -Verbose
                Start-Sleep -Seconds $Seconds
              }
              else {
                Write-Verbose 'Enable-AzureAdAdminrole - No roles have been activated - If Privileged Admin Groups are used, please activate via PIM: https://aka.ms/myroles ' -Verbose
              }
              Write-Information "SUCCESS: $Status - $Operation"
            }
            catch {
              if ($_.Exception.Message.Split('["')[2] -eq 'MfaRule') {
                Write-Warning 'Enable-AzureAdAdminrole - No valid authentication via MFA is present. Please authenticate again and retry'
              }
              elseif ($_.Exception.Message.Split('["')[2] -eq 'TicketingRule') {
                Write-Warning 'Enable-AzureAdAdminrole - Activating Admin roles failed: PIM requires a Ticket Number - please activate via Azure Admin Center - https://aka.ms/myroles'
              }
              else {
                Write-Verbose 'Enable-AzureAdAdminrole - Tenant may not be enabled for PIM' -Verbose
                if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
                  "Function: $($MyInvocation.MyCommand.Name): Exception:", $_.Exception.Message | Write-Debug
                }
              }
              $PIMavailable = $false
            }
          }
          'MicrosoftTeams' {
            $MicrosoftTeamsParameters = $ConnectionParameters
            #Using AccountId currently results in a Connection that is established but cannot open a PS context to SfBOnline
            #$MicrosoftTeamsParameters += @{ 'AccountId' = $AccountId }
            if ($AzureAdFeedback) {
              $MicrosoftTeamsParameters += @{ 'TenantId' = $AzureAdFeedback.TenantId }
            }
            try {
              $TeamsConnection = Connect-MicrosoftTeams @MicrosoftTeamsParameters
            }
            catch {
              Write-Verbose -Message "$Status - $Operation - Try `#2 - Please confirm Account" -Verbose
              if ($AzureAdFeedback) {
                $TeamsConnection = Connect-MicrosoftTeams -TenantId $AzureAdFeedback.TenantId -ErrorAction Stop
              }
              else {
                $TeamsConnection = Connect-MicrosoftTeams -ErrorAction Stop
              }
            }
            #$null = Use-MicrosoftTeamsConnection
            if (-not (Use-MicrosoftTeamsConnection) -and $TeamsConnection) {
              # order is important here!
              Write-Warning -Message "When activating roles with this CmdLet, propagation may not have completed. Please wait a few seconds and retry this command."
              throw 'MicrosoftTeams - Connection to MicrosoftTeams established, but Cmdlets not able to run. Please verify Admin Roles via https://aka.ms/myroles'
            }
            Write-Information "SUCCESS: $Status - $Operation"
          }
          'ExchangeOnline' {
            $ExchangeOnlineParameters = $ConnectionParameters
            $ExchangeOnlineParameters += @{ 'UserPrincipalName' = $AccountId }
            $ExchangeOnlineParameters += @{ 'ShowProgress' = $true }
            $ExchangeOnlineParameters += @{ 'ShowBanner' = $false }
            $null = Connect-ExchangeOnline @ExchangeOnlineParameters
            Write-Information "SUCCESS: $Status - $Operation"
          }
        }
      }
      catch {
        Write-Error -Message "$($_.Exception.Message)"
        if (($_.Exception.Message.Contains('User canceled authentication'))) {
          return
        }
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
            $Roles = $(Get-AzureAdAdminRole -Identity (Get-AzureADCurrentSessionInfo).Account -ErrorAction Stop).RoleName -join ', '
          }
          catch {
            $Roles = $(Get-AzureAdAdminRole -Identity (Get-AzureADCurrentSessionInfo).Account -QueryGroupsOnly).RoleName -join ', '
          }
          $SessionInfo.AdminRoles = $Roles
        }
      }

      # Changing Window Title to match TenantDomain
      if ( $SessionInfo.TenantDomain ) {
        Set-PowerShellWindowTitle $SessionInfo.TenantDomain
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
