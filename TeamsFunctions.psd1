#
# Module manifest for module 'TeamsFunctions'
#
# Generated by: David Eberhardt
#
# Generated on: 16/05/2020
#

@{

  # Script module or binary module file associated with this manifest.
  RootModule            = 'TeamsFunctions.psm1'

  # Version number of this module.
  ModuleVersion         = '21.07.25'

  # Supported PSEditions
  # CompatiblePSEditions = @()

  # ID used to uniquely identify this module
  GUID                  = 'c0165b45-500b-4d59-be47-64f567e4b4c9'

  # Author of this module
  Author                = 'David Eberhardt'

  # Company or vendor of this module
  CompanyName           = 'None / Personal'

  # Copyright statement for this module
  Copyright             = '(c) 2020,2021 David Eberhardt. All Rights Reserved'

  # Description of the functionality provided by this module
  Description           = 'Teams Functions for Administration of Users, Common Area Phones, Resource Accounts, Call Queues and Auto Attendants, incl. Licensing, User Voice Configuration with Calling Plans and Direct Routing,
For more information, please visit the https://davideberhardt.wordpress.com/ or https://github.com/DEberhardt/TeamsFunctions'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion     = '5.1'

  # Name of the Windows PowerShell host required by this module
  # PowerShellHostName = ''

  # Minimum version of the Windows PowerShell host required by this module
  # PowerShellHostVersion = ''

  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # DotNetFrameworkVersion = ''

  # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # CLRVersion = ''

  # Processor architecture (None, X86, Amd64) required by this module
  ProcessorArchitecture = 'Amd64'

  # Modules that must be imported into the global environment prior to importing this module
  # RequiredModules       = @('MicrosoftTeams')
  # RequiredModules       = @('AzureAdPreview','MicrosoftTeams')
  # RequiredModules       = @('AzureAd','MicrosoftTeams'))

  # Assemblies that must be loaded prior to importing this module
  # RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  # FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  # NestedModules = @()

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport     = @(
    # Auto Attendant
    'Get-TeamsAutoAttendant',
    'Import-TeamsAudioFile',
    'New-TeamsAutoAttendant',
    'New-TeamsAutoAttendantCallFlow',
    'New-TeamsAutoAttendantMenu',
    'New-TeamsAutoAttendantMenuOption',
    'New-TeamsAutoAttendantPrompt',
    'New-TeamsAutoAttendantSchedule',
    'New-TeamsAutoAttendantDialScope',
    'Remove-TeamsAutoAttendant',

    # Call Queue
    'Get-TeamsCallQueue',
    'New-TeamsCallQueue',
    'Remove-TeamsCallQueue',
    'Set-TeamsCallQueue',

    # Licensing
    'Get-AzureAdLicense',
    'Get-AzureAdLicenseServicePlan',
    'Get-AzureAdUserLicense',
    'Get-AzureAdUserLicenseServicePlan',
    'Get-TeamsTenantLicense',
    'Get-TeamsUserLicense',
    'Get-TeamsUserLicenseServicePlan',
    'Set-TeamsUserLicense',
    'Set-AzureAdUserLicenseServicePlan',

    # Resource Account
    'Find-TeamsResourceAccount',
    'Get-TeamsResourceAccount',
    'Get-TeamsResourceAccountAssociation',
    'Get-TeamsResourceAccountLineIdentity',
    'New-TeamsResourceAccount',
    'New-TeamsResourceAccountAssociation',
    'New-TeamsResourceAccountLineIdentity',
    'Remove-TeamsResourceAccount',
    'Remove-TeamsResourceAccountAssociation',
    'Set-TeamsResourceAccount',

    # Session
    'Connect-Me',
    'Disconnect-Me',

    #region Support
    ## AutoAttendant
    'Get-PublicHolidayCountry',
    'Get-PublicHolidayList',
    'Get-TeamsAutoAttendantSchedule',
    'New-TeamsHolidaySchedule',
    ## Backup
    'Backup-TeamsEV',
    'Backup-TeamsTenant',
    'Restore-TeamsEV',
    ## Helper
    'Assert-Module',
    'Format-StringForUse',
    'Format-StringRemoveSpecialCharacter',
    'Get-RegionFromCountryCode',
    'Get-TeamsObjectType',
    ## Licensing
    'New-AzureAdLicenseObject',
    'Test-AzureAdLicenseContainsServicePlan',
    'Test-TeamsUserHasCallPlan',
    'Test-TeamsUserLicense',
    ## Other
    'Get-SkypeOnlineConferenceDialInNumbers',
    'Remove-TenantDialPlanNormalizationRule',
    'Test-TeamsExternalDNS',
    ## Session
    'Assert-AzureADConnection',
    'Assert-MicrosoftTeamsConnection',
    'Get-CurrentConnectionInfo',
    'Test-AzureADConnection',
    'Test-ExchangeOnlineConnection',
    'Test-MicrosoftTeamsConnection',
    ## UserManagement
    'Test-AzureAdGroup',
    'Test-AzureAdUser',
    'Test-TeamsResourceAccount',
    'Test-TeamsUser',
    ## VoiceConfig
    'Enable-TeamsUserForEnterpriseVoice',
    'Get-TeamsMGW',
    'Get-TeamsOPU',
    'Get-TeamsOVP',
    'Get-TeamsOVR',
    'Get-TeamsTDP',
    'Get-TeamsTenant',
    'Get-TeamsVNR',
    'Get-TeamsCP',
    'Get-TeamsIPP',
    'Get-TeamsECP',
    'Get-TeamsECRP',
    'Grant-TeamsEmergencyAddress',
    #endregion

    #Teams
    'Get-TeamsTeamChannel',

    #region UserManagement
    ## AzureAdObjects
    'Find-AzureAdGroup',
    'Find-AzureAdUser',
    ## AzureAdAdminRole
    'Disable-AzureAdAdminRole',
    'Disable-MyAzureAdAdminRole',
    'Enable-AzureAdAdminRole',
    'Enable-MyAzureAdAdminRole',
    'Get-AzureAdAdminRole',
    'Get-MyAzureAdAdminRole',
    ## TeamsCallableEntity
    'Assert-TeamsCallableEntity',
    'Find-TeamsCallableEntity',
    'Get-TeamsCallableEntity',
    'New-TeamsCallableEntity',
    ## TeamsCommonAreaPhone
    'Get-TeamsCommonAreaPhone',
    'New-TeamsCommonAreaPhone',
    'Set-TeamsCommonAreaPhone',
    'Remove-TeamsCommonAreaPhone'
    #endregion

    # VoiceConfig
    'Assert-TeamsUserVoiceConfig',
    'Find-TeamsUserVoiceConfig',
    'Find-TeamsUserVoiceRoute',
    'Find-TeamsEmergencyCallRoute',
    'Get-TeamsTenantVoiceConfig',
    'Get-TeamsUserVoiceConfig',
    'New-TeamsUserVoiceConfig',
    'Remove-TeamsUserVoiceConfig',
    'Set-TeamsUserVoiceConfig',
    'Test-TeamsUserVoiceConfig'

  )

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport       = @()

  # Variables to export from this module
  #VariablesToExport     = @('TeamsLicenses', 'TeamsServicePlans')

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport       = @(
    'con', 'dis', 'pol', 'ear', 'dar', 'gar', 'cur', 'Enable-Ev', 'Set-ServicePlan',
    'Set-TeamsUVC', 'New-TeamsUVC', 'Get-TeamsUVC', 'Find-TeamsUVC', 'Remove-TeamsUVC', 'Test-TeamsUVC', 'Assert-TeamsUVC',
    'Find-TeamsUVR', 'Find-TeamsECR',
    'Get-TeamsCAP', 'New-TeamsCAP', 'Remove-TeamsCAP', 'Set-TeamsCAP',

    'New-TeamsRA', 'Find-TeamsRA', 'Get-TeamsRA', 'Remove-TeamsRA', 'Set-TeamsRA',
    'Get-TeamsRAIdentity', 'Get-TeamsRACLI', 'New-TeamsRAIdentity', 'New-TeamsRACLI',
    'Get-TeamsRAA', 'New-TeamsRAA', 'Remove-TeamsRAA', 'Remove-CsOnlineApplicationInstance',
    'Get-TeamsCQ', 'New-TeamsCQ', 'Remove-TeamsCQ', 'Set-TeamsCQ',
    'Get-TeamsAA', 'New-TeamsAA', 'Remove-TeamsAA', 'Set-TeamsAA', 'Set-TeamsAutoAttendant',

    'New-TeamsAAMenu', 'New-TeamsAAOption', 'New-TeamsAAFlow',
    'New-TeamsAAPrompt', 'New-TeamsAAScope', 'New-TeamsAASchedule',
    'New-TeamsAAEntity', 'New-TeamsAutoAttendantCallHandlingAssociation',
    'Get-TeamsAASchedule',
    'Get-Channel'

  )

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  # ModuleList = @()

  # List of all files packaged with this module
  # FileList = @()

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData           = @{

    PSData = @{

      # Tags applied to this module. These help with module discovery in online galleries.
      Tags       = @('Teams', 'DirectRouting', 'EnterpriseVoice', 'Licensing', 'ResourceAccount', 'CallQueue', 'AutoAttendant', 'VoiceConfig', 'CommonAreaPhone')

      # Prerelease Version
      #Prerelease = '-prerelease'

      # A URL to the license for this module.
      LicenseUri = 'https://github.com/DEberhardt/TeamsFunctions/blob/master/LICENSE'

      # A URL to the main website for this project.
      # ProjectUri = ''

      # A URL to an icon representing this module.
      # IconUri = ''

      # ReleaseNotes of this module
      # ReleaseNotes = ''

    } # End of PSData hashtable

  } # End of PrivateData hashtable

  # HelpInfo URI of this module
  # Full Path: https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/TeamsFunctions-help.xml'
  #Does not work!
  #HelpInfoURI           = 'https://raw.githubusercontent.com/DEberhardt/TeamsFunctions/master/docs/'

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''

}
