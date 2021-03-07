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
  ModuleVersion         = '21.03'

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
  RequiredModules       = @('MicrosoftTeams')
  #RequiredModules       = @('AzureAdPreview','MicrosoftTeams')
  #RequiredModules = @('AzureAd','MicrosoftTeams'))

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
    'Get-TeamsTenantLicense',
    'Get-TeamsUserLicense',
    'Set-TeamsUserLicense',
    'Set-AzureAdUserLicenseServicePlan',

    # Resource Account
    'Find-TeamsResourceAccount',
    'Get-TeamsResourceAccount',
    'Get-TeamsResourceAccountAssociation',
    'New-TeamsResourceAccount',
    'New-TeamsResourceAccountAssociation',
    'Remove-TeamsResourceAccount',
    'Remove-TeamsResourceAccountAssociation',
    'Set-TeamsResourceAccount',
    'Test-TeamsResourceAccount',

    # Session
    'Assert-AzureADConnection',
    'Assert-MicrosoftTeamsConnection',
    'Connect-Me',
    'Disconnect-Me',
    'Test-AzureADConnection',
    'Test-ExchangeOnlineConnection',
    'Test-MicrosoftTeamsConnection',

    # Support
    ## Backup
    'Backup-TeamsEV',
    'Backup-TeamsTenant',
    'Restore-TeamsEV',
    ## Helper
    'Format-StringForUse',
    'Format-StringRemoveSpecialCharacter',
    'Find-AzureAdGroup',
    'Find-AzureAdUser',
    'Get-PublicHolidayCountry',
    'Get-PublicHolidayList',
    'Get-RegionFromCountryCode',
    'Get-TeamsObjectType',
    'Test-AzureAdGroup',
    'Test-AzureAdUser',
    'Assert-Module',
    'Test-TeamsUser',
    ## Licensing
    #'Enable-AzureAdLicenseServicePlan',
    'New-AzureAdLicenseObject',
    'Test-TeamsUserHasCallPlan',
    'Test-TeamsUserLicense',
    ## Other
    'Get-SkypeOnlineConferenceDialInNumbers',
    'Remove-TenantDialPlanNormalizationRule',
    'Test-TeamsExternalDNS',
    ## VoiceConfig
    'Get-TeamsMGW',
    'Get-TeamsOPU',
    'Get-TeamsOVP',
    'Get-TeamsOVR',
    'Get-TeamsTDP',
    'Get-TeamsTenant',
    'Get-TeamsVNR',

    #UserManagement
    ##AzureAdAdminRole
    'Enable-AzureAdAdminRole',
    'Get-AzureAdAdminRole',
    ##TeamsCallableEntity
    'Assert-TeamsCallableEntity',
    'Find-TeamsCallableEntity',
    'Get-TeamsCallableEntity',
    'New-TeamsCallableEntity',
    ##TeamsCommonAreaPhone
    'Get-TeamsCommonAreaPhone',
    'New-TeamsCommonAreaPhone',
    'Set-TeamsCommonAreaPhone',
    'Remove-TeamsCommonAreaPhone'

    # Voice Config
    'Enable-TeamsUserForEnterpriseVoice',
    'Find-TeamsUserVoiceConfig',
    'Find-TeamsUserVoiceRoute',
    'Get-TeamsTenantVoiceConfig',
    'Get-TeamsUserVoiceConfig',
    'Remove-TeamsUserVoiceConfig',
    'Set-TeamsUserVoiceConfig',
    #'Test-TeamsTenantDialPlan',
    'Test-TeamsUserVoiceConfig'

  )

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport       = @()

  # Variables to export from this module
  #VariablesToExport     = @('TeamsLicenses', 'TeamsServicePlans')

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport       = @(
    'con', 'dis', 'pol', 'Enable-Ev', 'Set-ServicePlan',
    'Set-TeamsUVC', 'Get-TeamsUVC', 'Find-TeamsUVC', 'Find-TeamsUVR', 'Remove-TeamsUVC', 'Test-TeamsUVC',
    'Get-TeamsCAP', 'New-TeamsCAP', 'Remove-TeamsCAP', 'Set-TeamsCAP', #'Test-TeamsTDP',

    'New-TeamsRA', 'Find-TeamsRA', 'Get-TeamsRA', 'Remove-TeamsRA', 'Set-TeamsRA',
    'Get-TeamsRAA', 'New-TeamsRAA', 'Remove-TeamsRAA', 'Remove-CsOnlineApplicationInstance',
    'Get-TeamsCQ', 'New-TeamsCQ', 'Remove-TeamsCQ', 'Set-TeamsCQ',
    'Get-TeamsAA', 'New-TeamsAA', 'Remove-TeamsAA', 'Set-TeamsAA', 'Set-TeamsAutoAttendant',

    'New-TeamsAAMenu', 'New-TeamsAAOption', 'New-TeamsAAFlow',
    'New-TeamsAAPrompt', 'New-TeamsAAScope', 'New-TeamsAASchedule',
    'New-TeamsAAEntity', 'New-TeamsAutoAttendantCallableEntity',
    'New-TeamsAutoAttendantCallHandlingAssociation'

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
      Tags       = @('Teams', 'DirectRouting', 'SkypeOnline', 'Licensing', 'ResourceAccount', 'CallQueue', 'AutoAttendant', 'VoiceConfig')

      # Prerelease Version
      Prerelease = '-prerelease'

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
