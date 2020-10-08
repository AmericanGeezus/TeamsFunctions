﻿# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:		David Eberhardtt
# Updated:  01-OCT-2020
# Status:   PreLive

function Get-TeamsTenantVoiceConfig {
  <#
	.SYNOPSIS
		Displays Information about available Voice Configuration in the Tenant
	.DESCRIPTION
		Displays all Voice relevant information configured in the Tenant incl. counters for free Licenses and Numbers
  .PARAMETER DisplayUserCounters
    Optional. Displays information about Users enabled for Teams and for EnterpriseVoice
    This extends Script execution depending on number of Users in the Tenant
  .PARAMETER Detailed
    Optional. Displays more information about Voice Routing Policies, Dial Plans, etc.
	.EXAMPLE
		Get-TeamsTenantVoiceConfig
    Displays Licenses for Call Plans, available Numbers, as well as
    Counters for all relevant Policies, available VoiceRoutingPolicies
	.EXAMPLE
		Get-TeamsTenantVoiceConfig -Detailed
    Displays a detailed view also listing Names for DialPlans, PSTN Usages, Voice Routes and PSTN Gateways
    Also displays diagnostic parameters for troubleshooting
	.NOTES
		General notes
  .LINK
    Get-TeamsTenantVoiceConfig
    Get-TeamsUserVoiceConfig
    Find-TeamsUserVoiceConfig
    New-TeamsUserVoiceConfig
    Set-TeamsUserVoiceConfig
    Remove-TeamsUserVoiceConfig
    Test-TeamsUserVoiceConfig
  #>

  [CmdletBinding()]
  param(
    [Parameter(HelpMessage = 'Displays counters for User information')]
    [switch]$DisplayUserCounters,

    [Parameter(HelpMessage = 'Displays detailed information')]
    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level PreLive
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Asserting SkypeOnline Connection
    if (-not (Assert-SkypeOnlineConnection)) { break }

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"
    #region Information Gathering
    Write-Verbose -Message "Querying Tenant"
    $Tenant = Get-CsTenant -WarningAction SilentlyContinue

    Write-Verbose -Message "Querying SIP Domains"
    $SipDomains = Get-CsOnlineSipDomain -WarningAction SilentlyContinue

    Write-Verbose -Message "Querying Tenant Licenses"
    $TenantLicenses = Get-TeamsTenantLicense
    $CallPlanINT = $TenantLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN1"
    $CallPlanDOM = $TenantLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN2"
    $CallPlanDOM120 = $TenantLicenses | Where-Object { $_.SkuPartNumber -EQ "MCOPSTN5" -or $_.SkuPartNumber -EQ "MCOPSTN_5" }
    $CommunicationC = $TenantLicenses | Where-Object SkuPartNumber -EQ "MCOPSTNC"

    Write-Verbose -Message "Querying Direct Routing Information"
    $TDP = Get-CsTenantDialPlan -WarningAction SilentlyContinue
    $OVP = Get-CsOnlineVoiceRoutingPolicy -WarningAction SilentlyContinue
    $OPU = (Get-CsOnlinePSTNusage -WarningAction SilentlyContinue).Usage
    $OVR = Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue
    $OGW = Get-CsOnlinePSTNGateway -WarningAction SilentlyContinue
    #endregion

    #region Creating Base Custom Object
    $Object = [PSCustomObject][ordered]@{
      DisplayName                            = $Tenant.DisplayName
      Domains                                = $Tenant.Domains
      SipDomains                             = $SipDomains.Name
      TeamsUpgradeEffectiveMode              = $Tenant.TeamsUpgradeEffectiveMode
      TenantLicenses                         = $TenantLicenses.FriendlyName
      InternationalCallingPlanUnitsRemaining = $CallPlanINT.Remaining
      DomesticCallingPlanUnitsRemaining      = $CallPlanDOM.Remaining
      DomesticCallingPlan120UnitsRemaining   = $CallPlanDOM120.Remaining
      CommunicationCreditsUnitsRemaining     = $CommunicationC.Remaining
      ConfiguredTenantDialPlans              = $TDP.Count
      ConfiguredOnlineVoiceRoutingPolicies   = $OVP.Count
      ConfiguredOnlinePSTNUsages             = $OPU.Count
      ConfiguredOnlineVoiceRoutes            = $OVR.Count
      ConfiguredOnlinePSTNGateways           = $OGW.Count
    }
    #endregion

    #region User Information
    if ($PSBoundParameters.ContainsKey('DisplayUserCounters')) {
      Write-Verbose -Message "DisplayUserCounters - Querying User Information - This will take some time!" -Verbose
      Write-Verbose -Message "DisplayUserCounters - Querying AzureADUsers"
      $AdUsers = Get-AzureADUser -All:$TRUE | Where-Object AccountEnabled -EQ $TRUE -WarningAction SilentlyContinue
      Write-Verbose -Message "DisplayUserCounters - Querying CsOnlineUsers"
      $CsOnlineUsers = Get-CsOnlineUser -WarningAction SilentlyContinue
      Write-Verbose -Message "DisplayUserCounters - Counting EV Users"
      $CsOnlineUsersEV = $CsOnlineUsers | Where-Object EnterpriseVoiceEnabled -EQ $TRUE

      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledInAzureAD -Value $AdUsers.Count
      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledForTeams -Value $CsOnlineUsers.Count
      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledForEnterpriseVoice -Value $CsOnlineUsersEV.Count

    }
    #endregion

    #region Detailed Information
    if ($PSBoundParameters.ContainsKey('Detailed')) {
      Write-Verbose -Message "Querying Microsoft Telephone Numbers Information"
      $MSNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      if ( $null -ne $MSNumbers ) {
        $MSTelephoneNumbers = $MSNumbers.Count
        $MSTelephoneNumbersFree = $MSNumbers.IsNotAssigned.Count

        $MSNumbersUser = $MSNumbers | Where-Object InventoryType -EQ "Subscriber"
        $MSTelephoneNumbersUser = $MSNumbersUser.Count
        $MSTelephoneNumbersUserFree = $MSNumbersUser | Where-Object IsNotAssigned -EQ "True"

        $MSNumbersService = $MSNumbers | Where-Object InventoryType -EQ "Service"
        $MSTelephoneNumbersService = $MSNumbersService.Count
        $MSTelephoneNumbersServiceFree = $MSNumbersService | Where-Object IsNotAssigned -EQ "True"

        $MSNumbersTollFree = $MSNumbers | Where-Object InventoryType -EQ "Subscriber"
        $MSTelephoneNumbersTollFree = $MSNumbersTollFree.Count
        $MSTelephoneNumbersTollFreeFree = $MSNumbersTollFree | Where-Object IsNotAssigned -EQ "True"

      }
      else {
        $MSTelephoneNumbers = 0
        $MSTelephoneNumbersFree = 0
        $MSTelephoneNumbersUser = 0
        $MSTelephoneNumbersUserFree = 0
        $MSTelephoneNumbersService = 0
        $MSTelephoneNumbersServiceFree = 0
        $MSTelephoneNumbersTollFree = 0
        $MSTelephoneNumbersTollFreeFree = 0
      }

      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbers -Value $MSTelephoneNumbers
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersFree -Value $MSTelephoneNumbersFree
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersUser -Value $MSTelephoneNumbersUser
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersUserFree -Value $MSTelephoneNumbersUserFree
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersService -Value $MSTelephoneNumbersService
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersServiceFree -Value $MSTelephoneNumbersServiceFree
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersTollFree -Value $MSTelephoneNumbersTollFree
      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbersTollFreeFree -Value $MSTelephoneNumbersTollFreeFree
      $Object | Add-Member -MemberType NoteProperty -Name TenantDialPlans -Value $TDP.Identity
      $Object | Add-Member -MemberType NoteProperty -Name OnlineVoiceRoutingPolicies -Value $OVP.Identity
      $Object | Add-Member -MemberType NoteProperty -Name OnlinePSTNUsages -Value $OPU
      $Object | Add-Member -MemberType NoteProperty -Name OnlineVoiceRoutes -Value $OVR.Identity
      $Object | Add-Member -MemberType NoteProperty -Name OnlinePSTNGateways -Value $OGW.Identity
      $Object | Add-Member -MemberType NoteProperty -Name DirSyncEnabled -Value $Tenant.DirSyncEnabled
      $Object | Add-Member -MemberType NoteProperty -Name LastSyncTimeStamp -Value $Tenant.LastSyncTimeStamp

    }
    #endregion

    # Output
    Write-Output $Object

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end
} #Get-TeamsTenantVoiceConfig