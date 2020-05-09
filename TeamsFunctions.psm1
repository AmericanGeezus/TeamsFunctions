#Requires -Version 3.0
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

    To use the functions in this module, use the Import-Module command followed by the path to this file. For example:
    Import-Module C:\Code\TeamsFunctions.psm1
    You can also place the .psm1 file in one of the locations PowerShell searches for available modules to import.
    These paths can be found in the $env:PSModulePath variable.A common path is C:\Users\<UserID>\Documents\WindowsPowerShell\Modules
    Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
    Always review any code and steps before applying to a production system to understand their full impact.

    # Limitations:
    - PhoneSystem_VirtualUser cannot be selected as no GUID is known for it currently
    - Office 365 F1 and F3 as well as Microsoft 365 F1 and F3 cannot be assigned

    # Versioning
    This Module follows the Versioning Convention Microsoft uses to show the Release Date in the Version number
    Major v20 is the the first one published in 2020, followed by Minor verson for Month and Day. 
    Subsequent Minor versions indicate additional publications on this day.
    Revisions are planned quarterly

    # Version History
    V1.0    02-OCT-2017 - Initial Version (as SkypeFunctions)
    V20.04  17-APR-2020 - Initial Version (as TeamsFunctions) - Multiple updates for Teams
            References to Skype for Business Online or SkypeOnline have been replaced with Teams as far as sensible
            Function ProcessLicense has seen many additions to LicensePackages. See Documentation there
            Microsoft 365 Licenses have been added to all Functions dealing with Licensing
            Functions to Test against AzureAD and SkypeOnline (Module, Connection, Object) are now elevated as exported functions
            Added Function Test-TeamsTenantPolicy to ascertain that the Object exists
            Added Function Test-TeamsUserLicensePackage queries whether the Object has a certain License Package assigned
            Added Function Test-AzureADObjectServicePlan queries whether the Object has a specific ServicePlan assinged
    V20.05  02-MAY-2020 - First Publish Version - Hello Universe!
#>

#region *** Exported Functions ***
#region Existing Functions
# Assigns a Teams License to a User/Object
function Add-TeamsUserLicense 
{
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
      .NOTES
      The command will test to see if the license exists in the tenant as well as if the user already
      has the licensed assigned. It does not keep track or take into account the number of licenses
      available before attempting to assign the license.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory=$false)]
    [Alias("AddS2")]
    [switch]$AddSFBO2,

    [Parameter(Mandatory=$false)]
    [Alias("AddE3,AddO365E3")]
    [switch]$AddOffice365E3,

    [Parameter(Mandatory=$false)]
    [Alias("AddE5,AddO365E5")]
    [switch]$AddOffice365E5,

    [Parameter(Mandatory=$false)]
    [Alias("AddMSE3,AddM365E3")]
    [switch]$AddMicrosoft365E3,

    [Parameter(Mandatory=$false)]
    [Alias("AddMSE5,AddM365E5")]
    [switch]$AddMicrosoft365E5,
    
    [Parameter(Mandatory=$false)]
    [Alias("AddE5NoAudioConferencing,AddO365E5NoAudioConferencing")]
    [switch]$AddOffice365E5NoAudioConferencing,

    [Parameter(Mandatory=$false)]
    [Alias("AddPSTNConferencing,AddMeetAdv")]
    [switch]$AddAudioConferencing,

    [Parameter(Mandatory=$false)]
    [Alias("AddSFBOCloudPBX,AddCloudPBX")]
    [switch]$AddPhoneSystem,

    [Parameter(Mandatory=$false)]
    [Alias("AddCommonAreaPhone,AddCAP")]
    [switch]$AddCommonAreaPhone,
    
    
    [Parameter(ParameterSetName = 'AddDomestic')]
    [Alias("AddDomesticCallingPlan")]
    [switch]$AddMSCallingPlanDomestic,

    [Parameter(ParameterSetName = 'AddInternational')]
    [Alias("AddInternationalCallingPlan")]
    [switch]$AddMSCallingPlanInternational
    
  )

  BEGIN {
    # Testing AzureAD Module and Connection
    if ((Test-AzureADModule) -eq $false) {RETURN}
    if ((Test-AzureADConnection) -eq $false) {
      try {
        Connect-AzureAD -ErrorAction STOP | Out-Null
      }
      catch {
        Write-Warning $_
        CONTINUE
      }
    }

    # Querying all SKUs from the Tenant
    try {
      $tenantSKUs = Get-AzureADSubscribedSku -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      RETURN
    }

    # Build Skype SKU Variables from Available Licenses in the Tenant
    foreach ($tenantSKU in $tenantSKUs) {
      switch ($tenantSKU.SkuPartNumber) {
        "MCOPSTN1" {$DomesticCallingPlan = $tenantSKU.SkuId; break}
        "MCOPSTN2" {$InternationalCallingPlan = $tenantSKU.SkuId; break}
        "MCOMEETADV" {$AudioConferencing = $tenantSKU.SkuId; break}
        "MCOEV" {$PhoneSystem = $tenantSKU.SkuId; break}
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

  PROCESS {
    foreach ($ID in $Identity) {
      try {
        Get-AzureADUser -ObjectId $ID -ErrorAction STOP | Out-Null
      }
      catch {
        $output = GetActionOutputObject2 -Name $ID -Result "Not a valid user account"
        Write-Output $output
        continue
      }

      # Get user's currently assigned licenses
      # Not used. Ignored
      $userCurrentLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ID).SkuId
      
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
        ProcessLicense -UserID $ID -LicenseSkuID $PhoneSystem -LicenseName "PhoneSystem (Add-On License)"
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

function Connect-SkypeOnline
{
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
      .EXAMPLE
      Connect-SkypeOnline
      Example 1 will prompt for the username and password of an administrator with permissions to connect to Skype for Business Online.
      .EXAMPLE
      Connect-SkypeOnline -UserName admin@contoso.com
      Example 2 will prefill the authentication prompt with admin@contoso.com and only ask for the password for the account to connect out to Skype for Business Online.
      .NOTES
      Requires that the Skype Online Connector PowerShell module be installed.
      If the PowerShell Module SkypeOnlineConnector is v7 or higher, the Session TimeOut of 60min can be circumvented.
      Enable-CsOnlineSessionForReconnection is run.
      Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
      The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
      To manage Teams, Channels, etc. within Microsoft Teams, use Connect-MicrosoftTeams
      Connect-MicrosoftTeams requires Teams Service Admin and is part of the PowerShell Module MicrosoftTeams 
      https://www.powershellgallery.com/packages/MicrosoftTeams
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [string]$UserName         
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
            $SkypeOnlineSession = New-CsOnlineSession $UserName -ErrorAction STOP
          }
          else
          {
            $SkypeOnlineSession = New-CsOnlineSession -ErrorAction STOP
          }

          Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
        }
        catch
        {
          Write-Warning -Message $_
        }
      } # End of if statement for module version checking
      #region For v7 and higher: run Enable-CsOnlineSessionForReconnection
      $moduleVersion = (Get-Module -Name SkypeOnlineConnector).Version
      Write-Host "SkypeOnlineConnector Module is v$ModuleVersion"
      if ($moduleVersion.Major -gt "6") # v7 and higher can run Session Limit Extension
      {
        Enable-CsOnlineSessionForReconnection -WarningAction SilentlyContinue
        Write-Verbose "The PowerShell session reconnects and authenticates, allowing it to be re-used without having to launch a new instance to reconnect." -Verbose

      }
      else 
      {
        Write-Host "Your Session will time out after 60 min. - To prevent this, Update this module to v7 or higher, then run Enable-CsOnlineSessionForReconnection"
        Write-Host "You can download the Module here: https://www.microsoft.com/download/details.aspx?id=39366"
      }
      #endregion
    }
    else
    {
      Write-Warning -Message "A Skype Online PowerShell Sessions already exists. Please run DisConnect-SkypeOnline before attempting this command again."
    } # End checking for existing Skype Online Connection
  }
  else
  {
    Write-Warning -Message "Skype Online PowerShell Connector module is not installed. Please install and try again."
    Write-Warning -Message "The module can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366"
  } # End of testing module existence
} # End of Connect-SkypeOnline

function Disconnect-SkypeOnline
{
  <#
      .SYNOPSIS
      Disconnects any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
      .EXAMPLE
      Disconnect-SkypeOnline
      Example 1 will remove any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
  #>

  [CmdletBinding()]
  param()

  [bool]$sessionFound = $false

  $PSSesssions = Get-PSSession

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
    Write-Warning -Message "No remote PowerShell sessions to Skype Online currently exist"
  }

} # End of DisConnect-SkypeOnline

function Get-SkypeOnlineConferenceDialInNumbers
{
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

  try
  {
    $siteContents = Invoke-WebRequest https://webdir1a.online.lync.com/DialinOnline/Dialin.aspx?path=$Domain -ErrorAction STOP
  }
  catch
  {
    Write-Warning -Message "Unable to access that dial-in page. Please check the domain name and try again. Also try to manually navigate to the page using the URL http://dialin.lync.com/DialInOnline/Dialin.aspx?path=$Domain."
    RETURN
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

function Get-TeamsUserLicense
{
  <#
      .SYNOPSIS
      Gathers licenses assigned to a Teams user for Cloud PBX and PSTN Calling Plans.
      .DESCRIPTION
      This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License
      .PARAMETER Identity
      The Identity/UPN/sign-in address for the user entered in the format <name>@<domain>.
      Aliases include: "UPN","UserPrincipalName","Username"
      .EXAMPLE
      .\Get-SkypeOnlineLicense.ps1 -Identity John@domain.com
      Example 1 will confirm the license for a single user: John@domain.com
      .EXAMPLE
      .\Get-SkypeOnlineLicense.ps1 -Identity John@domain.com,Jane@domain.com
      Example 2 will confirm the licenses for two users: John@domain.com & Jane@domain.com
      .EXAMPLE
      Import-Csv User.csv | .\Get-SkypeOnlineLicense.ps1
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
    if ((Test-AzureADModule) -eq $false) {RETURN}

    if ((Test-AzureADConnection) -eq $false)
    {
      try
      {
        Connect-AzureAD -ErrorAction STOP
      }
      catch
      {
        Write-Warning $_
        CONTINUE
      }
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
            "DESKLESSPACK" {$O365License += "Kiosk Plan, ";break}
            "EXCHANGEDESKLESS" {$O365License += "Exchange Kiosk, "; break}
            "EXCHANGESTANDARD" {$O365License += "Exchange Standard, "; break}
            "EXCHANGEENTERPRISE" {$O365License += "Exchange Premium, "; break}
            "MCOSTANDARD" {$O365License += "Skype Plan 2, "; break}
            "STANDARDPACK" {$O365License += "Office 365 E1, "; break}
            "ENTERPRISEPACK" {$O365License += "Office 365 E3, "; break}
            "ENTERPRISEPREMIUM" {$O365License += "Office 365 E5, "; break}
            "ENTERPRISEPREMIUM_NOPSTNCONF" {$O365License += "Office 365 E5 (No Audio Conferencing), "; break}
            "SPE_E3" {$O365License += "Microsoft 365 E3, "; break}
            "SPE_E5" {$O365License += "Microsoft 365 E5, "; break}
            "MCOEV" {$O365License += "PhoneSystem, "; break}
            "PHONESYSTEM_VIRTUALUSER" {$O365License = "PhoneSystem - Virtual User"; break}
            "MCOCAP" {$CommonAreaPhoneLicense = $true; break}
            "MCOPSTN1" {$currentCallingPlan = "Domestic"; break}
            "MCOPSTN2" {$currentCallingPlan = "Domestic and International"; break}
            "MCOPSTNC" {$CommunicationsCreditLicense = $true; break}
            "MCOMEETADV" {$AudioConferencingAddOn = $true; break}
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
        CallingPlan                 = $currentCallingPlan                
        CommunicationsCreditLicense = $CommunicationsCreditLicense
        AudioConferencingAddOn      = $AudioConferencingAddOn
        CommoneAreaPhoneLicense     = $CommonAreaPhoneLicense                
      }

      Write-Output $output
      
      # Add Judgement of Licensing state based on 3 different Licensing models?
      # Add Support for PhoneSystem_VirtualUser to also capture Resource accounts?
      
      
    } # End of foreach ($UserPrincipal in $Identity)
  } # End of PROCESS
} # End of Get-TeamsUserLicense

function Get-TeamsTenantLicenses
{
  <#
      .SYNOPSIS
      Displays the individual plans, add-on & grouped license SKUs for Teams in the tenant.
      .DESCRIPTION
      Teams services can be provisioned through several different combinations of individual
      plans as well as add-on and grouped license SKUs. This command displays these license SKUs in a more friendly
      format with descriptive names, active, consumed, remaining, and expiring licenses.
      .EXAMPLE
      Get-TeamsTenantLicenses
      Example 1 will display all the Skype related licenses for the tenant.
      .NOTES
      Requires the Azure Active Directory PowerShell module to be installed and authenticated to the tenant's Azure AD instance.
  #>

  [CmdletBinding()]
  param()
        
  if ((Test-AzureADModule) -eq $false) {RETURN}

  if ((Test-AzureADConnection) -eq $false)
  {
    try
    {
      Connect-AzureAD -ErrorAction STOP | Out-Null
    }
    catch
    {
      Write-Warning $_
      CONTINUE
    }
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
      "MCOEV" {$skuFriendlyName = "PhoneSystem Add-On"; break}
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
        License     = $skuFriendlyName
        Available   = $tenantSKU.PrepaidUnits.Enabled
        Consumed    = $tenantSKU.ConsumedUnits
        Remaining   = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
        Expiring    = $tenantSKU.PrepaidUnits.Warning
      }
    }    
  } # End of foreach ($tenantSKU in $tenantSKUs}
} # End of Get-TeamsTenantLicenses

function Remove-TenantDialPlanNormalizationRule
{
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

  if ((Test-SkypeOnlineModule) -eq $true)
  {
    if ((Test-SkypeOnlineConnection) -eq $false)
    {
      Connect-SkypeOnline
    }
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
function Set-TeamsUserPolicy
{
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
    if ((Test-SkypeOnlineModule) -eq $true)
    {
      if ((Test-SkypeOnlineConnection) -eq $false)
      {
        Write-Warning -Message "You must create a remote PowerShell session to Skype Online before continuing."
        Connect-SkypeOnline
      }
    }
    else
    {
      Write-Warning -Message "Skype Online PowerShell Connector module is not installed. Please install and try again."
      Write-Warning -Message "The module can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=39366"
    }

    # Get available policies for tenant
    Write-Verbose -Message "Gathering all policies for tenant"
    $tenantTeamsUpgradePolicies = (Get-CsTeamsUpgradePolicy -WarningAction SilentlyContinue).Identity
    $tenantClientPolicies = (Get-CsClientPolicy -WarningAction SilentlyContinue).Identity
    $tenantConferencingPolicies = (Get-CsConferencingPolicy -Include SubscriptionDefaults -WarningAction SilentlyContinue).Identity
    $tenantExternalAccessPolicies = (Get-CsExternalAccessPolicy -WarningAction SilentlyContinue).Identity
    $tenantMobilityPolicies = (Get-CsMobilityPolicy -WarningAction SilentlyContinue).Identity
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



function Test-TeamsExternalDNS
{
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

function Test-AzureADModule
{
  <#
      .SYNOPSIS
      Tests whether the AzureADModule is loaded
      .EXAMPLE
      Test-AzureADModule
      Will Return $TRUE if the Module is loaded

  #>
  [CmdletBinding()]
  param()

  Write-Verbose -Message "Verifying if AzureAD module is installed and available"

  if ((Get-Module -ListAvailable).Name -notcontains "AzureAD")
  {
    Write-Warning -Message "Azure Active Directory PowerShell module is not installed. Please install and try again."
    return $false
  }
} # End of Test-AzureADModule

function Test-AzureADConnection
{
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
    Get-AzureADCurrentSessionInfo -ErrorAction STOP | Out-Null
    return $true
  }
  catch
  {
    Write-Warning -Message "A connection to AzureAD must be present before continuing"
    return $false
  }
} # End of Test-AzureADConnection

function Test-SkypeOnlineModule
{
  <#
      .SYNOPSIS
      Tests whether the SkypeOnlineConnector Module is loaded
      .EXAMPLE
      Test-SkypeOnlineModule
      Will Return $TRUE if the Module is loaded

  #>
  [CmdletBinding()]
  param()
    
  if ((Get-Module -ListAvailable).Name -notcontains "SkypeOnlineConnector")
  {        
    return $false
  }
  else
  {
    try
    {
      Import-Module -Name SkypeOnlineConnector
      return $true
    }
    catch
    {
      Write-Warning $_
      return $false
    }
  }
} # End of Test-SkypeOnlineModule

function Test-SkypeOnlineConnection
{
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
      $PSSkypeOnlineSession = Get-PsSession | Where-Object {$_.ComputerName -like "*.online.lync.com"} | Select-Object -First 1
      if (($PSSkypeOnlineSession).State -notlike "Opened" -or ($PSSkypeOnlineSession).Availability -notlike "Available")
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
function Test-AzureADObject
{
  <#
      .SYNOPSIS
      Tests whether an Object exists in Azure AD (record found)
      .DESCRIPTION
      Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .EXAMPLE
      Test-AzureADObject
      Will Return $TRUE only if the object is found.
      Will Return $FALSE in any other case, including if there is no Connection to AzureAD!
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity  
  )

  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
  Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  TRY
  {
    Get-AzureADUser -ObjectId $Identity | Out-Null -ErrorAction STOP
    Return $true
  }
  CATCH [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]
  {
    Return $False
  }
  CATCH [Microsoft.Open.AzureAD16.Client.ApiException]
  {
    Return $False
  }
  CATCH
  {
    Return $False
  }
} # End of Test-AzureADObject

function Test-TeamsObject
{
  <#
      .SYNOPSIS
      Tests whether an Object exists in Teams (record found)
      .DESCRIPTION
      Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing
      .PARAMETER Identity
      Mandatory. The sign-in address or User Principal Name of the user account to modify.
      .EXAMPLE
      Test-TeamsObject
      Will Return $TRUE only if the object is found.
      Will Return $FALSE in any other case, including if there is no Connection to SkypeOnline!
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity   
  )

  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
  Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  TRY
  {
    Get-CsOnlineUser -Identity $Identity | Out-Null -ErrorAction STOP
    Return $true
  }
  CATCH [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]
  {
    Return $False
  }
  CATCH [Microsoft.Open.AzureAD16.Client.ApiException]
  {
    Return $False
  }
  CATCH
  {
    Return $False
  }
  
} # End of Test-TeamsObject

function Test-TeamsTenantPolicy
{
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
    [string]$Policy,
    
    [Parameter(Mandatory = $true, HelpMessage = "This is the Name of the Policy to test")]
    [string]$PolicyName
    
       
  )

  TRY
  {
    $Command = "Get-" + $Policy + " -Identity " + $PolicyName
    Invoke-Expression $Command | Out-Null -ErrorAction STOP
    Return $true
  }
  CATCH
  {
    Return $False
  }
  
} # End of Test-TeamsTenantPolicy

function Test-TeamsUserLicense
{
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
      Test-TeamsUserLicensePackage -Identity User@domain.com -ServicePlan MCOEV
      Will Return $TRUE only if the License is assigned
      .EXAMPLE
      Test-TeamsUserLicensePackage -Identity User@domain.com -LicensePackage Microsoft365E5
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
    [ValidateSet("SPE_E5", "SPE_E3", "ENTERPRISEPREMIUM","ENTERPRISEPACK","MCOSTANDARD","MCOMEETADV","MCOEV","PHONESYSTEM_VIRTUALUSER","MCOCAP","MCOPSTN1","MCOPSTN2","MCOPSTNC")]
    [string]$ServicePlan,

    [Parameter(Mandatory = $true, ParameterSetName = "Package", HelpMessage = "Teams License Package: E5,E3,S2")]
    [ValidateSet("Microsoft365E5", "Microsoft365E3andPhoneSystem", "Office365E5","Office365E3andPhoneSystem","SFBOPlan2andAdvancedMeetingandPhoneSystem","CommonAreaPhoneLicense","PhoneSystem","PhoneSystemVirtualUserLicense")]
    [string]$LicensePackage
    
  )
  #endregion

  switch ($PsCmdlet.ParameterSetName){
    "ServicePlan" {
        $UserLicensePlans = (Get-AzureADUserLicenseDetail -ObjectId $Identity).ServicePlans

        #Checks if it is assigned
        IF($ServicePlanName -in $UserLicensePlans.ServicePlanName)
        {
          #Checks if the Provisioning Status is also "Success"
          IF($($UserLicensePlans | Where-Object {$_.ServicePlanName -eq $ServicePlanName}).ProvisioningStatus -eq "Success")
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
    "LicensePackage" {
      TRY
      {
        # Querying License Details
        $UserLicenseSKU = (Get-AzureADUserLicenseDetail -ObjectId $Identity).SkuPartNumber
        
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
          "PhoneSystemVirtualUserLicense"
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
      CATCH
      {
        Return $False
      }
    }
  }
} # End of Test-TeamsUserLicense

#endregion
#endregion *** Exported Functions ***


#region *** Non-Exported Helper Functions ***
# Work in Progress - Currently not in list of exported functions
# Deprecated function. Taken as-is from SkypeFunctions and not further optimised.
function Connect-SkypeOnlineForMultiForest
{
  <#
    .NOTES
    This function was taken 1:1 from SkypeFunctions and remains untested for Teams
  #>
  [CmdletBinding()]
  param(
    [Parameter()]
    [string]$UserName,

    [Parameter()]
    [ValidateSet("APC","AUS","CAN","EUR","IND","JPN","NAM")]
    [string]$Region
  )

  if ((Get-Module).Name -notcontains "SkypeOnlineConnector")
  {
    try
    {
      Import-Module SkypeOnlineConnector -ErrorAction STOP
    }
    catch
    {
      Write-Error -Message "Unable to import SkypeOnlineConnector PowerShell Module : $_"
    }
  }
    
  if ((Get-PsSession).ComputerName -notlike "*.online.lync.com")
  {
    try
    {        
      $SkypeOnlineCredentials = Get-Credential $UserName -Message "Enter the sign-in address and password of an O365 or Skype Online Admin"
            
      if ($Region.Length -gt 0)
      {
        switch ($Region)
        {
          "APC" {$forestCode = "0F"; break}
          "AUS" {$forestCode = "AU1"; break}
          "CAN" {$forestCode = "CA1"; break}
          "EUR" {$forestCode = "1E"; break}
          "IND" {$forestCode = "IN1"; break}
          "JPN" {$forestCode = "JP1"; break}
          "NAM" {$forestCode = "2A"; break}
        }
                
        $SkypeOnlineSession = New-CsOnlineSession -Credential $SkypeOnlineCredentials -OverridePowershellUri "https://admin$forestCode.online.lync.com/OcsPowershellLiveId" -Verbose -ErrorAction STOP
      }
      else
      {
        $SkypeOnlineSession = New-CsOnlineSession -Credential $SkypeOnlineCredentials -Verbose -ErrorAction STOP
      }

      Import-PSSession -Session $SkypeOnlineSession -AllowClobber -Verbose -ErrorAction STOP
    }
    catch
    {
      Write-Warning -Message $_
    }
  }
  else
  {
    Write-Warning -Message "Existing Skype Online PowerShell Sessions Exists"
  }
} # End of Connect-SkypeOnlineForMultiForest


function GetActionOutputObject2
{
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

function GetActionOutputObject3
{
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

function NewLicenseObject
{
  <#
      .SYNOPSIS
      Creates a new License Object based on existing License assigned
      .DESCRIPTION
      Helper function to create a new License Object
      To execute Teams Commands, a connection via SkypeOnline must be established.
      This connection must be valid (Available and Opened)
      .PARAMETER SkuId
      SkuId of the Licnese
      .EXAMPLE
      NewLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd
      Will create a license Object for the MCOEV license .
  #>
  param(
    [Parameter(Mandatory = $true, HelpMessage = "SkuId of the license")]
    [string]$SkuId
  )

  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
  $productLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
  $productLicenseObj.SkuId = $SkuId
  $assignedLicensesObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
  $assignedLicensesObj.AddLicenses = $productLicenseObj
  return $assignedLicensesObj
}

function ProcessLicense
{
  <#
      .SYNOPSIS
      Processes one License against a user account.
      .DESCRIPTION
      Helper function for Add-TeamsUserLicense
      Teams services are available through assignment of different types of licenses.
      This command allows assigning one Skype related Office 365 licenses to a user account.
      .PARAMETER ID
      The sign-in address or User Principal Name of the user account to modify.
      .PARAMETER LicenseSkuID
      The SkuID for the License to assign.
      .PARAMETER LicenseName
      A friendly Name of the License/Task for feedback.
      .NOTES
      Uses Microsoft List for Licenses in SWITCH statement, update periodically or switch to lookup from DB(CSV or XLSX)
      https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time

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
  #>
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$UserID,

    [Parameter(Mandatory = $true, HelpMessage = "SkuID of the License")]
    [AllowEmptyString()]
    [string]$LicenseSkuID,

    [Parameter(Mandatory = $true, HelpMessage = "License name")]
    [string]$LicenseName
    
  )
  
  # Query currently assigned Licenses (SkuID) for User ($ID)
  $UserLicenses = (Get-AzureADUserLicenseDetail -ObjectId $UserID).SkuId
  
  # Query StringID and ProductName (Friendly Name) from $LicenseSkuID
  # But useful to have somewhere, but requires periodic updates (XLSX available as source).
  switch ($LicenseSkuID) {
    "0c266dff-15dd-4b49-8397-2bb16070ed52" {$StringID = "MCOMEETADV"; $ProductName = "AUDIO CONFERENCING"; break}
    "2b9c8e7c-319c-43a2-a2a0-48c5c6161de7" {$StringID = "AAD_BASIC"; $ProductName = "AZURE ACTIVE DIRECTORY BASIC"; break}
    "078d2b04-f1bd-4111-bbd4-b4b1b354cef4" {$StringID = "AAD_PREMIUM"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P1"; break}
    "84a661c4-e949-4bd2-a560-ed7766fcaf2b" {$StringID = "AAD_PREMIUM_P2"; $ProductName = "AZURE ACTIVE DIRECTORY PREMIUM P2"; break}
    "c52ea49f-fe5d-4e95-93ba-1de91d380f89" {$StringID = "RIGHTSMANAGEMENT"; $ProductName = "AZURE INFORMATION PROTECTION PLAN 1"; break}
    "ea126fc5-a19e-42e2-a731-da9d437bffcf" {$StringID = "DYN365_ENTERPRISE_PLAN1"; $ProductName = "DYNAMICS 365 CUSTOMER ENGAGEMENT PLAN ENTERPRISE EDITION"; break}
    "749742bf-0d37-4158-a120-33567104deeb" {$StringID = "DYN365_ENTERPRISE_CUSTOMER_SERVICE"; $ProductName = "DYNAMICS 365 FOR CUSTOMER SERVICE ENTERPRISE EDITION"; break}
    "cc13a803-544e-4464-b4e4-6d6169a138fa" {$StringID = "DYN365_FINANCIALS_BUSINESS_SKU"; $ProductName = "DYNAMICS 365 FOR FINANCIALS BUSINESS EDITION"; break}
    "8edc2cf8-6438-4fa9-b6e3-aa1660c640cc" {$StringID = "DYN365_ENTERPRISE_SALES_CUSTOMERSERVICE"; $ProductName = "DYNAMICS 365 FOR SALES AND CUSTOMER SERVICE ENTERPRISE EDITION"; break}
    "1e1a282c-9c54-43a2-9310-98ef728faace" {$StringID = "DYN365_ENTERPRISE_SALES"; $ProductName = "DYNAMICS 365 FOR SALES ENTERPRISE EDITION"; break}
    "8e7a3d30-d97d-43ab-837c-d7701cef83dc" {$StringID = "DYN365_ENTERPRISE_TEAM_MEMBERS"; $ProductName = "DYNAMICS 365 FOR TEAM MEMBERS ENTERPRISE EDITION"; break}
    "ccba3cfe-71ef-423a-bd87-b6df3dce59a9" {$StringID = "Dynamics_365_for_Operations"; $ProductName = "DYNAMICS 365 UNF OPS PLAN ENT EDITION"; break}
    "efccb6f7-5641-4e0e-bd10-b4976e1bf68e" {$StringID = "EMS"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E3"; break}
    "b05e124f-c7cc-45a0-a6aa-8cf78c946968" {$StringID = "EMSPREMIUM"; $ProductName = "ENTERPRISE MOBILITY + SECURITY E5"; break}
    "4b9405b0-7788-4568-add1-99614e613b69" {$StringID = "EXCHANGESTANDARD"; $ProductName = "EXCHANGE ONLINE (PLAN 1)"; break}
    "19ec0d23-8335-4cbd-94ac-6050e30712fa" {$StringID = "EXCHANGEENTERPRISE"; $ProductName = "EXCHANGE ONLINE (PLAN 2)"; break}
    "ee02fd1b-340e-4a4b-b355-4a514e4c8943" {$StringID = "EXCHANGEARCHIVE_ADDON"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE ONLINE"; break}
    "90b5e015-709a-4b8b-b08e-3200f994494c" {$StringID = "EXCHANGEARCHIVE"; $ProductName = "EXCHANGE ONLINE ARCHIVING FOR EXCHANGE SERVER"; break}
    "7fc0182e-d107-4556-8329-7caaa511197b" {$StringID = "EXCHANGEESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break}
    "e8f81a67-bd96-4074-b108-cf193eb9433b" {$StringID = "EXCHANGE_S_ESSENTIALS"; $ProductName = "EXCHANGE ONLINE ESSENTIALS"; break}
    "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82" {$StringID = "EXCHANGEDESKLESS"; $ProductName = "EXCHANGE ONLINE KIOSK"; break}
    "cb0a98a8-11bc-494c-83d9-c1b1ac65327e" {$StringID = "EXCHANGETELCO"; $ProductName = "EXCHANGE ONLINE POP"; break}
    "061f9ace-7d42-4136-88ac-31dc755f143f" {$StringID = "INTUNE_A"; $ProductName = "INTUNE"; break}
    "b17653a4-2443-4e8c-a550-18249dda78bb" {$StringID = "M365EDU_A1"; $ProductName = "Microsoft 365 A1"; break}
    "4b590615-0888-425a-a965-b3bf7789848d" {$StringID = "M365EDU_A3_FACULTY"; $ProductName = "Microsoft 365 A3 for faculty"; break}
    "7cfd9a2b-e110-4c39-bf20-c6a3f36a3121" {$StringID = "M365EDU_A3_STUDENT"; $ProductName = "Microsoft 365 A3 for students"; break}
    "e97c048c-37a4-45fb-ab50-922fbf07a370" {$StringID = "M365EDU_A5_FACULTY"; $ProductName = "Microsoft 365 A5 for faculty"; break}
    "46c119d4-0379-4a9d-85e4-97c66d3f909e" {$StringID = "M365EDU_A5_STUDENT"; $ProductName = "Microsoft 365 A5 for students"; break}
    "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" {$StringID = "SPB"; $ProductName = "MICROSOFT 365 BUSINESS"; break}
    "05e9a617-0261-4cee-bb44-138d3ef5d965" {$StringID = "SPE_E3"; $ProductName = "MICROSOFT 365 E3"; break}
    "d61d61cc-f992-433f-a577-5bd016037eeb" {$StringID = "SPE_E3_USGOV_DOD"; $ProductName = "Microsoft 365 E3_USGOV_DOD"; break}
    "ca9d1dd9-dfe9-4fef-b97c-9bc1ea3c3658" {$StringID = "SPE_E3_USGOV_GCCHIGH"; $ProductName = "Microsoft 365 E3_USGOV_GCCHIGH"; break}
    "06ebc4ee-1bb5-47dd-8120-11324bc54e06" {$StringID = "SPE_E5"; $ProductName = "Microsoft 365 E5"; break}
    "184efa21-98c3-4e5d-95ab-d07053a96e67" {$StringID = "INFORMATION_PROTECTION_COMPLIANCE"; $ProductName = "Microsoft 365 E5 Compliance"; break}
    "26124093-3d78-432b-b5dc-48bf992543d5" {$StringID = "IDENTITY_THREAT_PROTECTION"; $ProductName = "Microsoft 365 E5 Security"; break}
    "44ac31e7-2999-4304-ad94-c948886741d4" {$StringID = "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"; $ProductName = "Microsoft 365 E5 Security for EMS E5"; break}
    "66b55226-6b4f-492c-910c-a3b7a3c9d993" {$StringID = "SPE_F1"; $ProductName = "Microsoft 365 F1"; break}
    "111046dd-295b-4d6d-9724-d52ac90bd1f2" {$StringID = "WIN_DEF_ATP"; $ProductName = "Microsoft Defender Advanced Threat Protection"; break}
    "d17b27af-3f49-4822-99f9-56a661538792" {$StringID = "CRMSTANDARD"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE"; break}
    "906af65a-2970-46d5-9b58-4e9aa50f0657" {$StringID = "CRMPLAN2"; $ProductName = "MICROSOFT DYNAMICS CRM ONLINE BASIC"; break}
    "ba9a34de-4489-469d-879c-0f0f145321cd" {$StringID = "IT_ACADEMY_AD"; $ProductName = "MS IMAGINE ACADEMY"; break}
    "a4585165-0533-458a-97e3-c400570268c4" {$StringID = "ENTERPRISEPREMIUM_FACULTY"; $ProductName = "Office 365 A5 for faculty"; break}
    "ee656612-49fa-43e5-b67e-cb1fdf7699df" {$StringID = "ENTERPRISEPREMIUM_STUDENT"; $ProductName = "Office 365 A5 for students"; break}
    "1b1b1f7a-8355-43b6-829f-336cfccb744c" {$StringID = "EQUIVIO_ANALYTICS"; $ProductName = "Office 365 Advanced Compliance"; break}
    "4ef96642-f096-40de-a3e9-d83fb2f90211" {$StringID = "ATP_ENTERPRISE"; $ProductName = "Office 365 Advanced Threat Protection (Plan 1)"; break}
    "cdd28e44-67e3-425e-be4c-737fab2899d3" {$StringID = "O365_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break}
    "b214fe43-f5a3-4703-beeb-fa97188220fc" {$StringID = "SMB_BUSINESS"; $ProductName = "OFFICE 365 BUSINESS"; break}
    "3b555118-da6a-4418-894f-7df1e2096870" {$StringID = "O365_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break}
    "dab7782a-93b1-4074-8bb1-0e61318bea0b" {$StringID = "SMB_BUSINESS_ESSENTIALS"; $ProductName = "OFFICE 365 BUSINESS ESSENTIALS"; break}
    "f245ecc8-75af-4f8e-b61f-27d8114de5f3" {$StringID = "O365_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break}
    "ac5cef5d-921b-4f97-9ef3-c99076e5470f" {$StringID = "SMB_BUSINESS_PREMIUM"; $ProductName = "OFFICE 365 BUSINESS PREMIUM"; break}
    "18181a46-0d4e-45cd-891e-60aabd171b4e" {$StringID = "STANDARDPACK"; $ProductName = "OFFICE 365 E1"; break}
    "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e" {$StringID = "STANDARDWOFFPACK"; $ProductName = "OFFICE 365 E2"; break}
    "6fd2c87f-b296-42f0-b197-1e91e994b900" {$StringID = "ENTERPRISEPACK"; $ProductName = "OFFICE 365 E3"; break}
    "189a915c-fe4f-4ffa-bde4-85b9628d07a0" {$StringID = "DEVELOPERPACK"; $ProductName = "OFFICE 365 E3 DEVELOPER"; break}
    "b107e5a3-3e60-4c0d-a184-a7e4395eb44c" {$StringID = "ENTERPRISEPACK_USGOV_DOD"; $ProductName = "Office 365 E3_USGOV_DOD"; break}
    "aea38a85-9bd5-4981-aa00-616b411205bf" {$StringID = "ENTERPRISEPACK_USGOV_GCCHIGH"; $ProductName = "Office 365 E3_USGOV_GCCHIGH"; break}
    "1392051d-0cb9-4b7a-88d5-621fee5e8711" {$StringID = "ENTERPRISEWITHSCAL"; $ProductName = "OFFICE 365 E4"; break}
    "c7df2760-2c81-4ef7-b578-5b5392b571df" {$StringID = "ENTERPRISEPREMIUM"; $ProductName = "OFFICE 365 E5"; break}
    "26d45bd9-adf1-46cd-a9e1-51e9a5524128" {$StringID = "ENTERPRISEPREMIUM_NOPSTNCONF"; $ProductName = "OFFICE 365 E5 WITHOUT AUDIO CONFERENCING"; break}
    "4b585984-651b-448a-9e53-3b10f069cf7f" {$StringID = "DESKLESSPACK"; $ProductName = "OFFICE 365 F1"; break}
    "04a7fb0d-32e0-4241-b4f5-3f7618cd1162" {$StringID = "MIDSIZEPACK"; $ProductName = "OFFICE 365 MIDSIZE BUSINESS"; break}
    "c2273bd0-dff7-4215-9ef5-2c7bcfb06425" {$StringID = "OFFICESUBSCRIPTION"; $ProductName = "OFFICE 365 PROPLUS"; break}
    "bd09678e-b83c-4d3f-aaba-3dad4abd128b" {$StringID = "LITEPACK"; $ProductName = "OFFICE 365 SMALL BUSINESS"; break}
    "fc14ec4a-4169-49a4-a51e-2c852931814b" {$StringID = "LITEPACK_P2"; $ProductName = "OFFICE 365 SMALL BUSINESS PREMIUM"; break}
    "e6778190-713e-4e4f-9119-8b8238de25df" {$StringID = "WACONEDRIVESTANDARD"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 1)"; break}
    "ed01faf2-1d88-4947-ae91-45ca18703a96" {$StringID = "WACONEDRIVEENTERPRISE"; $ProductName = "ONEDRIVE FOR BUSINESS (PLAN 2)"; break}
    "b30411f5-fea1-4a59-9ad9-3db7c7ead579" {$StringID = "POWERAPPS_PER_USER"; $ProductName = "POWER APPS PER USER PLAN"; break}
    "45bc2c81-6072-436a-9b0b-3b12eefbc402" {$StringID = "POWER_BI_ADDON"; $ProductName = "POWER BI FOR OFFICE 365 ADD-ON"; break}
    "f8a1db68-be16-40ed-86d5-cb42ce701560" {$StringID = "POWER_BI_PRO"; $ProductName = "POWER BI PRO"; break}
    "a10d5e58-74da-4312-95c8-76be4e5b75a0" {$StringID = "PROJECTCLIENT"; $ProductName = "PROJECT FOR OFFICE 365"; break}
    "776df282-9fc0-4862-99e2-70e561b9909e" {$StringID = "PROJECTESSENTIALS"; $ProductName = "PROJECT ONLINE ESSENTIALS"; break}
    "09015f9f-377f-4538-bbb5-f75ceb09358a" {$StringID = "PROJECTPREMIUM"; $ProductName = "PROJECT ONLINE PREMIUM"; break}
    "2db84718-652c-47a7-860c-f10d8abbdae3" {$StringID = "PROJECTONLINE_PLAN_1"; $ProductName = "PROJECT ONLINE PREMIUM WITHOUT PROJECT CLIENT"; break}
    "53818b1b-4a27-454b-8896-0dba576410e6" {$StringID = "PROJECTPROFESSIONAL"; $ProductName = "PROJECT ONLINE PROFESSIONAL"; break}
    "f82a60b8-1ee3-4cfb-a4fe-1c6a53c2656c" {$StringID = "PROJECTONLINE_PLAN_2"; $ProductName = "PROJECT ONLINE WITH PROJECT FOR OFFICE 365"; break}
    "1fc08a02-8b3d-43b9-831e-f76859e04e1a" {$StringID = "SHAREPOINTSTANDARD"; $ProductName = "SHAREPOINT ONLINE (PLAN 1)"; break}
    "a9732ec9-17d9-494c-a51c-d6b45b384dcb" {$StringID = "SHAREPOINTENTERPRISE"; $ProductName = "SHAREPOINT ONLINE (PLAN 2)"; break}
    "e43b5b99-8dfb-405f-9987-dc307f34bcbd" {$StringID = "MCOEV"; $ProductName = "SKYPE FOR BUSINESS CLOUD PBX"; break}
    "b8b749f8-a4ef-4887-9539-c95b1eaa5db7" {$StringID = "MCOIMP"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 1)"; break}
    "d42c793f-6c78-4f43-92ca-e8f6a02b035f" {$StringID = "MCOSTANDARD"; $ProductName = "SKYPE FOR BUSINESS ONLINE (PLAN 2)"; break}
    "d3b4fe1f-9992-4930-8acb-ca6ec609365e" {$StringID = "MCOPSTN2"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC AND INTERNATIONAL CALLING"; break}
    "0dab259f-bf13-4952-b7f8-7db8f131b28d" {$StringID = "MCOPSTN1"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING"; break}
    "54a152dc-90de-4996-93d2-bc47e670fc06" {$StringID = "MCOPSTN5"; $ProductName = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING (120 Minutes)"; break}
    "4b244418-9658-4451-a2b8-b5e2b364e9bd" {$StringID = "VISIOONLINE_PLAN1"; $ProductName = "VISIO ONLINE PLAN 1"; break}
    "c5928f49-12ba-48f7-ada3-0d743a3601d5" {$StringID = "VISIOCLIENT"; $ProductName = "VISIO Online Plan 2"; break}
    "cb10e6cd-9da4-4992-867b-67546b1db821" {$StringID = "WIN10_PRO_ENT_SUB"; $ProductName = "WINDOWS 10 ENTERPRISE E3"; break}
    "488ba24a-39a9-4473-8ee5-19291e71b002" {$StringID = "WIN10_VDA_E5"; $ProductName = "Windows 10 Enterprise E5"; break}
  } # End Switch statement
      
  # Checking if the Tenant has a License of that SkuID
  if ($LicenseSkuID -ne "") {
    # Checking whether the User already has this license assigned
    if ($UserLicenses -notcontains $LicenseSkuID) {
      # Trying to assign License, SUCCESS if so, ERROR if not.
      try {
        #NOTE: Backward Compatibility (Set-MsolUserLicense) - Old method, requires Microsoft Azure AD (v1) Connection (Connect-MsolService) which we want to avoid because of MFA!
        #Set-MsolUserLicense -UserPrincipalName $ID -AddLicenses $LicenseSkuID -ErrorAction STOP
        $license = NewLicenseObject -SkuId $LicenseSkuID
        Set-AzureADUserLicense -ObjectId $UserID -AssignedLicenses $license -ErrorAction STOP
        $Result = GetActionOutputObject2 -Name $UserID -Result "SUCCESS: $ProductName assigned"
      }
      catch {
        $Result = GetActionOutputObject2 -Name $UserID -Result "ERROR: Unable to assign $ProductName`: $_"
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
#endregion *** Non-Exported Helper Functions ***

# Create a new Module out of this


Export-ModuleMember -Function Add-TeamsUserLicense, Connect-SkypeOnline, Disconnect-SkypeOnline,`
                              Get-SkypeOnlineConferenceDialInNumbers, Get-TeamsUserLicense, Get-TeamsTenantLicenses, Set-TeamsUserPolicy,`
                              Remove-TenantDialPlanNormalizationRule, Test-TeamsExternalDNS,`
                              Test-AzureADModule, Test-SkypeOnlineModule,`
                              Test-AzureADConnection, Test-SkypeOnlineConnection,`
                              Test-AzureADObject, Test-TeamsObject, Test-TeamsTenantPolicy,`
                              Test-TeamsUserLicense