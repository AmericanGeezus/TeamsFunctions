# Module:   TeamsFunctions
# Function: Lookup
# Author:	  David Eberhardt
# Updated:  11-NOV-2020
# Status:   Live




function Get-TeamsTenant {
  <#
  .SYNOPSIS
    Lists basic Tenant information
  .DESCRIPTION
    To gain a quick overview, this wrapper for Get-CsTenant will display basic information
  .EXAMPLE
    Get-TeamsTenant
    Lists basic tenant information relevant for working on this Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
 #>

  [CmdletBinding()]
  param (
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Information 'INFO: This is abbreviated output of Get-CsTenant. For full information, please run Get-CsTenant' -InformationAction Continue

    $T = Get-CsTenant -WarningAction SilentlyContinue # This should trigger a reconnect as well.

    #Determining OverrideURL
    $TenantId = $T | Select-Object -ExpandProperty identity

    if ($TenantId -match '.*DC\=lync(.*)001\,DC=local') {
      $Id = $TenantId.Substring($TenantId.IndexOf('lync') + 4, 2)
      $OverrideURL = "https://admin$Id.online.lync.com/HostedMigration/hostedmigrationService.svc"
    }
    else {
      Write-Warning -Message "Override Admin URL could not be determined, please Read from Identity manually (2 digits after 'DC\=lync')"
      $OverrideURL = $null
    }

    $TenantObject = [PSCustomObject][ordered]@{
      TenantId                         = $T.TenantId
      DisplayName                      = $T.DisplayName
      CountryAbbreviation              = $T.CountryAbbreviation
      PreferredLanguage                = $T.PreferredLanguage
      TeamsUpgradeEffectiveMode        = $T.TeamsUpgradeEffectiveMode
      TeamsUpgradeNotificationsEnabled = $T.TeamsUpgradeNotificationsEnabled
      TeamsUpgradePolicyIsReadOnly     = $T.TeamsUpgradePolicyIsReadOnly
      TeamsUpgradeOverridePolicy       = $T.TeamsUpgradeOverridePolicy
      ExperiencePolicy                 = $T.ExperiencePolicy
      Domains                          = $T.Domains
      DirSyncEnabled                   = $T.DirSyncEnabled
      LastSyncTimeStamp                = $T.LastSyncTimeStamp
      #AllowedDataLocation              = $T.AllowedDataLocation
      IsValid                          = $T.IsValid
      #PendingDeletion                  = $T.PendingDeletion
      WhenCreated                      = $T.WhenCreated
      WhenChanged                      = $T.WhenChanged
      TenantPoolExtension              = $T.TenantPoolExtension
      HostedMigrationOverrideURL       = $OverrideURL

    }

    return $TenantObject

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTDP