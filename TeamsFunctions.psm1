#Requires -Version 5.1
<#
  TeamsFunctions
  Module for Management of Teams Voice Configuration for Tenant and Users
  User Configuration for Voice, Creation and connection of Resource Accounts,
  Licensing of Objects for Calling Plans & Direct Routing,
  Creation and Management of Call Queues and Auto Attendants

  by David Eberhardt
  david@davideberhardt.at
  @MightyOrmus
  www.davideberhardt.at
  https://github.com/DEberhardt
  https://davideberhardt.wordpress.com/

  This Module is a Fork of the Module SkypeFunctions and built on the work of Jeff Brown.
  Jeff@JeffBrown.tech / @JeffWBrown / www.jeffbrown.tech / https://github.com/JeffBrownTech
  Individual Scripts incorporated into this Module are taken with the express permission of the original Author

  Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
  Always review any code and steps before applying to a production system to understand their full impact.

  # Versioning
  This Module follows the Versioning Convention Microsoft uses to show the Release Date in the Version number
  Major v20 is the the first one published in 2020, followed by Minor version for the Month.
  Subsequent Minor versions include the Day and are released as PreReleases
  Revisions are planned quarterly, but are currently on a monthly schedule until mature. PreReleases weekly.

  # Version History (abbreviated)
  1.0         Initial Version (as SkypeFunctions) - 02-OCT-2017
  20.04.17.1  Initial Version (as TeamsFunctions)
  20.05.03.1  MAY 2020 Release - First Publication - Refresh for Teams
  20.06.09.1  JUN 2020 Release - Added Session Connection & TeamsCallQueue Functions
  20.06.29.1  JUL 2020 Release - Added TeamsResourceAccount & TeamsResourceAccountAssociation Functions
  20.08       AUG 2020 Release - Added new License Functions, Shared Voicemail Support for TeamsCalLQueue
  20.09       SEP 2020 Release - Bugfixes
  20.10       OCT 2020 Release - Added TeamsUserVoiceConfig & TeamsAutoAttendant Functions

  20.10.xx-prerelease  Restructured TeamsFunctions in order to prepare it for adding Pester tests.
              Adding Folder Structure Private/Public with Subfolders Functions & Tests

#>

#region Licensing Table
# $PSCustomObject created to simplifying any licensing related lookup

#region Licenses
[System.Collections.ArrayList]$TeamsLicenses = @()
#region LicensePackages (which include Teams)
$TeamsLicensesEntry01 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 A3 for faculty"
  ProductName         = "Microsoft 365 A3 for faculty"
  SkuPartNumber       = "M365EDU_A3_FACULTY"
  SkuId               = "4b590615-0888-425a-a965-b3bf7789848d"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365A3faculty"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry01)

$TeamsLicensesEntry02 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 A3 for students"
  ProductName         = "Microsoft 365 A3 for students"
  SkuPartNumber       = "M365EDU_A3_STUDENT"
  SkuId               = "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365A3students"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry02)

$TeamsLicensesEntry03 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 A5 for faculty"
  ProductName         = "Microsoft 365 A5 for faculty"
  SkuPartNumber       = "M365EDU_A5_FACULTY"
  SkuId               = "e97c048c-37a4-45fb-ab50-922fbf07a370"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365A5faculty"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry03)

$TeamsLicensesEntry04 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 A5 for students"
  ProductName         = "Microsoft 365 A5 for students"
  SkuPartNumber       = "M365EDU_A5_STUDENT"
  SkuId               = "46c119d4-0379-4a9d-85e4-97c66d3f909e"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365A5students"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry04)

$TeamsLicensesEntry05 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 Business Basic (O365)"
  ProductName         = "MICROSOFT 365 BUSINESS BASIC"
  SkuPartNumber       = "O365_BUSINESS_ESSENTIALS"
  SkuId               = "3b555118-da6a-4418-894f-7df1e2096870"
  LicenseType         = "LicensePackage"
  ParameterName       = ""
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry05)

$TeamsLicensesEntry06 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 Business Basic (SMB)"
  ProductName         = "MICROSOFT 365 BUSINESS BASIC"
  SkuPartNumber       = "SMB_BUSINESS_ESSENTIALS"
  SkuId               = "dab7782a-93b1-4074-8bb1-0e61318bea0b"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365BusinessBasic"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry06)

$TeamsLicensesEntry07 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 Business Standard (O365)"
  ProductName         = "MICROSOFT 365 BUSINESS STANDARD"
  SkuPartNumber       = "O365_BUSINESS_PREMIUM"
  SkuId               = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"
  LicenseType         = "LicensePackage"
  ParameterName       = ""
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry07)

$TeamsLicensesEntry08 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 Business Standard (SMB)"
  ProductName         = "MICROSOFT 365 BUSINESS STANDARD"
  SkuPartNumber       = "SMB_BUSINESS_PREMIUM"
  SkuId               = "ac5cef5d-921b-4f97-9ef3-c99076e5470f"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365BusinessStandard"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry08)

$TeamsLicensesEntry09 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 Business Premium"
  ProductName         = "MICROSOFT 365 BUSINESS PREMIUM"
  SkuPartNumber       = "SPB"
  SkuId               = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365BusinessPremium"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry09)

$TeamsLicensesEntry10 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 E3"
  ProductName         = "MICROSOFT 365 E3"
  SkuPartNumber       = "SPE_E3"
  SkuId               = "05e9a617-0261-4cee-bb44-138d3ef5d965"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365E3"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry10)

$TeamsLicensesEntry11 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 E5"
  ProductName         = "MICROSOFT 365 E5"
  SkuPartNumber       = "SPE_E5"
  SkuId               = "06ebc4ee-1bb5-47dd-8120-11324bc54e06"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365E5"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry11)

$TeamsLicensesEntry12 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 F1"
  ProductName         = "Microsoft 365 F1"
  SkuPartNumber       = "M365_F1"
  SkuId               = "44575883-256e-4a79-9da4-ebe9acabe2b2"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365F1"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry12)

$TeamsLicensesEntry13 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 F3"
  ProductName         = "Microsoft 365 F3"
  SkuPartNumber       = "SPE_F1"
  SkuId               = "66b55226-6b4f-492c-910c-a3b7a3c9d993"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365F3"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry13)

$TeamsLicensesEntry14 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 A5 for faculty"
  ProductName         = "Office 365 A5 for faculty"
  SkuPartNumber       = "ENTERPRISEPREMIUM_FACULTY"
  SkuId               = "a4585165-0533-458a-97e3-c400570268c4"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365A5faculty"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry14)

$TeamsLicensesEntry15 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 A5 for students"
  ProductName         = "Office 365 A5 for students"
  SkuPartNumber       = "ENTERPRISEPREMIUM_STUDENT"
  SkuId               = "ee656612-49fa-43e5-b67e-cb1fdf7699df"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365A5students"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry15)

$TeamsLicensesEntry16 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E1"
  ProductName         = "OFFICE 365 E1"
  SkuPartNumber       = "STANDARDPACK"
  SkuId               = "18181a46-0d4e-45cd-891e-60aabd171b4e"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E1"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry16)

$TeamsLicensesEntry17 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E2"
  ProductName         = "OFFICE 365 E2"
  SkuPartNumber       = "STANDARDWOFFPACK"
  SkuId               = "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E2"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry17)

$TeamsLicensesEntry18 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E3"
  ProductName         = "OFFICE 365 E3"
  SkuPartNumber       = "ENTERPRISEPACK"
  SkuId               = "6fd2c87f-b296-42f0-b197-1e91e994b900"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E3"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry18)

$TeamsLicensesEntry19 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E3 Developer"
  ProductName         = "OFFICE 365 E3 DEVELOPER"
  SkuPartNumber       = "DEVELOPERPACK"
  SkuId               = "189a915c-fe4f-4ffa-bde4-85b9628d07a0"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E3Dev"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry19)

$TeamsLicensesEntry20 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E4"
  ProductName         = "OFFICE 365 E4"
  SkuPartNumber       = "ENTERPRISEWITHSCAL"
  SkuId               = "1392051d-0cb9-4b7a-88d5-621fee5e8711"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E4"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry20)

$TeamsLicensesEntry21 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E5"
  ProductName         = "OFFICE 365 E5"
  SkuPartNumber       = "ENTERPRISEPREMIUM"
  SkuId               = "c7df2760-2c81-4ef7-b578-5b5392b571df"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E5"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry21)

$TeamsLicensesEntry22 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E5 without Audio Conferencing"
  ProductName         = "OFFICE 365 E5 WITHOUT AUDIO CONFERENCING"
  SkuPartNumber       = "ENTERPRISEPREMIUM_NOPSTNCONF"
  SkuId               = "26d45bd9-adf1-46cd-a9e1-51e9a5524128"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E5NoAudioConferencing"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry22)

$TeamsLicensesEntry23 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 F1"
  ProductName         = "OFFICE 365 F1"
  SkuPartNumber       = "DESKLESSPACK"
  SkuId               = "4b585984-651b-448a-9e53-3b10f069cf7f"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365F1"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry23)

$TeamsLicensesEntry24 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 E3_USGOV_DOD"
  ProductName         = "Microsoft 365 E3_USGOV_DOD"
  SkuPartNumber       = "SPE_E3_USGOV_DOD"
  SkuId               = "d61d61cc-f992-433f-a577-5bd016037eeb"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365E3USGOVDOD"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry24)

$TeamsLicensesEntry25 = [PSCustomObject][ordered]@{
  FriendlyName        = "Microsoft 365 E3_USGOV_GCCHIGH"
  ProductName         = "Microsoft 365 E3_USGOV_GCCHIGH"
  SkuPartNumber       = "SPE_E3_USGOV_GCCHIGH"
  SkuId               = "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658"
  LicenseType         = "LicensePackage"
  ParameterName       = "Microsoft365E3USGOVGCCHIGH"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry25)


$TeamsLicensesEntry26 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E3_USGOV_DOD"
  ProductName         = "Office 365 E3_USGOV_DOD"
  SkuPartNumber       = "ENTERPRISEPACK_USGOV_DOD"
  SkuId               = "b107e5a3-3e60-4c0d-a184-a7e4395eb44c"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E3USGOVDOD"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry26)

$TeamsLicensesEntry27 = [PSCustomObject][ordered]@{
  FriendlyName        = "Office 365 E3_USGOV_GCCHIGH"
  ProductName         = "Office 365 E3_USGOV_GCCHIGH"
  SkuPartNumber       = "ENTERPRISEPACK_USGOV_GCCHIGH"
  SkuId               = "aea38a85-9bd5-4981-aa00-616b411205bf"
  LicenseType         = "LicensePackage"
  ParameterName       = "Office365E3USGOVGCCHIGH"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry27)
#endregion

#region Standalone Licenses (incl. either Teams or PhoneSystem)
$TeamsLicensesEntry28 = [PSCustomObject][ordered]@{
  FriendlyName        = "Common Area Phone"
  ProductName         = "Common Area Phone"
  SkuPartNumber       = "MCOCAP"
  SkuId               = "295a8eb0-f78d-45c7-8b5b-1eed5ed02dff"
  LicenseType         = "StandaloneLicense"
  ParameterName       = "CommonAreaPhone"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry28)

$TeamsLicensesEntry29 = [PSCustomObject][ordered]@{
  FriendlyName        = "Phone System - Virtual User License"
  ProductName         = "Phone System - Virtual User License"
  SkuPartNumber       = "PHONESYSTEM_VIRTUALUSER"
  SkuId               = "440eaaa8-b3e0-484b-a8be-62870b9ba70a"
  LicenseType         = "StandaloneLicense"
  ParameterName       = "PhoneSystemVirtualUser"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry29)

$TeamsLicensesEntry30 = [PSCustomObject][ordered]@{
  FriendlyName        = "Skype for Business Online (Plan 2)"
  ProductName         = "SKYPE FOR BUSINESS ONLINE (PLAN 2)"
  SkuPartNumber       = "MCOSTANDARD"
  SkuId               = "d42c793f-6c78-4f43-92ca-e8f6a02b035f"
  LicenseType         = "StandaloneLicense"
  ParameterName       = "SkypeOnlinePlan2"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry30)
#endregion

#region Add-On Licenses
$TeamsLicensesEntry31 = [PSCustomObject][ordered]@{
  FriendlyName        = "Phone System"
  ProductName         = "SKYPE FOR BUSINESS CLOUD PBX"
  SkuPartNumber       = "MCOEV"
  SkuId               = "e43b5b99-8dfb-405f-9987-dc307f34bcbd"
  LicenseType         = "AddOnLicense"
  ParameterName       = "PhoneSystem"
  IncludesTeams       = $TRUE
  IncludesPhoneSystem = $TRUE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry31)

$TeamsLicensesEntry32 = [PSCustomObject][ordered]@{
  FriendlyName        = "Audio Conferencing"
  ProductName         = "AUDIO CONFERENCING"
  SkuPartNumber       = "MCOMEETADV"
  SkuId               = "0c266dff-15dd-4b49-8397-2bb16070ed52"
  LicenseType         = "AddOnLicense"
  ParameterName       = "AudioConferencing"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry32)

#endregion

#region Additional Licenses to Query (Non-Teams Licenses)
$TeamsLicensesEntry33 = [PSCustomObject][ordered]@{
  FriendlyName        = "Skype for Business Online (Plan 1)"
  ProductName         = "SKYPE FOR BUSINESS ONLINE (PLAN 1)"
  SkuPartNumber       = "MCOIMP"
  SkuId               = "b8b749f8-a4ef-4887-9539-c95b1eaa5db7"
  LicenseType         = "StandaloneLicense"
  ParameterName       = ""
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry33)
#endregion

#region Microsoft Calling Plans
$TeamsLicensesEntry34 = [PSCustomObject][ordered]@{
  FriendlyName        = "Domestic and International Calling Plan"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC AND INTERNATIONAL CALLING"
  SkuPartNumber       = "MCOPSTN2"
  SkuId               =	"d3b4fe1f-9992-4930-8acb-ca6ec609365e"
  LicenseType         = "CallingPlan"
  ParameterName       = "InternationalCallingPlan"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry34)

$TeamsLicensesEntry35 = [PSCustomObject][ordered]@{
  FriendlyName        = "Domestic Calling Plan"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING"
  SkuPartNumber       = "MCOPSTN1"
  SkuId               = "0dab259f-bf13-4952-b7f8-7db8f131b28d"
  LicenseType         = "CallingPlan"
  ParameterName       = "DomesticCallingPlan"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry35)

$TeamsLicensesEntry36 = [PSCustomObject][ordered]@{
  FriendlyName        = "Domestic Calling Plan (120 Minutes)"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"
  SkuPartNumber       = "MCOPSTN5"
  SkuId               = "54a152dc-90de-4996-93d2-bc47e670fc06"
  LicenseType         = "CallingPlan"
  ParameterName       = "DomesticCallingPlan120"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry36)

$TeamsLicensesEntry37 = [PSCustomObject][ordered]@{
  FriendlyName        = "Domestic Calling Plan (240 Minutes)"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (240 Minutes)"
  SkuPartNumber       = "MCOPSTN6"
  SkuId               = ""
  LicenseType         = "CallingPlan"
  ParameterName       = ""
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry37)

$TeamsLicensesEntry38 = [PSCustomObject][ordered]@{
  FriendlyName        = "Communication Credits"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"
  SkuPartNumber       = "MCOPSTNC"
  SkuId               = "47794cd0-f0e5-45c5-9033-2eb6b5fc84e0"
  LicenseType         = "CallingPlan"
  ParameterName       = "CommunicationCredits"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry38)
$TeamsLicensesEntry39 = [PSCustomObject][ordered]@{
  FriendlyName        = "Domestic Calling Plan (120 Minutes)(2)"
  ProductName         = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"
  SkuPartNumber       = "MCOPSTN_5"
  SkuId               = "54a152dc-90de-4996-93d2-bc47e670fc06"
  LicenseType         = "CallingPlan"
  ParameterName       = "DomesticCallingPlan120b"
  IncludesTeams       = $FALSE
  IncludesPhoneSystem = $FALSE
}
[void]$TeamsLicenses.Add($TeamsLicensesEntry39)
#endregion
#endregion

#region ServicePlans
[System.Collections.ArrayList]$TeamsServicePlans = @()
#region Main Service Plans
$TeamsServicePlansEntry01 = [PSCustomObject][ordered]@{
  FriendlyName     = "Teams"
  ProductName      = "Teams"
  ServicePlanName  = "TEAMS1"
  ServicePlanId    = "57ff2da0-773e-42df-b2af-ffb7a2317929"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry01)

$TeamsServicePlansEntry02 = [PSCustomObject][ordered]@{
  FriendlyName     = "Teams AR DoD"
  ProductName      = "Teams AR DoD"
  ServicePlanName  = "TEAMS_AR_DOD"
  ServicePlanId    = "fd500458-c24c-478e-856c-a6067a8376cd"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry02)

$TeamsServicePlansEntry03 = [PSCustomObject][ordered]@{
  FriendlyName     = "Teams AR GCC High"
  ProductName      = "Teams AR GCC High"
  ServicePlanName  = "TEAMS_AR_GCCHIGH"
  ServicePlanId    = "9953b155-8aef-4c56-92f3-72b0487fce41"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry03)

$TeamsServicePlansEntry04 = [PSCustomObject][ordered]@{
  FriendlyName     = "Skype Online"
  ProductName      = "Skype for Business Online"
  ServicePlanName  = "MCOSTANDARD"
  ServicePlanId    = "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry04)

$TeamsServicePlansEntry05 = [PSCustomObject][ordered]@{
  FriendlyName     = "Audio Conferencing"
  ProductName      = "Audio Conferencing"
  ServicePlanName  = "MCOMEETADV"
  ServicePlanId    = "3e26ee1f-8a5f-4d52-aee2-b81ce45c8f40"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry05)

$TeamsServicePlansEntry06 = [PSCustomObject][ordered]@{
  FriendlyName     = "Phone System"
  ProductName      = "Phone System"
  ServicePlanName  = "MCOEV"
  ServicePlanId    = "4828c8ec-dc2e-4779-b502-87ac9ce28ab7"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry06)

$TeamsServicePlansEntry07 = [PSCustomObject][ordered]@{
  FriendlyName     = "Phone System - Virtual User"
  ProductName      = "Phone System - Virtual User"
  ServicePlanName  = "MCOEV_VIRTUALUSER"
  ServicePlanId    = "f47330e9-c134-43b3-9993-e7f004506889"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry07)
#endregion

#region Additional Service Plans
$TeamsServicePlansEntry08 = [PSCustomObject][ordered]@{
  FriendlyName     = "Skype Online (Midmarket)"
  ProductName      = "Skype for Business Online (Plan 2)"
  ServicePlanName  = "MCOSTANDARD_MIDMARKET"
  ServicePlanId    = "b2669e95-76ef-4e7e-a367-002f60a39f3e"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry08)
#endregion

#region Calling Plans
$TeamsServicePlansEntry09 = [PSCustomObject][ordered]@{
  FriendlyName     = "International Calling Plan"
  ProductName      = "International Calling Plan"
  ServicePlanName  = "MCOPSTN2"
  ServicePlanId    = "5a10155d-f5c1-411a-a8ec-e99aae125390"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry09)

$TeamsServicePlansEntry10 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan"
  ProductName      = "Domestic Calling Plan (3000 min US / 1200 min EU plans)"
  ServicePlanName  = "MCOPSTN1"
  ServicePlanId    = "4ed3ff63-69d7-4fb7-b984-5aec7f605ca8"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry10)

$TeamsServicePlansEntry11 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan (120 min calling plan)"
  ProductName      = "Domestic Calling Plan (120 min calling plan)"
  ServicePlanName  = "MCOPSTN5"
  ServicePlanId    = "54a152dc-90de-4996-93d2-bc47e670fc06"
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry11)

$TeamsServicePlansEntry12 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan (240 min calling plan)"
  ProductName      = "Domestic Calling Plan (240 min calling plan)"
  ServicePlanName  = "MCOPSTN6"
  ServicePlanId    = ""
  RelevantForTeams = $FALSE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry12)

$TeamsServicePlansEntry13 = [PSCustomObject][ordered]@{
  FriendlyName     = "Communications Credits"
  ProductName      = "Communications Credits"
  ServicePlanName  = "MCOPSTNC"
  ServicePlanId    = ""
  RelevantForTeams = $TRUE
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntry13)
#endregion


<# Template
$TeamsLicensesEntryXX = [PSCustomObject][ordered]@{
  FriendlyName        = ""
  ProductName         = ""
  SkuPartNumber       = ""
  SkuId               = ""
  LicenseType         = ""
  ParameterName       = ""
  IncludesTeams       = $
  IncludesPhoneSystem = $
}
[void]$TeamsLicenses.Add($TeamsLicensesEntryXX)

$TeamsServicePlansEntryXX = [PSCustomObject][ordered]@{
  FriendlyName        = ""
  ProductName         = ""
  ServicePlanName     = ""
  ServicePlanId               = ""
  RelevantForTeams    = $
}
[void]$TeamsServicePlans.Add($TeamsServicePlansEntryXX)

#>
#endregion

#region Additional Sku defintions (not in the Array)
<# Additional Licenses, not in the Array
$SkuID = "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7"; $SkuPartNumber = "AAD_BASIC"; $ProductName = "AZURE ACTIVE DIRECTORY BASIC"
$SkuID = "078d2b04-f1bd-4111-bbd4-b4b1b354cef4"; $SkuPartNumber = "AAD_PREMIUM"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P1"
$SkuID = "84a661c4-e949-4bd2-a560-ed7766fcaf2b"; $SkuPartNumber = "AAD_PREMIUM_P2"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P2"
$SkuID = "c52ea49f-fe5d-4e95-93ba-1de91d380f89"; $SkuPartNumber = "RIGHTSMANAGEMENT"; $ProductName = "AZURE INFORMATION PROTECTION PLAN 1"
$SkuID = "ea126fc5-a19e-42e2-a731-da9d437bffcf"; $SkuPartNumber = "DYN365_ENTERPRISE_PLAN1"; $ProductName = "DYNAMICS 365 CUSTOMER ENGAGEMENT PLAN ENTERPRISE EDITION"
$SkuID = "749742bf-0d37-4158-a120-33567104deeb"; $SkuPartNumber = "DYN365_ENTERPRISE_CUSTOMER_SERVICE"; $ProductName = "DYNAMICS 365 FOR CUSTOMER SERVICE ENTERPRISE EDITION"
$SkuID = "cc13a803-544e-4464-b4e4-6d6169a138fa"; $SkuPartNumber = "DYN365_FINANCIALS_BUSINESS_SKU"; $ProductName = "DYNAMICS 365 FOR FINANCIALS BUSINESS EDITION"
$SkuID = "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc"; $SkuPartNumber = "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE"; $ProductName = "DYNAMICS 365 FOR SALES AND CUSTOMER SERVICE ENTERPRISE EDITION"
$SkuID = "1e1a282c-9c54-43a2-9310-98ef728faace"; $SkuPartNumber = "DYN365_ENTERPRISE_SALES"; $ProductName = "DYNAMICS 365 FOR SALES ENTERPRISE EDITION"
$SkuID = "8e7a3d30-d97d-43ab-837c-d7701cef83dc"; $SkuPartNumber = "DYN365_ENTERPRISE_TEAM_MEMBERS"; $ProductName = "DYNAMICS 365 FOR TEAM MEMBERS ENTERPRISE EDITION"
$SkuID = "ccba3cfe-71ef-423a-bd87-b6df3dce59a9"; $SkuPartNumber = "Dynamics_365_for_Operations"; $ProductName = "DYNAMICS 365 UNF OPS PLAN ENT EDITION"
$SkuID = "efccb6f7-5641-4e0e-bd10-b4976e1bf68e"; $SkuPartNumber = "EMS"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E3"
$SkuID = "b05e124f-c7cc-45a0-a6aa-8cf78c946968"; $SkuPartNumber = "EMSPREMIUM"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E5"
$SkuID = "4b9405b0-7788-4568-add1-99614e613b69"; $SkuPartNumber = "EXCHANGESTANDARD"; $ProductName = "EXCHANGE ONLINE (PLAN 1)"
$SkuID = "19ec0d23-8335-4cbd-94ac-6050e30712fa"; $SkuPartNumber = "EXCHANGEENTERPRISE"; $ProductName = "EXCHANGE ONLINE (PLAN 2)"
$SkuID = "ee02fd1b-340e-4a4b-b355-4a514e4c8943"; $SkuPartNumber = "EXCHANGEARCHIVE_ADDON"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE ONLINE"
$SkuID = "90b5e015-709a-4b8b-b08e-3200f994494c"; $SkuPartNumber = "EXCHANGEARCHIVE"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE SERVER"
$SkuID = "7fc0182e-d107-4556-8329-7caaa511197b"; $SkuPartNumber = "EXCHANGEESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"
$SkuID = "e8f81a67-bd96-4074-b108-cf193eb9433b"; $SkuPartNumber = "EXCHANGE_S_ESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"
$SkuID = "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82"; $SkuPartNumber = "EXCHANGEDESKLESS"; $ProductName = "EXCHANGE ONLINE KIOSK"
$SkuID = "cb0a98a8-11bc-494c-83d9-c1b1ac65327e"; $SkuPartNumber = "EXCHANGETELCO"; $ProductName = "EXCHANGE ONLINE POP"
$SkuID = "061f9ace-7d42-4136-88ac-31dc755f143f"; $SkuPartNumber = "INTUNE_A"; $ProductName = "INTUNE"
$SkuID = "184efa21-98c3-4e5d-95ab-d07053a96e67"; $SkuPartNumber = "INFORMATION_PROTECTION_COMPLIANCE"; $ProductName = "Microsoft 365 E5 Compliance"
$SkuID = "26124093-3d78-432b-b5dc-48bf992543d5"; $SkuPartNumber = "IDENTITY_THREAT_PROTECTION"; $ProductName = "Microsoft 365 E5 Security"
$SkuID = "44ac31e7-2999-4304-ad94-c948886741d4"; $SkuPartNumber = "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"; $ProductName = "Microsoft 365 E5 Security for EMS E5"
$SkuID = "111046dd-295b-4d6d-9724-d52ac90bd1f2"; $SkuPartNumber = "WIN_DEF_ATP"; $ProductName = "Microsoft Defender Advanced Threat Protection"
$SkuID = "d17b27af-3f49-4822-99f9-56a661538792"; $SkuPartNumber = "CRMSTANDARD"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE"
$SkuID = "906af65a-2970-46d5-9b58-4e9aa50f0657"; $SkuPartNumber = "CRMPLAN2"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE BASIC"
$SkuID = "ba9a34de-4489-469d-879c-0f0f145321cd"; $SkuPartNumber = "IT_ACADEMY_AD"; $ProductName = "MS IMAGINE ACADEMY"
$SkuID = "1b1b1f7a-8355-43b6-829f-336cfccb744c"; $SkuPartNumber = "EQUIVIO_ANALYTICS"; $ProductName = "Office 365 Advanced Compliance"
$SkuID = "4ef96642-f096-40de-a3e9-d83fb2f90211"; $SkuPartNumber = "ATP_ENTERPRISE"; $ProductName = "Office 365 Advanced Threat Protection (Plan 1)"
$SkuID = "04a7fb0d-32e0-4241-b4f5-3f7618cd1162"; $SkuPartNumber = "MIDSIZEPACK"; $ProductName = "OFFICE 365 MIDSIZE BUSINESS"
$SkuID = "c2273bd0-dff7-4215-9ef5-2c7bcfb06425"; $SkuPartNumber = "OFFICESUBSCRIPTION"; $ProductName = "OFFICE 365 PROPLUS"
$SkuID = "bd09678e-b83c-4d3f-aaba-3dad4abd128b"; $SkuPartNumber = "LITEPACK"; $ProductName = "OFFICE 365 SMALL BUSINESS"
$SkuID = "fc14ec4a-4169-49a4-a51e-2c852931814b"; $SkuPartNumber = "LITEPACK_P2"; $ProductName = "OFFICE 365 SMALL BUSINESS PREMIUM"
$SkuID = "e6778190-713e-4e4f-9119-8b8238de25df"; $SkuPartNumber = "WACONEDRIVESTANDARD"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 1)"
$SkuID = "ed01faf2-1d88-4947-ae91-45ca18703a96"; $SkuPartNumber = "WACONEDRIVEENTERPRISE"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 2)"
$SkuID = "b30411f5-fea1-4a59-9ad9-3db7c7ead579"; $SkuPartNumber = "POWERAPPS_PER_USER"; $ProductName = "POWER APPS PER USER PLAN"
$SkuID = "45bc2c81-6072-436a-9b0b-3b12eefbc402"; $SkuPartNumber = "POWER_BI_ADDON"; $ProductName = "POWER BI FOR OFFICE 365 ADD-ON"
$SkuID = "f8a1db68-be16-40ed-86d5-cb42ce701560"; $SkuPartNumber = "POWER_BI_PRO"; $ProductName = "POWER BI PRO"
$SkuID = "a10d5e58-74da-4312-95c8-76be4e5b75a0"; $SkuPartNumber = "PROJECTCLIENT"; $ProductName = "PROJECT FOR OFFICE 365"
$SkuID = "776df282-9fc0-4862-99e2-70e561b9909e"; $SkuPartNumber = "PROJECTESSENTIALS"; $ProductName = "PROJECT ONLINE ESSENTIALS"
$SkuID = "09015f9f-377f-4538-bbb5-f75ceb09358a"; $SkuPartNumber = "PROJECTPREMIUM"; $ProductName = "PROJECT ONLINE PREMIUM"
$SkuID = "2db84718-652c-47a7-860c-f10d8abbdae3"; $SkuPartNumber = "PROJECTONLINE_PLAN_1"; $ProductName = "PROJECT ONLINE PREMIUM WITHOUT PROJECT CLIENT"
$SkuID = "53818b1b-4a27-454b-8896-0dba576410e6"; $SkuPartNumber = "PROJECTPROFESSIONAL"; $ProductName = "PROJECT ONLINE PROFESSIONAL"
$SkuID = "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c"; $SkuPartNumber = "PROJECTONLINE_PLAN_2"; $ProductName = "PROJECT ONLINE WITH PROJECT FOR OFFICE 365"
$SkuID = "1fc08a02-8b3d-43b9-831e-f76859e04e1a"; $SkuPartNumber = "SHAREPOINTSTANDARD"; $ProductName = "SHAREPOINT ONLINE (PLAN 1)"
$SkuID = "a9732ec9-17d9-494c-a51c-d6b45b384dcb"; $SkuPartNumber = "SHAREPOINTENTERPRISE"; $ProductName = "SHAREPOINT ONLINE (PLAN 2)"
$SkuID = "4b244418-9658-4451-a2b8-b5e2b364e9bd"; $SkuPartNumber = "VISIOONLINE_PLAN1"; $ProductName = "VISIO ONLINE PLAN 1"
$SkuID = "c5928f49-12ba-48f7-ada3-0d743a3601d5"; $SkuPartNumber = "VISIOCLIENT"; $ProductName = "VISIO Online Plan 2"
$SkuID = "cb10e6cd-9da4-4992-867b-67546b1db821"; $SkuPartNumber = "WIN10_PRO_ENT_SUB"; $ProductName = "WINDOWS 10 ENTERPRISE E3"
$SkuID = "488ba24a-39a9-4473-8ee5-19291e71b002"; $SkuPartNumber = "WIN10_VDA_E5"; $ProductName = "Windows 10 Enterprise E5"
#>
#endregion
#endregion


# DotSourcing PS1 Files
Get-ChildItem -Filter *.ps1 -Path Public\Functions, Private\Functions -Recurse | ForEach-Object {
  . $_.FullName
}

# Exporting Module Members (Functions, Aliases)
#CHECK Aliases are integrated in Functions
Get-ChildItem -Filter *.ps1 -Path Public\Functions -Recurse | ForEach-Object {
  Export-ModuleMember $_.BaseName
}

# Exporting Module Members (Variables)
Export-ModuleMember -Variable TeamsLicenses, TeamsServicePlans