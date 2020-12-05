# Module:   TeamsFunctions
# Function: Lookup
# Author:	David Eberhardt
# Updated:  11-NOV-2020
# Status:   PreLive

#TODO Add Function to query Hosted Migration Override URL:
#https://uclikeaboss.wordpress.com/2020/02/16/get-sfb-hosted-migration-override-url-programmatically/

function Get-TeamsTenant {
  <#
  .SYNOPSIS
    Lists basic Tenant information
  .DESCRIPTION
    To gain a quick overview, this wrapper for Get-CsTenant will display basic information
  .EXAMPLE
    Get-TeamsTenant
    Lists basic tenant information relevant for working on this Tenant
  #>

  [CmdletBinding()]
  param (
  )

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "This is abbreviated output of Get-CsTenant. For full information, please run Get-CsTenant" -Verbose

    $T = Get-CsTenant -WarningAction SilentlyContinue # This should trigger a reconnect as well.
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
      AllowedDataLocation              = $T.AllowedDataLocation
      IsValid                          = $T.IsValid
      PendingDeletion                  = $T.PendingDeletion
      WhenCreated                      = $T.WhenCreated
      WhenChanged                      = $T.WhenChanged
      TenantPoolExtension              = $T.TenantPoolExtension

    }

    return $TenantObject

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTDP