# Module:   TeamsFunctions
# Function: VoiceConfig
# Author:   David Eberhardt
# Updated:  01-OCT-2020
# Status:   Live




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
    Get-TeamsTenantVoiceConfig DisplayUserCounters
    Displays a counters for Users in the Tenant as well as Users enabled for EnterpriseVoice
    This will run for a long time and may result in a timeout with AzureAd and with Teams. Handle with care.
  .EXAMPLE
    Get-TeamsTenantVoiceConfig -Detailed
    Displays a detailed view also listing Names for DialPlans, PSTN Usages, Voice Routes and PSTN Gateways
    Also displays diagnostic parameters for troubleshooting
  .INPUTS
    None
  .OUTPUTS
    System.Object
  .NOTES
    General notes
  .COMPONENT
    VoiceConfiguration
  .FUNCTIONALITY
    Returns Object with information about the Voice Configuration in the Tenant
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTenantVoiceConfig.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  param(
    [Parameter(HelpMessage = 'Displays counters for User information')]
    [switch]$DisplayUserCounters,

    [Parameter(HelpMessage = 'Displays detailed information')]
    [switch]$Detailed
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if ( -not $script:TFPSSA) { $script:TFPSSA = Assert-AzureADConnection; if ( -not $script:TFPSSA ) { break } }

    # Asserting MicrosoftTeams Connection
    if ( -not (Assert-MicrosoftTeamsConnection) ) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    #Initialising Counters
    $private:StepsID0, $private:StepsID1 = Get-WriteBetterProgressSteps -Code $($MyInvocation.MyCommand.Definition) -MaxId 1
    $private:ActivityID0 = $($MyInvocation.MyCommand.Name)
    [int] $private:CountID0 = [int] $private:CountID1 = 1

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    #region Information Gathering
    $StatusID0 = 'Information Gathering'
    $CurrentOperationID0 = 'Querying Tenant'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $Tenant = Get-CsTenant -WarningAction SilentlyContinue

    $CurrentOperationID0 = 'Querying SIP Domains'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $SipDomains = Get-CsOnlineSipDomain -WarningAction SilentlyContinue

    $CurrentOperationID0 = 'Querying Tenant Licenses'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $TenantLicenses = Get-TeamsTenantLicense -Detailed
    $CallPlanINT = $TenantLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN1'
    $CallPlanDOM = $TenantLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTN2'
    $CallPlanDOM120 = $TenantLicenses | Where-Object { $_.SkuPartNumber -EQ 'MCOPSTN5' -or $_.SkuPartNumber -EQ 'MCOPSTN_5' }
    $CommunicationC = $TenantLicenses | Where-Object SkuPartNumber -EQ 'MCOPSTNC'

    $CurrentOperationID0 = 'Querying Direct Routing Information'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $TDP = Get-CsTenantDialPlan -WarningAction SilentlyContinue
    $OVP = Get-CsOnlineVoiceRoutingPolicy -WarningAction SilentlyContinue
    $OPU = (Get-CsOnlinePstnUsage -WarningAction SilentlyContinue).Usage
    $OVR = Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue
    $OGW = Get-CsOnlinePSTNGateway -WarningAction SilentlyContinue
    #endregion

    #region Creating Base Custom Object
    $CurrentOperationID0 = 'Preparing Output Object'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    $Object = [PSCustomObject][ordered]@{
      DisplayName                            = $Tenant.DisplayName
      Domains                                = $Tenant.Domains
      SipDomains                             = $SipDomains.Name
      TeamsUpgradeEffectiveMode              = $Tenant.TeamsUpgradeEffectiveMode
      TenantLicenses                         = $TenantLicenses.ProductName
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
    $CurrentOperationID0 = 'Processing Parameter DisplayUserCounters'
    Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
    if ($PSBoundParameters.ContainsKey('DisplayUserCounters')) {
      $ActivityID1 = 'Querying User Information - This will take some time!'
      Write-Information "INFO:    $ActivityID1"
      $StatusID1 = 'Querying AzureADUsers'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $AdUsers = Get-AzureADUser -All:$TRUE | Where-Object AccountEnabled -EQ $TRUE -WarningAction SilentlyContinue

      $StatusID1 = 'Querying CsOnlineUsers'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $CsOnlineUsers = Get-CsOnlineUser -WarningAction SilentlyContinue

      $StatusID1 = 'Counting Voice Users (EnterpriseVoiceEnabled)'
      Write-BetterProgress -Id 1 -Activity $ActivityID1 -Status $StatusID1 -CurrentOperation $CurrentOperationID1 -Step ($private:CountID1++) -Of $private:StepsID1
      $CsOnlineUsersEV = $CsOnlineUsers | Where-Object EnterpriseVoiceEnabled -EQ $TRUE

      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledInAzureAD -Value $AdUsers.Count
      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledForTeams -Value $CsOnlineUsers.Count
      $Object | Add-Member -MemberType NoteProperty -Name UsersEnabledForEnterpriseVoice -Value $CsOnlineUsersEV.Count

      Write-Progress -Id 1 -Activity $ActivityID1 -Completed
    }
    #endregion

    #region Detailed Information
    if ($PSBoundParameters.ContainsKey('Detailed')) {
      $CurrentOperationID0 = 'Processing Parameter Detailed - Querying Microsoft Telephone Numbers'
      Write-BetterProgress -Id 0 -Activity $ActivityID0 -Status $StatusID0 -CurrentOperation $CurrentOperationID0 -Step ($private:CountID0++) -Of $private:StepsID0
      if (-not $TeamsFunctionsMSTelephoneNumbers) {
        $TeamsFunctionsMSTelephoneNumbers = Get-CsOnlineTelephoneNumber -ResultSize 20000 -WarningAction SilentlyContinue
      }

      if ( $null -ne $TeamsFunctionsMSTelephoneNumbers ) {
        $MSTelephoneNumbersCount = $TeamsFunctionsMSTelephoneNumbers.Count
        [int]$MSTelephoneNumbersFree = ($TeamsFunctionsMSTelephoneNumbers | Where-Object TargetType -NE $null).Count

        $MSNumbersUser = $TeamsFunctionsMSTelephoneNumbers | Where-Object InventoryType -EQ 'Subscriber'
        [int]$MSTelephoneNumbersUser = $MSNumbersUser.Count
        [int]$MSTelephoneNumbersUserFree = ($MSNumbersUser | Where-Object TargetType -NE $null).Count

        $MSNumbersService = $TeamsFunctionsMSTelephoneNumbers | Where-Object InventoryType -EQ 'Service'
        [int]$MSTelephoneNumbersService = $MSNumbersService.Count
        [int]$MSTelephoneNumbersServiceFree = ($MSNumbersService | Where-Object TargetType -NE $null).Count

        $MSNumbersTollFree = $TeamsFunctionsMSTelephoneNumbers | Where-Object InventoryType -EQ 'TollFree'
        [int]$MSTelephoneNumbersTollFree = $MSNumbersTollFree.Count
        [int]$MSTelephoneNumbersTollFreeFree = ($MSNumbersTollFree | Where-Object TargetType -NE $null).Count

      }
      else {
        $MSTelephoneNumbersCount = 0
        $MSTelephoneNumbersFree = 0
        $MSTelephoneNumbersUser = 0
        $MSTelephoneNumbersUserFree = 0
        $MSTelephoneNumbersService = 0
        $MSTelephoneNumbersServiceFree = 0
        $MSTelephoneNumbersTollFree = 0
        $MSTelephoneNumbersTollFreeFree = 0
      }

      $Object | Add-Member -MemberType NoteProperty -Name MSTelephoneNumbers -Value $MSTelephoneNumbersCount
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
    Write-Progress -Id 0 -Activity $ActivityID0 -Completed
    Write-Output $Object

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Get-TeamsTenantVoiceConfig
