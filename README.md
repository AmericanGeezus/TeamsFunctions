# Teams Scripts and Functions

## Available Functions

### Connections

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them is not implemented very nicely. The following is trying to make this simpler and provide an easier way to connect:

| Function                 | Alias                                  | Description                                                                                                                                  |
| ------------------------ | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Connect-SkypeOnline`    |                                        | Creates a Session to SkypeOnline (v7 also extends Timeout Limit!)                                                                            |
| `Connect-Me`             | con, <br/>Connect-SkypeTeamsAndAAD*    | Creates a Session to SkypeOnline and AzureAD in one go. Only displays **ONE** authentication prompt, and, if applicable, **ONE** MFA prompt! |
| `Disconnect-SkypeOnline` |                                        | Disconnects from a Session to SkypeOnline. This prevents timeouts and hanging sessions                                                       |
| `Disconnect-Me`          | dis, <br/>Disconnect-SkypeTeamsAndAAD* | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD                                                                     |

NOTE: Aliases (*) switched places and old (long) one will be removed with v20.11

### Licensing Functions

Functions for licensing in AzureAD. Hopefully simplifies license application a bit

| Function                                | Description                                                                                                                                    |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `Get-TeamsTenantLicense`                | Queries licenses present on the Tenant. Switches are available for better at-a-glance visibility                                               |
| `Get-TeamsUserLicense`                  | Queries licenses assigned to a User and displays visual output                                                                                 |
| `Test-TeamsUserLicense`                 | Tests an individual Service Plan or a License Package against the provided Identity                                                            |
| `Add-TeamsUserLicense` **[deprecated]** | Adds one or more Licenses specified per Switch to the provided Identity                                                                        |
| `Set-TeamsUserLicense`                  | Adds or removes one or more Licenses against the provided Identity. Also can remove all Licenses. Replaces Add-TeamsUserLicense                |
| `New-AzureAdLicenseObject`              | Creates a License Object for application. Generic helper function.                                                                             |
| `$TeamsLicenses`                        | 39 Relevant Licenses for Teams. Exported variable to standardise and harmonise Licensing queries. Used by all `TeamsUserLicense` CmdLets       |
| `$TeamsServicePlans`                    | 13 Relevant Service Plans for Teams. Exported variable to standardise and harmonise Licensing queries. Used by some `TeamsUserLicense` CmdLets |

### Voice Configuration Functions

Functions for querying Teams Voice Configuration, both for Direct Routing and Calling Plans

| Function                      | Alias           | Description                                                                                                                                              |
| ----------------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Get-TeamsTenantVoiceConfig`  |                 | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                              |
| `Get-TeamsUserVoiceConfig`    | Get-TeamsUVC    | Queries Voice Configuration assigned to a User and displays visual output. At-a-glance concise output. Switch *DiagnosticLevel* displays more parameters |
| `Find-TeamsUserVoiceConfig`   | Find-TeamsUVC   | Queries Voice Configuration parameters against all Users on the tenant. Good to find where a specific Number is assigned to.                             |
| `Set-TeamsUserVoiceConfig`    | Set-TeamsUVC    | Applies a full Set of Voice Configuration (Number, OnlineVoiceRouting Policy, Tenant Dial Plan, etc.) to the provided Identity                           |
| `Remove-TeamsUserVoiceConfig` | Remove-TeamsUVC | Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set        |
| `Test-TeamsUserVoiceConfig`   | Test-TeamsUVC   | TBC - Tests an individual VoiceConfig Package against the provided Identity                                                                              |

### Resource Accounts

As Microsoft has selected a GUID as the Identity the `CsOnlineApplicationInstance` scripts are a bit cumbersome. IDs are also used for the Application Type. These Scripts are wrapping around them and bind to the *UserPrincipalName* instead of the *ObjectId*/Identity.

| Function                      | Alias                                                   | Underlying Function              | Description                                                                                                 |
| ----------------------------- | ------------------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccount`    | New-TeamsRA                                             | New-CsOnlineApplicationInstance  | Creates a Resource Account in Teams                                                                         |
| `Find-TeamsResourceAccount`   | Find-TeamsRA                                            | Find-CsOnlineApplicationInstance | Finds Resource Accounts based on provided SearchString                                                      |
| `Get-TeamsResourceAccount`    | Get-TeamsRA                                             | Get-CsOnlineApplicationInstance  | Queries Resource Accounts based on input: SearchString, Identity (UserPrincipalName), PhoneNumber, Type     |
| `Set-TeamsResourceAccount`    | Set-TeamsRA                                             | Set-CsOnlineApplicationInstance  | Changes settings for a Resource Accounts, applying UsageLocation, Licenses and Phone Numbers, swapping Type |
| `Remove-TeamsResourceAccount` | Remove-TeamsRA, <br/>Remove-CsOnlineApplicationInstance | Remove-AzureAdUser               | Removes a Resource Account and optionally (with -Force) also the Associations this account has.             |

### Resource Account Association

| Function                                 | Alias               | Underlying Function                           | Description                                                                                          |
| ---------------------------------------- | ------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccountAssociation`    | New-TeamsRAAssoc    | New-CsOnlineApplicationInstanceAssociation    | Links one or more Resource Accounts to a Call Queue or an Auto Attendant                             |
| `Get-TeamsResourceAccountAssociation`    | Get-TeamsRAAssoc    | Get-CsOnlineApplicationInstanceAssociation    | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants. Also shows Status |
| `Remove-TeamsResourceAccountAssociation` | Remove-TeamsRAAssoc | Remove-CsOnlineApplicationInstanceAssociation | Removes a link for one or more Resource Accounts                                                     |

### Call Queues

Microsoft has selected a GUID as the Identity the `CsCallQueue` scripts are a bit cumbersome. The Searchstring parameter is available, and utilised as a basic input method for `TeamsCallQueue` CmdLets. They query by *DisplayName*, which comes with a drawback for the `Set`-command: It requires a unique result. Also uses Filenames instead of IDs when adding Audio Files. <br/>Hope these make managing Call Queues easier.

| Function                | Alias          | Underlying Function | Description                                                        |
| ----------------------- | -------------- | ------------------- | ------------------------------------------------------------------ |
| `New-TeamsCallQueue`    | New-TeamsCQ    | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Get-TeamsCallQueue`    | Get-TeamsCQ    | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| `Set-TeamsCallQueue`    | Set-TeamsCQ    | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Remove-TeamsCallQueue` | Remove-TeamsCQ | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

### Auto Attendants

The complexity of the AutoAttendants and design principles of PowerShell ("one function does one thing and one thing only") means that the `CsAutoAttendant` CmdLets are a bit cumbersome. Multiple CmdLets have to be used in conjunction in order to create an Auto Attendant. No defaults are available. The `TeamsAutoAttendant` CmdLets try to address that. From the basic NEW-Command that - without providing *any* Parameters (except the name of course) can create an Auto Attendant entity. This simplifies things a bit and tries to get you 80% there without lifting much of a finger. Amending it afterwards in the Admin Center is my current mantra.

| Function                    | Alias          | Underlying Function         | Description                                                                                  |
| --------------------------- | -------------- | --------------------------- | -------------------------------------------------------------------------------------------- |
| `New-TeamsAutoAttendant`    | New-TeamsAA    | New-CsTeamsAutoAttendant    | Creates an Auto Attendant with defaults (Disconnect, Standard Business Hours schedule, etc.) |
| `Get-TeamsAutoAttendant`    | Get-TeamsAA    | Get-CsTeamsAutoAttendant    | Queries an Auto Attendant                                                                    |
| Set-TeamsAutoAttendant      | Set-TeamsAA    | Set-CsTeamsAutoAttendant    | Changes an Auto Attendant with friendly inputs (Not Built yet. Need to design first!)        |
| `Remove-TeamsAutoAttendant` | Remove-TeamsAA | Remove-CsTeamsAutoAttendant | Removes an Auto Attendant from the Tenant                                                    |

#### Auto Attendant Support Functions

The complexity of the AutoAttendants and design principles of PowerShell ("one function does one thing and one thing only") means that to create objects connected to Auto Attendants have spawned a few support functions. Keeping in step with them and simplifying their use a bit is what my take on them represents.

| Function                               | Alias                | Underlying Function                    | Description                                                                                                                                                     |
| -------------------------------------- | -------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `New-TeamsAutoAttendantDialScope`      | New-TeamsAADialScope | New-CsTeamsAutoAttendantDialScope      | Creates a `DialScope` Object given Office 365 Group Names                                                                                                       |
| `New-TeamsAutoAttendantPrompt`         | New-TeamsAAPrompt    | New-CsTeamsAutoAttendantPrompt         | Changes a `Prompt Object` based on String input alone (decides whether the string is a file name or a Text-to-Voice String)                                     |
| `New-TeamsAutoAttendantSchedule`       | New-TeamsAASchedule  | New-CsTeamsAutoAttendantSchedule       | Changes a `Schedule Object` based on selection (many options available). THIS is missing from Auto Attendants                                                   |
| `New-TeamsAutoAttendantCallableEntity` | New-TeamsAAEntity    | New-CsTeamsAutoAttendantCallableEntity | Creates a `Callable Entity` Object given a Type and CallTarget (also doubles as a verification Script for Call Queues)                                          |
| `Get-TeamsAutoAttendantCallableEntity` | Get-TeamsAAEntity    | N/A (new)                              | Creates a new Object emulating the output of a `Callable Entity`. Also usable for Call Queues, this validates the Object type and its usability for CQs or AAs. |

### Lookup Commands

The more prominent helper functions. Get-AzureAdAssignedAdminRoles is run with `Connect-Me`, but can be used on its own just as well. The others are mainly helping to cut down on typing when doing stuff quickly. Using `Get-AzureAdUser -Searchstring "$UPN"` is fine, but sometimes I just want to bash in the $UPN and get a result. Other times knowing just enough is enough. Like knowing only the names of the Tenant Dial Plan or the Online Voice Routing Policy in question is just what I need, nothing more.

| Function                        | Description                                                                                               |
| ------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `Get-AzureAdAssignedAdminRoles` | Displays all Admin Roles assigned to an AzureAdUser                                                       |
| `Find-AzureAdUser`              | Helper Function to find AzureAd Users. Returns Objects if found. Simplifies Lookup and Search of Objects  |
| `Find-AzureAdGroup`             | Helper Function to find AzureAd Groups. Returns Objects if found. Simplifies Lookup and Search of Objects |
| `Get-TeamsTenant`               | Get-CsTenant gives too much output? This can help.                                                        |
| `Get-TeamsOVP`                  | Get-CsOnlineVoiceRoutingPolicy is too long to type. Here is a shorter one :)                              |
| `Get-TeamsTDP`                  | Get-TeamsTenantDialPlan is too long to type. Also, we only want the names...                              |
| `Get-TeamsObjectType`           | Returns the type of any given Object to identify its use in CQs and AAs.                                  |

### Backup and Restore

Curtesy of Ken Lasko

| Function             | Description                                                                                   |
| -------------------- | --------------------------------------------------------------------------------------------- |
| `Backup-TeamsEV`     | Takes a backup of all EnterpriseVoice related features in Teams.                              |
| `Restore-TeamsEV`    | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care! |
| `Backup-TeamsTenant` | An adaptation of the above, backing up the whole tenant in the process.                       |

### Other functions

| Function                                 | Description                                                                                                            |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `Assert-AzureAdConnection`               | Tests connection and visual feedback.                                                                                  |
| `Assert-MicrosoftTeamsConnection`        | Tests connection and visual feedback.                                                                                  |
| `Assert-SkypeOnlineConnection`           | Tests connection and visual feedback. **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*         |
| `Format-StringRemoveSpecialCharacter`    | Formats a String and removes special characters (harmonising Display Names)                                            |
| `Format-StringForUse`                    | Formats a String and removes special characters for DisplayNames, UserPrincipalNames, LineUri or E.164 Number formats. |
| `Get-SkuIdFromSkuPartNumber`             | Helper function for Licensing. Returns a SkuID from a specific SkuPartNumber                                           |
| `Get-SkuPartNumberFromSkuId`             | Helper function for Licensing. Returns a SkuPartNumber from a specific SkuID                                           |
| `Get-SkypeOnlineConferenceDialInNumbers` | Gathers Dial-In Conferencing Numbers for a specific Domain                                                             |
| `Import-TeamsAudioFile`                  | Imports an Audio File for use within Call Queues or Auto Attendants                                                    |
| `Remove-TenantDialPlanNormalizationRule` | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove                               |
| `Set-TeamsUserPolicy`                    | Assigns specific Policies to a User  (Currently only six policies available)                                           |
| `Write-ErrorRecord`                      | Helper function for Troubleshooting and to display Errors in a more readable format and in the Output stream           |

#### Test & Assert Functions

These are helper functions for testing Connections and Modules. All Functions return boolean output.

| Function                        | Description                                                                                |
| ------------------------------- | ------------------------------------------------------------------------------------------ |
| `Test-AzureAdConnection`        | Verifying a Session to AzureAD exists                                                      |
| `Test-MicrosoftTeamsConnection` | Verifying a Session to MicrosoftTeams exists                                               |
| `Test-SkypeOnlineConnection`    | Verifying a Session to SkypeOnline exists                                                  |
| `Test-ExchangeOnlineConnection` | Verifying a Session to ExchangeOnline exists                                               |
| `Test-Module`                   | Verifying the specified Module is loaded                                                   |
| `Test-AzureAdUser`              | Testing whether the User exists in AzureAd (this also returns TRUE for Resource Accounts!) |
| `Test-AzureAdGroup`             | Testing whether the Group exists in AzureAd                                                |
| `Test-TeamsResourceAccount`     | Testing whether a Resource Account exists in AzureAd                                       |
| `Test-TeamsUser`                | Testing whether the User exists in SkypeOnline/Teams                                       |
| `Test-TeamsUserLicense`         | Testing whether the User has a specific Teams License (from $TeamsLicenses)                |
| `Test-TeamsUserHasCallPlan`     | Testing whether the User has any Call Plan License (from $TeamsLicenses)                   |
| `Test-TeamsTenantPolicy`        | Tests whether any Policy is present in the Tenant (Uses Invoke-Expression)                 |
| `Test-TeamsExternalDNS`         | Tests DNS Records for Skype for Business Online and Teams                                  |

NOTE: Private functions are not exported and also not listed here.

***

## Change Log

Please see VERSION.md for a detailed breakdown of the Change log.

- Changes for Pre-Releases are 'hidden' in the Module documentation for now
- Changes for Releases have wandered into VERSION.md

***

## Looking ahead

### Current issues

- Figuring out Pester, Writing proper Test scenarios
- Continuous Improvement and Bugfixing for BETA Functions

### Update/Extension plans

- Adding all Policies to `Set-TeamsUserPolicy` - currently only 6 are supported.
- Performance improvements, bug fixing and more testing
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- Testing
  - Currently, only limited Pester tests are available for the Module and select functions.
  - No Pester tests exist for Functions that require a Session to AzureAd or SkypeOnline - I cannot figure them out yet.
  - All Testing is done with VScode and my trusty ISESteroids.
- Functions
  - `Connect-SkypeOnline` still seems to be timing out, despite `Enable-CsOnlineSessionForReconnection` being run - Recent improvements should stabilise these now, but I will still test them more thoroughly.&nbsp; <br/>**UPDATE**: v20.08 should hopefully be able to alleviate this. - Reconnection attempt is taken if connection is broken.
  - `CallQueue` Scripts are nearing RC status. The functionality is tested and working but we might yet find bugs for them.
  - `AutoAttendant` Scripts not fully tested yet. They have improved a lot, but are still BETA - Handle with Care!
  - I try to build my scripts so that they are very talkative, if you get stuck, `-Verbose` should be able to help

*Enjoy,*

David
