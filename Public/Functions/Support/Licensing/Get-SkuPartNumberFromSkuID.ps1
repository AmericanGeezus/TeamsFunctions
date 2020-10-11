# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    01-AUG-2020
# Status:     Live




function Get-SkuPartNumberFromSkuID {
  <#
	.SYNOPSIS
		Returns FriendlyName from SkuID
	.DESCRIPTION
		Returns SkuPartNumber or ProductName for any given SkuID
	.PARAMETER SkuId
		Identity of the License
	.PARAMETER Output
		Changes the Output Object. Can Return ProductName or SkuPartNumber (default)
  .EXAMPLE
    Get-SkuPartNumberFromSkuID e43b5b99-8dfb-405f-9987-dc307f34bcbd [-Output SkuPartNumber]
    Returns the SkuPartNumber MCOEV (PhoneSystem) (default)
  .EXAMPLE
    Get-SkuPartNumberFromSkuID e43b5b99-8dfb-405f-9987-dc307f34bcbd -Output ProductName
    Returns the ProductName "SKYPE FOR BUSINESS CLOUD PBX" for MCOEV (PhoneSystem)
  .FUNCTIONALITY
		Helper Function for Licensing, translating ID to FriendlyName
	#>

  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuID,

    [Parameter(Mandatory = $false, HelpMessage = "Desired Output, SkuPartNumber or ProductName; Default: SkuPartNumber")]
    [ValidateSet("SkuPartNumber", "ProductName")]
    [String]$Output = "SkuPartNumber"
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    switch ($SkuID) {
      "0c266dff-15dd-4b49-8397-2bb16070ed52" { $SkuPartNumber = "MCOMEETADV"; $ProductName = "AUDIO CONFERENCING"; break }
      "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7" { $SkuPartNumber = "AAD_BASIC"; $ProductName = "AZURE ACTIVE DIRECTORY BASIC"; break }
      "078d2b04-f1bd-4111-bbd4-b4b1b354cef4" { $SkuPartNumber = "AAD_PREMIUM"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P1"; break }
      "84a661c4-e949-4bd2-a560-ed7766fcaf2b" { $SkuPartNumber = "AAD_PREMIUM_P2"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P2"; break }
      "c52ea49f-fe5d-4e95-93ba-1de91d380f89" { $SkuPartNumber = "RIGHTSMANAGEMENT"; $ProductName = "AZURE INFORMATION PROTECTION PLAN 1"; break }
      "ea126fc5-a19e-42e2-a731-da9d437bffcf" { $SkuPartNumber = "DYN365_ENTERPRISE_PLAN1"; $ProductName = "DYNAMICS 365 CUSTOMER ENGAGEMENT PLAN ENTERPRISE EDITION"; break }
      "749742bf-0d37-4158-a120-33567104deeb" { $SkuPartNumber = "DYN365_ENTERPRISE_CUSTOMER_SERVICE"; $ProductName = "DYNAMICS 365 FOR CUSTOMER SERVICE ENTERPRISE EDITION"; break }
      "cc13a803-544e-4464-b4e4-6d6169a138fa" { $SkuPartNumber = "DYN365_FINANCIALS_BUSINESS_SKU"; $ProductName = "DYNAMICS 365 FOR FINANCIALS BUSINESS EDITION"; break }
      "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc" { $SkuPartNumber = "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE"; $ProductName = "DYNAMICS 365 FOR SALES AND CUSTOMER SERVICE ENTERPRISE EDITION"; break }
      "1e1a282c-9c54-43a2-9310-98ef728faace" { $SkuPartNumber = "DYN365_ENTERPRISE_SALES"; $ProductName = "DYNAMICS 365 FOR SALES ENTERPRISE EDITION"; break }
      "8e7a3d30-d97d-43ab-837c-d7701cef83dc" { $SkuPartNumber = "DYN365_ENTERPRISE_TEAM_MEMBERS"; $ProductName = "DYNAMICS 365 FOR TEAM MEMBERS ENTERPRISE EDITION"; break }
      "ccba3cfe-71ef-423a-bd87-b6df3dce59a9" { $SkuPartNumber = "Dynamics_365_for_Operations"; $ProductName = "DYNAMICS 365 UNF OPS PLAN ENT EDITION"; break }
      "efccb6f7-5641-4e0e-bd10-b4976e1bf68e" { $SkuPartNumber = "EMS"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E3"; break }
      "b05e124f-c7cc-45a0-a6aa-8cf78c946968" { $SkuPartNumber = "EMSPREMIUM"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E5"; break }
      "4b9405b0-7788-4568-add1-99614e613b69" { $SkuPartNumber = "EXCHANGESTANDARD"; $ProductName = "EXCHANGE ONLINE (PLAN 1)"; break }
      "19ec0d23-8335-4cbd-94ac-6050e30712fa" { $SkuPartNumber = "EXCHANGEENTERPRISE"; $ProductName = "EXCHANGE ONLINE (PLAN 2)"; break }
      "ee02fd1b-340e-4a4b-b355-4a514e4c8943" { $SkuPartNumber = "EXCHANGEARCHIVE_ADDON"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE ONLINE"; break }
      "90b5e015-709a-4b8b-b08e-3200f994494c" { $SkuPartNumber = "EXCHANGEARCHIVE"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE SERVER"; break }
      "7fc0182e-d107-4556-8329-7caaa511197b" { $SkuPartNumber = "EXCHANGEESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break }
      "e8f81a67-bd96-4074-b108-cf193eb9433b" { $SkuPartNumber = "EXCHANGE_S_ESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break }
      "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82" { $SkuPartNumber = "EXCHANGEDESKLESS"; $ProductName = "EXCHANGE ONLINE KIOSK"; break }
      "cb0a98a8-11bc-494c-83d9-c1b1ac65327e" { $SkuPartNumber = "EXCHANGETELCO"; $ProductName = "EXCHANGE ONLINE POP"; break }
      "061f9ace-7d42-4136-88ac-31dc755f143f" { $SkuPartNumber = "INTUNE_A"; $ProductName = "INTUNE"; break }
      "b17653a4-2443-4e8c-a550-18249dda78bb" { $SkuPartNumber = "M365EDU_A1"; $ProductName = "Microsoft 365 A1"; break }
      "4b590615-0888-425a-a965-b3bf7789848d" { $SkuPartNumber = "M365EDU_A3_FACULTY"; $ProductName = "Microsoft 365 A3 for faculty"; break }
      "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121" { $SkuPartNumber = "M365EDU_A3_STUDENT"; $ProductName = "Microsoft 365 A3 for students"; break }
      "e97c048c-37a4-45fb-ab50-922fbf07a370" { $SkuPartNumber = "M365EDU_A5_FACULTY"; $ProductName = "Microsoft 365 A5 for faculty"; break }
      "46c119d4-0379-4a9d-85e4-97c66d3f909e" { $SkuPartNumber = "M365EDU_A5_STUDENT"; $ProductName = "Microsoft 365 A5 for students"; break }
      "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" { $SkuPartNumber = "SPB"; $ProductName = "MICROSOFT 365 BUSINESS"; break }
      "05e9a617-0261-4cee-bb44-138d3ef5d965" { $SkuPartNumber = "SPE_E3"; $ProductName = "MICROSOFT 365 E3"; break }
      "d61d61cc-f992-433f-a577-5bd016037eeb" { $SkuPartNumber = "SPE_E3_USGOV_DOD"; $ProductName = "Microsoft 365 E3_USGOV_DOD"; break }
      "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658" { $SkuPartNumber = "SPE_E3_USGOV_GCCHIGH"; $ProductName = "Microsoft 365 E3_USGOV_GCCHIGH"; break }
      "06ebc4ee-1bb5-47dd-8120-11324bc54e06" { $SkuPartNumber = "SPE_E5"; $ProductName = "Microsoft 365 E5"; break }
      "184efa21-98c3-4e5d-95ab-d07053a96e67" { $SkuPartNumber = "INFORMATION_PROTECTION_COMPLIANCE"; $ProductName = "Microsoft 365 E5 Compliance"; break }
      "26124093-3d78-432b-b5dc-48bf992543d5" { $SkuPartNumber = "IDENTITY_THREAT_PROTECTION"; $ProductName = "Microsoft 365 E5 Security"; break }
      "44ac31e7-2999-4304-ad94-c948886741d4" { $SkuPartNumber = "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"; $ProductName = "Microsoft 365 E5 Security for EMS E5"; break }
      "66b55226-6b4f-492c-910c-a3b7a3c9d993" { $SkuPartNumber = "SPE_F1"; $ProductName = "Microsoft 365 F1"; break }
      "111046dd-295b-4d6d-9724-d52ac90bd1f2" { $SkuPartNumber = "WIN_DEF_ATP"; $ProductName = "Microsoft Defender Advanced Threat Protection"; break }
      "d17b27af-3f49-4822-99f9-56a661538792" { $SkuPartNumber = "CRMSTANDARD"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE"; break }
      "906af65a-2970-46d5-9b58-4e9aa50f0657" { $SkuPartNumber = "CRMPLAN2"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE BASIC"; break }
      "ba9a34de-4489-469d-879c-0f0f145321cd" { $SkuPartNumber = "IT_ACADEMY_AD"; $ProductName = "MS IMAGINE ACADEMY"; break }
      "a4585165-0533-458a-97e3-c400570268c4" { $SkuPartNumber = "ENTERPRISEPREMIUM_FACULTY"; $ProductName = "Office 365 A5 for faculty"; break }
      "ee656612-49fa-43e5-b67e-cb1fdf7699df" { $SkuPartNumber = "ENTERPRISEPREMIUM_STUDENT"; $ProductName = "Office 365 A5 for students"; break }
      "1b1b1f7a-8355-43b6-829f-336cfccb744c" { $SkuPartNumber = "EQUIVIO_ANALYTICS"; $ProductName = "Office 365 Advanced Compliance"; break }
      "4ef96642-f096-40de-a3e9-d83fb2f90211" { $SkuPartNumber = "ATP_ENTERPRISE"; $ProductName = "Office 365 Advanced Threat Protection (Plan 1)"; break }
      "cdd28e44-67e3-425e-be4c-737fab2899d3" { $SkuPartNumber = "O365_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break }
      "b214fe43-f5a3-4703-beeb-fa97188220fc" { $SkuPartNumber = "SMB_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break }
      "3b555118-da6a-4418-894f-7df1e2096870" { $SkuPartNumber = "O365_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break }
      "dab7782a-93b1-4074-8bb1-0e61318bea0b" { $SkuPartNumber = "SMB_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break }
      "f245ecc8-75af-4f8e-b61f-27d8114de5f3" { $SkuPartNumber = "O365_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break }
      "ac5cef5d-921b-4f97-9ef3-c99076e5470f" { $SkuPartNumber = "SMB_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break }
      "18181a46-0d4e-45cd-891e-60aabd171b4e" { $SkuPartNumber = "STANDARDPACK"; $ProductName = "OFFICE 365 E1"; break }
      "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e" { $SkuPartNumber = "STANDARDWOFFPACK"; $ProductName = "OFFICE 365 E2"; break }
      "6fd2c87f-b296-42f0-b197-1e91e994b900" { $SkuPartNumber = "ENTERPRISEPACK"; $ProductName = "OFFICE 365 E3"; break }
      "189a915c-fe4f-4ffa-bde4-85b9628d07a0" { $SkuPartNumber = "DEVELOPERPACK"; $ProductName = "OFFICE 365 E3 DEVELOPER"; break }
      "b107e5a3-3e60-4c0d-a184-a7e4395eb44c" { $SkuPartNumber = "ENTERPRISEPACK_USGOV_DOD"; $ProductName = "Office 365 E3_USGOV_DOD"; break }
      "aea38a85-9bd5-4981-aa00-616b411205bf" { $SkuPartNumber = "ENTERPRISEPACK_USGOV_GCCHIGH"; $ProductName = "Office 365 E3_USGOV_GCCHIGH"; break }
      "1392051d-0cb9-4b7a-88d5-621fee5e8711" { $SkuPartNumber = "ENTERPRISEWITHSCAL"; $ProductName = "OFFICE 365 E4"; break }
      "c7df2760-2c81-4ef7-b578-5b5392b571df" { $SkuPartNumber = "ENTERPRISEPREMIUM"; $ProductName = "OFFICE 365 E5"; break }
      "26d45bd9-adf1-46cd-a9e1-51e9a5524128" { $SkuPartNumber = "ENTERPRISEPREMIUM_NOPSTNCONF"; $ProductName = "OFFICE 365 E5 WITHOUT AUDIO CONFERENCING"; break }
      "4b585984-651b-448a-9e53-3b10f069cf7f" { $SkuPartNumber = "DESKLESSPACK"; $ProductName = "OFFICE 365 F1"; break }
      "04a7fb0d-32e0-4241-b4f5-3f7618cd1162" { $SkuPartNumber = "MIDSIZEPACK"; $ProductName = "OFFICE 365 MIDSIZE BUSINESS"; break }
      "c2273bd0-dff7-4215-9ef5-2c7bcfb06425" { $SkuPartNumber = "OFFICESUBSCRIPTION"; $ProductName = "OFFICE 365 PROPLUS"; break }
      "bd09678e-b83c-4d3f-aaba-3dad4abd128b" { $SkuPartNumber = "LITEPACK"; $ProductName = "OFFICE 365 SMALL BUSINESS"; break }
      "fc14ec4a-4169-49a4-a51e-2c852931814b" { $SkuPartNumber = "LITEPACK_P2"; $ProductName = "OFFICE 365 SMALL BUSINESS PREMIUM"; break }
      "e6778190-713e-4e4f-9119-8b8238de25df" { $SkuPartNumber = "WACONEDRIVESTANDARD"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 1)"; break }
      "ed01faf2-1d88-4947-ae91-45ca18703a96" { $SkuPartNumber = "WACONEDRIVEENTERPRISE"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 2)"; break }
      "b30411f5-fea1-4a59-9ad9-3db7c7ead579" { $SkuPartNumber = "POWERAPPS_PER_USER"; $ProductName = "POWER APPS PER USER PLAN"; break }
      "45bc2c81-6072-436a-9b0b-3b12eefbc402" { $SkuPartNumber = "POWER_BI_ADDON"; $ProductName = "POWER BI FOR OFFICE 365 ADD-ON"; break }
      "f8a1db68-be16-40ed-86d5-cb42ce701560" { $SkuPartNumber = "POWER_BI_PRO"; $ProductName = "POWER BI PRO"; break }
      "a10d5e58-74da-4312-95c8-76be4e5b75a0" { $SkuPartNumber = "PROJECTCLIENT"; $ProductName = "PROJECT FOR OFFICE 365"; break }
      "776df282-9fc0-4862-99e2-70e561b9909e" { $SkuPartNumber = "PROJECTESSENTIALS"; $ProductName = "PROJECT ONLINE ESSENTIALS"; break }
      "09015f9f-377f-4538-bbb5-f75ceb09358a" { $SkuPartNumber = "PROJECTPREMIUM"; $ProductName = "PROJECT ONLINE PREMIUM"; break }
      "2db84718-652c-47a7-860c-f10d8abbdae3" { $SkuPartNumber = "PROJECTONLINE_PLAN_1"; $ProductName = "PROJECT ONLINE PREMIUM WITHOUT PROJECT CLIENT"; break }
      "53818b1b-4a27-454b-8896-0dba576410e6" { $SkuPartNumber = "PROJECTPROFESSIONAL"; $ProductName = "PROJECT ONLINE PROFESSIONAL"; break }
      "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c" { $SkuPartNumber = "PROJECTONLINE_PLAN_2"; $ProductName = "PROJECT ONLINE WITH PROJECT FOR OFFICE 365"; break }
      "1fc08a02-8b3d-43b9-831e-f76859e04e1a" { $SkuPartNumber = "SHAREPOINTSTANDARD"; $ProductName = "SHAREPOINT ONLINE (PLAN 1)"; break }
      "a9732ec9-17d9-494c-a51c-d6b45b384dcb" { $SkuPartNumber = "SHAREPOINTENTERPRISE"; $ProductName = "SHAREPOINT ONLINE (PLAN 2)"; break }
      "440eaaa8-b3e0-484b-a8be-62870b9ba70a" { $SkuPartNumber = "PHONESYSTEM_VIRTUALUSER"; $ProductName = "Phone System - Virtual User License"; break }
      "e43b5b99-8dfb-405f-9987-dc307f34bcbd" { $SkuPartNumber = "MCOEV"; $ProductName = "SKYPE FOR BUSINESS CLOUD PBX"; break }
      "b8b749f8-a4ef-4887-9539-c95b1eaa5db7" { $SkuPartNumber = "MCOIMP"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 1)"; break }
      "d42c793f-6c78-4f43-92ca-e8f6a02b035f" { $SkuPartNumber = "MCOSTANDARD"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 2)"; break }
      "d3b4fe1f-9992-4930-8acb-ca6ec609365e" { $SkuPartNumber = "MCOPSTN2"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC AND INTERNATIONAL CALLING"; break }
      "0dab259f-bf13-4952-b7f8-7db8f131b28d" { $SkuPartNumber = "MCOPSTN1"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING"; break }
      "54a152dc-90de-4996-93d2-bc47e670fc06" { $SkuPartNumber = "MCOPSTN5"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"; break }
      "4b244418-9658-4451-a2b8-b5e2b364e9bd" { $SkuPartNumber = "VISIOONLINE_PLAN1"; $ProductName = "VISIO ONLINE PLAN 1"; break }
      "c5928f49-12ba-48f7-ada3-0d743a3601d5" { $SkuPartNumber = "VISIOCLIENT"; $ProductName = "VISIO Online Plan 2"; break }
      "cb10e6cd-9da4-4992-867b-67546b1db821" { $SkuPartNumber = "WIN10_PRO_ENT_SUB"; $ProductName = "WINDOWS 10 ENTERPRISE E3"; break }
      "488ba24a-39a9-4473-8ee5-19291e71b002" { $SkuPartNumber = "WIN10_VDA_E5"; $ProductName = "Windows 10 Enterprise E5"; break }
    } # End Switch statement

    switch ($Output) {
      "SkuPartNumber" { return $SkuPartNumber }
      "ProductName" { return $ProductName }
    }

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #Get-SkuPartNumberFromSkuID
