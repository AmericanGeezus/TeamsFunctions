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
  20.11       NOV 2020 Release - Restructuring, Bugfixes and general overhaul. Also more Pester-Testing
  20.12       DEC 2020 Release - Added Progress bars, Performance improvements, and bugfixes

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
  ProductName         = "MICROSOFT 365 PHONE SYSTEM"
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
#endregion

# DotSourcing PS1 Files
Get-ChildItem -Filter *.ps1 -Path $PSScriptRoot\Public\Functions, $PSScriptRoot\Private\Functions -Recurse | ForEach-Object {
  . $_.FullName
}

# Adding manual Aliases (not recorded in Functions)
Set-Alias -Name Set-TeamsAutoAttendant -Value Set-CsAutoAttendant
Set-Alias -Name Set-TeamsAA -Value Set-CsAutoAttendant


# Exporting Module Members (Functions)
Export-ModuleMember -Function $(Get-ChildItem -Include *.ps1 -Path $PSScriptRoot\Public\Functions -Recurse).BaseName

# Exporting Module Members (Aliases)
Export-ModuleMember -Alias con, dis, pol, New-TeamsUVC, Set-TeamsUVC, Get-TeamsUVC, Find-TeamsUVC, Remove-TeamsUVC, Test-TeamsUVC, `
  New-TeamsRA, Set-TeamsRA, Get-TeamsRA, Find-TeamsRA, Remove-TeamsRA, New-TeamsRAassoc, Get-TeamsRAassoc, Remove-TeamsRAassoc, Remove-CsOnlineApplicationInstance, `
  New-TeamsCQ, Set-TeamsCQ, Get-TeamsCQ, Remove-TeamsCQ, New-TeamsAA, Set-TeamsAA, Set-TeamsAutoAttendant, Get-TeamsAA, Remove-TeamsAA, `
  New-TeamsAAPrompt, New-TeamsAASchedule, New-TeamsAAEntity, New-TeamsAAScope

# Exporting Module Members (Variables)
Export-ModuleMember -Variable TeamsLicenses, TeamsServicePlans

# SIG # Begin signature block
# MIIECAYJKoZIhvcNAQcCoIID+TCCA/UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULd+hnHTwr/fAvfh/7bTaWJV2
# qzCgggIZMIICFTCCAX6gAwIBAgIQa3i9Sh/NdbhOjG+ewKFPfjANBgkqhkiG9w0B
# AQUFADAlMSMwIQYDVQQDDBpEYXZpZCBFYmVyaGFyZHQgLSBDb2RlU2lnbjAeFw0y
# MDA2MTMxMTA4NTNaFw0yNDA2MTMwMDAwMDBaMCUxIzAhBgNVBAMMGkRhdmlkIEVi
# ZXJoYXJkdCAtIENvZGVTaWduMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3
# m6z32wDOJ/ZnUYR5tJaujtCN2MVrOYs/ZwSVJvralxDUKHSLAGdmKmO1H5hH4Nmv
# NBe1/L95AVDugTaoH9UK/snN9pcYJ7E7UqLH4ySqJuqE10VmpD2sRi3I2RDL1/eh
# weUut8B3G4bwrA3o2Iy4Y6Kd7IMUAZzUVWwl01jsPQIDAQABo0YwRDATBgNVHSUE
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUO8DeqyD0FHkF6JO8JT7syAeXJXAwDgYD
# VR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBBQUAA4GBAFCN2PtWoAvowM+pcxIV/gp2
# RB2rFyPfjLWjfAeKPfXmcfsMAPIoevTrKj3VAzzoF32wZRvdHk7jLssrhT0nmF7L
# 20n7K7RxJ3lccZ0MEdIHsmiklqbV+f9moVtXmgwwJzYkWekjIfrDUSdJeu0BYzR0
# H+8/FVd9YHgogHQN9t3hMYIBWTCCAVUCAQEwOTAlMSMwIQYDVQQDDBpEYXZpZCBF
# YmVyaGFyZHQgLSBDb2RlU2lnbgIQa3i9Sh/NdbhOjG+ewKFPfjAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQURQxzgfgGfXHvpGs06jzjJFcKCwYwDQYJKoZIhvcNAQEBBQAEgYBt2/9H
# Sp6WVW56xFX26VBPg6EhI4dCKKY5VpiipN4/3CAcJ8u9owgfoPY+SejJXNLDml2S
# pslhMopY7CPa3O9aG4tejz6EhjvoiUnAu/3LQODoZKQl1BEllVI8hKt4Dr1rF6qt
# qJpqVVlCAuCR/0IduwtpdgAk+CRr3WvumG+BEg==
# SIG # End signature block
