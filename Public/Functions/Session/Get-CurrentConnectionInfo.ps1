﻿# Module:     TeamsFunctions
# Function:   Session
# Author:     David Eberhardt
# Updated:    01-OCT-2020
# Status:     Live




function Get-CurrentConnectionInfo {
  <#
	.SYNOPSIS
		Queries AzureAd, MicrosoftTeams and ExchangeOnline for currently established Sessions
	.DESCRIPTION
		Returns an object displaying all currently connected PowerShell Sessions and basic output about the Tenant.
	.EXAMPLE
		Get-CurrentConnectionInfo
    Will Test current connection to AzureAd, MicrosoftTeams and ExchangeOnline and displays simple output object.
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Connect-Me
  .LINK
    Get-CurrentConnectionInfo
  #>

  [CmdletBinding()]
  [Alias('cur')]
  [OutputType([Boolean])]
  param() #param

  begin {
    Show-FunctionStatus -Level Live
    $Stack = Get-PSCallStack
    $Called = ($stack.length -ge 3)
  } #begin

  process {

    # Creating main Object
    $SessionInfo = [PSCustomObject][ordered]@{
      Account                   = ''
      Tenant                    = ''
      TenantDomain              = ''
      TenantId                  = ''
      ConnectedTo               = [System.Collections.ArrayList]@()
      AzureEnvironment          = ''
      TeamsUpgradeEffectiveMode = ''
    }
    #AzureAd SessionInfo
    $ConnectedToAD = Test-AzureADConnection
    if ( $ConnectedToAD ) {
      $SessionInfo.ConnectedTo += 'AzureAd'
      $AzureAdFeedback = Get-AzureADCurrentSessionInfo
      $SessionInfo.Account = $AzureAdFeedback.Account.Id
      $SessionInfo.Tenant = "$($AzureAdFeedback.Account.Id.split('@')[1])"
      $SessionInfo.TenantDomain = $AzureAdFeedback.TenantDomain
      $SessionInfo.TenantId = $AzureAdFeedback.TenantId
      $SessionInfo.AzureEnvironment = $AzureAdFeedback.Environment
    }

    #MicrosoftTeams SessionInfo
    $ConnectedToTeams = Test-MicrosoftTeamsConnection
    if ( $ConnectedToTeams ) {
      try {
        #NOTE This will also initialise (or reconnect) the SkypeOnline part of MicrosoftTeams and test Admin roles
        $CsTenant = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction Stop
      }
      catch {
        Write-Warning -Message 'Connection to MicrosoftTeams established, but Skype Admin Roles not activated. Please enable Admin Roles before continuing'
        Write-Verbose -Message 'The TeamsUpgradeEffectiveMode is not shown as it cannot be queried from the Tenant'
      }
      $SessionInfo.ConnectedTo += 'MicrosoftTeams'
      $SessionInfo.Tenant = "$($CsTenant.DisplayName)"
      $SessionInfo.TeamsUpgradeEffectiveMode = $CsTenant.TeamsUpgradeEffectiveMode
    }


    if ( $ConnectedToAD -and $ConnectedToTeams ) {
      $SessionInfo.Tenant = "$($AzureAdFeedback.Account.Id.split('@')[1]) - $($CsTenant.DisplayName)"
    }

    #Exchange SessionInfo
    if ( Test-ExchangeOnlineConnection ) {
      $SessionInfo.ConnectedTo += 'ExchangeOnline'
      #What to add?
      if ($PSBoundParameters.ContainsKey('Debug') -or $DebugPreference -eq 'Continue') {
        "Function: $($MyInvocation.MyCommand.Name): ExchangeOnlineFeedback:", ($ExchangeOnlineFeedback | Format-Table -AutoSize | Out-String).Trim() | Write-Debug
      }
    }

    #Output
    Write-Output $SessionInfo
  } #process

  end {

  } #end

} #Get-CurrentConnectionInfo