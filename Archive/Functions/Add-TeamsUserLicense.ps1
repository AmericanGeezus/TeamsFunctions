# Module:     TeamsFunctions
# Function:   Licensing
# Author:		  Jeff Brown
# Updated:    01-AUG-2020
# Status:     Archived




function Add-TeamsUserLicense {
  <#
	.SYNOPSIS
		Adds one or more Teams related licenses to a user account.
	.DESCRIPTION
		Teams services are available through assignment of different types of licenses.
		This command allows assigning one or more Teams related Office 365 licenses to a user account to enable
    the different services, such as E3/E5, Phone System, Calling Plans, and Audio Conferencing.
    NOTE: This function is deprecated. Please use Set-TeamsUserLicense instead
	.PARAMETER Identity
		The sign-in address or User Principal Name of the user account to modify.
	.PARAMETER AddSFBO2
		Adds a Skype for Business Plan 2 license to the user account.
	.PARAMETER AddOffice365E3
		Adds an Office 365 E3 license to the user account.
	.PARAMETER AddOffice365E5
		Adds an Office 365 E5 license to the user account.
	.PARAMETER AddMicrosoft365E3
		Adds an Microsoft 365 E3 license to the user account.
	.PARAMETER AddMicrosoft365E5
		Adds an Microsoft 365 E5 license to the user account.
	.PARAMETER AddOffice365E5NoAudioConferencing
		Adds an Office 365 E5 without Audio Conferencing license to the user account.
	.PARAMETER AddAudioConferencing
		Adds a Audio Conferencing add-on license to the user account.
	.PARAMETER AddPhoneSystem
		Adds a Phone System add-on license to the user account.
		Can be combined with Replace (which then will remove PhoneSystem_VirtualUser from the User)
	.PARAMETER AddPhoneSystemVirtualUser
		Adds a Phone System Virtual User add-on license to the user account.
		Can be combined with Replace (which then will remove PhoneSystem from the User)
	.PARAMETER AddMSCallingPlanDomestic
		Adds a Domestic Calling Plan add-on license to the user account.
	.PARAMETER AddMSCallingPlanInternational
		Adds an International Calling Plan add-on license to the user account.
	.PARAMETER AddCommonAreaPhone
		Adds a Common Area Phone license to the user account.
	.EXAMPLE
		Add-TeamsUserLicense -Identity Joe@contoso.com -AddMicrosoft365E5
		Example 1 will add the an Microsoft 365 E5 to Joe@contoso.com
	.EXAMPLE
		Add-TeamsUserLicense -Identity Joe@contoso.com -AddMicrosoft365E3 -AddPhoneSystem
		Example 2 will add the an Microsoft 365 E3 and Phone System add-on license to Joe@contoso.com
	.EXAMPLE
		Add-TeamsUserLicense -Identity Joe@contoso.com -AddSfBOS2 -AddAudioConferencing -AddPhoneSystem
		Example 3 will add the a Skype for Business Plan 2 (S2) and PSTN Conferencing and PhoneSystem add-on license to Joe@contoso.com
	.EXAMPLE
		Add-TeamsUserLicense -Identity Joe@contoso.com -AddOffice365E3 -AddPhoneSystem
		Example 4 will add the an Office 365 E3 and PhoneSystem add-on license to Joe@contoso.com
	.EXAMPLE
		Add-TeamsUserLicense -Identity Joe@contoso.com -AddOffice365E5 -AddDomesticCallingPlan
		Example 5 will add the an Office 365 E5 and Domestic Calling Plan add-on license to Joe@contoso.com
	.EXAMPLE
		Add-TeamsUserLicense -Identity ResourceAccount@contoso.com -AddPhoneSystem -Replace
		Example 5 will add the PhoneSystem add-on license to ResourceAccount@contoso.com, removing the PhoneSystem_VirtualUserLicense
		NOTE: This is currently in development
	.NOTES
		The command will test to see if the license exists in the tenant as well as if the user already
		has the licensed assigned. It does not keep track or take into account the number of licenses
		available before attempting to assign the license.

		05-APR-2020 - Update/Revamp for Teams:
		# Added Switch to support Microsoft365 E3 License (SPE_E3)
		# Added Switch to support Microsoft365 E5 License (SPE_E5)
		# Renamed Switch AddSkypeStandalone to AddSFBO2
		# Renamed Switch AddE3 to AddOffice365E3 (Alias retains AddE3 for input)
		# Renamed Switch AddE5 to AddOffice365E5 (Alias retains AddE5 for input)
		# #TBC: Renamed references from SkypeOnline to Teams where appropriate
		# #TBC: Renamed function Names to reflect use for Teams
		# Removed Switch AddE1 (Office 365 E1) as it is not a valid license for Teams
		# Removed Switch CommunicationCredits as it is not available for Teams (SFBO only)

		23-MAY-2020 - Update: Added Switch Replace
		# This is for exclusive use for Resource Accounts (swap between PhoneSystem or PhoneSystemVirtualUser)
		# MS Best practice: https://docs.microsoft.com/en-us/microsoftteams/manage-resource-accounts#change-an-existing-resource-account-to-use-a-virtual-user-license
		# Aliases had to be removed as they were confusing, sorry
  .COMPONENT
    Teams Migration and Enablement. License Assignment
  .ROLE
    Licensing
  .FUNCTIONALITY
		Returns a list of Licenses depending on input
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  .LINK
    Get-TeamsLicense
  .LINK
    Get-TeamsLicenseServicePlan
  .LINK
    Get-TeamsTenantLicense
  .LINK
    Get-TeamsUserLicense
  .LINK
    Set-TeamsUserLicense
  .LINK
    Test-TeamsUserLicense
  #>

  [CmdletBinding(DefaultParameterSetName = 'General')]
  [OutputType([Void])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddSFBO2,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddOffice365E3,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddOffice365E5,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddMicrosoft365E3,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddMicrosoft365E5,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [switch]$AddOffice365E5NoAudioConferencing,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [Alias("AddPSTNConferencing", "AddMeetAdv")]
    [switch]$AddAudioConferencing,

    [Parameter(Mandatory = $false, ParameterSetName = 'General')]
    [Parameter(Mandatory = $true, ParameterSetName = 'PhoneSystem')]
    [switch]$AddPhoneSystem,

    [Parameter(Mandatory = $true, ParameterSetName = 'PhoneSystemVirtualUser', HelpMessage = "This is an exclusive license!")]
    [switch]$AddPhoneSystemVirtualUser,

    [Parameter(Mandatory = $true, ParameterSetName = 'CommonAreaPhone', HelpMessage = "This is an exclusive license!")]
    [Alias("AddCAP")]
    [switch]$AddCommonAreaPhone,

    [Parameter(Mandatory = $true, ParameterSetName = 'AddDomestic')]
    [Alias("AddDomesticCallingPlan")]
    [switch]$AddMSCallingPlanDomestic,

    [Parameter(Mandatory = $true, ParameterSetName = 'AddInternational')]
    [Alias("AddInternationalCallingPlan")]
    [switch]$AddMSCallingPlanInternational,

    [Parameter(Mandatory = $false, ParameterSetName = 'PhoneSystem', HelpMessage = 'Will swap a PhoneSystem License to a Virtual User License and vice versa')]
    [Parameter(Mandatory = $false, ParameterSetName = 'PhoneSystemVirtualUser', HelpMessage = 'Will swap a PhoneSystem License to a Virtual User License and vice versa')]
    [switch]$Replace
  ) #param

  begin {
    Show-FunctionStatus -Level Archived
    Write-Verbose -Message "[BEGIN  ] $($MyInvocation.MyCommand)"

    # Asserting AzureAD Connection
    if (-not (Assert-AzureADConnection)) { break }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    if (-not $PSBoundParameters.ContainsKey('Debug')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference') } else { $DebugPreference = 'Continue' }

    Write-Verbose -Message "This function is deprecated. Its limitations have prompted development of 'Set-TeamsUserLicense'" -Verbose

    # Querying all SKUs from the Tenant
    try {
      $tenantSKUs = Get-AzureADSubscribedSku -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }

    # Build Skype SKU Variables from Available Licenses in the Tenant
    foreach ($tenantSKU in $tenantSKUs) {
      switch ($tenantSKU.SkuPartNumber) {
        "MCOPSTN1" { $DomesticCallingPlan = $tenantSKU.SkuId; break }
        "MCOPSTN2" { $InternationalCallingPlan = $tenantSKU.SkuId; break }
        "MCOMEETADV" { $AudioConferencing = $tenantSKU.SkuId; break }
        "MCOEV" { $PhoneSystem = $tenantSKU.SkuId; break }
        "PHONESYSTEM_VIRTUALUSER" { $PhoneSystemVirtualUser = $tenantSKU.SkuId; break }
        "SPE_E3" { $MSE3 = $tenantSKU.SkuId; break }
        "SPE_E5" { $MSE5 = $tenantSKU.SkuId; break }
        "ENTERPRISEPREMIUM" { $E5WithPhoneSystem = $tenantSKU.SkuId; break }
        "ENTERPRISEPREMIUM_NOPSTNCONF" { $E5NoAudioConferencing = $tenantSKU.SkuId; break }
        "ENTERPRISEPACK" { $E3 = $tenantSKU.SkuId; break }
        "MCOSTANDARD" { $SkypeStandalonePlan = $tenantSKU.SkuId; break }
        "MCOCAP" { $CommonAreaPhone = $tenantSKU.SkuId; break }
      } # End of switch statement
    } # End of foreach $tenantSKUs
  } #begin

  process {
    Write-Verbose -Message "[PROCESS] $($MyInvocation.MyCommand)"
    foreach ($ID in $Identity) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -WarningAction SilentlyContinue -ErrorAction STOP
      }
      catch {
        Write-Error -Message "User Account not valid" -Category ObjectNotFound -RecommendedAction "Verify UserPrincipalName" -ErrorAction Stop
      }

      try {
        if ($null -eq $UserObject.UsageLocation) {
          throw
        }
      }
      catch {
        Write-Error -Message "Usage Location not set" -Category InvalidResult -RecommendedAction "Set Usage Location, then try assigning a License again" -ErrorAction Stop
      }

      # Get user's currently assigned licenses
      # Not used. Ignored
      #$userCurrentLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ID).SkuId

      # Skype Standalone Plan
      if ($AddSFBO2 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $SkypeStandalonePlan
      }

      # E3
      if ($AddOffice365E3 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E3
      }

      # E5 with Phone System
      if ($AddOffice365E5 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E5WithPhoneSystem
      }

      # MS E3
      if ($AddMicrosoft365E3 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $MSE3
      }

      # MS E5
      if ($AddMicrosoft365E5 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $MSE5
      }

      # E5 No PSTN Conferencing
      if ($AddOffice365E5NoAudioConferencing -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E5NoAudioConferencing
      }

      # Audio Conferencing Add-On
      if ($AddAudioConferencing -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $AudioConferencing
      }

      # Phone System Add-On License
      if ($AddPhoneSystem -eq $true) {
        if ((Get-AzureADUser -ObjectId "$ID").Department -eq 'Microsoft Communication Application Instance') {
          # This is a correct resource Account
          if ($Replace) {
            Write-Warning -Message "Currently not possible as PhoneSystem cannot be assigned standalone"
            $ReplaceLicenseSkuID = Get-SkuIDfromSkuPartNumber PHONESYSTEM_VIRTUALUSER # Replaces PhoneSystem_VirtualUser
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem -ReplaceLicense $ReplaceLicenseSkuID
          }
          else {
            Write-Warning -Message "Currently not possible as PhoneSystem cannot be assigned standalone. Combine with other Licenses"
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem
          }
        }
        else {
          # This is not supported. Non-Resource Accounts must not have VirtualUser licenses
          ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem
          Write-Error -Message "Non-Resource Account determined. No replacement can be executed" -Category InvalidOperation -RecommendedAction "Verify Account Type is correct. For Resource Accounts, verify Department is set to 'Microsoft Communication Application Instance'" -ErrorAction Stop
        }
      }

      # Phone System Virtual User Add-On License
      if ($AddPhoneSystemVirtualUser -eq $true) {
        if ((Get-AzureADUser -ObjectId "$ID").Department -eq 'Microsoft Communication Application Instance') {
          # This is a correct resource Account
          if ($Replace) {
            $ReplaceLicenseSkuID = Get-SkuIDfromSkuPartNumber MCOEV # Replaces PhoneSystem
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystemVirtualUser -ReplaceLicense $ReplaceLicenseSkuID
          }
          else {
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystemVirtualUser
          }
        }
        else {
          # This is not supported. Non-Resource Accounts must not have VirtualUser licenses
          Write-Error -Message "Non-Resource Account determined. No replacement can be executed" -Category InvalidOperation -RecommendedAction "Verify Account Type is correct. For Resource Accounts, verify Department is set to 'Microsoft Communication Application Instance'" -ErrorAction Stop
        }
      }

      # Domestic Calling Plan
      if ($AddMSCallingPlanDomestic -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $DomesticCallingPlan
      }

      # Domestic & International Calling Plan
      if ($AddMSCallingPlanInternational -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $InternationalCallingPlan
      }

      # Common Area Phone
      if ($AddCommonAreaPhone -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $CommonAreaPhone
      }
    } # End of foreach ($ID in $Identity)
  } #process

  end {
    Write-Verbose -Message "[END    ] $($MyInvocation.MyCommand)"
  } #end
} #Add-TeamsUserLicense
