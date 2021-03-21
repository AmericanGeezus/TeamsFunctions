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

    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    # preparing Output Field Separator
    $OFS = ', ' # do not remove - Automatic variable, used to separate elements!

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Information 'INFO: This is abbreviated output of Get-CsTenant. For full information, please run Get-CsTenant'

    $TenantObject = Get-CsTenant -WarningAction SilentlyContinue # This should trigger a reconnect as well.

    #Determining OverrideURL
    $TenantId = $TenantObject | Select-Object -ExpandProperty identity

    if ($TenantId -match '.*DC\=lync(.*)001\,DC=local') {
      $Id = $TenantId.Substring($TenantId.IndexOf('lync') + 4, 2)
      $OverrideURL = "https://admin$Id.online.lync.com/HostedMigration/hostedmigrationService.svc"
    }
    else {
      Write-Warning -Message "Override Admin URL could not be determined, please Read from Identity manually (2 digits after 'DC\=lync')"
      $OverrideURL = $null
    }

    # Adding OverrideURL
    $TenantObject | Add-Member -MemberType NoteProperty -Name HostedMigrationOverrideURL -Value $OverrideURL -Force

    #Filtering Object
    $Object = $TenantObject | Select-Object TenantId, DisplayName, CountryAbbreviation, PreferredLanguage, `
      TeamsUpgradeEffectiveMode, TeamsUpgradeNotificationsEnabled, TeamsUpgradePolicyIsReadOnly, TeamsUpgradeOverridePolicy, `
      ExperiencePolicy, DirSyncEnabled, LastSyncTimeStamp, IsValid, WhenCreated, WhenChanged, TenantPoolExtension, HostedMigrationOverrideURL

    #Reworking Domains and filtering onmicrosoft.com domains. Adding Script Method for Domains
    $Domains = $TenantObject.Domains.Split(',') #| Select-Object -First 10
    [psCustomObject]$DomainsOnMicrosoft = @()
    foreach ($D in $Domains) {
      if ($D.EndsWith('.onmicrosoft.com')) {
        $DomainsOnMicrosoft += "$D"
      }
    }
    $Object | Add-Member -MemberType NoteProperty -Name DomainsOnMicrosoft -Value $DomainsOnMicrosoft -Force
    $Object | Add-Member -MemberType NoteProperty -Name Domains -Value $Domains -Force
    $Object.Domains | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.Domains } -Force

    return $Object
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTenant