# Module:   TeamsFunctions
# Function: Licensing
# Author:   Philipp, Scripting.up-in-the.cloud
# Updated:  14-FEB-2021
# Status:   Live




function Get-AzureAdLicense {
  <#
  .SYNOPSIS
    License information for AzureAD Licenses related to Teams
  .DESCRIPTION
    Returns an Object containing all Teams related Licenses
  .PARAMETER FilterRelevantForTeams
    Optional. By default, shows all 365 Licenses
    Using this switch, shows only Licenses relevant for Teams
  .EXAMPLE
    Get-AzureAdLicense
    Returns 39 Azure AD Licenses that relate to Teams for use in other commands
    .INPUTS
    System.String
    .OUTPUTS
    System.Object
    .NOTES
    Reads:  https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
    Source: https://scripting.up-in-the.cloud/licensing/o365-license-names-its-a-mess.html
    With very special thanks to Philip
    This CmdLet can assign one of 123 Azure Ad Licenses. (see ParameterName)
    Please raise an issue on Github if you require additional Licenses for assignment
  .COMPONENT
    Licensing
  .FUNCTIONALITY
    Returns a list of published Licenses
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdLicense.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
    [Parameter()]
    [switch]$FilterRelevantForTeams
  ) #param

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"
    Write-Verbose -Message "Need help? Online:  $global:TeamsFunctionsHelpURLBase$($MyInvocation.MyCommand)`.md"

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }
    if ( $PSBoundParameters.ContainsKey('InformationAction')) { $InformationPreference = $PSCmdlet.SessionState.PSVariable.GetValue('InformationAction') } else { $InformationPreference = 'Continue' }

    [System.Collections.ArrayList]$Products = @()

    $srcProductPlans = @{}
    $planServicePlanNames = @{}

    [System.Collections.ArrayList]$ProductsNotAdded = @()
    [System.Collections.ArrayList]$PlansNotAdded = @()

  } #begin

  process {
    #read the content of the Microsoft web page and extract the first table
    $url = 'https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-WebRequest $url -UseBasicParsing).Content
    $content = $content.SubString($content.IndexOf('<tbody>'))
    $content = $content.Substring(0, $content.IndexOf('</tbody>'))

    #eliminate line feeds so that we can use regular expression to get the table rows...
    $content = $content -replace "`r?`n", ''
    $rows = (Select-String -InputObject $content -Pattern '<tr>(.*?)</tr>' -AllMatches).Matches | ForEach-Object {
      $_.Groups[1].Value
    }

    #on each table row, get the column cell content
    #   1st cell contains the product display name
    #   2nd cell contains the Sku ID (called 'string ID' here)
    #   3rd cell contains the included service plans (with string IDs)
    #   3rd cell contains the included service plans (with display names)
    $rows | ForEach-Object {
      $cells = (Select-String -InputObject $_ -Pattern '<td>(.*?)</td>' -AllMatches).Matches | ForEach-Object {
        $_.Groups[1].Value
      }

      $srcProductName = $cells[0]
      $srcSkuPartNumber = $cells[1]
      $srcSkuId = $cells[2]
      $srcServicePlan = $cells[3]
      $srcServicePlanName = $cells[4]

      $srcProductPlans = $null
      [System.Collections.ArrayList]$srcProductPlans = @()

      #region Sub-Skus (Plans)
      # Preparing Plans
      if (($srcServicePlan.Trim() -ne '') -and ($srcServicePlanName.Trim() -ne '')) {

        #store the service plan string IDs for later match
        if ($PSBoundParameters.ContainsKey('Debug')) {
          "Function: $($MyInvocation.MyCommand.Name): This ServicePlan: $srcServicePlan" | Write-Debug
        }
        $srcServicePlan -split '<br.?>' | ForEach-Object {
          if ($PSBoundParameters.ContainsKey('Debug')) {
            "Function: $($MyInvocation.MyCommand.Name): Splitting at '<br/>': $_" | Write-Debug
          }
          try {
            if ($_ -eq '') {
              Write-Verbose -Message "Entry '$srcServicePlan' has a trailing '<br/>', omitting entry"
            }
            else {
              $planServicePlanName = ($_.SubString(0, $_.LastIndexOf('('))).Trim()
              $planServicePlanId = $_.SubString($_.LastIndexOf('(') + 1)
              if ($planServicePlanId.Contains(')')) {
                $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(')'))
              }
            }
          }
          catch {
            Write-Warning -Message "Cannot read Entry '$srcServicePlan' (Service Plan) - malformed string. Reading this requires open and close parenthesis around ServicePlanId - please open issue against Documentation: https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
          }

          if (-not $planServicePlanNames.ContainsKey($planServicePlanId)) {
            $planServicePlanNames.Add($planServicePlanId, $planServicePlanName)
          }
        }

        #get the included service plans
        $srcServicePlanName -split '<br.?>' | ForEach-Object {
          try {
            if ($_ -eq '') {
              Write-Verbose -Message "Entry '$srcServicePlanName' has a trailing '<br/>', omitting entry"
            }
            else {
              $planProductName = ($_.SubString(0, $_.LastIndexOf('('))).Trim()
              $planServicePlanId = $_.SubString($_.LastIndexOF('(') + 1)
              if ($planServicePlanId.Contains(')')) {
                $planServicePlanId = $planServicePlanId.SubString(0, $planServicePlanId.IndexOf(')'))
              }
            }
          }
          catch {
            Write-Warning -Message "Cannot read Entry '$srcServicePlanName' (Service Plan Name) - malformed string. Reading this requires open and close parenthesis around ServicePlanId - please open issue against Documentation: https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference"
          }

          # Add RelevantForTeams
          if ( $planServicePlanNames[$planServicePlanId] ) {
            if ( $planServicePlanNames[$planServicePlanId].Contains('TEAMS') -or $planServicePlanNames[$planServicePlanId].Contains('MCO') ) {
              $Relevant = $true
            }
            else {
              $Relevant = $false
            }
          }
          else {
            $Relevant = $false
          }

          # reworking ProductName into TitleCase
          $VerbosePreference = 'SilentlyContinue'
          $TextInfo = (Get-Culture).TextInfo
          $planProductName = $TextInfo.ToTitleCase($planProductName.ToLower())
          $planProductName = Format-StringRemoveSpecialCharacter -String "$planProductName" -SpecialCharacterToKeep '()+ -'
          # Building Object
          if ($srcProductPlans.ServicePlanId -notcontains $planServicePlanId) {
            try {
              [void]$srcProductPlans.Add([TFTeamsServicePlan]::new("$planProductName", "$($planServicePlanNames[$planServicePlanId])", "$planServicePlanId", $Relevant))
            }
            catch {
              Write-Debug "[TFTeamsServicePlan] Couldn't add entry for $planProductName"
              if ( $planProductName -ne 'Powerapps For Office 365 K1') {
                $PlansNotAdded += $planProductName
              }
            }
          }
        }
      }
      #endregion

      #region Reworking Parameters
      # Adding ParameterName
      $ParameterName = switch ($srcSkuPartNumber) {
        #region Main Licenses
        'M365EDU_A1' { 'Microsoft365A1' }
        'M365EDU_A3_FACULTY' { 'Microsoft365A3faculty' }
        'M365EDU_A3_STUDENT' { 'Microsoft365A3students' }
        'M365EDU_A5_FACULTY' { 'Microsoft365A5faculty' }
        'M365EDU_A5_STUDENT' { 'Microsoft365A5students' }
        'SMB_BUSINESS' { 'Microsoft365AppsForBusiness' }
        'SMB_BUSINESS_ESSENTIALS' { 'Microsoft365BusinessBasic' }
        'SMB_BUSINESS_PREMIUM' { 'Microsoft365BusinessStandard' }
        'MIDSIZEPACK' { 'Office365MidsizeBusiness' }
        'SPB' { 'Microsoft365BusinessPremium' }
        'SPE_E3' { 'Microsoft365E3' }
        'SPE_E5' { 'Microsoft365E5' }
        'M365_F1' { 'Microsoft365F1' }
        'SPE_F1' { 'Microsoft365F3' }
        'ENTERPRISEPREMIUM_FACULTY' { 'Office365A5faculty' }
        'ENTERPRISEPREMIUM_STUDENT' { 'Office365A5students' }
        'STANDARDPACK' { 'Office365E1' }
        'STANDARDWOFFPACK' { 'Office365E2' }
        'ENTERPRISEPACK' { 'Office365E3' }
        'DEVELOPERPACK' { 'Office365E3Dev' }
        'ENTERPRISEWITHSCAL' { 'Office365E4' }
        'ENTERPRISEPREMIUM' { 'Office365E5' }
        'ENTERPRISEPREMIUM_NOPSTNCONF' { 'Office365E5NoAudioConferencing' }
        'DESKLESSPACK' { 'Office365F1' }
        #endregion

        #region Government Licenses
        'SPE_E3_USGOV_DOD' { 'Microsoft365E3USGovDoD' }
        'SPE_E3_USGOV_GCCHIGH' { 'Microsoft365E3USGovGCCHigh' }
        'ENTERPRISEPACK_GOV' { 'Office365G3GCC' }
        'ENTERPRISEPACK_USGOV_DOD' { 'Office365E3USGovDoD' }
        'ENTERPRISEPACK_USGOV_GCCHIGH' { 'Office365E3USGovGCCHigh' }
        'ENTERPRISEPREMIUM_GOV' { 'Office365E5Gov' }
        'MCOCAP_GOV' { 'CommonAreaPhoneGov' }
        'MCOEV_GOV' { 'PhoneSystemGov' }
        'MCOPSTN_1_GOV' { 'DomesticCallingPlanGov' }
        'PHONESYSTEM_VIRTUALUSER_GOV' { 'PhoneSystemVirtualUserGov' }
        'EMS_GOV' { 'EnterpriseMobilitySecurityE3Gov' }
        'EMSPREMIUM_GOV' { 'EnterpriseMobilitySecurityE5Gov' }
        'M365_G3_GOV' { 'Microsoft365G3GCC' }
        'INTUNE_A_D_GOV' { 'IntuneDeviceGov' }
        #endregion

        #region Apps & Additional Licenses (addresses part of Issue #80)
        'EMS' { 'EnterpriseMobilitySecurityE3' }
        'EMSPREMIUM' { 'EnterpriseMobilitySecurityE5' }
        'VISIOONLINE_PLAN1' { 'VisioOnlinePlan1' }
        'VISIOCLIENT' { 'VisioOnlinePlan2' }
        'VISIOCLIENT_GOV' { 'VisioOnlinePlan2Gov' }
        'PROJECT_P1' { 'ProjectPlan1' }
        'PROJECTONLINE_PLAN_1' { 'ProjectOnlinePlan1' }
        'PROJECTONLINE_PLAN_2' { 'ProjectOnlinePlan2' }
        'PROJECT_P1' { 'ProjectPlan1' }
        'PROJECTESSENTIALS' { 'ProjectEssentials' }
        'PROJECTPROFESSIONAL' { 'ProjectPro' }
        'PROJECTPROFESSIONAL_GOV' { 'ProjectProGov' }
        'PROJECTPREMIUM' { 'ProjectPremium' }
        'PROJECTPREMIUM_GOV' { 'ProjectPremiumGov' }
        'CRMPLAN2' { 'DynamicsCrmOnlineBasic' }
        'CRMSTANDARD' { 'DynamicsCrmOnline' }
        'Dynamics_365_for_Operations' { 'Dynamics365Operations' }
        'DYN365_FINANCIALS_BUSINESS_SKU' { 'Dynamics365Financials' }
        'DYN365_TEAM_MEMBERS' { 'Dynamics365TeamMembers' }
        'DYN365_ENTERPRISE_TEAM_MEMBERS' { 'Dynamics365EnterpriseTeamMembers' }
        'DYN365_ENTERPRISE_P1_IW' { 'Dynamics365EnterpriseP1' }
        'DYN365_ENTERPRISE_PLAN1' { 'Dynamics365Enterprise' }
        'DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE' { 'Dynamics365EnterpriseSalesAndCustServ' }
        'DYN365_ENTERPRISE_CUSTOMER_SERVICE' { 'Dynamics365EnterpriseCustServ' }
        'DYN365_ENTERPRISE_SALES' { 'Dynamics365EnterpriseSales' }
        'DYN365_SCM' { 'Dynamics365SupplyChain' }
        'DYNAMICS_365_ONBOARDING_SKU' { 'Dynamics365TalentOnboard' }
        'POWER_BI_ADDON' { 'PowerBIAddOn' }
        'POWER_BI_PRO' { 'PowerBIPro' }
        'POWER_BI_STANDARD' { 'PowerBIStd' }
        'WIN10_PRO_ENT_SUB' { 'Win10EnterpriseE3Pro' }
        'WIN10_VDA_E3' { 'Win10EnterpriseE3' }
        'WIN10_VDA_E5' { 'Win10EnterpriseE5' }
        'O365_BUSINESS_ESSENTIALS' { 'Office365BusinessEssentials' }
        'O365_BUSINESS_PREMIUM' { 'Office365BusinessPremium' }
        'O365_BUSINESS' { 'Microsoft365AppsForBusiness' }
        'OFFICESUBSCRIPTION' { 'Microsoft365AppsForEnterprise' }
        'EQUIVIO_ANALYTICS' { 'Office365AdvCompliance' }
        'AAD_BASIC' { 'AzureAdBasic' }
        'AAD_PREMIUM' { 'AzureAdPremiumP1' }
        'AAD_PREMIUM_P2' { 'AzureAdPremiumP2' }
        'ATP_ENTERPRISE' { 'AdvancedThreatProtectionEnterprise' }
        'FLOW_FREE' { 'MicrosoftFlowFree' }
        'M365_SECURITY_COMPLIANCE_FOR_FLW' { 'Microsoft365SecurityComplianceForFlw' }
        'IDENTITY_THREAT_PROTECTION' { 'Microsoft365E5Security' }
        'IDENTITY_THREAT_PROTECTION_FOR_EMS_E5' { 'Microsoft365E5SecurityForEMS' }
        'INFORMATION_PROTECTION_COMPLIANCE' { 'Microsoft365E5Compliance' }
        'WACONEDRIVESTANDARD' { 'OneDriveForBusinessPlan1' }
        'WACONEDRIVEENTERPRISE' { 'OneDriveForBusinessPlan2' }
        'WIN_DEF_ATP' { 'WindowsDefenderForEndPoint' }
        'STREAM' { 'ThreatIntelligenceGov' }
        'TOPIC_EXPERIENCES' { 'TopicExperiences' }
        'POWERAPPS_INDIVIDUAL_USER' { 'PowerAppsAndLogicFlows' }
        'MICROSOFT_BUSINESS_CENTER' { 'MicrosoftBusinessCenter' }
        'SPZA_IW' { 'AppConnectIw' }
        'LITEPACK' { 'Office365SmallBusiness' }
        'LITEPACK_P2' { 'Office365SmallBusinessPremium' }
        'RIGHTSMANAGEMENT' { 'AzureInformationProtectionPlan1' }
        'TEAMS_FREE' { 'MicrosoftTeamsFree' }
        'TEAMS_EXPLORATORY' { 'MicrosoftTeamsExploratory' }
        'ATA' { 'AdvancedThreatAnalytics' }
        'ADALLOM_STANDALONE' { 'MicrosoftCloudAppSecurity' }
        'RMSBASIC' { 'AzureRMSBasic' }
        #endregion

        <# Deliberately omitted
        'EXCHANGEESSENTIALS' { 'ExchangeOnlineEssentials' } # Duplicate/Incongruent
        'EXCHANGE_S_ESSENTIALS' { 'ExchangeOnlineEssentialsS' } # Duplicate/Incongruent
        'POWERAPPS_VIRAL' { 'PowerAppsPlan2Trial' } # Promotional?
        'WINDOWS_STORE' { 'WindowsStoreForBusiness' } # License cannot be assigned to a user
        #>

        #region Standalone, Add-On & Calling Plans Licenses
        # Standalone Licenses
        'MCOIMP' { 'SkypeOnlinePlan1' }
        'MCOCAP' { 'CommonAreaPhone' }
        'PHONESYSTEM_VIRTUALUSER' { 'PhoneSystemVirtualUser' }
        'MCOSTANDARD' { 'SkypeOnlinePlan2' }
        'EXCHANGEDESKLESS' { 'ExchangeOnlineKiosk' }
        'EXCHANGESTANDARD' { 'ExchangeOnlinePlan1' }
        'EXCHANGEENTERPRISE' { 'ExchangeOnlinePlan2' }
        'EXCHANGEARCHIVE' { 'ExchangeOnlineArchivingForOnPrem' }
        'EXCHANGEARCHIVE_ADDON' { 'ExchangeOnlineArchivingForOnline' }
        'SHAREPOINTENTERPRISE' { 'SharePointEnterprise' }
        'SHAREPOINTSTANDARD' { 'SharePointStd' }
        'SHAREPOINTSTORAGE_GOV' { 'SharePointStorageGov' }
        'PROJECTCLIENT' { 'ProjectClient' }
        'EXCHANGETELCO' { 'ExchangeOnlinePop' }
        'INTUNE_A' { 'Intune' }
        'INTUNE_SMB' { 'IntuneSMB' }
        'IT_ACADEMY_AD' { 'MSImagineAcademy' }

        # Add-on Licenses
        'MCOEV' { 'PhoneSystem' }
        'MCOMEETADV' { 'AudioConferencing' }
        'MCOMEETADV_GOC' { 'AudioConferencingGOC' }
        'MCOMEETADV_GOV' { 'AudioConferencingGov' }

        'MCOEV_STUDENT' { 'PhoneSystemStudent' }
        'MCOEV_USGOV_GCCHIGH' { 'PhoneSystemUSGovGCCHigh' }
        'MCOEV_USGOV_DOD' { 'PhoneSystemUSGovDoD' }
        'MCOEV_TELSTRA' { 'PhoneSystemTestra' }
        'MCOEV_FACULTY' { 'PhoneSystemFaculty' }
        'MCOEV_DOD' { 'PhoneSystemDoD' }
        'MCOEVSMB_1' { 'PhoneSystemSMB' }
        'MCOEV_GCCHIGH' { 'PhoneSystemGCCHigh' }

        # Microsoft Calling Plans
        'MCOPSTNEAU2' { 'TelstraCallingForO365' }
        'MCOPSTN2' { 'InternationalCallingPlan' }
        'MCOPSTN1' { 'DomesticCallingPlan' }
        'MCOPSTN5' { 'DomesticCallingPlan120' }
        'MCOPSTN_5' { 'DomesticCallingPlan120b' }
        'MCOPSTNC' { 'CommunicationCredits' }
        #endregion

        <# Parameter names missing for Government Licenses #80
        'WINE5_GCC_COMPAT' { '' }
        #>

        default { '' }
      }

      # determining LicenseType
      if ( $srcProductPlans.Count -gt 1 ) {
        $LicenseType = 'Package'
        $IncludesTeams = ($srcProductPlans.ServicePlanName -like 'Teams*')
        $IncludesPhoneSystem = ( $srcProductPlans.ServicePlanName -like 'MCOEV*')
      }
      else {
        $LicenseType = 'Standalone'
        $LicenseType = switch -Regex ( $srcProductPlans.ServicePlanName ) {
          'PHONESYSTEM_VIRTUALUSER' { 'Standalone'; break }
          'MCOPSTN' { 'CallingPlan'; break }
          'MCOEV' { 'Add-On'; break }
          'MCOMEETADV' { 'Add-On'; break }
          'ADDON' { 'Add-On'; break }
          default { 'Standalone' }
        }
        $IncludesTeams = ($srcProductPlans.ServicePlanName -like 'Teams*')
        $IncludesPhoneSystem = ( $srcProductPlans.ServicePlanName -like 'MCOEV*')
      }

      # reworking ProductName into TitleCase
      $TextInfo = (Get-Culture).TextInfo
      $ProductName = $TextInfo.ToTitleCase($srcProductName.ToLower())

      #Normalising "SKYPE FOR BUSINESS PSTN" from ProductName for Calling Plans
      $StringToCut = 'Skype For Business Pstn '
      if ( $ProductName -match "^$StringToCut" ) {
        $ProductName = $ProductName.Substring($StringToCut.Length, $ProductName.Length - $StringToCut.Length)
      }
      $VerbosePreference = 'SilentlyContinue'
      $ProductName = Format-StringRemoveSpecialCharacter -String "$ProductName" -SpecialCharacterToKeep '()+ -'
      # Building Object
      try {
        [void]$Products.Add([TFTeamsLicense]::new( "$ProductName", "$srcSkuPartNumber", "$LicenseType", "$ParameterName", $IncludesTeams, $IncludesPhoneSystem, "$srcSkuId", $srcProductPlans))
      }
      catch {
        Write-Verbose "[TFTeamsLicense] Couldn't add entry for '$ProductName'" -Verbose
        $ProductsNotAdded += $ProductName
      }
    }

    # Output
    if ( $ProductsNotAdded.Count -gt 0 ) {
      Write-Warning -Message "The following Products could not be added: $ProductsNotAdded"
    }

    $ProductsSorted = $Products | Sort-Object ProductName | Sort-Object LicenseType -Desc
    if ($FilterRelevantForTeams) {
      $ProductsSorted = $ProductsSorted | Where-Object { $_.ParameterName -NE '' -or $_.IncludesTeams -or $_.IncludesPhoneSystem }
    }

    return $ProductsSorted

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"

  } #end
} #Get-AzureAdLicense
