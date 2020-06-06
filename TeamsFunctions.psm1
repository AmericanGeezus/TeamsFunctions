#Requires -Version 5.1
<#
    Fork of SkypeFunctions
    Written by Jeff Brown
    Jeff@JeffBrown.tech
    @JeffWBrown
    www.jeffbrown.tech
    https://github.com/JeffBrownTech

    Adopted for Teams as TeamsFunctions
    by David Eberhardt
    david@davideberhardt.at
    @MightyOrmus
    www.davideberhardt.at
    https://github.com/DEberhardt
    https://davideberhardt.wordpress.com/

    Individual Scripts incorporated into this Module are taken with the express permission of the original Author
    The 

    To use the functions in this module, use the Import-Module command followed by the path to this file. For example:
    Import-Module TeamsFunctions

    Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
    Always review any code and steps before applying to a production system to understand their full impact.

    # Limitations:
    - Office 365 F1 and F3 as well as Microsoft 365 F1 and F3 cannot be assigned

    # Versioning
    This Module follows the Versioning Convention Microsoft uses to show the Release Date in the Version number
    Major v20 is the the first one published in 2020, followed by Minor verson for Month and Day. 
    Subsequent Minor versions indicate additional publications on this day.
    Revisions are planned quarterly

    # Version History
    1.0         Initial Version (as SkypeFunctions) - 02-OCT-2017
    20.04.17.1  Initial Version (as TeamsFunctions) - Multiple updates for Teams
                References to Skype for Business Online or SkypeOnline have been replaced with Teams as far as sensible
                Function ProcessLicense has seen many additions to LicensePackages. See Documentation there
                Microsoft 365 Licenses have been added to all Functions dealing with Licensing
                Functions to Test against AzureAD and SkypeOnline (Module, Connection, Object) are now elevated as exported functions
                Added Function Test-TeamsTenantPolicy to ascertain that the Object exists
                Added Function Test-TeamsUserLicensePackage queries whether the Object has a certain License Package assigned
                Added Function Test-AzureADUserLicense queries whether the Object has a specific ServicePlan assinged
    20.05.02.1  First Publication  
    20.05.02.2  Bug fixing, erroneously incorporated all local modules.
    20.05.03.1  Bug fixing, minor improvements
    20.05.09.1  Bug fixing, minor improvements
    20.05.16.1  Added Backup-TeamsEV, Restore-TeamsEV by Ken Lasko
                Added Get-AzureAdAssignedAdminRoles
                Added BETA-Functions New-TeamsResourceAccount, Get-TeamsResourceAccount 
    20.05.19.1  Fixed an issue with access to the new functions
    20.05.23.1  Added Replace switch for Licenses (valid only for PhoneSystem and PhoneSystem_VirtualUser licenses)
                Added Helper functions for Resource Accounts (switching between ApplicationID and ApplicationType, i.E. friendly Name)
                Added Helper function for Licensing: Get-SkuPartNumberfromSkuID (returns SkuPartNumber or ProductName)
                Added Helper function for Licensing: Get-SkuIDfromSkuPartNumber (returns SkuID)
                Renamed Helper function for Licensing: New-AzureADLicenseObject (creates a new License Object, can add and remove one)
                RESOLVED Limitation "PhoneSystem_VirtualUser cannot be selected as no GUID is known for it currently"
                Added AzureAD Module and Connection Test in all Functions that need it.
                Added SkypeOnline Module and Connection Test in all Functions that need it.
                Some bug fixing and code scrubbing
    20.06.06.1  Added TeamsResourceAccount Cmdlets: NEW, GET, SET, REMOVE - Tested
                Added TeamsCallQueue Cmdlets: NEW, GET, SET, REMOVE - Untested
                Added Connect-SkypeTeamsAndAAD and Disconnect-SkypeTeamsAndAAD incl. Aliases "con" and "Connect-Me"
                Run "sotaad $Username" to connect to all 3 with one authentication prompt

  #>

#region *** Exported Functions ***
#region Existing Functions
# Assigns a Teams License to a User/Object
function Add-TeamsUserLicense {
  <#
      .SYNOPSIS
      Adds one or more Teams related licenses to a user account.
      .DESCRIPTION
      Teams services are available through assignment of different types of licenses.
      This command allows assigning one or more Teams related Office 365 licenses to a user account to enable
      the different services, such as E3/E5, Phone System, Calling Plans, and Audio Conferencing.
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
      Add-TeamsUserLicense -Identity Joe@contoso.com -AddSFBOS2 -AddAudioConferencing -AddPhoneSystem
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
  #>
  [CmdletBinding(DefaultParameterSetName = 'General')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddSFBO2,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddOffice365E3,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddOffice365E5,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddMicrosoft365E3,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddMicrosoft365E5,
    
    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [switch]$AddOffice365E5NoAudioConferencing,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [Alias("AddPSTNConferencing","AddMeetAdv")]
    [switch]$AddAudioConferencing,

    [Parameter(Mandatory=$false, ParameterSetName = 'General')]
    [Parameter(Mandatory=$true, ParameterSetName = 'PhoneSystem')]
    [switch]$AddPhoneSystem,

    [Parameter(Mandatory=$true, ParameterSetName = 'PhoneSystemVirtualUser', HelpMessage = "This is an exclusive licence!")]
    [switch]$AddPhoneSystemVirtualUser,

    [Parameter(Mandatory=$true, ParameterSetName = 'CommonAreaPhone', HelpMessage = "This is an exclusive licence!")]
    [Alias("AddCAP")]
    [switch]$AddCommonAreaPhone,
    
    [Parameter(Mandatory=$true, ParameterSetName = 'AddDomestic')]
    [Alias("AddDomesticCallingPlan")]
    [switch]$AddMSCallingPlanDomestic,

    [Parameter(Mandatory=$true, ParameterSetName = 'AddInternational')]
    [Alias("AddInternationalCallingPlan")]
    [switch]$AddMSCallingPlanInternational,

    [Parameter(Mandatory=$false, ParameterSetName = 'PhoneSystem', HelpMessage = 'Will swap a PhoneSystem License to a Virtual User License and vice versa')]
    [Parameter(Mandatory=$false, ParameterSetName = 'PhoneSystemVirtualUser', HelpMessage = 'Will swap a PhoneSystem License to a Virtual User License and vice versa')]
    [switch]$Replace
  )

  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

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
        "MCOPSTN1" {$DomesticCallingPlan = $tenantSKU.SkuId; break}
        "MCOPSTN2" {$InternationalCallingPlan = $tenantSKU.SkuId; break}
        "MCOMEETADV" {$AudioConferencing = $tenantSKU.SkuId; break}
        "MCOEV" {$PhoneSystem = $tenantSKU.SkuId; break}
        "PHONESYSTEM_VIRTUALUSER" {$PhoneSystemVirtualUser = $tenantSKU.SkuId; break}
        "SPE_E3" {$MSE3 = $tenantSKU.SkuId; break}
        "SPE_E5" {$MSE5= $tenantSKU.SkuId; break}
        "ENTERPRISEPREMIUM" {$E5WithPhoneSystem = $tenantSKU.SkuId; break}
        "ENTERPRISEPREMIUM_NOPSTNCONF" {$E5NoAudioConferencing = $tenantSKU.SkuId; break}
        "ENTERPRISEPACK" {$E3 = $tenantSKU.SkuId; break}
        "MCOSTANDARD" {$SkypeStandalonePlan = $tenantSKU.SkuId; break}
        "MCOCAP" {$CommonAreaPhone = $tenantSKU.SkuId; break}
      } # End of switch statement
    } # End of foreach $tenantSKUs
  } # End of BEGIN

  process {
    foreach ($ID in $Identity) {
      try {
        $UserObject = Get-AzureADUserFromUPN $ID -ErrorAction STOP
      }
      catch {
        Write-Error -Message "User Account not valid" -Category ObjectNotFound -RecommendedAction "Verify UserPrincipalName"
        return
      }

      try {
        if ($null -eq $UserObject.UsageLocation) {
          throw
        }
      }
      catch {
        Write-Error -Message "Usage Location not set" -Category InvalidResult -RecommendedAction "Set Usage Location, then try assigning a License again"
        break
      }

      # Get user's currently assigned licenses
      # Not used. Ignored
      #$userCurrentLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ID).SkuId
      
      # Skype Standalone Plan
      if ($AddSFBO2 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $SkypeStandalonePlan -LicenseName "SkypeStandalonePlan"
      }

      # E3
      if ($AddOffice365E3 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E3 -LicenseName "Office 365 E3"
      }

      # E5 with Phone System
      if ($AddOffice365E5 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E5WithPhoneSystem -LicenseName "Office 365 E5 (with PhoneSystem)"
      }

      # MS E3
      if ($AddMicrosoft365E3 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $MSE3 -LicenseName "Microsoft 365 E3"
      }

      # MS E5
      if ($AddMicrosoft365E5 -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $MSE5 -LicenseName "Microsoft 365 E5"
      }

      # E5 No PSTN Conferencing
      if ($AddOffice365E5NoAudioConferencing -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $E5NoAudioConferencing -LicenseName "Office 365 E5 (without Audio Conferencing)"
      }

      # Audio Conferencing Add-On
      if ($AddAudioConferencing -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $AudioConferencing -LicenseName "AudioConferencing (Add-On License)"
      }

      # Phone System Add-On License
      if ($AddPhoneSystem -eq $true) {
        if ((Get-AzureADUserFromUPN $ID).Department -eq 'Microsoft Communication Application Instance') {
          # This is a correct resource Account
          if ($Replace) {
            Write-Warning -Message "Currently not possible as PhoneSystem cannot be assigned standalone"
            $ReplaceLicenseSkuID = Get-SkuIDfromSkuPartNumber PHONESYSTEM_VIRTUALUSER # Replaces PhoneSystem_VirtualUser
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem -LicenseName "PhoneSystem (Add-On License)" -ReplaceLicense $ReplaceLicenseSkuID  
          }
          else {
            Write-Warning -Message "Currently not possible as PhoneSystem cannot be assigned standalone. Combine with other Licenses"
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem -LicenseName "PhoneSystem (Add-On License)"
          }
        }
        else  {
          # This is not supported. Non-Resource Accounts must not have VirtualUser licenses
          Write-Error -Message "Non-Resource Account determined. No replacement can be executed" -Category InvalidOperation -RecommendedAction "Verify Account Type is correct. For Resource Accounts, verify Department is set to 'Microsoft Communication Application Instance'"
          break
        }
      }

      # Phone System Virtual User Add-On License
      if ($AddPhoneSystemVirtualUser -eq $true) {
        if ((Get-AzureADUserFromUPN $ID).Department -eq 'Microsoft Communication Application Instance') {
          # This is a correct resource Account
          if ($Replace) {
            $ReplaceLicenseSkuID = Get-SkuIDfromSkuPartNumber MCOEV # Replaces PhoneSystem
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystemVirtualUser -LicenseName "PhoneSystem Virtual User" -ReplaceLicense $ReplaceLicenseSkuID  
          }
          else {
            ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystemVirtualUser -LicenseName "PhoneSystem Virtual User"
          }
        }
        else  {
          # This is not supported. Non-Resource Accounts must not have VirtualUser licenses
          Write-Error -Message "Non-Resource Account determined. No replacement can be executed" -Category InvalidOperation -RecommendedAction "Verify Account Type is correct. For Resource Accounts, verify Department is set to 'Microsoft Communication Application Instance'"
          break
        }
      }
      
      # Domestic Calling Plan
      if ($AddMSCallingPlanDomestic -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $DomesticCallingPlan -LicenseName "Microsoft CallingPlan (Domestic)"
      }

      # Domestic & International Calling Plan
      if ($AddMSCallingPlanInternational -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $InternationalCallingPlan -LicenseName "Microsoft CallingPlan (Domestic & International)"
      }

      # Common Area Phone
      if ($AddCommonAreaPhone -eq $true) {
        ProcessLicense -UserID $ID -LicenseSkuID $CommonAreaPhone -LicenseName "CommonAreaPhone"
      }
    } # End of foreach ($ID in $Identity)
  } # End of PROCESS
} # End of Add-TeamsUserLicense

function Connect-SkypeOnline {
  <#
    .SYNOPSIS
    Creates a remote PowerShell session out to Skype for Business Online and Teams
    .DESCRIPTION
    Connecting to a remote PowerShell session to Skype for Business Online requires several components
    and steps. This function consolidates those activities by 
    1) verifying the SkypeOnlineConnector is installed and imported
    2) prompting for username and password to make and to import the session.
    3) extnding the session time-out limit beyond 60mins (SkypeOnlineConnector v7 or higher only!)
    A SkypeOnline Session requires one of the Teams Admin roles or Skype For Business Admin to connect.
    .PARAMETER UserName
    Optional String. The username or sign-in address to use when making the remote PowerShell session connection.
    .PARAMETER OverrideAdminDomain
    Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
    .EXAMPLE
    $null = Connect-SkypeOnline
    Example 1 will prompt for the username and password of an administrator with permissions to connect to Skype for Business Online.
    .EXAMPLE
    $null = Connect-SkypeOnline -UserName admin@contoso.com
    Example 2 will prefill the authentication prompt with admin@contoso.com and only ask for the password for the account to connect out to Skype for Business Online.
    .NOTES
    Requires that the Skype Online Connector PowerShell module be installed.
    If the PowerShell Module SkypeOnlineConnector is v7 or higher, the Session TimeOut of 60min can be circumvented.
    Enable-CsOnlineSessionForReconnection is run.
    Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
    The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
    To manage Teams, Channels, etc. within Microsoft Teams, use Connect-MicrosoftTeams
    Connect-MicrosoftTeams requires a Teams Admin role and is part of the PowerShell Module MicrosoftTeams 
    https://www.powershellgallery.com/packages/MicrosoftTeams
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [string]$UserName,
    
    [Parameter(Mandatory = $false)]
    [ValidateScript({$null -eq $_ -or $_ -match '.onmicrosoft.com'})]
    [string]$OverrideAdminDomain
  )

  if ((Test-SkypeOnlineModule) -eq $true)
  {
    if ((Test-SkypeOnlineConnection) -eq $false)
    {
      $moduleVersion = (Get-Module -Name SkypeOnlineConnector).Version
      if ($moduleVersion.Major -le "6") # Version 6 and lower do not support MFA authentication for Skype Module PowerShell; also allows use of older PSCredential objects
      {
        try
        {
          $SkypeOnlineSession = New-CsOnlineSession -Credential (Get-Credential $UserName -Message "Enter the sign-in address and password of a Global or Skype for Business Admin") -ErrorAction STOP
          Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
        }
        catch
        {
          $errorMessage = $_
          if ($errorMessage -like "*Making sure that you have used the correct user name and password*")
          {
            Write-Warning -Message "Logon failed. Please try again and make sure that you have used the correct user name and password."
          }                    
          elseif ($errorMessage -like "*Please create a new credential object*")
          {
            Write-Warning -Message "Logon failed. This may be due to multi-factor being enabled for the user account and not using the latest Skype for Business Online PowerShell module."
          }
          else
          {
            Write-Warning -Message $_
          }
        }
      }
      else # This should be all newer version than 6; does not support PSCredential objects but supports MFA
      {
        try
        {
          if ($PSBoundParameters.ContainsKey("UserName"))
          {
            if ($PSBoundParameters.ContainsKey("OverrideAdminDomain")) {
              $SkypeOnlineSession = New-CsOnlineSession -UserName $UserName -OverrideAdminDomain $OverrideAdminDomain -ErrorAction STOP
            }
            else {
              $SkypeOnlineSession = New-CsOnlineSession -UserName $UserName -ErrorAction STOP
            }            
          }
          else
          {
            if ($PSBoundParameters.ContainsKey("OverrideAdminDomain")) {
              $SkypeOnlineSession = New-CsOnlineSession -OverrideAdminDomain $OverrideAdminDomain -ErrorAction STOP
            }
            else {
              $SkypeOnlineSession = New-CsOnlineSession -ErrorAction STOP
            }
          }

          Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global

          #region For v7 and higher: run Enable-CsOnlineSessionForReconnection
          $moduleVersion = (Get-Module -Name SkypeOnlineConnector).Version
          Write-Host "SkypeOnlineConnector Module is v$ModuleVersion"
          if ($moduleVersion.Major -ge "7") # v7 and higher can run Session Limit Extension
          {
            Enable-CsOnlineSessionForReconnection -WarningAction SilentlyContinue
            Write-Verbose -Message "The PowerShell session reconnects and authenticates, allowing it to be re-used without having to launch a new instance to reconnect." -Verbose

          }
          else 
          {
            Write-Host "Your Session will time out after 60 min. - To prevent this, Update this module to v7 or higher, then run Enable-CsOnlineSessionForReconnection"
            Write-Host "You can download the Module here: https://www.microsoft.com/download/details.aspx?id=39366"
          }
          #endregion
        }
        catch
        {
          Write-Error -Message "Connection not established" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Managment Role activation" -Exception $_.Exception.Message
        }
      } # End of if statement for module version checking
    }
    else
    {
      Write-Warning -Message "A Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again."
    } # End checking for existing Skype Online Connection
  }
  else
  {
    Write-Warning -Message "Skype Online PowerShell Connector module is not installed. Please install and try again."
    Write-Warning -Message "The module can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366"
  } # End of testing module existence
} # End of Connect-SkypeOnline

function Connect-SkypeTeamsAndAAD {
  <#
  .SYNOPSIS
      Connect to SkypeOnline Teams and AzureActiveDirectory
  .DESCRIPTION
      One function to connect them all.
      This function tries to solves the requirement for individual authentication prompts for
      SkypeOnline, MicrosoftTeams and AzureAD when multiple connections are required.
      For SkypeOnline, the Skype for Business Legacy Administrator Roles is required
      For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Service Administrator or Teams Communication Admin)
      For AzureAD, no particular role is needed as GET-commands are available without a role.
      Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output) 
      Disconnects current SkypeOnline, MicrosoftTeams and AzureAD session in order to establish a clean new session to each service.
      Combine as desired
  .PARAMETER UserName 
      Requried. UserPrincipalName or LoginName of the Office365 Administrator
  .PARAMETER SkypeOnline
      Optional. Connects to SkypeOnline. Requires Office 365 Admin role Skype for Business Legacy Administrator
  .PARAMETER MicrosoftTeams
      Optional. Connects to MicrosoftTeams. Requires Office 365 Admin role for Teams, e.g. Microsoft Teams Service Administrator
  .PARAMETER AzureAD
      Optional. Connects to Azure Active Directory (AAD). Requires no Office 365 Admin roles (Read-only access to AzureAD)
  .PARAMETER OverrideAdminDomain
      Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
  .PARAMETER Silent
      Optional. Suppresses output session information about established sessions. Used for calls by other functions
  .EXAMPLE
      Connect-SkypeTeamsAndAAD -Username admin@domain.com
      Connects to all three Services prompting ONCE for a Password for 'admin@domain.com'
  .EXAMPLE
      Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -AzureAD
      Connects to SkypeOnline and AzureAD prompting ONCE for a Password for 'admin@domain.com'
  .FUNCTIONALITY
      Connects to one or multiple Office 365 Services with as few Authentication prompts as possible
  #>

  param(
      [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'UserPrincipalName, Administrative Account')]
      [string]$UserName,
      
      [Parameter(Mandatory = $false, HelpMessage = 'Establises a connection to SkypeOnline. Prompts for new credentials.')]
      [Alias('SFBO')]
      [switch]$SkypeOnline,

      [Parameter(Mandatory = $false, HelpMessage = 'Establises a connection to Azure AD. Reuses credentials if authenticated already.')]
      [Alias('AAD')]
      [switch]$AzureAD,
  
      [Parameter(Mandatory = $false, HelpMessage = 'Establises a connection to MicrosoftTeams. Reuses credentials if authenticated already.')]
      [Alias('Teams')]
      [switch]$MicrosoftTeams,

      [Parameter(Mandatory = $false, HelpMessage = 'Domain used to connect to for SkypeOnline if DNS points to OnPrem Skype')]
      [ValidateScript({$null -eq $_ -or $_ -match '.onmicrosoft.com'})]
      [string]$OverrideAdminDomain,

      [Parameter(Mandatory = $false, HelpMessage = 'Suppresses Session Information output')]
      $Silent

  )
  
  # Preparing variables
  if (-not ('SkypeOnline' -in $PSBoundParameters -or 'MicrosoftTeams' -in $PSBoundParameters -or 'AzureAD' -in $PSBoundParameters)) {
      # No parameter provided. Assuming connection to all three!
      $ConnectALL = $true
  }
  if ($PSBoundParameters.ContainsKey('SkypeOnline')) {
      $ConnectToSkype = $true
  }
  if ($PSBoundParameters.ContainsKey('AzureAD')) {
      $ConnectToAAD = $true
  }
  if ($PSBoundParameters.ContainsKey('MicrosoftTeams')) {
      $ConnectToTeams = $true
  }

  # Cleaning up existing sessions
  Write-Verbose -Message "Disconnecting from all existing sessions for SkypeOnline, AzureAD and MicrosoftTeams" -Verbose
  Disconnect-SkypeTeamsAndAAD

  #region Connections
  # SkypeOnline
  if ($ConnectALL -or $ConnectToSkype) {
    Write-Verbose -Message "Establishing connection to SkypeOnline" -Verbose
    try {
      if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
        $null = (Connect-SkypeOnline -Username $Username -OverrideAdminDomain $OverrideAdminDomain -ErrorAction STOP)
      }
      else {
        $null = (Connect-SkypeOnline -Username $Username -ErrorAction STOP)
      }       
    }
    catch {
      Write-Error   -Message "Could not establish Connection to SkypeOnline" `
      -RecommendedAction "Run Connect-SkypeOnline manually" `
      -Category NotEnabled `
      -Exception $_.Exception.Message
    }

    if ((Test-SkypeOnlineConnection) -and -not $Silent) {
      $PSSkypeOnlineSession = Get-PsSession | Where-Object {$_.ComputerName -like "*.online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available"} -WarningAction STOP -ErrorAction STOP
      $TenantInformation = Get-CsTenant -WarningAction STOP -ErrorAction STOP
      $TenantDomain = $TenantInformation.Domains | Select-Object -Last 1

      $PSSkypeOnlineSessionInfo = [PSCustomObject][ordered]@{
        Account                   = $UserName
        Environment               = 'SfBPowerShellSession'
        Tenant                    = $TenantInformation.DisplayName
        TenantId                  = $TenantInformation.TenantId
        TenantDomain              = $TenantDomain
        ComputerName              = $PSSkypeOnlineSession.ComputerName
        SkypeOnlineIdleTimeout    = $PSSkypeOnlineSession.IdleTimeout
        TeamsUpgradeEffectiveMode = $TenantInformation.TeamsUpgradeEffectiveMode
        }

      $PSSkypeOnlineSessionInfo
    }
  }

  # MicrosoftTeams
  if ($ConnectALL -or $ConnectToTeams) {
    try {
      Write-Verbose -Message "Establishing connection to MicrosoftTeams" -Verbose
      if ((Test-MicrosoftTeamsConnection) -and -not $Silent) {
          Connect-MicrosoftTeams -AccountID $Username
      }
      else {
          $null = (Connect-MicrosoftTeams -AccountID $Username) 
      }
    }
    catch {
      Write-Error   -Message "Could not establish Connection to MicrosoftTeams" `
      -RecommendedAction "Run Connect-MicrosoftTeams manually" `
      -Category NotEnabled `
      -Exception $_.Exception.Message
    }
  }

  # AzureAD
  if ($ConnectALL -or $ConnectToAAD) {
    try {
      Write-Verbose -Message "Establishing connection to AzureAD" -Verbose
      $null = (Connect-AzureAD -AccountID $Username)
      if ((Test-AzureADConnection) -and -not $Silent) {
        Get-AzureADCurrentSessionInfo

        Write-Host "Displaying assigned Admin Roles for Account: $Username" -ForegroundColor DarkYellow
        Get-AzureAdAssignedAdminRoles (Get-AzureADCurrentSessionInfo).Account | Select-Object DisplayName,Description | Format-Table -AutoSize
      }
    }
    catch {
      Write-Error   -Message "Could not establish Connection to AzureAD" `
      -RecommendedAction "Run Connect-AzureAD manually" `
      -Category NotEnabled `
      -Exception $_.Exception.Message
    }
  }
  #endregion
return 
}

function Disconnect-SkypeTeamsAndAAD {
  # Helper function to do all three 
  # Module
  Import-Module SkypeOnlineConnector -Global
  Import-Module AzureAD -Global
  Import-Module MicrosoftTeams -Global
  
  try {
    $null = (Disconnect-SkypeOnline -ErrorAction SilentlyContinue)
    $null = (Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue)
    $null = (Disconnect-AzureAD -ErrorAction SilentlyContinue)  
  }
  catch {}
}

Set-Alias -Name con -Value Connect-SkypeTeamsAndAAD
Set-Alias -Name Connect-Me -Value Connect-SkypeTeamsAndAAD

function Disconnect-SkypeOnline {
  <#
      .SYNOPSIS
      Disconnects any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
      .EXAMPLE
      Disconnect-SkypeOnline
      Removes any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
  #>

  [CmdletBinding()]
  param()

  [bool]$sessionFound = $false

  $PSSesssions = Get-PSSession -WarningAction SilentlyContinue

  foreach ($session in $PSSesssions)
  {
    if ($session.ComputerName -like "*.online.lync.com")
    {
      $sessionFound = $true
      Remove-PSSession $session
    }
  }

  Get-Module | Where-Object {$_.Description -like "*.online.lync.com*"} | Remove-Module

  if ($sessionFound -eq $false)
  {
    Write-Verbose -Message "No remote PowerShell sessions to Skype Online currently exist"
  }

} # End of Disconnect-SkypeOnline

function Get-SkypeOnlineConferenceDialInNumbers {
  <#
      .SYNOPSIS
      Gathers the audio conference dial-in numbers information for a Skype for Business Online tenant.
      .DESCRIPTION
      This command uses the tenant's conferencing dial-in number web page to gather a "user-readable" list of
      the regions, numbers, and available languages where dial-in conferencing numbers are available. This web
      page can be access at https://dialin.lync.com/DialInOnline/Dialin.aspx?path=<DOMAIN> replacing "<DOMAIN>"
      with the tenant's default domain name (i.e. contoso.com).
      .PARAMETER Domain
      The Skype for Business Online Tenant domain to gather the conference dial-in numbers.
      .EXAMPLE
      Get-SkypeOnlineConferenceDialInNumbers -Domain contoso.com
      Example 1 will gather the conference dial-in numbers for contoso.com based on their conference dial-in number web page.
      .NOTES
      This function was taken 1:1 from SkypeFunctions and remains untested for Teams
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,HelpMessage="Enter the domain name to gather the available conference dial-in numbers")]
    [string]$Domain
  )

  # Testing SkypeOnline Connection
  if (-not (Test-SkypeOnlineConnection)) {
    Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  try
  {
    $siteContents = Invoke-WebRequest https://webdir1a.online.lync.com/DialinOnline/Dialin.aspx?path=$Domain -ErrorAction STOP
  }
  catch
  {
    Write-Warning -Message "Unable to access that dial-in page. Please check the domain name and try again. Also try to manually navigate to the page using the URL http://dialin.lync.com/DialInOnline/Dialin.aspx?path=$Domain."
    return
  }

  $tables = $siteContents.ParsedHtml.getElementsByTagName("TABLE")
  $table = $tables[0]
  $rows = @($table.rows)

  $output = [PSCustomObject][ordered]@{
    Location = $null
    Number = $null
    Languages = $null
  }

  for ($n = 0; $n -lt $rows.Count; $n += 1)
  {
    if ($rows[$n].innerHTML -like "<TH*")
    {
      $output.Location = $rows[$n].innerText
    }
    else
    {
      $output.Number = $rows[$n].cells[0].innerText
      $output.Languages = $rows[$n].cells[1].innerText
      Write-Output $output
    }
  }
} # End of Get-SkypeOnlineConferenceDialInNumbers

function Get-TeamsUserLicense {
  <#
      .SYNOPSIS
      Gathers licenses assigned to a Teams user for Cloud PBX and PSTN Calling Plans.
      .DESCRIPTION
      This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License
      .PARAMETER Identity
      The Identity/UPN/sign-in address for the user entered in the format <name>@<domain>.
      Aliases include: "UPN","UserPrincipalName","Username"
      .EXAMPLE
      Get-TeamsUserLicense -Identity John@domain.com
      Example 1 will confirm the license for a single user: John@domain.com
      .EXAMPLE
      Get-TeamsUserLicense -Identity John@domain.com,Jane@domain.com
      Example 2 will confirm the licenses for two users: John@domain.com & Jane@domain.com
      .EXAMPLE
      Import-Csv User.csv | Get-TeamsUserLicense
      Example 3 will use a CSV as an input file and confirm the licenses for users listed in the file. The input file must
      have a single column heading of "Identity" with properly formatted UPNs.
      .NOTES
      If using a CSV file for pipeline input, the CSV user data file should contain a column name matching each of this script's parameters. Example:
      Identity
      John@domain.com
      Jane@domain.com
      Output can be redirected to a file or grid-view.
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, 
              HelpMessage = "Enter the UPN or login name of the user account, typically <user>@<domain>.")]
    [Alias("UPN","UserPrincipalName","Username")]
    [string[]]$Identity
  )

  BEGIN
  {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }
  } # End of BEGIN

  PROCESS
  {
    foreach ($User in $Identity)
    {
      try
      {
        Get-AzureADUser -ObjectId $User -ErrorAction STOP | Out-Null
      }
      catch
      {
        $output = [PSCustomObject][ordered]@{
          User = $User
          License = "Invalid User"
          SkuPartNumber = "Invalid User"
          CallingPlan = "Invalid User"
          CommunicationsCreditLicense = "Invalid User"
          AudioConferencingAddOn = "Invalid User"
          CommoneAreaPhoneLicense = "Invalid User"
        }

        Write-Output $output
        continue
      }
                        
      $userInformation = Get-AzureADUser -ObjectId $User
      $assignedLicenses = (Get-AzureADUserLicenseDetail -ObjectId $User).SkuPartNumber
      [string]$DisplayName = $userInformation.Surname + ", " + $userInformation.GivenName
      [string]$O365License = $null
      [string]$currentCallingPlan = "Not Assigned"
      [bool]$CommunicationsCreditLicense = $false
      [bool]$AudioConferencingAddOn = $false
      [bool]$CommonAreaPhoneLicense = $false

      if ($null -ne $assignedLicenses)
      {
        foreach ($license in $assignedLicenses)
        {
          switch -Wildcard ($license)
          {
            "DESKLESSPACK"                  {$O365SkuParNrs += $license; $O365License += "Kiosk Plan, ";break}
            "EXCHANGEDESKLESS"              {$O365SkuParNrs += $license; $O365License += "Exchange Kiosk, "; break}
            "EXCHANGESTANDARD"              {$O365SkuParNrs += $license; $O365License += "Exchange Standard, "; break}
            "EXCHANGEENTERPRISE"            {$O365SkuParNrs += $license; $O365License += "Exchange Premium, "; break}
            "MCOSTANDARD"                   {$O365SkuParNrs += $license; $O365License += "Skype Plan 2, "; break}
            "STANDARDPACK"                  {$O365SkuParNrs += $license; $O365License += "Office 365 E1, "; break}
            "ENTERPRISEPACK"                {$O365SkuParNrs += $license; $O365License += "Office 365 E3, "; break}
            "ENTERPRISEPREMIUM"             {$O365SkuParNrs += $license; $O365License += "Office 365 E5, "; break}
            "ENTERPRISEPREMIUM_NOPSTNCONF"  {$O365SkuParNrs += $license; $O365License += "Office 365 E5 (No Audio Conferencing), "; break}
            "SPE_E3"                        {$O365SkuParNrs += $license; $O365License += "Microsoft 365 E3, "; break}
            "SPE_E5"                        {$O365SkuParNrs += $license; $O365License += "Microsoft 365 E5, "; break}
            "MCOEV"                         {$O365SkuParNrs += $license; $O365License += "PhoneSystem, "; break}
            "PHONESYSTEM_VIRTUALUSER"       {$O365SkuParNrs += $license; $O365License = "PhoneSystem - Virtual User"; break}
            "MCOCAP"                        {$O365SkuParNrs += $license; $CommonAreaPhoneLicense = $true; break}
            "MCOPSTN1"                      {$O365SkuParNrs += $license; $currentCallingPlan = "Domestic"; break}
            "MCOPSTN2"                      {$O365SkuParNrs += $license; $currentCallingPlan = "Domestic and International"; break}
            "MCOPSTNC"                      {$O365SkuParNrs += $license; $CommunicationsCreditLicense = $true; break}
            "MCOMEETADV"                    {$O365SkuParNrs += $license; $AudioConferencingAddOn = $true; break}
          }
        }
      }
      else
      {
        $O365License = "No Licenses Assigned"
      }
            
      $output = [PSCustomObject][ordered]@{
        User                        = $User
        DisplayName                 = $DisplayName                
        License                     = $O365License.TrimEnd(", ") # Removes any trailing ", " at the end of the string
        SkuPartNumber               = $O365SkuParNrs.TrimEnd(", ") # Removes any trailing ", " at the end of the string
        CallingPlan                 = $currentCallingPlan                
        CommunicationsCreditLicense = $CommunicationsCreditLicense
        AudioConferencingAddOn      = $AudioConferencingAddOn
        CommoneAreaPhoneLicense     = $CommonAreaPhoneLicense                
      }

      Write-Output $output      
    } # End of foreach ($UserPrincipal in $Identity)
  } # End of PROCESS
} # End of Get-TeamsUserLicense

function Get-TeamsTenantLicenses {
  <#
      .SYNOPSIS
      Displays the individual plans, add-on & grouped license SKUs for Teams in the tenant.
      .DESCRIPTION
      Teams services can be provisioned through several different combinations of individual
      plans as well as add-on and grouped license SKUs. This command displays these license SKUs in a more friendly
      format with descriptive names, SKUpartNumber, active, consumed, remaining, and expiring licenses.
      .EXAMPLE
      Get-TeamsTenantLicenses
      Example 1 will display all the Skype related licenses for the tenant.
      .NOTES
      Requires the Azure Active Directory PowerShell module to be installed and authenticated to the tenant's Azure AD instance.
  #>

  [CmdletBinding()]
  param()

  # Testing AzureAD Connection
  if (-not (Test-AzureADConnection)) {
    Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  try
  {
    $tenantSKUs = Get-AzureADSubscribedSku -ErrorAction STOP
  }
  catch
  {
    Write-Warning $_
    RETURN
  }

  foreach ($tenantSKU in $tenantSKUs)
  {
    [string]$skuFriendlyName = $null
    switch ($tenantSKU.SkuPartNumber)
    {
      "MCOPSTN1" {$skuFriendlyName = "Domestic Calling Plan"; break}
      "MCOPSTN2" {$skuFriendlyName = "Domestic and International Calling Plan"; break}
      "MCOPSTNC" {$skuFriendlyName = "Communications Credit Add-On"; break}
      "MCOMEETADV" {$skuFriendlyName = "Audio Conferencing Add-On"; break}
      "MCOEV" {$skuFriendlyName = "PhoneSystem"; break}
      "MCOCAP" {$skuFriendlyName = "Common Area Phone"; break}
      "ENTERPRISEPREMIUM" {$skuFriendlyName = "Office 365 E5 with Phone System"; break}
      "ENTERPRISEPREMIUM_NOPSTNCONF" {$skuFriendlyName = "Office 365 E5 Without Audio Conferencing"; break}
      "ENTERPRISEPACK" {$skuFriendlyName = "Office 365 E3"; break}
      "STANDARDPACK" {$skuFriendlyName = "Office 365 E1"; break}
      "MCOSTANDARD" {$skuFriendlyName = "Skype for Business Online Standalone Plan 2"; break}
      "O365_BUSINESS_PREMIUM" {$skuFriendlyName = "O365 Business Premium"; break}
      "PHONESYSTEM_VIRTUALUSER" {$skuFriendlyName = "PhoneSystem - Virtual User"; break}
      "SPE_E3" {$skuFriendlyName = "Microsoft 365 E3"; break}
      "SPE_E5" {$skuFriendlyName = "Microsoft 365 E5"; break}
      
    }
        
    if ($skuFriendlyName.Length -gt 0)
    {
      [PSCustomObject][ordered]@{
        License       = $skuFriendlyName
        SkuPartNumber = $tenantSKU.SkuPartNumber
        Available     = $tenantSKU.PrepaidUnits.Enabled
        Consumed      = $tenantSKU.ConsumedUnits
        Remaining     = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
        Expiring      = $tenantSKU.PrepaidUnits.Warning
      }
    }    
  } # End of foreach ($tenantSKU in $tenantSKUs}
} # End of Get-TeamsTenantLicenses

function Remove-TenantDialPlanNormalizationRule {
  <#
      .SYNOPSIS
      Removes a normalization rule from a tenant dial plan.
      .DESCRIPTION
      This command will display the normalization rules for a tenant dial plan in a list with
      index numbers. After choosing one of the rule index numbers, the rule will be removed from
      the tenant dial plan. This command requires a remote PowerShell session to Teams.
      Note: The Module name is still referencing Skype for Business Online (SkypeOnlineConnector).
      .PARAMETER DialPlan
      This is the name of a valid dial plan for the tenant. To view available tenant dial plans,
      use the command Get-CsTenantDialPlan.
      .EXAMPLE
      Remove-TenantDialPlanNormalizationRule -DialPlan US-OK-OKC-DialPlan
      Example 1 will display the availble normalization rules to remove from dial plan US-OK-OKC-DialPlan.
      .NOTES
      The dial plan rules will display in format similar the example below:
      RuleIndex Name            Pattern    Translation
      --------- ----            -------    -----------
      0 Intl Dialing    ^011(\d+)$ +$1
      1 Extension Rule  ^(\d{5})$  +155512$1
      2 Long Distance   ^1(\d+)$   +1$1
      3 Default         ^(\d+)$    +1$1
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Enter the name of the dial plan to modify the normalization rules.")]
    [string]$DialPlan
  )

  # Testing SkypeOnline Connection
  if (-not (Test-SkypeOnlineConnection)) {
    Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  $dpInfo = Get-CsTenantDialPlan -Identity $DialPlan -ErrorAction SilentlyContinue

  if ($null -ne $dpInfo)
  {
    $currentNormRules = $dpInfo.NormalizationRules
    [int]$ruleIndex = 0
    [int]$ruleCount = $currentNormRules.Count
    [array]$ruleArray = @()
    [array]$indexArray = @()

    if ($ruleCount -ne 0)
    {
      foreach ($normRule in $dpInfo.NormalizationRules)
      {
        $output = [PSCustomObject][ordered]@{
          'RuleIndex' = $ruleIndex
          'Name' = $normRule.Name
          'Pattern' = $normRule.Pattern
          'Translation' = $normRule.Translation
        }

        $ruleArray += $output
        $indexArray += $ruleIndex
        $ruleIndex++
      } # End of foreach ($normRule in $dpInfo.NormalizationRules)

      # Displays rules to the screen with RuleIndex added
      $ruleArray | Out-Host

      do
      {
        $indexToRemove = Read-Host -Prompt "Enter the Rule Index of the normalization rule to remove from the dial plan (leave blank to quit without changes)"
                
        if ($indexToRemove -notin $indexArray -and $indexToRemove.Length -ne 0)
        {
          Write-Warning -Message "That is not a valid Rule Index. Please try again or leave blank to quit."
        }
      } until ($indexToRemove -in $indexArray -or $indexToRemove.Length -eq 0)

      if ($indexToRemove.Length -eq 0) {RETURN}

      # If there is more than 1 rule left, remove the rule and set to new normalization rules
      # If there is only 1 rule left, we have to set -NormalizationRules to $null
      if ($ruleCount -ne 1)
      {
        $newNormRules = $currentNormRules
        $newNormRules.Remove($currentNormRules[$indexToRemove])
        Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $newNormRules
      }
      else
      {
        Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $null
      }
    }
    else
    {
      Write-Warning -Message "$DialPlan does not contain any normalization rules."
    }
  }
  else
  {
    Write-Warning -Message "$DialPlan is not a valid dial plan for the tenant. Please try again."
  }
} # End of Remove-TenantDialPlanNormalizationRule



# Assigning Policies to Users
# ToDo: Add more policies
function Set-TeamsUserPolicy {
  <#
      .SYNOPSIS
      Sets policies on a Teams user
      .DESCRIPTION
      Teams offers the assignment of several policies, to control multiple aspects of the Users experience.
      For example: TeamsUpgrade, Client, Conferencing, External access, Mobility.
      Typically these are assigned using different commands, but
      Set-TeamsUserPolicy allows settings all these with a single command. One or all policy options can
      be used during assignment.
      .PARAMETER Identity
      This is the sign-in address/User Principal Name of the user to configure.
      .PARAMETER TeamsUpgradePolicy
      This is one of the available TeamsUpgradePolicies to assign to the user.
      .PARAMETER ClientPolicy
      This is the Client Policy to assign to the user.
      .PARAMETER ConferencingPolicy
      This is the Conferencing Policy to assign to the user.
      .PARAMETER ExternalAccessPolicy
      This is the External Access Policy to assign to the user.
      .PARAMETER MobilityPolicy
      This is the Mobility Policy to assign to the user.
      .EXAMPLE
      Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL
      Example 1 will set the user John.Does@contoso.com with a client policy.
      .EXAMPLE
      Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL -ConferencingPolicy BposSAllModalityNoFT
      Example 2 will set the user John.Does@contoso.com with a client and conferencing policy.
      .EXAMPLE
      Set-TeamsUserPolicy -Identity John.Doe@contoso.com -ClientPolicy ClientPolicyNoIMURL -ConferencingPolicy BposSAllModalityNoFT -ExternalAccessPolicy FederationOnly -MobilityPolicy
      Example 3 will set the user John.Does@contoso.com with a client, conferencing, external access, and mobility policy.
      .NOTES
      TeamsUpgrade Policy has been added.
      Multiple other policies are planned to be added to round the function off
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Enter the identity for the user to configure")]
    [Alias("UPN","UserPrincipalName","Username")]
    [string]$Identity,
        
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$TeamsUpgradePolicy,
    
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ClientPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ConferencingPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$ExternalAccessPolicy,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$MobilityPolicy
  )

  BEGIN
  {
    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Get available policies for tenant
    Write-Verbose -Message "Gathering all policies for tenant"
    $tenantTeamsUpgradePolicies   = (Get-CsTeamsUpgradePolicy -WarningAction SilentlyContinue).Identity
    $tenantClientPolicies         = (Get-CsClientPolicy -WarningAction SilentlyContinue).Identity
    $tenantConferencingPolicies   = (Get-CsConferencingPolicy -Include SubscriptionDefaults -WarningAction SilentlyContinue).Identity
    $tenantExternalAccessPolicies = (Get-CsExternalAccessPolicy -WarningAction SilentlyContinue).Identity
    $tenantMobilityPolicies       = (Get-CsMobilityPolicy -WarningAction SilentlyContinue).Identity
  } # End of BEGIN

  PROCESS
  {
    foreach ($ID in $Identity)
    {
      #User Validation
      # NOTE: Validating users in a try/catch block does not catch the error properly and does not allow for custom outputting of an error message
      if ($null -ne (Get-CsOnlineUser -Identity $ID -ErrorAction SilentlyContinue))
      {
        #region Teams Upgrade Policy
        if ($PSBoundParameters.ContainsKey("TeamsUpgradePolicy"))
        {
          # Verify if $TeamsUpgradePolicy is a valid policy to assign
          if ($tenantTeamsUpgradePolicies -icontains "Tag:$TeamsUpgradePolicy")
          {
            try
            {
              # Attempt to assign policy
              Grant-CsClientPolicy -Identity $ID -PolicyName $ClientPolicy -WarningAction SilentlyContinue -ErrorAction STOP
              $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Success: $TeamsUpgradePolicy"
            }
            catch
            {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $errorMessage"
            }
          }
          else
          {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $TeamsUpgradePolicy is not valid or does not exist"
          }

          # Output final TeamsUpgradePolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Teams Upgrade Policy
        #endregion

        #region Client Policy
        if ($PSBoundParameters.ContainsKey("ClientPolicy"))
        {
          # Verify if $ClientPolicy is a valid policy to assign
          if ($tenantClientPolicies -icontains "Tag:$ClientPolicy")
          {
            try
            {
              # Attempt to assign policy
              Grant-CsClientPolicy -Identity $ID -PolicyName $ClientPolicy -WarningAction SilentlyContinue -ErrorAction STOP
              $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Success: $ClientPolicy"
            }
            catch
            {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $errorMessage"
            }
          }
          else
          {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $ClientPolicy is not valid or does not exist"
          }

          # Output final ClientPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Client Policy
        #endregion

        #region Conferencing Policy
        if ($PSBoundParameters.ContainsKey("ConferencingPolicy"))
        {
          # Verify if $ConferencingPolicy is a valid policy to assign
          if ($tenantConferencingPolicies -icontains "Tag:$ConferencingPolicy")
          {
            try
            {
              # Attempt to assign policy
              Grant-CsConferencingPolicy -Identity $ID -PolicyName $ConferencingPolicy -WarningAction SilentlyContinue -ErrorAction STOP
              $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Success: $ConferencingPolicy"
            }
            catch
            {
              # Output to error log file on policy assignment error
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $errorMessage"
            }
          }
          else
          {
            # Output invalid conferencing policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $ConferencingPolicy is not valid or does not exist"
          }

          # Output final ConferencingPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Conferencing Policy
        #endregion
    
        #region External Access Policy
        if ($PSBoundParameters.ContainsKey("ExternalAccessPolicy"))
        {
          # Verify if $ExternalAccessPolicy is a valid policy to assign
          if ($tenantExternalAccessPolicies -icontains "Tag:$ExternalAccessPolicy")
          {
            try
            {
              # Attempt to assign policy
              Grant-CsExternalAccessPolicy -Identity $ID -PolicyName $ExternalAccessPolicy -WarningAction SilentlyContinue -ErrorAction STOP
              $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Success: $ExternalAccessPolicy"
            }
            catch
            {
              $errorMessage = $_                            
              $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $errorMessage"
            }
          }
          else
          {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $ExternalAccessPolicy is not valid or does not exist"
          }

          # Output final ExternalAccessPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting External Access Policy
        #endregion

        #region Mobility Policy
        if ($PSBoundParameters.ContainsKey("MobilityPolicy"))
        {
          # Verify if $MobilityPolicy is a valid policy to assign
          if ($tenantMobilityPolicies -icontains "Tag:$MobilityPolicy")
          {
            try
            {
              # Attempt to assign policy
              Grant-CsMobilityPolicy -Identity $ID -PolicyName $MobilityPolicy -WarningAction SilentlyContinue -ErrorAction STOP
              $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Success: $MobilityPolicy"
            }
            catch
            {
              $errorMessage = $_                            
              $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $errorMessage"
            }
          }
          else
          {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $MobilityPolicy is not valid or does not exist"
          }

          # Output final MobilityPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Mobility Policy
        #endregion
      } # End of setting policies
      else
      {
        $output = GetActionOutputObject3 -Name $ID -Property "User Validation" -Result "Error: Not a valid Skype user account"
        Write-Output -InputObject $output
      }
    } # End of foreach ($ID in $Identity)
  } # End of PROCESS block
} # End of Set-TeamsUserPolicy



function Test-TeamsExternalDNS {
  <#
      .SYNOPSIS
      Tests a domain for the required external DNS records for a Teams deployment.
      .DESCRIPTION
      Teams requires the use of several external DNS records for clients and federated
      partners to locate services and users. This function will look for the required external DNS records
      and display their current values, if they are correctly implemented, and any issues with the records.
      .PARAMETER Domain
      The domain name to test records. This parameter is required.
      .EXAMPLE
      Test-TeamsExternalDNS -Domain contoso.com
      Example 1 will test the contoso.com domain for the required external DNS records for Teams.
  #>

  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory=$true, HelpMessage="This is the domain name to test the external DNS Skype Online records.")]
    [string]$Domain
  )

  # VARIABLES
  [string]$federationSRV = "_sipfederationtls._tcp.$Domain"
  [string]$sipSRV = "_sip._tls.$Domain"
  [string]$lyncdiscover = "lyncdiscover.$Domain"
  [string]$sip = "sip.$Domain"

  # Federation SRV Record Check
  $federationSRVResult = Resolve-DnsName -Name "_sipfederationtls._tcp.$Domain" -Type SRV -ErrorAction SilentlyContinue
  $federationOutput = [PSCustomObject][ordered]@{
    Name = $federationSRV
    Type = "SRV"
    Target = $null
    Port = $null
    Correct = "Yes"
    Notes = $null
  }

  if ($null -ne $federationSRVResult)
  {
    $federationOutput.Target = $federationSRVResult.NameTarget
    $federationOutput.Port = $federationSRVResult.Port
    if ($federationOutput.Target -ne "sipfed.online.lync.com")
    {
      $federationOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $federationOutput.Correct = "No"
    }

    if ($federationOutput.Port -ne "5061")
    {
      $federationOutput.Notes += "Port is not set to 5061. "
      $federationOutput.Correct = "No"
    }
  }
  else
  {
    $federationOutput.Notes = "Federation SRV record does not exist. "
    $federationOutput.Correct = "No"
  }

  Write-Output -InputObject $federationOutput
    
  # SIP SRV Record Check
  $sipSRVResult = Resolve-DnsName -Name $sipSRV -Type SRV -ErrorAction SilentlyContinue
  $sipOutput = [PSCustomObject][ordered]@{
    Name = $sipSRV
    Type = "SRV"
    Target = $null
    Port = $null
    Correct = "Yes"
    Notes = $null
  }

  if ($null -ne $sipSRVResult)
  {
    $sipOutput.Target = $sipSRVResult.NameTarget
    $sipOutput.Port = $sipSRVResult.Port
    if ($sipOutput.Target -ne "sipdir.online.lync.com")
    {
      $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $sipOutput.Correct = "No"
    }

    if ($sipOutput.Port -ne "443")
    {
      $sipOutput.Notes += "Port is not set to 443. "
      $sipOutput.Correct = "No"
    }
  }
  else
  {
    $sipOutput.Notes = "SIP SRV record does not exist. "
    $sipOutput.Correct = "No"
  }

  Write-Output -InputObject $sipOutput

  #Lyncdiscover Record Check
  $lyncdiscoverResult = Resolve-DnsName -Name $lyncdiscover -Type CNAME -ErrorAction SilentlyContinue
  $lyncdiscoverOutput = [PSCustomObject][ordered]@{
    Name = $lyncdiscover
    Type = "CNAME"
    Target = $null
    Port = $null
    Correct = "Yes"
    Notes = $null
  }

  if ($null -ne $lyncdiscoverResult)
  {
    $lyncdiscoverOutput.Target = $lyncdiscoverResult.NameHost
    $lyncdiscoverOutput.Port = "----"
    if ($lyncdiscoverOutput.Target -ne "webdir.online.lync.com")
    {
      $lyncdiscoverOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $lyncdiscoverOutput.Correct = "No"
    }
  }
  else
  {
    $lyncdiscoverOutput.Notes = "Lyncdiscover record does not exist. "
    $lyncdiscoverOutput.Correct = "No"
  }

  Write-Output -InputObject $lyncdiscoverOutput

  #SIP Record Check
  $sipResult = Resolve-DnsName -Name $sip -Type CNAME -ErrorAction SilentlyContinue
  $sipOutput = [PSCustomObject][ordered]@{
    Name = $sip
    Type = "CNAME"
    Target = $null
    Port = $null
    Correct = "Yes"
    Notes = $null
  }

  if ($null -ne $sipResult)
  {
    $sipOutput.Target = $sipResult.NameHost
    $sipOutput.Port = "----"
    if ($sipOutput.Target -ne "sipdir.online.lync.com")
    {
      $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $sipOutput.Correct = "No"
    }
  }
  else
  {
    $sipOutput.Notes = "SIP record does not exist. "
    $sipOutput.Correct = "No"
  }

  Write-Output -InputObject $sipOutput
} # End of Test-TeamsExternalDNS

function Test-AzureADModule {
  <#
      .SYNOPSIS
      Tests whether the AzureAD Module is loaded
      .EXAMPLE
      Test-AzureADModule
      Will Return $TRUE if the Module is loaded

  #>
  [CmdletBinding()]
  param()

  Write-Verbose -Message "Verifying if AzureAD module is installed and available"

  if ((Get-Module "AzureAD" -ListAvailable).count -lt 1)
  {
    Write-Warning -Message "Azure Active Directory PowerShell module is not installed. Please install and try again."
    return $false
  }
  else {
    return $true
  }
} # End of Test-AzureADModule

function Test-AzureADConnection {
  <#
      .SYNOPSIS
      Tests whether a valid PS Session exists for Azure Active Directory (v2)
      .DESCRIPTION
      A connection established via Connect-AzureAD is parsed.
      .EXAMPLE
      Test-AzureADConnection
      Will Return $TRUE only if a session is found.
  #>
  [CmdletBinding()]
  param()

  try
  {
    $null = (Get-AzureADCurrentSessionInfo -ErrorAction STOP)
    return $true
  }
  catch
  {
    return $false
  }
} # End of Test-AzureADConnection

function Test-SkypeOnlineModule {
  <#
      .SYNOPSIS
      Tests whether the SkypeOnlineConnector Module is loaded
      .EXAMPLE
      Test-SkypeOnlineModule
      Will Return $TRUE if the Module is loaded

  #>
  [CmdletBinding()]
  param()
      
  if ((Get-Module "SkypeOnlineConnector" -ListAvailable).count -lt 1)
  {        
    return $false
  }
  else
  {
    return $true
  }
} # End of Test-SkypeOnlineModule

function Test-SkypeOnlineConnection {
  <#
      .SYNOPSIS
      Tests whether a valid PS Session exists for SkypeOnline (Teams)
      .DESCRIPTION
      A connection established via Connect-SkypeOnline is parsed.
      This connection must be valid (Available and Opened)
      .EXAMPLE
      Test-SkypeOnlineConnection
      Will Return $TRUE only if a valid and open session is found.
      .NOTES
      Added check for Open Session to err on the side of caution. 
      Use with DisConnect-SkypeOnline when tested negative, then Connect-SkypeOnline
  #>

  [CmdletBinding()]
  param()

  if ((Get-PsSession).ComputerName -notlike "*.online.lync.com")
  {
    return $false
  }
  else
    {
      $PSSkypeOnlineSession = Get-PsSession | Where-Object {$_.ComputerName -like "*.online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available"}
      if ($PSSkypeOnlineSession.Count -lt 1)
      {
        return $false
      }
      else
      {
        return $true
      }
    }
} # End of Test-SkypeOnlineModule
#endregion

#region New Functions
function Test-MicrosoftTeamsModule {
  <#
      .SYNOPSIS
      Tests whether the MicrosoftTeams Module is loaded
      .EXAMPLE
      Test-AzureADModule
      Will Return $TRUE if the Module is loaded

  #>
  [CmdletBinding()]
  param()

  Write-Verbose -Message "Verifying if MicrosoftTeams module is installed and available"

  if ((Get-Module "MicrosoftTeams" -ListAvailable).count -lt 1)
  {
    Write-Warning -Message "MicrosoftTeams PowerShell module is not installed. Please install and try again."
    return $false
  }
  else {
    return $true
  }
} # End of Test-MicrosoftTeamsModule

function Test-MicrosoftTeamsConnection {
  <#
      .SYNOPSIS
      Tests whether a valid PS Session exists for MicrosoftTeams
      .DESCRIPTION
      A connection established via Connect-MicrosoftTeams is parsed.
      .EXAMPLE
      Test-MicrosoftTeamsConnection
      Will Return $TRUE only if a session is found.
  #>
  [CmdletBinding()]
  param()

  try
  {
    $null = (Get-CsPolicyPackage -ErrorAction STOP)
    return $true
  }
  catch
  {
    return $false
  }
} # End of Test-MicrosoftTeamsConnection

function Get-AzureADUserFromUPN {
  <#
      .SYNOPSIS
      Returns User Object in Azure AD from UPN
      .DESCRIPTION
      Enables UPN lookup for AzureAD user the User Object exist
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to test.
      .EXAMPLE
      Get-AzureADUserFromUPN -Identity $UPN
      Will Return the Object if UPN is found, otherwise returns error message from Get-AzureAdUser
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "This is the UserID (UPN)")]
    [Alias('UserPrincipalName')]
    [string]$Identity  
  )

  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try
    {
      $User = Get-AzureADUser -All:$true | Where-Object {$_.UserPrincipalName -eq $Identity} -ErrorAction STOP
      return $User
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException]
    {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
      }
      # output Info. Post-process collected info, and log info (optional)
      $info
    }
    catch
    {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
      }
      # output Info. Post-process collected info, and log info (optional)
      $info
    }
  }
} # End of Get-AzureADUserFromUPN


function Test-AzureADUser {
  <#
      .SYNOPSIS
      Tests whether a User exists in Azure AD (record found)
      .DESCRIPTION
      Simple lookup - does the User Object exist - to avoid TRY/CATCH statements for processing
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to test.
      .EXAMPLE
      Test-AzureADUser -Identity $UPN
      Will Return $TRUE only if the object $UPN is found.
      Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity  
  )

  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }
  
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try
    {
      $null = (Get-AzureADUser -All:$true | Where-Object {$_.UserPrincipalName -eq $Identity} -ErrorAction STOP)
      return $true
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException]
    {
      return $False
    }
    catch
    {
      return $False
    }
  }
} # End of Test-AzureADUser

function Test-AzureADGroup {
  <#
      .SYNOPSIS
      Tests whether an Group exists in Azure AD (record found)
      .DESCRIPTION
      Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing
      .PARAMETER Identity
      Mandatory. The User Principal Name of the Group to test.
      .EXAMPLE
      Test-AzureADGroup -Identity $UPN
      Will Return $TRUE only if the object $UPN is found.
      Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserPrincipalName of the Group")]
    [string]$Identity  
  )

  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }
  
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try
    {
      Get-AzureADGroup -ObjectId $Identity -ErrorAction STOP > $null
      return $true
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException]
    {
      return $False
    }
    catch
    {
      return $False
    }
  }
} # End of Test-AzureADGroup

function Test-TeamsUser {
  <#
      .SYNOPSIS
      Tests whether an Object exists in Teams (record found)
      .DESCRIPTION
      Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .EXAMPLE
      Test-TeamsUser -Identity $UPN
      Will Return $TRUE only if the object $UPN is found.
      Will Return $FALSE in any other case, including if there is no Connection to SkypeOnline!
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity   
  )

  begin {
    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

  }
  process {
    try
    {
      Get-CsOnlineUser -Identity $Identity -ErrorAction STOP | Out-Null
      return $true
    }
    catch [System.Exception]
    {
      return $False
    }
  }

} # End of Test-TeamsUser

function Test-TeamsTenantPolicy {
  <#
      .SYNOPSIS
      Tests whether a specific Policy exists in the Teams Tenant
      .DESCRIPTION
      Universal commandlet to test any Policy Object that can be granted to a User
      .PARAMETER Policy
      Mandatory. Name of the Policy Object - Which Policy? (PowerShell Noun of the Get/Grant Command).
      .PARAMETER PolicyName
      Mandatory. Name of the Policy to look up.
      .EXAMPLE
      Test-TeamsPolicy
      Will Return $TRUE only if a the policy was found in the Teams Tenant.
      .NOTES
      This is a crude but universal way of testing it, intended for check of multiple at a time.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the Noun of Policy, i.e. 'TeamsUpgradePolicy' of 'Get-TeamsUpgradePolicy'")]
    [Alias("Noun")]
    [string]$Policy,
    
    [Parameter(Mandatory = $true, HelpMessage = "This is the Name of the Policy to test")]
    [string]$PolicyName
  )
  begin {
    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Data Gathering
    try {
      $TestCommand = "Get-" + $Policy + " -ErrorAction Stop"
      Invoke-Expression "$TestCommand" -ErrorAction STOP | Out-Null
    }  
    catch {
      Write-Warning -Message "Policy Noun '$Policy' is invalid. No such Policy found!"
      return
    }
    finally {
      $Error.clear()
    }  
  }

  process{
    try {
      $Command = "Get-" + $Policy + " -Identity " + $PolicyName + " -ErrorAction Stop"
      Invoke-Expression "$Command" -ErrorAction STOP | Out-Null
      Return $true
    }
    catch [System.Exception] {
      if($_.FullyQualifiedErrorId -like "*MissingItem*") {
        Return $False
      }
      else {
        # get error record
        [Management.Automation.ErrorRecord]$e = $_

        # retrieve Info about runtime error
        $info = [PSCustomObject]@{
          Exception = $e.Exception.Message
          Reason    = $e.CategoryInfo.Reason
          Target    = $e.CategoryInfo.TargetName
          Script    = $e.InvocationInfo.ScriptName
          Line      = $e.InvocationInfo.ScriptLineNumber
          Column    = $e.InvocationInfo.OffsetInLine
        }
  
        # output Info. Post-process collected info, and log info (optional)
        $info
      }
    }
    finally {
      $Error.clear()
    }

  }
} # End of Test-TeamsTenantPolicy

function Test-TeamsUserLicense {
  <#
      .SYNOPSIS
      Tests a License or License Package assignment against an AzureAD-Object
      .DESCRIPTION
      Teams requires a specific License combination (LicensePackage) for a User.
      Teams Direct Routing requries a specific License (ServicePlan), namely 'Phone System'
      to enable a User for Enterprise Voice
      This Script can be used to ascertain either.
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .PARAMETER ServicePlan
      Switch. Defined and descriptive Name of the Service Plan to test.
      Only ServicePlanNames pertaining to Teams are tested.
      Returns $TRUE only if the ServicePlanName was found and the ProvisioningStatus is "Success"
      .PARAMETER LicensePackage
      Switch. Defined and descriptive Name of the License Combination to test.
      This will test multiple individual Service Plans are present
      .EXAMPLE
      Test-TeamsUserLicense -Identity User@domain.com -ServicePlan MCOEV
      Will Return $TRUE only if the License is assigned and ProvisioningStatus is SUCCESS!
      .EXAMPLE
      Test-TeamsUserLicense -Identity User@domain.com -LicensePackage Microsoft365E5
      Will Return $TRUE only if the license Package is assigned.
      Specific Names have been assigned to these LicensePackages
      .NOTES
      This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested. 
  #>
  #region Parameters
  [CmdletBinding(DefaultParameterSetName = "ServicePlan")]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity,

    [Parameter(Mandatory = $true, ParameterSetName = "ServicePlan", HelpMessage = "AzureAd Service Plan")]
    [ValidateSet("SPE_E5", "SPE_E3", "ENTERPRISEPREMIUM","ENTERPRISEPACK","MCOSTANDARD","MCOMEETADV","MCOEV","MCOEV_VIRTUALUSER","MCOCAP","MCOPSTN1","MCOPSTN2","MCOPSTNC")]
    [string]$ServicePlan,

    [Parameter(Mandatory = $true, ParameterSetName = "LicensePackage", HelpMessage = "Teams License Package: E5,E3,S2")]
    [ValidateSet("Microsoft365E5", "Microsoft365E3andPhoneSystem", "Office365E5","Office365E3andPhoneSystem","SFBOPlan2andAdvancedMeetingandPhoneSystem","CommonAreaPhoneLicense","PhoneSystem","PhoneSystem_VirtualUser")]
    [string]$LicensePackage
    
  )
  #endregion

  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

  }
  
  process{
    # Query User
    $UserObject = Get-AzureADUserFromUPN $Identity
    $DisplayName = $UserObject.DisplayName
    $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId)

    # ParameterSetName ServicePlan VS LicensePackage
    switch ($PsCmdlet.ParameterSetName) {
      "ServicePlan" 
      {
        Write-Verbose -Message "'$DisplayName' - Testing against '$ServicePlan'"
        IF($ServicePlan -in $UserLicenseObject.ServicePlans.ServicePlanName)
        {
          #Checks if the Provisioning Status is also "Success"
          $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object -Property ServicePlanName -EQ -Value $ServicePlanName).ProvisioningStatus
          IF($ServicePlanStatus -eq "Success")
          {
            Return $true
          }
          ELSE
          {
            Return $false
          }
        }
        ELSE
        {
          Return $false
        }
      }
      "LicensePackage" 
      {
        Write-Verbose -Message "'$DisplayName' - Testing against '$LicensePackage'"
        TRY
        {
          $UserLicenseSKU = $UserLicenseObject.SkuPartNumber
          SWITCH($LicensePackage)
          {
            "Microsoft365E5" 
            {
              # Combination 1 - Microsoft 365 E5 has PhoneSystem included
              IF("SPE_E5" -in $UserLicenseSKU) 
              {Return $TRUE}
              ELSE
              {Return $FALSE}
            }
            "Office365E5" 
            {
              # Combination 2 - Office 365 E5 has PhoneSystem included
              IF("ENTERPRISEPREMIUM" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}
            }
            "Microsoft365E3andPhoneSystem" 
            {
              # Combination 3 - Microsoft 365 E3 + PhoneSystem
              IF("MCOEV" -in $UserLicenseSKU -and "SPE_E3" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE} 
            }
            "Office365E3andPhoneSystem" 
            {
              # Combination 4 - Office 365 E3 + PhoneSystem
              IF("MCOEV" -in $UserLicenseSKU -and "ENTERPRISEPACK" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}      
            }
            "SFBOPlan2andAdvancedMeetingandPhoneSystem"
            {
              # Combination 5 - Skype for Business Online Plan 2 (S2) + Audio Conferencing + PhoneSystem
              # NOTE: This is a functioning license, but not one promoted by Microsoft.
              IF("MCOEV" -in $UserLicenseSKU -and "MCOMEEDADV" -in $UserLicenseSKU -and "MCOSTANDARD" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}
            }
            "CommonAreaPhoneLicense"
            {
              # Combination 6 - Common Area Phone
              # NOTE: This is for Common Area Phones ONLY!
              IF("MCOCAP" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}
            }           
            "PhoneSystem"
            {
              # Combination 7 - PhoneSystem
              # NOTE: This is for Resource Accounts ONLY!
              IF("MCOEV" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}
            }
            "PhoneSystem_VirtualUser"
            {
              # Combination 8 - PhoneSystem Virtual User License
              # NOTE: This is for Resource Accounts ONLY!
              IF("PHONESYSTEM_VIRTUALUSER" -in $UserLicenseSKU)
              {Return $TRUE}
              ELSE
              {Return $FALSE}    
            }
          }
        
        }
        catch {
        }       
      }
    }
  }
} # End of Test-TeamsUserLicense

#endregion

#region Call Queues - Work in Progress - 
function New-TeamsCallQueue {
  <#
  .SYNOPSIS
      New-CsCallQueue with UPNs instead of GUIDs
  .DESCRIPTION
      Does all the same things that New-CsCallQueue does, but differs in a few significant respects:
      UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
      Small changes to defaults (see Parameter UseMicrosoftDefaults for details)
      New-CsCallQueue   is used to create the Call Queue with minimum settings (Name and UseDefaultMusicOnHold)
      Set-CsCallQueue   is used to apply parameters dependent on specification.
      Partial implementation is possible, output will show differences.
  .PARAMETER Name
      Name of the Call Queue. Name will be normalised (unsuitable characters are filtered)
  .PARAMETER Silent
      Optional. Supresses output. Use for Bulk provisioning only.
      Will return the Output object, but not display any output on Screen.
  .PARAMETER UseMicrosoftDefaults
      This script uses different default values for some parameters than New-CsCallQueue
      Using this switch will instruct the Script to adhere to Microsoft defaults.
      ChangedPARAMETER:      This Script   Microsoft    Reason:
      - AllowOptOut:            FALSE         TRUE        Useful for smaller Call Queues
      - ConferenceMode:         TRUE          FALSE       Helpful with Call establishment
      - AgentAlertTime:         20s           30s         Shorter Alert Time more universally useful
      - OverflowThreshold:      30s           50s         Shorter Overflow more universally useful
      - TimeoutThreshold:       30s           1200s       Shorter Overflow more universally useful
      - UseDefaultMusicOnHold:  TRUE*         NONE        ONLY if neither UseDefaultMusicOnHold nor MusicOnHoldAudioFile are specificed
      NOTE: This only affects parameters which are NOT specified when running the script.
  .PARAMETER AgentAlertTime
      Optional. Time in Seconds to alert each agent. Works depending on Routing method
      NOTE: Size AgentAlertTime and TimeoutThreshold depending on Routing method and # of Agents available.
  .PARAMETER AllowOptOut
      Optional Switch. Allows Agents to Opt out of receiving calls from the Call Queue
  .PARAMETER UseDefaultMusicOnHold
      Optional Switch. Indicates whether the default Music On Hold should be used.
  .PARAMETER WelcomeMusicAudioFile
      Optional. Path to Audio File to be used as a Welcome message
      Accepted Formats: MP3, WAV or WMA format, max 5MB
  .PARAMETER MusicOnHoldAudioFile
      Optional. Path to Audio File to be used as Music On Hold.
      Required if UseDefaultMusicOnHold is not specified/set to TRUE
      Accepted Formats: MP3, WAV or WMA format, max 5MB
  .PARAMETER OverflowAction
      Optional. Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail
      Action to be taken if the Queue size limit (OverflowThreshold) is reached
      Forward requires specification of OverflowActionTarget
  .PARAMETER OverflowActionTarget
      Situational. Required only if OverflowAction is Forward
      UserPrincipalName of the Target
  .PARAMETER OverflowThreshold
      Optional. Default:  30s,   Microsoft Default:   50s (See Parameter UseMicrosoftDefaults)
      Time in Seconds for the OverflowAction to trigger
  .PARAMETER TimeoutAction
      Optional. Default: Disconnect, Values: Disconnect, Forward, VoiceMail
      Action to be taken if the TimeoutThreshold is reached
      Forward requires specification of TimeoutActionTarget
  .PARAMETER TimeoutActionTarget
      Situational. Required only if TimeoutAction is Forward
      UserPrincipalName of the Target
  .PARAMETER TimeoutThreshold
      Optional. Default:  30s,   Microsoft Default:  1200s (See Parameter UseMicrosoftDefaults)
      Time in Seconds for the TimeoutAction to trigger        
  .PARAMETER RoutingMethod
      Optional. Default: Attendant, Values: Attendant, Serial, RoundRobin,LongestIdle
      Describes how the Call Queue is hunting for an Agent.
      Serial will Alert them one by one in order specified (Distribution lists will contact alphabethically)
      Attendant behaves like Parallel if PresenceBasedRouting is used.
  .PARAMETER PresenceBasedRouting
      Optional. Default: FALSE. If used alerts Agents only when they are available (Teams status). 
  .PARAMETER ConferenceMode
      Optional. Default: TRUE,   Microsoft Default: FALSE
      Will establish a conference instead of a direct call and should help with connection time.
      Documentation vague.
  .PARAMETER DistributionLists
      Optional. UPNs of DistributionLists or Groups to be used as Agents.
      Will be parsed after Users if they are specified as well.
  .PARAMETER Users
      Optional. UPNs of Users.
      Will be parsed first. Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue"
      Creates a new Call Queue "My Queue" with the Default Music On Hold
      All other values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefautls
      Creates a new Call Queue "My Queue" with the Default Music On Hold
      All values not specified default to Microsoft defaults for New-CsCallQueue (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
      Creates a new Call Queue "My Queue" and sets it to overflow with more than 5 Callers waiting and a timeout window of 90s
      All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
      Creates a new Call Queue "My Queue" with custom Audio Files
      All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
      Creates a new Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.
      All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults
  .EXAMPLE
      New-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
      Creates a new Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.
      All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
  .NOTES
      Currently in Testing
  .FUNCTIONALITY
      Creates a Call Queue with custom settings and friendly names as input
  .LINK
    Get-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
  #>

  [CmdletBinding()]
  param(
      [Parameter(Mandatory=$true, HelpMessage = "Name of the Call Queue")]
      [string]$Name,

      [Parameter(HelpMessage = "No output is written to the screen, but Object returned for processing")]
      [switch]$Silent,

      #Deviation from MS Default (30s)
      [Parameter(HelpMessage = "Time an agent is alerted in seconds (15-180s)")]
      [ValidateScript({
          If ($_ -ge 15 -and $_ -le 180) {
            $True
          }
          else {
            Write-Host "Must be a value between 30 and 180s (3 minutes)" -ForeGroundColor Red
          }
        })]
      [int16]$AgentAlertTime = 20,
      
      #Deviation from MS Default
      [Parameter(HelpMessage = "Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)")]
      [switch]$AllowOptOut,

      [Parameter(HelpMessage = "Action to be taken for Overflow")]
      [Validateset("Voicemail","Forward","DisconnectWithBusy")]
      [string]$OverflowAction = "DisconnectWithBusy",

      #usually accepts GUID, needs to be captured, queried and translated into a guid (Get-AzureADUser?)
      #Only valid for $OverflowAction = "Forward"
      [Parameter(HelpMessage = "UPN that is targeted upon overflow, only valid for forwarded calls")]
      [ValidateScript({
          If ($_ -match '@') {
            $True
          }
          else {
            Write-Host "Must be a valid UPN" -ForeGroundColor Red
          }
        })]
      [string]$OverflowActionTarget,

      #Deviation from MS Default (50)
      [Parameter(HelpMessage = "Time in seconds (0-200s) before timeout action is triggered (Default: 10, Note: Microsoft default: 50)")]
      [ValidateScript({
          If ($_ -ge 0 -and $_ -le 200) {
            $True
          }
          else {
            Write-Host "Must be a value between 0 and 200s." -ForeGroundColor Red
          }
        })]
      [int16]$OverflowThreshold = 10,

      [Parameter(HelpMessage = "Action to be taken for Timeout")]
      [Validateset("Voicemail","Forward","Disconnect")]
      [string]$TimeoutAction = "Disconnect",

      #usually accepts GUID, needs to be captured, queried and translated into a guid (Get-AzureADUser?)
      #Only valid for $TimeoutAction = "Forward"
      [Parameter(HelpMessage = "UPN that is targeted upon timeout, only valid for forwarded calls")]
      [ValidateScript({
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string]$TimeoutActionTarget,

      #Deviation from MS Default (1200s)
      [Parameter(HelpMessage = "Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)")]
      [ValidateScript({
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          Write-Host "Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)" -ForeGroundColor Red
        }
      })]
      [int16]$TimeoutThreshold = 30,
      
      [Parameter(HelpMessage = "Method to alert Agents")]
      [Validateset("Attendant","Serial","RoundRobin","LongestIdle")]
      [string]$RoutingMethod = "Attendant",

      [Parameter(HelpMessage = "If used, Agents receive calls only when their presence state is Available")]
      [switch]$PresenceBasedRouting = $false,

      [Parameter(HelpMessage = "Indicates whether the default Music On Hold is used")]
      [switch]$UseDefaultMusicOnHold,

      [Parameter(HelpMessage = "If used, Conference mode is used to establish calls")]
      [switch]$ConferenceMode = $false,

      [Parameter(HelpMessage = "Path to Audio File for WelcomeMuic")]
      [ValidateScript({
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
        }
      })]
      [string]$WelcomeMusicAudioFile,
      
      [Parameter(HelpMessage = "Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)")]
      [ValidateScript({
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
        }
      })]
      [string]$MusicOnHoldAudioFile,

      #Agents
      [Parameter(HelpMessage = "UPN of one or more Distribution Lists")]
      [ValidateScript({
        If ($_ -match '@') {
          If(Test-AzureADGroup $_) {
            $True
          }
          else {
            Write-Host "Distribution List $_ not found" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string[]]$DistributionLists,

      [Parameter(HelpMessage = "UPN of one or more Distribution Lists")]
      [ValidateScript({
        If ($_ -match '@') {
          If(Test-AzureADUser $_) {
            $True
          }
          else {
            Write-Host "User $_ not found!" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string[]]$Users,

      [Parameter(HelpMessage = "Will adhere to defaults as Microsoft outlines in New-CsCallQueue")]
      [switch]$UseMicrosoftDefaults

      #Other
      #not implemented as it is reserved for MS use: Tenant <Guid>


  )
  
  begin {
    # Caveat - Script in Testing
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"

    #region Required Parameters: Name and MusicOnHold
    # Normalising $Name
    $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
  
    # Processing Music On Hold
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Warning -Message "Parameters UseDefaultMusicOnHold and MusicOnHoldAudioFile are mutually exclusive. UseDefaultMusicOnHold is ignored!"
      $UseDefaultMusicOnHold = $false
    }
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
      Write-Verbose -Message "Parsing Music On Hold"
      $MOHcontent   = Get-Content $MusicOnHoldAudioFile -Encoding byte -ReadCount 0
      $MOHFileName  = Split-Path $MusicOnHoldAudioFile -Leaf
      $MOHFile      = New-CsOnlineAudioFile -FileName $MOHFileName -Content $MOHcontent
      Write-Verbose -Message "Music On Hold parsed: $MOHFileName used"
    }
    else {
      $UseDefaultMusicOnHold = $true
      Write-Verbose -Message "No Music On Hold specified: Using UseDefaultMusicOnHold"
    }
    #endregion

    #region Welcome Message
    if ($PSBoundParameters.ContainsKey('WelcomeMessageAudioFile')) {
        Write-Verbose -Message "Parsing Welcome Message"
        $WMcontent    = Get-Content $WelcomeMusicAudioFile -Encoding byte -ReadCount 0
        $WMFileName   = Split-Path $WelcomeMusicAudioFile -Leaf
        $WMFile       = New-CsOnlineAudioFile -FileName $WMFileName -Content $WMcontent
        Write-Verbose -Message "Welcome Message parsed: $WMFileName used"
      }
      else {
        Write-Verbose -Message "No Welcome Message File provided, omitting"
      }
    #endregion

    #region Default settings for Parameters (if not specified): AllowOptOut, ConferenceMode, OverflowThreshold, TimeoutTheshold
    Write-Verbose -Message "Parsing defaulting parameters"
    # Processing defaults based on $UseMicrosoftDefaults
    if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
      Write-Verbose -Message "Switch UseMicrosoftDefaults used - Setting default values according to New-CsCallQueue" -Verbose
      if (-not $PSBoundParameters.ContainsKey('AllowOptOut')) {
        $AllowOptOut = $true
        Write-Verbose -Message "Setting default value: AllowOptOut: $AllowOptOut"
      }
      if (-not $PSBoundParameters.ContainsKey('ConferenceMode')) {
        $ConferenceMode = $false
        Write-Verbose -Message "Setting default value: ConferenceMode: $ConferenceMode"
      }
      if (-not $PSBoundParameters.ContainsKey('AgentAlertTime')) {
        $TimeoutThreshold = 30
        Write-Verbose -Message "Setting default value: TimeoutThreshold: $AgentAlertTime"
      }
      if (-not $PSBoundParameters.ContainsKey('OverflowThreshold')) {
        $OverflowThreshold = 50
        Write-Verbose -Message "Setting default value: OverflowThreshold: $OverflowThreshold"
      }
      if (-not $PSBoundParameters.ContainsKey('TimeoutTheshold')) {
        $TimeoutThreshold = 1200
        Write-Verbose -Message "Setting default value: TimeoutThreshold: $TimeoutThreshold"
      }
    }
    else {
      Write-Verbose -Message "Switch UseMicrosoftDefaults NOT used - Setting default values according to New-TeamsCallQueue" -Verbose
      if (-not $PSBoundParameters.ContainsKey('AllowOptOut')) {
        $AllowOptOut = $false
        Write-Verbose -Message "Setting default value: AllowOptOut: $AllowOptOut"
      }
      if (-not $PSBoundParameters.ContainsKey('ConferenceMode')) {
        $ConferenceMode = $true
        Write-Verbose -Message "Setting default value: ConferenceMode: $ConferenceMode"
      }
      # AgentAlertTime    is set within PARAM block to 20s
      Write-Verbose -Message "Setting default value: TimeoutThreshold: $AgentAlertTime"
      # OverflowThreshold is set within PARAM block to 30s
      Write-Verbose -Message "Setting default value: OverflowThreshold: $OverflowThreshold"
      # TimeoutTheshold   is set within PARAM block to 30s
      Write-Verbose -Message "Setting default value: TimeoutThreshold: $TimeoutThreshold"
    }
    #endregion

    #region Overflow Action and Target
    # Overflow Action
    Write-Verbose -Message "Parsing requirements for OverflowAction: $OverflowAction"
    switch ($OverflowAction) {
      "DisconnectWithBusy" {
      # No Action
      }
      "VoiceMail" {
      # Currently no actions, but might be added later
      }
      "Forward" {
      if (-not $PSBoundParameters.ContainsKey('OverflowActionTarget')) {
          Write-Error -Message "Parameter OverFlowActionTarget Missing, Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowAction = "DisconnectWithBusy"
      }
      else {
          # Processing OverflowActionTarget
          try {
              $OverflowActionTargetId = (Get-AzureAdUser $OverflowActionTarget -ErrorAction STOP).ObjectId
          }                                   
          catch {
              Write-Warning -Message "$NameNormalised - Could not enumerate 'OverflowActionTarget'"
          }
      }
      }
    }
    #endregion

    #region Timeout Action and Target
    Write-Verbose -Message "Parsing requirements for TimeoutAction: $TimeoutAction"
    switch ($TimeoutAction) {
      "Disconnect" {
      # No Action
      }
      "VoiceMail" {
      # Currently no actions, but might be added later
      }
      "Forward" {
      if (-not $PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
          Write-Error -Message "Parameter TimeoutActionTarget Missing, Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowAction = "Disconnect"
      }
      else {
          # Processing TimeoutActionTarget
          try {
              $TimeoutActionTargetId = (Get-AzureAdUser -ObjectId $TimeoutActionTarget -ErrorAction STOP).ObjectId
          }                                   
          catch {
              Write-Warning -Message "$NameNormalised - Could not enumerate 'TimoutActionTarget'"
          }
      }
      }
    }
    #endregion

    #region Users - Parsing and verifying Users
    $UserIdList = @()
    if ($PSBoundParameters.ContainsKey('Users')) {
      Write-Verbose -Message "Parsing Users"
      foreach ($User in $Users) {
        # Determine ID from UPN
        if (Test-AzureAdUser $User) {
          $UserObject = Get-AzureADUserFromUPN $User
        
          # Test whether User is enabled for EV and/or licensed?

          # Add to List
          $UserIdList.Add($UserObject.ObjectId)
        }
        else {
          Write-Warning -Message "User $User not found in AzureAd, omitting user!"
        }
      }
    }
    #endregion

    #region Groups - Parsing Distribution Lists and their Users
    $DLIdList = @()
    if ($PSBoundParameters.ContainsKey('DistributionLists')) {
      Write-Verbose -Message "Parsing Distribution Lists"
      foreach ($DL in $DistributionLists) {
        # Determine ID from UPN
        Write-Debug -Message "Function Test-AzureAdGroup is experimental!"
        if (Test-AzureAdGroup $DL) {
          $DLObject = Get-AzureAdGroup -ObjectId $DL
          
          # Test whether Users in DL are enabled for EV and/or licensed?

          # Add to List
          $DLIdList.Add($DLObject.ObjectId)
        }
        else {
          Write-Warning -Message "Group $DL not found in AzureAd, omitting Group!"
        }
      }
    }

    #endregion

  }
  
  process {
    #region Create CQ (New-CsCallQueue)
    # Create the Call Queue with $Name as $NameNormalised and $UseDefaultMusicOnHold Switch
    try {
      switch ($UseDefaultMusicOnHold) {
        $true   {
          Write-Verbose -Message "Creating Call Queue with DEFAULT Music On Hold"
          $Null = (New-CsCallQueue -Name "$NameNormalised" -UseDefaultMusicOnHold $true -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Call Queue created with default Music on Hold"
        }
        $false  {
          Write-Verbose -Message "Creating Call Queue with CUSTOM Music On Hold"
          Write-Debug -Message "TEST: `$MOHfile.id should result in the GUID for -MusicOnHoldFileId!"
          $Null = (New-CsCallQueue -Name "$NameNormalised" -MusicOnHoldFileId $MOHfile.Id -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Call Queue created with custom Music on Hold: $MOHfileName."
        }
      }

    }
    catch {
      Write-Error -Message "Error creating the Call Queue" -Category WriteError -Exception "Erorr Creating Call Queue"
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
  
      # output Info. Post-process collected info, and log info (optional)
      $info
      return
    }
    #endregion

    # Re-Query CallQueue with Get-CsCallQueue - Used going forward
    $CallQueue = Get-CsCallQueue -NameFilter "$NameNormalised"

    #region Desired Configuration
    # Creating Custom Object with desired configuration for comparison
    $CallQueueDesired = [PSCustomObject][ordered]@{
      Identity                                           = $CallQueue.Identity                                  
      Name                                               = $CallQueue.Name                     
      UseDefaultMusicOnHold                              = $CallQueue.UseDefaultMusicOnHold                     
      MusicOnHoldAudioFileId                             = $CallQueue.MusicOnHoldAudioFileId                    
      WelcomeMusicAudioFileId                            = $WMFile.Id				
      RoutingMethod                                      = $RoutingMethod                             
      PresenceBasedRouting                               = $PresenceBasedRouting                      
      AgentAlertTime                                     = $AgentAlertTime                            
      AllowOptOut                                        = $AllowOptOut                               
      ConferenceMode                                     = $ConferenceMode
      OverflowAction                                     = $OverflowAction                            
      OverflowActionTarget                               = $OverflowActionTarget                      
      #OverflowSharedVoicemailAudioFilePrompt             = $OverflowSharedVoicemailAudioFilePrompt    
      #OverflowSharedVoicemailTextToSpeechPrompt          = $OverflowSharedVoicemailTextToSpeechPrompt 
      OverflowThreshold                                  = $OverflowThreshold
      TimeoutAction                                      = $TimeoutAction                             
      TimeoutActionTarget                                = $TimeoutActionTarget                       
      #TimeoutSharedVoicemailAudioFilePrompt              = $TimeoutSharedVoicemailAudioFilePrompt     
      #TimeoutSharedVoicemailTextToSpeechPrompt           = $TimeoutSharedVoicemailTextToSpeechPrompt  
      TimeoutThreshold                                   = $TimeoutThreshold
      #EnableOverflowSharedVoicemailTranscription         = $EnableOverflowSharedVoicemailTranscription
      #EnableTimeoutSharedVoicemailTranscription          = $EnableTimeoutSharedVoicemailTranscription 
      #LanguageId                                         = $LanguageId                                
      #LineUri                                            = $LineUri
      Agents                                              = $Users                                     
      DistributionLists                                  = $DistributionLists                         
    }
    #endregion   

    #region Settings (Set-CsCallQueue): Welcome Message
    # Welcome Message
    if ($PSBoundParameters.ContainsKey('WelcomeMessageAudioFile')) {
      try {
        Write-Verbose -Message "Processing Welcome Message $WMfilename"
        Write-Debug -Message "TEST: `$MOHfile.id should result in the GUID for -WelcomeMusicAudioFileId!"
        $null = (Set-CsCallQueue -Identity $CallQueue.Identity -WelcomeMusicAudioFileId $WMfile.Id -ErrorAction  Stop)
        Write-Verbose -Message "SUCCESS: $NameNormalised - Welcome messsage $WMFilename set"
      }
      catch {
        Write-Warning -Message "$NameNormalised - Could not apply Welcome Message"
      }


    }
    #endregion

    #region Settings (Set-CsCallQueue): Routing Parameters: RoutingMethod, PresenceBasedRouting, AgentAlertTime
    # Routing Method
    try {
      Write-Verbose -Message "Processing Routing Method"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -RoutingMethod $RoutingMethod -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Routing Method set to: $RoutingMethod"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set Routing Method"
    }

    # Presence Based Routing
    try {
      Write-Verbose -Message "Processing Presence Based Routing Switch"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -PresenceBasedRouting  $PresenceBasedRouting -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Presence Based Routing set to: $PresenceBasedRouting"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set Presence Based Routing Switch"
    }

    # Agent Alert Time
    try {
      Write-Verbose -Message "Processing Agent Alert Time"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -AgentAlertTime $AgentAlertTime -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Agent Alert Time set to: $AgentAlertTime"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set Agent Alert Time"
    }
    #endregion

    #region Settings (Set-CsCallQueue): Default Parameters: AllowOptOut, ConferenceMode
    # NOTE: Other Default Parameters OverflowThreshold and TimoutThreshold are processed in thier section
    # Allow Opt-out
    try {
      Write-Verbose -Message "Processing AllowOptOut Swich"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -AllowOptOut $AllowOptOut -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Allow Opt-out set to: $AllowOptOut"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set AllowOptOut Switch"
    }

    # Conference Mode
    try {
      Write-Verbose -Message "Processing Conference Mode Switch"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -ConferenceMode $ConferenceMode -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Conference Mode set to: $ConferenceMode"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set ConferenceMode Switch"
    }
    #endregion

    #region Settings (Set-CsCallQueue): Overflow (Queue Size Limit)
    # Overflow Threshold
    try {
      Write-Verbose -Message "Processing Overflow Threshold"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowThreshold $OverflowThreshold -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Threshold set to: $OverflowThreshold"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set Overflow Threshold"
    }

    # OverflowAction and OverflowActionTarget
    Write-Verbose -Message "Processing Overflow Action and Target"
    switch ($OverflowAction) {
      "DisconnectWithBusy" {
        try {
          # No Action
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Overflow Action"
        }
      }
      "VoiceMail" {
        try {
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Overflow Action"
        }
      }
      "Forward" {
        try {
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -OverflowActionTarget $OverflowActionTargetId -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
          Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Target set to: $OverflowActionTarget"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Overflow Action and Target"
          # get error record
          [Management.Automation.ErrorRecord]$e = $_
  
          # retrieve Info about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
          # output Info. Post-process collected info, and log info (optional)
          $info
          }
      }
    }
    #endregion

    #region Settings (Set-CsCallQueue): Timeout (No answer)
    # TimeoutThreshold
    try {
      Write-Verbose -Message "Processing Timeout Threshold"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutThreshold $TimeoutThreshold -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Threshold set to: $TimeoutThreshold"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not set Timeout Threshold"
    }

    # TimeoutAction and TimeoutActionTarget
    Write-Verbose -Message "Processing Timeout Action and Target"
    switch ($OverflowAction) {
      "DisconnectWithBusy" {
        try {
          # No Action
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Timeout Action"
        }
      }
      "VoiceMail" {
        try {
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Timeout Action"
        }
      }
      "Forward" {
        try {
          $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -TimeoutActionTarget $TimeoutActionTargetId -ErrorAction Stop)
          Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
          Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Target set to: $TimeoutActionTarget"
        }
        catch {
          Write-Warning -Message "$NameNormalised - Could not set Timeout Action and Target"
          # get error record
          [Management.Automation.ErrorRecord]$e = $_
  
          # retrieve Info about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
          # output Info. Post-process collected info, and log info (optional)
          $info
          }
      }
    }
    #endregion

    #region Settings (Set-CsCallQueue): Agents (Users and Groups)
    # Users
    try {
      Write-Verbose -Message "Processing Users"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -Users $UserIdList -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Users added: $Users"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not add Users"
    }

    # DistributionLists
    try {
      Write-Verbose -Message "Processing Distribution Lists"
      $null = (Set-CsCallQueue -Identity $CallQueue.Identity -DistributionLists $DLIdList -ErrorAction Stop)
      Write-Verbose -Message "SUCCESS: $NameNormalised - Groups added: $DistributionLists"
    }
    catch {
      Write-Warning -Message "$NameNormalised - Could not add Groups"
    }


    #endregion   
  }
  
  end {
    #region Output and Desired Configuration
    # Re-query output
    $CallQueueFinal = Get-CsCallQueue -NameFilter $NameNormalised
    if ($PSBoundParameters.ContainsKey('Silent')) {
      Return $CallQueueFinal
    }
    else {
      $CallQueueFinal = [PSCustomObject][ordered]@{
        Identity                                           = $CallQueueFinal.Identity                                  
        Name                                               = $CallQueueFinal.Name                                      
        UseDefaultMusicOnHold                              = $CallQueueFinal.UseDefaultMusicOnHold                     
        MusicOnHoldAudioFileId                             = $CallQueueFinal.MusicOnHoldAudioFileId                    
        WelcomeMusicAudioFileId                            = $CallQueueFinal.WelcomeMusicAudioFileId				
        RoutingMethod                                      = $CallQueueFinal.RoutingMethod                             
        PresenceBasedRouting                               = $CallQueueFinal.PresenceBasedRouting                      
        AgentAlertTime                                     = $CallQueueFinal.AgentAlertTime                            
        AllowOptOut                                        = $CallQueueFinal.AllowOptOut                               
        ConferenceMode                                     = $CallQueueFinal.ConferenceMode
        OverflowAction                                     = $CallQueueFinal.OverflowAction                            
        OverflowActionTarget                               = $CallQueueFinal.OverflowActionTarget                      
        #OverflowSharedVoicemailAudioFilePrompt             = $CallQueueFinal.OverflowSharedVoicemailAudioFilePrompt    
        #OverflowSharedVoicemailTextToSpeechPrompt          = $CallQueueFinal.OverflowSharedVoicemailTextToSpeechPrompt 
        OverflowThreshold                                  = $CallQueueFinal.OverflowThreshold
        TimeoutAction                                      = $CallQueueFinal.TimeoutAction                             
        TimeoutActionTarget                                = $CallQueueFinal.TimeoutActionTarget                       
        #TimeoutSharedVoicemailAudioFilePrompt              = $CallQueueFinal.TimeoutSharedVoicemailAudioFilePrompt     
        #TimeoutSharedVoicemailTextToSpeechPrompt           = $CallQueueFinal.TimeoutSharedVoicemailTextToSpeechPrompt  
        TimeoutThreshold                                   = $CallQueueFinal.TimeoutThreshold
        #EnableOverflowSharedVoicemailTranscription         = $CallQueueFinal.EnableOverflowSharedVoicemailTranscription
        #EnableTimeoutSharedVoicemailTranscription          = $CallQueueFinal.EnableTimeoutSharedVoicemailTranscription 
        #LanguageId                                         = $CallQueueFinal.LanguageId                                
        #LineUri                                            = $CallQueueFinal.LineUri
        Agents                                              = $CallQueueFinal.Users                                     
        DistributionLists                                  = $CallQueueFinal.DistributionLists                         
      }

      $Difference = Compare-Object -ReferenceObject $CallQueueDesired -DifferenceObject $CallQueueFinal
      if ($difference.Count -gt 0) {
        Write-Host "SUCCESS: Call Queue created and SOME values set" -Foregroundcolor Yellow
        Write-Host "The following Settings have not been able to be applied"
        return $Difference
      }
      else {
        Write-Host "SUCCESS: Call Queue created and all values set" -Foregroundcolor Green
        Return $CallQueueFinal

        Write-Verbose -Message "Done"
      }
    }
    #endregion
  }
}

function Get-TeamsCallQueue {
  <#
  .SYNOPSIS
      Queries Call Queues and displays friendly Names (UPN or Displayname)
  .DESCRIPTION
      Same functionality as Get-CsCallQueue, but display reveals friendly Names,
      like UserPrincipalName or DisplayName for the following connected Objects
      OverflowActionTarget, TimeoutActionTarget, Agents, DistributionLists and ApplicationInstances (Resource Accounts)
  .PARAMETER Name
      Optional. Searches all Call Queues for this names (multiple results possible.)
      If omitted, Get-TeamsCallQueue acts like an Alias to Get-CsCallQueue (no friendly names)
  .EXAMPLE
      Get-TeamsCallQueue
      Same result as Get-CsCallQueue
  .EXAMPLE
      Get-TeamsCallQueue -Name "My CallQueue"
      Returns an Object for every Call Queue found with the String "My CallQueue"
      Agents, DistributionLists, Targets and Resource Accounts are displayed with friendly name. 
  .NOTES
      This is as-is as it was built for a specific purpose to look up and query current status of a CQ
      Some Parameters are not shown as they are also omitted from NEW and SET commands (not live yet)
  .FUNCTIONALITY
      Get-CsCallQueue with friendly names instead of GUID-strings for connected objects
  .LINK
    New-TeamsCallQueue
    Set-TeamsCallQueue
    Remove-TeamsCallQueue
  #>
  param(
    [Parameter(HelpMessage = 'Partial or full Name of the Call Queue to search')]
    [AllowNull()]
    [string]$Name
  )

  # Caveat - Script in Testing
  $VerbosePreference = "Continue"
  $DebugPreference = "Continue"
  Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"
  
  try {
    if (-not $PSBoundParameters.ContainsKey('Name')) {
      Write-Verbose -Message "No parameters specified. Acting as Alias to Get-CsCallQueue"
      Get-CsCallQueue -ErrorAction STOP
    }
    else {
      # Finding all Queues with this Name (Should return one Object, but since it IS a filter, handling it as an array)
      $Queues = Get-CsCallQueue -NameFilter "$Name" -ErrorAction STOP

      Write-Verbose -Message "Only a subset of Parameters are displayed, to display all, please run Get-CsCallQueue -Identity $Queues.Identity" -Verbose

      # Initialising Arrays
      $DEQueueObjects = @()

      $DLobjects    = [System.Collections.ArrayList]::new()
      $AgentObjects = [System.Collections.ArrayList]::new()
      $AIObjects    = [System.Collections.ArrayList]::new()
            
      # Reworking Objects  
      foreach ($Q in $Queues) {
          
        # Finding OverflowActionTarget
        if ($null -eq $Q.OverflowActionTarget) {
          Write-Verbose -Message "$Q.Name does not have an OverflowActionTarget"
        }
        else {   
          try {
            $OATobject = Get-AzureAdUser -ObjectId $Q.OverflowActionTarget.Id -ErrorAction STOP
          }                                   
          catch {
            Write-Warning -Message "$Q.Name - Could not enumerate 'OverflowActionTarget'"
          }
        }
        # Output: $OATobject.Userprincipalname
            
        # Finding TimeoutActionTarget
        if ($null -eq $Q.TimeoutActionTarget) {
          Write-Verbose -Message "$Q.Name does not have a TimeoutActionTarget"
        }
        else {                               
          try {
            $TATobject = Get-AzureAdUser -ObjectId $Q.TimeoutActionTarget.Id -ErrorAction STOP
          }                                   
          catch {
            Write-Warning -Message "$Q.Name - Could not enumerate 'TimoutActionTarget'"
          }
        }
        # Output: $TATobject.Userprincipalname
            
        foreach ($DL in $Q.DistributionLists) {
          $DLobject = Get-AzureAdGroup -ObjectId $DL | Select-Object DisplayName,Description,SecurityEnabled,MailEnabled,MailNickName,Mail
          [void]$DLobjects.Add($DLobject)
        }
        # Output: $DLobjects.DisplayName

        foreach ($Agent in $Q.Agents) {
          $AgentObject = Get-AzureAdUser -ObjectId $Agent.ObjectId | Select-Object UserPrincipalName,DisplayName,JobTitle,CompanyName,Country,UsageLocation,PreferredLanguage
          [void]$AgentObjects.Add($AgentObject)
        }
        # Output: $AgentObjects.UserPrincipalName

        # Finding Application Instance UPNs                                    
        foreach ($AI in $Q.ApplicationInstances) {
          $AIobject = Get-CsOnlineApplicationInstance | Where-Object {$_.ObjectId -eq $AI} | Select-Object UserPrincipalName,DisplayName,PhoneNumber
          [void]$AIObjects.Add($AIobject)
        }
        # Output: $AIObjects.Userprincipalname          

            
        # Building custom Object with Friendly Names  
        $Q = [PSCustomObject][ordered]@{
          Identity                                           = $Q.Identity                                  
          Name                                               = $Q.Name                                      
          UseDefaultMusicOnHold                              = $Q.UseDefaultMusicOnHold                     
          MusicOnHoldAudioFileId                             = $Q.MusicOnHoldAudioFileId                    
          WelcomeMusicAudioFileId                            = $Q.WelcomeMusicAudioFileId				
          RoutingMethod                                      = $Q.RoutingMethod                             
          PresenceBasedRouting                               = $Q.PresenceBasedRouting                      
          AgentAlertTime                                     = $Q.AgentAlertTime                            
          AllowOptOut                                        = $Q.AllowOptOut                               
          ConferenceMode                                     = $Q.ConferenceMode
          OverflowAction                                     = $Q.OverflowAction                            
          OverflowActionTarget                               = $OATobject.Userprincipalname                      
          #OverflowSharedVoicemailAudioFilePrompt             = $Q.OverflowSharedVoicemailAudioFilePrompt    
          #OverflowSharedVoicemailTextToSpeechPrompt          = $Q.OverflowSharedVoicemailTextToSpeechPrompt 
          OverflowThreshold                                  = $Q.OverflowThreshold
          TimeoutAction                                      = $Q.TimeoutAction                             
          TimeoutActionTarget                                = $TATobject.Userprincipalname                       
          #TimeoutSharedVoicemailAudioFilePrompt              = $Q.TimeoutSharedVoicemailAudioFilePrompt     
          #TimeoutSharedVoicemailTextToSpeechPrompt           = $Q.TimeoutSharedVoicemailTextToSpeechPrompt  
          TimeoutThreshold                                   = $Q.TimeoutThreshold
          #EnableOverflowSharedVoicemailTranscription         = $Q.EnableOverflowSharedVoicemailTranscription
          #EnableTimeoutSharedVoicemailTranscription          = $Q.EnableTimeoutSharedVoicemailTranscription 
          #LanguageId                                         = $Q.LanguageId                                
          #LineUri                                            = $Q.LineUri
          Agents                                              = $AgentObjects.UserPrincipalName
          DistributionLists                                  = $DLobjects.DisplayName
          ApplicationInstances                               = $AIObjects.Userprincipalname                              
        }
            
        [void]$DEQueueObjects.Add($Q)
      }
          
      # Output
      return $DEQueueObjects
    }
  }
  catch {
    Write-Error -Message 'Parsing error' -Category ParserError
    # get error record
    [Management.Automation.ErrorRecord]$e = $_

    # retrieve Info about runtime error
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
    }
    $info
    return
  }
}

function Set-TeamsCallQueue {
  <#
  .SYNOPSIS
      Set-CsCallQueue with UPNs instead of GUIDs
  .DESCRIPTION
      Does all the same things that Set-CsCallQueue does, but differs in a few significant respects:
      UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
      Set-CsCallQueue   is used to apply parameters dependent on specification.
      Partial implementation is possible, output will show differences.
  .PARAMETER Identity
      Required. UserPrincipalName (UPN) of the Call Queue. Used to Identify the Object
  .PARAMETER Name
      Optional. Updates the Name of the Call Queue. Name will be normalised (unsuitable characters are filtered)
  .PARAMETER Silent
      Optional. Supresses output. Use for Bulk provisioning only.
      Will return the Output object, but not display any output on Screen.
  .PARAMETER AgentAlertTime
      Optional. Time in Seconds to alert each agent. Works depending on Routing method
      NOTE: Size AgentAlertTime and TimeoutThreshold depending on Routing method and # of Agents available.
  .PARAMETER AllowOptOut
      Optional Switch. Allows Agents to Opt out of receiving calls from the Call Queue
  .PARAMETER UseDefaultMusicOnHold
      Optional Switch. Indicates whether the default Music On Hold should be used.
  .PARAMETER WelcomeMusicAudioFile
      Optional. Path to Audio File to be used as a Welcome message
      Accepted Formats: MP3, WAV or WMA format, max 5MB
      .PARAMETER MusicOnHoldAudioFile
      Optional. Path to Audio File to be used as Music On Hold.
      Required if UseDefaultMusicOnHold is not specified/set to TRUE
      Accepted Formats: MP3, WAV or WMA format, max 5MB
  .PARAMETER OverflowAction
      Optional. Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail
      Action to be taken if the Queue size limit (OverflowThreshold) is reached
      Forward requires specification of OverflowActionTarget
  .PARAMETER OverflowActionTarget
      Situational. Required only if OverflowAction is Forward
      UserPrincipalName of the Target
  .PARAMETER OverflowThreshold
      Optional. Time in Seconds for the OverflowAction to trigger
  .PARAMETER TimeoutAction
      Optional. Default: Disconnect, Values: Disconnect, Forward, VoiceMail
      Action to be taken if the TimeoutThreshold is reached
      Forward requires specification of TimeoutActionTarget
  .PARAMETER TimeoutActionTarget
      Situational. Required only if TimeoutAction is Forward
      UserPrincipalName of the Target
  .PARAMETER TimeoutThreshold
      Optional. Time in Seconds for the TimeoutAction to trigger        
  .PARAMETER RoutingMethod
      Optional. Default: Attendant, Values: Attendant, Serial, RoundRobin, LongestIdle
      Describes how the Call Queue is hunting for an Agent.
      Serial will Alert them one by one in order specified (Distribution lists will contact alphabethically)
      Attendant behaves like Parallel if PresenceBasedRouting is used.
  .PARAMETER PresenceBasedRouting
      Optional. Default: FALSE. If used alerts Agents only when they are available (Teams status). 
  .PARAMETER ConferenceMode
      Optional. Default: TRUE,   Microsoft Default: FALSE
      Will establish a conference instead of a direct call and should help with connection time.
      Documentation vague.
  .PARAMETER DistributionLists
      Optional. UPNs of DistributionLists or Groups to be used as Agents.
      Will be parsed after Users if they are specified as well.
  .PARAMETER Users
      Optional. UPNs of Users.
      Will be parsed first. Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -DisplayName "My new Queue Name"
      Changes the DisplayName of Call Queue "My Queue" to "My new Queue Name"
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefautls
      Changes the Call Queue "My Queue" to use Microsft Default Values
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
      Changes the Call Queue "My Queue" to overflow with more than 5 Callers waiting and a timeout window of 90s
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
      Changes the Call Queue "My Queue" with custom Audio Files
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
      Changes the Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.
  .EXAMPLE
      Set-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
      Changes the Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.
  .NOTES
      Currently in Testing
  .FUNCTIONALITY
      Changes a Call Queue with friendly names as input
  .LINK
    Set-TeamsCallQueue
    Get-TeamsCallQueue
    Remove-TeamsCallQueue
  #>

  [CmdletBinding()]
  param(
      [Parameter(Mandatory=$true, HelpMessage = "UserPrincipalName of the Call Queue")]
      [string]$Name,

      [Parameter(HelpMessage = "Changes the Name to this DisplayName")]
      [string]$DisplayName,

      [Parameter(HelpMessage = "No output is written to the screen, but Object returned for processing")]
      [switch]$Silent,

      [Parameter(HelpMessage = "Time an agent is alerted in seconds (15-180s)")]
      [ValidateScript({
          If ($_ -ge 15 -and $_ -le 180) {
            $True
          }
          else {
            Write-Host "Must be a value between 30 and 180s (3 minutes)" -ForeGroundColor Red
          }
        })]
      [int16]$AgentAlertTime,
      
      [Parameter(HelpMessage = "Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)")]
      [switch]$AllowOptOut,

      [Parameter(HelpMessage = "Action to be taken for Overflow")]
      [Validateset("Voicemail","Forward","DisconnectWithBusy")]
      [string]$OverflowAction = "DisconnectWithBusy",

      #usually accepts GUID, needs to be captured, queried and translated into a guid (Get-AzureADUser?)
      #Only valid for $OverflowAction = "Forward"
      [Parameter(HelpMessage = "UPN that is targeted upon overflow, only valid for forwarded calls")]
      [ValidateScript({
          If ($_ -match '@') {
            $True
          }
          else {
            Write-Host "Must be a valid UPN" -ForeGroundColor Red
          }
        })]
      [string]$OverflowActionTarget,

      [Parameter(HelpMessage = "Time in seconds (0-200s) before timeout action is triggered (Default: 30, Note: Microsoft default: 50)")]
      [ValidateScript({
          If ($_ -ge 0 -and $_ -le 200) {
            $True
          }
          else {
            Write-Host "Must be a value between 0 and 200s." -ForeGroundColor Red
          }
        })]
      [int16]$OverflowThreshold,

      [Parameter(HelpMessage = "Action to be taken for Timeout")]
      [Validateset("Voicemail","Forward","Disconnect")]
      [string]$TimeoutAction = "Disconnect",

      #usually accepts GUID, needs to be captured, queried and translated into a guid (Get-AzureADUser?)
      #Only valid for $TimeoutAction = "Forward"
      [Parameter(HelpMessage = "UPN that is targeted upon timeout, only valid for forwarded calls")]
      [ValidateScript({
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string]$TimeoutActionTarget,

      [Parameter(HelpMessage = "Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)")]
      [ValidateScript({
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          Write-Host "Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)" -ForeGroundColor Red
        }
      })]
      [int16]$TimeoutThreshold,
      
      [Parameter(HelpMessage = "Method to alert Agents")]
      [Validateset("Attendant","Serial","RoundRobin","LongestIdle")]
      [string]$RoutingMethod = "Attendant",

      [Parameter(HelpMessage = "If used, Agents receive calls only when their presence state is Available")]
      [switch]$PresenceBasedRouting,

      [Parameter(HelpMessage = "Indicates whether the default Music On Hold is used")]
      [switch]$UseDefaultMusicOnHold,

      [Parameter(HelpMessage = "If used, Conference mode is used to establish calls")]
      [switch]$ConferenceMode,

      [Parameter(HelpMessage = "Path to Audio File for WelcomeMuic")]
      [ValidateScript({
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
        }
      })]
      [string]$WelcomeMusicAudioFile,
      
      [Parameter(HelpMessage = "Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)")]
      [ValidateScript({
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
        }
      })]
      [string]$MusicOnHoldAudioFile,

      #Agents
      [Parameter(HelpMessage = "UPN of one or more Distribution Lists")]
      [ValidateScript({
        If ($_ -match '@') {
          If(Test-AzureADGroup $_) {
            $True
          }
          else {
            Write-Host "Distribution List $_ not found" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string[]]$DistributionLists,

      [Parameter(HelpMessage = "UPN of one or more Distribution Lists")]
      [ValidateScript({
        If ($_ -match '@') {
          If(Test-AzureADUser $_) {
            $True
          }
          else {
            Write-Host "User $_ not found!" -ForeGroundColor Red
          }
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
        }
      })]
      [string[]]$Users

      #Other
      #not implemented as it is reserved for MS use: Tenant <Guid>


  )
  
  begin {
    # Caveat - Script in Testing
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"

    #region DisplayName
      # Normalising $DisplayName
      if ($PSBoundParameters.ContainsKey('Displayname')) {
      $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
      }
      else {
          $NameNormalised = $Name
      }
      #endregion

      #region Music On Hold
      if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
          Write-Warning -Message "Parameters UseDefaultMusicOnHold and MusicOnHoldAudioFile are mutually exclusive. UseDefaultMusicOnHold is ignored!"
          $UseDefaultMusicOnHold = $false
      }
      if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
          Write-Verbose -Message "Parsing Music On Hold"
          $MOHcontent   = Get-Content $MusicOnHoldAudioFile -Encoding byte -ReadCount 0
          $MOHFileName  = Split-Path $MusicOnHoldAudioFile -Leaf
          $MOHFile      = New-CsOnlineAudioFile -FileName $MOHFileName -Content $MOHcontent
          Write-Verbose -Message "Music On Hold parsed: $MOHFileName used"
      }
      else {
          $UseDefaultMusicOnHold = $true
          Write-Verbose -Message "No Music On Hold specified: Using UseDefaultMusicOnHold"
      }
      #endregion

      #region Welcome Message
      if ($PSBoundParameters.ContainsKey('WelcomeMessageAudioFile')) {
          Write-Verbose -Message "Parsing Welcome Message"
          $WMcontent    = Get-Content $WelcomeMusicAudioFile -Encoding byte -ReadCount 0
          $WMFileName   = Split-Path $WelcomeMusicAudioFile -Leaf
          $WMFile       = New-CsOnlineAudioFile -FileName $WMFileName -Content $WMcontent
          Write-Verbose -Message "Welcome Message parsed: $WMFileName used"
      }
      else {
          Write-Verbose -Message "No Welcome Message File provided, omitting"
      }
      #endregion

      #region Overflow Action and Target
      # Overflow Action
      Write-Verbose -Message "Parsing requirements for OverflowAction: $OverflowAction"
      switch ($OverflowAction) {
          "DisconnectWithBusy" {
          # No Action
          }
          "VoiceMail" {
          # Currently no actions, but might be added later
          }
          "Forward" {
          if (-not $PSBoundParameters.ContainsKey('OverflowActionTarget')) {
              Write-Error -Message "Parameter OverFlowActionTarget Missing, Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
              $OverflowAction = "DisconnectWithBusy"
          }
          else {
              # Processing OverflowActionTarget
              try {
                  $OverflowActionTargetId = (Get-AzureAdUser $OverflowActionTarget -ErrorAction STOP).ObjectId
              }                                   
              catch {
                  Write-Warning -Message "$NameNormalised - Could not enumerate 'OverflowActionTarget'"
              }
          }
      }
      }
      #endregion

      #region Timeout Action and Target
      Write-Verbose -Message "Parsing requirements for TimeoutAction: $TimeoutAction"
      switch ($TimeoutAction) {
          "Disconnect" {
          # No Action
          }
          "VoiceMail" {
          # Currently no actions, but might be added later
          }
          "Forward" {
          if (-not $PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
              Write-Error -Message "Parameter TimeoutActionTarget Missing, Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
              $OverflowAction = "Disconnect"
          }
          else {
              # Processing TimeoutActionTarget
              try {
                  $TimeoutActionTargetId = (Get-AzureAdUser -ObjectId $TimeoutActionTarget -ErrorAction STOP).ObjectId
              }                                   
              catch {
                  Write-Warning -Message "$NameNormalised - Could not enumerate 'TimoutActionTarget'"
              }
          }
          }
      }
      #endregion

      #region Users - Parsing and verifying Users
      $UserIdList = @()
      if ($PSBoundParameters.ContainsKey('Users')) {
          Write-Verbose -Message "Parsing Users"
          foreach ($User in $Users) {
            # Determine ID from UPN
            if (Test-AzureAdUser $User) {
              $UserObject = Get-AzureADUserFromUPN $User
            
              # Test whether User is enabled for EV and/or licensed?

              # Add to List
              $UserIdList.Add($UserObject.ObjectId)
            }
          else {
              Write-Warning -Message "User $User not found in AzureAd, omitting user!"
          }
          }
      }
      #endregion

      #region Groups - Parsing Distribution Lists and their Users
      $DLIdList = @()
      if ($PSBoundParameters.ContainsKey('DistributionLists')) {
          Write-Verbose -Message "Parsing Distribution Lists"
          foreach ($DL in $DistributionLists) {
          # Determine ID from UPN
          Write-Debug -Message "Function Test-AzureAdGroup is experimental!"
          if (Test-AzureAdGroup $DL) {
              $DLObject = Get-AzureAdGroup -ObjectId $DL
              
              # Test whether Users in DL are enabled for EV and/or licensed?

              # Add to List
              $DLIdList.Add($DLObject.ObjectId)
          }
          else {
              Write-Warning -Message "Group $DL not found in AzureAd, omitting Group!"
          }
          }
      }
      #endregion

  }
  
  process {
      # Querying the Call Queue by Name
      $CallQueue = Get-CsCallQueue -NameFilter "$Name"

      #region Settings (Set-CsCallQueue): DisplayName
      if ($PSBoundParameters.ContainsKey('Displayname')) {
          try {
              Write-Verbose -Message "Changing DisplayName"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -Name $NameNormalised -ErrorAction STOP)
              Write-Verbose -Message "SUCCESS: $Name - Call Queue DisplayName changed to: $NameNormalised"
          }
          catch {
              Write-Error -Message "Error changing DisplayName, using $Name instead" -Category WriteError -Exception "Erorr changing DisplayNae"
              $NameNormalised = $Name # Required for re-query
          }
      }
      #endregion

      # Re-Query CallQueue with Get-CsCallQueue - Used going forward
      $CallQueue = Get-CsCallQueue -NameFilter "$NameNormalised"

      #region Desired Configuration
      # Creating Custom Object with desired configuration for comparison
      $CallQueueDesired = [PSCustomObject][ordered]@{
          Identity                                           = $CallQueue.Identity                                  
          Name                                               = $CallQueue.Name                     
          UseDefaultMusicOnHold                              = $UseDefaultMusicOnHold                     
          MusicOnHoldAudioFileId                             = $MOHFile.Id                    
          WelcomeMusicAudioFileId                            = $WMFile.Id				
          RoutingMethod                                      = $RoutingMethod                             
          PresenceBasedRouting                               = $PresenceBasedRouting                      
          AgentAlertTime                                     = $AgentAlertTime                            
          AllowOptOut                                        = $AllowOptOut                               
          ConferenceMode                                     = $ConferenceMode
          OverflowAction                                     = $OverflowAction                            
          OverflowActionTarget                               = $OverflowActionTarget                      
          #OverflowSharedVoicemailAudioFilePrompt             = $OverflowSharedVoicemailAudioFilePrompt    
          #OverflowSharedVoicemailTextToSpeechPrompt          = $OverflowSharedVoicemailTextToSpeechPrompt 
          OverflowThreshold                                  = $OverflowThreshold
          TimeoutAction                                      = $TimeoutAction                             
          TimeoutActionTarget                                = $TimeoutActionTarget                       
          #TimeoutSharedVoicemailAudioFilePrompt              = $TimeoutSharedVoicemailAudioFilePrompt     
          #TimeoutSharedVoicemailTextToSpeechPrompt           = $TimeoutSharedVoicemailTextToSpeechPrompt  
          TimeoutThreshold                                   = $TimeoutThreshold
          #EnableOverflowSharedVoicemailTranscription         = $EnableOverflowSharedVoicemailTranscription
          #EnableTimeoutSharedVoicemailTranscription          = $EnableTimeoutSharedVoicemailTranscription 
          #LanguageId                                         = $LanguageId                                
          #LineUri                                            = $LineUri
          Agents                                              = $Users                                     
          DistributionLists                                  = $DistributionLists                         
      }
      #endregion   
      
      #region Settings (Set-CsCallQueue): Music On Hold
      # No check for Key as it is interdependent with $UseDefaultMusicOnHold
      try {
          switch ($UseDefaultMusicOnHold) {
          $true   {
              Write-Verbose -Message "Processing change to DEFAULT Music On Hold"
              $Null = (Set-CsCallQueue -Identity $CallQueue.Identity -UseDefaultMusicOnHold $true -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Music On Hold changed to: DEFAULT"
          }
          $false  {
              Write-Verbose -Message "Processing change to CUSTOM Music On Hold"
              Write-Debug -Message "TEST: `$MOHfile.id should result in the GUID for -MusicOnHoldFileId!"
              $Null = (Set-CsCallQueue -Identity $CallQueue.Identity -MusicOnHoldFileId $MOHfile.Id -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Music On Hold changed to: $MOHfileName."
          }
          }
      }
      catch {
          Write-Error -Message "Error changing Music On Hold" -Category WriteError -Exception "Erorr changing Music On Hold"
      }
      #endregion

      #region Settings (Set-CsCallQueue): Welcome Message
      if ($PSBoundParameters.ContainsKey('WelcomeMessageAudioFile')) {
          try {
              Write-Verbose -Message "Processing Welcome Message $WMfilename"
              Write-Debug -Message "TEST: `$MOHfile.id should result in the GUID for -WelcomeMusicAudioFileId!"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -WelcomeMusicAudioFileId $WMfile.Id -ErrorAction  Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Welcome messsage $WMFilename set"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not apply Welcome Message"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): RoutingMethod
      if ($PSBoundParameters.ContainsKey('RoutingMethod')) {
          try {
              Write-Verbose -Message "Processing Routing Method"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -RoutingMethod $RoutingMethod -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Routing Method set to: $RoutingMethod"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set Routing Method"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): PresenceBasedRouting
      if ($PSBoundParameters.ContainsKey('PresenceBasedRouting')) {
          try {
              Write-Verbose -Message "Processing Presence Based Routing Switch"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -PresenceBasedRouting  $PresenceBasedRouting -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Presence Based Routing set to: $PresenceBasedRouting"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set Presence Based Routing Switch"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): AgentAlertTime
      if ($PSBoundParameters.ContainsKey('AgentAlertTime')) {
          try {
              Write-Verbose -Message "Processing Agent Alert Time"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -AgentAlertTime $AgentAlertTime -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Agent Alert Time set to: $AgentAlertTime"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set Agent Alert Time"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): AllowOptOut
      if ($PSBoundParameters.ContainsKey('AllowOptOut')) {
          try {
              Write-Verbose -Message "Processing AllowOptOut Swich"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -AllowOptOut $AllowOptOut -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Allow Opt-out set to: $AllowOptOut"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set AllowOptOut Switch"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): ConferenceMode
      if ($PSBoundParameters.ContainsKey('ConferenceMode')) {
          try {
              Write-Verbose -Message "Processing Conference Mode Switch"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -ConferenceMode $ConferenceMode -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Conference Mode set to: $ConferenceMode"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set ConferenceMode Switch"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): OverflowThreshold
      if ($PSBoundParameters.ContainsKey('OverflowThreshold')) {
          try {
              Write-Verbose -Message "Processing Overflow Threshold"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowThreshold $OverflowThreshold -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Threshold set to: $OverflowThreshold"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set Overflow Threshold"
          }
      }
      #endregion
      
      #region Settings (Set-CsCallQueue): OverflowAction and OverflowActionTarget
      if ($PSBoundParameters.ContainsKey('OverflowAction')) {
          Write-Verbose -Message "Processing Overflow Action and Target"
          switch ($OverflowAction) {
              "DisconnectWithBusy" {
              try {
                  # No Action
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Overflow Action"
              }
              }
              "VoiceMail" {
              try {
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Overflow Action"
              }
              }
              "Forward" {
              try {
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -OverflowAction $OverflowAction -OverflowActionTarget $OverflowActionTargetId -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Action set to: $OverflowAction"
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Overflow Target set to: $OverflowActionTarget"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Overflow Action and Target"
                  # get error record
                  [Management.Automation.ErrorRecord]$e = $_
          
                  # retrieve Info about runtime error
                  $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
                  }
                  # output Info. Post-process collected info, and log info (optional)
                  $info
                  }
              }
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): TimeoutThreshold
      if ($PSBoundParameters.ContainsKey('TimeoutThreshold')) {
          try {
              Write-Verbose -Message "Processing Timeout Threshold"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutThreshold $TimeoutThreshold -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Threshold set to: $TimeoutThreshold"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not set Timeout Threshold"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): TimeoutAction and TimeoutActionTarget
      if ($PSBoundParameters.ContainsKey('TimeoutAction')) {
          Write-Verbose -Message "Processing Timeout Action and Target"
          switch ($OverflowAction) {
              "DisconnectWithBusy" {
              try {
                  # No Action
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Timeout Action"
              }
              }
              "VoiceMail" {
              try {
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Timeout Action"
              }
              }
              "Forward" {
              try {
                  $null = (Set-CsCallQueue -Identity $CallQueue.Identity -TimeoutAction $TimeoutAction -TimeoutActionTarget $TimeoutActionTargetId -ErrorAction Stop)
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Action set to: $TimeoutAction"
                  Write-Verbose -Message "SUCCESS: $NameNormalised - Timeout Target set to: $TimeoutActionTarget"
              }
              catch {
                  Write-Warning -Message "$NameNormalised - Could not set Timeout Action and Target"
                  # get error record
                  [Management.Automation.ErrorRecord]$e = $_
          
                  # retrieve Info about runtime error
                  $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
                  }
                  # output Info. Post-process collected info, and log info (optional)
                  $info
                  }
              }
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue): Users
      if ($PSBoundParameters.ContainsKey('Users')) {
          try {
              Write-Verbose -Message "Processing Users"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -Users $UserIdList -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Users added: $Users"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not add Users"
          }
      }
      #endregion

      #region Settings (Set-CsCallQueue):  DistributionLists
      if ($PSBoundParameters.ContainsKey('DistributionLists')) {
          try {
              Write-Verbose -Message "Processing Distribution Lists"
              $null = (Set-CsCallQueue -Identity $CallQueue.Identity -DistributionLists $DLIdList -ErrorAction Stop)
              Write-Verbose -Message "SUCCESS: $NameNormalised - Groups added: $DistributionLists"
          }
          catch {
              Write-Warning -Message "$NameNormalised - Could not add Groups"
          }
      }
      #endregion   
  }
  
  end {
      #region Output and Desired Configuration
      # Re-query output
      $CallQueueFinal = Get-CsCallQueue -NameFilter $NameNormalised
      if ($PSBoundParameters.ContainsKey('Silent')) {
          Return $CallQueueFinal
      }
      else {
          $CallQueueFinal = [PSCustomObject][ordered]@{
            Identity                                           = $CallQueueFinal.Identity                                  
            Name                                               = $CallQueueFinal.Name                                      
            UseDefaultMusicOnHold                              = $CallQueueFinal.UseDefaultMusicOnHold                     
            MusicOnHoldAudioFileId                             = $CallQueueFinal.MusicOnHoldAudioFileId                    
            WelcomeMusicAudioFileId                            = $CallQueueFinal.WelcomeMusicAudioFileId				
            RoutingMethod                                      = $CallQueueFinal.RoutingMethod                             
            PresenceBasedRouting                               = $CallQueueFinal.PresenceBasedRouting                      
            AgentAlertTime                                     = $CallQueueFinal.AgentAlertTime                            
            AllowOptOut                                        = $CallQueueFinal.AllowOptOut                               
            ConferenceMode                                     = $CallQueueFinal.ConferenceMode
            OverflowAction                                     = $CallQueueFinal.OverflowAction                            
            OverflowActionTarget                               = $CallQueueFinal.OverflowActionTarget                      
            #OverflowSharedVoicemailAudioFilePrompt             = $CallQueueFinal.OverflowSharedVoicemailAudioFilePrompt    
            #OverflowSharedVoicemailTextToSpeechPrompt          = $CallQueueFinal.OverflowSharedVoicemailTextToSpeechPrompt 
            OverflowThreshold                                  = $CallQueueFinal.OverflowThreshold
            TimeoutAction                                      = $CallQueueFinal.TimeoutAction                             
            TimeoutActionTarget                                = $CallQueueFinal.TimeoutActionTarget                       
            #TimeoutSharedVoicemailAudioFilePrompt              = $CallQueueFinal.TimeoutSharedVoicemailAudioFilePrompt     
            #TimeoutSharedVoicemailTextToSpeechPrompt           = $CallQueueFinal.TimeoutSharedVoicemailTextToSpeechPrompt  
            TimeoutThreshold                                   = $CallQueueFinal.TimeoutThreshold
            #EnableOverflowSharedVoicemailTranscription         = $CallQueueFinal.EnableOverflowSharedVoicemailTranscription
            #EnableTimeoutSharedVoicemailTranscription          = $CallQueueFinal.EnableTimeoutSharedVoicemailTranscription 
            #LanguageId                                         = $CallQueueFinal.LanguageId                                
            #LineUri                                            = $CallQueueFinal.LineUri
            Agents                                              = $CallQueueFinal.Users                                     
            DistributionLists                                  = $CallQueueFinal.DistributionLists                         
          }

          $Difference = Compare-Object -ReferenceObject $CallQueueDesired -DifferenceObject $CallQueueFinal
          if ($difference.Count -gt 0) {
          Write-Host "SUCCESS: Call Queue created and SOME values set" -Foregroundcolor Yellow
          Write-Host "The following Settings have not been able to be applied"
          return $Difference
          }
          else {
          Write-Host "SUCCESS: Call Queue created and all values set" -Foregroundcolor Green
          Return $CallQueueFinal

          Write-Verbose -Message "Done"
          }
      }
      #endregion
  }
}

function Remove-TeamsCallQueue {
  <#
  .SYNOPSIS
      Removes a Call Queue
  .DESCRIPTION
      Remove-CsCallQueue for friendly Names
  .PARAMETER Name
      DisplayName of the Call Queue 
  .EXAMPLE
      Remove-TeamsCallQueue -Name "My Queue"
      Prompts for removal for all queues found with the string "My Queue"
  .LINK
    New-TeamsCallQueue
    Get-TeamsCallQueue
    Set-TeamsCallQueue

  #>
  param(
      [Parameter(Mandatory = $true, HelpMessage = "Name of the Call Queue")]
      [string]$Name
  )

  # Caveat - Script in Testing
  $VerbosePreference = "Continue"
  $DebugPreference = "Continue"
  Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"

  try {
      Get-CsCallQueue -NameFilter "$Name" | Remove-TeamsCallQueue -Confirm:$true -ErrorAction STOP
  }
  catch {
      Write-Error -Message "Parsing error" -Category ParserError
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
          Exception = $e.Exception.Message
          Reason    = $e.CategoryInfo.Reason
          Target    = $e.CategoryInfo.TargetName
          Script    = $e.InvocationInfo.ScriptName
          Line      = $e.InvocationInfo.ScriptLineNumber
          Column    = $e.InvocationInfo.OffsetInLine
      }
      $info
      return
  }
}
#endregion

#region Resource Accounts - Work in Progress - 
function New-TeamsResourceAccount {
  <#
  .SYNOPSIS
      Creates a new Resource Account
  .DESCRIPTION
      Teams Call Queues and Auto Attendants require a resource account.
      It can carry a license and optionally also a phone number.
  .PARAMETER UserPrincipalName
      The UPN for the new ResourceAccount. Invalid characters are stripped from the provided string
  .PARAMETER DisplayName
      The Name it will show up in Teams. Invalid characters are stripped from the provided string
  .PARAMETER ApplicationType
      Required. CallQueue or AutoAttendant. Determines the association the account can have: 
      A resource Account of the type "CallQueue" can only be associated with to a Call Queue
      A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
      NOTE: The type can be switched later, though this is not recommended.
  .PARAMETER License
      Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystemVirtualUser
      Unlicensed Objects can exist, but cannot be assigned a phone number
  .PARAMETER PhoneNumber
      Optional. Adds a Microsoft or Direct Routing Number to the Resource Account.
      Requires the Resource Account to be licensed (License Switch)
  .EXAMPLE
      New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -Displayname "My {ResourceAccount}" -ApplicationType CallQueue
      Will create a ResourceAccount of the type CallQueue
      User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
      DisplayName will be normalised to "My ResourceAccount"
  .EXAMPLE
      New-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -Displayname "Mainline" -ApplicationType AutoAttendant -License PhoneSystem -PhoneNumber +1555123456
      Creates a Resource Account for Auto Attendants
      Applies the specified PhoneSystem License (if available in the Tenant)
      Assigns the Telephone Number if object could be licensed correctly. 
  .NOTES
      CmdLet currently in testing.
      Please feed back any issues to david.eberhardt@outlook.com
  .FUNCTIONALITY
      Creates a resource Account in AzureAD for use in Teams
  .LINK
      Set-TeamsResourceAccount
      Get-TeamsResourceAccount
      Remove-TeamsResourceAccount

  #>

  [CmdletBinding()]
  param (
      [Parameter(Mandatory, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = "UPN of the Object to create. Must end in '.onmicrosoft.com'")]
      [ValidateScript({
        If ($_ -match '@' -and $_ -match '.onmicrosoft.com') {
          $True
        }
        else {
          Write-Host "Must contain one '@' and end in '.onmicrosoft.com'" -ForeGroundColor Red
        }
      })]
      [Alias("Identity")]
      [string]$UserPrincipalName,

      [Parameter(HelpMessage = "Display Name as shown in Teams")]
      [string]$DisplayName,
      
      [Parameter(Mandatory, HelpMessage = "CallQueue or AutoAttendant")]
      [ValidateSet("CallQueue","AutoAttendant","CQ","AA")]
      [Alias("Type")]
      [string]$ApplicationType,
      
      [Parameter(HelpMessage = "License to be assigned")]
      [ValidateSet("PhoneSystem","PhoneSystem_VirtualUser")]
      [string]$License = "PhoneSystem_VirtualUser",

      [Parameter(HelpMessage = "Telephone Number to assign")]
      [ValidateScript({
        If ($_ -match "^\+[0-9]{10,15}$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. Must start with a + and 10 to 15 digits long" -ForeGroundColor Red
        }
      })]
      [Alias("Tel","Number","TelephoneNumber")]
      [string]$PhoneNumber        
  )
  
  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Normalising $UserPrincipalname
    $UPN = Format-StringForUse -InputString $UserPrincipalName -As UserPrincipalName
    
    # Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      Write-Verbose -Message "Preparation: Normalising Displayname"
      $DisplayNameNormalised = Format-StringForUse -InputString $DisplayName -As DisplayName
    }

    # Translating $ApplicationType (Name) to ID used by Commands.
    $AppId = GetAppIdfromApplicationType $ApplicationType

    # Phone Numbers
    if($PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Loading all Microsoft Telephone Numbers
      Write-Verbose -Message "Preparation: Loading Telephone Numbers from Tenant"
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers) 
    }

    # Querying Tenant Country as basis for Usage Location
    Write-Verbose -Message "Preparation: Usage Location"
    $Tenant = Get-CsTenant
    if ($null -ne $Tenant.CountryAbbreviation) {
      $UsageLocation = $Tenant.CountryAbbreviation
      Write-Verbose -Message "SUCCESS - Country Abbreviation found in Tenant. Usage Location will be set to $UsageLocation"
    }
    else {
      if($PSBoundParameters.ContainsKey("License")) {
        Write-Error -Message "Country not found in Tenant. Usage Location cannot be set." -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount to apply license and phone number"
        break
      }
      else {
        Write-Warning -Message "Country not found in Tenant. Usage Location cannot be set. If a license is needed, please assign UsageLocation manually before assigning a license"
      }
    }

  } # end of begin

  process {
    #region Creation
    # Creating Account
    try {
        #Trying to create the Resource Account
        Write-Verbose -Message "Action: Creating Resource Account with New-CsOnlineApplicationInstance"
        $null = (New-CsOnlineApplicationInstance -UserPrincipalName $UPN -ApplicationId $AppId -DisplayName $DisplayNameNormalised -ErrorAction STOP)

        Write-Verbose -Message "Waiting for Get-AzureAdUser to return a Result..."
        while ($null -eq $(Get-AzureADUserFromUPN $UPN).ObjectId) {
          Start-Sleep 1
        }
        $ResourceAccountCreated = Get-AzureADUserFromUPN $UPN
      }
    catch {
        # Catching anything
        Write-Host "ERROR:   Creation failed: $($_.Exception.Message)" -ForegroundColor Red
        break
    }
    #endregion
    
    #region UsageLocation
    Write-Verbose -Message "Action: Assigning Usage Location"
    try {
      Get-AzureADUserFromUPN $UPN | Set-AzureAdUser -UsageLocation $UsageLocation -ErrorAction STOP
      Write-Verbose -Message "SUCCESS - Usage Location set to: $UsageLocation"
    }
    catch {
      if($PSBoundParameters.ContainsKey("License")) {
        Write-Error -Message "Usage Location could not be set." -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount to apply license and phone number"
      }
      else {
        Write-Warning -Message "Usage Location cannot be set. If a license is needed, please assign UsageLocation manually before assigning a license"
      }
    }      
    #endregion

    #region Licensing
    # Licensing the new Account
    if($PSBoundParameters.ContainsKey("License")) {
        # Verifying License is available to be assigned
        # Determining available Licenses from Tenant
        Write-Verbose -Message "Querying Licenses..."
        $TenantLicenses = Get-TeamsTenantLicenses
        $RemainingPSlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem"}).Remaining
        Write-Verbose -Message "$RemainingPSlicenses remaining Phone System Licenses"
        $RemainingPSVUlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem - Virtual User"}).Remaining
        Write-Verbose -Message "$RemainingPSVUlicenses remaining Phone System Virtual User Licenses"

        # Assigning License
        switch ($License) {
            "PhoneSystem" {
              # Free License  
              if ($RemainingPSlicenses -lt 1) {
                Write-Warning -Message "No free PhoneSystem License remaining in the Tenant. Trying to assign..."
              }
              # 

              try {
                $null = (Add-TeamsUserLicense -Identity $UPN -AddPhoneSystem -WarningAction STOP -ErrorAction STOP)
                Write-Verbose -Message "SUCCESS - PhoneSystem License assigned"
                $Islicensed = $true                        
                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve Info about runtime error
                $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
                }
            
                # output Info. Post-process collected info, and log info (optional)
                $info
              }
              catch {
                Write-Error -Message "License assignment failed"
                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve Info about runtime error
                $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
                }
            
                # output Info. Post-process collected info, and log info (optional)
                $info
              }
            }
            "PhoneSystem_VirtualUser" {
              if ($RemainingPSVUlicenses -lt 1) {
                Write-Warning -Message "No free PhoneSystem Virtual User License remaining in the Tenant. Trying to assign..."
              }

              try {
                $null = (Add-TeamsUserLicense -Identity $UPN -WarningAction STOP -AddPhoneSystemVirtualUser -ErrorAction STOP)
                Write-Verbose -Message "SUCCESS - PhoneSystem Virtual User License assigned"
                $Islicensed = $true                        
              }
              catch {
                Write-Error -Message "License assignment failed"
                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve Info about runtime error
                $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
                }
            
                # output Info. Post-process collected info, and log info (optional)
                $info
              }
            }
        }
    }
    else {
        $Islicensed = $false        
    }
    #endregion

    #region PhoneNumber
    # Assigning Telephone Number
    Write-Verbose -Message "Assigning Phone Number"
    Write-Verbose -Message "NOTE: Assigning a phone number might fail because the Object in AzureAD does not exist yet." -Verbose
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      if (-not $Islicensed) {
        Write-Host "ERROR: A Phone Number can only be assigned to licensed objects." -ForegroundColor Red
        Write-Host "Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both"
      }
      else {
        # Query CsOnlineApplicationInstance (making sure the Object exists)
        Write-Verbose -Message "Waiting for the CsOnlineApplicationInstance - In testing this took longer than 30s" -Verbose
        $count = 40
        For($i = 1; $i -le $count; $i++)
        {
          Write-Progress -Activity "Waiting for AAD to create the ApplicationInstance" `
          -PercentComplete (($i*100)/$count) `
          -Status "$(([math]::Round((($i)/$count * 100),0))) %"
          
          Start-Sleep -Milliseconds 1000
        }

        # Processing paths for Telephone Numbers depending on Type
        if ($PhoneNumberIsMSNumber) {
          # Set in VoiceApplicationInstance
          Write-Verbose -Message "Number found in Tenant, assuming provisioning Microsoft Calling Plans"
          try {
            $null = (Set-CsOnlineVoiceApplicationInstance -Identity $ResourceAccountCreated.UserPrincipalName -Telephonenumber $PhoneNumber -ErrorAction STOP)
          }
          catch {
            Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsResourceAccount manually"
          }
        }
        else {
          # Set in ApplicationInstance
          Write-Verbose -Message "Number not found in Tenant, assuming provisioning for Direct Routing"
          try {
            $null = (Set-CsOnlineApplicationInstance -Identity $ResourceAccountCreated.UserPrincipalName -OnPremPhoneNumber $PhoneNumber -ErrorAction STOP)
          }
          catch {
            Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsResourceAccount manually"
          }
        }
      }
    }
    #  wating for replication in the hope that the PhoneNumber is able to be queried correctly
    Start-Sleep -Seconds 2
    #endregion

    #region Output
    #Creating new PS Object
    try {
        # Data
        $ResourceAccount = Get-CsOnlineApplicationInstance -Identity $UPN -ErrorAction STOP

        # readable Application type
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId

        # Resource Account License
        if ($Islicensed) {
          # License
          if (Test-TeamsUserLicense -Identity $UPN -LicensePackage PhoneSystem) {
            $ResourceAccuntLicense = "PhoneSystem"
          }
          elseif (Test-TeamsUserLicense -Identity $UPN -LicensePackage PhoneSystem_VirtualUser) {
            $ResourceAccuntLicense = "PhoneSystem_VirtualUser"
          }
          else {
            $ResourceAccuntLicense = $null
          }

          if($null -ne $ResourceAccount.PhoneNumber) {
            # Phone Number Type
            if ($PhoneNumberIsMSNumber) {
              $ResourceAccountPhoneNumberType = "Microsoft Number"
            }
            else {
              $ResourceAccountPhoneNumberType = "Direct Routing Number"
            }
          }
          else {
            $ResourceAccountPhoneNumberType = $null
          }
          
          # Phone Number is taken from Original Object and should be populated correctly

        }
        else {
          $ResourceAccuntLicense = $null
          $ResourceAccountPhoneNumberType = $null
          # Phone Number is taken from Original Object and should be empty at this point                    
        }

        # creating new PS Object (synchronous with Get and Set)
        $ResourceAccountObject = [PSCustomObject][ordered]@{
          UserPrincipalName   = $ResourceAccount.UserPrincipalName
          DisplayName         = $ResourceAccount.DisplayName
          UsageLocation       = $UsageLocation
          ApplicationType     = $ResourceAccountApplicationType
          License             = $ResourceAccuntLicense
          PhoneNumberType     = $ResourceAccountPhoneNumberType
          PhoneNumber         = $ResourceAccount.PhoneNumber
        }
        
        Write-Verbose -Message "Resource Account Created:"
        if ($PSBoundParameters.ContainsKey("PhoneNumber") -and $Islicensed -and $ResourceAccount.PhoneNumber -eq "") {
          Write-Warning -Message "Object replication pending, Phone Number does not show yet. Run Get-TeamsResourceAccount after 5-10 mins to verify"
        }
        return $ResourceAccountObject

    }
    catch {
      Write-Warning -Message "Object Output could not be verified. Please verify manually with Get-CsOnlineApplicationInstance"
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
  
      # output Info. Post-process collected info, and log info (optional)
      $info
    }
    #endregion
  }
  
  end {
      
  }
}

function Get-TeamsResourceAccount {
  <#
  .SYNOPSIS
      Returns Resource Accounts
  .DESCRIPTION
      Returns one or more Resource Accounts based on input.
  .EXAMPLE
      Get-TeamsResourceAccount
      Returns all Resource Accounts
  .EXAMPLE
      Get-TeamsResourceAccount -Identity ResourceAccount@TenantName.onmicrosoft.com
      Returns the Resource Account with the Identity specified, if found.
  .EXAMPLE
      Get-TeamsResourceAccount -ApplicationType AutoAttendant
      Returns all Resource Accounts of the specified ApplicationType.
  .EXAMPLE
      Get-TeamsResourceAccount -PhoneNumber +1555123456
      Returns the Resource Account with the Phone Number specifed, if found.
  .NOTES
      CmdLet currently in testing.
      Pipeline input possible, though untested. Requires figuring out :)
      Please feed back any issues to david.eberhardt@outlook.com
  .FUNCTIONALITY
      Returns one or more Resource Accounts
  .LINK
      New-TeamsResourceAccount
      Set-TeamsResourceAccount
      Remove-TeamsResourceAccount
  #>

  [CmdletBinding(DefaultParameterSetName = "Search")]
  param (
      [Parameter(ParameterSetName = "Identity", ValueFromPipelineByPropertyName = $true, HelpMessage = "User Principal Name of the Object.")]
      [Alias("UPN","UserPrincipalName")]
      [string]$Identity,

      [Parameter(ParameterSetName = "Search", Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Searches for AzureAD Object with this Name")]
      [AllowNull()]
      [string]$Searchstring,

      [Parameter(ParameterSetName = "AppType", HelpMessage = "Limits search to specific Types: CallQueue or AutoAttendant")]
      [ValidateSet("CallQueue","AutoAttendant","CQ","AA")]
      [Alias("Type")]
      [string]$ApplicationType,

      [Parameter(ParameterSetName = "Number", ValueFromPipelineByPropertyName = $true, HelpMessage = "Telephone Number of the Object")]
      [ValidateScript({
        If ($_ -match "^\+?[0-9]{3,15}$") {
          $True
        }
        else {
          Write-Host "Not a phone number or part of a number. Must start with a + and 3 to 15 digits long" -ForeGroundColor Red
        }
      })]
      [Alias("Tel","Number","TelephoneNumber")]
      [string]$PhoneNumber        
  )
  
  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    #Data gathering
    if ($PSBoundParameters.ContainsKey('Searchstring')) {
        if ($null -ne $Searchstring) {
          Write-Verbose -Message "Searchstring used - Searching for DisplayName $SearchString" -Verbose
          $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property DisplayName -Like -Value $SearchString
        }
        else {
          Write-Verbose -Message "SearchString used but no data provided, listing all Resource Accounts" -Verbose
          $ResourceAccounts = Get-CsOnlineApplicationInstance
        }
      }
      elseif ($PSBoundParameters.ContainsKey('Identity')) {
        Write-Verbose -Message "Identity used - Searching for $Identity" -Verbose
        try {
          $ResourceAccounts = Get-CsOnlineApplicationInstance $Identity -ErrorAction Stop
        }
        catch {
          $ResourceAccounts = $null
        }
      }
      elseif ($PSBoundParameters.ContainsKey('ApplicationType')) {
        Write-Verbose -Message "ApplicationType used - Searching for $ApplicationType"
        $AppId = GetAppIdfromApplicationType $ApplicationType
        $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property ApplicationId -EQ -Value $AppId
      }
      elseif ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        Write-Verbose -Message "PhoneNumber used - Searching for $PhoneNumber"
        $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property PhoneNumber -Like -Value "*$PhoneNumber*"
        
        # Loading all Microsoft Telephone Numbers
        Write-Verbose -Message "Gathering Phone Numbers from the Tenant"
        $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
        $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers) 
      }
      else {
        Write-Verbose -Message "No Parameter provided, listing all Resource Accounts"
        $ResourceAccounts = Get-CsOnlineApplicationInstance
      }

      # Stop script if no data has been determined
      if ($null -eq $ResourceAccounts) {
        Write-Verbose -Message "No Data found."
        return
      }

      # Usage Location from Object
      $UsageLocation = (Get-CsTenant).CountryAbbreviation
    

    } # end of begin

  process {
      #Creating new PS Object
      try {
          [System.Collections.ArrayList]$AllAccounts = @()
          Write-Verbose -Message "Parsing Resource Accounts, please wait..." -Verbose
          foreach ($ResourceAccount in $ResourceAccounts) {
              # readable Application type
              if ($PSBoundParameters.ContainsKey('ApplicationType')) {
                $ResourceAccountApplicationType = $ApplicationType
              }
              else {
                $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId
              }
            
              # Resource Account License
              # License
              if (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -LicensePackage PhoneSystem) {
                $ResourceAccuntLicense = "PhoneSystem"
              }
              elseif (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -LicensePackage PhoneSystem_VirtualUser) {
                  $ResourceAccuntLicense = "PhoneSystem_VirtualUser"
              }
              else {
                  $ResourceAccuntLicense = $null
              }

              # Phone Number Type
              if ($null -ne $ResourceAccount.PhoneNumber) {
                  if ($PhoneNumberIsMSNumber) {
                      $ResourceAccountPhoneNumberType = "Microsoft Number"
                  }
                  else {
                      $ResourceAccountPhoneNumberType = "Direct Routing Number"
                  }
              }
              else {
                  $ResourceAccountPhoneNumberType = $null
              }
             
              # creating new PS Object (synchronous with Get and Set)
              $ResourceAccountObject = [PSCustomObject][ordered]@{
                UserPrincipalName   = $ResourceAccount.UserPrincipalName
                DisplayName         = $ResourceAccount.DisplayName
                UsageLocation       = $UsageLocation
                ApplicationType     = $ResourceAccountApplicationType
                License             = $ResourceAccuntLicense
                PhoneNumberType     = $ResourceAccountPhoneNumberType
                PhoneNumber         = $ResourceAccount.PhoneNumber
              }

              [void]$AllAccounts.Add($ResourceAccountObject)
          }
          return $AllAccounts

      }
      catch {
          Write-Warning -Message "Object Output could not be determined. Please verify manually with Get-CsOnlineApplicationInstance"
          # get error record
          [Management.Automation.ErrorRecord]$e = $_

          # retrieve Info about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
      
          # output Info. Post-process collected info, and log info (optional)
          $info
      }
  }
  
  end {
      
  }
}

function Set-TeamsResourceAccount {
  <#
  .SYNOPSIS
      Changes a new Resource Account
  .DESCRIPTION
      This function allows you to update Resource accounts for Teams Call Queues and Auto Attendants.
      It can carry a license and optionally also a phone number.
  .PARAMETER UserPrincipalName
      Required. Identifies the Object being changed
  .PARAMETER DisplayName
      Optional. The Name it will show up in Teams. Invalid characters are stripped from the provided string
  .PARAMETER ApplicationType
      CallQueue or AutoAttendant. Determines the association the account can have: 
      A resource Account of the type "CallQueue" can only be associated with to a Call Queue
      A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
      NOTE: Though switching the account type is possible, this is currently untested: Handle with Care!
  .PARAMETER License
      Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystemVirtualUser
      Unlicensed Objects can exist, but cannot be assigned a phone number
      If a license already exists, it will try to swap the license to the specified one.
  .PARAMETER PhoneNumber
      Optional. Changes the Phone Number of the object.
      Can either be a Microsoft Number or a Direct Routing Number.
      Requires the Resource Account to be licensed correctly
  .EXAMPLE
      Set-TeamsResourceAccount -UserPrincipalName ResourceAccount@TenantName.onmicrosoft.com -Displayname "My {ResourceAccount}"
      Will normalise the Display Name (i.E. remove special characters), then set it as "My ResourceAccount"
  .EXAMPLE
      Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -License PhoneSystem
      Changes the License to Resource Account AA-Mainline: If no license is assigned, will try to assign.
      If a PhoneSystem License is applied, no action is taken. If a PhoneSystem Virtual User license is assigned, the license will be swapped.
  .EXAMPLE
      Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber +1555123456
      Changes the Phone number of the Object. Will cleanly remove the Phone Number first before reapplying it.
      This will only succeed if the object is licensed correctly!
  .EXAMPLE
      Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber $Null
      Removes the Phone number from the Object
  .EXAMPLE
      Set-TeamsResourceAccount -UserPrincipalName MyRessourceAccount@TenantName.onmicrosoft.com -ApplicationType AutoAttendant
      Switches MyResourceAccount to the Type AutoAttendant
      NOTE: This is currently untested, errors might occur simply because not all caveats could be captured.
      Handle with care!
  .NOTES
      CmdLet currently in testing.
      Please feed back any issues to david.eberhardt@outlook.com
  .FUNCTIONALITY
      Changes a resource Account in AzureAD for use in Teams
  .LINK
      New-TeamsResourceAccount
      Get-TeamsResourceAccount
      Remove-TeamsResourceAccount
  #>

  [CmdletBinding()]
  param (
      [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to change. Must end in '.onmicrosoft.com'")]
      [ValidateScript({
        If ($_ -match '@' -and $_ -match '.onmicrosoft.com') {
          $True
        }
        else {
          Write-Host "Must contain one '@' and end in '.onmicrosoft.com'" -ForeGroundColor Red
        }
      })]      
      [Alias("Identity")]
      [string]$UserPrincipalName,

      [Parameter(HelpMessage = "Display Name as shown in Teams")]
      [string]$DisplayName,
      
      [Parameter(HelpMessage = "CallQueue or AutoAttendant")]
      [ValidateSet("CallQueue","AutoAttendant","CQ","AA")]
      [Alias("Type")]
      [string]$ApplicationType,
      
      [Parameter(HelpMessage = "License to be assigned")]
      [ValidateSet("PhoneSystem","PhoneSystem_VirtualUser")]
      [string]$License = "PhoneSystem_VirtualUser",

      [Parameter(HelpMessage = "Telephone Number to assign")]
      [Alias("Tel","Number","TelephoneNumber")]
      [string]$PhoneNumber        
  )
  
  begin {
    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      Write-Verbose -Message "Preparation: Normalising Displayname"
      $DisplayNameNormalised = Format-StringForUse -InputString $DisplayName -As DisplayName
    }

    # Application Type and Associations
    if($PSBoundParameters.ContainsKey("ApplicationType")) {
      # Translating $ApplicationType (Name) to ID used by Commands.
      Write-Verbose -Message "Preparation: ApplicationType and Associations"
      $AppId = GetAppIdfromApplicationType $ApplicationType
      $CurrentAppId = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).ApplicationId
      # Does the ApplicationType differ? Does it have to be changed?
      if ($AppId -eq $CurrentAppId) {
        # Application IDs match - Type does not need to be changed
        Write-Verbose -Message "Application Type already set to $ApplicationType. No change necessary."
      }
      else {
        # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
        $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -ErrorAction Ignore
        if ($Associations.count -gt 0) {
          # Associations found. Aborting
          Write-Error -Message "Object is associated with Call Queue or AutoAttendant. ApplicationType cannot be changed" -Category OperationStopped -RecommendedAction "Remove Associations with Remove-CsOnlineApplicationInstanceAssociation manually"
          break
        }  
      }      
    }

    # Phone Numbers
    # Loading all Microsoft Telephone Numbers
    Write-Verbose -Message "Preparation: Loading Telephone Numbers from Tenant"
    $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
    if($PSBoundParameters.ContainsKey("PhoneNumber")) {
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers) 
    }
    try {
      $CurrentPhoneNumber = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).PhoneNumber.Replace('tel:','')
    }
    catch {
      $CurrentPhoneNumber = $null
    }
    
    # Querying UsageLocation
    Write-Verbose -Message "Preparation: Usage Location"
    $CurrentUsageLocation = (Get-AzureADUserFromUPN $UserPrincipalName).UsageLocation
    if ($null -eq $CurrentUsageLocation) {
      Write-Verbose -Message "$UserPrincipalName - Usage Location not set for Object"
      # Quering Tenant Country as basis for Usage Location
      $Tenant = Get-CsTenant
      if ($null -ne $Tenant.CountryAbbreviation) {
        $UsageLocation = $Tenant.CountryAbbreviation
        Write-Verbose -Message "SUCCESS - Country Abbreviation found in Tenant. Usage Location will be set to $UsageLocation"
      }
      else {
        if ($PSBoundParameters.ContainsKey("License") -or $PSBoundParameters.ContainsKey("PhoneNumber")) {
          Write-Error -Message "Country not found in Tenant. Usage Location cannot be set. License cannot be applied either" -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount again to apply license and phone number"
          break
        }
        else {
          Write-Warning -Message "Country not found in Tenant. Usage Location cannot be set. If a license is needed, please assign UsageLocation manually before assigning a license"
        }
      }  
    }

    # Current License
    if($PSBoundParameters.ContainsKey("License") -or $PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Determining license Status of Object
      Write-Verbose -Message "Preparation: License Assignment"
      if (Test-TeamsUserLicense -Identity $UserPrincipalName -LicensePackage PhoneSystem) {
        $CurrentLicense = "PhoneSystem"
      }
      elseif (Test-TeamsUserLicense -Identity $UserPrincipalName -LicensePackage PhoneSystem_VirtualUser) {
          $CurrentLicense = "PhoneSystem_VirtualUser"
      }
      else {
          $CurrentLicense = $null
      }
    }    
  } # end of begin

  process {
    #region Lookup of UserPrincipalName
    try {
        #Trying to query the Resource Account
        $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -ErrorAction STOP)
        $CurrentDisplayName = $Object.DisplayName
    }
    catch {
        # Catching anything
        Write-Error -Message "Object not found! Please provide a valid UserPrincipalName of an existing Resource Account" -Category ObjectNotFound
        break
    }
    #endregion

    #region DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      try {
        Write-Verbose -Message "'$CurrentDisplayName' - Changing DisplayName to: $DisplayNameNormalised"
        $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -Displayname "$DisplayNameNormalised" -ErrorAction STOP)
        Write-Verbose -Message "SUCCESS"

        $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -ErrorAction STOP)
        $CurrentDisplayName = $Object.DisplayName
      }
      catch {
          Write-Verbose -Message "FAILED - Error encountered changing DisplayName"
          Write-Error -Message "Problem encountered with changing DisplayName" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
          # get error record
          [Management.Automation.ErrorRecord]$e = $_

          # retrieve Info about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
      
          # output Info. Post-process collected info, and log info (optional)
          $info
      }
    }
    #endregion

    #region Application Type
    if ($PSBoundParameters.ContainsKey("ApplicationType")) {
        $CurrentAppId = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).ApplicationId
        # Application Type Change?
        if ($AppId -ne $CurrentAppId) {
          try {
            Write-Verbose -Message "'$CurrentDisplayName' - Changing Application Type to: $ApplicationType"
            $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -ApplicationId $AppId -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS"
          }
          catch {
            Write-Error -Message "Problem encountered changing Application Type" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve Info about runtime error
            $info = [PSCustomObject]@{
              Exception = $e.Exception.Message
              Reason    = $e.CategoryInfo.Reason
              Target    = $e.CategoryInfo.TargetName
              Script    = $e.InvocationInfo.ScriptName
              Line      = $e.InvocationInfo.ScriptLineNumber
              Column    = $e.InvocationInfo.OffsetInLine
            }
        
            # output Info. Post-process collected info, and log info (optional)
            $info
          }
        }
    }
    #endregion

    #region Licensing
    if($PSBoundParameters.ContainsKey("License")) {
      # Verifying License is available to be assigned
      # Determining available Licenses from Tenant
      Write-Verbose -Message "Querying Licenses..."
      $TenantLicenses = Get-TeamsTenantLicenses
      $RemainingPSlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem"}).Remaining
      Write-Verbose -Message "$RemainingPSlicenses remaining Phone System Licenses"
      $RemainingPSVUlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem - Virtual User"}).Remaining
      Write-Verbose -Message "$RemainingPSVUlicenses remaining Phone System Virtual User Licenses"

      # Changing License if requried
      if ($License -eq $CurrentLicense) {
        # No action required
        Write-Verbose -Message "'$CurrentDisplayName' - No action taken: License '$License' already assigned."
        $Islicensed = $true
      }
      else {
        # Switching dependent on input
        switch ($License) {
            "PhoneSystem" {
                Write-Verbose -Message "Testing whether PhoneSystem License is available"
                $RemainingPSlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem"}).Remaining
                if ($RemainingPSlicenses -lt 1) {
                    Write-Warning -Message "No free PhoneSystem License remaining in the Tenant! Trying to assign regardles..."
                }
                else {
                    Write-Verbose -Message "SUCCESS - Phone System License found available"
                }
                try {
                    if ($null = $CurrentLicense) {
                        Write-Verbose -Message "Trying to assign new License: '$License'"
                        Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystem -ErrorAction STOP
                    }
                    else {
                        Write-Verbose -Message "Trying to swap License from '$CurrentLicense' to '$License'"
                        #This will fail - currently blocked in Add-TeamsUserLicense
                        Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystem -Replace -ErrorAction STOP
                    }
                    Write-Verbose -Message "SUCCESS - PhoneSystem License assigned"
                    $Islicensed = $true                        
                }
                catch {
                    Write-Error -Message "License assignment failed"
                    $Islicensed = $false

                    # get error record
                    [Management.Automation.ErrorRecord]$e = $_

                    # retrieve Info about runtime error
                    $info = [PSCustomObject]@{
                      Exception = $e.Exception.Message
                      Reason    = $e.CategoryInfo.Reason
                      Target    = $e.CategoryInfo.TargetName
                      Script    = $e.InvocationInfo.ScriptName
                      Line      = $e.InvocationInfo.ScriptLineNumber
                      Column    = $e.InvocationInfo.OffsetInLine
                    }
                
                    # output Info. Post-process collected info, and log info (optional)
                    $info
                }
            }
            "PhoneSystem_VirtualUser" {
                Write-Verbose -Message "Testing whether PhoneSystem Virtual User License is available"
                $RemainingPSVUlicenses = ($TenantLicenses | Where-Object {$_.License -eq "PhoneSystem - Virtual User"}).Remaining
                if ($RemainingPSVUlicenses -lt 1) {
                    Write-Warning -Message "No free PhoneSystem Virtual User License remaining in the Tenant! Trying to assign regardles..."
                }
                else {
                    Write-Verbose -Message "SUCCESS - Phone System Virtual User License found available"
                }
                try {
                    if ($null = $CurrentLicense) {
                        Write-Verbose -Message "Trying to assign new License: '$License'"
                        Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystemVirtualUser -ErrorAction STOP
                    }
                    else {
                        Write-Verbose -Message "Trying to swap License from '$CurrentLicense' to '$License'"
                        Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystemVirtualUser -Replace -ErrorAction STOP
                    }
                    Write-Verbose -Message "SUCCESS - PhoneSystem Virtual User License assigned"
                    $Islicensed = $true                        
                }
                catch {
                    Write-Error -Message "License assignment failed"
                    $Islicensed = $false
                    # get error record
                    [Management.Automation.ErrorRecord]$e = $_

                    # retrieve Info about runtime error
                    $info = [PSCustomObject]@{
                      Exception = $e.Exception.Message
                      Reason    = $e.CategoryInfo.Reason
                      Target    = $e.CategoryInfo.TargetName
                      Script    = $e.InvocationInfo.ScriptName
                      Line      = $e.InvocationInfo.ScriptLineNumber
                      Column    = $e.InvocationInfo.OffsetInLine
                    }
                
                    # output Info. Post-process collected info, and log info (optional)
                    $info
                }
            }
        }
      }
    }
    #endregion

    #region PhoneNumber
    # Assigning Telephone Number
    Write-Verbose -Message "Assigning Phone Number"
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      if ($CurrentPhoneNumber -eq $PhoneNumber) {
        # No action requried. Phone Number already assigned.
        Write-Verbose -Message "'$CurrentDisplayName' - No action taken: Phone Number already assigned."
      }
      else {
        if ($null -eq $CurrentLicense -and -not $Islicensed) {
          Write-Host "ERROR: A Phone Number can only be assigned to licensed objects." -ForegroundColor Red
          Write-Host "Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both"
        }
        else {
          # Processing paths for Telephone Numbers depending on Type
          # Removing old Number
          # Type of current number is determined as $CurrentPhoneNumberIsMSNumber, though not used.
          # This is due to the fact that the Number should be removed from both, just in case.
          try {
            # Remove from VoiceApplicationInstance
            Write-Verbose -Message "'$CurrentDisplayName' - Removing Microsoft Number"
            $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
            # Remove from ApplicationInstance
            Write-Verbose -Message "'$CurrentDisplayName' - Removing Direct Routing Number"
            $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
          }
          catch {
            Write-Error -Message "Unassignment of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser" 
            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve Info about runtime error
            $info = [PSCustomObject]@{
              Exception = $e.Exception.Message
              Reason    = $e.CategoryInfo.Reason
              Target    = $e.CategoryInfo.TargetName
              Script    = $e.InvocationInfo.ScriptName
              Line      = $e.InvocationInfo.ScriptLineNumber
              Column    = $e.InvocationInfo.OffsetInLine
            }
        
            # output Info. Post-process collected info, and log info (optional)
            $info
          }
          # Assigning new Number
          # Processing paths for Telephone Numbers depending on Type
          if ($PhoneNumberIsMSNumber) {
            # Set in VoiceApplicationInstance
            Write-Verbose -Message "Number found in Tenant, assuming provisioning Microsoft Calling Plans"
            try {
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $PhoneNumber)
            }
            catch {
              Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsResourceAccount manually"
            }
          }
          else {
            # Set in ApplicationInstance
            Write-Verbose -Message "Number not found in Tenant, assuming provisioning for Direct Routing"
            try {
              $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $PhoneNumber)
            }
            catch {
              Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsResourceAccount manually"
            }
          }
        }
      }
    }
    #endregion
      
  }
  
  end {
      
  }
}

function Remove-TeamsResourceAccount {
  <#
  .SYNOPSIS
      Removes a new Resource Account
  .DESCRIPTION
      This function allows you to update Resource accounts for Teams Call Queues and Auto Attendants.
      It can carry a license and optionally also a phone number.
  .PARAMETER UserPrincipalName
      Required. Identifies the Object being changed
  .PARAMETER Force
      Optional. Will also sever all associations this account has in order to remove it
      Script fails if the Account is assigned somewhere
  .EXAMPLE
      Remove-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com"
      Removes a ResourceAccount
      Removes in order: Phone Number, License and Account  
  .EXAMPLE
      Remove-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com" -Force
      Removes a ResourceAccount
      Removes in order: Phone Number, License and Account
      Parameter Force is optional and will also remove all Associations this account has to Call Queues or AutoAttendants.
  .NOTES
      CmdLet currently in testing.
      Execution requires User Admin Role in Azure AD
      Please feed back any issues to david.eberhardt@outlook.com
  .FUNCTIONALITY
      Removes a resource Account in AzureAD for use in Teams
  .LINK
      New-TeamsResourceAccount
      Get-TeamsResourceAccount
      Set-TeamsResourceAccount
  #>

  [CmdletBinding()]
  param (
      [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to create. Must end in '.onmicrosoft.com'")]
      [ValidateScript({
        If ($_ -match '@' -and $_ -match '.onmicrosoft.com') {
          $True
        }
        else {
          Write-Host "Must contain one '@' and end in '.onmicrosoft.com'" -ForeGroundColor Red
        }
      })]
      [Alias("Identity","ObjectId")]
      [string]$UserPrincipalName,

      [Parameter(Mandatory = $false)]
      [switch]$Force
  )
  
  begin {
    # Caveat - Access rights 
    Write-Verbose -Message "This Script requires the executor to have access to AzureAD and rights to execute Remove-AzureAdUser" -Verbose
    Write-Verbose -Message "No verficication of required admin roles is performed. Use Get-AzureAdAssignedAdminRoles to determine roles for your account"

    # Testing AzureAD Connection
    if (-not (Test-AzureADConnection)) {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (-not (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Adding Types - Required for License manipulation in Process
    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
        
  } # end of begin

process {
    #region Lookup of UserPrincipalName
    try {
      #Trying to query the Resource Account
      Write-Verbose -Message "Processing: $UserPrincipalName"
      $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -ErrorAction STOP)
      $DisplayName = $Object.DisplayName
    }
    catch {
      # Catching anything
      Write-Warning -Message "Object not found! Please provide a valid UserPrincipalName of an existing Resource Account"
      return
    }
    #endregion

    #region Associations
    # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
    Write-Verbose -Message "Processing: '$DisplayName' - Associations to Call Queues or Auto Attendants"
    $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -ErrorAction Ignore
    if ($Associations.count -eq 0) {
      # Object has no associations
      Write-Verbose -Message "'$DisplayName' - Object does not have any associaions"
      $Associations = $null
    }
    else {
      Write-Verbose -Message "'$DisplayName' - associaions found"
      if($PSBoundParameters.ContainsKey("Force")) {
        # Removing all Associations to of this Resource Account to Call Queues or Auto Attendants
        # with: Remove-CsOnlineApplicationInstanceAssociation
        try {
          Write-Verbose -Message "Trying to remove the Associations of this Resource Account"
          $null = (Remove-CsOnlineApplicationInstanceAssociation $Associations  -ErrorAction STOP)
          Write-Verbose -Message "SUCCESS: Associations removed"
        }
        catch {
          Write-Error -Message "Associations could not be removed! Please check manually with Remove-CsOnlineApplicationInstanceAssociation" -Category InvalidOperation
          # get error record
          [Management.Automation.ErrorRecord]$e = $_

          # retrieve Info about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
      
          # output Info. Post-process collected info, and log info (optional)
          $info
          return                
        }
      }
      else {
        Write-Error -Message "Associations detected. Please remove first or use -Force" -Category ResourceExists
        return $Associations
      }
    }
    #endregion

    #region PhoneNumber
    # Removing Phone Number Assignments
    Write-Verbose -Message "Processing: '$DisplayName' - Phone Number Assignments"
    try {
      # Remove from VoiceApplicationInstance
      Write-Verbose -Message "'$DisplayName' - Removing Microsoft Number"
      $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
      # Remove from ApplicationInstance
      Write-Verbose -Message "'$DisplayName' - Removing Direct Routing Number"
      $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
    }
    catch {
      Write-Error -Message "Unassignment of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser" 
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
  
      # output Info. Post-process collected info, and log info (optional)
      $info
      return
    }
    #endregion

    #region Licensing
    # Reading User Licenses
    Write-Verbose -Message "Processing: '$DisplayName' - Phone Number Assignments"
    try {
      $UserLicenseSkuIDs = (Get-AzureADUserLicenseDetail -ObjectId $UserPrincipalName -ErrorAction STOP).SkuId

      if ($null -eq $UserLicenseSkuIDs) {
        Write-Verbose -Message "'$DisplayName' - No licenses assigned. OK"
      }
      else {
        $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        # This should work: 
        Write-Verbose -Message "'$DisplayName' - Removing Removing licenses"
        $Licenses.RemoveLicenses = @($UserLicenseSkuIDs)
        Set-AzureADUserLicense -ObjectId $Object.ObjectId -AssignedLicenses $Licenses -ErrorAction STOP
        Write-Verbose -Message "SUCCESS"
      }
    }
    catch {
      Write-Error -Message "Unassignment of Licenses failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-AzureADUserLicense" 
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
  
      # output Info. Post-process collected info, and log info (optional)
      $info
      return
    }

    #endregion

    #region Account Removal
    # Removing AzureAD User
    Write-Verbose -Message "Processing: '$DisplayName' - Removing AzureAD User Objcet"
    try {
      $null = (Remove-AzureADUser -ObjectID $UserPrincipalName -ErrorAction STOP)
      Write-Verbose -Message "SUCCESS - Object removed from Azure Active Directory"
    }
    catch {
      Write-Error -Message "Removal failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser" 
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve Info about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
  
      # output Info. Post-process collected info, and log info (optional)
      $info
    }
    #endregion
    
  }
  
  end {
      
  }
}
#Alias is set to provide default behaviour to CsOnlineApplicationInstance
Set-Alias -Name Remove-CsOnlineApplicationInstance -Value Remove-TeamsResourceAccount
#endregion


#region Backup Scripts
# by Ken Lasko
function Backup-TeamsEV {
  <#
    .SYNOPSIS
      A script to automatically backup a Microsoft Teams Enterprise Voice configuration.
    
    .DESCRIPTION
      Automates the backup of Microsoft Teams Enterprise Voice normalization rules, dialplans, voice policies, voice routes, PSTN usages and PSTN GW translation rules for various countries.
    
    .PARAMETER OverrideAdminDomain
      OPTIONAL: The FQDN your Office365 tenant. Use if your admin account is not in the same domain as your tenant (ie. doesn't use a @tenantname.onmicrosoft.com address)

    .NOTES
      Version 1.10
      Build: Feb 04, 2020
      
      Copyright © 2020  Ken Lasko
      klasko@ucdialplans.com
      https://www.ucdialplans.com
  #>

  [CmdletBinding(ConfirmImpact = 'None')]
  param
  (
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $OverrideAdminDomain
  )

  $Filenames = 'Dialplans.txt', 'VoiceRoutes.txt', 'VoiceRoutingPolicies.txt', 'PSTNUsages.txt', 'TranslationRules.txt', 'PSTNGateways.txt'

  If ((Get-PSSession | Where-Object -FilterScript {
          $_.ComputerName -like '*.online.lync.com'
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

  Try {
    $null = (Get-CsTenantDialPlan -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath Dialplans.txt -Force -Encoding utf8)
    $null = (Get-CsOnlineVoiceRoute -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath VoiceRoutes.txt -Force -Encoding utf8)
    $null = (Get-CsOnlineVoiceRoutingPolicy -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath VoiceRoutingPolicies.txt -Force -Encoding utf8)
    $null = (Get-CsOnlinePstnUsage -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath PSTNUsages.txt -Force -Encoding utf8)
    $null = (Get-CsTeamsTranslationRule -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath TranslationRules.txt -Force -Encoding utf8)
    $null = (Get-CsOnlinePSTNGateway -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath PSTNGateways.txt -Force -Encoding utf8)
  } 
  Catch {
    Write-Error -Message 'There was an error backing up the MS Teams Enterprise Voice configuration.'
    return
  }

  $BackupFile = ('TeamsEVBackup_' + (Get-Date -Format yyyy-MM-dd) + '.zip')
  $null = (Compress-Archive -Path $Filenames -DestinationPath $BackupFile -Force)
  $null = (Remove-Item -Path $Filenames -Force -Confirm:$false)

  Write-Host -Object ('Microsoft Teams Enterprise Voice configuration backed up to {0}' -f $BackupFile)

}

function Restore-TeamsEV {
  <#
    .SYNOPSIS
      A script to automatically restore a backed-up Teams Enterprise Voice configuration.

    .DESCRIPTION
      A script to automatically restore a backed-up Teams Enterprise Voice configuration. Requires a backup run using Backup-TeamsEV.ps1 in the same directory as the script. Will restore the following items:
      - Dialplans and associated normalization rules
      - Voice routes
      - Voice routing policies
      - PSTN usages
      - Outbound translation rules

    .PARAMETER File
      REQUIRED. Path to the zip file containing the backed up Teams EV config to restore

    .PARAMETER KeepExisting
      OPTIONAL. Will not erase existing Enterprise Voice configuration before restoring.

    .PARAMETER OverrideAdminDomain
      OPTIONAL: The FQDN your Office365 tenant. Use if your admin account is not in the same domain as your tenant (ie. doesn't use a @tenantname.onmicrosoft.com address)

    .NOTES
      Version 1.10
      Build: Feb 04, 2020

      Copyright © 2020  Ken Lasko
      klasko@ucdialplans.com
      https://www.ucdialplans.com
  #>

  [CmdletBinding(ConfirmImpact = 'Medium',
  SupportsShouldProcess)]
  param
  (
    [Parameter(Mandatory, HelpMessage = 'Path to the zip file containing the backed up Teams EV config to restore',
    ValueFromPipelineByPropertyName)]
    [string]
    $File,
    [switch]
    $KeepExisting,
    [string]
    $OverrideAdminDomain
  )

  Try {
    $ZipPath = (Resolve-Path -Path $File)
    $null = (Add-Type -AssemblyName System.IO.Compression.FileSystem)
    $ZipStream = [io.compression.zipfile]::OpenRead($ZipPath)
  }
  Catch {
    Write-Error -Message 'Could not open zip archive.' -ErrorAction Stop
    return
  }

  If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
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

  $EV_Entities = 'Dialplans', 'VoiceRoutes', 'VoiceRoutingPolicies', 'PSTNUsages', 'TranslationRules', 'PSTNGateways'

  Write-Host -Object 'Validating backup files.'

  ForEach ($EV_Entity in $EV_Entities) {
    Try {
      $ZipItem = $ZipStream.GetEntry("$EV_Entity.txt")
      $ItemReader = (New-Object -TypeName System.IO.StreamReader -ArgumentList ($ZipItem.Open()))

      $null = (Set-Variable -Name $EV_Entity -Value ($ItemReader.ReadToEnd() | ConvertFrom-Json))
      
      # Throw error if there is no Identity field, which indicates this isn't a proper backup file
      If ($null -eq ((Get-Variable -Name $EV_Entity).Value[0].Identity)) {
        $null = (Set-Variable -Name $EV_Entity -Value $NULL)
        Throw ('Error')
      }
    }
    Catch {
      Write-Error -Message ($EV_Entity + '.txt could not be found, was empty or could not be parsed. ' + $EV_Entity + ' will not be restored.') -ErrorAction Continue
    }
    $ItemReader.Close()
  }

  If (!$KeepExisting) {
    $Confirm = Read-Host -Prompt 'WARNING: This will ERASE all existing dialplans/voice routes/policies etc prior to restoring from backup. Continue (Y/N)?'
    If ($Confirm -notmatch '^[Yy]$') {
      Write-Host -Object 'returning without making changes.'
      return
    }
    
    Write-Host -Object 'Erasing all existing dialplans/voice routes/policies etc.'

    Write-Verbose 'Erasing all tenant dialplans'
    $null = (Get-CsTenantDialPlan -ErrorAction SilentlyContinue | Remove-CsTenantDialPlan -ErrorAction SilentlyContinue)
    Write-Verbose 'Erasing all online voice routes'
    $null = (Get-CsOnlineVoiceRoute -ErrorAction SilentlyContinue | Remove-CsOnlineVoiceRoute -ErrorAction SilentlyContinue)
    Write-Verbose 'Erasing all online voice routing policies'
    $null = (Get-CsOnlineVoiceRoutingPolicy -ErrorAction SilentlyContinue | Remove-CsOnlineVoiceRoutingPolicy -ErrorAction SilentlyContinue)
    Write-Verbose 'Erasing all PSTN usages'
    $null = (Set-CsOnlinePstnUsage -Identity Global -Usage $NULL -ErrorAction SilentlyContinue)
    Write-Verbose 'Removing translation rules from PSTN gateways'
    $null = (Get-CsOnlinePSTNGateway -ErrorAction SilentlyContinue | Set-CsOnlinePSTNGateway -OutbundTeamsNumberTranslationRules $NULL -OutboundPstnNumberTranslationRules $NULL -ErrorAction SilentlyContinue)
    Write-Verbose 'Removing translation rules'
    $null = (Get-CsTeamsTranslationRule -ErrorAction SilentlyContinue | Remove-CsTeamsTranslationRule -ErrorAction SilentlyContinue)
  }

  # Rebuild tenant dialplans from backup
  Write-Host -Object 'Restoring tenant dialplans'

  ForEach ($Dialplan in $Dialplans) {
    Write-Verbose -Message "Restoring $($Dialplan.Identity) dialplan"
    $DPExists = (Get-CsTenantDialPlan -Identity $Dialplan.Identity -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Identity)

    $DPDetails = @{
      Identity = $Dialplan.Identity
      OptimizeDeviceDialing = $Dialplan.OptimizeDeviceDialing
      Description = $Dialplan.Description
    }
    
    # Only include the external access prefix if one is defined. MS throws an error if you pass a null/empty ExternalAccessPrefix
    If ($Dialplan.ExternalAccessPrefix) {
      $DPDetails.Add("ExternalAccessPrefix", $Dialplan.ExternalAccessPrefix)
    }

    If ($DPExists) {
      $null = (Set-CsTenantDialPlan @DPDetails)
    }
    Else {
      $null = (New-CsTenantDialPlan @DPDetails)
    }	

    # Create a new Object
    $NormRules = @()
    
    ForEach ($NormRule in $Dialplan.NormalizationRules) {		
      $NRDetails = @{
        Parent = $Dialplan.Identity
        Name = [regex]::Match($NormRule, '(?ms)Name=(.*?);').Groups[1].Value
        Pattern = [regex]::Match($NormRule, '(?ms)Pattern=(.*?);').Groups[1].Value
        Translation = [regex]::Match($NormRule, '(?ms)Translation=(.*?);').Groups[1].Value
        Description = [regex]::Match($NormRule, '(?ms)^Description=(.*?);').Groups[1].Value
        IsInternalExtension = [Convert]::ToBoolean([regex]::Match($NormRule, '(?ms)IsInternalExtension=(.*?)$').Groups[1].Value)
      }
      $NormRules += New-CsVoiceNormalizationRule @NRDetails -InMemory
    }
    $null = (Set-CsTenantDialPlan -Identity $Dialplan.Identity -NormalizationRules $NormRules)
  }

  # Rebuild PSTN usages from backup
  Write-Host -Object 'Restoring PSTN usages'

  ForEach ($PSTNUsage in $PSTNUsages.Usage) {
    Write-Verbose -Message "Restoring $PSTNUsage PSTN usage"
    $null = (Set-CsOnlinePstnUsage -Identity Global -Usage @{Add = $PSTNUsage} -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)
  }

  # Rebuild voice routes from backup
  Write-Host -Object 'Restoring voice routes'

  ForEach ($VoiceRoute in $VoiceRoutes) {
    Write-Verbose -Message "Restoring $($VoiceRoute.Identity) voice route"
    $VRExists = (Get-CsOnlineVoiceRoute -Identity $VoiceRoute.Identity -ErrorAction SilentlyContinue).Identity

    $VRDetails = @{
      Identity = $VoiceRoute.Identity
      NumberPattern = $VoiceRoute.NumberPattern
      Priority = $VoiceRoute.Priority
      OnlinePstnUsages = $VoiceRoute.OnlinePstnUsages
      OnlinePstnGatewayList = $VoiceRoute.OnlinePstnGatewayList
      Description = $VoiceRoute.Description
    }
    
    If ($VRExists) {
      $null = (Set-CsOnlineVoiceRoute @VRDetails)
    }
    Else {
      $null = (New-CsOnlineVoiceRoute @VRDetails)
    }
  }

  # Rebuild voice routing policies from backup
  Write-Host -Object 'Restoring voice routing policies'

  ForEach ($VoiceRoutingPolicy in $VoiceRoutingPolicies) {
    Write-Verbose -Message "Restoring $($VoiceRoutingPolicy.Identity) voice routing policy"
    $VPExists = (Get-CsOnlineVoiceRoutingPolicy -Identity $VoiceRoutingPolicy.Identity -ErrorAction SilentlyContinue).Identity

    $VPDetails = @{
      Identity = $VoiceRoutingPolicy.Identity
      OnlinePstnUsages = $VoiceRoutingPolicy.OnlinePstnUsages
      Description = $VoiceRoutingPolicy.Description
    }
    
    If ($VPExists) {
      $null = (Set-CsOnlineVoiceRoutingPolicy @VPDetails)
    }
    Else {
      $null = (New-CsOnlineVoiceRoutingPolicy @VPDetails)
    }
  }

  # Rebuild outbound translation rules from backup
  Write-Host -Object 'Restoring outbound translation rules'

  ForEach ($TranslationRule in $TranslationRules) {
    Write-Verbose -Message "Restoring $($TranslationRule.Identity) translation rule"
    $TRExists = (Get-CsTeamsTranslationRule -Identity $TranslationRule.Identity -ErrorAction SilentlyContinue).Identity
    
    $TRDetails = @{
      Identity = $TranslationRule.Identity
      Pattern = $TranslationRule.Pattern
      Translation = $TranslationRule.Translation
      Description = $TranslationRule.Description
    }

    If ($TRExists) {
      $null = (Set-CsTeamsTranslationRule @TRDetails)
    }
    Else {
      $null = (New-CsTeamsTranslationRule @TRDetails)
    }
  }

  # Re-add translation rules to PSTN gateways
  Write-Host -Object 'Re-adding translation rules to PSTN gateways'

  ForEach ($PSTNGateway in $PSTNGateways) {
    Write-Verbose -Message "Restoring translation rules to $($PSTNGateway.Identity)"
    $GWExists = (Get-CsOnlinePSTNGateway -Identity $PSTNGateway.Identity -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Identity)
    
    $GWDetails = @{
      Identity = $PSTNGateway.Identity
      OutbundTeamsNumberTranslationRules = $PSTNGateway.OutbundTeamsNumberTranslationRules #Sadly Outbund isn't a spelling mistake here. That's what the command uses.
      OutboundPstnNumberTranslationRules = $PSTNGateway.OutboundPstnNumberTranslationRules 
      InboundTeamsNumberTranslationRules = $PSTNGateway.InboundTeamsNumberTranslationRules
      InboundPstnNumberTranslationRules = $PSTNGateway.InboundPstnNumberTranslationRules
    }
    If ($GWExists) {
      $null = (Set-CsOnlinePSTNGateway @GWDetails)
    }
  }

  Write-Host -Object 'Finished!'

}

# Extended to do a full backup
# Replace with Lee Fords wonderful Backup script that also compares backups?
function Backup-TeamsTenant {
  <#
      .SYNOPSIS
      A script to automatically backup a Microsoft Teams Tenant configuration.
	
      .DESCRIPTION
      Automates the backup of Microsoft Teams.
	
      .PARAMETER OverrideAdminDomain
      OPTIONAL: The FQDN your Office365 tenant. Use if your admin account is not in the same domain as your tenant (ie. doesn't use a @tenantname.onmicrosoft.com address)

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
  #>

  [CmdletBinding(ConfirmImpact = 'None')]
  param
  (
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $OverrideAdminDomain
  )

  # Testing SkypeOnline Connection
  if (-not (Test-SkypeOnlineConnection)) {
    Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  $Filenames = '*.txt'

  If ((Get-PSSession | Where-Object -FilterScript {
          $_.ComputerName -like '*.online.lync.com'
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

  # Tenant Configuration
  $null = (Get-CsOnlineDialInConferencingBridge -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingBridge.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingLanguagesSupported -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingLanguagesSupported.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingServiceNumber -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingServiceNumber.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialinConferencingTenantConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialinConferencingTenantConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingTenantSettings -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingTenantSettings.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineLisCivicAddress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineLisCivicAddress.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineLisLocation -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineLisLocation.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsClientConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsClientConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestCallingConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestCallingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestMeetingConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestMeetingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestMessagingConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestMessagingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingBroadcastConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingBroadcastConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsUpgradeConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsUpgradeConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTenant.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantFederationConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTenantFederationConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantNetworkConfiguration -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTenantNetworkConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantPublicProvider -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTenantPublicProvider.txt" -Force -Encoding utf8)
  
  # Tenant Policies (except voice)
  $null = (Get-CsTeamsUpgradePolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsUpgradePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsAppPermissionPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsAppPermissionPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsAppSetupPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsAppSetupPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsCallParkPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsCallParkPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsChannelsPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsChannelsPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEducationAssignmentsAppPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEducationAssignmentsAppPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsFeedbackPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsFeedbackPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingBroadcastPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingBroadcastPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMessagingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMessagingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsNotificationAndFeedsPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsNotificationAndFeedsPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsTargetingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsTargetingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsVerticalPackagePolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsVerticalPackagePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsVideoInteropServicePolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsVideoInteropServicePolicy.txt" -Force -Encoding utf8)

  # Tenant Voice Configuration
  $null = (Get-CsTeamsTranslationRule -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsTranslationRule.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantDialPlan -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTenantDialPlan.txt" -Force -Encoding utf8)

  $null = (Get-CsOnlinePSTNGateway -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlinePSTNGateway.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceRoute -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceRoute.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlinePstnUsage -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlinePstnUsage.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceRoutingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceRoutingPolicy.txt" -Force -Encoding utf8)

  # Tenant Voice related Configuration and Policies
  $null = (Get-CsTeamsIPPhonePolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsIPPhonePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEmergencyCallingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEmergencyCallingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEmergencyCallRoutingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEmergencyCallRoutingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialinConferencingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialinConferencingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoicemailPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoicemailPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsCallingPolicy -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsCallingPolicy.txt" -Force -Encoding utf8)

  # Tenant Telephone Numbers
  $null = (Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumber.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberAvailableCount -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberAvailableCount.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberInventoryTypes -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberInventoryTypes.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberReservationsInformation -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberReservationsInformation.txt" -Force -Encoding utf8)

  # Resource Accounts, Call Queues and Auto Attendants
  $null = (Get-CsOnlineApplicationInstance -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineApplicationInstance.txt" -Force -Encoding utf8)
  $null = (Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsCallQueue.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendant -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendant.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantSupportedLanguage -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantSupportedLanguage.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantSupportedTimeZone -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantSupportedTimeZone.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantTenantInformation -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantTenantInformation.txt" -Force -Encoding utf8)

  # User Configuration
  $null = (Get-CsOnlineUser -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceUser -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUser -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUserInfo -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUserInfo.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUserState -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUserState.txt" -Force -Encoding utf8)


  $TenantName = (Get-CsTenant).Displayname
  $BackupFile = ('TeamsBackup_' + (Get-Date -Format yyyy-MM-dd) + " " + $TenantName + '.zip')
  $null = (Compress-Archive -Path $Filenames -DestinationPath $BackupFile -Force)
  $null = (Remove-Item -Path $Filenames -Force -Confirm:$false)

  Write-Host -Object ('Microsoft Teams configuration backed up to {0}' -f $BackupFile)

}
#endregion

#region *** Exported Functions ***
# Helper Function to find Assigned Admin Roles
function Get-AzureAdAssignedAdminRoles {
  <#
    .SYNOPSIS
    Queries Admin Roles assigned to an Object
    .DESCRIPTION
    Azure Active Directory Admin Roles assigned to an Object are returned
    Requires a Connection to AzureAd 
    .EXAMPLE
    Get-AzureAdAssignedAdminRoles user@domain.com
    Returns an Object for all Admin Roles assigned
    .INPUTS
    Identity in from of a UserPrincipalName (UPN)
    .OUTPUTS
    PS Object containing all Admin Roles assigned to this Object
    .NOTES
    Script Development information
    This was intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
    Based on the output of this script we could then run activate ohter functions, like License Assignments (if License Admin), etc.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="Enter the identity of the User to Query")]
    [Alias("UPN","UserPrincipalName","Username")]
    [string]$Identity
  )

  # Testing AzureAD Connection
  if (-not (Test-AzureADConnection)) {
    Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }
  
  #Querying Admin Rights of authenticated Administator
  $AssignedRoles = @()
  $Roles = Get-AzureADDirectoryRole
  FOREACH ($R in $Roles)
  {
    $Members = (Get-AzureADDirectoryRoleMember -ObjectId $R.ObjectId).UserprincipalName
    IF($Identity -in $Members)
    {
      #Builing list of Roles assigned to $AdminUPN
      $AssignedRoles += $R
    } 
      
  }

  #Output
  return $AssignedRoles
}

# Helper Function to create new Azure AD License Objects
function New-AzureAdLicenseObject {
  <#
      .SYNOPSIS
      Creates a new License Object based on existing License assigned
      .DESCRIPTION
      Helper function to create a new License Object
      To execute Teams Commands, a connection via SkypeOnline must be established.
      This connection must be valid (Available and Opened)
      .PARAMETER SkuId
      SkuId of the License to be added
      .PARAMETER RemoveSkuId
      SkuId of the License to be removed
      .EXAMPLE
      New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd
      Will create a license Object for the MCOEV license .
      .EXAMPLE
      New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd -RemoveSkuId 440eaaa8-b3e0-484b-a8be-62870b9ba70a
      Will create a license Object based on the existing users License
      Adding the MCOEV license, removing the MCOEV_VIRTUALUSER license.
      .NOTES
      This function currently only accepts ONE license to be added and optionally ONE license to be removed.
      Rework to support multiple assignements is to be evaluated.
  #>
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "SkuId of the license to Add")]
    [Alias('AddSkuId')]
    [string]$SkuId,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "SkuId of the license to Remove")]
    [string]$RemoveSkuId
  )

  # Testing AzureAD Connection
  if (-not (Test-AzureADConnection)) {
    Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeAndTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
  $AddLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
  
  foreach ($Sku in $SkuId) {
    $AddLicenseObj.SkuId += $Sku
  }  

  $newLicensesObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
  $newLicensesObj.AddLicenses = $AddLicenseObj

  if ($PSBoundParameters.ContainsKey('RemoveSkuId')) {
    foreach ($Sku in $RemoveSkuId) {
      $newLicensesObj.RemoveLicenses += $Sku
    }
  }

  return $newLicensesObj
}

# Helper functions to test and format strings
function Remove-StringSpecialCharacter {
  <#
.SYNOPSIS
  This function will remove the special character from a string.
.DESCRIPTION
  This function will remove the special character from a string.
  I'm using Unicode Regular Expressions with the following categories
  \p{L} : any kind of letter from any language.
  \p{Nd} : a digit zero through nine in any script except ideographic
  http://www.regular-expressions.info/unicode.html
  http://unicode.org/reports/tr18/
.PARAMETER String
  Specifies the String on which the special character will be removed
.PARAMETER SpecialCharacterToKeep
  Specifies the special character to keep in the output
.EXAMPLE
  Remove-StringSpecialCharacter -String "^&*@wow*(&(*&@"
  wow
.EXAMPLE
  Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"
  wow
.EXAMPLE
  Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"
  wow-_*
.NOTES
  Francois-Xavier Cat
  @lazywinadmin
  lazywinadmin.com
  github.com/lazywinadmin
#>
  [CmdletBinding()]
  param
  (
      [Parameter(ValueFromPipeline)]
      [ValidateNotNullOrEmpty()]
      [Alias('Text')]
      [System.String[]]$String,

      [Alias("Keep")]
      #[ValidateNotNullOrEmpty()]
      [String[]]$SpecialCharacterToKeep
  )
  PROCESS {
      try {
          IF ($PSBoundParameters["SpecialCharacterToKeep"]) {
              $Regex = "[^\p{L}\p{Nd}"
              Foreach ($Character in $SpecialCharacterToKeep) {
                  IF ($Character -eq "-") {
                      $Regex += "-"
                  }
                  else {
                      $Regex += [Regex]::Escape($Character)
                  }
                  #$Regex += "/$character"
              }

              $Regex += "]+"
          } #IF($PSBoundParameters["SpecialCharacterToKeep"])
          ELSE { $Regex = "[^\p{L}\p{Nd}]+" }

          FOREACH ($Str in $string) {
              Write-Verbose -Message "Original String: $Str"
              $Str -replace $regex, ""
          }
      }
      catch {
          $PSCmdlet.ThrowTerminatingError($_)
      }
  } #PROCESS
}

function Format-StringForUse {
  <#
    .SYNOPSIS
    Formats a string by removing special characters usually not allowed. 
    .DESCRIPTION
    Special Characters in strings usually lead to terminating erros.
    This function gets around that by formating the string properly.
    Use is limited, but can be used for UPNs and Display Names
    Adheres to Microsoft recommendation of special Characters
    .PARAMETER InputString
    Mandatory. The string to be reformatted
    .PARAMETER As
    Optional String. DisplayName or UserPrincipalName. Uses predefined special characters to remove
    Cannot be used together with -SpecialChars
    .PARAMETER SpecialChars
    Default, Optional String. Manually define which special characters to remove.
    If not specified, only the following characters are removed: ?()[]{}
    Cannot be used together with -As
    .PARAMETER Replacement
    Optional String. Manually replaces removed characters with this string.
  #>
  [CmdletBinding(DefaultParameterSetName = "Manual")]
  param(
      [Parameter(Mandatory, HelpMessage = "String to reformat")]
      [string]$InputString,

      [Parameter(HelpMessage = "Replacement character or string for each removed character")]
      [string]$Replacement  = "",

      [Parameter(ParameterSetName = "Specific")]
      [ValidateSet("UserPrincipalName","DisplayName")]
      [string]$As,

      [Parameter(ParameterSetName = "Manual")]
      [string]$SpecialChars = "?()[]{}"
  )

  begin {
    switch ($PsCmdlet.ParameterSetName) {
      "Specific" {
        switch ($As) {
          "UserPrincipalName" {
            $CharactersToRemove = '\%&*+/=?{}|<>();:,[]"'
            $CharactersToRemove += "'´"
          }
          "DisplayName" {$CharactersToRemove = '\%*+/=?{}|<>[]"'}
        }
      }
      "Manual" {$CharactersToRemove = $SpecialChars}
      Default {}
      }
  }

  PROCESS {

    $rePattern = ($CharactersToRemove.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join "|"

    $InputString -replace $rePattern,$Replacement
  }
}

# SkuID and Partnumber are useful to look up dynamically, but would need a data source...
# Helper functions as a static alternative :)
function Get-SkuIDfromSkuPartNumber {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuPartNumber
  )

  switch($SkuPartNumber) {
      "MCOMEETADV"                              {$SkuID = "0c266dff-15dd-4b49-8397-2bb16070ed52"; break} 
      "AAD_BASIC"                               {$SkuID = "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7"; break} 
      "AAD_PREMIUM"                             {$SkuID = "078d2b04-f1bd-4111-bbd4-b4b1b354cef4"; break} 
      "AAD_PREMIUM_P2"                          {$SkuID = "84a661c4-e949-4bd2-a560-ed7766fcaf2b"; break} 
      "RIGHTSMANAGEMENT"                        {$SkuID = "c52ea49f-fe5d-4e95-93ba-1de91d380f89"; break} 
      "DYN365_ENTERPRISE_PLAN1"                 {$SkuID = "ea126fc5-a19e-42e2-a731-da9d437bffcf"; break} 
      "DYN365_ENTERPRISE_CUSTOMER_SERVICE"      {$SkuID = "749742bf-0d37-4158-a120-33567104deeb"; break} 
      "DYN365_FINANCIALS_BUSINESS_SKU"          {$SkuID = "cc13a803-544e-4464-b4e4-6d6169a138fa"; break} 
      "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE" {$SkuID = "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc"; break} 
      "DYN365_ENTERPRISE_SALES"                 {$SkuID = "1e1a282c-9c54-43a2-9310-98ef728faace"; break} 
      "DYN365_ENTERPRISE_TEAM_MEMBERS"          {$SkuID = "8e7a3d30-d97d-43ab-837c-d7701cef83dc"; break} 
      "Dynamics_365_for_Operations"             {$SkuID = "ccba3cfe-71ef-423a-bd87-b6df3dce59a9"; break} 
      "EMS"                                     {$SkuID = "efccb6f7-5641-4e0e-bd10-b4976e1bf68e"; break} 
      "EMSPREMIUM"                              {$SkuID = "b05e124f-c7cc-45a0-a6aa-8cf78c946968"; break} 
      "EXCHANGESTANDARD"                        {$SkuID = "4b9405b0-7788-4568-add1-99614e613b69"; break} 
      "EXCHANGEENTERPRISE"                      {$SkuID = "19ec0d23-8335-4cbd-94ac-6050e30712fa"; break} 
      "EXCHANGEARCHIVE_ADDON"                   {$SkuID = "ee02fd1b-340e-4a4b-b355-4a514e4c8943"; break} 
      "EXCHANGEARCHIVE"                         {$SkuID = "90b5e015-709a-4b8b-b08e-3200f994494c"; break} 
      "EXCHANGEESSENTIALS"                      {$SkuID = "7fc0182e-d107-4556-8329-7caaa511197b"; break} 
      "EXCHANGE_S_ESSENTIALS"                   {$SkuID = "e8f81a67-bd96-4074-b108-cf193eb9433b"; break} 
      "EXCHANGEDESKLESS"                        {$SkuID = "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82"; break} 
      "EXCHANGETELCO"                           {$SkuID = "cb0a98a8-11bc-494c-83d9-c1b1ac65327e"; break} 
      "INTUNE_A"                                {$SkuID = "061f9ace-7d42-4136-88ac-31dc755f143f"; break} 
      "M365EDU_A1"                              {$SkuID = "b17653a4-2443-4e8c-a550-18249dda78bb"; break} 
      "M365EDU_A3_FACULTY"                      {$SkuID = "4b590615-0888-425a-a965-b3bf7789848d"; break} 
      "M365EDU_A3_STUDENT"                      {$SkuID = "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121"; break} 
      "M365EDU_A5_FACULTY"                      {$SkuID = "e97c048c-37a4-45fb-ab50-922fbf07a370"; break} 
      "M365EDU_A5_STUDENT"                      {$SkuID = "46c119d4-0379-4a9d-85e4-97c66d3f909e"; break} 
      "SPB"                                     {$SkuID = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"; break} 
      "SPE_E3"                                  {$SkuID = "05e9a617-0261-4cee-bb44-138d3ef5d965"; break} 
      "SPE_E3_USGOV_DOD"                        {$SkuID = "d61d61cc-f992-433f-a577-5bd016037eeb"; break} 
      "SPE_E3_USGOV_GCCHIGH"                    {$SkuID = "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658"; break} 
      "SPE_E5"                                  {$SkuID = "06ebc4ee-1bb5-47dd-8120-11324bc54e06"; break} 
      "INFORMATION_PROTECTION_COMPLIANCE"       {$SkuID = "184efa21-98c3-4e5d-95ab-d07053a96e67"; break} 
      "IDENTITY_THREAT_PROTECTION"              {$SkuID = "26124093-3d78-432b-b5dc-48bf992543d5"; break} 
      "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"   {$SkuID = "44ac31e7-2999-4304-ad94-c948886741d4"; break} 
      "SPE_F1"                                  {$SkuID = "66b55226-6b4f-492c-910c-a3b7a3c9d993"; break} 
      "WIN_DEF_ATP"                             {$SkuID = "111046dd-295b-4d6d-9724-d52ac90bd1f2"; break} 
      "CRMSTANDARD"                             {$SkuID = "d17b27af-3f49-4822-99f9-56a661538792"; break} 
      "CRMPLAN2"                                {$SkuID = "906af65a-2970-46d5-9b58-4e9aa50f0657"; break} 
      "IT_ACADEMY_AD"                           {$SkuID = "ba9a34de-4489-469d-879c-0f0f145321cd"; break}
      "ENTERPRISEPREMIUM_FACULTY"               {$SkuID = "a4585165-0533-458a-97e3-c400570268c4"; break}
      "ENTERPRISEPREMIUM_STUDENT"               {$SkuID = "ee656612-49fa-43e5-b67e-cb1fdf7699df"; break}
      "EQUIVIO_ANALYTICS"                       {$SkuID = "1b1b1f7a-8355-43b6-829f-336cfccb744c"; break}
      "ATP_ENTERPRISE"                          {$SkuID = "4ef96642-f096-40de-a3e9-d83fb2f90211"; break}
      "O365_BUSINESS"                           {$SkuID = "cdd28e44-67e3-425e-be4c-737fab2899d3"; break}
      "SMB_BUSINESS"                            {$SkuID = "b214fe43-f5a3-4703-beeb-fa97188220fc"; break}
      "O365_BUSINESS_ESSENTIALS"                {$SkuID = "3b555118-da6a-4418-894f-7df1e2096870"; break}
      "SMB_BUSINESS_ESSENTIALS"                 {$SkuID = "dab7782a-93b1-4074-8bb1-0e61318bea0b"; break}
      "O365_BUSINESS_PREMIUM"                   {$SkuID = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"; break}
      "SMB_BUSINESS_PREMIUM"                    {$SkuID = "ac5cef5d-921b-4f97-9ef3-c99076e5470f"; break}
      "STANDARDPACK"                            {$SkuID = "18181a46-0d4e-45cd-891e-60aabd171b4e"; break}
      "STANDARDWOFFPACK"                        {$SkuID = "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e"; break}
      "ENTERPRISEPACK"                          {$SkuID = "6fd2c87f-b296-42f0-b197-1e91e994b900"; break}
      "DEVELOPERPACK"                           {$SkuID = "189a915c-fe4f-4ffa-bde4-85b9628d07a0"; break}
      "ENTERPRISEPACK_USGOV_DOD"                {$SkuID = "b107e5a3-3e60-4c0d-a184-a7e4395eb44c"; break}
      "ENTERPRISEPACK_USGOV_GCCHIGH"            {$SkuID = "aea38a85-9bd5-4981-aa00-616b411205bf"; break}
      "ENTERPRISEWITHSCAL"                      {$SkuID = "1392051d-0cb9-4b7a-88d5-621fee5e8711"; break}
      "ENTERPRISEPREMIUM"                       {$SkuID = "c7df2760-2c81-4ef7-b578-5b5392b571df"; break}
      "ENTERPRISEPREMIUM_NOPSTNCONF"            {$SkuID = "26d45bd9-adf1-46cd-a9e1-51e9a5524128"; break}
      "DESKLESSPACK"                            {$SkuID = "4b585984-651b-448a-9e53-3b10f069cf7f"; break}
      "MIDSIZEPACK"                             {$SkuID = "04a7fb0d-32e0-4241-b4f5-3f7618cd1162"; break}
      "OFFICESUBSCRIPTION"                      {$SkuID = "c2273bd0-dff7-4215-9ef5-2c7bcfb06425"; break}
      "LITEPACK"                                {$SkuID = "bd09678e-b83c-4d3f-aaba-3dad4abd128b"; break}
      "LITEPACK_P2"                             {$SkuID = "fc14ec4a-4169-49a4-a51e-2c852931814b"; break}
      "WACONEDRIVESTANDARD"                     {$SkuID = "e6778190-713e-4e4f-9119-8b8238de25df"; break}
      "WACONEDRIVEENTERPRISE"                   {$SkuID = "ed01faf2-1d88-4947-ae91-45ca18703a96"; break}
      "POWERAPPS_PER_USER"                      {$SkuID = "b30411f5-fea1-4a59-9ad9-3db7c7ead579"; break}
      "POWER_BI_ADDON"                          {$SkuID = "45bc2c81-6072-436a-9b0b-3b12eefbc402"; break}
      "POWER_BI_PRO"                            {$SkuID = "f8a1db68-be16-40ed-86d5-cb42ce701560"; break}
      "PROJECTCLIENT"                           {$SkuID = "a10d5e58-74da-4312-95c8-76be4e5b75a0"; break}
      "PROJECTESSENTIALS"                       {$SkuID = "776df282-9fc0-4862-99e2-70e561b9909e"; break}
      "PROJECTPREMIUM"                          {$SkuID = "09015f9f-377f-4538-bbb5-f75ceb09358a"; break}
      "PROJECTONLINE_PLAN_1"                    {$SkuID = "2db84718-652c-47a7-860c-f10d8abbdae3"; break}
      "PROJECTPROFESSIONAL"                     {$SkuID = "53818b1b-4a27-454b-8896-0dba576410e6"; break}
      "PROJECTONLINE_PLAN_2"                    {$SkuID = "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c"; break}
      "SHAREPOINTSTANDARD"                      {$SkuID = "1fc08a02-8b3d-43b9-831e-f76859e04e1a"; break}
      "SHAREPOINTENTERPRISE"                    {$SkuID = "a9732ec9-17d9-494c-a51c-d6b45b384dcb"; break}
      "PHONESYSTEM_VIRTUALUSER"                 {$SkuID = "440eaaa8-b3e0-484b-a8be-62870b9ba70a"; break}
      "MCOEV"                                   {$SkuID = "e43b5b99-8dfb-405f-9987-dc307f34bcbd"; break}
      "MCOIMP"                                  {$SkuID = "b8b749f8-a4ef-4887-9539-c95b1eaa5db7"; break}
      "MCOSTANDARD"                             {$SkuID = "d42c793f-6c78-4f43-92ca-e8f6a02b035f"; break}
      "MCOPSTN2"                                {$SkuID = "d3b4fe1f-9992-4930-8acb-ca6ec609365e"; break}
      "MCOPSTN1"                                {$SkuID = "0dab259f-bf13-4952-b7f8-7db8f131b28d"; break}
      "MCOPSTN5"                                {$SkuID = "54a152dc-90de-4996-93d2-bc47e670fc06"; break}
      "VISIOONLINE_PLAN1"                       {$SkuID = "4b244418-9658-4451-a2b8-b5e2b364e9bd"; break}
      "VISIOCLIENT"                             {$SkuID = "c5928f49-12ba-48f7-ada3-0d743a3601d5"; break}
      "WIN10_PRO_ENT_SUB"                       {$SkuID = "cb10e6cd-9da4-4992-867b-67546b1db821"; break}
      "WIN10_VDA_E5"                            {$SkuID = "488ba24a-39a9-4473-8ee5-19291e71b002"; break}
  }
  return $SkuID
}

function Get-SkuPartNumberfromSkuID {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuID,
    
    [Parameter(Mandatory = $false, HelpMessage = "Desired Output, SkuPartNumber or ProductName; Default: SkuPartNumber")]
    [ValidateSet("SkuPartNumber","ProductName")]
    [String]$Output = "SkuPartNumber"
  )

  switch ($SkuID) {
      "0c266dff-15dd-4b49-8397-2bb16070ed52" {$SkuPartNumber = "MCOMEETADV"; $ProductName = "AUDIO CONFERENCING"; break}
      "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7" {$SkuPartNumber = "AAD_BASIC"; $ProductName = "AZURE ACTIVE DIRECTORY BASIC"; break}
      "078d2b04-f1bd-4111-bbd4-b4b1b354cef4" {$SkuPartNumber = "AAD_PREMIUM"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P1"; break}
      "84a661c4-e949-4bd2-a560-ed7766fcaf2b" {$SkuPartNumber = "AAD_PREMIUM_P2"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P2"; break}
      "c52ea49f-fe5d-4e95-93ba-1de91d380f89" {$SkuPartNumber = "RIGHTSMANAGEMENT"; $ProductName = "AZURE INFORMATION PROTECTION PLAN 1"; break}
      "ea126fc5-a19e-42e2-a731-da9d437bffcf" {$SkuPartNumber = "DYN365_ENTERPRISE_PLAN1"; $ProductName = "DYNAMICS 365 CUSTOMER ENGAGEMENT PLAN ENTERPRISE EDITION"; break}
      "749742bf-0d37-4158-a120-33567104deeb" {$SkuPartNumber = "DYN365_ENTERPRISE_CUSTOMER_SERVICE"; $ProductName = "DYNAMICS 365 FOR CUSTOMER SERVICE ENTERPRISE EDITION"; break}
      "cc13a803-544e-4464-b4e4-6d6169a138fa" {$SkuPartNumber = "DYN365_FINANCIALS_BUSINESS_SKU"; $ProductName = "DYNAMICS 365 FOR FINANCIALS BUSINESS EDITION"; break}
      "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc" {$SkuPartNumber = "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE"; $ProductName = "DYNAMICS 365 FOR SALES AND CUSTOMER SERVICE ENTERPRISE EDITION"; break}
      "1e1a282c-9c54-43a2-9310-98ef728faace" {$SkuPartNumber = "DYN365_ENTERPRISE_SALES"; $ProductName = "DYNAMICS 365 FOR SALES ENTERPRISE EDITION"; break}
      "8e7a3d30-d97d-43ab-837c-d7701cef83dc" {$SkuPartNumber = "DYN365_ENTERPRISE_TEAM_MEMBERS"; $ProductName = "DYNAMICS 365 FOR TEAM MEMBERS ENTERPRISE EDITION"; break}
      "ccba3cfe-71ef-423a-bd87-b6df3dce59a9" {$SkuPartNumber = "Dynamics_365_for_Operations"; $ProductName = "DYNAMICS 365 UNF OPS PLAN ENT EDITION"; break}
      "efccb6f7-5641-4e0e-bd10-b4976e1bf68e" {$SkuPartNumber = "EMS"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E3"; break}
      "b05e124f-c7cc-45a0-a6aa-8cf78c946968" {$SkuPartNumber = "EMSPREMIUM"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E5"; break}
      "4b9405b0-7788-4568-add1-99614e613b69" {$SkuPartNumber = "EXCHANGESTANDARD"; $ProductName = "EXCHANGE ONLINE (PLAN 1)"; break}
      "19ec0d23-8335-4cbd-94ac-6050e30712fa" {$SkuPartNumber = "EXCHANGEENTERPRISE"; $ProductName = "EXCHANGE ONLINE (PLAN 2)"; break}
      "ee02fd1b-340e-4a4b-b355-4a514e4c8943" {$SkuPartNumber = "EXCHANGEARCHIVE_ADDON"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE ONLINE"; break}
      "90b5e015-709a-4b8b-b08e-3200f994494c" {$SkuPartNumber = "EXCHANGEARCHIVE"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE SERVER"; break}
      "7fc0182e-d107-4556-8329-7caaa511197b" {$SkuPartNumber = "EXCHANGEESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break}
      "e8f81a67-bd96-4074-b108-cf193eb9433b" {$SkuPartNumber = "EXCHANGE_S_ESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break}
      "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82" {$SkuPartNumber = "EXCHANGEDESKLESS"; $ProductName = "EXCHANGE ONLINE KIOSK"; break}
      "cb0a98a8-11bc-494c-83d9-c1b1ac65327e" {$SkuPartNumber = "EXCHANGETELCO"; $ProductName = "EXCHANGE ONLINE POP"; break}
      "061f9ace-7d42-4136-88ac-31dc755f143f" {$SkuPartNumber = "INTUNE_A"; $ProductName = "INTUNE"; break}
      "b17653a4-2443-4e8c-a550-18249dda78bb" {$SkuPartNumber = "M365EDU_A1"; $ProductName = "Microsoft 365 A1"; break}
      "4b590615-0888-425a-a965-b3bf7789848d" {$SkuPartNumber = "M365EDU_A3_FACULTY"; $ProductName = "Microsoft 365 A3 for faculty"; break}
      "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121" {$SkuPartNumber = "M365EDU_A3_STUDENT"; $ProductName = "Microsoft 365 A3 for students"; break}
      "e97c048c-37a4-45fb-ab50-922fbf07a370" {$SkuPartNumber = "M365EDU_A5_FACULTY"; $ProductName = "Microsoft 365 A5 for faculty"; break}
      "46c119d4-0379-4a9d-85e4-97c66d3f909e" {$SkuPartNumber = "M365EDU_A5_STUDENT"; $ProductName = "Microsoft 365 A5 for students"; break}
      "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" {$SkuPartNumber = "SPB"; $ProductName = "MICROSOFT 365 BUSINESS"; break}
      "05e9a617-0261-4cee-bb44-138d3ef5d965" {$SkuPartNumber = "SPE_E3"; $ProductName = "MICROSOFT 365 E3"; break}
      "d61d61cc-f992-433f-a577-5bd016037eeb" {$SkuPartNumber = "SPE_E3_USGOV_DOD"; $ProductName = "Microsoft 365 E3_USGOV_DOD"; break}
      "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658" {$SkuPartNumber = "SPE_E3_USGOV_GCCHIGH"; $ProductName = "Microsoft 365 E3_USGOV_GCCHIGH"; break}
      "06ebc4ee-1bb5-47dd-8120-11324bc54e06" {$SkuPartNumber = "SPE_E5"; $ProductName = "Microsoft 365 E5"; break}
      "184efa21-98c3-4e5d-95ab-d07053a96e67" {$SkuPartNumber = "INFORMATION_PROTECTION_COMPLIANCE"; $ProductName = "Microsoft 365 E5 Compliance"; break}
      "26124093-3d78-432b-b5dc-48bf992543d5" {$SkuPartNumber = "IDENTITY_THREAT_PROTECTION"; $ProductName = "Microsoft 365 E5 Security"; break}
      "44ac31e7-2999-4304-ad94-c948886741d4" {$SkuPartNumber = "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"; $ProductName = "Microsoft 365 E5 Security for EMS E5"; break}
      "66b55226-6b4f-492c-910c-a3b7a3c9d993" {$SkuPartNumber = "SPE_F1"; $ProductName = "Microsoft 365 F1"; break}
      "111046dd-295b-4d6d-9724-d52ac90bd1f2" {$SkuPartNumber = "WIN_DEF_ATP"; $ProductName = "Microsoft Defender Advanced Threat Protection"; break}
      "d17b27af-3f49-4822-99f9-56a661538792" {$SkuPartNumber = "CRMSTANDARD"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE"; break}
      "906af65a-2970-46d5-9b58-4e9aa50f0657" {$SkuPartNumber = "CRMPLAN2"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE BASIC"; break}
      "ba9a34de-4489-469d-879c-0f0f145321cd" {$SkuPartNumber = "IT_ACADEMY_AD"; $ProductName = "MS IMAGINE ACADEMY"; break}
      "a4585165-0533-458a-97e3-c400570268c4" {$SkuPartNumber = "ENTERPRISEPREMIUM_FACULTY"; $ProductName = "Office 365 A5 for faculty"; break}
      "ee656612-49fa-43e5-b67e-cb1fdf7699df" {$SkuPartNumber = "ENTERPRISEPREMIUM_STUDENT"; $ProductName = "Office 365 A5 for students"; break}
      "1b1b1f7a-8355-43b6-829f-336cfccb744c" {$SkuPartNumber = "EQUIVIO_ANALYTICS"; $ProductName = "Office 365 Advanced Compliance"; break}
      "4ef96642-f096-40de-a3e9-d83fb2f90211" {$SkuPartNumber = "ATP_ENTERPRISE"; $ProductName = "Office 365 Advanced Threat Protection (Plan 1)"; break}
      "cdd28e44-67e3-425e-be4c-737fab2899d3" {$SkuPartNumber = "O365_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break}
      "b214fe43-f5a3-4703-beeb-fa97188220fc" {$SkuPartNumber = "SMB_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break}
      "3b555118-da6a-4418-894f-7df1e2096870" {$SkuPartNumber = "O365_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break}
      "dab7782a-93b1-4074-8bb1-0e61318bea0b" {$SkuPartNumber = "SMB_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break}
      "f245ecc8-75af-4f8e-b61f-27d8114de5f3" {$SkuPartNumber = "O365_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break}
      "ac5cef5d-921b-4f97-9ef3-c99076e5470f" {$SkuPartNumber = "SMB_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break}
      "18181a46-0d4e-45cd-891e-60aabd171b4e" {$SkuPartNumber = "STANDARDPACK"; $ProductName = "OFFICE 365 E1"; break}
      "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e" {$SkuPartNumber = "STANDARDWOFFPACK"; $ProductName = "OFFICE 365 E2"; break}
      "6fd2c87f-b296-42f0-b197-1e91e994b900" {$SkuPartNumber = "ENTERPRISEPACK"; $ProductName = "OFFICE 365 E3"; break}
      "189a915c-fe4f-4ffa-bde4-85b9628d07a0" {$SkuPartNumber = "DEVELOPERPACK"; $ProductName = "OFFICE 365 E3 DEVELOPER"; break}
      "b107e5a3-3e60-4c0d-a184-a7e4395eb44c" {$SkuPartNumber = "ENTERPRISEPACK_USGOV_DOD"; $ProductName = "Office 365 E3_USGOV_DOD"; break}
      "aea38a85-9bd5-4981-aa00-616b411205bf" {$SkuPartNumber = "ENTERPRISEPACK_USGOV_GCCHIGH"; $ProductName = "Office 365 E3_USGOV_GCCHIGH"; break}
      "1392051d-0cb9-4b7a-88d5-621fee5e8711" {$SkuPartNumber = "ENTERPRISEWITHSCAL"; $ProductName = "OFFICE 365 E4"; break}
      "c7df2760-2c81-4ef7-b578-5b5392b571df" {$SkuPartNumber = "ENTERPRISEPREMIUM"; $ProductName = "OFFICE 365 E5"; break}
      "26d45bd9-adf1-46cd-a9e1-51e9a5524128" {$SkuPartNumber = "ENTERPRISEPREMIUM_NOPSTNCONF"; $ProductName = "OFFICE 365 E5 WITHOUT AUDIO CONFERENCING"; break}
      "4b585984-651b-448a-9e53-3b10f069cf7f" {$SkuPartNumber = "DESKLESSPACK"; $ProductName = "OFFICE 365 F1"; break}
      "04a7fb0d-32e0-4241-b4f5-3f7618cd1162" {$SkuPartNumber = "MIDSIZEPACK"; $ProductName = "OFFICE 365 MIDSIZE BUSINESS"; break}
      "c2273bd0-dff7-4215-9ef5-2c7bcfb06425" {$SkuPartNumber = "OFFICESUBSCRIPTION"; $ProductName = "OFFICE 365 PROPLUS"; break}
      "bd09678e-b83c-4d3f-aaba-3dad4abd128b" {$SkuPartNumber = "LITEPACK"; $ProductName = "OFFICE 365 SMALL BUSINESS"; break}
      "fc14ec4a-4169-49a4-a51e-2c852931814b" {$SkuPartNumber = "LITEPACK_P2"; $ProductName = "OFFICE 365 SMALL BUSINESS PREMIUM"; break}
      "e6778190-713e-4e4f-9119-8b8238de25df" {$SkuPartNumber = "WACONEDRIVESTANDARD"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 1)"; break}
      "ed01faf2-1d88-4947-ae91-45ca18703a96" {$SkuPartNumber = "WACONEDRIVEENTERPRISE"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 2)"; break}
      "b30411f5-fea1-4a59-9ad9-3db7c7ead579" {$SkuPartNumber = "POWERAPPS_PER_USER"; $ProductName = "POWER APPS PER USER PLAN"; break}
      "45bc2c81-6072-436a-9b0b-3b12eefbc402" {$SkuPartNumber = "POWER_BI_ADDON"; $ProductName = "POWER BI FOR OFFICE 365 ADD-ON"; break}
      "f8a1db68-be16-40ed-86d5-cb42ce701560" {$SkuPartNumber = "POWER_BI_PRO"; $ProductName = "POWER BI PRO"; break}
      "a10d5e58-74da-4312-95c8-76be4e5b75a0" {$SkuPartNumber = "PROJECTCLIENT"; $ProductName = "PROJECT FOR OFFICE 365"; break}
      "776df282-9fc0-4862-99e2-70e561b9909e" {$SkuPartNumber = "PROJECTESSENTIALS"; $ProductName = "PROJECT ONLINE ESSENTIALS"; break}
      "09015f9f-377f-4538-bbb5-f75ceb09358a" {$SkuPartNumber = "PROJECTPREMIUM"; $ProductName = "PROJECT ONLINE PREMIUM"; break}
      "2db84718-652c-47a7-860c-f10d8abbdae3" {$SkuPartNumber = "PROJECTONLINE_PLAN_1"; $ProductName = "PROJECT ONLINE PREMIUM WITHOUT PROJECT CLIENT"; break}
      "53818b1b-4a27-454b-8896-0dba576410e6" {$SkuPartNumber = "PROJECTPROFESSIONAL"; $ProductName = "PROJECT ONLINE PROFESSIONAL"; break}
      "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c" {$SkuPartNumber = "PROJECTONLINE_PLAN_2"; $ProductName = "PROJECT ONLINE WITH PROJECT FOR OFFICE 365"; break}
      "1fc08a02-8b3d-43b9-831e-f76859e04e1a" {$SkuPartNumber = "SHAREPOINTSTANDARD"; $ProductName = "SHAREPOINT ONLINE (PLAN 1)"; break}
      "a9732ec9-17d9-494c-a51c-d6b45b384dcb" {$SkuPartNumber = "SHAREPOINTENTERPRISE"; $ProductName = "SHAREPOINT ONLINE (PLAN 2)"; break}
      "440eaaa8-b3e0-484b-a8be-62870b9ba70a" {$SkuPartNumber = "PHONESYSTEM_VIRTUALUSER"; $ProductName = "Phone System - Virtual User License"; break}
      "e43b5b99-8dfb-405f-9987-dc307f34bcbd" {$SkuPartNumber = "MCOEV"; $ProductName = "SKYPE FOR BUSINESS CLOUD PBX"; break}
      "b8b749f8-a4ef-4887-9539-c95b1eaa5db7" {$SkuPartNumber = "MCOIMP"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 1)"; break}
      "d42c793f-6c78-4f43-92ca-e8f6a02b035f" {$SkuPartNumber = "MCOSTANDARD"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 2)"; break}
      "d3b4fe1f-9992-4930-8acb-ca6ec609365e" {$SkuPartNumber = "MCOPSTN2"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC AND INTERNATIONAL CALLING"; break}
      "0dab259f-bf13-4952-b7f8-7db8f131b28d" {$SkuPartNumber = "MCOPSTN1"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING"; break}
      "54a152dc-90de-4996-93d2-bc47e670fc06" {$SkuPartNumber = "MCOPSTN5"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"; break}
      "4b244418-9658-4451-a2b8-b5e2b364e9bd" {$SkuPartNumber = "VISIOONLINE_PLAN1"; $ProductName = "VISIO ONLINE PLAN 1"; break}
      "c5928f49-12ba-48f7-ada3-0d743a3601d5" {$SkuPartNumber = "VISIOCLIENT"; $ProductName = "VISIO Online Plan 2"; break}
      "cb10e6cd-9da4-4992-867b-67546b1db821" {$SkuPartNumber = "WIN10_PRO_ENT_SUB"; $ProductName = "WINDOWS 10 ENTERPRISE E3"; break}
      "488ba24a-39a9-4473-8ee5-19291e71b002" {$SkuPartNumber = "WIN10_VDA_E5"; $ProductName = "Windows 10 Enterprise E5"; break}
    } # End Switch statement
    
    switch($Output) {
      "SkuPartNumber" {return $SkuPartNumber}
      "ProductName"   {return $ProductName}
    }   
}
#endregion *** Exported Functions ***


#region *** Non-Exported Helper Functions ***
function GetActionOutputObject2 {
  <#
      .SYNOPSIS
      Tests whether a valid PS Session exists for SkypeOnline (Teams)
      .DESCRIPTION
      Helper function for Output with 2 Parameters
      .PARAMETER Name
      Name of account being modified
      .PARAMETER Result
      Result of action being performed
  #>
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of account being modified")]
    [string]$Name,

    [Parameter(Mandatory = $true, HelpMessage = "Result of action being performed")]
    [string]$Result
  )
        
  $outputReturn = [PSCustomObject][ordered]@{
    User = $Name
    Result = $Result
  }

  return $outputReturn
} 

function GetActionOutputObject3 {
  <#
      .SYNOPSIS
      Tests whether a valid PS Session exists for SkypeOnline (Teams)
      .DESCRIPTION
      Helper function for Output with 3 Parameters
      .PARAMETER Name
      Name of account being modified
      .PARAMETER Property
      Object/property that is being modified
      .PARAMETER Result
      Result of action being performed
  #>
  param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of account being modified")]
    [string]$Name,

    [Parameter(Mandatory = $true, HelpMessage = "Object/property that is being modified")]
    [string]$Property,

    [Parameter(Mandatory = $true, HelpMessage = "Result of action being performed")]
    [string]$Result
  )
        
  $outputReturn = [PSCustomObject][ordered]@{
    User = $Name
    Property = $Property
    Result = $Result
  }

  return $outputReturn
}

function ProcessLicense {
  <#
      .SYNOPSIS
      Processes one License against a user account.
      .DESCRIPTION
      Helper function for Add-TeamsUserLicense
      Teams services are available through assignment of different types of licenses.
      This command allows assigning one Skype related Office 365 licenses to a user account.
      .PARAMETER UserID
      The sign-in address or User Principal Name of the user account to modify.
      .PARAMETER LicenseSkuID
      The SkuID for the License to assign.
      .PARAMETER LicenseName
      A friendly Name of the License/Task for feedback.
      .PARAMETER ReplaceLicense
      The SkuID for the License to replace (Resource Accounts only).
      .NOTES
      Uses Microsoft List for Licenses in SWITCH statement, update periodically or switch to lookup from DB(CSV or XLSX)
      https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
  #>
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$UserID,

    [Parameter(Mandatory = $true, HelpMessage = "SkuID of the License")]
    [AllowEmptyString()]
    [string]$LicenseSkuID,

    [Parameter(Mandatory = $true, HelpMessage = "License name")]
    [string]$LicenseName,

    [Parameter(Mandatory = $false, HelpMessage = "SkuID of the License to be replaced")]
    [string]$ReplaceLicense
    
  )
  
  # Query currently assigned Licenses (SkuID) for User ($UserID)
  $ObjectId = (Get-AzureADUserFromUPN $UserID).ObjectId
  $UserLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ObjectId).SkuId
  
 
  # Checking if the Tenant has a License of that SkuID
  if ($LicenseSkuID -ne "") {
    # Checking whether the User already has this license assigned
    if ($UserLicenses -notcontains $LicenseSkuID) {
      # Trying to assign License, SUCCESS if so, ERROR if not.
      try {
        #NOTE: Backward Compatibility (Set-MsolUserLicense) - Old method, requires Microsoft Azure AD (v1) Connection (Connect-MsolService) which we want to avoid because of MFA!
        #Set-MsolUserLicense -UserPrincipalName $ID -AddLicenses $LicenseSkuID -ErrorAction STOP
        if ($PSBoundParameters.ContainsKey('ReplaceLicense')) {
          Write-Warning -Message "Replace is in testing and currently non-operational. Parameter is ignored"
          $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
          #$license = New-AzureAdLicenseObject -SkuId $LicenseSkuID -RemoveSkuId $ReplaceLicense
        }
        else {
          $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
        }
        Set-AzureADUserLicense -ObjectId $UserID -AssignedLicenses $license -ErrorAction STOP
        $Result = GetActionOutputObject2 -Name $UserID -Result "SUCCESS: $LicenseName assigned"
      }
      catch {
        #$Result = GetActionOutputObject2 -Name $UserID -Result "ERROR: Unable to assign $LicenseName`: $_"
        # get error record
        [Management.Automation.ErrorRecord]$e = $_

        # retrieve Info about runtime error
        $Result = [PSCustomObject]@{
          Exception = $e.Exception.Message
          Reason    = $e.CategoryInfo.Reason
          Target    = $e.CategoryInfo.TargetName
          Script    = $e.InvocationInfo.ScriptName
          Line      = $e.InvocationInfo.ScriptLineNumber
          Column    = $e.InvocationInfo.OffsetInLine
        }
    
        # output Info. Post-process collected info, and log info (optional)
      }
    }
    else {
      $Result = GetActionOutputObject2 -Name $UserID -Result "INFO: User already has '$LicenseName' assigned"
    }
  }
  else {
    $Result = GetActionOutputObject2 -Name $UserID -Result "WARNING: License '$LicenseName' not found in tenant"
  }
  
  RETURN $Result
}

function GetApplicationTypeFromAppId ($CsAppId) {
  # Translates a given AppId into a friendly ApplicationType (Name)
  switch ($CsAppId) {
      "11cd3e2e-fccb-42ad-ad00-878b93575e07"  { $CsApplicationType = "CallQueue"}
      "ce933385-9390-45d1-9512-c8d228074e07"  {$CsApplicationType = "AutoAttendant"}
      Default {}
  }
  return $CsApplicationType
}
function GetAppIdfromApplicationType ($CsApplicationType) {
  # Translates a given friendly ApplicationType (Name) into an AppId used by MS commands
  switch ($CsApplicationType) {
      "CallQueue"     { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07"}
      "CQ"            { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07"}
      "AutoAttendant" { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07"}
      "AA"            { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07"}
      Default {}
  }
  return $CsAppId
}
#endregion *** Non-Exported Helper Functions ***

# Exporting ModuleMembers

Export-ModuleMember -Alias    Remove-CsOnlineApplicationInstance, con, Connect-Me
Export-ModuleMember -Function Connect-SkypeOnline, Disconnect-SkypeOnline, Connect-SkypeTeamsAndAAD, Disconnect-SkypeTeamsAndAAD, `
                              Get-AzureAdAssignedAdminRoles, Get-AzureADUserFromUPN,`
                              Add-TeamsUserLicense, New-AzureAdLicenseObject, Get-TeamsUserLicense, Get-TeamsTenantLicenses,`
                              Test-TeamsUserLicense, Set-TeamsUserPolicy, Test-TeamsTenantPolicy,`
                              Test-AzureADModule, Test-AzureADConnection, Test-AzureADUser,Test-AzureADGroup,`
                              Test-SkypeOnlineModule,Test-SkypeOnlineConnection, `
                              Test-MicrosoftTeamsModule,Test-MicrosoftTeamsConnection,Test-TeamsUser,`
                              Test-SkypeOnlineModule, Test-SkypeOnlineConnection, Test-TeamsUser,`
                              New-TeamsResourceAccount, Get-TeamsResourceAccount, Set-TeamsResourceAccount, Remove-TeamsResourceAccount,`
                              New-TeamsCallQueue, Get-TeamsCallQueue, Set-TeamsCallQueue, Remove-TeamsCallQueue,`
                              Backup-TeamsEV, Restore-TeamsEV, Backup-TeamsTenant,`
                              Remove-TenantDialPlanNormalizationRule, Test-TeamsExternalDNS, Get-SkypeOnlineConferenceDialInNumbers,`
                              Get-SkuPartNumberfromSkuID, Get-SkuIDfromSkuPartNumber, Remove-StringSpecialCharacter, Format-StringForUse