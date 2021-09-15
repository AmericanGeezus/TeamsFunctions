# Module:   TeamsFunctions
# Function: Lookup
# Author:   David Eberhardt
# Updated:  11-NOV-2020
# Status:   Live


#TODO Add TenantDomain - Change HostedMigrationOverrideURL?

function Get-TeamsTenant {
  <#
  .SYNOPSIS
    Lists basic Tenant information
  .DESCRIPTION
    To gain a quick overview, this wrapper for Get-CsTenant will display basic information
  .EXAMPLE
    Get-TeamsTenant
    Lists basic tenant information relevant for working on this Tenant
  .INPUTS
    None
  .OUTPUTS
    System.Object
  .NOTES
    None
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Queries abbreviated information about the Teams Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTenant.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
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

    # Querying Version Number for
    #TODO put this in a Global variable for all TF cmdlets!
    $TeamsModuleVersion = (Get-Module MicrosoftTeams -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).Version

    # Format enumeration
    $FormatEnumerationLimit = -1 # Unlimited (for Domains)

    # preparing Output Field Separator
    $OFS = ', ' # do not remove - Automatic variable, used to separate elements!

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Write-Information 'INFO: This is abbreviated output of Get-CsTenant. For full information, please run Get-CsTenant'

    $TenantObject = Get-CsTenant -WarningAction SilentlyContinue # This should trigger a reconnect as well.

    #Determining OverrideURL
    if ( $TeamsModuleVersion -gt 2.3.1 ) {
      #BODGE may need addressing with Get-CsHostedMigrationURL
      $OverrideURL = $(Get-AzureADCurrentSessionInfo).TenantDomain
    }
    else {
      $TenantId = $TenantObject | Select-Object -ExpandProperty Identity

      if ($TenantId -match '.*DC\=lync(.*)001\,DC=local') {
        $Id = $TenantId.Substring($TenantId.IndexOf('lync') + 4, 2)
        $OverrideURL = "https://admin$Id.online.lync.com/HostedMigration/hostedmigrationService.svc"
      }
      else {
        Write-Warning -Message "Override Admin URL could not be determined, please Read from Identity manually (2 digits after 'DC\=lync')"
        $OverrideURL = $null
      }
    }

    # Adding OverrideURL
    $TenantObject | Add-Member -MemberType NoteProperty -Name TenantDomain -Value $OverrideURL -Force #TODO Change!
    $TenantObject | Add-Member -MemberType NoteProperty -Name HostedMigrationOverrideURL -Value $OverrideURL -Force

    #Filtering Object
    if ( $TeamsModuleVersion -gt 2.3.1 ) {
      $Object = $TenantObject | Select-Object TenantId, DisplayName, CountryAbbreviation, PreferredLanguage, `
        TeamsUpgradeEffectiveMode, TeamsUpgradeNotificationsEnabled, TeamsUpgradePolicyIsReadOnly, TeamsUpgradeOverridePolicy, `
        DefaultDataLocation, DirSyncEnabled, WhenCreated, TenantDomain, HostedMigrationOverrideURL, Domains

      #Reworking Domains and filtering onmicrosoft.com domains. Adding Script Method for Domains
      $Domains = $TenantObject.Domains
      <#
      #$DomainsOnMicrosoft = ($Domains | Where-Object Name -Match '.onmicrosoft.com').Name -join ', '
      $DomainsOnMicrosoft = ($Domains | Where-Object Name -Match '.onmicrosoft.com').Name -join '
'
      #$DomainsForTeams = ($Domains | Where-Object Capability -Match 'OfficeCommunicationsOnline').Name -join ', '
      $DomainsForTeams = ($Domains | Where-Object Capability -Match 'OfficeCommunicationsOnline').Name -join '
'
      $Object | Add-Member -MemberType NoteProperty -Name ManagedOnMicrosoftDomains -Value $DomainsOnMicrosoft -Force
      $Object | Add-Member -MemberType NoteProperty -Name ManagedSipDomains -Value $DomainsForTeams -Force
      #$Object.DomainsOnMicrosoft | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.Name } -Force
      #$Object.DomainsForTeams | Add-Member -MemberType ScriptMethod -Name ToString -Value { $this.Name } -Force
      #>

      $ManagedOnMicrosoftDomains = $Domains | Where-Object Name -Match '.onmicrosoft.com'
      $Object | Add-Member -MemberType NoteProperty -Name ManagedOnMicrosoftDomains -Value $ManagedOnMicrosoftDomains.Name -Force

      $ManagedCommunicationsDomains = $Domains | Where-Object Capability -Match 'OfficeCommunicationsOnline'
      $Object | Add-Member -MemberType NoteProperty -Name ManagedCommunicationsDomains -Value $ManagedCommunicationsDomains.Name -Force

      $SipDomains = Get-CsOnlineSipDomain -WarningAction SilentlyContinue
      $Object | Add-Member -MemberType NoteProperty -Name ManagedSipDomains -Value $SipDomains.Name -Force
    }
    else {
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
    }

    return $Object
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTenant