# Teams Scripts and Functions

## Overview

### Prerequisites

- All Functions are based on the assumption that PowerShell v5.1 is used. This is required.
- Though not explicitely called out with `#Requires` in the Module, one of the Modules `AzureAd` or `AzureAdPreview` are required.
- To access Teams, either `SkypeOnlineConnector`(v7) or `MicrosoftTeams` are required.

### Information

This module currently contains over 85 Functions covering a broad area of Teams Functions for Admins: From Session Connection and activating Admin Roles in PIM to User Administration, Licensing and Voice Configuration all the way to Resource Accounts, Call Queues, Auto Attendants

## Access

To properly administer Teams, a connection to `AzureAd` is most likely needed. Privileged Identity Management and Role Activation are only available with the Module `AzureAdPreview` installed in Version `2.0.2.24` or higher, until the functions become generally available through the AzureAd Module.

Initially, this module was built around the use of the `SkypeOnlineConnector`(v7). The Connector is now deprectated and will be replaced by end of FEB 2021.
The command to establish a connection has been ported to `MicrosoftTeams` in `v1.1.6`. Starting with **TeamsFunctions v21.01**, the requirement for SkypeOnlineConnector is lifted. Either module can be used, with some drawbacks: Using MicrosoftTeams does currently not allow seamless Single-Sign-On as no Username can be passed on to the Session command and Session Reconnection is currently not possible as the Command `Enable-CsOnlineSessionForReconnection` was not ported over. Some further testing is required still.

### Session Connection

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them is not implemented very nicely. The introduction of Privileged Identity Management and Privileged Access Groups further requires some manual steps that the following are trying to make simpler and provide an easier way to connect and activate your roles:

| Function                 | Description                                                                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Connect-SkypeOnline`    | Creates a Session to SkypeOnline (v7 also extends Timeout Limit!)                                                                            |
| `Connect-Me` (con)       | Creates a Session to SkypeOnline and AzureAD in one go. Only displays **ONE** authentication prompt, and, if applicable, **ONE** MFA prompt! |
| `Disconnect-SkypeOnline` | Disconnects from a Session to SkypeOnline. This prevents timeouts and hanging sessions                                                       |
| `Disconnect-Me` (dis)    | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD                                                                     |

### Admin Roles

Activating Admin Roles made easier. Please note that Privileged Access Groups are not yet integrated as there are no PowerShell commands available yet in the AzureAdPreview Module. This will be added as soon as possible. Commands are used with `Connect-Me`, but can be used on its own just as well.

> [!NOTE] Please note, that Privileged Admin Groups are currently not covered by these CmdLets. This will be added as soon as possible

| Function                  | Description                                                                                                                                     |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `Enable-AzureAdAdminRole` | Enables Admin Roles assigned directly to the AccountId provided. If no accountId is provided, the currently connected User to AzureAd is taken. |
| `Get-AzureAdAdminRole`    | Displays all (active or eligible) Admin Roles assigned to an AzureAdUser                                                                        |

***

## User Admin

### Licensing Functions

Functions for licensing in AzureAD. Hopefully simplifies license queries and application a bit

| Function                        | Description                                                                                                    |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `Get-TeamsTenantLicense`        | Queries licenses present on the Tenant. Switches are available for better at-a-glance visibility               |
| `Get-TeamsUserLicense`          | Queries licenses assigned to a User and displays visual output                                                 |
| `Test-TeamsUserLicense`         | Tests an individual Service Plan or a License Package against the provided Identity                            |
| `Set-TeamsUserLicense`          | Adds or removes one or more Licenses against the provided Identity. Also can remove all Licenses.              |
| `New-AzureAdLicenseObject`      | Creates a License Object for application. Generic helper function.                                             |
| `Get-TeamsLicense`              | 39 Relevant Licenses for Teams. Exported variable to standardise and harmonise Licensing queries.              |
| `Get-TeamsLicenseServicePlan`   | 13 Relevant Service Plans for Teams. Exported variable to standardise and harmonise Licensing queries.         |
| `Get-AzureAdLicense`            | A Script to query all published Licenses and their Service Plans. Switch can filter for Teams related Licenses |
| `Get-AzureAdLicenseServicePlan` | Same as above, but displaying Service Plans only. Switch can filter for Teams related ServicePlans             |

All Licenses and Service Plans are queried from [Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference)
***

## Voice Configuration

Functions for querying Teams Voice Configuration, both for Direct Routing and Calling Plans

| Function                             | Description                                                                                                                                       |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Enable-TeamsUserForEnterpriseVoice` | Validates User License requirements and enables a User for Enterprise Voice (I needed a shortcut)                                                 |
| `Find-TeamsUserVoiceRoute`           | Queries a users Voice Configuration chain to finding a route a call takes for a User (more granular with a `-DialedNumber`)                       |
| `Find-TeamsUserVoiceConfig`          | Queries Voice Configuration parameters against all Users on the tenant. Finding assignments of a number, usage of a specific OVP or TDP, etc.     |
| `Get-TeamsTenantVoiceConfig`         | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                       |
| `Get-TeamsUserVoiceConfig`           | Queries Voice Configuration assigned to a User and displays visual output. At-a-glance concise output, extensible through `-DiagnosticLevel`      |
| `Remove-TeamsUserVoiceConfig`        | Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set |
| `Set-TeamsUserVoiceConfig`           | Applies a full Set of Voice Configuration (Number, Online Voice Routing Policy, Tenant Dial Plan, etc.) to the provided Identity                  |
| `Test-TeamsUserVoiceConfig`          | Tests an individual VoiceConfig Package against the provided Identity                                                                             |

### Support cmdlets for Voice Config

The others are mainly helping to cut down on typing when doing stuff quickly. Sometimes knowing just enough is enough, like knowing only the names of the Tenant Dial Plan or the Online Voice Routing Policy in question is just what I need, nothing more.

| Function          | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| `Get-TeamsTenant` | Get-CsTenant gives too much output? This can help.                                  |
| `Get-TeamsOVP`    | Get-CsOnlineVoiceRoutingPolicy is too long to type? Here is a shorter one :)        |
| `Get-TeamsOPU`    | Get-CsOnlinePstnUsage is too clunky. Here is a shorter one, with a search function! |
| `Get-TeamsOVR`    | Get-CsOnlineVoiceRoute                                                              |
| `Get-TeamsMGW`    | Get-CsOnlinePstnGateway                                                             |
| `Get-TeamsTDP`    | Get-TeamsTenantDialPlan is too long to type. Also, we only want the names...        |
| `Get-TeamsVNR`    | Displays all Voice Normalization Rules (VNR) for a given Dial Plan                  |

### Handling Objects

Finding Users, Groups or other objects is sometimes too complex for my taste. Using `Get-AzureAdUser -Searchstring "$UPN"` is fine, but sometimes I just want to bash in the UserPrincipalName or Group Name and get a result. Some helper functions that simplify input a bit and expand on the functionality of Callable Entity:

| Function                   | Description                                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `Find-AzureAdGroup`        | Helper Function to find AzureAd Groups. Returns Objects if found. Simplifies Lookup and Search of Objects                               |
| `Find-AzureAdUser`         | Helper Function to find AzureAd Users. Returns Objects if found. Simplifies Lookup and Search of Objects                                |
| `Find-TeamsCallableEntity` | Searches all Call Queues and/or all Auto Attendants for a connected/targeted `Callable Entity` (TelURI, User, Group, Resource Account). |
| `Get-TeamsCallableEntity`  | Creates a new Object emulating the output of a `Callable Entity`, validating the Object type and its usability for CQs or AAs.          |
| `New-TeamsCallableEntity`  | Used for Auto Attendants, creates a `Callable Entity` Object given a CallTarget (the type is enumerated through lookup)                 |

***

## Automatic Call Handling

Voice options that are not handled by the User, but rather through additional entities in the Tenant, I have dubbed 'Automatic Call Handling'. This includes Call Queues and Auto Attendants but also their pre-requisites Resource Accounts and their association to them.

### Resource Accounts

Though you can now also provide a UserPrincipalName for `CsOnlineApplicationInstance` scripts, they are, I think, not telling you enough. IDs are used for the Application Type. These Scripts are wrapping around them, bind to the *UserPrincipalName* and offer more required information for properly managing Resource Accounts for Call Queues and Auto Attendants.

| Function                      | Underlying Function                 | Description                                                                                                 |
| ----------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccount`    | Creates a Resource Account in Teams |                                                                                                             |
| `Find-TeamsResourceAccount`   | Find-CsOnlineApplicationInstance    | Finds Resource Accounts based on provided SearchString                                                      |
| `Get-TeamsResourceAccount`    | Get-CsOnlineApplicationInstance     | Queries Resource Accounts based on input: SearchString, Identity (UserPrincipalName), PhoneNumber, Type     |
| `Set-TeamsResourceAccount`    | Set-CsOnlineApplicationInstance     | Changes settings for a Resource Accounts, applying UsageLocation, Licenses and Phone Numbers, swapping Type |
| `Remove-TeamsResourceAccount` | Remove-AzureAdUser                  | Removes a Resource Account and optionally (with -Force) also the Associations this account has.             |

### Resource Account Association

| Function                                 | Underlying Function                           | Description                                                                                          |
| ---------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccountAssociation`    | New-CsOnlineApplicationInstanceAssociation    | Links one or more Resource Accounts to a Call Queue or an Auto Attendant                             |
| `Get-TeamsResourceAccountAssociation`    | Get-CsOnlineApplicationInstanceAssociation    | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants. Also shows Status |
| `Remove-TeamsResourceAccountAssociation` | Remove-CsOnlineApplicationInstanceAssociation | Removes a link for one or more Resource Accounts                                                     |

### Call Queues

Microsoft has selected a GUID as the Identity the `CsCallQueue` scripts are a bit cumbersome for the average admin. Though the Searchstring parameter is available, enabling me to utilise it as a basic input method for `TeamsCallQueue` CmdLets. They query by *DisplayName*, which comes with a drawback for the `Set`-command: It requires a unique result. Also uses Filenames instead of IDs when adding Audio Files. Microsoft is continuing to improve these scripts, so I hope these can stand the test of time and make managing Call Queues easier.

| Function                | Underlying Function | Description                                                        |
| ----------------------- | ------------------- | ------------------------------------------------------------------ |
| `New-TeamsCallQueue`    | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Get-TeamsCallQueue`    | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| `Set-TeamsCallQueue`    | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Remove-TeamsCallQueue` | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

### Auto Attendants

The complexity of the AutoAttendants and design principles of PowerShell ("one function does one thing and one thing only") means that the `CsAutoAttendant` CmdLets are feeling to be all over the place. Multiple CmdLets have to be used in conjunction in order to create an Auto Attendant. No defaults are available. The `TeamsAutoAttendant` CmdLets try to address that. From the basic NEW-Command that - without providing *any* Parameters (except the name of course) can create an Auto Attendant entity. This simplifies things a bit and tries to get you 80% there without lifting much of a finger. Amending it afterwards in the Admin Center is my current mantra. See Support Functions for more versatility!

| Function                    | Underlying Function    | Description                                                                                  |
| --------------------------- | ---------------------- | -------------------------------------------------------------------------------------------- |
| `Get-TeamsAutoAttendant`    | Get-CsAutoAttendant    | Queries an Auto Attendant                                                                    |
| `New-TeamsAutoAttendant`    | New-CsAutoAttendant    | Creates an Auto Attendant with defaults (Disconnect, Standard Business Hours schedule, etc.) |
| Set-TeamsAutoAttendant      | Set-CsAutoAttendant    | Changes an Auto Attendant with friendly input. Alias to Set-CsAutoAttendant only!            |
| `Remove-TeamsAutoAttendant` | Remove-CsAutoAttendant | Removes an Auto Attendant from the Tenant                                                    |

### Call Queue & Auto Attendant Support Functions

Creating a Menu or a Call Flow feels clunky to me, the commands require excessive chaining in order to create a full Auto Attendant. The complexity of the AutoAttendants also has spawned a few support functions. Keeping in step with them and simplifying their use a bit is what my take on them represents.

| Function                                      | Underlying Function                        | Description                                                                                                         |
| --------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `Import-TeamsAudioFile`                       | Import-CsOnlineAudioFile                   | Imports an Audio File for use within Call Queues or Auto Attendants                                                 |
| `New-TeamsAutoAttendantCallFlow`              | New-CsAutoAttendantCallFlow                | Creates a `CallFlow` Object with a Prompt and Menu and some default options.                                        |
| New-TeamsAutoAttendantCallHandlingAssociation | New-CsAutoAttendantCallHandlingAssociation | Not written yet, a CallHandlingAssociation is created with only contain a `Schedule` object and a `CallFlow` object |
| `New-TeamsAutoAttendantDialScope`             | New-CsAutoAttendantDialScope               | Creates a `DialScope` Object for provided Office 365 Group Names                                                    |
| `New-TeamsAutoAttendantMenu`                  | New-CsAutoAttendantMenu                    | Creates a `Menu` Object for Menu Options in two possible inputs                                                     |
| `New-TeamsAutoAttendantMenuOption`            | New-CsAutoAttendantMenuOption              | Creates a `MenuOption` Object for easier use                                                                        |
| `New-TeamsAutoAttendantPrompt`                | New-CsAutoAttendantPrompt                  | Creates a `Prompt` Object and simplifies usage as it determines the type based on the input string.                 |
| `New-TeamsAutoAttendantSchedule`              | New-CsAutoAttendantSchedule                | Creates a `Schedule` Object and simplifies input for use in AA CHA. Multiple default options are available          |
| `New-TeamsCallableEntity`                     | New-CsAutoAttendantCallableEntity          | Creates a `CallableEntity` Object given a CallTarget (type is enumerated)                                           |

***

## Other Functions

Functions that do not build the core of this module, but nevertheless are usefull additions to it. Covering Backup, Testing, Assertions and other Helper functions for public use. Private Functions are not listed.

### Backup and Restore

Curtesy of Ken Lasko

| Function             | Description                                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `Backup-TeamsEV`     | Takes a backup of all EnterpriseVoice related features in Teams.                                                    |
| `Restore-TeamsEV`    | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care!                       |
| `Backup-TeamsTenant` | An adaptation of the above, backing up as much as can be gathered through available `Get`-Commands from the tenant. |

NOTE: `Backup-TeamsTenant` is currently static, if additional Get-Commands are added this command is not automatically covering this (yet)

### Helper functions

| Function                                 | Description                                                                                                                               |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `Format-StringForUse`                    | Prepares a string for use as DisplayName, UserPrincipalName, LineUri or E.164 Number, removing special characters as needed.              |
| `Format-StringRemoveSpecialCharacter`    | Formats a String and removes special characters (harmonising Display Names)                                                               |
| `Get-RegionFromCountryCode`              | Just a little helper figuring out which geographical region (AMER, EMEA, APAC) a specific country is in.                                  |
| `Get-TeamsObjectType`                    | Little brother to `Get-TeamsCallableEntity` Returns the type of any given Object to identify its use in CQs and AAs.                      |
| `Get-SkypeOnlineConferenceDialInNumbers` | Gathers Dial-In Conferencing Numbers for a specific Domain<br />NOTE: This command is evaluated for revival                               |
| `Remove-TenantDialPlanNormalizationRule` | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove<br />NOTE: This command is evaluated for revival |

### Test & Assert Functions

These are helper functions for testing Connections and Modules. All Functions return boolean output.

| Function                          | Description                                                                                                 |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Assert-AzureAdConnection`        | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-MicrosoftTeamsConnection` | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-SkypeOnlineConnection`    | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*               |
| `Test-AzureAdConnection`          | Verifying a Session to AzureAD exists                                                                       |
| `Test-MicrosoftTeamsConnection`   | Verifying a Session to MicrosoftTeams exists                                                                |
| `Test-SkypeOnlineConnection`      | Verifying a Session to SkypeOnline exists                                                                   |
| `Test-ExchangeOnlineConnection`   | Verifying a Session to ExchangeOnline exists                                                                |
| `Test-Module`                     | Verifying the specified Module is loaded                                                                    |
| `Test-AzureAdGroup`               | Testing whether the Group exists in AzureAd                                                                 |
| `Test-AzureAdUser`                | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!)                 |
| `Test-TeamsResourceAccount`       | Testing whether a Resource Account exists in AzureAd                                                        |
| `Test-TeamsUser`                  | Testing whether the User exists in SkypeOnline/Teams                                                        |
| `Test-TeamsUserLicense`           | Testing whether the User has a specific Teams License                                                       |
| `Test-TeamsUserHasCallPlan`       | Testing whether the User has any Call Plan License                                                          |
| `Test-TeamsExternalDNS`           | Tests DNS Records for Skype for Business Online and Teams<br />NOTE: This command is evaluated for revival. |

NOTE: The `Test-TeamsUser*` CmdLets are currently limited to the output from `Get-TeamsLicense`. These will be reworked to draw from `Get-AzureAdLicense` soon.

***

## Appendix

### Documentation and Change Log

- README.md provides a general overview
- VERSION.md for a detailed breakdown of the Change log.
- VERSION-PreRelease.md records all changes for Pre-Releases
- ARCHIVE.md records all removed functions

### Current issues

- Figuring out Pester, Writing proper Test scenarios
- Continuous Improvement and Bugfixing for BETA and RC Functions
- Privileged Admin Groups cannot be queried via PowerShell yet.

### Update/Extension plans

- Performance improvements, bug fixing and more testing
- Adding Functional improvements to lookup
- Licensing. Embedding of new Functions and replacement of current Variables. (v21.02)
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- Testing: Currently, only limited Pester tests are available for the Module and select functions.<br />No Pester tests exist for Functions that require a Session to AzureAd or SkypeOnline - I cannot figure them out yet. All Testing is done with VScode and my trusty ISESteroids.
- Privileged Identity Management functionality is only available with the AzureAdPreview module

## Final Word

I hope you enjoy using this module and its functions as much as I do :)

David
