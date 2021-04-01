# Module:   TeamsFunctions
# Function: Backup
# Author:		David Eberhardt
# Updated:  01-JUN-2020
# Status:   Unmanaged




function Backup-TeamsTenant {
  <#
	.SYNOPSIS
		A script to automatically backup a Microsoft Teams Tenant configuration.
	.DESCRIPTION
		Automates the backup of Microsoft Teams.
	.PARAMETER OverrideAdminDomain
		OPTIONAL: The FQDN your Office365 tenant. Use if your admin account is not in the same domain as your tenant (ie. doesn't use a @tenantname.onmicrosoft.com address)
  .EXAMPLE
    Backup-TeamsTenant
    Takes a backup of the entire Teams Tenant configuration and stores it as a ZIP file with the Tenant Name and Current Date in the current directory.
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

		Expanded to cover more elements
		David Eberhardt
		https://github.com/DEberhardt/
		https://davideberhardt.wordpress.com/

		14-MAY 2020

		The list of command is not dynamic, meaning addded commandlets post publishing date are not captured
  .COMPONENT
    SupportingFunction
	.FUNCTIONALITY
    Creating a backup for all Configuration in the Teams Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    about_SupportingFunction
	#>

  [CmdletBinding(ConfirmImpact = 'None')]
  param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$OverrideAdminDomain

  ) #param

  begin {
    Show-FunctionStatus -Level Unmanaged
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Asserting MicrosoftTeams Connection
    if (-not (Assert-MicrosoftTeamsConnection)) { break }

    $Filenames = '*.txt'

    If ((Get-PSSession -WarningAction SilentlyContinue | Where-Object -FilterScript {
          $_.Computername -match 'online.lync.com' -or $_.ComputerName -eq 'api.interfaces.records.teams.microsoft.com'
        }).State -eq 'Opened') {
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

    $ErrorActionP

    $CommandParams += @{'WarningAction' = 'SilentlyContinue' }
    $CommandParams += @{'ErrorAction' = 'SilentlyContinue' }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    # Tenant Configuration
    $null = (Get-CsOnlineDialInConferencingBridge @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingBridge.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingLanguagesSupported @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingLanguagesSupported.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingServiceNumber @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingServiceNumber.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialinConferencingTenantConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialinConferencingTenantConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingTenantSettings @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingTenantSettings.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineLisCivicAddress @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineLisCivicAddress.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineLisLocation @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineLisLocation.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsClientConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsClientConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsGuestCallingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsGuestCallingConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsGuestMeetingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsGuestMeetingConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsGuestMessagingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsGuestMessagingConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMeetingBroadcastConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMeetingBroadcastConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMeetingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMeetingConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsUpgradeConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsUpgradeConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTenant @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTenant.txt' -Force -Encoding utf8)
    $null = (Get-CsTenantFederationConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTenantFederationConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTenantNetworkConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTenantNetworkConfiguration.txt' -Force -Encoding utf8)
    $null = (Get-CsTenantPublicProvider @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTenantPublicProvider.txt' -Force -Encoding utf8)

    # Tenant Policies (except voice)
    $null = (Get-CsTeamsUpgradePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsUpgradePolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsAppPermissionPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsAppPermissionPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsAppSetupPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsAppSetupPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsCallParkPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsCallParkPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsChannelsPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsChannelsPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsComplianceRecordingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsComplianceRecordingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsEducationAssignmentsAppPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsEducationAssignmentsAppPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsFeedbackPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsFeedbackPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMeetingBroadcastPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMeetingBroadcastPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMeetingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMeetingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMessasgingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMessagingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsMobilityPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsMobilityPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsNotificationAndFeedsPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsNotificationAndFeedsPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsTargetingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsTargetingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsVerticalPackagePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsVerticalPackagePolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsVideoInteropServicePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsVideoInteropServicePolicy.txt' -Force -Encoding utf8)

    # Tenant Voice Configuration
    $null = (Get-CsTeamsTranslationRule @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsTranslationRule.txt' -Force -Encoding utf8)
    $null = (Get-CsTenantDialPlan @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTenantDialPlan.txt' -Force -Encoding utf8)

    $null = (Get-CsOnlinePSTNGateway @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlinePSTNGateway.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineVoiceRoute @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineVoiceRoute.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlinePstnUsage @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlinePstnUsage.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineVoiceRoutingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineVoiceRoutingPolicy.txt' -Force -Encoding utf8)

    # Tenant Voice related Configuration and Policies
    $null = (Get-CsTeamsIPPhonePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsIPPhonePolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsEmergencyCallingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsEmergencyCallingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsEmergencyCallRoutingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsEmergencyCallRoutingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialinConferencingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialinConferencingPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineVoicemailPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineVoicemailPolicy.txt' -Force -Encoding utf8)
    $null = (Get-CsTeamsCallingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsTeamsCallingPolicy.txt' -Force -Encoding utf8)

    # Tenant Telephone Numbers
    $null = (Get-CsOnlineTelephoneNumber @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineTelephoneNumber.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineTelephoneNumberAvailableCount @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineTelephoneNumberAvailableCount.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineTelephoneNumberInventoryTypes @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineTelephoneNumberInventoryTypes.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineTelephoneNumberReservationsInformation @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineTelephoneNumberReservationsInformation.txt' -Force -Encoding utf8)

    # Resource Accounts, Call Queues and Auto Attendants
    $null = (Get-CsOnlineApplicationInstance @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineApplicationInstance.txt' -Force -Encoding utf8)
    $null = (Get-CsCallQueue @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsCallQueue.txt' -Force -Encoding utf8)
    $null = (Get-CsAutoAttendant @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsAutoAttendant.txt' -Force -Encoding utf8)
    $null = (Get-CsAutoAttendantSupportedLanguage @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsAutoAttendantSupportedLanguage.txt' -Force -Encoding utf8)
    $null = (Get-CsAutoAttendantSupportedTimeZone @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsAutoAttendantSupportedTimeZone.txt' -Force -Encoding utf8)
    $null = (Get-CsAutoAttendantTenantInformation @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsAutoAttendantTenantInformation.txt' -Force -Encoding utf8)

    # User Configuration
    $null = (Get-CsOnlineUser @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineUser.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineVoiceUser @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineVoiceUser.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingUser @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingUser.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingUserInfo @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingUserInfo.txt' -Force -Encoding utf8)
    $null = (Get-CsOnlineDialInConferencingUserState @CommandParams | ConvertTo-Json | Out-File -FilePath 'Get-CsOnlineDialInConferencingUserState.txt' -Force -Encoding utf8)


    $TenantName = (Get-CsTenant -WarningAction SilentlyContinue).Displayname
    $BackupFile = ('TeamsBackup_' + (Get-Date -Format yyyy-MM-dd) + ' ' + $TenantName + '.zip')
    $null = (Compress-Archive -Path $Filenames -DestinationPath $BackupFile -Force)
    $null = (Remove-Item -Path $Filenames -Force -Confirm:$false)

    Write-Host -Object ('Microsoft Teams configuration backed up to {0}' -f $BackupFile)

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Backup-TeamsTenant
