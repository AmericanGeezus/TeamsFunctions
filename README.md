# Teams Scripts and Functions

## Available Functions

### Connections

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them is not implemented very nicely. The following is trying to make this simpler and provide an easier way to connect:

| Function                      | Description                                                                                              |
| ----------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Connect-SkypeOnline`         | Creates a Session to SkypeOnline (v7 also extends TimeOut Limit!)                                        |
| `Connect-SkypeTeamsAndAAD`    | Creates a Session to SkypeOnline, MicrosoftTeams and AzureAD in one go (one authentication prompt only!) |
| `Disconnect-SkypeOnline`      | Disconnects from a Session to SkypeOnline                                                                |
| `Disconnect-SkypeTeamsAndAAD` | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD                                 |

Aliases are available for `Connect-SkypeTeamsAndAAD`: `Connect-Me` or even shorter: `con` - To run disconnect, `Disconnect-Me` or `dis` :)

#### Test Functions for Connection

These are helper functions for testing Connections and Modules

| Function                        | Description                                  |
| ------------------------------- | -------------------------------------------- |
| `Test-AzureAdConnection`        | Verifying a Session to AzureAD exists        |
| `Test-MicrosoftTeamsConnection` | Verifying a Session to MicrosoftTeams exists |
| `Test-SkypeOnlineConnection`    | Verifying a Session to SkypeOnline exists    |
| `Test-ExchangeOnlineConnection` | Verifying a Session to ExchangeOnline exists |
| `Test-Module`                   | Verifying the specified Module is loaded     |

### Licensing Functions

Functions for licensing in AzureAD. Hopefully simplifies license application a bit

| Function                   | Description                                                                                                                                                                                                                      |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Get-TeamsTenantLicense`   | Queries licenses present on the Tenant. Output needs improving (Objectification)                                                                                                                                                 |
| `Get-TeamsUserLicense`     | Queries licenses assigned to a User and displays visual output                                                                                                                                                                   |
| `Test-TeamsUserLicense`    | Tests an individual Service Plan or a License Package against the provided Identity                                                                                                                                              |
| `Add-TeamsUserLicense`     | Adds one or more Licenses specified per Switch to the provided Identity (deprecated)                                                                                                                                             |
| `Set-TeamsUserLicense`     | Adds one or more Licenses specified in an Array to the provided Identity.  Removes one or more Licenses specified through an Array to the provided Identity. Removes all Licenses from the Object. Replaces Add-TeamsUserLicense |
| `New-AzureAdLicenseObject` | Creates a License Object for application. Generic helper function.                                                                                                                                                               |

### Resource Accounts

As Microsoft has selected a GUID as the Identity the `CsOnlineApplicationInstance` scripts are a bit cumbersome. IDs are also used for the Application Type. These Scripts are wrapping around and are bound to the *UserPrincipalName* instead of the Identity.

| Function                      | Underlying Function              | Description                                                                                                                                       |
| ----------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccount`    | New-CsOnlineApplicationInstance  | Creates a Resource Account in Teams (CsOnlineApplicationInstance)                                                                                 |
| `Find-TeamsResourceAccount`   | Find-CsOnlineApplicationInstance | Finds Resource Accounts based on provided SearchString                                                                                            |
| `Get-TeamsResourceAccount`    | Get-CsOnlineApplicationInstance  | Queries Resource Accounts based on input: SearchString, Identity (UPN), PhoneNumber, Type (Call Queue or Auto Attendant)                          |
| `Set-TeamsResourceAccount`    | Set-CsOnlineApplicationInstance  | Changes settings for a Resource Accounts, swapping License (doesn't work right now...), Type (experimental, 'should work' according to Microsoft) |
| `Remove-TeamsResourceAccount` | Remove-AzureAdUser               | Removes a Resource Account and optionally (with -Force) also the Associations this account has.                                                   |

### Account Association

| Function                                 | Underlying Function                                                                          | Description                                                                       |
| ---------------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `New-TeamsResourceAccountAssociation`    | New-CsOnlineApplicationInstanceAssociation                                                   | Links one or more Resource Accounts to a Call Queue or an Auto Attendant          |
| `Get-TeamsResourceAccountAssociation`    | Get-CsOnlineApplicationInstanceAssociation, Get-CsOnlineApplicationInstanceAssociationStatus | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants |
| `Remove-TeamsResourceAccountAssociation` | Remove-CsOnlineApplicationInstanceAssociation                                                | Removes a link for one or more Resource Accounts                                  |

### Call Queues

Bound to the Display Name rather than the Identity/GUID these aim to make managing Call Queues easier.

| Function                | Underlying Function | Description                                                        |
| ----------------------- | ------------------- | ------------------------------------------------------------------ |
| `New-TeamsCallQueue`    | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Get-TeamsCallQueue`    | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| `Set-TeamsCallQueue`    | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Remove-TeamsCallQueue` | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

### Backup and Restore

Curtesy of Ken Lasko

| Function             | Description                                                                                   |
| -------------------- | --------------------------------------------------------------------------------------------- |
| `Backup-TeamsEV`     | Takes a backup of all EnterpriseVoice related features in Teams.                              |
| `Restore-TeamsEV`    | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care! |
| `Backup-TeamsTenant` | An adaptation of the above, backing up the whole tenant in the process.                       |

### Other functions

| Function                                 | Description                                                                              |
| ---------------------------------------- | ---------------------------------------------------------------------------------------- |
| `Set-TeamsUserPolicy`                    | Assigns specific Policies to a User  (Currently only six policies available)             |
| `Test-TeamsTenantPolicy`                 | Tests whether any Policy is present in the Tenant (Uses Invoke-Expression)               |
| `Get-SkypeOnlineConferenceDialInNumbers` | Gathers Dial-In Conferencing Numbers for a specific Domain                               |
| `Remove-TenantDialPlanNormalizationRule` | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove |
| `Test-TeamsExternalDNS`                  | Tests DNS Records for Skype for Business Online and Teams                                |
| `Test-TeamsUser`                         | Testing whether the User exists in SkypeOnline/Teams                                     |
| `Test-AzureAdUser`                       | Testing whether the User exists in AzureAd                                               |
| `Test-AzureAdGroup`                      | Testing whether the Group exists in AzureAd                                              |

***

## Looking ahead

### Current issues

- Figuring out Pester, Writing proper Test scenarios
- Bugfixing for BETA Functions (`TeamsCallQueue`)

### Update/Extension plans

- Adding all Policies to `Set-TeamsUserPolicy` - currently only 6 are supported.
- Simplifying creation and provisioning of Resource Accounts for Call Queues and Auto Attendants
- Performance improvements, bug fixing and more testing
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- Testing
  - Currently, no Pester tests exist for this Module. - I cannot figure them out yet.
  - All Testing is done with my trusty ISEsteroids.
- Functions
  - `Connect-SkypeOnline` still seems to be timing out, despite `Enable-CsOnlineSessionForReconnection` being run - Recent improvements should stabilise these now, but I will still test them more thoroughly.&nbsp; **UPDATE**: v20.08 should hopefully be able to alleviate this. - Reconnection attempt is taken if connection is broken.
  - Scripts for **Call Queue Handling** are not fully tested yet. They have improved a lot, but are still BETA - Handle with Care!
  - I try to build my scripts so that they are very talkative, if you get stuck, `-Verbose` should be able to help

*Enjoy,*

David

***
Change Log

## v20.08 - August 2020 Release

July was "quiet" because I only published pre-releases with bugfixes (mostly). Here the full log:

- **New: Teams Licensing Application**
  - `Set-TeamsUserLicense` - Replacement function for Add-TeamsUserLicense (which now is deprecated). Add or Remove Licenses with an array. Accepted values are found in the accompanying variable `$TeamsLicenses.ParameterName`
  - Added Variables containing all relevant information for `$TeamsLicenses`(38!) and `$TeamsServicePlans`(13). They are threaded into the TeamsUserLicense CmdLets as well as Get-TeamsTenantLicense. Translating a friendly Name (Property `ParameterName`, `FriendlyName`& `ProductName`) to the `SkuPartNumber`or `SkuID`is what I am trying to bridge (who wants to remember a 36 digit GUID for each Product?)
  - Accompanying this, changes to `Get-TeamsUserLicense` have been made to report a uniform feedback of Licenses (based on the same variable)
  - `Get-TeamsTenantLicense` (replaces Get-TeamsTenantLicense**s**) has been completely reworked. A
- **New: Teams Call Queue Handling**
  - Added SharedVoicemail-Parameters are processed for `New-TeamsCallQueue` and `Set-TeamsCallQueue`
  - **New**: `Import-TeamsAudioFile` - Generic helper function for Importing Audio Files. Returnes ID of the File for processing. TeamsCallQueue CmdLets are using it.
- **Changed: Default behaviour of Scripts that require a valid Session to SkypeOnline**
  - This now has changed from *REQUIRE VALID SESSION (ERROR)* to *TRYING TO RECONNECT (VERBOSE)*. This was made possible by the quality work of the Exchange-Team (publishing [Module ExchangeOnlineManagement](https://www.powershellgallery.com/packages/ExchangeOnlineManagement/1.0.1)) which inspird me to deploy the same for Scripts that require connections to SkypeOnline
  - All CmdLets that can try a reconnect (SkypeOnline and ExchangeOnline) will try. This is done with Get-CsTenant and Get-UnifiedGroup respectively.
  - NOTE: AzureAD and MicrosoftTeams should not time out and therefore do not need to be reconnected to.
  - `Connect-SkypeTeamsAndAAD` (`Connect-Me` for short) now supports a connection to Exchange, though manually to select with the Switch `-ExchangeOnline`.
- **Improved: Behind the scenes improvements and Performance**
  - Proper application of `ShouldProcess` for all State Changing Functions
  - Performance for all `Test`-Cmdlets (and some `Get`-CmdLets)
  - Verification for Sessions
- **Fixed**:
  - Plenty of Bugs squashed for `TeamsCallQueue` CmdLets (Plenty more to come, I am sure)
  - Fixes applied for `TeamsResourceAccount` Scripts - These have now lost the BETA-Moniker and are live :)

We are now in line with all but a few recommendations from PS Script Analyzer. Invoke-Expression is still in there, but now wrapped in a ShouldProcess should you need it.

This modules row count is OVER 9000! ;)

## v20.6.29.1

added Resouce Account Association Scripts

- Updated this ReadMe.MD - About time, I agree :grin:
- More improvements curtesy of PSScriptanalyzer
  - Added **ShouldProcess** for all State changing functions.
  - Created new Snippets for the **Begin**-Block in order to support proper application of  `$ConfirmPreference`, `$WhatIfPreference` and `$VerbosePreference` for Functions that are calling the ones in this Module (will adhere to the values if defined)
  - Added proper application of **-Force** switchs in conjunction with the above
- Added Scripts to connect Resource Accounts to Call Queues or Auto Attendants. These are fully tested and functional
  - `New-TeamsResourceAccountAssociation`
  - `Get-TeamsResourceAccountAssociation`
  - `Remove-TeamsResourceAccountAssociation`

Making a tactical halt here to add some Pester tests (once I figure them out :))

*Celerating 7500 lines of code* :pensieve:

## v20.6.22.0

- More Improvements for Resource Accounts Scripts - LIVE
- More Improvements for Call Queue Scripts - Still BETA
- Added `Find-TeamsResourceAccount` to complete the set and remove some complexity from the GET-Command. It works similar, though the output is more detailed then its equivalent (Find-CsOnlineApplicationInstance)
- Incorporating Script Analyzer and starting to implement some suggestions:
- Renamed Remove-StringSepcialCharacter to `Format-StringRemoveSpecialCharacter`

## v20.6.17.1

- More Improvements for Resource Accounts Scripts - Still BETA
- More Improvements for Call Queue Scripts - Still BETA
- Added helper function `Write-ErrorRecord` to improve the output for Error Messages in a more readable format.

## v20.6.9.1

- Added `Get-AzureADUserFromUPN` to simplify looking up Users in AzureAD by providing the UserPrincipalName
- Added Call Queue Scripts
  - `New-CsCallQueue`
  - `Get-CsCallQueue`
  - `Set-CsCallQueue`
  - `Remove-CsCallQueue`
- Helper functions for Call Queues
  - Renamed Test-AzureAdObject to `Test-AzureAdUser`
  - Added `Test-AzureAdGroup`
  - Added `Test-TeamsUser`
- Removed Module testing scripts and replaced them with a generic `Test-Module`

## v20.5.24.2

- Improved Resource Accounts by employing Parameter splatting. Much better now, faster too! Continuing to testing the scripts, still in BETA.

- Improvements for Licensing Functions: Added `PhoneSystem_VirtualUser`-License to the portfolio
- Exposed Helper Functions to translate SkuID to Sku Part Number and vice versa
  - `New-AzureAdLicenseObject` - Creates a new License Object to be used with `Set-AzureADUserLicense`
  - `Get-SkuPartNumberFromSkuId` - Tiny little helper translating SkuPartNumber (License Name) to their SkuID
  - `Get-SkuIdfromSkuPartNumber` - Tiny little helper translating SkuID to their SkuPartNumber (License Name)
- Improved Test functions for Module (speed!) and Connection (consistency)
- Added test functions for Module and Connection consistently to all functions that need it.

## v20.5.19.2

- Added Resource Account Scripts - in BETA.
  - `New-TeamsResourceAccount`
  - `Get-TeamsResourceAccount`
  - `Set-TeamsResourceAccount`
  - `Remove-TeamsResourceAccount`

- Added Backup Scripts by [Ken Lasko](https://www.ucdialplans.com)

- Added Script to find AzureAD Admin Roles assigned to a User
  - `Get-AzureAdAssignedAdminRoles` - Queries Admin Roles assigned to one User (UPN). Somehow that wasn't as easy to do...

- Added Helper Functions for reformatting Strings
  - `Remove-StringSpecialCharacter` - By Francois-Xavier Cat. Removes special characters from strings. Incorporated here only because I need to rely on it.
  - `Format-StringForUse` - Same as above, though my own approach based on an anonymous coder. Applies rules for DisplayName and UPN respectively.

## v20.5.9.1

Revamping existing scripts. No Addiotns.

## v20.5.3.1

TeamsFunctions. A module. A way to collect relevant Scipts and Functions for Administration of SkypeOnline (Teams Backend), Voice and Direct Routing, Resource Accounts, Call Queues, etc.

### Origins

This module is a collection of Teams-related PowerShell scripts and functions based on [**SkypeFunctions** by Jeff Brown](https://github.com/JeffBrownTech/Skype). Please show your love. This is published separately (and with permission) rather than updated because I couldn't figure out Forks and Pull-Requests and by the time I had, I had substantially altered the code...

The first goal was to refresh what needs adding (for example, License names for Microsoft 365). The second goal was to learn and understand PowerShell better and test all Functions for applicability in Teams. Once vetted, some functions have been renamed from "SkypeOnline" to "Teams" (others, like the "Connect"-scripts have been retained).

### Current Scope

Becoming the Go-To Module for Teams Provisioning. Be that Enterprise Voice (Direct Routing),  Licensing, Policy Assignment, etc.

General Administration tasks, like Backup and Restore round up the offering

### Planned Scope

As this develops, I try to incorporate more and more to manage and maintain your Teams Tenant.
Anything related to Voice functionality has priority, Resource Accounts and Call Queues being the first.
(Auto Attendants will have to be evaluated, as they are very complex and require multiple single steps from File management to Schedules, Call Flows etc. Scripts, if started need to solve a particularly nasty issue or simplify steps by verifying and combining steps.)

Scripts related to creating Direct Routing implementation are present already, but created in Excel which I cannot currently transfer easily to a better PS script. I am working on `*-TeamsUserForVoice` cmdlets, but they will still take some time.

Next project will be bulk-provisioning. All functions are designed to work with pipeline input, next step will be reading this from CSV or XLSX, for people writing functions around this, please check out [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel) (the successor to PSExcel) which will help you tremendously

### Contributions welcome

If you have a script or a function that could cover something I mentioned or solves a particular problem when working with Teams, I am happy to host it and integrate here. Happy to collaborate as well. I am grateful for every small addition to the Module. :)

### Dependencies

> Module **AzureAd** - Heavily integrated into Azure Active Directory, we are relying on `Connect-AzureAd` to establish a connection and use the Licensing Scripts of AzureAd V2
> Module **MicrosoftTeams** - The connect Scripts are relying on `Connect-MicrosoftTeams` to establish a connection to Microsoft Teams.

### Functions

- Connecting, Disconnecting and Testing PowerShell Sessions to SkypeOnline, Teams and AzureAD
- Licensing of Users, Resource Accounts, etc. with focus for Teams
- Managing Resource Accounts
- Managing Resource Account connection to Call Queues or Auto Attendants
- Managing Call Queues
- Backup & Restore for Voice (with thanks to [Ken Lasko](https://www.ucdialplans.com)) expanded to cover the whole Tenant
- Additional functions
  - Policies
  - Dial-in Conferencing
  - Dial Plans & Normalisation rules
  - etc.

Enjoy

***
