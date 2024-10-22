﻿# Module:   TeamsFunctions
# Function: Backup
# Author:   Ken Lasko
# Updated:  01-JUN-2020
# Status:   Unmanaged




function Backup-TeamsEV {
  <#
  .SYNOPSIS
    A script to automatically back-up a Microsoft Teams Enterprise Voice configuration.
  .DESCRIPTION
    Automates the backup of Microsoft Teams Enterprise Voice normalization rules, dialplans, voice policies, voice routes, PSTN usages and PSTN GW translation rules for various countries.
  .PARAMETER OverrideAdminDomain
    OPTIONAL: The FQDN your Office365 tenant. Use if your admin account is not in the same domain as your tenant (ie. doesn't use a @tenantname.onmicrosoft.com address)
  .EXAMPLE
    Backup-TeamsEV
    Takes a backup of the Teams Enterprise Voice Configuration and stores it as a ZIP file with the Tenant Name and Current Date in the current directory.
  .INPUTS
    None
    System.String
  .OUTPUTS
    System.File
  .NOTES
    Version 1.10
    Build: Feb 04, 2020

    Copyright © 2020  Ken Lasko
    klasko@ucdialplans.com
    https://www.ucdialplans.com
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Creating a backup for all Enterprise Voice Configuration in the Teams Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Backup-TeamsEV.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colourful feedback required to emphasise feedback for script executors')]
  [CmdletBinding(ConfirmImpact = 'None')]
  param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$OverrideAdminDomain

  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    $Filenames = 'DialPlans.txt', 'VoiceRoutes.txt', 'VoiceRoutingPolicies.txt', 'PSTNUsages.txt', 'TranslationRules.txt', 'PSTNGateways.txt'

    If ((Get-PSSession | Where-Object -FilterScript { $_.ComputerName -eq 'api.interfaces.records.teams.microsoft.com|online.lync.com' }).State -eq 'Opened') {
      Write-Host -Object 'Using existing session credentials'
    }
    Else {
      Write-Host -Object 'Logging into Office 365...'

      If ($OverrideAdminDomain) {
        $O365Session = (New-CsOnlineSession -OverrideAdminDomain $OverrideAdminDomain)
      }
      Else {
        $O365Session = (New-CsOnlineSession)
      }
      $null = (Import-PSSession -Session $O365Session -AllowClobber)
    }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    Try {
      $null = (Get-CsTenantDialPlan -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath Dialplans.txt -Force -Encoding utf8)
      $null = (Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath VoiceRoutes.txt -Force -Encoding utf8)
      $null = (Get-CsOnlineVoiceRoutingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath VoiceRoutingPolicies.txt -Force -Encoding utf8)
      $null = (Get-CsOnlinePstnUsage -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath PSTNUsages.txt -Force -Encoding utf8)
      $null = (Get-CsTeamsTranslationRule -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath TranslationRules.txt -Force -Encoding utf8)
      $null = (Get-CsOnlinePSTNGateway -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath PSTNGateways.txt -Force -Encoding utf8)
    }
    Catch {
      Write-Error -Message 'There was an error backing up the MS Teams Enterprise Voice configuration.'
      return
    }

    $BackupFile = ('TeamsEVBackup_' + (Get-Date -Format yyyy-MM-dd) + '.zip')
    $null = (Compress-Archive -Path $Filenames -DestinationPath $BackupFile -Force)
    $null = (Remove-Item -Path $Filenames -Force -Confirm:$false)

    Write-Host -Object ('Microsoft Teams Enterprise Voice configuration backed up to {0}' -f $BackupFile)
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Backup-TeamsEV
