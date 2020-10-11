# Module:     TeamsFunctions
# Function:   AzureAd Licensing
# Author:     David Eberhardt
# Updated:    01-AUG-2020
# Status:     Live




function Get-SkuIDFromSkuPartNumber {
  <#
	.SYNOPSIS
		Returns SkuID from SkuPartNumber
	.DESCRIPTION
		Returns SkuID from SkuPartNumber
	.PARAMETER SkuPartNumber
    Part Number of the Sku
  .EXAMPLE
    Get-SkuIDFromSkuPartNumber MCOEV
    Returns the SkuId for MCOEV (PhoneSystem): e43b5b99-8dfb-405f-9987-dc307f34bcbd
	.FUNCTIONALITY
		Helper Function for Licensing, translating ID to SkuPartNumber
	#>

  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuPartNumber
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.Mycommand)"

  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.Mycommand)"

    switch ($SkuPartNumber) {
      "MCOMEETADV" { $SkuID = "0c266dff-15dd-4b49-8397-2bb16070ed52"; break }
      "AAD_BASIC" { $SkuID = "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7"; break }
      "AAD_PREMIUM" { $SkuID = "078d2b04-f1bd-4111-bbd4-b4b1b354cef4"; break }
      "AAD_PREMIUM_P2" { $SkuID = "84a661c4-e949-4bd2-a560-ed7766fcaf2b"; break }
      "RIGHTSMANAGEMENT" { $SkuID = "c52ea49f-fe5d-4e95-93ba-1de91d380f89"; break }
      "DYN365_ENTERPRISE_PLAN1" { $SkuID = "ea126fc5-a19e-42e2-a731-da9d437bffcf"; break }
      "DYN365_ENTERPRISE_CUSTOMER_SERVICE" { $SkuID = "749742bf-0d37-4158-a120-33567104deeb"; break }
      "DYN365_FINANCIALS_BUSINESS_SKU" { $SkuID = "cc13a803-544e-4464-b4e4-6d6169a138fa"; break }
      "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE" { $SkuID = "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc"; break }
      "DYN365_ENTERPRISE_SALES" { $SkuID = "1e1a282c-9c54-43a2-9310-98ef728faace"; break }
      "DYN365_ENTERPRISE_TEAM_MEMBERS" { $SkuID = "8e7a3d30-d97d-43ab-837c-d7701cef83dc"; break }
      "Dynamics_365_for_Operations" { $SkuID = "ccba3cfe-71ef-423a-bd87-b6df3dce59a9"; break }
      "EMS" { $SkuID = "efccb6f7-5641-4e0e-bd10-b4976e1bf68e"; break }
      "EMSPREMIUM" { $SkuID = "b05e124f-c7cc-45a0-a6aa-8cf78c946968"; break }
      "EXCHANGESTANDARD" { $SkuID = "4b9405b0-7788-4568-add1-99614e613b69"; break }
      "EXCHANGEENTERPRISE" { $SkuID = "19ec0d23-8335-4cbd-94ac-6050e30712fa"; break }
      "EXCHANGEARCHIVE_ADDON" { $SkuID = "ee02fd1b-340e-4a4b-b355-4a514e4c8943"; break }
      "EXCHANGEARCHIVE" { $SkuID = "90b5e015-709a-4b8b-b08e-3200f994494c"; break }
      "EXCHANGEESSENTIALS" { $SkuID = "7fc0182e-d107-4556-8329-7caaa511197b"; break }
      "EXCHANGE_S_ESSENTIALS" { $SkuID = "e8f81a67-bd96-4074-b108-cf193eb9433b"; break }
      "EXCHANGEDESKLESS" { $SkuID = "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82"; break }
      "EXCHANGETELCO" { $SkuID = "cb0a98a8-11bc-494c-83d9-c1b1ac65327e"; break }
      "INTUNE_A" { $SkuID = "061f9ace-7d42-4136-88ac-31dc755f143f"; break }
      "M365EDU_A1" { $SkuID = "b17653a4-2443-4e8c-a550-18249dda78bb"; break }
      "M365EDU_A3_FACULTY" { $SkuID = "4b590615-0888-425a-a965-b3bf7789848d"; break }
      "M365EDU_A3_STUDENT" { $SkuID = "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121"; break }
      "M365EDU_A5_FACULTY" { $SkuID = "e97c048c-37a4-45fb-ab50-922fbf07a370"; break }
      "M365EDU_A5_STUDENT" { $SkuID = "46c119d4-0379-4a9d-85e4-97c66d3f909e"; break }
      "SPB" { $SkuID = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"; break }
      "SPE_E3" { $SkuID = "05e9a617-0261-4cee-bb44-138d3ef5d965"; break }
      "SPE_E3_USGOV_DOD" { $SkuID = "d61d61cc-f992-433f-a577-5bd016037eeb"; break }
      "SPE_E3_USGOV_GCCHIGH" { $SkuID = "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658"; break }
      "SPE_E5" { $SkuID = "06ebc4ee-1bb5-47dd-8120-11324bc54e06"; break }
      "INFORMATION_PROTECTION_COMPLIANCE" { $SkuID = "184efa21-98c3-4e5d-95ab-d07053a96e67"; break }
      "IDENTITY_THREAT_PROTECTION" { $SkuID = "26124093-3d78-432b-b5dc-48bf992543d5"; break }
      "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5" { $SkuID = "44ac31e7-2999-4304-ad94-c948886741d4"; break }
      "SPE_F1" { $SkuID = "66b55226-6b4f-492c-910c-a3b7a3c9d993"; break }
      "WIN_DEF_ATP" { $SkuID = "111046dd-295b-4d6d-9724-d52ac90bd1f2"; break }
      "CRMSTANDARD" { $SkuID = "d17b27af-3f49-4822-99f9-56a661538792"; break }
      "CRMPLAN2" { $SkuID = "906af65a-2970-46d5-9b58-4e9aa50f0657"; break }
      "IT_ACADEMY_AD" { $SkuID = "ba9a34de-4489-469d-879c-0f0f145321cd"; break }
      "ENTERPRISEPREMIUM_FACULTY" { $SkuID = "a4585165-0533-458a-97e3-c400570268c4"; break }
      "ENTERPRISEPREMIUM_STUDENT" { $SkuID = "ee656612-49fa-43e5-b67e-cb1fdf7699df"; break }
      "EQUIVIO_ANALYTICS" { $SkuID = "1b1b1f7a-8355-43b6-829f-336cfccb744c"; break }
      "ATP_ENTERPRISE" { $SkuID = "4ef96642-f096-40de-a3e9-d83fb2f90211"; break }
      "O365_BUSINESS" { $SkuID = "cdd28e44-67e3-425e-be4c-737fab2899d3"; break }
      "SMB_BUSINESS" { $SkuID = "b214fe43-f5a3-4703-beeb-fa97188220fc"; break }
      "O365_BUSINESS_ESSENTIALS" { $SkuID = "3b555118-da6a-4418-894f-7df1e2096870"; break }
      "SMB_BUSINESS_ESSENTIALS" { $SkuID = "dab7782a-93b1-4074-8bb1-0e61318bea0b"; break }
      "O365_BUSINESS_PREMIUM" { $SkuID = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"; break }
      "SMB_BUSINESS_PREMIUM" { $SkuID = "ac5cef5d-921b-4f97-9ef3-c99076e5470f"; break }
      "STANDARDPACK" { $SkuID = "18181a46-0d4e-45cd-891e-60aabd171b4e"; break }
      "STANDARDWOFFPACK" { $SkuID = "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e"; break }
      "ENTERPRISEPACK" { $SkuID = "6fd2c87f-b296-42f0-b197-1e91e994b900"; break }
      "DEVELOPERPACK" { $SkuID = "189a915c-fe4f-4ffa-bde4-85b9628d07a0"; break }
      "ENTERPRISEPACK_USGOV_DOD" { $SkuID = "b107e5a3-3e60-4c0d-a184-a7e4395eb44c"; break }
      "ENTERPRISEPACK_USGOV_GCCHIGH" { $SkuID = "aea38a85-9bd5-4981-aa00-616b411205bf"; break }
      "ENTERPRISEWITHSCAL" { $SkuID = "1392051d-0cb9-4b7a-88d5-621fee5e8711"; break }
      "ENTERPRISEPREMIUM" { $SkuID = "c7df2760-2c81-4ef7-b578-5b5392b571df"; break }
      "ENTERPRISEPREMIUM_NOPSTNCONF" { $SkuID = "26d45bd9-adf1-46cd-a9e1-51e9a5524128"; break }
      "DESKLESSPACK" { $SkuID = "4b585984-651b-448a-9e53-3b10f069cf7f"; break }
      "MIDSIZEPACK" { $SkuID = "04a7fb0d-32e0-4241-b4f5-3f7618cd1162"; break }
      "OFFICESUBSCRIPTION" { $SkuID = "c2273bd0-dff7-4215-9ef5-2c7bcfb06425"; break }
      "LITEPACK" { $SkuID = "bd09678e-b83c-4d3f-aaba-3dad4abd128b"; break }
      "LITEPACK_P2" { $SkuID = "fc14ec4a-4169-49a4-a51e-2c852931814b"; break }
      "WACONEDRIVESTANDARD" { $SkuID = "e6778190-713e-4e4f-9119-8b8238de25df"; break }
      "WACONEDRIVEENTERPRISE" { $SkuID = "ed01faf2-1d88-4947-ae91-45ca18703a96"; break }
      "POWERAPPS_PER_USER" { $SkuID = "b30411f5-fea1-4a59-9ad9-3db7c7ead579"; break }
      "POWER_BI_ADDON" { $SkuID = "45bc2c81-6072-436a-9b0b-3b12eefbc402"; break }
      "POWER_BI_PRO" { $SkuID = "f8a1db68-be16-40ed-86d5-cb42ce701560"; break }
      "PROJECTCLIENT" { $SkuID = "a10d5e58-74da-4312-95c8-76be4e5b75a0"; break }
      "PROJECTESSENTIALS" { $SkuID = "776df282-9fc0-4862-99e2-70e561b9909e"; break }
      "PROJECTPREMIUM" { $SkuID = "09015f9f-377f-4538-bbb5-f75ceb09358a"; break }
      "PROJECTONLINE_PLAN_1" { $SkuID = "2db84718-652c-47a7-860c-f10d8abbdae3"; break }
      "PROJECTPROFESSIONAL" { $SkuID = "53818b1b-4a27-454b-8896-0dba576410e6"; break }
      "PROJECTONLINE_PLAN_2" { $SkuID = "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c"; break }
      "SHAREPOINTSTANDARD" { $SkuID = "1fc08a02-8b3d-43b9-831e-f76859e04e1a"; break }
      "SHAREPOINTENTERPRISE" { $SkuID = "a9732ec9-17d9-494c-a51c-d6b45b384dcb"; break }
      "PHONESYSTEM_VIRTUALUSER" { $SkuID = "440eaaa8-b3e0-484b-a8be-62870b9ba70a"; break }
      "MCOEV" { $SkuID = "e43b5b99-8dfb-405f-9987-dc307f34bcbd"; break }
      "MCOIMP" { $SkuID = "b8b749f8-a4ef-4887-9539-c95b1eaa5db7"; break }
      "MCOSTANDARD" { $SkuID = "d42c793f-6c78-4f43-92ca-e8f6a02b035f"; break }
      "MCOPSTN2" { $SkuID = "d3b4fe1f-9992-4930-8acb-ca6ec609365e"; break }
      "MCOPSTN1" { $SkuID = "0dab259f-bf13-4952-b7f8-7db8f131b28d"; break }
      "MCOPSTN5" { $SkuID = "54a152dc-90de-4996-93d2-bc47e670fc06"; break }
      "VISIOONLINE_PLAN1" { $SkuID = "4b244418-9658-4451-a2b8-b5e2b364e9bd"; break }
      "VISIOCLIENT" { $SkuID = "c5928f49-12ba-48f7-ada3-0d743a3601d5"; break }
      "WIN10_PRO_ENT_SUB" { $SkuID = "cb10e6cd-9da4-4992-867b-67546b1db821"; break }
      "WIN10_VDA_E5" { $SkuID = "488ba24a-39a9-4473-8ee5-19291e71b002"; break }
    }
    return $SkuID

  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.Mycommand)"
  } #end

} #Get-SkuIDFromSkuPartNumber
