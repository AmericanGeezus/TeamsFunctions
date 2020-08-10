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

  To use the functions in this module, use the Import-Module command followed by the path to this file. For example:
  Import-Module TeamsFunctions

  Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
  Always review any code and steps before applying to a production system to understand their full impact.

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
  20.05.03.1  First Publication
        Bug fixing, erroneously incorporated all local modules.
  20.05.09.1  Bug fixing, minor improvements
  20.05.19.2  Adding Backup and TeamsResourceAccount functions (BETA)
        Added Backup-TeamsEV, Restore-TeamsEV by Ken Lasko
        Added Get-AzureAdAssignedAdminRoles
        Added BETA-Functions New-TeamsResourceAccount, Get-TeamsResourceAccount
        Fixed an issue with access to the new functions
        Added TeamsResourceAccount Cmdlets: NEW, GET, SET, REMOVE - Tested
  20.05.24.2  Added Helper functions
        Added Replace switch for Licenses (valid only for PhoneSystem and PhoneSystem_VirtualUser licenses)
        Added Helper functions for Resource Accounts (switching between ApplicationID and ApplicationType, i.E. friendly Name)
        Added Helper function for Licensing: Get-SkuPartNumberfromSkuID (returns SkuPartNumber or ProductName)
        Added Helper function for Licensing: Get-SkuIDfromSkuPartNumber (returns SkuID)
        Renamed Helper function for Licensing: New-AzureADLicenseObject (creates a new License Object, can add and remove one)
        RESOLVED Limitation "PhoneSystem_VirtualUser cannot be selected as no GUID is known for it currently"
        Added AzureAD Module and Connection Test in all Functions that need it.
        Added SkypeOnline Module and Connection Test in all Functions that need it.
        Some bug fixing and code scrubbing
  20.06.09.1  Added TeamsCallQueue Functions (BETA)
        Added TeamsCallQueue Cmdlets: NEW, GET, SET, REMOVE - Untested
        Added Connect-SkypeTeamsAndAAD and Disconnect-SkypeTeamsAndAAD incl. Aliases "con" and "Connect-Me"
        Run "con $Username" to connect to all 3 with one authentication prompt
        Removed Test-AzureADModule, Test-SkypeOnlineModule, Test-MicrosoftTeamsModule.
        Replaced by Test-Module $ModuleNames
  20.06.17.1  Bugfixing
        Added Write-ErrorRecord.
        Bugfixing Resource Account and Call Queue Scripts
  20.06.22.0
        Added Find-TeamsResourceAccount, Renamed Format-StringRemoveSpecialCharacter
        Bugfixing Resource Account and Call Queue Scripts
        Added more suggestions from PS Script Analyzer: Renamed functions, added small elements.
  20.06.29.1
        Added TeamsResourceAccountAssociation Functions & Script Analyzer
        Added TeamsResourceAccountAssociation Scripts
        Added more suggestions from PS Script Analyzer: ShouldProcess, Preference Adherence, Force & Confirm interoperability
  20.07.08-alpha2       Import-TeamsAudioFile
        Exposed Import-TeamsAudioFile for public use.
        Updated New-TeamsCallQueue and Set-TeamsCallQueue to use Import-TeamsAudioFile for Welcome Message and Music On Hold
        Updated Set-TeamsCallQueue to allow $NULL for Parameter WelcomeMusicAudioFile
  20.07.18-prerelase    License Update
        Added Variable $TeamsLicenses - Fully populated with 38 Microsoft Licenses
        Updated Get-TeamsTenantLicense - now returns a proper Object, based on Variable $TeamsLicenses
        Updated Get-TeamsUserLicense - now returns a proper Object, based on Variable $TeamsLicenses
        Added Set-TeamsUserLicense - now a full replacement for Add-TeamsUserLicnese
        This function now supports multiple adds and removes including purges
        Added Disclaimer for Add-TeamsUserLicense as it is now deprecated
        Removed Get-TeamsTenantLicneses (plural)
  20.07.26-prerelease   Voicemail and SharedVoicemail for TeamsCallQueue
        Updated New-TeamsCallQueue to support Voicemail and SharedVoicemail for Overflow and Timeout
        Updated Set-TeamsCallQueue to support Voicemail and SharedVoicemail for Overflow and Timeout
        Updated Get-TeamsCallQueue to support Voicemail and SharedVoicemail for Overflow and Timeout (output)
        Removed Parameter Slow from New & Set-TeamsCallQueue as splatting is working fine
        Updated Connect-SkypeTeamsAndAAD to support connection to Exchange with the same credentials (required to check O365 Groups)
  20.08 Live Version for AUG 2020
        # Not perfect yet, but the monthly release. Future releases as PreRelease again
        Miscellaneous Bugfixes and performance improvements
        Fixes for New-TeamsResourceAccountAssociation for AutoAttendants
        Fixes for New-TeamsCallQueue - Lookup for Users and Groups and Desired Configuration
        Fixes for Set-TeamsCallQueue - Lookup for Users and Groups
        Fixes for Get-TeamsCallQueue - Improvements for Output
        Fixes for New-TeamsResourceAccountAssociation for AutoAttendants
        Minor fixes for all Test-Commands which now also have verbose output for re-using a session
	#>

#region *** Exported Functions ***
#region Existing Functions
# Assigns a Teams License to a User/Object

function Set-TeamsUserLicense {
  <#
	.SYNOPSIS
		Changes the License of an AzureAD Object
	.DESCRIPTION
    Adds, removes or purges teams related Licenses from an AzureAD Object
    Supports all Licenses listed in $TeamsLicenses, currently: 38 Licenses
    Uses friendly Names for Parameter Values, supports Arrays.
    Calls New-AzureAdLicenseObject from this Module in order to run Set-AzureADUserLicense.
		This will work with ANY AzureAD Object, not just for Teams, but only Licenses relevant to Teams are covered.
    Will verify major Licenses and their exclusivity, but not all.
    Verifies whether the Licenses selected are available on the Tenant before executing
	.PARAMETER Identity
		Required. UserPrincipalName of the Object to be manipulated
	.PARAMETER AddLicenses
		Optional. Licenses to be added (main function)
    Accepted Values are listed in $TeamsLicenses.ParameterName
	.PARAMETER RemoveLicenses
		Optional. Licesnses to be removed (alternative function)
    Accepted Values are listed in $TeamsLicenses.ParameterName
	.PARAMETER RemoveAllLicenses
		Optional Switch. Removes all licenses currently assigned (intended for replacements)
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses MS365E5
		Applies the Microsoft 365 E5 License (SPE_E5) to Name@domain.com
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses PhoneSystem
		Applies the PhoneSystem Add-on License (MCOEV) to Name@domain.com
		This requires a main license to be present as PhoneSystem is an add-on license
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses MS365E3,PhoneSystem
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses @('MS365E3','PhoneSystem')
		Applies the Microsoft 365 E3 License (SPE_E3) and PhoneSystem Add-on License (MCOEV) to Name@domain.com
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses O365E5 -RemoveLicenses SFBOP2
		Special Case Scenario to replace a specific license with another.
		Replaces Skype for Business Online Plan 2 License (MCOSTANDARD) with the Office 365 E5 License (ENTERPRISEPREMIUM).
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -AddLicenses PhoneSystem_VirtualUser -RemoveAllLicenses
		Special Case Scenario for Resource Accounts to swap licenses for a Phone System VirtualUser License
		Replaces all Licenses currently on the User Name@domain.com with the Phone System Virtual User (MCOEV_VIRTUALUSER) License
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -RemoveLicenses PhoneSystem
		Removes the Phone System License from the Object.
	.EXAMPLE
		Set-TeamsUserLicense -Identity Name@domain.com -RemoveAllLicenses
		Removes all licenses the Object is currently provisioned for!
	.NOTES
		Many license packages are available, the following Licenses are most predominant:
		# Main License Packages
		- Microsoft 365 E5 License - Microsoft365E5 (SPE_E5)
		- Microsoft 365 E3 License - Microsoft365E3 (SPE_E3)  #NOTE: For Teams EV this requires PhoneSystem as an add-on!
		- Office 365 E5 License - Microsoft365E5 (ENTERPRISEPREMIUM)
		- Office 365 E5 without Audio Conferencing License - Microsoft365E5noAudioConferencing (ENTERPRISEPREMIUM_NOPSTNCONF)  #NOTE: For Teams EV this requires AudioConferencing and PhoneSystem as an add-on!
		- Office 365 E3 License - Microsoft365E3 (ENTERPRISEPACK) #NOTE: For Teams EV this requires PhoneSystem as an add-on!
		- Skype for Business Online (Plan 2) (MCOSTANDARD)   #NOTE: For Teams EV this requires PhoneSystem as an add-on!

		# Add-On Licenses (Require Main License Package from above)
		- Audio Conferencing License - AudioConferencing (MCOMEETADV)
		- Phone System - PhoneSystem (MCOEV)

		# Standaolne Licenses (Special)
		- Common Area Phone License (MCOCAP)  #NOTE: Cheaper, but limits the Object to a Common Area Phone (no mailbox)
		- Phone System Virtual User License (PHONESYSTEM_VIRTUALUSER)  #NOTE: Only use for Resource Accounts!

		# Microsoft Calling Plan Licenses
		- Domestic Calling Plan - DomesticCallingPlan (MCOPSTN1)
		- Domestic and International Calling Plan - InternationalCallingPlan (MCOPSTN2)

    # Data in $TeamsLicenses as per Microsoft Docs Article: Published Service Plan IDs for Licensing
    https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time

	.COMPONENT
		Teams Migration and Enablement. License Assignment
	.ROLE
		Licensing
	.FUNCTIONALITY
		This script changes the AzureAD Object provided by adding or removing Licenses relevant to Teams
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Test-TeamsUserLicense
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Add')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(ParameterSetName = 'Add', Mandatory = $true, HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'Remove', Mandatory = $false, HelpMessage = 'License(s) to be added to this Object')]
    [Parameter(ParameterSetName = 'RemoveAll', Mandatory = $false, HelpMessage = 'License(s) to be added to this Object')]
    [ValidateSet('Microsoft365A3faculty', 'Microsoft365A3students', 'Microsoft365A5faculty', 'Microsoft365A5students', 'Microsoft365BusinessBasic', 'Microsoft365BusinessStandard', 'Microsoft365BusinessPremium', 'Microsoft365E3', 'Microsoft365E5', 'Microsoft365F1', 'Microsoft365F3', 'Office365A5faculty', 'Office365A5students', 'Office365E1', 'Office365E2', 'Office365E3', 'Office365E3Dev', 'Office365E4', 'Office365E5', 'Office365E5NoAudioConferencing', 'Office365F1', 'Microsoft365E3USGOVDOD', 'Microsoft365E3USGOVGCCHIGH', 'Office365E3USGOVDOD', 'Office365E3USGOVGCCHIGH', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone', 'SkypeOnlinePlan2', 'AudioConferencing', 'InternationalCallingPlan', 'DomesticCallingPlan', 'DomesticCallingPlan120', 'CommunicationCredits', 'SkypeOnlinePlan1')]
    #ValidateScript needs testing, but would make things easier here
    #TODO: Test swap to ValidateScript
    #[ValidateScript( {$_ -in $TeamsLicenses.ParameterName} )]
    [string[]]$AddLicenses,

    [Parameter(ParameterSetName = 'Remove', Mandatory, HelpMessage = 'License(s) to be removed from this Object')]
    [ValidateSet('Microsoft365A3faculty', 'Microsoft365A3students', 'Microsoft365A5faculty', 'Microsoft365A5students', 'Microsoft365BusinessBasic', 'Microsoft365BusinessStandard', 'Microsoft365BusinessPremium', 'Microsoft365E3', 'Microsoft365E5', 'Microsoft365F1', 'Microsoft365F3', 'Office365A5faculty', 'Office365A5students', 'Office365E1', 'Office365E2', 'Office365E3', 'Office365E3Dev', 'Office365E4', 'Office365E5', 'Office365E5NoAudioConferencing', 'Office365F1', 'Microsoft365E3USGOVDOD', 'Microsoft365E3USGOVGCCHIGH', 'Office365E3USGOVDOD', 'Office365E3USGOVGCCHIGH', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone', 'SkypeOnlinePlan2', 'AudioConferencing', 'InternationalCallingPlan', 'DomesticCallingPlan', 'DomesticCallingPlan120', 'CommunicationCredits', 'SkypeOnlinePlan1')]
    #[ValidateScript( {$_ -in $TeamsLicenses.ParameterName} )]
    [string[]]$RemoveLicenses,

    [Parameter(ParameterSetName = 'RemoveAll', Mandatory, HelpMessage = 'Switch to indicate that all Licenses should be removed')]
    [Switch]$RemoveAllLicenses
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }
    #Loading License Array
    $AllLicenses = $null
    $AllLicenses = $TeamsLicenses

    #region Input verification
    # All Main licenses are mutually exclusive
    # Domestic and International are mutually exclusive
    # Common AreaPhone and PhoneSystemVirtualUser are exclusive
    # AudioConf only for O365E5NoConf, E3 Licenses and SFBOP2
    # PhoneSystem only for E3 Licenses and SFBOP2
    <#
			'Microsoft365E5', 'Microsoft365E3',
			'Office365E5', 'Office365E5NoAudioConferencing', 'Office365E3', 'SkypeOnlinePlan2',
			'AudioConferencing', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone'
			'DomesticCallingPlan','InternationalCallingPlan'
		#>
    try {
      if ($PSBoundParameters.ContainsKey('AddLicenses') -and $PSBoundParameters.ContainsKey('RemoveLicenses')) {
        # Check if any are listed in both!
        Write-Verbose -Message "Validating input for Add and Remove (identifying inconsistencies)" -Verbose

        foreach ($Lic in $AddLicenses) {
          if ($Lic -in $RemoveLicenses) {
            Write-Error -Message "Invalid combination. '$Lic' cannot be added AND removed" -Category LimitsExceeded -RecommendedAction "Please specify only once!" -ErrorAction Stop
          }
        }
      }

      if ($PSBoundParameters.ContainsKey('AddLicenses')) {
        Write-Verbose -Message "Validating input for Adding Licenses (identifying inconsistencies)" -Verbose
        #region Disclaimer
        # Checking any other combinations then the verified
        if ( -not ('Microsoft365E3' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses`
              -or 'PhoneSystem' -in $AddLicenses -or 'AudioConferencing' -in $AddLicenses)) {
          Write-Warning -Message "License combination not verified. Errors due to incompatibilities may occur!"
          Write-Verbose -Message "Please check yourself which Licenses may not be assigned together" -Verbose
        }
        #endregion

        #region Main Licenses
        #region Microsoft 365
        # Checking combinations for Microsoft365E5
        if ('Microsoft365E5' -in $AddLicenses) {
          if ('Microsoft365E3' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses`
              -or 'PhoneSystem' -in $AddLicenses -or 'AudioConferencing' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Microsoft365E3
        if ('Microsoft365E3' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }
        #endregion

        #region Office 365
        # Checking combinations for Office365E5
        if ('Office365E5' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Microsoft365E3' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses`
              -or 'PhoneSystem' -in $AddLicenses -or 'AudioConferencing' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E5NoAudioConferencing
        if ('Office365E5NoAudioConferencing' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Microsoft365E3' -in $AddLicenses -or 'Office365E5' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for Office365E3
        if ('Office365E3' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Microsoft365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!"
            break
          }
        }
        #endregion

        #region Skype Online Plan2
        # Checking combinations for SkypeOnlinePlan2
        if ('SkypeOnlinePlan2' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'Microsoft365E3' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }
        #endregion
        #endregion

        #region Standalone Licenses
        # Checking combinations for CommonAreaPhone
        if ('CommonAreaPhone' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'Microsoft365E3' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }

        # Checking combinations for PhoneSystemVirtualUser
        if ('PhoneSystemVirtualUser' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'Microsoft365E3' -in $AddLicenses) {
            Write-Error -Message "Invalid combination of Main Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Main License!" -ErrorAction Stop
          }
        }
        #endregion

        #region Add-on Licenses
        # Checking combinations for PhoneSystem
        if ('PhoneSystem' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination. 'PhoneSystem' cannot be added to the Main License specified (already integrated)" -Category LimitsExceeded -RecommendedAction "Please remove 'PhoneSystem'" -ErrorAction Stop
          }
          elseif ('Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses) {
            Write-Verbose -Message "Combination correct. 'PhoneSystem' can be added"
          }
        }

        # Checking combinations for Microsoft365E3
        if ('AudioConferencing' -in $AddLicenses) {
          if ('Microsoft365E5' -in $AddLicenses -or 'Office365E5' -in $AddLicenses `
              -or 'Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses `
              -or 'CommonAreaPhone' -in $AddLicenses -or 'PhoneSystemVirtualUser' -in $AddLicenses) {
            Write-Error -Message "Invalid combination. 'AudioConferencing' cannot be added to the Main License specified (already integrated)" -Category LimitsExceeded -RecommendedAction "Please remove 'AudioConferencing'" -ErrorAction Stop
          }
          elseif ('Office365E3' -in $AddLicenses -or 'SkypeOnlinePlan2' -in $AddLicenses -or 'Office365E5NoAudioConferencing' -in $AddLicenses) {
            Write-Verbose -Message "Combination correct. 'AudioConferencing' can be added"
          }
        }
        #endregion

        #region Calling Plans
        # Checking combinations for Calling Plans
        if ('DomesticCallingPlan' -in $AddLicenses -and 'InternationalCallingPlan' -in $AddLicenses) {
          Write-Error -Message "Invalid combination of Calling Plan Licenses" -Category LimitsExceeded -RecommendedAction "Please select only one Calling Plan License!" -ErrorAction Stop
        }
        #endregion
      }

      if ($PSBoundParameters.ContainsKey('RemoveLicenses')) {
        Write-Verbose -Message "Validating input for Removing (identifying inconsistencies)"
        # No checks needed that aren't captured by the Add and Remove check! - Leaving this here just in case.
        Write-Verbose -Message "NOTE: Currently no checks for Remove Licenses necessary"
      }

      if ($PSBoundParameters.ContainsKey('RemoveAllLicenses') -and -not $PSBoundParameters.ContainsKey('AddLicenses')) {
        Write-Warning -Message "This will leave the Object without ANY License!"
        if (-not (Get-Consent)) {
          throw "No consent given. Aborting execution!"
        }
      }

    }
    catch {
      throw
    }

    #endregion

    #region Queries
    # Querying licenses in the Tenant to compare SKUs
    try {
      Write-Verbose -Message "Querying Licenses from the Tenant" -Verbose
      $TenantLicenses = Get-TeamsTenantLicense -ErrorAction STOP
    }
    catch {
      Write-Warning $_
      return
    }
    #endregion

    Write-Verbose -Message "Processing Licenses:"
    #region AddLicenses
    if ($PSBoundParameters.ContainsKey('AddLicenses')) {
      Write-Verbose -Message "Parsing array 'AddLicenses'" -Verbose
      try {
        # Creating Array of $AddSkuIds to pass to New-AzureAdLicenseObject
        [System.Collections.ArrayList]$AddSkuIds = @()
        foreach ($AddLic in $AddLicenses) {
          $SkuPartNumber = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('SkuPartNumber')
          $AddSku = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('SkuId')
          $AddLicName = ($AllLicenses | Where-Object ParameterName -EQ $AddLic).('FriendlyName')

          #region Verifying license is available in the Tenant
          if (-not ($SkuPartNumber -in $($TenantLicenses.SkuPartNumber))) {
            Write-Error -Message "'$AddLicName' - License not found in the Tenant" -ErrorAction Stop
          }
          else {
            $RemainingLics = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber }).Remaining
            if ($RemainingLics -lt 1) {
              Write-Error -Message "'$AddLicName' - License found in the Tenant, but no units available" -ErrorAction Stop
            }
            else {
              Write-Verbose -Message "'$AddLicName' - License found in the Tenant. Free unit available!" -Verbose
            }
          }
          #endregion

          $AddSkuIds.Add("$AddSku")
          Write-Verbose -Message "Preparing License Object: Adding   '$AddLicName'"
        }

      }
      catch {
        throw
      }
    }
    #endregion

    #region RemoveLicenses
    if ($PSBoundParameters.ContainsKey('RemoveLicenses')) {
      Write-Verbose -Message "Parsing array 'RemoveLicenses'" -Verbose
      try {
        # Creating Array of $RemoveSkuIds to pass to New-AzureAdLicenseObject
        [System.Collections.ArrayList]$RemoveSkuIds = @()
        foreach ($RemoveLic in $RemoveLicenses) {
          $RemoveSku = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('SkuId')
          $RemoveLicName = ($AllLicenses | Where-Object ParameterName -EQ $RemoveLic).('FriendlyName')
          $RemoveSkuIds.Add("$RemoveSku")
          Write-Verbose -Message "Preparing License Object: Removing '$RemoveLicName'"
        }
      }
      catch {
        throw
      }
    }
    #endregion

    # Parsing RemoveAllLicenses is user specific and has to be done in PROCESS

  }

  process {
    foreach ($ID in $Identity) {
      #region Object Verification
      # Querying User
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -ErrorAction STOP
      }
      catch {
        Write-Error -Message "User Account not valid" -Category ObjectNotFound -RecommendedAction "Verify UserPrincipalName"
        return
      }

      # Checking Usage Location is Set
      try {
        if ($null -eq $UserObject.UsageLocation) {
          throw
        }
      }
      catch {
        Write-Error -Message "Usage Location not set" -Category InvalidResult -RecommendedAction "Set Usage Location, then try assigning a License again"
        return
      }
      #endregion


      #region RemoveAllLicenses (dependent on Licenses currently on User)
      if ($PSBoundParameters.ContainsKey('RemoveAllLicenses')) {
        Write-Verbose -Message "Parsing switch 'RemoveAllLicenses'" -Verbose
        try {
          # Creating Array of $RemoveSkuIds to pass to New-AzureAdLicenseObject
          $AllSkus = (Get-AzureADUserLicenseDetail -ObjectId $User).SkuPartNumber

          [System.Collections.ArrayList]$RemoveAllSkuIds = @()
          foreach ($RemoveLic in $AllSkus) {
            $RemoveSku = ($AllLicenses | Where-Object SkuPartNumber -EQ $RemoveLic).('SkuId')
            $RemoveLicName = ($AllLicenses | Where-Object SkuPartNumber -EQ $RemoveLic).('FriendlyName')
            $RemoveAllSkuIds.Add("$RemoveSku")
            Write-Verbose -Message "Preparing License Object: Removing '$RemoveLicName'"
          }

          <# Alternative
          $RemoveAllSkuIds = Get-AzureADUser -ObjectID $ID | Select-Object -ExpandProperty AssignedLicenses | Select-Object SkuID
          [System.Collections.ArrayList]$RemoveAllSkuIds = @()
          foreach ($Lic in $RemoveAllSkuIds) {
            Write-Verbose -Message "Preparing License Object: Removing Sku '$Lic'"
          }
          #>
        }
        catch {
          throw
        }
      }
      #endregion

      #region Creating User specific License Object
      $NewLicenseObjParameters = $null
      if ($PSBoundParameters.ContainsKey('AddLicenses')) {
        $NewLicenseObjParameters += @{'SkuId' = $AddSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('RemoveLicenses')) {
        $NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveSkuIds }
      }
      if ($PSBoundParameters.ContainsKey('RemoveAllLicenses')) {
        $NewLicenseObjParameters += @{'RemoveSkuId' = $RemoveAllSkuIds }
      }

      $LicenseObject = New-AzureAdLicenseObject @NewLicenseObjParameters
      Write-Verbose -Message "Creating License Object: Done"
      #endregion

      # Executing Assignment
      if ($PSCmdlet.ShouldProcess("$ID", "Set-AzureADUserLicense")) {
        #Assign $LicenseObject to each User
        Write-Verbose -Message "'$ID' - Applying License"
        Set-AzureADUserLicense -ObjectId $ID -AssignedLicenses $LicenseObject
        Write-Verbose -Message "'$ID' - Applying License: Done"
      }
    }
    #endregion
  }
}
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
  .FUNCTIONALITY
		Returns a list of Licenses depending on input
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Test-TeamsUserLicense
  #>
  [CmdletBinding(DefaultParameterSetName = 'General')]
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

    [Parameter(Mandatory = $true, ParameterSetName = 'PhoneSystemVirtualUser', HelpMessage = "This is an exclusive licence!")]
    [switch]$AddPhoneSystemVirtualUser,

    [Parameter(Mandatory = $true, ParameterSetName = 'CommonAreaPhone', HelpMessage = "This is an exclusive licence!")]
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
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    Write-Verbose -Message "This function is deprecated. It is still functional, but limited. Please use Set-TeamsUserLicense instead" -Verbose

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
  } # End of BEGIN

  process {
    foreach ($ID in $Identity) {
      try {
        $UserObject = Get-AzureADUser -ObjectId "$ID" -ErrorAction STOP
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
          break
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
          Write-Error -Message "Non-Resource Account determined. No replacement can be executed" -Category InvalidOperation -RecommendedAction "Verify Account Type is correct. For Resource Accounts, verify Department is set to 'Microsoft Communication Application Instance'"
          break
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
	.PARAMETER IdleTimeout
		Optional. Defines the IdleTimeout of the session in full hours between 1 and 8. Default is 4 hrs.
		Note, by default, creating a session with New-CsSkypeOnlineSession results in a Timeout of 15mins!
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
    [Parameter(Mandatory = $false)]
    [string]$UserName,

    [Parameter(Mandatory = $false)]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Helpmessage = "Idle Timeout of the session in hours between 1 and 8; Default is 4")]
    [ValidateRange(1, 8)]
    [int]$IdleTimeout = 4
  )

  # Required as Warnings on the OriginalRegistrarPool may halt Script execution
  $WarningPreference = "Continue"

  #region SessionOptions
  # Generating Session Options (Timeout) based on input
  $IdleTimeoutInMS = $IdleTimeout * 3600000
  if ($PSboundparameters.ContainsKey('IdleTimeout')) {
    $SessionOption = New-PSSessionOption -IdleTimeout $IdleTimeoutInMS
  }
  else {
    $SessionOption = New-PSSessionOption -IdleTimeout 14400000
  }
  Write-Verbose -Message "Idle Timeout for session established: $IdleTimeout hours"

  #endregion

  # Testing exisiting Module and Connection
  if (Test-Module SkypeOnlineConnector) {
    if ((Test-SkypeOnlineConnection) -eq $false) {
      $moduleVersion = (Get-Module -Name SkypeOnlineConnector).Version
      Write-Verbose -Message "Module SkypeOnlineConnctor installed in Version: $moduleVersion"
      if ($moduleVersion.Major -le "6") {
        # Version 6 and lower do not support MFA authentication for Skype Module PowerShell; also allows use of older PSCredential objects
        try {
          $SkypeOnlineSession = New-CsOnlineSession -Credential (Get-Credential $UserName -Message "Enter the sign-in address and password of a Global or Skype for Business Admin") -ErrorAction STOP
          Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
        }
        catch {
          $errorMessage = $_
          if ($errorMessage -like "*Making sure that you have used the correct user name and password*") {
            Write-Warning -Message "Logon failed. Please try again and make sure that you have used the correct user name and password."
          }
          elseif ($errorMessage -like "*Please create a new credential object*") {
            Write-Warning -Message "Logon failed. This may be due to multi-factor being enabled for the user account and not using the latest Skype for Business Online PowerShell module."
          }
          else {
            Write-Warning -Message $_
          }
        }
      }
      else {
        # This should be all newer version than 6; does not support PSCredential objects but supports MFA
        try {
          # Constructing Parameters to be passed to New-CsOnlineSession
          Write-Verbose -Message "Constructing parameter list to be passed on to New-CsOnlineSession"
          $Parameters = $null
          if ($PSBoundParameters.ContainsKey("UserName")) {
            Write-Verbose -Message "Adding: Username: $Username"
            $Parameters += @{'UserName' = $UserName }
          }
          if ($PSBoundParameters.ContainsKey('OverrideAdminDomain')) {
            Write-Verbose -Message "OverrideAdminDomain: Provided: $OverrideAdminDomain"
            $Parameters += @{'OverrideAdminDomain' = $OverrideAdminDomain }
          }
          else {
            $UserNameDomain = $UserName.Split('@')[1]
            $Parameters += @{'OverrideAdminDomain' = $UserNameDomain }

          }
          Write-Verbose -Message "Adding: SessionOption with IdleTimeout $IdleTimeout (hrs)"
          $Parameters += @{'SessionOption' = $SessionOption }
          Write-Verbose -Message "Adding: Common Parameters"
          $Parameters += @{'ErrorAction' = 'STOP' }
          $Parameters += @{'WarningAction' = 'Continue' }

          # Creating Session
          Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
          $SkypeOnlineSession = New-CsOnlineSession @Parameters
        }
        catch [System.Net.WebException] {
          try {
            Write-Warning -Message "Session could not be created. Maybe missing OverrideAdminDomain to connect?"
            $Domain = Read-Host "Please enter an OverrideAdminDomain for this Tenant"
            # $Paramters +=@{'OverrideAdminDomain' = $Domain} # This works only if no OverrideAdminDomain is yet in the $Parameters Array. Current config means it will be there!
            $Parameters.OverrideAdminDomain = $Domain
            # Creating Session (again)
            Write-Verbose -Message "Creating Session with New-CsOnlineSession and these parameters: $($Parameters.Keys)"
            $SkypeOnlineSession = New-CsOnlineSession @Parameters
          }
          catch {
            Write-Error -Message "Session creation failed" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Managment Role activation"
            Write-ErrorRecord $_
          }
        }
        catch {
          Write-Error -Message "Session creation failed" -Category NotEnabled -RecommendedAction "Please verify input, especially Password, OverrideAdminDomain and, if activated, Azure AD Privileged Identity Managment Role activation"
          Write-ErrorRecord $_
        }

        # Separated session creation from Import for better troubleshooting
        if ($Null -ne $SkypeOnlineSession) {
          try {
            Import-Module (Import-PSSession -Session $SkypeOnlineSession -AllowClobber -ErrorAction STOP) -Global
            $null = Enable-CsOnlineSessionForReconnection
          }
          catch {
            Write-Verbose -Message "Session import failed - Error for troubleshooting" -Verbose
            Write-ErrorRecord $_
          }

          #region For v7 and higher: run Enable-CsOnlineSessionForReconnection
          if (Test-SkypeOnlineConnection) {
            $moduleVersion = (Get-Module -Name SkypeOnlineConnector).Version
            Write-Verbose -Message "SkypeOnlineConnector Module is installed in Version $ModuleVersion" -Verbose
            Write-Verbose -Message "Your Session will time out after $IdleTimeout hours" -Verbose
            if ($moduleVersion.Major -ge "7") {
              # v7 and higher can run Session Limit Extension
              try {
                Enable-CsOnlineSessionForReconnection -WarningAction SilentlyContinue -ErrorAction STOP
                Write-Verbose -Message "Enable-CsOnlienSessionForReconnection was run; The session should reconnect, allowing it to be re-used without having to launch a new instance to reconnect." -Verbose
              }
              catch {
                Write-ErrorRecord $_
              }
            }
            else {
              Write-Verbose -Message "Enable-CsOnlienSessionForReconnection is unavailable; To prevent having to re-authenticate, Update this module to v7 or higher" -Verbose
              Write-Verbose -Message "You can download the Module here: https://www.microsoft.com/download/details.aspx?id=39366" -Verbose
            }
          }
          #endregion
        }
      } # End of if statement for module version checking
    }
    else {
      Write-Warning -Message "A valid Skype Online PowerShell Sessions already exists. Please run Disconnect-SkypeOnline before attempting this command again."
    } # End checking for existing Skype Online Connection
  }
  else {
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
	.PARAMETER ExchangeOnline
		Optional. Connects to Exchange Online Management. Requires Exchange Admin Role
	.PARAMETER OverrideAdminDomain
		Optional. Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
    NOTE: The OverrideAdminDomain is handled by Connect-SkypeOnline (prompts if no connection can be established)
    Using the Parameter here is using it explicitely
	.PARAMETER Silent
		Optional. Suppresses output session information about established sessions. Used for calls by other functions
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com
		Connects to SkypeOnline, MicrosoftTeams & AzureAD prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -AzureAD
		Connects to SkypeOnline and AzureAD prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -ExchangeOnline
    Connects to SkypeOnline and ExchangeOnline prompting ONCE for a Password for 'admin@domain.com'
	.EXAMPLE
		Connect-SkypeTeamsAndAAD -Username admin@domain.com -SkypeOnline -OverrideAdminDomain domain.co.uk
    Connects to SkypeOnline prompting ONCE for a Password for 'admin@domain.com' using the explicit OverrideAdminDomain domain.co.uk
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

    [Parameter(Mandatory = $false, HelpMessage = 'Establises a connection to Exchange Online. Reuses credentials if authenticated already.')]
    [Alias('Exchange')]
    [switch]$ExchangeOnline,

    [Parameter(Mandatory = $false, HelpMessage = 'Domain used to connect to for SkypeOnline if DNS points to OnPrem Skype')]
    [AllowNull()]
    [string]$OverrideAdminDomain,

    [Parameter(Mandatory = $false, HelpMessage = 'Suppresses Session Information output')]
    $Silent

  )

  #region Preparation
  $WarningPreference = "Continue"

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
  $null = (Disconnect-SkypeTeamsAndAAD -ErrorAction SilentlyContinue)
  #endregion


  #region Connections
  #region SkypeOnline
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
      Write-Host "Could not establish Connection to SkypeOnline, please verify Username, Password, OverrideAdminDomain and Session Exhaustion (2 max!)" -Foregroundcolor Red
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }

    Start-Sleep 1
    if ((Test-SkypeOnlineConnection) -and -not $Silent) {
      $PSSkypeOnlineSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available" } -WarningAction STOP -ErrorAction STOP
      $TenantInformation = Get-CsTenant -WarningAction SilentlyContinue -ErrorAction STOP
      $TenantDomain = $TenantInformation.Domains | Select-Object -Last 1
      $Timeout = $PSSkypeOnlineSession.IdleTimeout / 3600000

      $PSSkypeOnlineSessionInfo = [PSCustomObject][ordered]@{
        Account                   = $UserName
        Environment               = 'SfBPowerShellSession'
        Tenant                    = $TenantInformation.DisplayName
        TenantId                  = $TenantInformation.TenantId
        TenantDomain              = $TenantDomain
        ComputerName              = $PSSkypeOnlineSession.ComputerName
        IdleTimeoutInHours        = $Timeout
        TeamsUpgradeEffectiveMode = $TenantInformation.TeamsUpgradeEffectiveMode
      }

      $PSSkypeOnlineSessionInfo
    }
  }
  #endregion

  #region AzureAD
  if ($ConnectALL -or $ConnectToAAD) {
    try {
      Write-Verbose -Message "Establishing connection to AzureAD" -Verbose
      $null = (Connect-AzureAD -AccountID $Username)
      Start-Sleep 1
      if ((Test-AzureADConnection) -and -not $Silent) {
        Get-AzureADCurrentSessionInfo
      }
    }
    catch {
      Write-Host "Could not establish Connection to AzureAD, please verify Module and run Connect-AzureAD manually" -Foregroundcolor Red
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
  }
  #endregion

  #region MicrosoftTeams
  if ($ConnectALL -or $ConnectToTeams) {
    try {
      if ( !(Test-Module MicrosoftTeams)) {
        Import-Module MicrosoftTeams -Force -ErrorAction SilentlyContinue
      }
      Write-Verbose -Message "Establishing connection to MicrosoftTeams" -Verbose
      if ((Test-MicrosoftTeamsConnection) -and -not $Silent) {
        Connect-MicrosoftTeams -AccountID $Username
      }
      else {
        $null = (Connect-MicrosoftTeams -AccountID $Username)
      }
    }
    catch {
      Write-Host "Could not establish Connection to MicrosoftTeams, please verify Module and run Connect-MicrosoftTeams manually" -Foregroundcolor Red
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
  }
  #endregion

  #region ExchangeOnline
  if ($PSBoundParameters.ContainsKey('ExchangeOnline')) {
    try {
      if ( !(Test-Module ExchangeOnlineManagement)) {
        Import-Module ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue
      }
      Write-Verbose -Message "Establishing connection to ExchangeOnlineManagement" -Verbose
      if ((Test-ExchangeOnlineConnection) -and -not $Silent) {
        Connect-ExchangeOnline -UserPrincipalName $Username -ShowProgress:$true -ShowBanner:$false
      }
      else {
        $null = (Connect-ExchangeOnline -UserPrincipalName $Username -ShowProgress:$true -ShowBanner:$false)
      }
    }
    catch {
      Write-Host "Could not establish Connection to ExchangeOnlineManagement, please verify Module and run Connect-ExchangeOnline manually" -Foregroundcolor Red
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
  }
  #endregion

  #region Display Admin Roles
  if ((Test-AzureADConnection) -and -not $Silent) {
    Write-Host "Displaying assigned Admin Roles for Account: " -ForegroundColor Magenta -NoNewline
    Write-Host "$Username"
    Get-AzureAdAssignedAdminRoles (Get-AzureADCurrentSessionInfo).Account | Select-Object DisplayName, Description | Format-Table -AutoSize
  }
  #endregion
  #endregion
  return
}

function Disconnect-SkypeTeamsAndAAD {
  <#
	.SYNOPSIS
		Disconnect from SkypeOnline, Teams, AzureAD
	.DESCRIPTION
		Helper function to disconnect from SkypeOnline, Teams, AzureAD
	.NOTES
    Helper function to disconnect from SkypeOnline, Teams, AzureAD
    To disconnect from ExchangeOnline, please run Disconnect-ExchangeOnline
	#>

  Import-Module SkypeOnlineConnector
  Import-Module MicrosoftTeams -Force # Must import Forcefully as the command otherwise fails (not available)
  Import-Module AzureAD

  try {
    $null = (Disconnect-SkypeOnline -ErrorAction SilentlyContinue)
    $null = (Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue)
    $null = (Disconnect-AzureAD -ErrorAction SilentlyContinue)
  }
  catch [NullReferenceException] {
    # Disconnecting from AzureAD results in a duplicated error which the ERRORACTION only suppresses one of.
    # This is to capture the second
    Write-Verbose -Message "AzureAD: Caught NullReferenceException. Not to worry"
  }
  catch {
    Write-ErrorRecord $_
  }
}

Set-Alias -Name con -Value Connect-SkypeTeamsAndAAD
Set-Alias -Name Connect-Me -Value Connect-SkypeTeamsAndAAD
Set-Alias -Name Disconnect-Me -Value Disconnect-SkypeTeamsAndAAD
Set-Alias -Name dis -Value Disconnect-SkypeTeamsAndAAD

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

  $PSSesssions = Get-PSSession  -WarningAction SilentlyContinue

  foreach ($session in $PSSesssions) {
    if ($session.ComputerName -like "*.online.lync.com") {
      $sessionFound = $true
      Remove-PSSession $session
    }
  }

  Get-Module | Where-Object { $_.Description -like "*.online.lync.com*" } | Remove-Module

  if ($sessionFound -eq $false) {
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
    [Parameter(Mandatory = $true, HelpMessage = "Enter the domain name to gather the available conference dial-in numbers")]
    [string]$Domain
  )

  # Testing SkypeOnline Connection
  if (Test-SkypeOnlineConnection) {
    Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
  }
  else {
    if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
      Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
      $null = Get-CsTenant
    }
    else {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }
  }

  try {
    $siteContents = Invoke-WebRequest https://webdir1a.online.lync.com/DialinOnline/Dialin.aspx?path=$Domain -ErrorAction STOP
  }
  catch {
    Write-Warning -Message "Unable to access that dial-in page. Please check the domain name and try again. Also try to manually navigate to the page using the URL http://dialin.lync.com/DialInOnline/Dialin.aspx?path=$Domain."
    return
  }

  $tables = $siteContents.ParsedHtml.getElementsByTagName("TABLE")
  $table = $tables[0]
  $rows = @($table.rows)

  $output = [PSCustomObject][ordered]@{
    Location  = $null
    Number    = $null
    Languages = $null
  }

  for ($n = 0; $n -lt $rows.Count; $n += 1) {
    if ($rows[$n].innerHTML -like "<TH*") {
      $output.Location = $rows[$n].innerText
    }
    else {
      $output.Number = $rows[$n].cells[0].innerText
      $output.Languages = $rows[$n].cells[1].innerText
      Write-Output $output
    }
  }
} # End of Get-SkypeOnlineConferenceDialInNumbers

function Get-TeamsUserLicense {
  <#
	.SYNOPSIS
    Returns License information for an Object in AzureAD
  .DESCRIPTION
    Returns an Object containing all Teams related Licenses found for a specific Object
		This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License
	.PARAMETER Identity
		The Identity/UPN/sign-in address for the user entered in the format <name>@<domain>.
    Aliases include: "UPN","UserPrincipalName","Username"
  .PARAMETER DisplayAll
    Displays all ServicePlans, not only relevant Teams Plans
	.EXAMPLE
		Get-TeamsUserLicense -Identity John@domain.com
		Displays all licenses assigned to User John@domain.com
	.EXAMPLE
		Get-TeamsUserLicense -Identity John@domain.com,Jane@domain.com
		Displays all licenses assigned to Users John@domain.com and Jane@domain.com
	.EXAMPLE
		Import-Csv User.csv | Get-TeamsUserLicense
    Displays all liceneses assigned to Users from User.csv, Column Identity.
    The input file must have a single column heading of "Identity" with properly formatted UPNs.
	.NOTES
		Requires a connection to Azure Active Directory
  .FUNCTIONALITY
		Returns a list of Licenses assigned to a specific User depending on input
  .LINK
    Get-TeamsTenantLicense
    Set-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Test-TeamsUserLicense
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true,
      HelpMessage = "Enter the UPN or login name of the user account, typically <user>@<domain>.")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string[]]$Identity,

    [Parameter(Mandatory = $false, HelpMessage = "Displays all ServicePlans")]
    [switch]$DisplayAll
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # preparing Output Field Separator
    $OFS = ", "

    # Loading License Array
    $AllLicenses = $null
    $AllLicenses = $TeamsLicenses
    $AllServicePlans = $null
    $AllServicePlans = $TeamsServicePlans

  }

  process {
    foreach ($User in $Identity) {
      try {
        Get-AzureADUser -ObjectId "$User" -ErrorAction STOP | Out-Null
      }
      catch {
        throw $_
        continue
      }

      $UserObject = Get-AzureADUser -ObjectId "$User"
      [string]$DisplayName = $UserObject.DisplayName

      # Querying Licenses
      $assignedSkuPartNumbers = (Get-AzureADUserLicenseDetail -ObjectId $User).SkuPartNumber
      [System.Collections.ArrayList]$UserLicenses = @()
      foreach ($PartNumber in $assignedSkuPartNumbers) {
        $Lic = $null
        $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ $Partnumber
        if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          [void]$UserLicenses.Add($Lic)
        }
      }
      $UserLicensesSorted = $UserLicenses | Sort-Object IncludesTeams, IncludesPhoneSystem, FriendlyName
      [string]$LicensesFriendlyNames = ($UserLicensesSorted | Where-Object FriendlyName -ne $null).FriendlyName

      # Querying Service Plans
      $assignedServicePlans = (Get-AzureADUserLicenseDetail -ObjectId $User).ServicePlans | Sort-Object ServicePlanName
      [System.Collections.ArrayList]$UserServicePlans = @()
      foreach ($ServicePlan in $assignedServicePlans) {
        $Lic = $null
        $Lic = $AllServicePlans | Where-Object ServicePlanName -EQ $ServicePlan.ServicePlanName
        if ($null -ne $Lic -or $PSBoundParameters.ContainsKey('DisplayAll')) {
          $LicObj = [PSCustomObject][ordered]@{
            FriendlyName       = $Lic.FriendlyName
            ServicePlanName    = $ServicePlan.ServicePlanName
            ProvisioningStatus = $ServicePlan.ProvisioningStatus
          }
          [void]$UserServicePlans.Add($LicObj)
        }
      }
      $UserServicePlansSorted = $UserServicePlans | Sort-Object Friendlyname, ProvisioningStatus, ServicePlanNam
      [string]$ServicePlansFriendlyNames = ($UserServicePlansSorted | Where-Object FriendlyName -ne $null).FriendlyName

      $PhoneSystemLicense = ("MCOEV" -in $UserServicePlans.ServicePlanName)
      $AudioConfLicense = ("MCOMEETADV" -in $UserServicePlans.ServicePlanName)
      $PhoneSystemVirtual = ("MCOEV_VIRTUALUSER" -in $UserServicePlans.ServicePlanName)
      $CommonAreaPhoneLic = ("MCOCAP" -in $UserServicePlans.ServicePlanName)
      $CommunicationCreds = ("MCOPSTNC" -in $UserServicePlans.ServicePlanName)
      $CallingPlanDom = ("MCOPSTN1" -in $UserServicePlans.ServicePlanName)
      $CallingPlanInt = ("MCOPSTN2" -in $UserServicePlans.ServicePlanName)

      if ($CallingPlanDom) {
        $currentCallingPlan = $AllLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN1"
      }
      elseif ($CallingPlanInt) {
        $currentCallingPlan = $AllLicenses | Where-Object SkuPartNumber -EQ "MCOPSTN2"
      }
      else {
        [string]$currentCallingPlan = $null
      }

      $output = [PSCustomObject][ordered]@{
        User                      = $User
        DisplayName               = $DisplayName
        LicensesFriendlyNames     = $LicensesFriendlyNames
        ServicePlansFriendlyNames = $ServicePlansFriendlyNames
        AudioConferencing         = $AudioConfLicense
        CommoneAreaPhoneLicense   = $CommonAreaPhoneLic
        PhoneSystemVirtualUser    = $PhoneSystemVirtual
        PhoneSystem               = $PhoneSystemLicense
        CallingPlanDomestic       = $CallingPlanDom
        CallingPlanInternational  = $CallingPlanInt
        CommunicationsCredits     = $CommunicationCreds
        CallingPlan               = $currentCallingPlan
        Licenses                  = $UserLicensesSorted
        ServicePlans              = $UserServicePlansSorted

      }

      Write-Output $output
    }
  }
}

function Get-TeamsTenantLicense {
  <#
	.SYNOPSIS
		Returns one or all Teams Tenant licenses from a Tenant
  .DESCRIPTION
    Returns an Object containing Teams related Licenses found in the Tenant
		Teams services can be provisioned through several different combinations of individual
		plans as well as add-on and grouped license SKUs. This command displays these license SKUs in a more friendly
    format with descriptive names, SKUpartNumber, active, consumed, remaining, and expiring licenses.
  .PARAMETER License
    Optional. Limits the Output to one license.
    Accepted Values are listed in $TeamsLicenses.ParameterName
  .PARAMETER ConciseView
    Displays only Parameters relevant to determine License availability
  .PARAMETER DisplayAll
    Displays all Licenses, not only relevant Teams Licenses
	.EXAMPLE
		Get-TeamsTenantLicense
		Displays detailed information about all Teams related licenses found on the tenant.
	.EXAMPLE
		Get-TeamsTenantLicense -License PhoneSystem
    Displays detailed information about the PhoneSystem license found on the tenant.
  .EXAMPLE
		Get-TeamsTenantLicense -ConciseView
		Displays all Teams Licenses found on the tenant, but only Name and counters.
  .EXAMPLE
		Get-TeamsTenantLicense -DisplayAll
		Displays detailed information about all licenses found on the tenant.
  .EXAMPLE
		Get-TeamsTenantLicense -ConciseView -DisplayAll
		Displays a concise view of all licenses found on the tenant.
  .NOTES
    Requires a connection to Azure Active Directory
  .FUNCTIONALITY
		Returns a list of Licenses on the Tenant depending on input
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
    Test-TeamsUserLicense
	#>

  [CmdletBinding()]
  [OutputType([Object[]])]
  param(
    [Parameter(Mandatory = $false, HelpMessage = 'License to be queried from the Tenant')]
    [ValidateSet('Microsoft365A3faculty', 'Microsoft365A3students', 'Microsoft365A5faculty', 'Microsoft365A5students', 'Microsoft365BusinessBasic', 'Microsoft365BusinessStandard', 'Microsoft365BusinessPremium', 'Microsoft365E3', 'Microsoft365E5', 'Microsoft365F1', 'Microsoft365F3', 'Office365A5faculty', 'Office365A5students', 'Office365E1', 'Office365E2', 'Office365E3', 'Office365E3Dev', 'Office365E4', 'Office365E5', 'Office365E5NoAudioConferencing', 'Office365F1', 'Microsoft365E3USGOVDOD', 'Microsoft365E3USGOVGCCHIGH', 'Office365E3USGOVDOD', 'Office365E3USGOVGCCHIGH', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone', 'SkypeOnlinePlan2', 'AudioConferencing', 'InternationalCallingPlan', 'DomesticCallingPlan', 'DomesticCallingPlan120', 'CommunicationCredits', 'SkypeOnlinePlan1')]
    [string]$License,

    [Parameter(Mandatory = $false, HelpMessage = "Displays only required Parameters")]
    [switch]$ConciseView,

    [Parameter(Mandatory = $false, HelpMessage = "Displays all ServicePlans")]
    [switch]$DisplayAll
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    #Loading License Array
    $AllLicenses = $null
    if ($PSBoundParameters.ContainsKey('ConciseView')) {
      $AllLicenses = $TeamsLicenses | Select-Object FriendlyName, SkuPartNumber
    }
    else {
      $AllLicenses = $TeamsLicenses
    }

    $AllLicenses | Add-Member -NotePropertyName Available -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Consumed -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Remaining -NotePropertyValue 0 -Force
    $AllLicenses | Add-Member -NotePropertyName Expiring -NotePropertyValue 0 -Force


    try {
      if ($PSBoundParameters.ContainsKey('License')) {
        $TenantID = (Get-AzureADCurrentSessionInfo).TenantId
        $SKU = ($TeamsLicenses | Where-Object ParameterName -EQ $License).SkuId
        $ObjectId = "$TenantID" + "_" + "$SKU"
        $tenantSKUs = Get-AzureADSubscribedSku -ObjectId $ObjectId -ErrorAction STOP
      }
      else {
        $tenantSKUs = Get-AzureADSubscribedSku -ErrorAction STOP
      }
    }
    catch {
      Write-Warning $_
      return
    }


  }

  process {

    [System.Collections.ArrayList]$TenantLicenses = @()
    foreach ($tenantSKU in $tenantSKUs) {
      $Lic = $null
      $Lic = $AllLicenses | Where-Object SkuPartNumber -EQ $($TeamsLicenses | Where-Object SkuId -EQ "$($tenantSKU.SkuId)").SkuPartNumber

      if ($null -ne $Lic) {
        $Lic.Available = $($tenantSKU.PrepaidUnits.Enabled)
        $Lic.Consumed = $($tenantSKU.ConsumedUnits)
        $Lic.Remaining = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
        $Lic.Expiring = $($tenantSKU.PrepaidUnits.Warning)

        [void]$TenantLicenses.Add($Lic)
      }
      else {
        if ($PSBoundParameters.ContainsKey('DisplayAll')) {
          if ($PSBoundParameters.ContainsKey('ConciseView')) {
            $NewLic = [PSCustomObject][ordered]@{
              SkuPartNumber = $tenantSKU.SkuPartNumber
              LicenseType   = "Unknown"
              Available     = $($tenantSKU.PrepaidUnits.Enabled)
              Consumed      = $($tenantSKU.ConsumedUnits)
              Remaining     = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
              Expiring      = $($tenantSKU.PrepaidUnits.Warning)
            }
            [void]$TenantLicenses.Add($NewLic)
          }
          else {
            $NewLic = [PSCustomObject][ordered]@{
              FriendlyName        = $null
              SkuPartNumber       = $tenantSKU.SkuPartNumber
              SkuId               = $tenantSKU.SkuId
              LicenseType         = "Unknown"
              ParameterName       = $null
              IncludesTeams       = $null
              IncludesPhoneSystem = $null
              Available           = $($tenantSKU.PrepaidUnits.Enabled)
              Consumed            = $($tenantSKU.ConsumedUnits)
              Remaining           = $($tenantSKU.PrepaidUnits.Enabled - $tenantSKU.ConsumedUnits)
              Expiring            = $($tenantSKU.PrepaidUnits.Warning)
            }
            [void]$TenantLicenses.Add($NewLic)
          }
        }
        else {
          if ($PSBoundParameters.ContainsKey('ConciseView')) {
            # no action - Verbose message will be suppressed.
          }
          else {
            Write-Verbose "No entry in Database found for '$($tenantSKU.SkuId)' - Use DisplayAll to show"
          }
        }
      }


    }
  }
  end {
    return $TenantLicenses
  }
}
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

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the name of the dial plan to modify the normalization rules.")]
    [string]$DialPlan
  )

  if (-not $PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
  }
  if (-not $PSBoundParameters.ContainsKey('Confirm')) {
    $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
  }
  if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
    $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
  }

  # Testing SkypeOnline Connection
  if ($false -eq (Test-SkypeOnlineConnection)) {
    Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-SkypeTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  $dpInfo = Get-CsTenantDialPlan -Identity $DialPlan -ErrorAction SilentlyContinue

  if ($null -ne $dpInfo) {
    $currentNormRules = $dpInfo.NormalizationRules
    [int]$ruleIndex = 0
    [int]$ruleCount = $currentNormRules.Count
    [array]$ruleArray = @()
    [array]$indexArray = @()

    if ($ruleCount -ne 0) {
      foreach ($normRule in $dpInfo.NormalizationRules) {
        $output = [PSCustomObject][ordered]@{
          'RuleIndex'   = $ruleIndex
          'Name'        = $normRule.Name
          'Pattern'     = $normRule.Pattern
          'Translation' = $normRule.Translation
        }

        $ruleArray += $output
        $indexArray += $ruleIndex
        $ruleIndex++
      } # End of foreach ($normRule in $dpInfo.NormalizationRules)

      # Displays rules to the screen with RuleIndex added
      $ruleArray | Out-Host

      do {
        $indexToRemove = Read-Host -Prompt "Enter the Rule Index of the normalization rule to remove from the dial plan (leave blank to quit without changes)"

        if ($indexToRemove -notin $indexArray -and $indexToRemove.Length -ne 0) {
          Write-Warning -Message "That is not a valid Rule Index. Please try again or leave blank to quit."
        }
      } until ($indexToRemove -in $indexArray -or $indexToRemove.Length -eq 0)

      if ($indexToRemove.Length -eq 0) { RETURN }

      # If there is more than 1 rule left, remove the rule and set to new normalization rules
      # If there is only 1 rule left, we have to set -NormalizationRules to $null
      if ($ruleCount -ne 1) {
        $newNormRules = $currentNormRules
        $newNormRules.Remove($currentNormRules[$indexToRemove])
        if ($PSCmdlet.ShouldProcess("$DialPlan", "Set-CsTenantDialPlan")) {
          Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $newNormRules
        }
      }
      else {
        if ($PSCmdlet.ShouldProcess("$DialPlan", "Set-CsTenantDialPlan")) {
          Set-CsTenantDialPlan -Identity $DialPlan -NormalizationRules $null
        }
      }
    }
    else {
      Write-Warning -Message "$DialPlan does not contain any normalization rules."
    }
  }
  else {
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

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the identity for the user to configure")]
    [Alias("UPN", "UserPrincipalName", "Username")]
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

  begin {
    # Testing SkypeOnline Connection
    if ($false -eq (Test-SkypeOnlineConnection)) {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-SkypeTeamsAndAAD can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Get available policies for tenant
    Write-Verbose -Message "Gathering all policies for tenant"
    $tenantTeamsUpgradePolicies = (Get-CsTeamsUpgradePolicy -WarningAction SilentlyContinue).Identity
    $tenantClientPolicies = (Get-CsClientPolicy -WarningAction SilentlyContinue).Identity
    $tenantConferencingPolicies = (Get-CsConferencingPolicy -Include SubscriptionDefaults -WarningAction SilentlyContinue).Identity
    $tenantExternalAccessPolicies = (Get-CsExternalAccessPolicy -WarningAction SilentlyContinue).Identity
    $tenantMobilityPolicies = (Get-CsMobilityPolicy -WarningAction SilentlyContinue).Identity
  } # End of BEGIN

  process {
    foreach ($ID in $Identity) {
      #User Validation
      # NOTE: Validating users in a try/catch block does not catch the error properly and does not allow for custom outputting of an error message
      if ($null -ne (Get-CsOnlineUser -Identity $ID -ErrorAction SilentlyContinue)) {
        #region Teams Upgrade Policy
        if ($PSBoundParameters.ContainsKey("TeamsUpgradePolicy")) {
          # Verify if $TeamsUpgradePolicy is a valid policy to assign
          if ($tenantTeamsUpgradePolicies -icontains "Tag:$TeamsUpgradePolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-TeamsUpgradePolicy -PolicyName $TeamsUpgradePolicy")) {
                Grant-TeamsUpgradePolicy -Identity $ID -PolicyName $TeamsUpgradePolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Success: $TeamsUpgradePolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Teams Upgrade Policy" -Result "Error: $TeamsUpgradePolicy is not valid or does not exist"
          }

          # Output final TeamsUpgradePolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Teams Upgrade Policy
        #endregion

        #region Client Policy
        if ($PSBoundParameters.ContainsKey("ClientPolicy")) {
          # Verify if $ClientPolicy is a valid policy to assign
          if ($tenantClientPolicies -icontains "Tag:$ClientPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsClientPolicy -PolicyName $ClientPolicy")) {
                Grant-CsClientPolicy -Identity $ID -PolicyName $ClientPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Success: $ClientPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid client policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Client Policy" -Result "Error: $ClientPolicy is not valid or does not exist"
          }

          # Output final ClientPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Client Policy
        #endregion

        #region Conferencing Policy
        if ($PSBoundParameters.ContainsKey("ConferencingPolicy")) {
          # Verify if $ConferencingPolicy is a valid policy to assign
          if ($tenantConferencingPolicies -icontains "Tag:$ConferencingPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsConferencingPolicy -PolicyName $ConferencingPolicy")) {
                Grant-CsConferencingPolicy -Identity $ID -PolicyName $ConferencingPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Success: $ConferencingPolicy"
              }
            }
            catch {
              # Output to error log file on policy assignment error
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid conferencing policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Conferencing Policy" -Result "Error: $ConferencingPolicy is not valid or does not exist"
          }

          # Output final ConferencingPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Conferencing Policy
        #endregion

        #region External Access Policy
        if ($PSBoundParameters.ContainsKey("ExternalAccessPolicy")) {
          # Verify if $ExternalAccessPolicy is a valid policy to assign
          if ($tenantExternalAccessPolicies -icontains "Tag:$ExternalAccessPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsExternalAccessPolicy -PolicyName $ExternalAccessPolicy")) {
                Grant-CsExternalAccessPolicy -Identity $ID -PolicyName $ExternalAccessPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Success: $ExternalAccessPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "External Access Policy" -Result "Error: $ExternalAccessPolicy is not valid or does not exist"
          }

          # Output final ExternalAccessPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting External Access Policy
        #endregion

        #region Mobility Policy
        if ($PSBoundParameters.ContainsKey("MobilityPolicy")) {
          # Verify if $MobilityPolicy is a valid policy to assign
          if ($tenantMobilityPolicies -icontains "Tag:$MobilityPolicy") {
            try {
              # Attempt to assign policy
              if ($PSCmdlet.ShouldProcess("$ID", "Grant-CsMobilityPolicy -PolicyName $MobilityPolicy")) {
                Grant-CsMobilityPolicy -Identity $ID -PolicyName $MobilityPolicy -WarningAction SilentlyContinue -ErrorAction STOP
                $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Success: $MobilityPolicy"
              }
            }
            catch {
              $errorMessage = $_
              $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $errorMessage"
            }
          }
          else {
            # Output invalid external access policy to error log file
            $output = GetActionOutputObject3 -Name $ID -Property "Mobility Policy" -Result "Error: $MobilityPolicy is not valid or does not exist"
          }

          # Output final MobilityPolicy Success or Fail message
          Write-Output -InputObject $output
        } # End of setting Mobility Policy
        #endregion
      } # End of setting policies
      else {
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
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory = $true, HelpMessage = "This is the domain name to test the external DNS Skype Online records.")]
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
    Name    = $federationSRV
    Type    = "SRV"
    Target  = $null
    Port    = $null
    Correct = "Yes"
    Notes   = $null
  }

  if ($null -ne $federationSRVResult) {
    $federationOutput.Target = $federationSRVResult.NameTarget
    $federationOutput.Port = $federationSRVResult.Port
    if ($federationOutput.Target -ne "sipfed.online.lync.com") {
      $federationOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $federationOutput.Correct = "No"
    }

    if ($federationOutput.Port -ne "5061") {
      $federationOutput.Notes += "Port is not set to 5061. "
      $federationOutput.Correct = "No"
    }
  }
  else {
    $federationOutput.Notes = "Federation SRV record does not exist. "
    $federationOutput.Correct = "No"
  }

  Write-Output -InputObject $federationOutput

  # SIP SRV Record Check
  $sipSRVResult = Resolve-DnsName -Name $sipSRV -Type SRV -ErrorAction SilentlyContinue
  $sipOutput = [PSCustomObject][ordered]@{
    Name    = $sipSRV
    Type    = "SRV"
    Target  = $null
    Port    = $null
    Correct = "Yes"
    Notes   = $null
  }

  if ($null -ne $sipSRVResult) {
    $sipOutput.Target = $sipSRVResult.NameTarget
    $sipOutput.Port = $sipSRVResult.Port
    if ($sipOutput.Target -ne "sipdir.online.lync.com") {
      $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $sipOutput.Correct = "No"
    }

    if ($sipOutput.Port -ne "443") {
      $sipOutput.Notes += "Port is not set to 443. "
      $sipOutput.Correct = "No"
    }
  }
  else {
    $sipOutput.Notes = "SIP SRV record does not exist. "
    $sipOutput.Correct = "No"
  }

  Write-Output -InputObject $sipOutput

  #Lyncdiscover Record Check
  $lyncdiscoverResult = Resolve-DnsName -Name $lyncdiscover -Type CNAME -ErrorAction SilentlyContinue
  $lyncdiscoverOutput = [PSCustomObject][ordered]@{
    Name    = $lyncdiscover
    Type    = "CNAME"
    Target  = $null
    Port    = $null
    Correct = "Yes"
    Notes   = $null
  }

  if ($null -ne $lyncdiscoverResult) {
    $lyncdiscoverOutput.Target = $lyncdiscoverResult.NameHost
    $lyncdiscoverOutput.Port = "----"
    if ($lyncdiscoverOutput.Target -ne "webdir.online.lync.com") {
      $lyncdiscoverOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $lyncdiscoverOutput.Correct = "No"
    }
  }
  else {
    $lyncdiscoverOutput.Notes = "Lyncdiscover record does not exist. "
    $lyncdiscoverOutput.Correct = "No"
  }

  Write-Output -InputObject $lyncdiscoverOutput

  #SIP Record Check
  $sipResult = Resolve-DnsName -Name $sip -Type CNAME -ErrorAction SilentlyContinue
  $sipOutput = [PSCustomObject][ordered]@{
    Name    = $sip
    Type    = "CNAME"
    Target  = $null
    Port    = $null
    Correct = "Yes"
    Notes   = $null
  }

  if ($null -ne $sipResult) {
    $sipOutput.Target = $sipResult.NameHost
    $sipOutput.Port = "----"
    if ($sipOutput.Target -ne "sipdir.online.lync.com") {
      $sipOutput.Notes += "Target FQDN is not correct for Skype Online. "
      $sipOutput.Correct = "No"
    }
  }
  else {
    $sipOutput.Notes = "SIP record does not exist. "
    $sipOutput.Correct = "No"
  }

  Write-Output -InputObject $sipOutput
} # End of Test-TeamsExternalDNS

function Test-Module {
  <#
	.SYNOPSIS
		Tests whether the AzureAD Module is loaded
	.EXAMPLE
		Test-AzureADModule
		Will Return $TRUE if the Module is loaded
	#>
  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Mandatory = $true, HelpMessage = "Module to test.")]
    [string]$Module
  )
  Write-Verbose -Message "Verifying if Module '$Module' is installed and available"
  Import-Module -Name $Module -ErrorAction SilentlyContinue
  if (Get-Module -Name $Module) {
    return $true
  }
  else {
    return $false
  }
} # End of Test-Module


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
  [OutputType([Boolean])]
  param()

  try {
    $null = (Get-AzureADCurrentSessionInfo -ErrorAction STOP)
    return $true
  }
  catch {
    return $false
  }
} # End of Test-AzureADConnection

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
  [OutputType([Boolean])]
  param()

  try {
    $null = (Get-CsPolicyPackage | Select-Object -First 1 -ErrorAction STOP)
    return $true
  }
  catch {
    return $false
  }
} # End of Test-MicrosoftTeamsConnection

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
  [OutputType([Boolean])]
  param()

  $Sessions = Get-PSSession
  if ([bool]($Sessions.Computername -match "online.lync.com")) {
    $PSSkypeOnlineSession = $Sessions | Where-Object { $_.Computername -match "online.lync.com" -and $_.State -eq "Opened" -and $_.Availability -eq "Available" }
    if ($PSSkypeOnlineSession.Count -ge 1) {
      return $true
    }
    else {
      return $false
    }
  }
  else {
    return $false
  }
} # End of Test-SkypeOnlineConnection

function Test-ExchangeOnlineConnection {
  <#
	.SYNOPSIS
		Tests whether a valid PS Session exists for ExchangeOnline
	.DESCRIPTION
		A connection established via Connect-ExchangeOnline is parsed.
		This connection must be valid (Available and Opened)
	.EXAMPLE
		Test-ExchangeOnlineConnection
		Will Return $TRUE only if a session is found.
	#>
  [CmdletBinding()]
  [OutputType([Boolean])]
  param()

  $Sessions = Get-PSSession
  if ([bool]($Sessions.Computername -match "outlook.office365.com")) {
    $PSExchangeOnlineSession = $Sessions | Where-Object { $_.State -eq "Opened" -and $_.Availability -eq "Available" }
    if ($PSExchangeOnlineSession.Count -ge 1) {
      return $true
    }
    else {
      return $false
    }
  }
  else {
    return $false
  }

} # End of Test-ExchangeOnlineConnection
function Get-AzureADUserFromUPN {
  <#
	.SYNOPSIS
		Returns User Object in Azure AD from UPN
	.DESCRIPTION
		Enables UPN lookup for AzureAD user the User Object exist
	.PARAMETER Identity
		Mandatory. The sign-in address or User Principal Name of the user account to test.
	.EXAMPLE
		Get-AzureADUserFromUPN $UPN
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
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try {
      # This is functional but slow in bigger environments!
      #$User = Get-AzureADUser -All:$true | Where-Object {$_.UserPrincipalName -eq $Identity} -ErrorAction STOP
      $User = Get-AzureADUser -ObjectId "$Identity" -ErrorAction STOP
      return $User
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException] {
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
    catch {
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
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
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try {
      $null = Get-AzureADUser -ObjectId "$Identity" -ErrorAction STOP
      return $true
    }
    catch [Microsoft.Open.AzureAD16.Client.ApiException] {
      return $False
    }
    catch {
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
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = "This is the UserPrincipalName of the Group")]
    [string]$Identity
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
    Add-Type -AssemblyName Microsoft.Open.Azure.AD.CommonLibrary
  }
  process {
    try {
      $Group2 = Get-AzureADGroup -SearchString "$Identity" -ErrorAction STOP
      if ($null -ne $Group2) {
        return $true
      }
      else {
        try {
          $MailNickName = $Identity.Split('@')[0]
          $null = Get-AzureADGroup -SearchString "$MailNickName" -ErrorAction STOP
          Write-Verbose "Test-AzureAdGroup found the group with its 'MailNickName'"
          return $true
        }
        catch {
          return $false
        }
      }
    }
    catch {
      try {
        $null = Get-AzureADGroup -ObjectId $Identity -ErrorAction STOP
        return $true
      }
      catch {
        return $false
      }
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
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity
  )

  begin {
    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }


  }
  process {
    try {
      $null = Get-CsOnlineUser -Identity $Identity -ErrorAction STOP
      return $true
    }
    catch [System.Exception] {
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
    NOTE: Uses Invoke-Expression for the PolicyName provided to from Get-$($PolicyName)
	#>
  [CmdletBinding()]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the Noun of Policy, i.e. 'TeamsUpgradePolicy' of 'Get-TeamsUpgradePolicy'")]
    [Alias("Noun")]
    [string]$Policy,

    [Parameter(Mandatory = $true, HelpMessage = "This is the Name of the Policy to test")]
    [string]$PolicyName
  )
  begin {
    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
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

  process {
    try {
      $Command = "Get-" + $Policy + " -Identity " + $PolicyName + " -ErrorAction Stop"
      Invoke-Expression "$Command" -ErrorAction STOP | Out-Null
      Return $true
    }
    catch [System.Exception] {
      if ($_.FullyQualifiedErrorId -like "*MissingItem*") {
        Return $False
      }
      else {
        Write-ErrorRecord $_ #This handles the eror message in human readable format.
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
		Defined and descriptive Name of the Service Plan to test.
		Only ServicePlanNames pertaining to Teams are tested.
		Returns $TRUE only if the ServicePlanName was found and the ProvisioningStatus is "Success"
		NOTE: ServicePlans can be part of a license, for Example MCOEV (PhoneSystem) is part of an E5 license.
		For Testing against a full License Package, please use Parameter LicensePackage
	.PARAMETER LicensePackage
		Defined and descriptive Name of the License Combination to test.
		This will test whether one more more individual Service Plans are present on the Identity
	.EXAMPLE
		Test-TeamsUserLicense -Identity User@domain.com -ServicePlan MCOEV
		Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
		This can be a part of a License.
	.EXAMPLE
		Test-TeamsUserLicense -Identity User@domain.com -LicensePackage Microsoft365E5
		Will Return $TRUE only if the license Package is assigned.
		Specific Names have been assigned to these LicensePackages
	.NOTES
		This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
  .FUNCTIONALITY
    Returns a boolean value for LicensePackage or Serviceplan for a specific user.
  .LINK
    Get-TeamsTenantLicense
    Get-TeamsUserLicense
    Set-TeamsUserLicense
    Add-TeamsUserLicense (deprecated)
  #>
  #region Parameters
  [CmdletBinding(DefaultParameterSetName = "ServicePlan")]
  [OutputType([Boolean])]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "This is the UserID (UPN)")]
    [string]$Identity,

    [Parameter(Mandatory = $true, ParameterSetName = "ServicePlan", HelpMessage = "AzureAd Service Plan")]
    [string]$ServicePlan,

    [Parameter(Mandatory = $true, ParameterSetName = "LicensePackage", HelpMessage = "Teams License Package: E5,E3,S2")]
    [ValidateSet('Microsoft365A3faculty', 'Microsoft365A3students', 'Microsoft365A5faculty', 'Microsoft365A5students', 'Microsoft365BusinessBasic', 'Microsoft365BusinessStandard', 'Microsoft365BusinessPremium', 'Microsoft365E3', 'Microsoft365E5', 'Microsoft365F1', 'Microsoft365F3', 'Office365A5faculty', 'Office365A5students', 'Office365E1', 'Office365E2', 'Office365E3', 'Office365E3Dev', 'Office365E4', 'Office365E5', 'Office365E5NoAudioConferencing', 'Office365F1', 'Microsoft365E3USGOVDOD', 'Microsoft365E3USGOVGCCHIGH', 'Office365E3USGOVDOD', 'Office365E3USGOVGCCHIGH', 'PhoneSystem', 'PhoneSystemVirtualUser', 'CommonAreaPhone', 'SkypeOnlinePlan2', 'AudioConferencing', 'InternationalCallingPlan', 'DomesticCallingPlan', 'DomesticCallingPlan120', 'CommunicationCredits', 'SkypeOnlinePlan1')]
    #TODO: Add Lookup here too!
    [string]$LicensePackage

  )
  #endregion

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

  }

  process {
    # Query User
    $UserObject = Get-AzureADUser -ObjectId "$Identity"
    $DisplayName = $UserObject.DisplayName
    $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId)

    # ParameterSetName ServicePlan VS LicensePackage
    switch ($PsCmdlet.ParameterSetName) {
      "ServicePlan" {
        Write-Verbose -Message "'$DisplayName' Testing against '$ServicePlan'"
        if ($ServicePlan -in $UserLicenseObject.ServicePlans.ServicePlanName) {
          Write-Verbose -Message "Service Plan found. Testing for ProvisioningStatus"
          #Checks if the Provisioning Status is also "Success"
          $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object -Property ServicePlanName -EQ -Value $ServicePlan)
          Write-Verbose -Message "ServicePlan: $ServicePlanStatus"
          if ('Success' -eq $ServicePlanStatus.ProvisioningStatus) {
            Return $true
          }
          else {
            Return $false
          }
        }
        else {
          Write-Verbose -Message "Service Plan not found."
          Return $false
        }
      }
      "LicensePackage" {
        # need to update $LicensePackage Parameters to list all
        # Also need to change lookup against License, not ServicePlan!
        Write-Verbose -Message "'$DisplayName' Testing against '$LicensePackage'"
        TRY {
          $UserLicenseSKU = $UserLicenseObject.SkuPartNumber
          #TODO: Change Lookup here to a simplified Cross-Ref from $TeamsLicenses
          # Translate Parametername to LicenseName and look it up in $UserLicenseSKU
          SWITCH ($LicensePackage) {
            "Microsoft365E5" {
              # Combination 1 - Microsoft 365 E5 has PhoneSystem included
              IF ("SPE_E5" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "Office365E5" {
              # Combination 2 - Office 365 E5 has PhoneSystem included
              IF ("ENTERPRISEPREMIUM" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "Microsoft365E3andPhoneSystem" {
              # Combination 3 - Microsoft 365 E3 + PhoneSystem
              IF ("MCOEV" -in $UserLicenseSKU -and "SPE_E3" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "Office365E3andPhoneSystem" {
              # Combination 4 - Office 365 E3 + PhoneSystem
              IF ("MCOEV" -in $UserLicenseSKU -and "ENTERPRISEPACK" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "SFBOPlan2andAdvancedMeetingandPhoneSystem" {
              # Combination 5 - Skype for Business Online Plan 2 (S2) + Audio Conferencing + PhoneSystem
              # NOTE: This is a functioning license, but not one promoted by Microsoft.
              IF ("MCOEV" -in $UserLicenseSKU -and "MCOMEEDADV" -in $UserLicenseSKU -and "MCOSTANDARD" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "CommonAreaPhoneLicense" {
              # Combination 6 - Common Area Phone
              # NOTE: This is for Common Area Phones ONLY!
              IF ("MCOCAP" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "PhoneSystemAddOn" {
              # Combination 7 - PhoneSystem
              # NOTE: This is testing for the Add-on License only.
              IF ("MCOEV" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
            "PhoneSystem_VirtualUser" {
              # Combination 8 - PhoneSystem Virtual User License
              # NOTE: This is for Resource Accounts ONLY!
              IF ("PHONESYSTEM_VIRTUALUSER" -in $UserLicenseSKU)
              { Return $TRUE }
              ELSE
              { Return $FALSE }
            }
          }

        }
        catch {
          Write-ErrorRecord $_
        }
      }
    }
  }
} # End of Test-TeamsUserLicense

#endregion

#region Call Queues - Work in Progress
function Get-TeamsCallQueue {
  <#
	.SYNOPSIS
		Queries Call Queues and displays friendly Names (UPN or Displayname)
	.DESCRIPTION
		Same functionality as Get-CsCallQueue, but display reveals friendly Names,
		like UserPrincipalName or DisplayName for the following connected Objects
    OverflowActionTarget, TimeoutActionTarget, Agents, DistributionLists and ApplicationInstances (Resource Accounts)
    Parameters for Audio Files display the File Name instead of the ID. The Parameter Name reflects that.
    MusicOnHoldAudioFile and WelcomeMusicAudioFile, OverflowSharedVoicemailAudioFilePrompt, TimeoutSharedVoicemailAudioFilePrompt
    Please Note, to differenciate Parameter Names are changed slightly to avoid down-stream
    processing errors while not calling the DisplayIDs switch
	.PARAMETER Name
		Optional. Searches all Call Queues for this name (multiple results possible.)
    If omitted, Get-TeamsCallQueue acts like an Alias to Get-CsCallQueue (no friendly names)
  .PARAMETER DisplayAudioFileIDs
    Optional Switch. Displays Music File IDs to enable processing
  .PARAMETER ConciseView
    Optional Switch. Displays reduced set of Parameters for better visibility
    Parameters relating to Language & Shared Voicemail are not shown.
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
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>
  param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Partial or full Name of the Call Queue to search')]
    [AllowNull()]
    [string]$Name,

    [switch]$DisplayIDs,

    [switch]$ConciseView
  )

  begin {
    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

  } # end of begin

  process {
    try {
      if (-not $PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "No parameters specified. Acting as an Alias to Get-CsCallQueue" -Verbose
        Write-Verbose -Message "Warnings are suppressed for this operation. Please query with -Name to display them" -Verbose
        Get-CsCallQueue -WarningAction SilentlyContinue -ErrorAction STOP
      }
      else {
        # Finding all Queues with this Name (Should return one Object, but since it IS a filter, handling it as an array)
        #$Queues = Get-CsCallQueue -NameFilter "$Name" -WarningAction SilentlyContinue -ErrorAction STOP
        $Queues = Get-CsCallQueue -NameFilter "$Name" -ErrorAction STOP

        if ($null -ne $Queues) {
          if ($PSBoundParameters.ContainsKey('ConciseView')) {
            Write-Verbose -Message "ConciseView: Parameters relating to Language & Shared Voicemail are not shown." -Verbose
          }
        }

        # Initialising Arrays
        [System.Collections.ArrayList]$DEQueueObjects = @()

        [System.Collections.ArrayList]$UserObjects = @()
        [System.Collections.ArrayList]$DLobjects = @()
        [System.Collections.ArrayList]$AgentObjects = @()
        [System.Collections.ArrayList]$AIObjects = @()

        # Reworking Objects
        foreach ($Q in $Queues) {

          <# If Get-CsOnlineAudioFile were available, the following code would be an option to extend this function
          This is currently not an option
          #region Finding Welcome Music Audio File
          if ($null -eq $Q.WelcomeMusicAudioFileId) {
            # Welcome Music is not set
            $WMAudioFile = $null
          }
          else {
            $WMAudioFile = Get-CsOnlineAudioFile $Q.WelcomeMusicAudioFileId
          }
          #endregion

          #region Finding MusicOnHoldAudioFile
          if ($Q.UseDefaultMusicOnHold) {
            $MoHAudioFile = $null
          }
          else {
            # Music On Hold is custom
            $MoHAudioFile = Get-CsOnlineAudioFile $Q.MusicOnHoldAudioFileId
          }
          #endregion
          #>

          #region Finding OverflowActionTarget
          if ($null -eq $Q.OverflowActionTarget) {
            $OAT = $null
          }
          else {
            switch ($Q.OverflowActionTarget.Type) {
              "ApplicationEndpoint" {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              "Mailbox" {
                try {
                  $OATobject = Get-AzureADGroup -ObjectId "$($Q.OverflowActionTarget.Id)" -ErrorAction STOP
                  $OAT = $OATobject.DisplayName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              "User" {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
              default {
                try {
                  $OATobject = Get-AzureADUser -ObjectId "$($Q.OverflowActionTarget.Id)" -ErrorAction STOP
                  $OAT = $OATobject.UserPrincipalName
                  if ($null -eq $OAT) {
                    try {
                      $OATobject = Get-AzureADGroup -ObjectId "$($Q.OverflowActionTarget.Id)" -ErrorAction STOP
                      $OAT = $OATobject.DisplayName
                      if ($null -eq $OAT) {
                        throw
                      }
                    }
                    catch {
                      Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                    }
                  }
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' OverflowActionTarget: Not enumerated"
                }
              }
            }
          }

          # Output: $OAT, $Q.OverflowActionTarget.Type
          #endregion

          #region Finding TimeoutActionTarget
          if ($null -eq $Q.OverflowActionTarget) {
            $TAT = $null
          }
          else {
            switch ($Q.TimeoutActionTarget.Type) {
              "ApplicationEndpoint" {
                try {
                  $TATobject = Get-AzureADUser -ObjectId "$($Q.TimeoutActionTarget.Id)" -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              "Mailbox" {
                try {
                  $TATobject = Get-AzureADGroup -ObjectId "$($Q.TimeoutActionTarget.Id)" -ErrorAction STOP
                  $TAT = $TATObject.DisplayName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              "User" {
                try {
                  $TATobject = Get-AzureADUser -ObjectId "$($Q.TimeoutActionTarget.Id)" -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
              default {
                try {
                  $TATobject = Get-AzureADUser -ObjectId "$($Q.TimeoutActionTarget.Id)" -ErrorAction STOP
                  $TAT = $TATObject.UserPrincipalName
                  if ($null -eq $TAT) {
                    try {
                      $TATobject = Get-AzureADGroup -ObjectId "$($Q.TimeoutActionTarget.Id)" -ErrorAction STOP
                      $TAT = $TATObject.DisplayName
                      if ($null -eq $TAT) {
                        throw
                      }
                    }
                    catch {
                      Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                    }
                  }
                }
                catch {
                  Write-Warning -Message "'$($Q.Name)' TimeoutActionTarget: Not enumerated"
                }
              }
            }
          }

          # Output: $TAT, $Q.TimeoutActionTarget.Type
          #endregion

          #region Endpoints - DistributionLists and Agents
          Write-Verbose -Message "'$($Q.Name)' Parsing DistributionLists"
          foreach ($DL in $Q.DistributionLists) {
            $DLobject = Get-AzureADGroup -ObjectId $DL | Select-Object DisplayName, Description, SecurityEnabled, MailEnabled, MailNickName, Mail
            [void]$DLobjects.Add($DLobject)
          }
          # Output: $DLobjects.DisplayName

          Write-Verbose -Message "'$($Q.Name)' Parsing Users"
          foreach ($User in $Q.Users) {
            $UserObject = Get-AzureADUser -ObjectId "$User".Guid | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
            [void]$UserObjects.Add($UserObject)
          }
          # Output: $UserObjects.UserPrincipalName

          Write-Verbose -Message "'$($Q.Name)' Parsing Agents"
          foreach ($Agent in $Q.Agents) {
            $AgentObject = Get-AzureADUser -ObjectId "$($Agent.ObjectId)" | Select-Object UserPrincipalName, DisplayName, JobTitle, CompanyName, Country, UsageLocation, PreferredLanguage
            [void]$AgentObjects.Add($AgentObject)
          }
          # Output: $AgentObjects.UserPrincipalName
          #endregion

          #region Application Instance UPNs
          Write-Verbose -Message "'$($Q.Name)' Parsing Resource Accounts"
          foreach ($AI in $Q.ApplicationInstances) {
            $AIobject = $null
            $AIobject = Get-CsOnlineApplicationInstance | Where-Object { $_.ObjectId -eq $AI } | Select-Object UserPrincipalName, DisplayName, PhoneNumber
            #TODO: Verify what to do if RA cannot be enumerated. Currently empty. Show ObjectId instead?
            if ($null -ne $AIobject) {
              [void]$AIObjects.Add($AIobject)
            }
            else {
              # Create new Object with ObjectId as UPN and ObjectId?
              [void]$AIObjects.Add($AIobject)
            }
          }

          # Output: $AIObjects.UserPrincipalName
          #endregion

          #region Creating Output Object
          # Building custom Object with Friendly Names
          if ($PSBoundParameters.ContainsKey('ConciseView')) {
            <# If Get-CsOnlineAudioFile were available, the following code would be an option to extend this function
            This is currently not an option. Leaving code for future expansion
            if ($PSBoundParameters.ContainsKey('DisplayAudioFileIDs')) {
              $Q = [PSCustomObject][ordered]@{
                Identity                = $Q.Identity
                Name                    = $Q.Name
                UseDefaultMusicOnHold   = $Q.UseDefaultMusicOnHold
                MusicOnHoldAudioFile    = $MoHAudioFile.Name
                WelcomeMusicAudioFile   = $WMAudioFile.Name
                MusicOnHoldAudioFileId  = $Q.MusicOnHoldAudioFileId
                WelcomeMusicAudioFileId = $Q.WelcomeMusicAudioFileId
                RoutingMethod           = $Q.RoutingMethod
                PresenceBasedRouting    = $Q.PresenceBasedRouting
                AgentAlertTime          = $Q.AgentAlertTime
                AllowOptOut             = $Q.AllowOptOut
                ConferenceMode          = $Q.ConferenceMode
                OverflowThreshold       = $Q.OverflowThreshold
                OverflowAction          = $Q.OverflowAction
                OverflowActionTarget    = $OAT
                OverflowActionTargetType = $Q.OverflowActionTarget.Type
                #OverflowSharedVoicemailAudioFilePrompt             = $Q.OverflowSharedVoicemailAudioFilePrompt
                #OverflowSharedVoicemailTextToSpeechPrompt          = $Q.OverflowSharedVoicemailTextToSpeechPrompt
                #EnableOverflowSharedVoicemailTranscription         = $Q.EnableOverflowSharedVoicemailTranscription
                TimeoutAction           = $Q.TimeoutAction
                TimeoutActionTarget     = $TAT
                TimeoutActionTargetType = $Q.TimeoutActionTarget.Type
                #TimeoutSharedVoicemailAudioFilePrompt              = $Q.TimeoutSharedVoicemailAudioFilePrompt
                #TimeoutSharedVoicemailTextToSpeechPrompt           = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
                #EnableTimeoutSharedVoicemailTranscription          = $Q.EnableTimeoutSharedVoicemailTranscription
                #LanguageId                                         = $Q.LanguageId
                #LineUri                                            = $Q.LineUri
                Users                   = $UserObjects.UserPrincipalName
                DistributionLists       = $DLobjects.DisplayName
                Agents                  = $AgentObjects.UserPrincipalName
                ApplicationInstances    = $AIObjects.Userprincipalname
              }
            }
            else {
              $Q = [PSCustomObject][ordered]@{
                Identity              = $Q.Identity
                Name                  = $Q.Name
                UseDefaultMusicOnHold = $Q.UseDefaultMusicOnHold
                MusicOnHoldAudioFile  = $MoHAudioFile.Name
                WelcomeMusicAudioFile = $WMAudioFile.Name
                RoutingMethod         = $Q.RoutingMethod
                PresenceBasedRouting  = $Q.PresenceBasedRouting
                AgentAlertTime        = $Q.AgentAlertTime
                AllowOptOut           = $Q.AllowOptOut
                ConferenceMode        = $Q.ConferenceMode
                OverflowThreshold     = $Q.OverflowThreshold
                OverflowAction        = $Q.OverflowAction
                OverflowActionTarget    = $OAT
                OverflowActionTargetType = $Q.OverflowActionTarget.Type
                #OverflowSharedVoicemailAudioFilePrompt             = $Q.OverflowSharedVoicemailAudioFilePrompt
                #OverflowSharedVoicemailTextToSpeechPrompt          = $Q.OverflowSharedVoicemailTextToSpeechPrompt
                #EnableOverflowSharedVoicemailTranscription         = $Q.EnableOverflowSharedVoicemailTranscription
                TimeoutThreshold      = $Q.TimeoutThreshold
                TimeoutAction         = $Q.TimeoutAction
                TimeoutActionTarget     = $TAT
                TimeoutActionTargetType = $Q.TimeoutActionTarget.Type
                #TimeoutSharedVoicemailAudioFilePrompt              = $Q.TimeoutSharedVoicemailAudioFilePrompt
                #TimeoutSharedVoicemailTextToSpeechPrompt           = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
                #EnableTimeoutSharedVoicemailTranscription          = $Q.EnableTimeoutSharedVoicemailTranscription
                #LanguageId                                         = $Q.LanguageId
                #LineUri                                            = $Q.LineUri
                Users                 = $UserObjects.UserPrincipalName
                DistributionLists     = $DLobjects.DisplayName
                Agents                = $AgentObjects.UserPrincipalName
                ApplicationInstances  = $AIObjects.Userprincipalname
              }
            }
            #>
            $Q = [PSCustomObject][ordered]@{
              Identity                 = $Q.Identity
              Name                     = $Q.Name
              UseDefaultMusicOnHold    = $Q.UseDefaultMusicOnHold
              MusicOnHoldAudioFileId   = $Q.MusicOnHoldAudioFileId
              WelcomeMusicAudioFileId  = $Q.WelcomeMusicAudioFileId
              RoutingMethod            = $Q.RoutingMethod
              PresenceBasedRouting     = $Q.PresenceBasedRouting
              AgentAlertTime           = $Q.AgentAlertTime
              AllowOptOut              = $Q.AllowOptOut
              ConferenceMode           = $Q.ConferenceMode
              OverflowThreshold        = $Q.OverflowThreshold
              OverflowAction           = $Q.OverflowAction
              OverflowActionTarget     = $OAT
              OverflowActionTargetType = $Q.OverflowActionTarget.Type
              #OverflowSharedVoicemailAudioFilePrompt             = $Q.OverflowSharedVoicemailAudioFilePrompt
              #OverflowSharedVoicemailTextToSpeechPrompt          = $Q.OverflowSharedVoicemailTextToSpeechPrompt
              #EnableOverflowSharedVoicemailTranscription         = $Q.EnableOverflowSharedVoicemailTranscription
              TimeoutThreshold         = $Q.TimeoutThreshold
              TimeoutAction            = $Q.TimeoutAction
              TimeoutActionTarget      = $TAT
              TimeoutActionTargetType  = $Q.TimeoutActionTarget.Type
              #TimeoutSharedVoicemailAudioFilePrompt              = $Q.TimeoutSharedVoicemailAudioFilePrompt
              #TimeoutSharedVoicemailTextToSpeechPrompt           = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
              #EnableTimeoutSharedVoicemailTranscription          = $Q.EnableTimeoutSharedVoicemailTranscription
              #LanguageId                                         = $Q.LanguageId
              #LineUri                                            = $Q.LineUri
              Users                    = $UserObjects.UserPrincipalName
              DistributionLists        = $DLobjects.DisplayName
              Agents                   = $AgentObjects.UserPrincipalName
              ApplicationInstances     = $AIObjects.Userprincipalname
            }
          }
          else {
            # Displays all except reserved Parameters (Microsoft Internal)
            <# This is currently not an option. Leaving code for future expansion

            if ($PSBoundParameters.ContainsKey('DisplayAudioFileIDs')) {
              # Displays also AudioFileIDs
              $Q = [PSCustomObject][ordered]@{
                Identity                                   = $Q.Identity
                Name                                       = $Q.Name
                UseDefaultMusicOnHold                      = $Q.UseDefaultMusicOnHold
                MusicOnHoldAudioFile                       = $MoHAudioFile.Name
                WelcomeMusicAudioFile                      = $WMAudioFile.Name
                MusicOnHoldAudioFileId                     = $Q.MusicOnHoldAudioFileId
                WelcomeMusicAudioFileId                    = $Q.WelcomeMusicAudioFileId
                RoutingMethod                              = $Q.RoutingMethod
                PresenceBasedRouting                       = $Q.PresenceBasedRouting
                AgentAlertTime                             = $Q.AgentAlertTime
                AllowOptOut                                = $Q.AllowOptOut
                ConferenceMode                             = $Q.ConferenceMode
                OverflowThreshold                          = $Q.OverflowThreshold
                OverflowAction                             = $Q.OverflowAction
                OverflowActionTarget    = $OAT
                OverflowActionTargetType = $Q.OverflowActionTarget.Type
                OverflowSharedVoicemailAudioFilePrompt     = $Q.OverflowSharedVoicemailAudioFilePrompt
                OverflowSharedVoicemailTextToSpeechPrompt  = $Q.OverflowSharedVoicemailTextToSpeechPrompt
                EnableOverflowSharedVoicemailTranscription = $Q.EnableOverflowSharedVoicemailTranscription
                TimeoutThreshold                           = $Q.TimeoutThreshold
                TimeoutAction                              = $Q.TimeoutAction
                TimeoutActionTarget     = $TAT
                TimeoutActionTargetType = $Q.TimeoutActionTarget.Type
                TimeoutSharedVoicemailAudioFilePrompt      = $Q.TimeoutSharedVoicemailAudioFilePrompt
                TimeoutSharedVoicemailTextToSpeechPrompt   = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
                EnableTimeoutSharedVoicemailTranscription  = $Q.EnableTimeoutSharedVoicemailTranscription
                LanguageId                                 = $Q.LanguageId
                #LineUri                                    = $Q.LineUri
                Users                                      = $UserObjects.UserPrincipalName
                DistributionLists                          = $DLobjects.DisplayName
                Agents                                     = $AgentObjects.UserPrincipalName
                ApplicationInstances                       = $AIObjects.Userprincipalname
              }
            }
            else {
              # Displays native Get-TeamsCallQueue Object
              $Q = [PSCustomObject][ordered]@{
                Identity                                   = $Q.Identity
                Name                                       = $Q.Name
                UseDefaultMusicOnHold                      = $Q.UseDefaultMusicOnHold
                MusicOnHoldAudioFile                       = $MoHAudioFile.Name
                WelcomeMusicAudioFile                      = $WMAudioFile.Name
                RoutingMethod                              = $Q.RoutingMethod
                PresenceBasedRouting                       = $Q.PresenceBasedRouting
                AgentAlertTime                             = $Q.AgentAlertTime
                AllowOptOut                                = $Q.AllowOptOut
                ConferenceMode                             = $Q.ConferenceMode
                OverflowThreshold                          = $Q.OverflowThreshold
                OverflowAction                             = $Q.OverflowAction
                OverflowActionTarget    = $OAT
                OverflowActionTargetType = $Q.OverflowActionTarget.Type
                OverflowSharedVoicemailAudioFilePrompt     = $Q.OverflowSharedVoicemailAudioFilePrompt
                OverflowSharedVoicemailTextToSpeechPrompt  = $Q.OverflowSharedVoicemailTextToSpeechPrompt
                EnableOverflowSharedVoicemailTranscription = $Q.EnableOverflowSharedVoicemailTranscription
                TimeoutThreshold                           = $Q.TimeoutThreshold
                TimeoutAction                              = $Q.TimeoutAction
                TimeoutActionTarget     = $TAT
                TimeoutActionTargetType = $Q.TimeoutActionTarget.Type
                TimeoutSharedVoicemailAudioFilePrompt      = $Q.TimeoutSharedVoicemailAudioFilePrompt
                TimeoutSharedVoicemailTextToSpeechPrompt   = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
                EnableTimeoutSharedVoicemailTranscription  = $Q.EnableTimeoutSharedVoicemailTranscription
                LanguageId                                 = $Q.LanguageId
                #LineUri                                    = $Q.LineUri
                Users                                      = $UserObjects.UserPrincipalName
                DistributionLists                          = $DLobjects.DisplayName
                Agents                                     = $AgentObjects.UserPrincipalName
                ApplicationInstances                       = $AIObjects.Userprincipalname
              }
            }

            #>
            $Q = [PSCustomObject][ordered]@{
              Identity                                   = $Q.Identity
              Name                                       = $Q.Name
              UseDefaultMusicOnHold                      = $Q.UseDefaultMusicOnHold
              MusicOnHoldAudioFileId                     = $Q.MusicOnHoldAudioFileId
              WelcomeMusicAudioFileId                    = $Q.WelcomeMusicAudioFileId
              RoutingMethod                              = $Q.RoutingMethod
              PresenceBasedRouting                       = $Q.PresenceBasedRouting
              AgentAlertTime                             = $Q.AgentAlertTime
              AllowOptOut                                = $Q.AllowOptOut
              ConferenceMode                             = $Q.ConferenceMode
              OverflowThreshold                          = $Q.OverflowThreshold
              OverflowAction                             = $Q.OverflowAction
              OverflowActionTarget                       = $OAT
              OverflowActionTargetType                   = $Q.OverflowActionTarget.Type
              OverflowSharedVoicemailAudioFilePrompt     = $Q.OverflowSharedVoicemailAudioFilePrompt
              OverflowSharedVoicemailTextToSpeechPrompt  = $Q.OverflowSharedVoicemailTextToSpeechPrompt
              EnableOverflowSharedVoicemailTranscription = $Q.EnableOverflowSharedVoicemailTranscription
              TimeoutThreshold                           = $Q.TimeoutThreshold
              TimeoutAction                              = $Q.TimeoutAction
              TimeoutActionTarget                        = $TAT
              TimeoutActionTargetType                    = $Q.TimeoutActionTarget.Type
              TimeoutSharedVoicemailAudioFilePrompt      = $Q.TimeoutSharedVoicemailAudioFilePrompt
              TimeoutSharedVoicemailTextToSpeechPrompt   = $Q.TimeoutSharedVoicemailTextToSpeechPrompt
              EnableTimeoutSharedVoicemailTranscription  = $Q.EnableTimeoutSharedVoicemailTranscription
              LanguageId                                 = $Q.LanguageId
              #LineUri                                    = $Q.LineUri
              Users                                      = $UserObjects.UserPrincipalName
              DistributionLists                          = $DLobjects.DisplayName
              Agents                                     = $AgentObjects.UserPrincipalName
              ApplicationInstances                       = $AIObjects.Userprincipalname
            }

          }
          [void]$DEQueueObjects.Add($Q)
          #endregion
        }
        # Output
        return $DEQueueObjects

      }
    }
    catch {
      Write-Error -Message 'Could not query Call Queues' -Category OperationStopped
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
      return
    }

  }
  end {

  }
}
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
		Used as the DisplayName - Visible in Teams
	.PARAMETER Silent
		Optional. Supresses output. Use for Bulk provisioning only.
		Will return the Output object, but not display any output on Screen.
	.PARAMETER UseMicrosoftDefaults
		This script uses different default values for some parameters than New-CsCallQueue
		Using this switch will instruct the Script to adhere to Microsoft defaults.
		ChangedPARAMETER:      This Script   Microsoft    Reason:
		- AgentAlertTime:         20s           30s         Shorter Alert Time more universally useful
		- OverflowThreshold:      10            50          Smaller Queue Size (Waiting Callers) more universally useful
		- TimeoutThreshold:       30s           1200s       Shorter Threshold for timeout more universally useful
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
	.PARAMETER OverflowSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailAudioFile is $null
	.PARAMETER OverflowSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableOverflowSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
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
	.PARAMETER TimeoutSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailAudioFile is $null
	.PARAMETER TimeoutSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableTimeoutSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
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
  .PARAMETER LanguageId
    Optional Language Identifier indicating the language that is used to play shared voicemail prompts.
    This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail.
	.EXAMPLE
		New-TeamsCallQueue -Name "My Queue"
		Creates a new Call Queue "My Queue" with the Default Music On Hold
		All other values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)
	.EXAMPLE
		New-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
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
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the Call Queue")]
    [string]$Name,

    [Parameter(HelpMessage = "No output is written to the screen, but Object returned for processing")]
    [switch]$Silent,

    #Deviation from MS Default (30s)
    [Parameter(HelpMessage = "Time an agent is alerted in seconds (15-180s)")]
    [ValidateScript( {
        If ($_ -ge 15 -and $_ -le 180) {
          $True
        }
        else {
          Write-Host "Must be a value between 30 and 180s (3 minutes)" -ForeGroundColor Red
          $false
        }
      })]
    [int16]$AgentAlertTime = 20,

    #Deviation from MS Default
    [Parameter(HelpMessage = "Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)")]
    [boolean]$AllowOptOut,

    #region Overflow Params
    [Parameter(HelpMessage = "Action to be taken for Overflow")]
    [Validateset("DisconnectWithBusy", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('OA')]
    [string]$OverflowAction = "DisconnectWithBusy",

    # if OverflowAction is not DisconnectWithBusy, this is required
    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon overflow, only valid for forwarded calls")]
    [Alias('OAT')]
    [ValidateScript( {
        if ($_ -match "(^tel:\+\d|^\+\d)|@") {
          return $true
        }
        else {
          throw "OverflowActionTarget: Value provided must either be a UPN (containing a '@'), a Tel URI (starting with 'tel:+') or a E.164 number (starting '+' followed by a number)"
          #return $false
        }
      }
    )]
    [string]$OverflowActionTarget,

    #region OverflowAction = SharedVoiceMail
    # if OverflowAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('OATTS', 'OverflowSharedVMTTS')]
    [string]$OverflowSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for the SharedVoiceMail Message")]
    [Alias('OAsharedVMfile', 'OverflowSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "OverflowSharedVoicemailAudioFile: File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$OverflowSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('OAsharedVMtranscript')]
    [bool]$EnableOverflowSharedVoicemailTranscription,
    #endregion

    #Deviation from MS Default (50)
    [Parameter(HelpMessage = "Time in seconds (0-200s) before timeout action is triggered (Default: 10, Note: Microsoft default: 50)")]
    [Alias('OAthreshold', 'OAQueueLength')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 200) {
          $True
        }
        else {
          Write-Host "OverflowThreshold: Must be a value between 0 and 200s." -ForeGroundColor Red
          $false
        }
      })]
    [int16]$OverflowThreshold = 10,
    #endregion

    #region Timeout Params
    [Parameter(HelpMessage = "Action to be taken for Timeout")]
    [Validateset("Disconnect", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('TA')]
    [string]$TimeoutAction = "Disconnect",

    # if TimeoutAction is not Disconnect, this is required
    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon timeout, only valid for forwarded calls")]
    [Alias('TAT')]
    [ValidateScript( {
        if ($_ -match "(^tel:\+\d|^\+\d)|@") {
          return $true
        }
        else {
          throw "TimeoutActionTarget: Value provided must either be a UPN (containing a '@'), a Tel URI (starting with 'tel:+') or a E.164 number (starting '+' followed by a number)"
          #return $false
        }
      }
    )]
    [string]$TimeoutActionTarget,

    #region TimeoutAction = SharedVoiceMail
    # if TimeoutAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('TATTS', 'TimeoutSharedVMTTS')]
    [string]$TimeoutSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for the SharedVoiceMail Message")]
    [Alias('TOsharedVMfile', 'TimeoutSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$TimeoutSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('TOsharedVMtranscript')]
    [bool]$EnableTimeoutSharedVoicemailTranscription,
    #endregion

    #Deviation from MS Default (1200s)
    [Parameter(HelpMessage = "Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)")]
    [Alias('TOthreshold')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          Write-Host "TimeoutThreshold: Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)" -ForeGroundColor Red
          $false
        }
      })]
    [int16]$TimeoutThreshold = 30,
    #endregion

    [Parameter(HelpMessage = "Method to alert Agents")]
    [Validateset("Attendant", "Serial", "RoundRobin", "LongestIdle")]
    [string]$RoutingMethod = "Attendant",

    [Parameter(HelpMessage = "If used, Agents receive calls only when their presence state is Available")]
    [boolean]$PresenceBasedRouting,

    [Parameter(HelpMessage = "Indicates whether the default Music On Hold is used")]
    [boolean]$UseDefaultMusicOnHold,

    [Parameter(HelpMessage = "If used, Conference mode is used to establish calls")]
    [boolean]$ConferenceMode,

    #region Music files
    [Parameter(HelpMessage = "Path to Audio File for Welcome Message")]
    [ValidateScript( {
        if ($null -eq $_) {
          $True
        }
        else {
          If (Test-Path $_) {
            If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
              $True
            }
            else {
              Write-Host "WelcomeMusicAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
              $false
            }
          }
          else {
            Write-Host "WelcomeMusicAudioFile: File not found, please verify" -ForeGroundColor Red
            $false
          }
        }
      })]
    [string]$WelcomeMusicAudioFile,

    [Parameter(HelpMessage = "Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)")]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "MusicOnHoldAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "MusicOnHoldAudioFile: File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$MusicOnHoldAudioFile,
    #endregion

    #region Agents
    [Parameter(HelpMessage = "Name of one or more Distribution Lists")]
    [ValidateScript( {
        foreach ($e in $_) {
          If (Test-AzureADGroup $e) {
            $True
          }
          else {
            Write-Host "DistributionLists: '$e' not found" -ForeGroundColor Red
            $false
          }
        }
      })]
    [string[]]$DistributionLists,

    [Parameter(HelpMessage = "UPN of one or more Users")]
    [ValidateScript( {
        foreach ($e in $_) {
          If (Test-AzureADUser $e) {
            return $true
          }
          else {
            Write-Host "Users: '$e' not found!" -ForeGroundColor Red
            return $false
          }
        }
      })]
    [string[]]$Users,
    #endregion

    [Parameter(HelpMessage = "Language Identifier from Get-CsAutoAttendantSupportedLanguage.")]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId,

    [Parameter(HelpMessage = "Will adhere to defaults as Microsoft outlines in New-CsCallQueue")]
    [switch]$UseMicrosoftDefaults

  )

  begin {
    # Caveat - Script in Testing
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"

    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Testing ExchangeOnline Connection if needed
    if ($OverflowAction -eq "SharedVoiceMail" -or $TimeoutAction -eq "SharedVoiceMail") {
      # Testing Exchange Online Connection
      if (Test-ExchangeOnlineConnection) {
        Write-Verbose -Message "ExchangeOnline: Valid Session found, reusing existing connection"
      }
      else {
        if ([bool]((Get-PSSession).Computername -match "outlook.office365.com")) {
          Write-Host "ExchangeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
          $null = Get-UnifiedGroup -Resultsize 1 -WarningAction SilentlyContinue
        }
        else {
          Write-Warning -Message "No connection to ExchangeOnline found. UnifiedGroup cannot be verified"
        }
      }
    }

    # Checking for Text-to-speech prompts without providing LanguageId
    if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt') -or $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
      if (-not $PSBoundParameters.ContainsKey('LanguageId')) {
        Write-Host "ERROR: You must provide the Parameter 'LanguageId' if using Text-to-speech prompts." -ForegroundColor Red
        break
      }
    }

    # Language has to be normalised as the Id is case sensititve
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Language = $($LanguageId.Split("-")[0]).ToLower() + "-" + $($LanguageId.Split("-")[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      if ((Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported) {
        Write-Verbose "LanguageId '$Language' - Voice Responses supported"
      }
      else {
        Write-Warning "LanguageId '$Language' - Voice Responses not supported"
      }
    }
  }

  process {
    #region PREPARATION
    # preparing Splatting Object
    $Parameters = $null

    #region Required Parameters: Name
    # Normalising $Name
    $NameNormalised = Format-StringForUse -InputString $Name -As DisplayName
    Write-Verbose -Message "'$Name' DisplayName normalised to: '$NameNormalised'"
    $Parameters += @{'Name' = $NameNormalised }
    #endregion

    #region Required Parameters: MusicOnHold
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Warning -Message "'$NameNormalised' MusicOnHoldAudioFile and UseDefaultMusicOnHold are mutually exclusive. UseDefaultMusicOnHold is ignored!"
      $UseDefaultMusicOnHold = $false
    }
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
      $MOHFileName = Split-Path $MusicOnHoldAudioFile -Leaf
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Parsing: '$MOHFileName'" -Verbose
      try {
        $MOHFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $MusicOnHoldAudioFile -ErrorAction STOP
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   '$($MOHFile.FileName)'"
        $Parameters += @{'MusicOnHoldAudioFileId' = $MOHFile.Id }
      }
      catch {
        Write-Error -Message "Import of MusicOnHoldAudioFile: '$MOHFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   DEFAULT"
        $UseDefaultMusicOnHold = $true
        $Parameters += @{'UseDefaultMusicOnHold' = $true }
      }
    }
    else {
      $UseDefaultMusicOnHold = $true
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   DEFAULT"
      $Parameters += @{'UseDefaultMusicOnHold' = $true }
    }
    #endregion

    #region Welcome Message
    if ($PSBoundParameters.ContainsKey('WelcomeMusicAudioFile')) {
      if ($null -ne $WelcomeMusicAudioFile) {
        $WMFileName = Split-Path $WelcomeMusicAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Parsing: '$WMFileName'" -Verbose
        try {
          $WMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $WelcomeMusicAudioFile -ErrorAction STOP
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   '$($WMFile.FileName)"
          $Parameters += @{'WelcomeMusicAudioFileId' = $WMfile.Id }
        }
        catch {
          Write-Error -Message "Import of WelcomeMusicAudioFile: '$WMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
        }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
    }
    #endregion

    #region Boolean Parameters
    if ($PSBoundParameters.ContainsKey('AllowOptOut')) {
      Write-Verbose -Message "'$NameNormalised' Setting default value: AllowOptOut: $AllowOptOut"
      $Parameters += @{'AllowOptOut' = $AllowOptOut }
    }
    if ($PSBoundParameters.ContainsKey('ConferenceMode')) {
      Write-Verbose -Message "'$NameNormalised' Setting default value: ConferenceMode: $ConferenceMode"
      $Parameters += @{'ConferenceMode' = $ConferenceMode }
    }
    #endregion

    #region Valued Parameters
    if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
      Write-Verbose -Message "'$NameNormalised' Setting default values according to New-CsCallQueue (Microsoft defaults)" -Verbose
    }
    else {
      Write-Verbose -Message "'$NameNormalised' Setting default values according to New-TeamsCallQueue (optimised defaults)" -Verbose
    }
    # AgentAlertTime
    if (-not $PSBoundParameters.ContainsKey('AgentAlertTime')) {
      if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
        $AgentAlertTime = 30
      }
      # AgentAlertTime    is set within PARAM block to 20s
    }
    $Parameters += @{'AgentAlertTime' = $AgentAlertTime }
    Write-Verbose -Message "'$NameNormalised' Setting default value: AgentAlertTime: $AgentAlertTime"

    # OverflowThreshold
    if (-not $PSBoundParameters.ContainsKey('OverflowThreshold')) {
      if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
        $OverflowThreshold = 50
      }
      # OverflowThreshold is set within PARAM block to 30s
    }
    $Parameters += @{'OverflowThreshold' = $OverflowThreshold }
    Write-Verbose -Message "'$NameNormalised' Setting default value: OverflowThreshold: $OverflowThreshold"

    # TimeoutThreshold
    if (-not $PSBoundParameters.ContainsKey('TimeoutThreshold')) {
      if ($PSBoundParameters.ContainsKey('UseMicrosoftDefaults')) {
        $TimeoutThreshold = 1200
      }
      # TimeoutTheshold   is set within PARAM block to 30s
    }
    $Parameters += @{'TimeoutThreshold' = $TimeoutThreshold }
    Write-Verbose -Message "'$NameNormalised' Setting default value: TimeoutThreshold: $TimeoutThreshold"
    #endregion

    #region Overflow
    #region Overflow Action and Target
    # Overflow Action
    Write-Verbose -Message "'$NameNormalised' Parsing requirements for OverflowAction: $OverflowAction"
    switch ($OverflowAction) {
      "DisconnectWithBusy" {
        # No Action - Default
      }
      "Forward" {
        # Forward requires an OverflowActionTarget (Tel URI or UPN of a User to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('OverflowActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter OverFlowActionTarget Missing, Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowAction = "DisconnectWithBusy"
        }
        else {
          # Processing OverflowActionTarget
          try {
            if ($OverflowActionTarget -match "^tel:\+\d|^\+\d") {
              #Telephone Number
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTarget }
            }
            else {
              #Assume it is a User
              $OverflowActionTargetId = (Get-AzureADUser -ObjectId "$($OverflowActionTarget)" -ErrorAction STOP).ObjectId
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate OverflowActionTarget: '$OverflowActionTarget'"
            $OverflowAction = "DisconnectWithBusy"
          }
        }
      }
      "VoiceMail" {
        # VoiceMail requires an OverflowActionTarget (UPN of a User to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('OverflowActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter OverFlowActionTarget Missing, Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowAction = "DisconnectWithBusy"
        }
        else {
          # Processing OverflowActionTarget
          try {
            $OverflowActionTargetId = (Get-AzureADUser -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ObjectId
            $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate OverflowActionTarget: '$OverflowActionTarget'"
            $OverflowAction = "DisconnectWithBusy"
          }
        }
      }
      "SharedVoiceMail" {
        # SharedVoiceMail requires an OverflowActionTarget (UPN of a Group to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('OverflowActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter OverFlowActionTarget Missing, Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowAction = "DisconnectWithBusy"
        }
        else {
          # Processing OverflowActionTarget
          try {
            if (Test-ExchangeOnlineConnection) {
              $OverflowActionTargetId = (Get-UnifiedGroup -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ExternalDirectoryObjectId
            }
            else {
              Write-Verbose -Message "No connection to Exchange, verifying AzureAD Object instead" -Verbose
              #TODO This Requires change to group, and correct lookup of DN or UPN respectively. Might need helper function!
              $OverflowActionTargetId = (Get-AzureADGroup -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ObjectId
            }
            $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate OverflowActionTarget: '$OverflowActionTarget'"
            $OverflowAction = "DisconnectWithBusy"
          }
        }
      }
    }
    # $OverflowAction is added to the Parameter list only after all checks are complete!
    #endregion

    #region OverflowAction SharedVoicemail - Processing
    if ($OverflowAction -eq "SharedVoiceMail") {
      # SharedVoiceMail requires either AudioFile or TTS prompt; TTS prompt requires Language
      if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
        # Both Parameters provided
        Write-Error -Message "'$NameNormalised' either Parameter OverflowSharedVoicemailAudioFile OR OverflowSharedVoicemailTextToSpeechPrompt are required (not both!); Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
        $OverflowAction = "DisconnectWithBusy"
      }
      elseif (-not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
        # Neither Parameter provided
        Write-Error -Message "'$NameNormalised' either Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt are required; Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
        $OverflowAction = "DisconnectWithBusy"
      }
      else {
        # Processing OverflowSharedVoicemailTextToSpeechPrompt
        if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt' -and -not $PSBoundParameters.ContainsKey('LanguageId'))) {
          # TTS Parameter without Language selected
          Write-Error -Message "'$NameNormalised': OverflowSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId; Reverting OverflowAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $OverflowSharedVoicemailTextToSpeechPrompt = $null
          $OverflowAction = "DisconnectWithBusy"
        }
        else {
          # TTS Parameter provided
          $Parameters += @{'OverflowSharedVoicemailTextToSpeechPrompt' = $OverflowSharedVoicemailTextToSpeechPrompt }
        }


        # Processing OverflowSharedVoicemailAudioFile
        if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile')) {
          $OFSVMFileName = Split-Path $OverflowSharedVoicemailAudioFile -Leaf
          Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Parsing: '$OFSVMFileName'" -Verbose
          try {
            $OFSVMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $OverflowSharedVoicemailAudioFile -ErrorAction STOP
            Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Using:   '$($OFSVMFile.FileName)'"
            $Parameters += @{'OverflowSharedVoicemailAudioFilePrompt' = $OFSVMFile.Id }
          }
          catch {
            Write-Error -Message "Import of OverflowSharedVoicemailAudioFile: '$OFSVMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
            break
          }
        }
      }

      # Processing TimeoutSharedVoicemailAudioFile
      if ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) {
        $Parameters += @{'EnableOverflowSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
      }
    }
    #endregion

    #region OverflowAction conclusion
    # finally, after all checks are done, adding OverflowAction to Parameters
    $Parameters += @{'OverflowAction' = $OverflowAction }
    #endregion
    #endregion

    #region Timeout
    #region Timeout Action and Target
    Write-Verbose -Message "'$NameNormalised' Parsing requirements for TimeoutAction: $TimeoutAction"
    switch ($TimeoutAction) {
      "Disconnect" {
        # No Action - Default
      }
      "Forward" {
        # Forward requires an TimeoutActionTarget (Tel URI or UPN of a User to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter TimeoutActionTarget Missing, Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $TimeoutAction = "Disconnect"
        }
        else {
          # Processing TimeoutActionTarget
          try {
            if ($TimeoutActionTarget -match "^tel:\+\d|^\+\d") {
              #Telephone Number
              $Parameters += @{'OverflowActionTarget' = $TimeoutActionTarget }
            }
            else {
              #Assume it is a User
              $TimeoutActionTargetId = (Get-AzureADUser -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ObjectId
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate TimeoutActionTarget: '$TimeoutActionTarget'"
            $TimeoutAction = "Disconnect"
          }
        }
      }
      "VoiceMail" {
        # VoiceMail requires an TimeoutActionTarget (UPN of a User to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter TimeoutActionTarget Missing, Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $TimeoutAction = "Disconnect"
        }
        else {
          # Processing TimeoutActionTarget
          try {
            $TimeoutActionTargetId = (Get-AzureADUser -ObjectId "$($TimeoutActionTarget)" -ErrorAction STOP).ObjectId
            $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate 'TimeoutActionTarget'"
            $TimeoutAction = "Disconnect"
          }
        }
      }
      "SharedVoiceMail" {
        # SharedVoiceMail requires an TimeoutActionTarget (UPN of a Group to be translated to GUID)
        if (-not $PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
          Write-Error -Message "'$NameNormalised' Parameter TimeoutActionTarget Missing, Reverting TimeoutAction to 'DisconnectWithBusy'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $TimeoutAction = "DisconnectWithBusy"
        }
        else {
          # Processing TimeoutActionTarget
          try {
            if (Test-ExchangeOnlineConnection) {
              $TimeoutwActionTargetId = (Get-UnifiedGroup -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ExternalDirectoryObjectId
            }
            else {
              Write-Verbose -Message "TimeoutActionTarget '$TimeoutActionTarget' - No connection to Exchange, verifying AzureAD Object instead" -Verbose
              #TODO This Requires change to group, and correct lookup of DN or UPN respectively. Might need helper function!
              $TimeoutActionTargetId = (Get-AzureADGroup -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ObjectId
            }
            $Parameters += @{'TimeoutActionTarget' = $TimeoutwActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' Could not enumerate TimeoutActionTarget: '$TimeoutActionTarget'"
            $TimeoutAction = "DisconnectWithBusy"
          }
        }
      }
    }
    # $TimeoutAction is added to the Parameter list only after all checks are complete!
    #endregion

    #region TimeoutAction SharedVoicemail - Processing
    if ($TimeoutAction -eq "SharedVoiceMail") {
      # SharedVoiceMail requires either AudioFile or TTS prompt; TTS prompt requires Language
      if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
        # Both Parameters provided
        Write-Error -Message "'$NameNormalised' either Parameter TimeoutSharedVoicemailAudioFile OR TimeoutSharedVoicemailTextToSpeechPrompt are required (not both!); Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
        $TimeoutAction = "Disconnect"
      }
      elseif (-not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
        # Neither Parameter provided
        Write-Error -Message "'$NameNormalised' either Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt are required; Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
        $TimeoutAction = "Disconnect"
      }
      else {
        # Processing TimeoutSharedVoicemailTextToSpeechPrompt
        if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt' -and -not $PSBoundParameters.ContainsKey('LanguageId'))) {
          # TTS Parameter without Language selected
          Write-Error -Message "'$NameNormalised': TimeoutSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId; Reverting TimeoutAction to 'Disconnect'" -ErrorAction Continue -RecommendedAction "Reapply again with Set-TeamsCallQueue or Set-CsCallQueue"
          $TimeoutSharedVoicemailTextToSpeechPrompt = $null
          $TimeoutAction = "Disconnect"
        }
        else {
          # TTS Parameter provided
          $Parameters += @{'TimeoutSharedVoicemailTextToSpeechPrompt' = $TimeoutSharedVoicemailTextToSpeechPrompt }
        }


        # Processing TimeoutSharedVoicemailAudioFile
        if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile')) {
          $OFSVMFileName = Split-Path $TimeoutSharedVoicemailAudioFile -Leaf
          Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Parsing: '$OFSVMFileName'" -Verbose
          try {
            $OFSVMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $TimeoutSharedVoicemailAudioFile -ErrorAction STOP
            Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Using:   '$($OFSVMFile.FileName)'"
            $Parameters += @{'TimeoutSharedVoicemailAudioFilePrompt' = $OFSVMFile.Id }
          }
          catch {
            Write-Error -Message "Import of TimeoutSharedVoicemailAudioFile: '$OFSVMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
            break
          }
        }
      }

      # Processing TimeoutSharedVoicemailAudioFile
      if ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription')) {
        $Parameters += @{'EnableTimeoutSharedVoicemailTranscription' = $EnableTimeoutSharedVoicemailTranscription }
      }
    }
    #endregion

    #region TimeoutAction conclusion
    # finally, after all checks are done, adding TimeoutAction to Parameters
    $Parameters += @{'TimeoutAction' = $TimeoutAction }
    #endregion

    # Adding Language
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Parameters += @{'LanguageId' = $Language }
    }
    #endregion

    #region Users - Parsing and verifying Users
    [System.Collections.ArrayList]$UserIdList = @()
    if ($PSBoundParameters.ContainsKey('Users')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Users"
      foreach ($User in $Users) {
        if (Test-AzureADUser $User) {
          # Determine ID from UPN
          $UserObject = Get-AzureADUser -ObjectId "$User"
          $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId)
          $ServicePlanName = "MCOEV"
          $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object ServicePlanName -EQ $ServicePlanName).ProvisioningStatus
          if ($ServicePlanStatus -ne "Success") {
            # User not licensed (doesn't have Phone System)
            Write-Warning -Message "User '$User' License (PhoneSystem):   FAILED - User is not correctly licensed, omitting User"
          }
          else {
            Write-Verbose -Message "User '$User' License (PhoneSystem):   SUCCESS"
            $EVenabled = $(Get-CsOnlineUser $User).EnterpriseVoiceEnabled
            if (-not $EVenabled) {
              # User not EV-Enabled
              Write-Warning -Message "User '$User' EnterpriseVoice-Enabled: FAILED - Omitting User"
            }
            else {
              # Add to List
              Write-Verbose -Message "User '$User' EnterpriseVoice-Enabled: SUCCESS"
              Write-Verbose -Message "User '$User' will be added to CallQueue" -Verbose
              [void]$UserIdList.Add($UserObject.ObjectId)
            }
          }
        }
        else {
          Write-Warning -Message "'$NameNormalised' User '$User' not found in AzureAd, omitting user!"
        }
      }
      $Parameters += @{'Users' = @($UserIdList) }
    }
    #endregion

    #region Groups - Parsing Distribution Lists and their Users
    [System.Collections.ArrayList]$DLIdList = @()
    if ($PSBoundParameters.ContainsKey('DistributionLists')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Distribution Lists"
      foreach ($DL in $DistributionLists) {
        # Determine ID from UPN
        if (Test-AzureADGroup "$DL") {
          $DLObject = Get-AzureADGroup -SearchString "$DL"
          if ($null -eq $DLObject) {
            $DL2 = $DL.Split('@')[0]
            $DLObject = Get-AzureADGroup -SearchString "$DL2"
            if ($null -eq $DLObject) {
              try {
                $DLObject = Get-AzureADGroup -ObjectId "$DL"
              }
              catch {
                Write-Warning -Message "Group '$DL' not found in AzureAd, omitting Group!"
              }
            }
          }
        }

        if ($DLObject) {
          Write-Verbose -Message "Group '$DL' will be added to the Call Queue" -Verbose
          # Test whether Users in DL are enabled for EV and/or licensed?

          # Add to List
          [void]$DLIdList.Add($DLObject.ObjectId)
        }
        else {
          Write-Warning -Message "Group '$DL' not found in AzureAd, omitting Group!"
        }
      }
      $Parameters += @{'DistributionLists' = @($DLIdList) }
      if ($DLIdList.Count -gt 0) {
        Write-Verbose -Message "NOTE: Group members are parsed by the subsystem" -Verbose
        Write-Verbose -Message "Currently no verification steps are taken against Licensing or EV-Enablement of Members" -Verbose

      }
    }
    #endregion


    #region Common parameters
    if ($PSBoundParameters.ContainsKey('Silent')) {
      $Parameters += @{'WarningAction' = 'SilentlyContinue' }
    }
    else {
      $Parameters += @{'WarningAction' = 'Continue' }
    }
    $Parameters += @{'ErrorAction' = 'STOP' }
    #endregion
    #endregion

    #region Desired Configuration
    # Creating Custom Object with desired configuration for comparison
    $CallQueueDesired = [PSCustomObject][ordered]@{
      Name                                       = $NameNormalised
      UseDefaultMusicOnHold                      = $UseDefaultMusicOnHold
      MusicOnHoldAudioFileId                     = $MOHfile.Id
      WelcomeMusicAudioFileId                    = $WMFile.Id
      RoutingMethod                              = $RoutingMethod
      PresenceBasedRouting                       = $PresenceBasedRouting
      AgentAlertTime                             = $AgentAlertTime
      AllowOptOut                                = $AllowOptOut
      ConferenceMode                             = $ConferenceMode
      OverflowAction                             = $OverflowAction
      OverflowActionTarget                       = $OverflowActionTarget
      OverflowSharedVoicemailAudioFilePrompt     = $OverflowSharedVoicemailAudioFilePrompt
      OverflowSharedVoicemailTextToSpeechPrompt  = $OverflowSharedVoicemailTextToSpeechPrompt
      OverflowThreshold                          = $OverflowThreshold
      TimeoutAction                              = $TimeoutAction
      TimeoutActionTarget                        = $TimeoutActionTarget
      TimeoutSharedVoicemailAudioFilePrompt      = $TimeoutSharedVoicemailAudioFilePrompt
      TimeoutSharedVoicemailTextToSpeechPrompt   = $TimeoutSharedVoicemailTextToSpeechPrompt
      TimeoutThreshold                           = $TimeoutThreshold
      EnableOverflowSharedVoicemailTranscription = $EnableOverflowSharedVoicemailTranscription
      EnableTimeoutSharedVoicemailTranscription  = $EnableTimeoutSharedVoicemailTranscription
      LanguageId                                 = $LanguageId
      #LineUri                                            = $LineUri
      # Testing whether names or IDs need to be compared - depends on what is queried in $CallQueueFinal - if CsCallQueue, we need IDs
      #Users                                      = $Users
      #DistributionLists                          = $DistributionLists
      Users                                      = $UserIdList
      DistributionLists                          = $DLIdList
    }
    #endregion


    #region ACTION
    # Create CQ (New-CsCallQueue)
    Write-Verbose -Message "'$NameNormalised' Creating Call Queue"
    if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "New-CsCallQueue")) {
      try {
        # Create the Call Queue with all enumerated Parameters passed through splatting
        $Null = (New-CsCallQueue @Parameters)
        Write-Verbose -Message "SUCCESS: '$NameNormalised' Call Queue created with all Parameters"
      }
      catch {
        Write-Error -Message "Error creating the Call Queue" -Category WriteError -Exception "Erorr Creating Call Queue"
        Write-ErrorRecord $_ #This handles the eror message in human readable format.
        return
      }
    }
    else {
      break
    }
    #endregion


    #region Output and Desired Configuration
    # Re-query output
    #TODO: Users and DLs need to be queried first, as they must be compared UPN to UPN
    $CallQueueFinal = Get-CsCallQueue -NameFilter $NameNormalised -WarningAction SilentlyContinue
    if (-not ($PSBoundParameters.ContainsKey('Silent'))) {
      # Displaying Warning when no Agents are found
      if ($null -eq $($CallQueueFinal.Agents) -and ($null -eq $($CallQueueFinal.DistributionLists))) {
        Write-Warning -Message "No Distribution Lists or Users added to callqueue. There will be no agents to call."
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
      }
    }
    else {
      Return
    }
    #endregion
  }

  end {

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
		Required. Friendly Name of the Call Queue. Used to Identify the Object
	.PARAMETER DisplayName
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
		Optional or $NULL. Path to Audio File to be used as a Welcome message
		Accepted Formats: MP3, WAV or WMA, max 5MB
	.PARAMETER MusicOnHoldAudioFile
		Optional. Path to Audio File to be used as Music On Hold.
		Required if UseDefaultMusicOnHold is not specified/set to TRUE
		Accepted Formats: MP3, WAV or WMA, max 5MB
	.PARAMETER OverflowAction
		Optional. Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail
		Action to be taken if the Queue size limit (OverflowThreshold) is reached
		Forward requires specification of OverflowActionTarget
	.PARAMETER OverflowActionTarget
		Situational. Required only if OverflowAction is Forward
		UserPrincipalName of the Target
	.PARAMETER OverflowSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailAudioFile is $null
	.PARAMETER OverflowSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableOverflowSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
	.PARAMETER OverflowThreshold
		Optional. Time in Seconds for the OverflowAction to trigger
	.PARAMETER TimeoutAction
		Optional. Default: Disconnect, Values: Disconnect, Forward, VoiceMail
		Action to be taken if the TimeoutThreshold is reached
		Forward requires specification of TimeoutActionTarget
	.PARAMETER TimeoutActionTarget
		Situational. Required only if TimeoutAction is Forward
		UserPrincipalName of the Target
	.PARAMETER TimeoutSharedVoicemailTextToSpeechPrompt
    Situational. Text to be read for a Shared Voicemail greeting. Requires LanguageId
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailAudioFile is $null
	.PARAMETER TimeoutSharedVoicemailAudioFile
    Situational. Path to the Audio File for a Shared Voicemail greeting
    Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailTextToSpeechPrompt is $null
  .PARAMETER EnableTimeoutSharedVoicemailTranscription
    Situational. Boolean Switch. Requires specification of LanguageId
    Enables a transcription of the Voicemail message to be sent to the Group mailbox
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
  .PARAMETER LanguageId
    Optional Language Identifier indicating the language that is used to play shared voicemail prompts.
    This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail.
	.EXAMPLE
		Set-TeamsCallQueue -Name "My Queue" -DisplayName "My new Queue Name"
		Changes the DisplayName of Call Queue "My Queue" to "My new Queue Name"
	.EXAMPLE
		Set-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
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
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UserPrincipalName of the Call Queue")]
    [string]$Name,

    [Parameter(HelpMessage = "Changes the Name to this DisplayName")]
    [string]$DisplayName,

    [Parameter(HelpMessage = "No output is written to the screen, but Object returned for processing")]
    [switch]$Silent,

    [Parameter(HelpMessage = "Time an agent is alerted in seconds (15-180s)")]
    [ValidateScript( {
        If ($_ -ge 15 -and $_ -le 180) {
          $True
        }
        else {
          Write-Host "Must be a value between 30 and 180s (3 minutes)" -ForeGroundColor Red
          $false
        }
      })]
    [int16]$AgentAlertTime,

    [Parameter(HelpMessage = "Can agents opt in or opt out from taking calls from a Call Queue (Default: TRUE)")]
    [boolean]$AllowOptOut,

    #region Overflow Params
    [Parameter(HelpMessage = "Action to be taken for Overflow")]
    [Validateset("DisconnectWithBusy", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('OA')]
    [string]$OverflowAction,

    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon overflow, only valid for forwarded calls")]
    [Alias('OAT')]
    [ValidateScript( {
        if ($_ -match "(^tel:\+\d|^\+\d)|@") {
          return $true
        }
        else {
          throw "OverflowActionTarget: Value provided must either be a UPN (containing a '@'), a Tel URI (starting with 'tel:+') or a E.164 number (starting '+' followed by a number)"
          #return $false
        }
      }
    )]
    [string]$OverflowActionTarget,

    #region OverflowAction = SharedVoiceMail
    # if OverflowAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('OATTS', 'OverflowSharedVMTTS')]
    [string]$OverflowSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for Overflow SharedVoiceMail Message")]
    [Alias('OAsharedVMfile', 'OverflowSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "OverflowSharedVoicemailAudioFile: File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$OverflowSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('OAsharedVMtranscript')]
    [bool]$EnableOverflowSharedVoicemailTranscription,
    #endregion

    [Parameter(HelpMessage = "Time in seconds (0-200s) before timeout action is triggered (Default: 30, Note: Microsoft default: 50)")]
    [Alias('OAthreshold', 'OAQueueLength')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 200) {
          $True
        }
        else {
          Write-Host "OverflowThreshold: Must be a value between 0 and 200s." -ForeGroundColor Red
          $false
        }
      })]
    [int16]$OverflowThreshold,
    #endregion

    #region Timeout Params
    [Parameter(HelpMessage = "Action to be taken for Timeout")]
    [Validateset("Disconnect", "Forward", "Voicemail", "SharedVoicemail")]
    [Alias('TA')]
    [string]$TimeoutAction,

    # if TimeoutAction is not Disconnect, this is required
    [Parameter(HelpMessage = "TEL URI or UPN that is targeted upon timeout, only valid for forwarded calls")]
    [Alias('TAT')]
    [ValidateScript( {
        if ($_ -match "(^tel:\+\d|^\+\d)|@") {
          return $true
        }
        else {
          throw "Value provided must either be a UPN (containing a '@'), a Tel URI (starting with 'tel:+') or a E.164 number (starting '+' followed by a number)"
          #return $false
        }
      }
    )]
    [string]$TimeoutActionTarget,

    #region TimeoutAction = SharedVoiceMail
    # if TimeoutAction is SharedVoicemail one of the following two have to be provided
    [Parameter(HelpMessage = "Text-to-speech Message. This will require the LanguageId Parameter")]
    [Alias('TATTS', 'TimeoutSharedVMTTS')]
    [string]$TimeoutSharedVoicemailTextToSpeechPrompt,

    [Parameter(HelpMessage = "Path to Audio File for the SharedVoiceMail Message")]
    [Alias('TOsharedVMfile', 'TimeoutSharedVMFile')]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$TimeoutSharedVoicemailAudioFile,

    [Parameter(HelpMessage = "Using this Parameter will make a Transcription of the Voicemail message available in the Mailbox")]
    [Alias('TOsharedVMtranscript')]
    [bool]$EnableTimeoutSharedVoicemailTranscription,
    #endregion

    [Parameter(HelpMessage = "Time in seconds (0-2700s) before timeout action is triggered (Default: 30, Note: Microsoft default: 1200)")]
    [Alias('TOthreshold')]
    [ValidateScript( {
        If ($_ -ge 0 -and $_ -le 2700) {
          $True
        }
        else {
          Write-Host "TimeoutThreshold: Must be a value between 0 and 2700s, will be rounded to nearest 15s intervall (0/15/30/45)" -ForeGroundColor Red
          $false
        }
      })]
    [int16]$TimeoutThreshold,
    #endregion

    [Parameter(HelpMessage = "Method to alert Agents")]
    [Validateset("Attendant", "Serial", "RoundRobin", "LongestIdle")]
    [string]$RoutingMethod = "Attendant",

    [Parameter(HelpMessage = "If used, Agents receive calls only when their presence state is Available")]
    [boolean]$PresenceBasedRouting,

    [Parameter(HelpMessage = "Indicates whether the default Music On Hold is used")]
    [boolean]$UseDefaultMusicOnHold,

    [Parameter(HelpMessage = "If used, Conference mode is used to establish calls")]
    [boolean]$ConferenceMode,

    #region Music files
    [Parameter(HelpMessage = "Path to Audio File for Welcome Message")]
    [ValidateScript( {
        if ($null -eq $_) {
          $True
        }
        else {
          If (Test-Path $_) {
            If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
              $True
            }
            else {
              Write-Host "WelcomeMusicAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
              $false
            }
          }
          else {
            Write-Host "WelcomeMusicAudioFile: File not found, please verify" -ForeGroundColor Red
            $false
          }
        }
      })]
    [string]$WelcomeMusicAudioFile,

    [Parameter(HelpMessage = "Path to Audio File for MusicOnHold (cannot be used with UseDefaultMusicOnHold switch!)")]
    [ValidateScript( {
        If (Test-Path $_) {
          If ((Get-Item $_).length -le 5242880 -and ($_ -match '.mp3' -or $_ -match '.wav' -or $_ -match '.wma')) {
            $True
          }
          else {
            Write-Host "MusicOnHoldAudioFile: Must be a file of MP3, WAV or WMA format, max 5MB" -ForeGroundColor Red
            $false
          }
        }
        else {
          Write-Host "MusicOnHoldAudioFile: File not found, please verify" -ForeGroundColor Red
          $false
        }
      })]
    [string]$MusicOnHoldAudioFile,
    #endregion

    #region Agents
    [Parameter(HelpMessage = "Name of one or more Distribution Lists")]
    [ValidateScript( {
        foreach ($e in $_) {
          If (Test-AzureADGroup $e) {
            $True
          }
          else {
            Write-Host "DistributionLists: '$e' not found" -ForeGroundColor Red
            $false
          }
        }
      })]
    [string[]]$DistributionLists,

    [Parameter(HelpMessage = "UPN of one or more Users")]
    [ValidateScript( {
        foreach ($e in $_) {
          If (Test-AzureADUser $e) {
            return $true
          }
          else {
            Write-Host "Users: '$e' not found!" -ForeGroundColor Red
            return $false
          }
        }
      })]
    [string[]]$Users,
    #endregion

    [Parameter(HelpMessage = "Language Identifier from Get-CsAutoAttendantSupportedLanguage.")]
    [ValidateScript( { $_ -in (Get-CsAutoAttendantSupportedLanguage).Id })]
    [string]$LanguageId

  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Testing ExchangeOnline Connection if needed
    if ($OverflowAction -eq "SharedVoiceMail" -or $TimeoutAction -eq "SharedVoiceMail") {
      # Testing Exchange Online Connection
      if (Test-ExchangeOnlineConnection) {
        Write-Verbose -Message "ExchangeOnline: Valid Session found, reusing existing connection"
      }
      else {
        if ([bool]((Get-PSSession).Computername -match "outlook.office365.com")) {
          Write-Host "ExchangeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
          $null = Get-UnifiedGroup -Resultsize 1 -WarningAction SilentlyContinue
        }
        else {
          Write-Warning -Message "No connection to ExchangeOnline found. UnifiedGroup cannot be verified"
        }
      }
    }

    # Language has to be normalised as the Id is case sensititve
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Language = $($LanguageId.Split("-")[0]).ToLower() + "-" + $($LanguageId.Split("-")[1]).ToUpper()
      Write-Verbose "LanguageId '$LanguageId' normalised to '$Language'"
      if ((Get-CsAutoAttendantSupportedLanguage -Id $Language).VoiceResponseSupported) {
        Write-Verbose "LanguageId '$Language' - Voice Responses supported"
      }
      else {
        Write-Warning "LanguageId '$Language' - Voice Responses not supported"
      }
    }
  }

  process {
    #region PREPARATION
    # preparing Splatting Object
    $Parameters = $null

    #region Query Unique Element
    # Initial Query to determine uniqure result (single object)
    $CallQueue = Get-CsCallQueue -NameFilter "$Name" -WarningAction SilentlyContinue
    if ($null -eq $CallQueue) {
      Write-Error "'$Name' No Object found" -Category ParserError -RecommendedAction  "Please check 'Name' provided"
      break
    }
    elseif ($CallQueue.GetType().BaseType.Name -eq "Array") {
      Write-Error "'$Name' Multiple Results found! Cannot determine unique result." -Category ParserError -RecommendedAction  "Please use Set-CsCallQueue with the -Identity switch!"
      break
    }
    else {
      $ID = $CallQueue.Identity
      Write-Verbose -Message "'$Name' Call Queue found: Identity: $ID"
      $Parameters += @{'Identity' = $ID }
    }
    #endregion


    #region DisplayName
    # Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey('DisplayName')) {
      $NameNormalised = Format-StringForUse -InputString "$DisplayName" -As DisplayName
      Write-Verbose -Message "'$Name' DisplayName normalised to: '$NameNormalised'"
      $Parameters += @{'Name' = "$NameNormalised" }
    }
    else {
      $NameNormalised = "$Name"
    }
    #endregion

    #region Music On Hold
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile') -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Warning -Message "'$NameNormalised' MusicOnHoldAudioFile and UseDefaultMusicOnHold are mutually exclusive. UseDefaultMusicOnHold is ignored!"
      $UseDefaultMusicOnHold = $false
    }
    if ($PSBoundParameters.ContainsKey('MusicOnHoldAudioFile')) {
      $MOHFileName = Split-Path $MusicOnHoldAudioFile -Leaf
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Parsing: '$MOHFileName'" -Verbose
      try {
        $MOHFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $MusicOnHoldAudioFile -ErrorAction STOP
        Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   '$($MOHFile.FileName)'"
        $Parameters += @{'MusicOnHoldAudioFileId' = $MOHFile.Id }
      }
      catch {
        Write-Error -Message "Import of MusicOnHoldAudioFile: '$MOHFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
        break
      }
    }
    elseif ($UseDefaultMusicOnHold -and $PSBoundParameters.ContainsKey('UseDefaultMusicOnHold')) {
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   NONE"
      $Parameters += @{'UseDefaultMusicOnHold' = $true }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' MusicOnHoldAudioFile:  Using:   EXISTING SETTING"
    }
    #endregion

    #region Welcome Message
    if ($PSBoundParameters.ContainsKey('WelcomeMusicAudioFile')) {
      if ($null -ne $WelcomeMusicAudioFile) {
        $WMFileName = Split-Path $WelcomeMusicAudioFile -Leaf
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Parsing: '$WMFileName'" -Verbose
        try {
          $WMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $WelcomeMusicAudioFile -ErrorAction STOP
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   '$($WMFile.FileName)"
          $Parameters += @{'WelcomeMusicAudioFileId' = $WMfile.Id }
        }
        catch {
          Write-Error -Message "Import of WelcomeMusicAudioFile: '$WMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
          Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE or EXISTING"
        }
      }
      else {
        Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   NONE"
        $Parameters += @{'WelcomeMusicAudioFileId' = $null }
      }
    }
    else {
      Write-Verbose -Message "'$NameNormalised' WelcomeMusicAudioFile: Using:   EXISTING SETTING"
    }
    #endregion

    #region ValueSet Parameters
    # RoutingMethod
    if ($PSBoundParameters.ContainsKey('RoutingMethod')) {
      $Parameters += @{'RoutingMethod' = $RoutingMethod }
    }
    #endregion

    #region Boolean Parameters
    # PresenceBasedRouting
    if ($PSBoundParameters.ContainsKey('PresenceBasedRouting')) {
      $Parameters += @{'PresenceBasedRouting' = $PresenceBasedRouting }
    }
    # AllowOptOut
    if ($PSBoundParameters.ContainsKey('AllowOptOut')) {
      $Parameters += @{'AllowOptOut' = $AllowOptOut }
    }
    # ConferenceMode
    if ($PSBoundParameters.ContainsKey('ConferenceMode')) {
      $Parameters += @{'ConferenceMode' = $ConferenceMode }
    }
    #endregion

    #region Valued Parameters
    # AgentAlertTime
    if ($PSBoundParameters.ContainsKey('AgentAlertTime')) {
      $Parameters += @{'AgentAlertTime' = $AgentAlertTime }
    }
    # OverflowThreshold
    if ($PSBoundParameters.ContainsKey('OverflowThreshold')) {
      $Parameters += @{'OverflowThreshold' = $OverflowThreshold }
    }
    # TimeoutThreshold
    if ($PSBoundParameters.ContainsKey('TimeoutThreshold')) {
      $Parameters += @{'TimeoutThreshold' = $TimeoutThreshold }
    }
    #endregion


    #region Language
    if ($PSBoundParameters.ContainsKey('LanguageId')) {
      $Parameters += @{'LanguageId' = $Language }
    }
    else {
      $Language = $CallQueue.LanguageId
    }

    # Checking for Text-to-speech prompts without providing LanguageId
    if ($null -eq $Language -and `
      ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) -or `
      ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) -or `
      ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) -or `
      ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription'))) {

      Write-Error "'$NameNormalised' LanguageId is not set and not provided. This is required for using Text-to-speech prompts or Transcription." -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
      break
    }
    #endregion


    #region Overflow
    #region OverflowAction
    if ($PSBoundParameters.ContainsKey('OverflowAction')) {
      Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
        # We have a Target
        if ($OverflowAction -eq "DisconnectWithBusy") {
          #but we don't need one
          Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction' does not require an OverflowActionTarget. It will not be processed"
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction' and OverflowActionTarget '$OverflowActionTarget' specified. Processing both."
        }
      }
      elseif ($OverflowAction -ne "DisconnectWithBusy") {
        Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction' not set! Parameter OverflowActionTarget missing"
      }
      # Adding OverflowAction here
      # This might lead to errors if the dependent Parameters are not all present.
      # Trying to Catching errors there.
      $Parameters += @{'OverflowAction' = $OverflowAction }
    }
    else {
      $OverflowAction = $CallQueue.OverflowAction
      Write-Verbose -Message "'$NameNormalised' Parameter OverflowAction not present. Using existing setting: '$OverflowAction'"
    }
    #endregion

    #region OverflowActionTarget
    # Processing for Target is depenent on Action
    if ($PSBoundParameters.ContainsKey('OverflowActionTarget')) {
      switch ($OverflowAction) {
        "DisconnectWithBusy" {
          # Explicit setting of DisconnectWithBusy
          if (-not $PSBoundParameters.ContainsKey('OverflowAction')) {
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': No Overflow-Parameters are processed" -Verbose
          }
          #else: No Action
        }
        "Forward" {
          # Forward requires an OverflowActionTarget (Tel URI or UPN of a User to be translated to GUID)
          try {
            if ($OverflowActionTarget -match "^tel:\+\d") {
              #Telephone URI
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTarget }
            }
            elseif ($OverflowActionTarget -match "^\+\d") {
              #Telephone Number (E.164)
              $OverflowActionTargetNormalised = "tel:" + $OverflowActionTarget
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetNormalised }
            }
            elseif ($OverflowActionTarget -match '@') {
              #Assume it is a User
              $OverflowActionTargetId = (Get-AzureADUser -ObjectId "$($OverflowActionTarget)" -ErrorAction STOP).ObjectId
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
            }
            else {
              # Capturing any other specified Target that does not match for the Forward
              Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget expected is a Tel URI or a UPN of a User" -Verbose
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
          }
        }
        "VoiceMail" {
          # VoiceMail requires an OverflowActionTarget (UPN of a User to be translated to GUID)
          try {
            $OverflowActionTargetId = (Get-AzureADUser -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ObjectId
            $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
          }
        }
        "SharedVoiceMail" {
          # SharedVoiceMail requires an OverflowActionTarget (UPN of a Group to be translated to GUID)
          #region SharedVoiceMail prerequisites
          if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            # Both Parameters provided
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailAudioFile and OverflowSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only"
            $PSBoundParameters.Remove('OverflowSharedVoicemailTextToSpeechPrompt')
          }
          elseif (-not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            # Neither Parameter provided
            Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': Parameter OverflowSharedVoicemailAudioFile or OverflowSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction "Add one of the two parameters"
            break
          }
          elseif ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
            if (($null -eq $CallQueue.LanguageId) -or (-not $PSBoundParameters.ContainsKey('LanguageId'))) {
              Write-Error -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
              break
            }
            elseif ($PSBoundParameters.ContainsKey('LanguageId')) {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
            }
            else {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowSharedVoicemailTextToSpeechPrompt: Language '$($CallQueue.LanguageId)' is used" -Verbose
            }
          }
          #endregion

          #region Processing OverflowActionTarget for SharedVoiceMail
          try {
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Testing Exchange Connection"
            if (Test-ExchangeOnlineConnection) {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Querying Exchange Object"
              $OverflowActionTargetId = (Get-UnifiedGroup -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ExternalDirectoryObjectId
            }
            else {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Querying AzureAD Object"
              $OverflowActionTargetId = (Get-AzureADGroup -ObjectId "$OverflowActionTarget" -ErrorAction STOP).ObjectId
            }
            if ($null -eq $OverflowActionTargetId) {
              throw
            }
            else {
              Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Object found!"
              $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
            }
          }
          catch {
            Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Querying AzureAD Object: Mailnickname"
            try {
              if ($OverflowActionTarget.Contains("@")) {
                $OverflowActionTargetId = (Get-AzureADGroup -SearchString $($OverflowActionTarget.Split("@")[0]) -ErrorAction STOP).ObjectId
              }
              else {
                $OverflowActionTargetId = (Get-AzureADGroup -SearchString $($OverflowActionTarget.Replace(" ", "")) -ErrorAction STOP).ObjectId
              }
              if ($null -eq $OverflowActionTargetId) {
                throw
              }
              else {
                Write-Verbose -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' - Object found!"
                $Parameters += @{'OverflowActionTarget' = $OverflowActionTargetId }
              }
            }
            catch {
              Write-Warning -Message "'$NameNormalised' OverflowAction '$OverflowAction': OverflowActionTarget '$OverflowActionTarget' not set! Error enumerating Target"
            }
          }
          #endregion
        }
      }
    }
    else {
      #no Target specified. Using existing
      $OverflowActionTarget = $CallQueue.OverflowActionTarget
    }
    #endregion

    #region OverflowAction SharedVoicemail - Processing
    if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailAudioFile')) {
      $OFSVMFileName = Split-Path $OverflowSharedVoicemailAudioFile -Leaf
      Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Parsing: '$OFSVMFileName'" -Verbose
      try {
        $OFSVMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $OverflowSharedVoicemailAudioFile -ErrorAction STOP
        Write-Verbose -Message "'$NameNormalised' OverflowSharedVoicemailAudioFile:  Using:   '$($OFSVMFile.FileName)'"
        $Parameters += @{'OverflowSharedVoicemailAudioFilePrompt' = $OFSVMFile.Id }
      }
      catch {
        Write-Error -Message "Import of OverflowSharedVoicemailAudioFile: '$OFSVMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
        break
      }
    }

    if ($PSBoundParameters.ContainsKey('OverflowSharedVoicemailTextToSpeechPrompt')) {
      $Parameters += @{'OverflowSharedVoicemailTextToSpeechPrompt' = $OverflowSharedVoicemailTextToSpeechPrompt }
    }

    if ($PSBoundParameters.ContainsKey('EnableOverflowSharedVoicemailTranscription')) {
      $Parameters += @{'EnableOverflowSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
    }
    #endregion
    #endregion

    #region Timeout
    #region TimeoutAction
    if ($PSBoundParameters.ContainsKey('TimeoutAction')) {
      Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' Parsing requirements"
      if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
        # We have a Target
        if ($TimeoutAction -eq "DisconnectWithBusy") {
          #but we don't need one
          Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' does not require an TimeoutActionTarget. It will not be processed"
        }
        else {
          # OK
          Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' and TimeoutActionTarget '$TimeoutActionTarget' specified. Processing both."
        }
      }
      elseif ($TimeoutAction -ne "Disconnect") {
        Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction' not set! Parameter TimeoutActionTarget missing"
      }
      # Adding TimeoutAction here
      # This might lead to errors if the dependent Parameters are not all present.
      # Trying to Catching errors there.
      $Parameters += @{'TimeoutAction' = $TimeoutAction }
    }
    else {
      $TimeoutAction = $CallQueue.TimeoutAction
      Write-Verbose -Message "'$NameNormalised' Parameter TimeoutAction not present. Using existing setting: '$TimeoutAction'"
    }
    #endregion

    #region TimeoutActionTarget
    # Processing for Target is depenent on Action
    if ($PSBoundParameters.ContainsKey('TimeoutActionTarget')) {
      switch ($TimeoutAction) {
        "Disconnect" {
          # Explicit setting of DisconnectWithBusy
          if (-not $PSBoundParameters.ContainsKey('TimeoutAction')) {
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': No Timeout-Parameters are processed" -Verbose
          }
          #else: No Action
        }
        "Forward" {
          # Forward requires an TimeoutActionTarget (Tel URI or UPN of a User to be translated to GUID)
          try {
            if ($TimeoutActionTarget -match "^tel:\+\d") {
              #Telephone URI
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTarget }
            }
            elseif ($TimeoutActionTarget -match "^\+\d") {
              #Telephone Number (E.164)
              $TimeoutActionTargetNormalised = "tel:" + $TimeoutActionTarget
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetNormalised }
            }
            elseif ($TimeoutActionTarget -match '@') {
              #Assume it is a User
              $TimeoutActionTargetId = (Get-AzureADUser -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ObjectId
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
            }
            else {
              # Capturing any other specified Target that does not match for the Forward
              Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' is incompatible and is not processed!"
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget expected is a Tel URI or a UPN of a User" -Verbose
            }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
          }
        }
        "VoiceMail" {
          # VoiceMail requires an TimeoutActionTarget (UPN of a User to be translated to GUID)
          try {
            $TimeoutActionTargetId = (Get-AzureADUser -ObjectId "$($TimeoutActionTarget)" -ErrorAction STOP).ObjectId
            $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
          }
          catch {
            Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
          }
        }
        "SharedVoiceMail" {
          # SharedVoiceMail requires an TimeoutActionTarget (UPN of a Group to be translated to GUID)
          #region SharedVoiceMail prerequisites
          if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            # Both Parameters provided
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailAudioFile and TimeoutSharedVoicemailTextToSpeechPrompt are mutually exclusive. Processing File only"
            $PSBoundParameters.Remove('TimeoutSharedVoicemailTextToSpeechPrompt')
          }
          elseif (-not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile') -and -not $PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            # Neither Parameter provided
            Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': Parameter TimeoutSharedVoicemailAudioFile or TimeoutSharedVoicemailTextToSpeechPrompt missing" -ErrorAction Stop -RecommendedAction "Add one of the two parameters"
            break
          }
          elseif ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
            if (($null -eq $CallQueue.LanguageId) -or (-not $PSBoundParameters.ContainsKey('LanguageId'))) {
              Write-Error -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt requires Language selection. Please provide Parameter LanguageId" -ErrorAction Stop -RecommendedAction "Add Parameter LanguageId"
              break
            }
            elseif ($PSBoundParameters.ContainsKey('LanguageId')) {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt: Language '$Language' is used" -Verbose
            }
            else {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutSharedVoicemailTextToSpeechPrompt: Language '$($CallQueue.LanguageId)' is used" -Verbose
            }
          }
          #endregion

          #region Processing TimeoutActionTarget for SharedVoiceMail
          try {
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Testing Exchange Connection"
            if (Test-ExchangeOnlineConnection) {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Querying Exchange Object"
              $TimeoutActionTargetId = (Get-UnifiedGroup -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ExternalDirectoryObjectId
            }
            else {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Querying AzureAD Object"
              $TimeoutActionTargetId = (Get-AzureADGroup -ObjectId "$TimeoutActionTarget" -ErrorAction STOP).ObjectId
            }
            if ($null -eq $TimeoutActionTargetId) {
              throw
            }
            else {
              Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Object found!"
              $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
            }
          }
          catch {
            Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Querying AzureAD Object: Mailnickname"
            try {
              if ($TimeoutActionTarget.Contains("@")) {
                $TimeoutActionTargetId = (Get-AzureADGroup -SearchString $($TimeoutActionTarget.Split("@")[0]) -ErrorAction STOP).ObjectId
              }
              else {
                $TimeoutActionTargetId = (Get-AzureADGroup -SearchString $($TimeoutActionTarget.Replace(" ", "")) -ErrorAction STOP).ObjectId
              }
              if ($null -eq $TimeoutActionTargetId) {
                throw
              }
              else {
                Write-Verbose -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' - Object found!"
                $Parameters += @{'TimeoutActionTarget' = $TimeoutActionTargetId }
              }
            }
            catch {
              Write-Warning -Message "'$NameNormalised' TimeoutAction '$TimeoutAction': TimeoutActionTarget '$TimeoutActionTarget' not set! Error enumerating Target"
            }
          }
          #endregion
        }
      }
    }
    else {
      #no Target specified. Using existing
      $TimeoutActionTarget = $CallQueue.TimeoutActionTarget
    }

    #endregion

    #region TimeoutAction SharedVoicemail - Processing
    if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailAudioFile')) {
      $OFSVMFileName = Split-Path $TimeoutSharedVoicemailAudioFile -Leaf
      Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Parsing: '$OFSVMFileName'" -Verbose
      try {
        $OFSVMFile = Import-TeamsAudioFile -ApplicationType CallQueue -File $TimeoutSharedVoicemailAudioFile -ErrorAction STOP
        Write-Verbose -Message "'$NameNormalised' TimeoutSharedVoicemailAudioFile:  Using:   '$($OFSVMFile.FileName)'"
        $Parameters += @{'TimeoutSharedVoicemailAudioFilePrompt' = $OFSVMFile.Id }
      }
      catch {
        Write-Error -Message "Import of TimeoutSharedVoicemailAudioFile: '$OFSVMFileName' failed." -Category InvalidData -RecommendedAction "Please check file size and compression ratio. If in doubt, provide WAV"
        break
      }
    }

    if ($PSBoundParameters.ContainsKey('TimeoutSharedVoicemailTextToSpeechPrompt')) {
      $Parameters += @{'TimeoutSharedVoicemailTextToSpeechPrompt' = $TimeoutSharedVoicemailTextToSpeechPrompt }
    }

    if ($PSBoundParameters.ContainsKey('EnableTimeoutSharedVoicemailTranscription')) {
      $Parameters += @{'EnableTimeoutSharedVoicemailTranscription' = $EnableOverflowSharedVoicemailTranscription }
    }
    #endregion
    #endregion


    #region Users - Parsing and verifying Users
    [System.Collections.ArrayList]$UserIdList = @()
    if ($PSBoundParameters.ContainsKey('Users')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Users"
      foreach ($User in $Users) {
        if (Test-AzureADUser $User) {
          # Determine ID from UPN
          $UserObject = Get-AzureADUser -ObjectId "$User"
          $UserLicenseObject = Get-AzureADUserLicenseDetail -ObjectId $($UserObject.ObjectId)
          $ServicePlanName = "MCOEV"
          $ServicePlanStatus = ($UserLicenseObject.ServicePlans | Where-Object ServicePlanName -EQ $ServicePlanName).ProvisioningStatus
          if ($ServicePlanStatus -ne "Success") {
            # User not licensed (doesn't have Phone System)
            Write-Warning -Message "User '$User' License (PhoneSystem):   FAILED - User is not correctly licensed, omitting User"
          }
          else {
            Write-Verbose -Message "User '$User' License (PhoneSystem):   SUCCESS"
            $EVenabled = $(Get-CsOnlineUser $User).EnterpriseVoiceEnabled
            if (-not $EVenabled) {
              # User not EV-Enabled
              Write-Warning -Message "User '$User' EnterpriseVoice-Enabled: FAILED - Omitting User"
            }
            else {
              # Add to List
              Write-Verbose -Message "User '$User' EnterpriseVoice-Enabled: SUCCESS"
              Write-Verbose -Message "User '$User' will be added to CallQueue" -Verbose
              [void]$UserIdList.Add($UserObject.ObjectId)
            }
          }
        }
        else {
          Write-Warning -Message "'$NameNormalised' User '$User' not found in AzureAd, omitting user!"
        }
      }
      $Parameters += @{'Users' = @($UserIdList) }
    }
    #endregion

    #region Groups - Parsing Distribution Lists and their Users
    [System.Collections.ArrayList]$DLIdList = @()
    if ($PSBoundParameters.ContainsKey('DistributionLists')) {
      Write-Verbose -Message "'$NameNormalised' Parsing Distribution Lists"
      foreach ($DL in $DistributionLists) {
        # Determine ID from UPN
        if (Test-AzureADGroup "$DL") {
          $DLObject = Get-AzureADGroup -SearchString "$DL"
          if ($null -eq $DLObject) {
            $DL2 = $DL.Split('@')[0]
            $DLObject = Get-AzureADGroup -SearchString "$DL2"
            if ($null -eq $DLObject) {
              try {
                $DLObject = Get-AzureADGroup -ObjectId "$DL"
              }
              catch {
                Write-Warning -Message "Group '$DL' not found in AzureAd, omitting Group!"
              }
            }
          }
        }

        if ($DLObject) {
          Write-Verbose -Message "Group '$DL' will be added to the Call Queue" -Verbose
          # Test whether Users in DL are enabled for EV and/or licensed?

          # Add to List
          [void]$DLIdList.Add($DLObject.ObjectId)
        }
        else {
          Write-Warning -Message "Group '$DL' not found in AzureAd, omitting Group!"
        }
      }
      $Parameters += @{'DistributionLists' = @($DLIdList) }
      if ($DLIdList.Count -gt 0) {
        Write-Verbose -Message "NOTE: Group members are parsed by the subsystem" -Verbose
        Write-Verbose -Message "Currently no verification steps are taken against Licensing or EV-Enablement of Members" -Verbose

      }
    }
    #endregion


    #region Common parameters
    if (-not ($PSBoundParameters.ContainsKey('Silent'))) {
      $Parameters += @{'WarningAction' = 'SilentlyContinue' }
    }
    else {
      $Parameters += @{'WarningAction' = 'Continue' }
    }
    $Parameters += @{'ErrorAction' = 'STOP' }
    #endregion
    #endregion


    #region ACTION
    # Set the Call Queue with all Parameters provided
    if ($PSCmdlet.ShouldProcess("$Name", "Set-CsCallQueue")) {
      $Null = (Set-CsCallQueue @Parameters)
      Write-Verbose -Message "SUCCESS: '$NameNormalised' Call Queue settings applied"
    }
    #endregion


    #region Output
    # Re-query output
    #$CallQueueFinal = Get-CsCallQueue -NameFilter $NameNormalised -WarningAction SilentlyContinue
    if (-not ($PSBoundParameters.ContainsKey('Silent'))) {
      $CallQueueFinal = Get-TeamsCallQueue -Name "$NameNormalised" -WarningAction SilentlyContinue
      Return $CallQueueFinal
    }
    else {
      Return
    }
    #endregion

  }

  end {

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
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  param(
    # Pipline does not work properly - rebind to Identity? or query with Get-TeamsCallQueue instead?
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the Call Queue")]
    [string]$Name
  )

  begin {
    # Caveat - Script in Testing
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    #Write-Warning -Message "This Script is currently in testing. Please feed back issues encountered"

    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection to AzureAD - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection to"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

  } # end of begin

  process {
    try {
      Write-Verbose -Message "The listed Queues have been removed" -Verbose
      $QueueToRemove = Get-CsCallQueue -NameFilter "$Name" -WarningAction SilentlyContinue
      foreach ($Q in $QueueToRemove) {
        if ($PSCmdlet.ShouldProcess("'Call Queue: '$($Q.Identity)'", 'Remove-CsCallQueue')) {
          Remove-CsCallQueue -Identity $($Q.Identity) -ErrorAction STOP
        }
      }
    }
    catch {
      Write-Error -Message "Removal of Call Queue '$($CallQueueToRemove.Name)' failed" -Category OperationStopped
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
      return
    }

  }
  end {

  }
}
#endregion

#region Resource Account Connection
function Get-TeamsResourceAccountAssociation {
  <#
	.SYNOPSIS
		Queries a Resource Account Association
	.DESCRIPTION
		Queries an existing Resource Account and lists its Association (if any)
	.PARAMETER UserPrincipalName
		Optional. UPN(s) of the Resource Account(s) to be queried
	.EXAMPLE
		Get-TeamsResourceAccountAssociation
		Queries all Resource Accounts and enumerates their Association as well as the Association Status
	.EXAMPLE
		Get-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
		Queries the Association of the Account 'ResourceAccount@domain.com'
	.NOTES
		Combination of Get-CsOnlineApplicationInstanceAssociation and Get-CsOnlineApplicationInstanceAssociationStatus but with friendly Names
		Without any Parameters, can be used to enumerate all Resource Accounts
		This may take a while to calculate, depending on # of Accounts in the Tenant
	#>
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to manipulate.")]
    [Alias('Identity')]
    [string[]]$UserPrincipalName
  )
  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }


  }
  process {
    # Querying ObjectId from provided UPNs
    if ($null -eq $UserPrincipalName) {
      # Getting all RAs
      Write-Verbose -Message "Querying all Resource Accounts, please wait..." -Verbose
      $Accounts = Get-CsOnlineApplicationInstance
    }
    else {
      # Query $UserPrincipalName
      [System.Collections.ArrayList]$Accounts = @()
      foreach ($UPN in $UserPrincipalName) {
        Write-Verbose -Message "Querying Resource Account '$UPN'"
        try {
          $RAObject = Get-AzureADUser -ObjectId $UPN -ErrorAction Stop
          $AppInstance = Get-CsOnlineApplicationInstance $RAObject.ObjectId -ErrorAction Stop
          [void]$Accounts.Add($AppInstance)
          Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
        }
        catch {
          Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
          continue
        }
      }
    }

    # Processing found accounts
    [System.Collections.ArrayList]$AllAccounts = @()
    if ($null -ne $Accounts) {
      foreach ($Account in $Accounts) {
        $Association = Get-CsOnlineApplicationInstanceAssociation $Account.ObjectId -ErrorAction SilentlyContinue
        $ApplicationType = GetApplicationTypeFromAppId $Account.ApplicationId
        if ($null -ne $Association) {
          # Finding associated entity
          $AssocObject = switch ($Association.ConfigurationType) {
            'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId }
            'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $Account.ObjectId -ErrorAction SilentlyContinue
        }
        else {
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - No Association found!" -Verbose
          continue
        }

        # Output
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $Account.UserPrincipalName
          ConfigurationType = $ApplicationType
          Status            = $AssociationStatus.Status
          StatusCode        = $AssociationStatus.StatusCode
          StatusMessage     = $AssociationStatus.Message
          StatusTimeStamp   = $AssociationStatus.StatusTimestamp
          AssociatedTo      = $AssocObject.Name

        }

        [void]$AllAccounts.Add($ResourceAccountAssociationObject)
      }
      return $AllAccounts
    }
    else {
      Write-Verbose -Message "No Accounts found" -Verbose
    }
  }
}

function New-TeamsResourceAccountAssociation {
  <#
	.SYNOPSIS
		Connects a Resource Account to a CQ or AA
	.DESCRIPTION
		Associates an existing Resource Account to a Call Queue or Auto Attendant
		Resource Account Type is checked against the ApplicationType.
		User is prompted if types do not match
	.PARAMETER UserPrincipalName
		Required. UPN(s) of the Resource Account(s) to be associated to a Call Queue or AutoAttendant
	.PARAMETER CallQueue
		Optional. Specifies the connection to be made to the provided Call Queue Name
	.PARAMETER AutoAttendant
		Optional. Specifies the connection to be made to the provided Auto Attendant Name
	.PARAMETER Force
		Optional. Suppresses Confirmation dialog if -Confirm is not provided
		Used to override prompts for alignment of ApplicationTypes.
		The Resource Account is changed to have the same type as the associated Object (CallQueue or AutoAttendant)!
	.EXAMPLE
		New-TeamsResourceAccountAssociation -UserPrincipalName Account1@domain.com -
		Explanation of what the example does
	.INPUTS
		Inputs (if any)
	.OUTPUTS
		Output (if any)
	.NOTES
		General notes
	#>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'CallQueue')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to change")]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $true, ParameterSetName = 'CallQueue', Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the CallQueue")]
    [string]$CallQueue,

    [Parameter(Mandatory = $true, ParameterSetName = 'AutoAttendant', Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "Name of the AutoAttendant")]
    [string]$AutoAttendant,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  )
  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }

  }
  process {
    # Query $UserPrincipalName
    [System.Collections.ArrayList]$Accounts = @()
    foreach ($UPN in $UserPrincipalName) {
      Write-Verbose -Message "Querying Resource Account '$UPN'"
      try {
        $RAObject = Get-AzureADUser -ObjectId $UPN -ErrorAction Stop
        $AppInstance = Get-CsOnlineApplicationInstance $RAObject.ObjectId -ErrorAction Stop
        [void]$Accounts.Add($AppInstance)
        Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
      }
      catch {
        Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
        continue
      }
    }

    # Processing found accounts
    [System.Collections.ArrayList]$AllAccounts = @()
    if ($null -ne $Accounts) {
      #region Connection to Call Queue
      if ($PSBoundParameters.ContainsKey('CallQueue')) {
        # Querying Call Queue by Name - need Unique Result
        Write-Verbose -Message "Querying Call Queue '$CallQueue'"
        $CallQueueObj = Get-CsCallQueue -NameFilter "$CallQueue" -WarningAction SilentlyContinue
        if ($null -eq $CallQueueObj) {
          Write-Error "'$CallQueue' - Not found" -Category ParserError -RecommendedAction  "Please check 'CallQueue' exists with this Name"
          break
        }
        elseif ($CallQueueObj.GetType().BaseType.Name -eq "Array") {
          Write-Error "'$CallQueue' - Multiple Results found! Cannot determine unique result. Please use New-CsOnlineApplicationInstanceAssociation!" -Category ParserError -RecommendedAction  "Please use New-CsOnlineApplicationInstanceAssociation!"
          $CallQueueObj | Select-Object Identity, Name | Format-Table
          Write-Verbose -Message "This script is based on lookup via Name, which requires a unique Name to process. Please use New-CsOnlineApplicationInstanceAssociation!"
          break
        }
        else {
          Write-Verbose -Message "'$CallQueue' - Unique result found: $($CallQueueObj.Identity)"
        }

        # Query existing connection
        $ExistingConnection = $null
        $ExistingConnection = Get-TeamsResourceAccountAssociation $UPN
        if ($null -eq $ExistingConnection.AssociatedTo) {
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - No assignment found. OK"
        }
        else {
          Write-Error -Message "'$($Account.UserPrincipalName)' - This account is already assigned to $($ExistingConnection.ConfigurationType) '$($ExistingConnection.AssociatedTo)'"
          $ExistingConnection
          break
        }

        # Processing Call Queue
        Write-Verbose -Message "Processing assignment of all Accounts to Call Queue"
        foreach ($Account in $Accounts) {
          # Comparing ApplicationType
          if ((Get-TeamsResourceAccount -Identity $Account.UserPrincipalName).ApplicationType -ne "CallQueue") {
            if ($PSBoundParameters.ContainsKey('Force')) {
              # Changing Application Type
              Write-Verbose -Message "'$($Account.UserPrincipalName)' - Changing Application Type to 'CallQueue'" -Verbose
              $null = Set-CsOnlineApplicationInstance -Identity $Account.ObjectId -ApplicationId $(GetAppIdfromApplicationType CallQueue)
              Start-Process Sleep 2
              if ("CallQueue" -ne $(GetApplicationTypeFromAppId (Get-CsOnlineApplicationInstance -Identity $Account.ObjectId).ApplicationId)) {
                Write-Error -Message "'$($Account.UserPrincipalName)' - Application type could not be changed" -Category InvalidType
                break
              }
              else {
                Write-Verbose -Message "SUCCESS"
              }
            }
            else {
              Write-Error -Message "'$($Account.UserPrincipalName)' - Application type does not match!" -Category InvalidType -RecommendedAction "Please change manually or use -Force switch"
            }
          }
          else {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - Application type matches Call Queue - OK"
          }

          # Establishing Association
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Assigning to Call Queue: '$CallQueue'"
          if ($PSCmdlet.ShouldProcess("$($Account.UserPrincipalName)", "New-CsOnlineApplicationInstanceAssociation")) {
            $OperationStatus = New-CsOnlineApplicationInstanceAssociation -Identities $Account.ObjectId -ConfigurationType CallQueue -ConfigurationId $CallQueueObj.Identity
          }
        }
        # Requery Association Target
        $AssociationTarget = Get-CsCallQueue -Identity $OperationStatus.Results.ConfigurationId -ErrorAction SilentlyContinue

        # Output
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $Account.UserPrincipalName
          ConfigurationType = $OperationStatus.Results.ConfigurationType
          Result            = $OperationStatus.Results.Result
          StatusCode        = $OperationStatus.Results.StatusCode
          StatusMessage     = $OperationStatus.Results.Message
          AssociatedTo      = $AssociationTarget.Name

        }
        [void]$AllAccounts.Add($ResourceAccountAssociationObject)
      }
      #endregion

      #region Connection to Auto Attendant
      if ($PSBoundParameters.ContainsKey('AutoAttendant')) {
        # Querying Auto Attendant by Name - need Unique Result
        Write-Verbose -Message "Querying Auto Attendant '$AutoAttendant'"
        $AutoAttendantObj = Get-CsAutoAttendant -NameFilter "$AutoAttendant" -WarningAction SilentlyContinue
        if ($null -eq $AutoAttendantObj) {
          Write-Error "'$AutoAttendant' - Not found" -Category ParserError -RecommendedAction  "Please check 'AutoAttendant' exists with this Name"
          break
        }
        elseif ($AutoAttendantObj.GetType().BaseType.Name -eq "Array") {
          Write-Error "'$AutoAttendant' - Multiple Results found! Cannot determine unique result. Please use New-CsOnlineApplicationInstanceAssociation!" -Category ParserError -RecommendedAction  "Please use New-CsOnlineApplicationInstanceAssociation!"
          $AutoAttendantObj | Select-Object Identity, Name | Format-Table
          Write-Verbose -Message "This script is based on lookup via Name, which requires a unique Name to process. Please use New-CsOnlineApplicationInstanceAssociation!"
          break
        }
        else {
          Write-Verbose -Message "'$AutoAttendant' - Unique result found: $($AutoAttendantObj.Identity)"
        }

        # Query existing connection
        $ExistingConnection = $null
        $ExistingConnection = Get-TeamsResourceAccountAssociation $UPN
        if ($null -eq $ExistingConnection.AssociatedTo) {
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - No assignment found. OK"
        }
        else {
          Write-Error -Message "'$($Account.UserPrincipalName)' - This account is already assigned to $($ExistingConnection.ConfigurationType) '$($ExistingConnection.AssociatedTo)'"
          $ExistingConnection
          break
        }


        # Processing Auto Attendant
        Write-Verbose -Message "Processing assignment of all Accounts to Auto Attendant"
        foreach ($Account in $Accounts) {
          # Comparing ApplicationType
          if ((Get-TeamsResourceAccount -Identity $Account.UserPrincipalName).ApplicationType -ne "AutoAttendant") {
            if ($PSBoundParameters.ContainsKey('Force')) {
              # Changing Application Type
              Write-Verbose -Message "'$($Account.UserPrincipalName)' - Changing Application Type to 'AutoAttendant'" -Verbose
              $null = Set-CsOnlineApplicationInstance -Identity $Account.ObjectId -ApplicationId $(GetAppIdfromApplicationType AutoAttendant)
              Start-Process Sleep 2
              if ("AutoAttendant" -ne $(GetApplicationTypeFromAppId (Get-CsOnlineApplicationInstance -Identity $Account.ObjectId).ApplicationId)) {
                Write-Error -Message "'$($Account.UserPrincipalName)' - Application type could not be changed" -Category InvalidType
                break
              }
              else {
                Write-Verbose -Message "SUCCESS"
              }
            }
            else {
              Write-Error -Message "'$($Account.UserPrincipalName)' - Application type does not match!" -Category InvalidType -RecommendedAction "Please change manually or use -Force switch"
            }
          }
          else {
            Write-Verbose -Message "'$($Account.UserPrincipalName)' - Application type matches Auto Attendant - OK"
          }


          # Establishing Association
          Write-Verbose -Message "'$($Account.UserPrincipalName)' - Assigning to Auto Attendant: '$AutoAttendant'"
          if ($PSCmdlet.ShouldProcess("$($Account.UserPrincipalName)", "New-CsOnlineApplicationInstanceAssociation")) {
            $OperationStatus = New-CsOnlineApplicationInstanceAssociation -Identities $Account.ObjectId -ConfigurationType AutoAttendant -ConfigurationId $AutoAttendantObj.Identity
          }
        }
        # Requery Association Target
        $AssociationTarget = Get-CsAutoAttendant -Identity $OperationStatus.Results.ConfigurationId -ErrorAction SilentlyContinue

        # Output
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $Account.UserPrincipalName
          ConfigurationType = $OperationStatus.Results.ConfigurationType
          Result            = $OperationStatus.Results.Result
          StatusCode        = $OperationStatus.Results.StatusCode
          StatusMessage     = $OperationStatus.Results.Message
          AssociatedTo      = $AssociationTarget.Name

        }
        [void]$AllAccounts.Add($ResourceAccountAssociationObject)
      }
      #endregion

      return $AllAccounts
    }
    else {
      Write-Warning -Message "No Accounts found"
    }
  }
}

function Remove-TeamsResourceAccountAssociation {
  <#
	.SYNOPSIS
		Removes the connection between a Resource Account and a CQ or AA
	.DESCRIPTION
		Removes an associated Resource Account from a Call Queue or Auto Attendant
	.PARAMETER UserPrincipalName
		Required. UPN(s) of the Resource Account(s) to be removed from a Call Queue or AutoAttendant
	.PARAMETER Force
		Optional. Suppresses Confirmation dialog if -Confirm is not provided
	.EXAMPLE
		Remove-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
		Removes the Association of the Account 'ResourceAccount@domain.com' from the identified Call Queue or Auto Attendant
	.NOTES
		Does the same as Remove-CsOnlineApplicationInstanceAssociation, but with friendly Names
		General notes
	#>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to manipulate.")]
    [Alias('Identity')]
    [string[]]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  )
  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
    }


  }
  process {
    # Querying ObjectId from provided UPNs
    [System.Collections.ArrayList]$Accounts = @()
    foreach ($UPN in $UserPrincipalName) {
      try {
        $RAObject = Get-AzureADUser -ObjectId $UPN -ErrorAction Stop
        $AppInstance = Get-CsOnlineApplicationInstance $RAObject.ObjectId -ErrorAction Stop
        [void]$Accounts.Add($AppInstance)
        Write-Verbose "Resource Account found: '$($AppInstance.DisplayName)'"
      }
      catch {
        Write-Error "Resource Account not found: '$UPN'" -Category ObjectNotFound
        continue
      }
    }

    # Processing found accounts
    [System.Collections.ArrayList]$AllAccounts = @()
    if ($null -ne $Accounts) {
      foreach ($Account in $Accounts) {
        $Association = Get-CsOnlineApplicationInstanceAssociation $Account.ObjectId -ErrorAction SilentlyContinue
        if ($null -ne $Association) {
          # Finding associated entity
          $AssocObject = switch ($Association.ConfigurationType) {
            'CallQueue' { Get-CsCallQueue -Identity $Association.ConfigurationId }
            'AutoAttendant' { Get-CsAutoAttendant -Identity $Association.ConfigurationId }
          }

          # Removing Association
          try {
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Removing Association of the Target Account to $($Association.ConfigurationType) '$($AssocObject.Name)'")) {
              Write-Verbose -Message "'$UserPrincipalName' - Removing Association to $($Association.ConfigurationType) '$($AssocObject.Name)'"
              $OperationStatus = Remove-CsOnlineApplicationInstanceAssociation $Association.Id -ErrorAction Stop
            }
            else {
              continue
            }
          }
          catch {
            Write-ErrorRecord $_
          }
        }
        else {
          Write-Verbose -Message "'$UserPrincipalName' - No Association found!" -Verbose
          continue
        }

        # Output
        $ResourceAccountAssociationObject = [PSCustomObject][ordered]@{
          UserPrincipalName  = $Account.UserPrincipalName
          ConfigurationType  = $OperationStatus.Results.ConfigurationType
          Result             = $OperationStatus.Results.Result
          StatusCode         = $OperationStatus.Results.StatusCode
          StatusMessage      = $OperationStatus.Results.Message
          AssociatedTo       = $null
          AssociationRemoved = $AssocObject.Name

        }
        [void]$AllAccounts.Add($ResourceAccountAssociationObject)
      }
      return $AllAccounts
    }
    else {
      Write-Warning -Message "No Accounts found"
    }
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
		This Function was designed to create the ApplicationInstance in AD,
		apply a UsageLocation to the corresponding AzureAD User,
		license the User and subsequently apply a phone number, all with one Command.
	.PARAMETER UserPrincipalName
		Required. The UPN for the new ResourceAccount. Invalid characters are stripped from the provided string
	.PARAMETER DisplayName
		Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
	.PARAMETER ApplicationType
		Required. CallQueue or AutoAttendant. Determines the association the account can have:
		A resource Account of the type "CallQueue" can only be associated with to a Call Queue
		A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
		NOTE: The type can be switched later, though this is not recommended.
	.PARAMETER UsageLocation
		Required. Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
		Before a License can be assigned, the account needs a Usage Location populated.
	.PARAMETER License
		Optional. Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
		If not provided, will default to PhoneSystem_VirtualUser
		Unlicensed Objects can exist, but cannot be assigned a phone number
		NOTE: PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
	.PARAMETER PhoneNumber
		Optional. Adds a Microsoft or Direct Routing Number to the Resource Account.
		Requires the Resource Account to be licensed (License Switch)
		Required format is E.164, starting with a '+' and 10-15 digits long.
	.EXAMPLE
		New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -ApplicationType CallQueue -UsageLocation US
		Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
		User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
		DisplayName will be taken from the User PrincipalName and normalised to "ResourceAccount"
	.EXAMPLE
		New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -Displayname "My {ResourceAccount}" -ApplicationType CallQueue -UsageLocation US
		Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
		User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
		DisplayName will be normalised to "My ResourceAccount"
	.EXAMPLE
		New-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -Displayname "Mainline" -ApplicationType AutoAttendant -UsageLocation US -License PhoneSystem -PhoneNumber +1555123456
		Creates a Resource Account for Auto Attendants with a Usage Location for 'US'
		Applies the specified PhoneSystem License (if available in the Tenant)
		Assigns the Telephone Number if object could be licensed correctly.
	.NOTES
		CmdLet currently in testing.
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Creates a resource Account in AzureAD for use in Teams
	.LINK
		Find-TeamsResourceAccount
		Set-TeamsResourceAccount
		Get-TeamsResourceAccount
		Remove-TeamsResourceAccount
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = "UPN of the Object to create.")]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
          $false
        }
      })]
    [Alias("Identity")]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = "Display Name for this Object")]
    [string]$DisplayName,

    [Parameter(Mandatory = $true, HelpMessage = "CallQueue or AutoAttendant")]
    [ValidateSet("CallQueue", "AutoAttendant", "CQ", "AA")]
    [Alias("Type")]
    [string]$ApplicationType,

    [Parameter(Mandatory = $true, HelpMessage = "Usage Location to assign")]
    [string]$UsageLocation,

    [Parameter(HelpMessage = "License to be assigned")]
    #[ValidateSet("PhoneSystem","PhoneSystem_VirtualUser")]
    [ValidateSet("PhoneSystem_VirtualUser")]
    [string]$License = "PhoneSystem_VirtualUser",

    [Parameter(HelpMessage = "Telephone Number to assign")]
    [ValidateScript( {
        If ($_ -match "^\+[0-9]{10,15}$") {
          $True
        }
        else {
          Write-Host "Not a valid phone number. Must start with a + and 10 to 15 digits long" -ForeGroundColor Red
          $false
        }
      })]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

  } # end of begin

  process {
    #TODO Use Set-TeamsUSerLicense in NEW and SET!
    #TODO Change behaviour of script if no Exchange Connection is there!
    # DO: Write-Warning "no connection to Exchange, Unified Group cannot be verified."

    #region PREPARATION
    Write-Verbose -Message "--- PREPARATION ---"
    #region Normalising $UserPrincipalname
    $UPN = Format-StringForUse -InputString $UserPrincipalName -As UserPrincipalName
    Write-Verbose -Message "UserPrincipalName normalised to: '$UPN'"
    #endregion

    #region Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      $Name = Format-StringForUse -InputString $DisplayName -As DisplayName
    }
    else {
      $Name = Format-StringForUse -InputString $($UserPrincipalName.Split('@')[0]) -As DisplayName
    }
    Write-Verbose -Message "DisplayName normalised to: '$Name'"
    #endregion

    #region ApplicationType
    # Translating $ApplicationType (Name) to ID used by Commands.
    $AppId = GetAppIdfromApplicationType $ApplicationType
    Write-Verbose -Message "'$Name' ApplicationType parsed"
    #endregion

    #region PhoneNumbers
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Loading all Microsoft Telephone Numbers
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
      Write-Verbose -Message "'$Name' PhoneNumber parsed"
    }
    #endregion

    #region UsageLocation
    if ($PSBoundParameters.ContainsKey('UsageLocation')) {
      Write-Verbose -Message "'$Name' UsageLocation parsed"
    }
    else {
      # Querying Tenant Country as basis for Usage Location
      # This is never triggered as UsageLocation is mandatory! Remaining here regardless
      $Tenant = Get-CsTenant
      if ($null -ne $Tenant.CountryAbbreviation) {
        $UsageLocation = $Tenant.CountryAbbreviation
        Write-Warning -Message "'$Name' UsageLocation not provided. Defaulting to: $UsageLocation. - Please verify before assigning the account!"
      }
      else {
        Write-Error -Message "'$Name' Usage Location not provided and Country not found in the Tenant!" -Category ObjectNotFound -RecommendedAction "Please run command again and specify -UsageLocation"
        break
      }
    }
    #endregion
    #endregion


    #region ACTION
    Write-Verbose -Message "--- ACTIONS -------"
    #region Creating Account
    try {
      #Trying to create the Resource Account
      Write-Verbose -Message "'$Name' Creating Resource Account with New-CsOnlineApplicationInstance..."
      if ($PSCmdlet.ShouldProcess("$UPN", "New-CsOnlineApplicationInstance")) {
        $null = (New-CsOnlineApplicationInstance -UserPrincipalName $UPN -ApplicationId $AppId -DisplayName $Name -ErrorAction STOP)
        $i = 0
        $imax = 20
        Write-Verbose -Message "Resource Account '$Name' ($ApplicationType) created; Please be patient while we wait ($imax s) to be able to parse the Object." -Verbose
        Write-Verbose -Message "Waiting for Get-AzureAdUser to return a Result..."
        while ( -not (Test-AzureADUser $UPN)) {
          if ($i -gt $imax) {
            Write-Error -Message "Could not find Object in AzureAD in the last $imax Seconds" -Category ObjectNotFound -RecommendedAction "Please verify Object has been creaated (UserPrincipalName); Continue with Set-TeamsResourceAccount"
            break
          }
          Write-Progress -Activity "'$Name' Azure Active Directory is creating the Object. Please wait" `
            -PercentComplete (($i * 100) / $imax) `
            -Status "$(([math]::Round((($i)/$imax * 100),0))) %"

          Start-Sleep -Milliseconds 1000
          $i++
        }
        $ResourceAccountCreated = Get-AzureADUser -ObjectId "$UPN"
      }
      else {
        break
      }
    }
    catch {
      # Catching anything
      Write-Host "ERROR:   Creation failed: $($_.Exception.Message)" -ForegroundColor Red
      break
    }
    #endregion

    #region UsageLocation
    try {
      if ($PSCmdlet.ShouldProcess("$UPN", "Set-AzureADUser -UsageLocation $UsageLocation")) {
        Set-AzureADUser -ObjectId $UPN -UsageLocation $UsageLocation -ErrorAction STOP
        Write-Verbose -Message "'$Name' SUCCESS - Usage Location set to: $UsageLocation"
      }
    }
    catch {
      if ($PSBoundParameters.ContainsKey("License")) {
        Write-Error -Message "'$Name' Usage Location could not be set." -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount to apply license and phone number"
      }
      else {
        Write-Warning -Message "'$Name' Usage Location cannot be set. If a license is needed, please assign UsageLocation manually before assigning a license"
      }
    }
    #endregion

    #region Licensing
    # Licensing the new Account
    if ($PSBoundParameters.ContainsKey("License")) {
      # Verifying License is available to be assigned
      # Determining available Licenses from Tenant
      Write-Verbose -Message "'$Name' Querying Licenses..."
      $TenantLicenses = Get-TeamsTenantLicense
      $RemainingPSlicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "MCOEV" }).Remaining
      Write-Verbose -Message "INFO: $RemainingPSlicenses remaining Phone System Licenses"
      $RemainingPSVUlicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "PHONESYSTEM_VIRTUALUSER" }).Remaining
      Write-Verbose -Message "INFO: $RemainingPSVUlicenses remaining Phone System Virtual User Licenses"

      # Assigning License
      switch ($License) {
        "PhoneSystem" {
          $ServicePlanName = "MCOEV"
          # PhoneSystem is currently disabled
          # It would require an E1/E3 license in addition OR a full E5 license
          # Deliberations and confirmation needed.

          # Free License
          if ($RemainingPSlicenses -lt 1) {
            Write-Warning -Message "ERROR: No free PhoneSystem License remaining in the Tenant. Trying to assign..."
          }
          else {
            try {
              if ($PSCmdlet.ShouldProcess("$UPN", "Add-TeamsUserLicense -AddPhoneSystem")) {
                $null = (Add-TeamsUserLicense -Identity $UPN -AddPhoneSystem -WarningAction STOP -ErrorAction STOP)
                Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'"
                $Islicensed = $true
              }
            }
            catch {
              Write-Error -Message "'$Name' License assignment failed"
              Write-ErrorRecord $_ #This handles the eror message in human readable format.
            }
          }
        }
        "PhoneSystem_VirtualUser" {
          $ServicePlanName = "MCOEV_VIRTUALUSER"
          if ($RemainingPSVUlicenses -lt 1) {
            Write-Error -Message "ERROR: No free PhoneSystem Virtual User License remaining in the Tenant."
          }
          else {
            try {
              if ($PSCmdlet.ShouldProcess("$UPN", "Add-TeamsUserLicense -AddPhoneSystemVirtualUser")) {
                $null = (Add-TeamsUserLicense -Identity $UPN -WarningAction STOP -AddPhoneSystemVirtualUser -ErrorAction STOP)
                Write-Verbose -Message "'$Name' SUCCESS - License Assigned: '$License'"
                $Islicensed = $true
              }
            }
            catch {
              Write-Error -Message "'$Name' License assignment failed"
              Write-ErrorRecord $_ #This handles the eror message in human readable format.
            }
          }
        }
      }
    }
    else {
      $Islicensed = $false
    }
    #endregion

    #region Waiting for License Application
    if ($PSBoundParameters.ContainsKey("License") -and $PSBoundParameters.ContainsKey("PhoneNumber")) {
      $i = 0
      $imax = 300
      Write-Warning -Message "Applying a License may take longer than provisioned for ($($imax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
      Write-Verbose -Message "Waiting for Get-AzureAdUserLicenseDetail to return a Result..."
      while (-not (Test-TeamsUserLicense -Identity $UPN -ServicePlan $ServicePlanName)) {
        if ($i -gt $imax) {
          Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $imax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount"
          break
        }
        Write-Progress -Activity "'$Name' Azure Active Directory is applying License. Please wait" `
          -PercentComplete (($i * 100) / $imax) `
          -Status "$(([math]::Round((($i)/$imax * 100),0))) %"

        Start-Sleep -Milliseconds 1000
        $i++
      }
    }
    #endregion

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Assigning Telephone Number
      Write-Verbose -Message "'$Name' Processing Phone Number"
      Write-Verbose -Message "NOTE: Assigning a phone number might fail if the Object is not yet replicated" -Verbose
      if (-not $Islicensed) {
        Write-Host "ERROR: A Phone Number can only be assigned to licensed objects." -ForegroundColor Red
        Write-Host "Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both"
      }
      else {
        # Processing paths for Telephone Numbers depending on Type
        if ($PhoneNumberIsMSNumber) {
          # Set in VoiceApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' found in Tenant, assuming provisioning for: Microsoft Calling Plans"
          try {
            if ($PSCmdlet.ShouldProcess("$($ResourceAccountCreated.UserPrincipalName)", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $PhoneNumber")) {
              $null = (Set-CsOnlineVoiceApplicationInstance -Identity $ResourceAccountCreated.UserPrincipalName -Telephonenumber $PhoneNumber -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message "Phone number could not be assigned! Please run Set-TeamsResourceAccount manually"
          }
        }
        else {
          # Set in ApplicationInstance
          Write-Verbose -Message "'$Name' Number '$PhoneNumber' not found in Tenant, assuming provisioning for: Direct Routing"
          try {
            if ($PSCmdlet.ShouldProcess("$($ResourceAccountCreated.UserPrincipalName)", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $PhoneNumber")) {
              $null = (Set-CsOnlineApplicationInstance -Identity $ResourceAccountCreated.UserPrincipalName -OnPremPhoneNumber $PhoneNumber -ErrorAction STOP)
            }
          }
          catch {
            Write-Warning -Message "'$Name' Number '$PhoneNumber' not assigned! Please run Set-TeamsResourceAccount manually"
          }
        }
      }
    }
    #  Wating for AAD to write the PhoneNumber so that it may be queried correctly
    Write-Verbose -Message "'$Name' Waiting for AAD to write '$PhoneNumber' Waiting for 2s "
    Start-Sleep -Seconds 2
    #endregion
    #endregion

    #region Output
    #Creating new PS Object
    try {
      Write-Verbose -Message "'$Name' Preparing Output Object"
      # Data
      $ResourceAccount = Get-CsOnlineApplicationInstance -Identity $UPN -ErrorAction STOP

      # readable Application type
      $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId

      # Resource Account License
      if ($Islicensed) {
        # License
        if (Test-TeamsUserLicense -Identity $UPN -ServicePlan MCOEV) {
          $ResourceAccuntLicense = "PhoneSystem"
        }
        elseif (Test-TeamsUserLicense -Identity $UPN -ServicePlan MCOEV_VIRTUALUSER) {
          $ResourceAccuntLicense = "PhoneSystem_VirtualUser"
        }
        else {
          $ResourceAccuntLicense = $null
        }

        if ($null -ne $ResourceAccount.PhoneNumber) {
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
        UserPrincipalName = $ResourceAccount.UserPrincipalName
        DisplayName       = $ResourceAccount.DisplayName
        UsageLocation     = $UsageLocation
        ApplicationType   = $ResourceAccountApplicationType
        License           = $ResourceAccuntLicense
        PhoneNumberType   = $ResourceAccountPhoneNumberType
        PhoneNumber       = $ResourceAccount.PhoneNumber
      }

      Write-Verbose -Message "Resource Account Created:" -Verbose
      if ($PSBoundParameters.ContainsKey("PhoneNumber") -and $Islicensed -and $ResourceAccount.PhoneNumber -eq "") {
        Write-Warning -Message "Object replication pending, Phone Number does not show yet. Run Get-TeamsResourceAccount to verify"
      }
      return $ResourceAccountObject

    }
    catch {
      Write-Warning -Message "Object Output could not be verified. Please verify manually with Get-CsOnlineApplicationInstance"
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
    #endregion

    Write-Verbose -Message "--- DONE ----------"
  }

  end {

  }
}

function Get-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Returns Resource Accounts from AzureAD
	.DESCRIPTION
		Returns one or more Resource Accounts based on input.
		This runs Get-CsOnlineApplicationInstance but reformats the Output with friendly names
	.PARAMETER Identity
		Required. Positional. One or more UserPrincipalNames to be queried.
	.PARAMETER DisplayName
		Optional. Search parameter. Alternative to Find-TeamsResourceAccount
	.PARAMETER ApplicationType
		Optional. Returns all Call Queues or AutoAttendants
	.PARAMETER PhoneNumber
		Optional. Returns all ResourceAccount with a specific string in the PhoneNumber
	.EXAMPLE
		Get-TeamsResourceAccount
		Returns all Resource Accounts.
		NOTE: Depending on size of the Tenant, this might take a while.
	.EXAMPLE
		Get-TeamsResourceAccount -Identity ResourceAccount@TenantName.onmicrosoft.com
		Returns the Resource Account with the Identity specified, if found.
	.EXAMPLE
		Get-TeamsResourceAccount -DisplayName "Queue"
		Returns all Resource Accounts with "Queue" as part of their Display Name.
		Use Find-TeamsResourceAccount / Find-CsOnlineApplicationInstance for finer search
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
		Find-TeamsResourceAccount
		Set-TeamsResourceAccount
		Remove-TeamsResourceAccount
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(DefaultParameterSetName = "Identity")]
  param (
    [Parameter(ParameterSetName = "Identity", Position = 0, ValueFromPipelineByPropertyName = $true, HelpMessage = "User Principal Name of the Object.")]
    [Alias("UPN", "UserPrincipalName")]
    [string[]]$Identity,

    [Parameter(ParameterSetName = "DisplayName", Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Searches for AzureAD Object with this Name")]
    [ValidateLength(3, 255)]
    [string]$DisplayName,

    [Parameter(ParameterSetName = "AppType", HelpMessage = "Limits search to specific Types: CallQueue or AutoAttendant")]
    [ValidateSet("CallQueue", "AutoAttendant", "CQ", "AA")]
    [Alias("Type")]
    [string]$ApplicationType,

    [Parameter(ParameterSetName = "Number", ValueFromPipelineByPropertyName = $true, HelpMessage = "Telephone Number of the Object")]
    [ValidateLength(3, 16)]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

  } # end of begin

  process {
    $ResourceAccounts = $null

    #region Data gathering
    if ($PSBoundParameters.ContainsKey('Identity')) {
      # Default Parameterset
      [System.Collections.ArrayList]$ResourceAccounts = @()
      foreach ($I in $Identity) {
        Write-Verbose -Message "Identity - Searching for Accounts with UserPrincipalName '$I'"
        try {
          $RA = Get-CsOnlineApplicationInstance -Identity $I -ErrorAction Stop
          [void]$ResourceAccounts.Add($RA)
        }
        catch {
          Write-Verbose -Message "Not found: '$I'" -Verbose
        }
      }
    }
    elseif ($PSBoundParameters.ContainsKey('DisplayName')) {
      # Minimum Character length is 3
      Write-Verbose -Message "DisplayName - Searching for Accounts with DisplayName '$DisplayName'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property DisplayName -Like -Value "*$DisplayName*"
    }
    elseif ($PSBoundParameters.ContainsKey('ApplicationType')) {
      Write-Verbose -Message "ApplicationType - Searching for Accounts with ApplicationType '$ApplicationType'"
      $AppId = GetAppIdfromApplicationType $ApplicationType
      $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property ApplicationId -EQ -Value $AppId
    }
    elseif ($PSBoundParameters.ContainsKey('PhoneNumber')) {
      Write-Verbose -Message "PhoneNumber - Searching for PhoneNumber '$PhoneNumber'"
      $ResourceAccounts = Get-CsOnlineApplicationInstance | Where-Object -Property PhoneNumber -Like -Value "*$PhoneNumber*"

      # Loading all Microsoft Telephone Numbers
      Write-Verbose -Message "Gathering Phone Numbers from the Tenant"
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
    }
    else {
      Write-Verbose -Message "Identity - Listing all Resource Accounts" -Verbose
      $ResourceAccounts = Get-CsOnlineApplicationInstance
    }

    # Stop script if no data has been determined
    if ($ResourceAccounts.Count -eq 0) {
      Write-Verbose -Message "No Data found."
      return
    }

    #endregion


    #region Output
    # Creating new PS Object
    try {
      [System.Collections.ArrayList]$AllAccounts = @()
      Write-Verbose -Message "Parsing Resource Accounts, please wait..."
      foreach ($ResourceAccount in $ResourceAccounts) {
        # readable Application type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: ApplicationType"
        if ($PSBoundParameters.ContainsKey('ApplicationType')) {
          $ResourceAccountApplicationType = $ApplicationType
        }
        else {
          $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId
        }

        # Resource Account License
        # License
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: License"
        if (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV) {
          $ResourceAccuntLicense = "PhoneSystem (Add-on)"
        }
        elseif (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV_VIRTUALUSER) {
          $ResourceAccuntLicense = "PhoneSystem_VirtualUser"
        }
        else {
          $ResourceAccuntLicense = $null
        }

        # Phone Number Type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: PhoneNumber"
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

        # Usage Location from Object
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Usage Location"
        $UsageLocation = (Get-AzureADUser -ObjectId "$($ResourceAccount.UserPrincipalName)").UsageLocation

        # Associations
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Association"
        try {
          $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $ResourceAccount.ObjectId -ErrorAction SilentlyContinue
          $AssocObject = switch ($Association.ConfigurationType) {
            "CallQueue" { Get-CsCallQueue -Identity $Association.ConfigurationId }
            "AutoAttendant" { Get-CsAutoAttendant -Identity $Association.ConfigurationId }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $ResourceAccount.ObjectId -ErrorAction SilentlyContinue
        }
        catch {
          $AssocObject	= $null
        }

        # creating new PS Object (synchronous with Get and Set)
        $ResourceAccountObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $ResourceAccount.UserPrincipalName
          DisplayName       = $ResourceAccount.DisplayName
          UsageLocation     = $UsageLocation
          ApplicationType   = $ResourceAccountApplicationType
          License           = $ResourceAccuntLicense
          PhoneNumberType   = $ResourceAccountPhoneNumberType
          PhoneNumber       = $ResourceAccount.PhoneNumber
          AssociatedTo      = $AssocObject.Name
          AssociatedAs      = $Association.ConfigurationType
          AssocationStatus  = $AssociationStatus.Status
        }

        [void]$AllAccounts.Add($ResourceAccountObject)
      }
      return $AllAccounts

    }
    catch {
      Write-Warning -Message "Object Output could not be determined. Please verify manually with Get-CsOnlineApplicationInstance"
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
    #endregion
  }

  end {

  }
}

#Add Association filter -AssociatedOnly, -UnassociatedOnly - use Find-CsOnlineApplicationInstance to do that
function Find-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Finds Resource Accounts from AzureAD
	.DESCRIPTION
		Returns Resource Accounts based on input (Search String).
		This runs Find-CsOnlineApplicationInstance but reformats the Output with friendly names
	.PARAMETER SearchQuery
		Required. Positional. Part of the DisplayName of the Account.
	.PARAMETER AssociatedOnly
		Optional. Considers only associated Resource Accounts
	.PARAMETER UnAssociatedOnly
		Optional. Considers only unassociated Resource Accounts
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office"
		Returns all Resource Accounts with "Office" as part of their DisplayName
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office" -AssiciatedOnly
		Returns all associated Resource Accounts with "Office" as part of their DisplayName
	.EXAMPLE
		Find-TeamsResourceAccount -SearchQuery "Office" -UnassiciatedOnly
		Returns all unassociated Resource Accounts with "Office" as part of their DisplayName
	.NOTES
		CmdLet currently in testing.
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Returns one or more Resource Accounts
	.LINK
		New-TeamsResourceAccount
		Get-TeamsResourceAccount
		Set-TeamsResourceAccount
		Remove-TeamsResourceAccount
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(DefaultParameterSetName = "Search")]
  [OutputType([System.Object[]])]
  param (
    [Parameter(Mandatory, Position = 0, ParameterSetName = "Search", HelpMessage = "Part of the DisplayName to be found")]
    [Parameter(Mandatory, Position = 0, ParameterSetName = "AssociatedOnly", HelpMessage = "Part of the DisplayName to be found")]
    [Parameter(Mandatory, Position = 0, ParameterSetName = "UnAssociatedOnly", HelpMessage = "Part of the DisplayName to be found")]
    [ValidateLength(3, 255)]
    [string]$SearchQuery,

    [Parameter(Mandatory, Position = 1, ParameterSetName = "AssociatedOnly", HelpMessage = "Returns only Objects assigned to CQ or AA")]
    [Alias("Assigned", "InUse")]
    [switch]$AssociatedOnly,

    [Parameter(Mandatory, Position = 1, ParameterSetName = "UnAssociatedOnly", HelpMessage = "Returns only Objects not assigned to CQ or AA")]
    [Alias("Unassigned", "Free")]
    [switch]$UnAssociatedOnly
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

  } # end of begin

  process {
    $FoundResourceAccounts = $null
    $ResourceAccounts = $null

    #region Data gathering
    if ($PSBoundParameters.ContainsKey('AssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for ASSOCIATED Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -AssociatedOnly
    }
    elseif ($PSBoundParameters.ContainsKey('UnAssociatedOnly')) {
      Write-Verbose -Message "SearchQuery - Searching for UNASSOCIATED Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery" -UnAssociatedOnly
    }
    else {
      Write-Verbose -Message "SearchQuery - Searching for Accounts containing '$SearchQuery'" -Verbose
      $FoundResourceAccounts = Find-CsOnlineApplicationInstance -SearchQuery "$SearchQuery"
    }

    if ($null -ne $FoundResourceAccounts) {
      # Querying found Accounts against Get-CsOnlineApplicationInstance
      Write-Verbose -Message "Found Resource Accounts. Performing lookup. Please wait..." -Verbose
      [System.Collections.ArrayList]$ResourceAccounts = @()
      foreach ($I in $FoundResourceAccounts) {
        Write-Verbose -Message "Querying Account '$($I.Id)'"
        try {
          $RA = Get-CsOnlineApplicationInstance -Identity $I.Id -ErrorAction Stop
          [void]$ResourceAccounts.Add($RA)
        }
        catch {
          Write-ErrorRecord $_
        }
      }
    }
    else {
      # Stop script if no data has been determined
      Write-Verbose -Message "No Data found."
      return
    }
    #endregion


    #region Output
    # Creating new PS Object
    try {
      [System.Collections.ArrayList]$AllAccounts = @()
      Write-Verbose -Message "Parsing Resource Accounts, please wait..." -Verbose
      foreach ($ResourceAccount in $ResourceAccounts) {
        # readable Application type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: ApplicationType"
        $ResourceAccountApplicationType = GetApplicationTypeFromAppId $ResourceAccount.ApplicationId

        # Resource Account License
        # License
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: License"
        if (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV) {
          $ResourceAccuntLicense = "PhoneSystem (Add-on)"
        }
        elseif (Test-TeamsUserLicense -Identity $ResourceAccount.UserPrincipalName -ServicePlan MCOEV_VIRTUALUSER) {
          $ResourceAccuntLicense = "PhoneSystem_VirtualUser"
        }
        else {
          $ResourceAccuntLicense = $null
        }

        # Phone Number Type
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: PhoneNumber"
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

        # Usage Location from Object
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Usage Location"
        $UsageLocation = (Get-AzureADUser -ObjectId "$($ResourceAccount.UserPrincipalName)").UsageLocation

        # Associations
        Write-Verbose -Message "'$($ResourceAccount.DisplayName)' Parsing: Association"
        try {
          $Association = Get-CsOnlineApplicationInstanceAssociation -Identity $ResourceAccount.ObjectId -ErrorAction SilentlyContinue
          $AssocObject = switch ($Association.ConfigurationType) {
            "CallQueue" { Get-CsCallQueue -Identity $Association.ConfigurationId -ErrorAction SilentlyContinue }
            "AutoAttendant" { Get-CsAutoAttendant -Identity $Association.ConfigurationId -ErrorAction SilentlyContinue }
          }
          $AssociationStatus = Get-CsOnlineApplicationInstanceAssociationStatus -Identity $ResourceAccount.ObjectId -ErrorAction SilentlyContinue
        }
        catch {
          $AssocObject	= $null
        }

        # creating new PS Object (synchronous with Get and Set)
        $ResourceAccountObject = [PSCustomObject][ordered]@{
          UserPrincipalName = $ResourceAccount.UserPrincipalName
          DisplayName       = $ResourceAccount.DisplayName
          UsageLocation     = $UsageLocation
          ApplicationType   = $ResourceAccountApplicationType
          License           = $ResourceAccuntLicense
          PhoneNumberType   = $ResourceAccountPhoneNumberType
          PhoneNumber       = $ResourceAccount.PhoneNumber
          AssociatedTo      = $AssocObject.Name
          AssociatedAs      = $Association.ConfigurationType
          AssocationStatus  = $AssociationStatus.Status
        }

        [void]$AllAccounts.Add($ResourceAccountObject)
      }
      return $AllAccounts

    }
    catch {
      Write-Warning -Message "Object Output could not be determined. Please verify manually with Get-CsOnlineApplicationInstance"
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
    }
    #endregion
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
		This Function was designed to service the ApplicationInstance in AD,
		the corresponding AzureAD User and its license and enable use of a phone number, all with one Command.
	.PARAMETER UserPrincipalName
		Required. Identifies the Object being changed
	.PARAMETER DisplayName
		Optional. The Name it will show up as in Teams. Invalid characters are stripped from the provided string
	.PARAMETER ApplicationType
		CallQueue or AutoAttendant. Determines the association the account can have:
		A resource Account of the type "CallQueue" can only be associated with to a Call Queue
		A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
		NOTE: Though switching the account type is possible, this is currently untested: Handle with Care!
	.PARAMETER UsageLocation
		Two Digit Country Code of the Location of the entity. Should correspond to the Phone Number.
		Before a License can be assigned, the account needs a Usage Location populated.
	.PARAMETER License
		Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
		If not provided, will default to PhoneSystem_VirtualUser
		Unlicensed Objects can exist, but cannot be assigned a phone number
		If a license already exists, it will try to swap the license to the specified one.
		NOTE: PhoneSystem is an add-on license and cannot be assigned on its own. it has therefore been deactivated for now.
	.PARAMETER PhoneNumber
		Changes the Phone Number of the object.
		Can either be a Microsoft Number or a Direct Routing Number.
		Requires the Resource Account to be licensed correctly
		Required format is E.164, starting with a '+' and 10-15 digits long.
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName ResourceAccount@TenantName.onmicrosoft.com -Displayname "My {ResourceAccount}"
		Will normalise the Display Name (i.E. remove special characters), then set it as "My ResourceAccount"
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -UsageLocation US
		Sets the UsageLocation for the Account in AzureAD to US.
	.EXAMPLE
		Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -License PhoneSystem_VirtualUser
		Requires the Account to have a UsageLocation populated. Applies the License to Resource Account AA-Mainline.
		If no license is assigned, will try to assign. If the license is already applied, no action is taken.
		NOTE: Swapping licenses is currently not possible.
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
		Find-TeamsResourceAccount
		Remove-TeamsResourceAccount
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to change")]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
          $false
        }
      })]
    [Alias("Identity")]
    [string]$UserPrincipalName,

    [Parameter(HelpMessage = "Display Name is shown in Teams")]
    [string]$DisplayName,

    [Parameter(HelpMessage = "CallQueue or AutoAttendant")]
    [ValidateSet("CallQueue", "AutoAttendant", "CQ", "AA")]
    [Alias("Type")]
    [string]$ApplicationType,

    [Parameter(HelpMessage = "Usage Location to assign")]
    [string]$UsageLocation,

    [Parameter(HelpMessage = "License to be assigned")]
    #[ValidateSet("PhoneSystem","PhoneSystem_VirtualUser")]
    [ValidateSet("PhoneSystem_VirtualUser")]
    [string]$License = "PhoneSystem_VirtualUser",

    [Parameter(HelpMessage = "Telephone Number to assign")]
    [Alias("Tel", "Number", "TelephoneNumber")]
    [string]$PhoneNumber
  )

  begin {
    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Setting Preference Variables according to Upstream settings
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }

  } # end of begin

  process {
    #region PREPARATION
    Write-Verbose -Message "--- PREPARATION ---"
    #region Lookup of UserPrincipalName
    try {
      #Trying to query the Resource Account
      $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -ErrorAction STOP)
      $CurrentDisplayName = $Object.DisplayName
      Write-Verbose -Message "'$UserPrincipalName' OnlineApplicationInstance found: '$CurrentDisplayName'"
    }
    catch {
      # Catching anything
      Write-Error -Message "'$UserPrincipalName' OnlineApplicationInstance not found!" -Category ObjectNotFound -RecommendedAction "Please provide a valid UserPrincipalName of an existing Resource Account"
      break
    }
    #endregion

    #region Normalising $DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      $DisplayNameNormalised = Format-StringForUse -InputString $DisplayName -As DisplayName
      $Name = $DisplayNameNormalised
      Write-Verbose -Message "DisplayName normalised to: '$Name'"
    }
    else {
      $Name = $CurrentDisplayName
    }
    #endregion

    #region ApplicationType and Associations
    if ($PSBoundParameters.ContainsKey("ApplicationType")) {
      # Translating $ApplicationType (Name) to ID used by Commands.
      $AppId = GetAppIdfromApplicationType $ApplicationType
      $CurrentAppId = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).ApplicationId
      # Does the ApplicationType differ? Does it have to be changed?
      if ($AppId -eq $CurrentAppId) {
        # Application IDs match - Type does not need to be changed
        Write-Verbose -Message "'$Name' Application Type already set to: $ApplicationType"
      }
      else {
        # Finding all Associations to of this Resource Account to Call Queues or Auto Attendants
        $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -ErrorAction Ignore
        if ($Associations.count -gt 0) {
          # Associations found. Aborting
          Write-Error -Message "'$Name' ApplicationType cannot be changed! Object is associated with Call Queue or AutoAttendant." -Category OperationStopped -RecommendedAction "Remove Associations with Remove-CsOnlineApplicationInstanceAssociation manually"
          break
        }
        else {
          Write-Verbose -Message "'$Name' Application Type will be changed to: $ApplicationType"
        }
      }
    }
    #endregion

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Loading all Microsoft Telephone Numbers
      $MSTelephoneNumbers = Get-CsOnlineTelephoneNumber -WarningAction SilentlyContinue
      $PhoneNumberIsMSNumber = ($PhoneNumber -in $MSTelephoneNumbers)
    }
    try {
      $CurrentPhoneNumber = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).PhoneNumber.Replace('tel:', '')
      Write-Verbose -Message "'$Name' Phone Number assigned currently: $CurrentPhoneNumber"
    }
    catch {
      $CurrentPhoneNumber = $null
      Write-Verbose -Message "'$Name' Phone Number assigned currently: NONE"
    }
    #endregion

    #region UsageLocation
    $CurrentUsageLocation = (Get-AzureADUser -ObjectId "$UserPrincipalName").UsageLocation
    if ($PSBoundParameters.ContainsKey('UsageLocation')) {
      if ($Usagelocation -eq $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location already set to: $CurrentUsageLocation"
      }
      elseif ($null -eq $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location not set! Will be set to: $Usagelocation"
      }
    }
    else {
      if ($null -ne $CurrentUsageLocation) {
        Write-Verbose -Message "'$Name' Usage Location currently set to: $CurrentUsageLocation"
      }
      else {
        if (($PSBoundParameters.ContainsKey('License')) -or ($PSBoundParameters.ContainsKey('PhoneNumber'))) {
          Write-Error -Message "'$Name' Usage Location not set!" -Category ObjectNotFound -RecommendedAction "Please run command again and specify -UsageLocation"
          break
        }
        else {
          Write-Warning -Message "'$Name' Usage Location not set! This is a requirement for License assignment and Phone Number"
        }
      }
    }
    #endregion

    #region Current License
    if ($PSBoundParameters.ContainsKey("License") -or $PSBoundParameters.ContainsKey("PhoneNumber")) {
      $CurrentLicense = $null
      # Determining license Status of Object
      if (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan MCOEV) {
        $CurrentLicense = "PhoneSystem"
      }
      elseif (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan MCOEV_VIRTUALUSER) {
        $CurrentLicense = "PhoneSystem_VirtualUser"
      }
      if ($null -ne $CurrentLicense) {
        Write-Verbose -Message "'$Name' Current License assigned: $CurrentLicense"
      }
      else {
        Write-Verbose -Message "'$Name' Current License assigned: NONE"
      }
    }
    #endregion
    #endregion


    #region ACTION
    Write-Verbose -Message "--- ACTIONS -------"
    #region DisplayName
    if ($PSBoundParameters.ContainsKey("DisplayName")) {
      try {
        if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -Displayname `"$DisplayNameNormalised`"")) {
          Write-Verbose -Message "'$CurrentDisplayName' Changing DisplayName to: $DisplayNameNormalised"
          $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -Displayname "$DisplayNameNormalised" -ErrorAction STOP)
          Write-Verbose -Message "SUCCESS"
          $Object = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName -ErrorAction STOP)
          $CurrentDisplayName = $Object.DisplayName
        }
      }
      catch {
        Write-Verbose -Message "FAILED - Error encountered changing DisplayName"
        Write-Error -Message "Problem encountered with changing DisplayName" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
        Write-ErrorRecord $_ #This handles the eror message in human readable format.
      }
    }
    #endregion

    #region Application Type
    if ($PSBoundParameters.ContainsKey("ApplicationType")) {
      $CurrentAppId = (Get-CsOnlineApplicationInstance -Identity $UserPrincipalName).ApplicationId
      # Application Type Change?
      if ($AppId -ne $CurrentAppId) {
        try {
          if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -ApplicationId $AppId")) {
            Write-Verbose -Message "'$Name' Setting Application Type to: $ApplicationType"
            $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -ApplicationId $AppId -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS"
          }
        }
        catch {
          Write-Error -Message "Problem encountered changing Application Type" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-CsOnlineApplicationInstance"
          Write-ErrorRecord $_ #This handles the eror message in human readable format.
        }
      }
    }
    #endregion

    #region UsageLocation
    if ($PSBoundParameters.ContainsKey("UsageLocation")) {
      if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-AzureADUser -UsageLocation $UsageLocation")) {
        try {
          Set-AzureADUser -ObjectId $UserPrincipalName -UsageLocation $UsageLocation -ErrorAction STOP
          Write-Verbose -Message "'$Name' SUCCESS - Usage Location set to: $UsageLocation"
        }
        catch {
          if ($PSBoundParameters.ContainsKey("License")) {
            Write-Error -Message "'$Name' Usage Location could not be set." -Category NotSpecified -RecommendedAction "Apply manually, then run Set-TeamsResourceAccount to apply license and phone number"
          }
          else {
            Write-Warning -Message "'$Name' Usage Location cannot be set. If a license is needed, please assign UsageLocation manually before assigning a license"
          }
        }
      }
    }
    #endregion

    #region Licensing
    if ($PSBoundParameters.ContainsKey("License")) {
      # Verifying License is available to be assigned
      # Determining available Licenses from Tenant
      Write-Verbose -Message "'$Name' Querying Licenses..."
      $TenantLicenses = Get-TeamsTenantLicense
      $RemainingPSlicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "MCOEV" }).Remaining
      Write-Verbose -Message "INFO: $RemainingPSlicenses remaining Phone System Licenses"
      $RemainingPSVUlicenses = ($TenantLicenses | Where-Object { $_.SkuPartNumber -eq "PHONESYSTEM_VIRTUALUSER" }).Remaining
      Write-Verbose -Message "INFO: $RemainingPSVUlicenses remaining Phone System Virtual User Licenses"

      # Changing License if requried
      if ($License -eq $CurrentLicense) {
        # No action required
        Write-Verbose -Message "'$Name' License '$License' already assigned."
        $Islicensed = $true
      }
      else {
        # Switching dependent on input
        switch ($License) {
          "PhoneSystem" {
            $ServicePlanName = "MCOEV"
            # PhoneSystem is currently disabled
            # It would require an E1/E3 license in addition OR a full E5 license
            # Deliberations and confirmation needed.

            Write-Verbose -Message "Testing whether PhoneSystem License is available"
            $RemainingPSlicenses = ($TenantLicenses | Where-Object { $_.License -eq "Phone System Add-On" }).Remaining
            if ($RemainingPSlicenses -lt 1) {
              Write-Error -Message "ERROR: No free PhoneSystem License remaining in the Tenant!"
            }
            else {
              Write-Verbose -Message "SUCCESS - Phone System License found available"
              try {
                if ($null -eq $CurrentLicense) {
                  if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Add-TeamsUserLicense -AddPhoneSystem")) {
                    Write-Verbose -Message "'$Name' Assigning new License: '$License'"
                    Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystem -ErrorAction STOP
                    Write-Verbose -Message "SUCCESS"
                  }
                }
                else {
                  if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Add-TeamsUserLicense -AddPhoneSystem -Replace")) {
                    Write-Verbose -Message "'$Name' Changing License from '$CurrentLicense' to '$License'"
                    #This will fail - currently blocked in Add-TeamsUserLicense
                    Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystem -Replace -ErrorAction STOP
                    Write-Verbose -Message "SUCCESS"
                  }
                }
                Write-Verbose -Message "SUCCESS - PhoneSystem License assigned"
                $Islicensed = $true
              }
              catch {
                Write-Error -Message "License assignment failed"
                $Islicensed = $false
                Write-ErrorRecord $_ #This handles the eror message in human readable format.
              }
            }
          }
          "PhoneSystem_VirtualUser" {
            $ServicePlanName = "MCOEV_VIRTUALUSER"
            Write-Verbose -Message "Testing whether PhoneSystem Virtual User License is available"
            $RemainingPSVUlicenses = ($TenantLicenses | Where-Object { $_.License -eq "Phone System - Virtual User" }).Remaining
            if ($RemainingPSVUlicenses -lt 1) {
              Write-Error -Message "ERROR: No free PhoneSystem Virtual User License remaining in the Tenant!"
            }
            else {
              Write-Verbose -Message "SUCCESS - Phone System Virtual User License found available"
              try {
                if ($null -eq $CurrentLicense) {
                  if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Add-TeamsUserLicense -AddPhoneSystemVirtualUser")) {
                    Write-Verbose -Message "'$Name' Assigning new License: '$License'"
                    Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystemVirtualUser -ErrorAction STOP
                    Write-Verbose -Message "SUCCESS"
                  }
                }
                else {
                  if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Add-TeamsUserLicense -AddPhoneSystemVirtualUser -Replace")) {
                    Write-Verbose -Message "'$Name' Changing License from '$CurrentLicense' to '$License'"
                    Add-TeamsUserLicense -Identity $UserPrincipalName -AddPhoneSystemVirtualUser -Replace -ErrorAction STOP
                    Write-Verbose -Message "SUCCESS"
                  }
                }
                Write-Verbose -Message "SUCCESS - PhoneSystem Virtual User License assigned"
                $Islicensed = $true
              }
              catch {
                Write-Error -Message "License assignment failed"
                $Islicensed = $false
                Write-ErrorRecord $_ #This handles the eror message in human readable format.
              }
            }
          }
        }
      }
    }
    #endregion

    #region Waiting for License Application
    if ($PSBoundParameters.ContainsKey("License") -and $PSBoundParameters.ContainsKey("PhoneNumber")) {
      $i = 0
      $imax = 300
      Write-Warning -Message "Applying a License may take longer than provisioned for ($($imax/60) mins) in this Script - If so, please apply PhoneNumber manually with Set-TeamsResourceAccount"
      Write-Verbose -Message "Waiting for Get-AzureAdUserLicenseDetail to return a Result..."
      while (-not (Test-TeamsUserLicense -Identity $UserPrincipalName -ServicePlan $ServicePlanName)) {
        if ($i -gt $imax) {
          Write-Error -Message "Could not find Successful Provisioning Status of the License '$ServicePlanName' in AzureAD in the last $imax Seconds" -Category LimitsExceeded -RecommendedAction "Please verify License has been applied correctly (Get-TeamsResourceAccount); Continue with Set-TeamsResourceAccount"
          break
        }
        Write-Progress -Activity "'$Name' Azure Active Directory is applying License. Please wait" `
          -PercentComplete (($i * 100) / $imax) `
          -Status "$(([math]::Round((($i)/$imax * 100),0))) %"

        Start-Sleep -Milliseconds 1000
        $i++
      }
    }
    #endregion

    #region PhoneNumber
    if ($PSBoundParameters.ContainsKey("PhoneNumber")) {
      # Assigning Telephone Number
      Write-Verbose -Message "'$Name' ACTION: Assigning Phone Number"
      if ($CurrentPhoneNumber -ne $PhoneNumber) {
        if ($null -eq $CurrentLicense -and -not $Islicensed) {
          Write-Error -Message "A Phone Number can only be assigned to licensed objects." -Category ResourceUnavailable -RecommendedAction "Please apply a license before assigning the number. Set-TeamsResourceAccount can be used to do both"
        }
        else {
          # Removing old Number
          try {
            # Remove from VoiceApplicationInstance
            Write-Verbose -Message "'$Name' Removing Microsoft Number"
            $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS"
            # Remove from ApplicationInstance
            Write-Verbose -Message "'$Name' Removing Direct Routing Number"
            $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS"
          }
          catch {
            Write-Error -Message "Unassignment of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
            Write-ErrorRecord $_ #This handles the eror message in human readable format.
          }
          # Assigning new Number
          # Processing paths for Telephone Numbers depending on Type
          if ($PhoneNumberIsMSNumber) {
            # Set in VoiceApplicationInstance
            try {
              if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineVoiceApplicationInstance -Telephonenumber $PhoneNumber")) {
                Write-Verbose -Message "'$Name' Number '$PhoneNumber' found in Tenant, assuming provisioning Microsoft for: Microsoft Calling Plans"
                $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $PhoneNumber -ErrorAction STOP)
                Write-Verbose -Message "SUCCESS"
              }
            }
            catch {
              Write-Error -Message "'$Name' Number '$PhoneNumber' not assigned!" -Category NotImplemented -RecommendedAction "Please run Set-TeamsResourceAccount manually"
              Write-ErrorRecord $_ #This handles the eror message in human readable format.
            }
          }
          else {
            # Set in ApplicationInstance
            try {
              if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set-CsOnlineApplicationInstance -OnPremPhoneNumber $PhoneNumber")) {
                Write-Verbose -Message "'$Name' Number '$PhoneNumber' not found in Tenant, assuming provisioning for: Direct Routing"
                $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $PhoneNumber -ErrorAction STOP)
                Write-Verbose -Message "SUCCESS"
              }
            }
            catch {
              Write-Error -Message "'$Name' Number '$PhoneNumber' not assigned!" -Category NotImplemented -RecommendedAction "Please run Set-TeamsResourceAccount manually"
              Write-ErrorRecord $_ #This handles the eror message in human readable format.
            }
          }
        }
      }
    }
    #endregion

    Write-Verbose -Message "--- DONE ----------"
    #endregion
  }

  end {

  }
}

function Remove-TeamsResourceAccount {
  <#
	.SYNOPSIS
		Removes a Resource Account from AzureAD
	.DESCRIPTION
		This function allows you to remove Resource Accounts (Application Instances) from AzureAD
	.PARAMETER UserPrincipalName
		Required. Identifies the Object being changed
	.PARAMETER Force
		Optional. Will also sever all associations this account has in order to remove it
		If not provided and the Account is connected to a Call Queue or Auto Attendant, an error will be displayed
	.EXAMPLE
		Remove-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com"
		Removes a ResourceAccount
		Removes in order: Phone Number, License and Account
	.EXAMPLE
		Remove-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com" -Force
		Removes a ResourceAccount
		Removes in order: Association, Phone Number, License and Account
	.NOTES
		CmdLet currently in testing.
		Execution requires User Admin Role in Azure AD
		Please feed back any issues to david.eberhardt@outlook.com
	.FUNCTIONALITY
		Removes a resource Account in AzureAD for use in Teams
	.LINK
		New-TeamsResourceAccount
		Get-TeamsResourceAccount
		Find-TeamsResourceAccount
		Set-TeamsResourceAccount
		Connect-ResourceAccount
		Disconnect-ResourceAccount
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "UPN of the Object to create.")]
    [ValidateScript( {
        If ($_ -match '@') {
          $True
        }
        else {
          Write-Host "Must be a valid UPN" -ForeGroundColor Red
          $false
        }
      })]
    [Alias("Identity", "ObjectId")]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [switch]$Force
  )

  begin {
    # Caveat - Access rights
    Write-Verbose -Message "This Script requires the executor to have access to AzureAD and rights to execute Remove-AzureAdUser" -Verbose
    Write-Verbose -Message "No verficication of required admin roles is performed. Use Get-AzureAdAssignedAdminRoles to determine roles for your account"

    # Testing AzureAD Connection
    if (Test-AzureADConnection) {
      Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
    }
    else {
      Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }

    # Testing SkypeOnline Connection
    if (Test-SkypeOnlineConnection) {
      Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
    }
    else {
      if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
        Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
        $null = Get-CsTenant
      }
      else {
        Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
        Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
        break
      }
    }

    # Enabling $Confirm to work with $Force
    if ($Force -and -not $Confirm) {
      $ConfirmPreference = 'None'
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
    Write-Verbose -Message "Processing: '$DisplayName' Associations to Call Queues or Auto Attendants"
    $Associations = Get-CsOnlineApplicationInstanceAssociation -Identity $UserPrincipalName -ErrorAction Ignore
    if ($Associations.count -eq 0) {
      # Object has no associations
      Write-Verbose -Message "'$DisplayName' Object does not have any associaions"
      $Associations = $null
    }
    else {
      Write-Verbose -Message "'$DisplayName' associaions found"
      if ($PSBoundParameters.ContainsKey("Force")) {
        # Removing all Associations to of this Resource Account to Call Queues or Auto Attendants
        # with: Remove-CsOnlineApplicationInstanceAssociation
        if ($PSCmdlet.ShouldProcess("Resource Account Associations ($($Associations.Count))", 'Remove-CsOnlineApplicationInstanceAssociation')) {
          try {
            Write-Verbose -Message "Trying to remove the Associations of this Resource Account"
            $null = (Remove-CsOnlineApplicationInstanceAssociation $Associations  -ErrorAction STOP)
            Write-Verbose -Message "SUCCESS: Associations removed"
          }
          catch {
            Write-Error -Message "Associations could not be removed! Please check manually with Remove-CsOnlineApplicationInstanceAssociation" -Category InvalidOperation
            Write-ErrorRecord $_ #This handles the eror message in human readable format.
            return
          }
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
    Write-Verbose -Message "Processing: '$DisplayName' Phone Number Assignments"
    try {
      # Remove from VoiceApplicationInstance
      Write-Verbose -Message "'$DisplayName' Removing Microsoft Number"
      $null = (Set-CsOnlineVoiceApplicationInstance -Identity $UserPrincipalName -Telephonenumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
      # Remove from ApplicationInstance
      Write-Verbose -Message "'$DisplayName' Removing Direct Routing Number"
      $null = (Set-CsOnlineApplicationInstance -Identity $UserPrincipalName -OnPremPhoneNumber $null -WarningAction SilentlyContinue -ErrorAction STOP)
    }
    catch {
      Write-Error -Message "Unassignment of Number failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
      return
    }
    #endregion

    #region Licensing
    # Reading User Licenses
    Write-Verbose -Message "Processing: '$DisplayName' Phone Number Assignments"
    try {
      $UserLicenseSkuIDs = (Get-AzureADUserLicenseDetail -ObjectId $UserPrincipalName -ErrorAction STOP).SkuId

      if ($null -eq $UserLicenseSkuIDs) {
        Write-Verbose -Message "'$DisplayName' No licenses assigned. OK"
      }
      else {
        $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        # This should work:
        Write-Verbose -Message "'$DisplayName' Removing Removing licenses"
        $Licenses.RemoveLicenses = @($UserLicenseSkuIDs)
        Set-AzureADUserLicense -ObjectId $Object.ObjectId -AssignedLicenses $Licenses -ErrorAction STOP
        Write-Verbose -Message "SUCCESS"
      }
    }
    catch {
      Write-Error -Message "Unassignment of Licenses failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Set-AzureADUserLicense"
      Write-ErrorRecord $_ #This handles the eror message in human readable format.
      return
    }

    #endregion

    #region Account Removal
    # Removing AzureAD User
    Write-Verbose -Message "Processing: '$DisplayName' Removing AzureAD User Object"
    if ($PSCmdlet.ShouldProcess("Resource Account with DisplayName: '$DisplayName'", 'Remove-AzureADUser')) {
      try {
        $null = (Remove-AzureADUser -ObjectID $UserPrincipalName -ErrorAction STOP)
        Write-Verbose -Message "SUCCESS - Object removed from Azure Active Directory"
      }
      catch {
        Write-Error -Message "Removal failed" -Category NotImplemented -Exception $_.Exception -RecommendedAction "Try manually with Remove-AzureAdUser"
        Write-ErrorRecord $_ #This handles the eror message in human readable format.
      }
    }
    else {
      Write-Verbose -Message "SKIPPED - Object removed not confirmed Azure Active Directory"
    }



    #endregion

  }

  end {

  }
}
#Alias is set to provide default behaviour to CsOnlineApplicationInstance
Set-Alias -Name Remove-CsOnlineApplicationInstance -Value Remove-TeamsResourceAccount


# Function untested, but prepared for later. Used in New-TeamsCallQueue and Set-TeamsCallQueue
function Import-TeamsAudioFile {
  <#
	.SYNOPSIS
		Imports an AudioFile for CallQueues or AutoAttendants
	.DESCRIPTION
		Imports an AudioFile for CallQueues or AutoAttendants with Import-CsOnlineAudioFile
	.PARAMETER File
		File to be imported
	.PARAMETER ApplicationType
		ApplicationType of the entity it is for
	.NOTES
		This is currently in development.
		Not tested yet. Will replace some code in New/Set-TeamsResourceAccount
	.FUNCTIONALITY
		Imports an AudioFile for CallQueues or AutoAttendants with Import-CsOnlineAudioFile
	#>

  [CmdletBinding()]
  #[OutputType()] # To be determined
  param(
    [Parameter(Mandatory = $true)]
    [string]$File,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CallQueue', 'AutoAttendant')]
    [string]$ApplicationType

  )

  begin {
  }

  process {
    # Testing File
    if (-not (Test-Path $File)) {
      Write-Error -Message "File not found!"
      break
    }

    $FileName = Split-Path $File -Leaf

    # remodelling ApplicationType to ApplicationId
    $ApplicationId = switch ($ApplicationType) {
      'CallQueue' { Return 'HuntGroup' }
      'AutoAttendant' { Return 'OrgAutoAttendant' }
    }

    try {
      # Importing Content
      if ($PSVersionTable.PSVersion.Major -ge 6) {
        $content = Get-Content $File -AsByteStream -ReadCount 0 -ErrorAction STOP
      }
      else {
        $content = Get-Content $File -Encoding byte -ReadCount 0 -ErrorAction STOP
      }

      # Importing file
      $AudioFile = Import-CsOnlineAudioFile -ApplicationId $ApplicationId -FileName $FileName -Content $content -ErrorAction STOP
      return $AudioFile
    }
    catch {
      Write-Host "Error importing file - Please check file size and compression ratio. If in doubt, provide WAV "
      # Writing Error Record in human readable format. Prepend with Custom message
      Write-ErrorRecord $_
      return
    }
  }

  end {
  }
}

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

  If ((Get-PSSession | Where-Object -FilterScript { $_.ComputerName -like '*.online.lync.com' }).State -eq 'Opened') {
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
      Identity              = $Dialplan.Identity
      OptimizeDeviceDialing = $Dialplan.OptimizeDeviceDialing
      Description           = $Dialplan.Description
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
        Parent              = $Dialplan.Identity
        Name                = [regex]::Match($NormRule, '(?ms)Name=(.*?);').Groups[1].Value
        Pattern             = [regex]::Match($NormRule, '(?ms)Pattern=(.*?);').Groups[1].Value
        Translation         = [regex]::Match($NormRule, '(?ms)Translation=(.*?);').Groups[1].Value
        Description         = [regex]::Match($NormRule, '(?ms)^Description=(.*?);').Groups[1].Value
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
    $null = (Set-CsOnlinePstnUsage -Identity Global -Usage @{Add = $PSTNUsage } -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)
  }

  # Rebuild voice routes from backup
  Write-Host -Object 'Restoring voice routes'

  ForEach ($VoiceRoute in $VoiceRoutes) {
    Write-Verbose -Message "Restoring $($VoiceRoute.Identity) voice route"
    $VRExists = (Get-CsOnlineVoiceRoute -Identity $VoiceRoute.Identity -ErrorAction SilentlyContinue).Identity

    $VRDetails = @{
      Identity              = $VoiceRoute.Identity
      NumberPattern         = $VoiceRoute.NumberPattern
      Priority              = $VoiceRoute.Priority
      OnlinePstnUsages      = $VoiceRoute.OnlinePstnUsages
      OnlinePstnGatewayList = $VoiceRoute.OnlinePstnGatewayList
      Description           = $VoiceRoute.Description
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
      Identity         = $VoiceRoutingPolicy.Identity
      OnlinePstnUsages = $VoiceRoutingPolicy.OnlinePstnUsages
      Description      = $VoiceRoutingPolicy.Description
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
      Identity    = $TranslationRule.Identity
      Pattern     = $TranslationRule.Pattern
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
      Identity                           = $PSTNGateway.Identity
      OutbundTeamsNumberTranslationRules = $PSTNGateway.OutbundTeamsNumberTranslationRules #Sadly Outbund isn't a spelling mistake here. That's what the command uses.
      OutboundPstnNumberTranslationRules = $PSTNGateway.OutboundPstnNumberTranslationRules
      InboundTeamsNumberTranslationRules = $PSTNGateway.InboundTeamsNumberTranslationRules
      InboundPstnNumberTranslationRules  = $PSTNGateway.InboundPstnNumberTranslationRules
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
  if (Test-SkypeOnlineConnection) {
    Write-Verbose -Message "SkypeOnline: Valid session found, reusing existing connection"
  }
  else {
    if ([bool]((Get-PSSession).Computername -match "online.lync.com")) {
      Write-Host "SkypeOnline: Session found. Reconnecting..." -ForegroundColor DarkCyan
      $null = Get-CsTenant
    }
    else {
      Write-Host "ERROR: You must call the Connect-SkypeOnline cmdlet before calling any other cmdlets." -ForegroundColor Red
      Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
      break
    }
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

  $ErrorActionP

  $CommandParams += @{'WarningAction' = 'SilentlyContinue' }
  $CommandParams += @{'ErrorAction' = 'SilentlyContinue' }

  # Tenant Configuration
  $null = (Get-CsOnlineDialInConferencingBridge @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingBridge.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingLanguagesSupported @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingLanguagesSupported.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingServiceNumber @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingServiceNumber.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialinConferencingTenantConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialinConferencingTenantConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingTenantSettings @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingTenantSettings.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineLisCivicAddress @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineLisCivicAddress.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineLisLocation @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineLisLocation.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsClientConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsClientConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestCallingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestCallingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestMeetingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestMeetingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsGuestMessagingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsGuestMessagingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingBroadcastConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingBroadcastConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsUpgradeConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsUpgradeConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenant @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTenant.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantFederationConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTenantFederationConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantNetworkConfiguration @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTenantNetworkConfiguration.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantPublicProvider @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTenantPublicProvider.txt" -Force -Encoding utf8)

  # Tenant Policies (except voice)
  $null = (Get-CsTeamsUpgradePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsUpgradePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsAppPermissionPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsAppPermissionPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsAppSetupPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsAppSetupPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsCallParkPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsCallParkPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsChannelsPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsChannelsPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsComplianceRecordingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsComplianceRecordingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEducationAssignmentsAppPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEducationAssignmentsAppPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsFeedbackPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsFeedbackPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingBroadcastPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingBroadcastPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMeetingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMeetingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMessasgingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMessagingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsMobilityPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsMobilityPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsNotificationAndFeedsPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsNotificationAndFeedsPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsTargetingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsTargetingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsVerticalPackagePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsVerticalPackagePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsVideoInteropServicePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsVideoInteropServicePolicy.txt" -Force -Encoding utf8)

  # Tenant Voice Configuration
  $null = (Get-CsTeamsTranslationRule @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsTranslationRule.txt" -Force -Encoding utf8)
  $null = (Get-CsTenantDialPlan @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTenantDialPlan.txt" -Force -Encoding utf8)

  $null = (Get-CsOnlinePSTNGateway @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlinePSTNGateway.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceRoute @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceRoute.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlinePstnUsage @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlinePstnUsage.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceRoutingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceRoutingPolicy.txt" -Force -Encoding utf8)

  # Tenant Voice related Configuration and Policies
  $null = (Get-CsTeamsIPPhonePolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsIPPhonePolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEmergencyCallingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEmergencyCallingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsEmergencyCallRoutingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsEmergencyCallRoutingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialinConferencingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialinConferencingPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoicemailPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoicemailPolicy.txt" -Force -Encoding utf8)
  $null = (Get-CsTeamsCallingPolicy @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsTeamsCallingPolicy.txt" -Force -Encoding utf8)

  # Tenant Telephone Numbers
  $null = (Get-CsOnlineTelephoneNumber @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumber.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberAvailableCount @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberAvailableCount.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberInventoryTypes @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberInventoryTypes.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineTelephoneNumberReservationsInformation @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineTelephoneNumberReservationsInformation.txt" -Force -Encoding utf8)

  # Resource Accounts, Call Queues and Auto Attendants
  $null = (Get-CsOnlineApplicationInstance @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineApplicationInstance.txt" -Force -Encoding utf8)
  $null = (Get-CsCallQueue @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsCallQueue.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendant @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendant.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantSupportedLanguage @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantSupportedLanguage.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantSupportedTimeZone @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantSupportedTimeZone.txt" -Force -Encoding utf8)
  $null = (Get-CsAutoAttendantTenantInformation @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsAutoAttendantTenantInformation.txt" -Force -Encoding utf8)

  # User Configuration
  $null = (Get-CsOnlineUser @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineVoiceUser @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineVoiceUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUser @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUser.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUserInfo @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUserInfo.txt" -Force -Encoding utf8)
  $null = (Get-CsOnlineDialInConferencingUserState @CommandParams | ConvertTo-Json | Out-File -FilePath "Get-CsOnlineDialInConferencingUserState.txt" -Force -Encoding utf8)


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
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the identity of the User to Query")]
    [Alias("UPN", "UserPrincipalName", "Username")]
    [string]$Identity
  )

  # Testing AzureAD Connection
  if (Test-AzureADConnection) {
    Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
  }
  else {
    Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }

  #Querying Admin Rights of authenticated Administator
  $AssignedRoles = @()
  $Roles = Get-AzureADDirectoryRole
  FOREACH ($R in $Roles) {
    $Members = (Get-AzureADDirectoryRoleMember -ObjectId $R.ObjectId).UserprincipalName
    IF ($Identity -in $Members) {
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
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "SkuId of the license to Add")]
    [Alias('AddSkuId')]
    [string[]]$SkuId,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "SkuId of the license to Remove")]
    [switch[]]$RemoveSkuId
  )

  if (-not $PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
  }
  if (-not $PSBoundParameters.ContainsKey('Confirm')) {
    $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
  }
  if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
    $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
  }

  # Testing AzureAD Connection
  if (Test-AzureADConnection) {
    Write-Verbose -Message "AzureAD(v2): Valid session found, reusing existing connection - Tenant: $((Get-AzureADCurrentSessionInfo).TenantDomain)"
  }
  else {
    Write-Host "ERROR: You must call the Connect-AzureAD cmdlet before calling any other cmdlets." -ForegroundColor Red
    Write-Host "INFO:  Connect-Me can be used to connect to SkypeOnline, MicrosoftTeams and AzureAD!" -ForegroundColor DarkCyan
    break
  }


  Add-Type -AssemblyName Microsoft.Open.AzureAD16.Graph.Client
  $AddLicenseObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense

  foreach ($Sku in $SkuId) {
    $AddLicenseObj.SkuId += $Sku
  }

  $newLicensesObj = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
  if ($PSCmdlet.ShouldProcess("New License Object: Microsoft.Open.AzureAD.Model.AssignedLicenses", "AddLicenses")) {
    $newLicensesObj.AddLicenses = $AddLicenseObj
  }


  if ($PSBoundParameters.ContainsKey('RemoveSkuId')) {
    foreach ($Sku in $RemoveSkuId) {
      if ($PSCmdlet.ShouldProcess("New License Object: Microsoft.Open.AzureAD.Model.AssignedLicenses", "RemoveLicenses")) {
        $newLicensesObj.RemoveLicenses += $Sku
      }
    }
  }

  return $newLicensesObj
}

# Helper functions to test and format strings
function Format-StringRemoveSpecialCharacter {
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
		Format-StringRemoveSpecialCharacter -String "^&*@wow*(&(*&@"
		wow
	.EXAMPLE
		Format-StringRemoveSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"
		wow
	.EXAMPLE
		Format-StringRemoveSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"
		wow-_*
	.NOTES
		Francois-Xavier Cat
		@lazywinadmin
		lazywinadmin.com
		github.com/lazywinadmin
	#>
  [CmdletBinding()]
  [OutputType([String])]
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

  process {
    try {
      if ($PSBoundParameters["SpecialCharacterToKeep"]) {
        $Regex = "[^\p{L}\p{Nd}"
        foreach ($Character in $SpecialCharacterToKeep) {
          if ($Character -eq "-") {
            $Regex += "-"
          }
          else {
            $Regex += [Regex]::Escape($Character)
          }
          #$Regex += "/$character"
        }

        $Regex += "]+"
      } #IF($PSBoundParameters["SpecialCharacterToKeep"])
      else { $Regex = "[^\p{L}\p{Nd}]+" }

      foreach ($Str in $string) {
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
  [OutputType([String])]
  param(
    [Parameter(Mandatory, HelpMessage = "String to reformat")]
    [string]$InputString,

    [Parameter(HelpMessage = "Replacement character or string for each removed character")]
    [string]$Replacement = "",

    [Parameter(ParameterSetName = "Specific")]
    [ValidateSet("UserPrincipalName", "DisplayName")]
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
          "DisplayName" { $CharactersToRemove = '\%*+/=?{}|<>[]"' }
        }
      }
      "Manual" { $CharactersToRemove = $SpecialChars }
      Default { }
    }
  }

  process {

    $rePattern = ($CharactersToRemove.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join "|"

    $InputString -replace $rePattern, $Replacement
  }
}

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
$TeamsLicenses.Add($TeamsLicensesEntry01)

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
$TeamsLicenses.Add($TeamsLicensesEntry02)

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
$TeamsLicenses.Add($TeamsLicensesEntry03)

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
$TeamsLicenses.Add($TeamsLicensesEntry04)

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
$TeamsLicenses.Add($TeamsLicensesEntry05)

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
$TeamsLicenses.Add($TeamsLicensesEntry06)

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
$TeamsLicenses.Add($TeamsLicensesEntry07)

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
$TeamsLicenses.Add($TeamsLicensesEntry08)

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
$TeamsLicenses.Add($TeamsLicensesEntry09)

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
$TeamsLicenses.Add($TeamsLicensesEntry10)

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
$TeamsLicenses.Add($TeamsLicensesEntry11)

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
$TeamsLicenses.Add($TeamsLicensesEntry12)

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
$TeamsLicenses.Add($TeamsLicensesEntry13)

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
$TeamsLicenses.Add($TeamsLicensesEntry14)

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
$TeamsLicenses.Add($TeamsLicensesEntry15)

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
$TeamsLicenses.Add($TeamsLicensesEntry16)

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
$TeamsLicenses.Add($TeamsLicensesEntry17)

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
$TeamsLicenses.Add($TeamsLicensesEntry18)

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
$TeamsLicenses.Add($TeamsLicensesEntry19)

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
$TeamsLicenses.Add($TeamsLicensesEntry20)

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
$TeamsLicenses.Add($TeamsLicensesEntry21)

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
$TeamsLicenses.Add($TeamsLicensesEntry22)

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
$TeamsLicenses.Add($TeamsLicensesEntry23)

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
$TeamsLicenses.Add($TeamsLicensesEntry24)

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
$TeamsLicenses.Add($TeamsLicensesEntry25)


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
$TeamsLicenses.Add($TeamsLicensesEntry26)

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
$TeamsLicenses.Add($TeamsLicensesEntry27)
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
$TeamsLicenses.Add($TeamsLicensesEntry28)

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
$TeamsLicenses.Add($TeamsLicensesEntry29)

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
$TeamsLicenses.Add($TeamsLicensesEntry30)
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
$TeamsLicenses.Add($TeamsLicensesEntry31)

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
$TeamsLicenses.Add($TeamsLicensesEntry32)

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
$TeamsLicenses.Add($TeamsLicensesEntry33)
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
$TeamsLicenses.Add($TeamsLicensesEntry34)

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
$TeamsLicenses.Add($TeamsLicensesEntry35)

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
$TeamsLicenses.Add($TeamsLicensesEntry36)

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
$TeamsLicenses.Add($TeamsLicensesEntry37)

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
$TeamsLicenses.Add($TeamsLicensesEntry38)
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
$TeamsServicePlans.Add($TeamsServicePlansEntry01)

$TeamsServicePlansEntry02 = [PSCustomObject][ordered]@{
  FriendlyName     = "Teams AR DoD"
  ProductName      = "Teams AR DoD"
  ServicePlanName  = "TEAMS_AR_DOD"
  ServicePlanId    = "fd500458-c24c-478e-856c-a6067a8376cd"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry02)

$TeamsServicePlansEntry03 = [PSCustomObject][ordered]@{
  FriendlyName     = "Teams AR GCC High"
  ProductName      = "Teams AR GCC High"
  ServicePlanName  = "TEAMS_AR_GCCHIGH"
  ServicePlanId    = "9953b155-8aef-4c56-92f3-72b0487fce41"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry03)

$TeamsServicePlansEntry04 = [PSCustomObject][ordered]@{
  FriendlyName     = "Skype Online"
  ProductName      = "Skype for Business Online"
  ServicePlanName  = "MCOSTANDARD"
  ServicePlanId    = "0feaeb32-d00e-4d66-bd5a-43b5b83db82c"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry04)

$TeamsServicePlansEntry05 = [PSCustomObject][ordered]@{
  FriendlyName     = "Audio Conferencing"
  ProductName      = "Audio Conferencing"
  ServicePlanName  = "MCOMEETADV"
  ServicePlanId    = "3e26ee1f-8a5f-4d52-aee2-b81ce45c8f40"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry05)

$TeamsServicePlansEntry06 = [PSCustomObject][ordered]@{
  FriendlyName     = "Phone System"
  ProductName      = "Phone System"
  ServicePlanName  = "MCOEV"
  ServicePlanId    = "4828c8ec-dc2e-4779-b502-87ac9ce28ab7"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry06)

$TeamsServicePlansEntry07 = [PSCustomObject][ordered]@{
  FriendlyName     = "Phone System - Virtual User"
  ProductName      = "Phone System - Virtual User"
  ServicePlanName  = "MCOEV_VIRTUALUSER"
  ServicePlanId    = "f47330e9-c134-43b3-9993-e7f004506889"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry07)
#endregion

#region Additional Service Plans
$TeamsServicePlansEntry08 = [PSCustomObject][ordered]@{
  FriendlyName     = "Skype Online (Midmarket)"
  ProductName      = "Skype for Business Online (Plan 2)"
  ServicePlanName  = "MCOSTANDARD_MIDMARKET"
  ServicePlanId    = "b2669e95-76ef-4e7e-a367-002f60a39f3e"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry08)
#endregion

#region Calling Plans
$TeamsServicePlansEntry09 = [PSCustomObject][ordered]@{
  FriendlyName     = "International Calling Plan"
  ProductName      = "International Calling Plan"
  ServicePlanName  = "MCOPSTN2"
  ServicePlanId    = "5a10155d-f5c1-411a-a8ec-e99aae125390"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry09)

$TeamsServicePlansEntry10 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan"
  ProductName      = "Domestic Calling Plan (3000 min US / 1200 min EU plans)"
  ServicePlanName  = "MCOPSTN1"
  ServicePlanId    = "4ed3ff63-69d7-4fb7-b984-5aec7f605ca8"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry10)

$TeamsServicePlansEntry11 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan (120 min calling plan)"
  ProductName      = "Domestic Calling Plan (120 min calling plan)"
  ServicePlanName  = "MCOPSTN5"
  ServicePlanId    = "54a152dc-90de-4996-93d2-bc47e670fc06"
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry11)

$TeamsServicePlansEntry12 = [PSCustomObject][ordered]@{
  FriendlyName     = "Domestic Calling Plan (240 min calling plan)"
  ProductName      = "Domestic Calling Plan (240 min calling plan)"
  ServicePlanName  = "MCOPSTN6"
  ServicePlanId    = ""
  RelevantForTeams = $FALSE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry12)

$TeamsServicePlansEntry13 = [PSCustomObject][ordered]@{
  FriendlyName     = "Communications Credits"
  ProductName      = "Communications Credits"
  ServicePlanName  = "MCOPSTNC"
  ServicePlanId    = ""
  RelevantForTeams = $TRUE
}
$TeamsServicePlans.Add($TeamsServicePlansEntry13)
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
$TeamsLicenses.Add($TeamsLicensesEntryXX)

$TeamsServicePlansEntryXX = [PSCustomObject][ordered]@{
  FriendlyName        = ""
  ProductName         = ""
  ServicePlanName     = ""
  ServicePlanId               = ""
  RelevantForTeams    = $
}
$TeamsServicePlans.Add($TeamsServicePlansEntryXX)

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

# SkuID and Partnumber are useful to look up dynamically, but would need a data source...
# Helper functions as a static alternative :)
function Get-SkuIDfromSkuPartNumber {
  <#
	.SYNOPSIS
		Returns SkuID from SkuPartNumber
	.DESCRIPTION
		Returns SkuID from SkuPartNumber
	.PARAMETER SkuPartNumber
		Part Number of the Sku
	.FUNCTIONALITY
		Helper Function for Licensing, translating ID to SkuPartNumber
	#>

  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuPartNumber
  )

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
}

function Get-SkuPartNumberfromSkuID {
  <#
	.SYNOPSIS
		Returns FriendlyName from SkuID
	.DESCRIPTION
		Returns SkuPartNumber or ProductName for any given SkuID
	.PARAMETER SkuId
		Identity of the License
	.PARAMETER Output
		Changes the Output Object. Can Return ProductName or SkuPartnumber (default)
	.FUNCTIONALITY
		Helper Function for Licensing, translating ID to FriendlyName
	#>

  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$SkuID,

    [Parameter(Mandatory = $false, HelpMessage = "Desired Output, SkuPartNumber or ProductName; Default: SkuPartNumber")]
    [ValidateSet("SkuPartNumber", "ProductName")]
    [String]$Output = "SkuPartNumber"
  )

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
}

function Write-ErrorRecord ($ErrorRecord) {
  <#
	.SYNOPSIS
		Returns the provided Error-Record as an Object
	.DESCRIPTION
		Helper Function for Troubleshooting
	.NOTES
		get error record (this is $_ from the parent function)
		This function must be called with 'Write-ErrorRecord $_'
	#>

  [Management.Automation.ErrorRecord]$e = $ErrorRecord

  # retrieve Info about runtime error
  $info = $null
  $info = [PSCustomObject]@{
    Exception = $e.Exception.Message
    Reason    = $e.CategoryInfo.Reason
    Target    = $e.CategoryInfo.TargetName
    Script    = $e.InvocationInfo.ScriptName
    Line      = $e.InvocationInfo.ScriptLineNumber
    Column    = $e.InvocationInfo.OffsetInLine
  }
  $info
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
    User   = $Name
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
    User     = $Name
    Property = $Property
    Result   = $Result
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
			.PARAMETER ReplaceLicense
			The SkuID for the License to replace (Resource Accounts only).
			.NOTES
			Uses Microsoft List for Licenses in SWITCH statement, update periodically or switch to lookup from DB(CSV or XLSX)
			https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time
	#>

  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
  param(
    [Parameter(Mandatory = $true, HelpMessage = "This is the UserID (UPN)")]
    [string]$UserID,

    [Parameter(Mandatory = $true, HelpMessage = "SkuID of the License")]
    #[AllowEmptyString()] #unknown why this is there
    [string]$LicenseSkuID,

    [Parameter(Mandatory = $false, HelpMessage = "Replaces all Licenses currently assigned. Handle with Care!")]
    [switch]$ReplaceLicense

  )

  # Query currently assigned Licenses (SkuID) for User ($UserID)
  $ObjectId = (Get-AzureADUser -ObjectId "$UserID").ObjectId
  $UserLicenses = (Get-AzureADUserLicenseDetail -ObjectId $ObjectId).SkuId
  $SkuPartNumber = Get-SkuPartNumberfromSkuID -SkuID "$LicenseSkuID"

  # Checking if the Tenant has a License of that SkuID
  if ($LicenseSkuID -ne "") {
    # Checking whether the User already has this license assigned
    if ($UserLicenses -notcontains $LicenseSkuID) {
      # Trying to assign License, SUCCESS if so, ERROR if not.
      try {
        if ($PSBoundParameters.ContainsKey('ReplaceLicense')) {
          if ($PSCmdlet.ShouldProcess("'Replace all assigned Licenses on Object '$UserID' with provided License: '$SkuPartNumber'", 'New-AzureAdLicenseObject')) {
            Write-Warning -Message "Replace License is removing all licenses from the Object. Only the License specified through -LicenseSkuID will remain on the Object"
            $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID -RemoveSkuId $UserLicenses
          }
          else {
            Write-Verbose -Message "Licenses not replaced. Specified SkuId is added regardless" -Verbose
            $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
          }
        }
        else {
          $license = New-AzureAdLicenseObject -SkuId $LicenseSkuID
        }
        Set-AzureADUserLicense -ObjectId $UserID -AssignedLicenses $license -ErrorAction STOP
        $Result = GetActionOutputObject2 -Name $UserID -Result "SUCCESS: $SkuPartNumber assigned"
      }
      catch {
        #$Result = GetActionOutputObject2 -Name $UserID -Result "ERROR: Unable to assign $SkuPartNumber`: $_"
        Write-ErrorRecord $_ #This handles the eror message in human readable format.
      }
    }
    else {
      $Result = GetActionOutputObject2 -Name $UserID -Result "INFO: User already has '$SkuPartNumber' assigned"
    }
  }
  else {
    $Result = GetActionOutputObject2 -Name $UserID -Result "WARNING: License '$SkuPartNumber' not found in tenant"
  }

  RETURN $Result
}

function GetApplicationTypeFromAppId ($CsAppId) {
  <#
	.SYNOPSIS
		ApplicationType for AppId
	.DESCRIPTION
		Translates a given AppId into a friendly ApplicationType (Name)
	#>

  switch ($CsAppId) {
    "11cd3e2e-fccb-42ad-ad00-878b93575e07" { $CsApplicationType = "CallQueue" }
    "ce933385-9390-45d1-9512-c8d228074e07" { $CsApplicationType = "AutoAttendant" }
    Default { }
  }
  return $CsApplicationType
}
function GetAppIdfromApplicationType ($CsApplicationType) {
  <#
	.SYNOPSIS
		AppId for ApplicationType
	.DESCRIPTION
		Translates a given friendly ApplicationType (Name) into an AppId used by MS commands
	#>

  switch ($CsApplicationType) {
    "CallQueue" { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07" }
    "CQ" { $CsAppId = "11cd3e2e-fccb-42ad-ad00-878b93575e07" }
    "AutoAttendant" { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07" }
    "AA" { $CsAppId = "ce933385-9390-45d1-9512-c8d228074e07" }
    Default { }
  }
  return $CsAppId
}
#endregion *** Non-Exported Helper Functions ***

# Exporting ModuleMembers

Export-ModuleMember -Variable TeamsLicenses, TeamsServicePlans
Export-ModuleMember -Alias    Remove-CsOnlineApplicationInstance, con, Connect-Me, dis, Disconnect-Me
Export-ModuleMember -Function Connect-SkypeOnline, Disconnect-SkypeOnline, Connect-SkypeTeamsAndAAD, Disconnect-SkypeTeamsAndAAD, Test-Module, `
  Get-AzureAdAssignedAdminRoles, Get-AzureADUserFromUPN, `
  Add-TeamsUserLicense, Set-TeamsUserLicense, New-AzureAdLicenseObject, Get-TeamsUserLicense, Get-TeamsTenantLicense, `
  Test-TeamsUserLicense, Set-TeamsUserPolicy, Test-TeamsTenantPolicy, `
  Test-AzureADModule, Test-AzureADConnection, Test-AzureADUser, Test-AzureADGroup, `
  Test-SkypeOnlineConnection, Test-MicrosoftTeamsConnection, Test-ExchangeOnlineConnection, Test-TeamsUser, `
  New-TeamsResourceAccount, Get-TeamsResourceAccount, Find-TeamsResourceAccount, Set-TeamsResourceAccount, Remove-TeamsResourceAccount, `
  New-TeamsResourceAccountAssociation, Get-TeamsResourceAccountAssociation, Remove-TeamsResourceAccountAssociation, `
  New-TeamsCallQueue, Get-TeamsCallQueue, Set-TeamsCallQueue, Remove-TeamsCallQueue, `
  Import-TeamsAudioFile, Backup-TeamsEV, Restore-TeamsEV, Backup-TeamsTenant, `
  Remove-TenantDialPlanNormalizationRule, Test-TeamsExternalDNS, Get-SkypeOnlineConferenceDialInNumbers, `
  Format-StringRemoveSpecialCharacter, Format-StringForUse, Write-ErrorRecord