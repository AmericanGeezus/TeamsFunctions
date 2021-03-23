# TeamsFunctions - Change Log

Full Change Log for all major releases.
Pre-releases are documented in VERSION-PreRelease.md and will be transferred here monthly in cadence with the release cycle

## v21.03 - March 2021 release

### Component Status

|           |                                                                                                                                                                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Functions | ![Public](https://img.shields.io/badge/Public-82-blue.svg) ![Private](https://img.shields.io/badge/Private-8-grey.svg) ![Aliases](https://img.shields.io/badge/Aliases-42-green.svg)                                                          |
| Status    | ![Live](https://img.shields.io/badge/Live-71-blue.svg) ![RC](https://img.shields.io/badge/RC-5-green.svg) ![BETA](https://img.shields.io/badge/BETA-0-yellow.svg) ![ALPHA](https://img.shields.io/badge/ALPHA-0-orange.svg)  ![Unmanaged](https://img.shields.io/badge/Unmanaged-6-grey.svg)                  |
| Pester    | ![Passed](https://img.shields.io/badge/Passed-1118-blue.svg) ![Failed](https://img.shields.io/badge/Failed-0-red.svg) ![Skipped](https://img.shields.io/badge/Skipped-0-yellow.svg) ![NotRun](https://img.shields.io/badge/NotRun-0-grey.svg) |
| Focus | MicrosoftTeams v2, Bugfixing, Licensing |

### Focus for this month

- Transition to Module MicrosoftTeams (v2.0.0) - Connect-MicrosoftTeams now also connects to SkypeOnline by default
- Bugfixing

### Requirements

- PowerShell v5.1
- Module `AzureAd` **or** `AzureAdPreview` (PIM Functions only available with AzureAdPreview)
- Module MicrosoftTeams in Version 2.0.0 (new!)

### Caveat

Switching to a new way of connecting was easy, though due to lack of information I do not know what else may have changed (or whether all cmdlets have been imported as-is)
"Here be dragons" until I could test all functions. If you find behaviour that is not consistent with the expected stated output in the documentation, please raise an issue.

### Changes

- `Get-AzureAdLicense`: Corrected an issue with display of Licenses
- `Set-AzureAdLicense` and `Set-AzureAdLicenseServicePlan` - Changed to reflect changes to Licensing website
- `Get-TeamsResourceAccount`: Added `InterpretedUserType` to Output Object
- `New-TeamsResourceAccount`: Addressed an issue with finding RA after creation
- `New-TeamsResourceAccountAssociation`: Caught an error if the RA is not found. Script is now halting correctly and erroring only once.
- `Set-TeamsCommonAreaPhone`: Added switch Passthru to parameter list
- Corrected identity queries and added Identity switch and quotes around the Identity
- `Get-TeamsTenantLicense`: Added debug output for counters
- `Get-TeamsUserVoiceConfig`: Corrected parameternames of `TeamsCallingPolicy` and `CallerIdPolicy` (Level 2 lookup)
- `Set-TeamsUserVoiceConfig`: Added a catch for dirsynced users.
- `Connect-Me`: Removed SkypeOnline as an option. Cleaned up connection steps
- `Test-MicrosoftTeamsConnection`: Replaced tests with (faster) tests by `Test-SkypeOnlineConnection`

### Removed Functions

- `Connect-SkypeOnline` - With the removal of New-CsOnlineSession and superceded by Connect-MicrosoftTeams, this CmdLet is now retired
- `Enable-CsOnlineSessionForReconnection` - It has had a short life in this module, but it too is now no longer needed.
- `Test-SkypeOnlineConnection` - The meat of the script lives on in `Test-MicrosoftTeamsConnection` as it does provide the same mechanics (PSSession)
- `Disconnect-SkypeOnline` - This too does not need to be provided anymore

## v21.02 - February 2021 release

### Component Status

|           |                                                                                                                                                                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Functions | ![Public](https://img.shields.io/badge/Public-87-blue.svg) ![Private](https://img.shields.io/badge/Private-8-grey.svg) ![Aliases](https://img.shields.io/badge/Aliases-42-green.svg)                                                          |
| Status    | ![Live](https://img.shields.io/badge/Live-76-blue.svg) ![RC](https://img.shields.io/badge/RC-5-green.svg) ![BETA](https://img.shields.io/badge/BETA-0-yellow.svg) ![ALPHA](https://img.shields.io/badge/ALPHA-0-orange.svg)  ![Unmanaged](https://img.shields.io/badge/Unmanaged-6-grey.svg)                  |
| Pester    | ![Passed](https://img.shields.io/badge/Passed-1181-blue.svg) ![Failed](https://img.shields.io/badge/Failed-0-red.svg) ![Skipped](https://img.shields.io/badge/Skipped-0-yellow.svg) ![NotRun](https://img.shields.io/badge/NotRun-0-grey.svg) |
| Focus | Bugfixing, TeamsCommonAreaPhone |

### Focus for this month

- Transition from Module SkypeOnlineConnector to MicrosoftTeams - Complete
- Bugfixing

### Requirements

- PowerShell v5.1
- Module `AzureAd` **or** `AzureAdPreview` (PIM Functions only available with AzureAdPreview)
- Module MicrosoftTeams in Version 1.1.6

### New

- `Enable-CsOnlineSessionForReconnection`: Thanks to the original Author, [Andrés Gorzelany](https://github.com/get-itips), this function, originally shipped with the SkypeOnlineConnector Module, has made it into this module. We are able to reconnect sessions again, even when using the Module MicrosoftTeams
- Added Markdown help for all Public Functions in [/docs](/docs)
- external
- Added Markdown about_-help for all major topics in this Module in [/help](/help)
- Added Global Variables for some longer running Scripts (for example, Licenses, AzureAdGroups, etc.)
- Information Output added to multiple CmdLets

### Updated

- `Connect-Me`:
  - Complete rework to remove double-usability with SkypeOnlineConnector
  - Removed Switches for individual connections. Sessions to AzureAd, MicrosoftTeams and SkypeOnline are always established
  - Switch ExchangeOnline is still there should it be needed as well.
  - Removed Module verification for MicrosoftTeams as it is now a requirement on the Module itself.
  - Module AzureAdPreview is still optional. If available, Enablement for PIM Admin Roles is tried
  - Improved feedback with Information Output instead of forced Verbosity
- `Connect-SkypeOnline`:
  - Complete rework to remove usability with SkypeOnlineConnector (module is now unloaded cleanly)
  - If connection to AzureAd already exists, OverrideAdminDomain will be taken from there.
  - `Enable-CsOnlineSessionForReconnection` is now always available and will be run
  - Improved feedback with Information Output instead of forced Verbosity
- `Assert-Module`: Reimagining Test-Module. Now also validates Latest Version and latest pre-release. Might add checking for specific version if needed, but not right now.
- `Get-TeamsAutoAttant`: Fine-Tuned output
- `New-TeamsCallQueue` and `Set-TeamsCallQueue`:
- `Find-TeamsUserVoiceConfig`: Improved lookup for Phone Numbers
- `Find-AzureAdUser`: Complete rework. Now properly extends Get-AzureAdUser -SearchString
- Revamped all Get-Helpers for OVR,OPU,OVP, etc.
- Bugfixes across the board!
- Enabled Pipelining for multiple functions.
- Updated help for all Functions and added Pester tests for Help files

## v21.01 - January 2021 release

### Component Status

- Function Status:
![Public](https://img.shields.io/badge/Public-86-blue.svg)
![Private](https://img.shields.io/badge/Private-6-grey.svg)
![Live](https://img.shields.io/badge/Live-43-blue.svg)
![PreLive](https://img.shields.io/badge/PreLive-39-green.svg)
![RC](https://img.shields.io/badge/RC-16-yellow.svg)
![BETA](https://img.shields.io/badge/BETA-0-orange.svg)
![ALPHA](https://img.shields.io/badge/ALPHA-4-red.svg)
![Deprecated](https://img.shields.io/badge/Deprecated-3-grey.svg)
- Pester Test Status: Tests Passed: 988, Failed: 0, Skipped: 0 NotRun: 0
- `TeamsAutoAttendant` Scripts have advanced to RC status.
- `TeamsCallableEntity` Scripts have been improved upon (GET, FIND, NEW and ASSERT)
- `AzureAdAdminRole` Scripts have been introduced upon (GET and ENABLE)
- `TeamsCommonAreaPhone` Scripts have been introduced in RC status.

### Focus for this month

- Transition from Module SkypeOnlineConnector to MicrosoftTeams
- More Auto Attendant functions and better structure to create value on top of existing scripts.
- Better support of sub-functions through Callable Entities
- Support for Privileged Identity Management
- Better Regex: Identification and normalisation of Phone Numbers
- Some Classes have been added to the Module for more consistency.
- Getting to grips with the Call stack - some functions now behave slightly differently (in output) if called by another function
- More Pipeline support, PassThru support, etc.
- Performance updates

### Requirements

- This Module currently only `#Requires` PowerShell v5.1, but
- Module `AzureAd` **or** `AzureAdPreview` are required
- Module `MicrosoftTeams` (v1.1.6 or higher) **or** `SkypeOnlineConnector` (v7) are required.

### New Functions

- **Introducing Support for Privileged Identity Management (if Module AzureAdPreview is installed):**
  - `Get-AzureAdAdminRole`:
    - Used in Connect-Me (and replaces Get-AzureAdAssignedAdminRoles, which was slow)
    - Queries currently active Admin Roles by default
    - Queries eligible Admin Roles with `-Type` (requires AzureAdPreview)
  - `Enable-AzureAdAdminRole`:
    - Simplifying Admin Role enablement for Users
    - Used in Connect-Me
    - Can be used to enable individual Roles (with `-Confirm`) or all eligible
    - NOTE: Currently does not support Privileged Admin Groups
- **New Common Area Phone CmdLets:**
  - `Get-TeamsCommonAreaPhone`: Queries an AzureAdUser and displays parameters relevant to Common Area Phones
  - `New-TeamsCommonAreaPhone`: Creates an AzureAdUser for use as a Common Area Phone. Also applies CommonAreaPhone License if not specified differently
  - `Remove-TeamsCommonAreaPhone`: Removes an AzureAdUser
  - `Set-TeamsCommonAreaPhone`: Changes a Common Area Phone Object (AzureAdUser and CsOnlineUser).
- **Expanding on the CallableEntity concept:**
  - `Assert-TeamsCallableEntity`: Verifies a User is ready to be used as a Call Target or Callable Entity (incl. enablement for Enterprise Voice)
  - `Find-TeamsCallableEntity`: Queries Call Queues and Auto Attendants for a User to be attached to.
  - `Get-TeamsCallableEntity`: Determines the type of Callable Entity to feed into other functions
  - `New-TeamsCallableEntity` (New-TeamsAutoAttendantCallableEntity, New-TeamsAAEntity): Creates a callable Entity for Auto Attendants (renamed and improved)
- **Completing the Set for AutoAttendants:**
  - `New-TeamsAutoAttendantCallFlow` (New-TeamsAAFlow): Call Flow Object with default options
  - `New-TeamsAutoAttendantMenu` (New-TeamsAAMenu): Menu Object with default options
  - `New-TeamsAutoAttendantMenuOption` (New-TeamsAAOption): Menu Option Object with default options
  - `New-TeamsAutoAttendantCallHandlingAssociations` is an Alias to complete the set, but a standalone function was not required.
- **Voice Functions Lookup Suite** has been extended and updated to display names only  (if more than 2 have been found)
  - `Find-TeamsUserVoiceRoute`: Finding the route a call takes for a User
  - `Get-TeamsTDP`: Now displays all Identities or max two full Objects
  - `Get-TeamsVNR`: Same as `(Get-CsTenantDialPlan $TDP).NormalizationRules`, but easier
  - `Get-TeamsOVP`: Now displays all Identities or max two full Objects
  - `Get-TeamsOPU`: Get-CsOnlinePstnUsage without the clunkyness.
  - `Get-TeamsOVR`: Get-CsOnlineVoiceRoute, displays all Identities or max two full Objects
  - `Get-TeamsMGW`: Get-CsOnlinePstnGateway, displays all Identities or max two full Objects

### Updated Functions & Bugfixes

#### Session Commands

- `Connect-Me`: Complete overhaul
  - Module MicrosoftTeams is replacing SkypeOnlineConverter in FEB 2021.
  - Connection can be made with either module present.<br />NOTE: If connected to multiple tenants, a dialog is shown to select the Account when connecting to SkypeOnline when using the MicrosoftTeams Module. There is no way this can be prevented currently.
  - Integrated Privileged Identity Management Role activation with `Enable-AzureAdAdminRole` (used only if Module AzureAdPreview is available and PIM is used! )
  - Integrated `Get-AzureAdAdminRole` to query Admin Roles faster
  - Improved feedback by catching all output and displaying custom object at the end when Parameter `NoFeedback` is not chosen.
- `Connect-SkypeOnline`: Complete overhaul
  - Now supports Module MicrosoftTeams or SkypeOnlineConnector (v7, support for v6 has been dropped)
  - Added Custom output object in line with Connect-AzureAd and Connect-MicrosoftTeams
  - Requirement for an AccountId (Username) has been removed
- `Disconnect-SkypeOnline`: Updated for compatibility with MicrosoftTeams
- `Assert-SkypeOnlineConnection`: Performance improvement and integrated reconnection when used with the MicrosoftTeams Module
- `Test-SkypeOnlineConnection`: Updated to allow verification against new ComputerName: api.interfaces.records.teams.microsoft.com

#### Voice Config

- `Get-TeamsUserLicense`: Better display for PhoneSystemStatus (String instead of Object)
- `Get-TeamsUserVoiceConfig`: Better display for PhoneSystemStatus (String instead of Object) - Using Get-TeamsUserLicense in the background
- `Set-TeamsUserVoiceConfig`:
  - Refined verification of PhoneSystemStatus. As the queried Object from Get-TeamsUserLicense changes, so needs the processing
  - Refined application of PhoneNumber. Now allowing an empty string and $null (removing the Number) - A warning is displayed as the Object is then not in the correct state to make outbound calls, but as it is a SET command, it shall allow for empty states.

#### Resource Account

- `Remove-TeamsResourceAccount`: Added Parameter PassThru to display UPNs of removed Accounts
- `Remove-TeamsResourceAccountAssociation`: Added Parameter PassThru to display an Object detailing the Status of the Account and its associations post change
- `New-TeamsResourceAccountAssociation`: Performance update: Now faster lookup of Objects (x10)

#### Call Queue

- `Get-TeamsCallQueue`: Complete rework.
  - Parameter `Name` now returns an exact result.
  - New Parameter `SearchString` (NameFilter) returns all results for the provided string, i.E. acts as Name did before.
  - Without any parameters, only Names are displayed
  - Switch `Detailed` expands on the result by also displaying all SharedVoicemail parameters (even if they are not set).
  - Small performance and accuracy improvement when parsing DLs
- `New-TeamsCallQueue`:
  - Small improvement for enumeration of Voicemail Target (now treted the same as a User) and SharedVoicemail Target (now faster lookup)
  - Fixed an issue with Call Queues forwarding to Resource Accounts (were treated as users.)
  - Reworked OverflowAction and TimeoutAction 'Forward' as well as Parsing of Users: Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`
- `Set-TeamsCallQueue`:
  - Small improvement for enumeration of Voicemail Target (now treted the same as a User) and SharedVoicemail Target (now faster lookup)
  - Fixed an issue with Call Queues forwarding to Resource Accounts (were treated as users.)
  - Reworked OverflowAction and TimeoutAction 'Forward' as well as Parsing of Users: Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`

#### Auto Attendant

- `Get-TeamsAutoAttendant`: Complete rework.
  - Parameter `Name` now returns an exact result.
  - New Parameter `SearchString` (NameFilter) returns all results for the provided string, i.E. acts as Name did before.
  - Without any parameters, only Names are displayed
  - Switch `Detailed` expands on the result by displaying the full tree of all nested objects.
- `New-TeamsAutoAttendant`: **Major Overhaul**
  - Simplified requirements for Operator. Parameter OperatorType now obsolete as the Target is parsed with Get-TeamsCallableEntity
  - Added Parameter EnableTranscription to allow for Transcription with all CallTargets (SharedVoicemail)
  - Removed Parameter Silent as it wasn't implemeneted and should not be used anyway.
  - Removed all TargetType parameters as the CallTarget is now found with Get-TeamsCallableEntity.
  - Parameter Schedule now properly overrides Parameter AfterHoursSchedule (renamed from DefaultSchedule)<br \>NOTE: This may have to change to work with one Parameter to allow for a HolidaySchedule
  - Parameter Validation is now improved
  - Separated requirements for DefaultCallflow. Using this parameter now overrides BusinessHours Parameters properly.
  - Separated requirements for CallFlows and CallHandlingAssociations. Using these parameters now overrides AfterHours Parameters properly.
- Updated Support Functions:
  - `New-TeamsAutoAttendantDialScope`: Improved lookup for Groups
  - `New-TeamsAutoAttendantDialSchedule`: TimeFrame 'AllDay' now is open for 24 hours, not 23 hours and 45 minutes.

#### Other Updates

- Multiple functions:
  - Lookup improvements to gain unique Objects, ValueFromPipeline, correcting pipeline processing. Better debug output before applying settings.
  - Cleanup of ToDos and improvement of code bits
  - Better Error management by throwing instead of writing errors.
- `Get-TeamsTenant` now displays the HostedMigrationOverrideUrl needed to move users
- `Set-TeamsUserLicense`: Added Parameter PassThru to display the User License Object post change
- `Format-StringForUse`:
  - Added more normalisation and verification for UserPrincipalname: ".@" is now properly caught and the dot removed.
  - Added normalisation for LineURI
  - Added normalisation for E164 Format (removing the Extension)
- `Import-TeamsAudioFile`: File path can now have spaces, yay :)

### Removed Functions

Yes, it is time to remove some Functions. Mainly letting go of unused (unloved) ones.

- `Add-TeamsUserLicense`: Replaced by `Set-TeamsUserLicense`
- `Get-SkuIdFromSkuPartNumber`: Superceded by functionality in Get-AzureAdLicense
- `Get-SkuPartNumberFromSkuId`: Superceded by functionality in Get-AzureAdLicense
- `Set-TeamsUserPolicy`: Limited usability and not used enough. Was using `Invoke-Expression`
- `Test-TeamsTenantPolicy`: Limited usability and not used enough. Was using `Invoke-Expression`
- `Write-ErrorRecord`: Superceded by proper understanding and use of `throw` and `Write-Error`
- `ProcessLicense`: Private Function and the gears behind `Add-TeamsUserLicense`
- `GetActionOutputObject2`: Private Function and like Write-ErrorRecord a way to display output
- `GetActionOutputObject3`: Private Function and like Write-ErrorRecord a way to display output

### Look ahead / Planning for vNext

- Licensing: Switch from custom (static) function `Get-TeamsLicense` to dynamically read `Get-AzureAdLicense`.<br />This requires some pondering and testing
- Module `MicrosoftTeams` - Further testing and stabilisation for `Connect-Me` and `Connect-SkypeOnline` - The clock is ticking...
- New Function planned: `Get-TeamsVoiceRoutingConfig` drawing the full chain of Voice Routing Config for OVP-OPU-OVR-MGW in one object
- Proper testing of the new: `TeamsCommonAreaPhone`-Scripts
- More Auto Attendant love.

## v20.12 - December 2020 release

### Component Status

- Function Status: 66 Public CmdLets, 8 private CmdLets, 15 Live
- Development Status: 35 PreLive, 14 RC Functions; 2 in Beta, 0 in Alpha
- Pester Test Status: Tests Passed: 864, Failed: 0, Skipped: 0 NotRun: 0
- `TeamsUserVoiceConfig` Scripts have advanced to RC Status (some are already PreLive)
- `TeamsResourceAccount` Scripts are still in RC Status - Multiple code improvements have been applied. See below.
- `TeamsCallQueue` Scripts are still in RC Status.
- `TeamsAutoAttendant` Scripts remain in BETA Status as improvements are still ongoing.
- `TeamsCallableEntity` Scripts have been added (GET and FIND)

### Focus for this month

- *Faster*: Performance Improvements for multiple `Get` and `Test` commands
- *Making 'Progress'*: Added Status bars and Verbose output to indicate progress for most longer running scripts (if you get div/0 errors, I can't count^^)
- *Better Lookup and feedback*: To ind the appropriate objects have improved in performance as well as received a clause for if no matches are found for the provided string
- *PassThru*: Previously `-Silent` was used to suppress output. This has now reversed with `-PassThru` for some (3) SET Commands and removed for 2 NEW commands. Going forward, the  `PassThru` Switch is added to SET and REMOVE Commands respectively.
- *Licensing*: New Scripts have been added to put the Licensing offer this Module is making on new, highly oiled rails: By parsing the [AzureAd License Document file on Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference) .

### New Functions

Some Helper functions for Call Queues and Auto Attendants, to find the type of Object: `Get-TeamsObjectType`, `Get-TeamsCallableEntity` and `Find-TeamsCallableEntity`. In the Resource Account family I have added `Test-TeamsResourceAccount`. To simplify Objects in AzureAd, `Find-AzureAdGroup` and `Find-AzureAdUser` (this was Get-AzureAdUserFromUpn, now renamed and revamped)

- `Test-TeamsResourceAccount`:
  - New Script to test whether an Object is a ResourceAccount and it has two modes, Quick and Thorough (default):
  - The default option is looking up (FINDing) the CsOnlineApplicationInstance and return $TRUE if found. Somehow this takes longer than expected so:
  - With the Parameter `Quick`, it will look up the AzureAd Object and return $TRUE if the Department is "Microsoft Communication Application Instance" (this is fast and accurrate enough as Resource Accounts with different department name have issues...).
- `Find-AzureAdGroup`:
  - A fork of Test-AzureAdGroup, but works quite differently
  - All Groups are parsed, then filtered if the String is found in DisplayName, Description, ObjectId or Mail. Unique Objects are then filtered and returned.
  - Returns all Group Objects found, or `$null` if not.
- `Find-AzureAdUser`:
  - Formerly known as "Get-AzureAdUserFromUPN", this command now simplifies searches against AdUsers.
  - It has been extended to cover not only lookup by UPN, but also Searchstring, making it into one command that can more reliably find User Objects.
  - Returns all User Objects found, or `$null` if not.
- `Find-TeamsCallableEntity`
  - Returns all Call Queue or Auto Attendant Names where the provided Entity is used/connected to.
  - Parameter `Scope` can be used to limit searches to Call Queues or Auto Attendants
  - For Call Queues, this can be as an Agent (User, or inherited via Group), as a Group, OverflowTarget or TimeoutTarget
  - For Auto Attendants, this can be as an Operator, Routing Target or Menu Option
- `Get-TeamsCallableEntity`:
  - Command can be used to determine type and usability for AutoAttendants or CallQueues: <br />Accepts a String which can be an Office 365 Group Name, Upn or TelUri
  - Returning a Custom Object with the same parameters (and more) as a CallableEntity Object
- `Get-TeamsObjectType`: Helper script to determine the type of Object provided.
- `Get-TeamsLicense` - A Replacement for the variable $TeamsLicenses which outputs the same information, but protected by accidental deletion of the Variable
- `Get-TeamsLicenseServicePlan` - A Replacement for the variable $TeamsServicePlans which outputs the same information, but protected by accidental deletion of the Variable
- `Get-AzureAdLicense` - EXPERIMENTAL - A Script to read from Microsoft Docs, reading the published Content. Eventually a replacement for the two above, but not yet :) - Returns Object containing all Microsoft 365 License Products. Can be `-FilterRelevantForTeams`. Not yet linked into any other functions.
- `Get-AzureAdLicenseServicePlan` - EXPERIMENTAL - Same as above, just displaying all ServicePlans instead of License Products. Can also be `-FilterRelevantForTeams`. Not yet linked into any other functions.
- `Enable-TeamsUserForEnterpriseVoice` (Alias: `Enable-Ev`) - I needed a shortcut.

### Updated Functions & Bugfixes

- `Assert-` Functions have now more simplified output, displaying only one Message in all but one case
- `Connect-Me`: Minor Code improvements and corrections. Added Output information at the end, containing Date, Timestamp, Connected Services
- `Get-AzureAdAssignedAdminRoles`: Added a Warning in case no Admin Roles are found. Displaying Verbose output to inform about Script limitation (no query against Group Assignments yet)
- `Find-TeamsResourceAccount`: Output Object is now separate from that of `Get`, which speeds up enumeration a lot.
- `Get-TeamsResourceAccount`:
  - Added Parameter `ObjectId` to output Object and improved lookup.
  - Lookup without a Name will now only list Names of ApplicationInstances.
- `New-TeamsResourceAccountAssociation`: Completely reworked processing. Status has advanced to RC, continuing to be tested.
- `Test-AzureAdUser` & `Test-AzureAdGroup`: Performance & precision update (Was reporting `$true` if no error received, but the command could come back empty handed as well!).
- `Test-TeamsUserLicense`: ServicePlans can be assigned through multiple Licenses, writing a warning when multiple assignments have been found, but returning $true if one of them is "Success"
- `Get-TeamsUserLicense`: To cover multiple potential assignments of *PhoneSystem*, parameter `PhoneSystemStatus` was added to display the values of ProvisioningStatus for all assignments as an array.
- `Get-TeamsUserVoiceConfig`:
  - Added parameter `Identity` (Level 0) to enable piping the output to Set-CsUser and other CmdLets.
  - Added parameter `ObjectType` (Level 0) to identify the ObjectType, shown just before the `InterpretedUserType`
  - Added parameter `PhoneSystemStatus` (Level 0) to list of Parameters to identify VoiceConfig capabilities better (Assigned but Disabled)
  - Parameter "ObjectType" has been renamed to `AdObjectType` to indicate where the value is from
  - Parameter "ObjectClass" has followed suit: `AdObjectClass` for consistency.
- `New-TeamsAutoAttendantSchedule`: Added TimeFrame 'AllDay' to potential Schedules enabling for use with New-TeamsAutoAttendant
- `New-TeamsAutoAttendant`:
  - Code improvements around terminating errors using `return` now instead of terminating on Write-Error
  - Added Parameter `DefaultSchedule` to support 3 basic Schedules: 'MonToFri9to5' (default), 'MonToFri8to12and13to18' and 'Open24x7'
- `Get-TeamsAutoAttendant`:
  - Lookup without a Name will now only list Names of Auto Attendants.
  - Parameter `Name` is now an array, enabling processing of multiple targets
- `Get-TeamsCallQueue`:
  - Lookup without a Name will now only list Names of Call Queues.
  - Parameter `Name` is now an array, enabling processing of multiple targets
- `Format-StringForUse`:
  - Added an option to normalise Strings `-As E164` - This will format any String to an E.164 Number, for example: "1 (555) 1234-567" to "+15551234567"
  - Added an option to normalise Strings `-As LineURI` - This will format any String to a LineURI, for example: "1 (555) 1234-567 ;ext=1234" to "tel:+15551234567;ext=1234"

### Other Improvements

- Component Status: 15 Live, 32 PreLive, 11 RC Functions; 5 in Beta, 0 in Alpha
- Pester Testing are still mostly structural checks, but I was able to formulate some tests for scripts (3) as well
  - More individual tests still to come.
  - Tests working with PowerShell v7.20-preview.1 resolving an issue with Security/not recognising Unblocked Files
- PowerShell 7 - More tests to come

## v20.11 - November 2020 release

### New Functions

Two small helper functions are coming to the fold. They mainly help you type less: `Get-TeamsOVP` for finding Online Voice Routing Policies and `Get-TeamsTDP` for finding Tenant Dial Plans (except the Global ones).

### Major Overhaul

New Module structure means debugging gets easier and testing becomes an option. This is a big internal shift from a Module of ONE file of 13k+ lines of code to separate PS1 files dot-sourced into the main Module.
While the one-file approach was managable with regions, it was a bit tiresome to scroll all the time...

Limiting the Scope to one function per file also means that I can - finally - use the debugger in VScode. This will help me find variable states easier and not rely on the ISE Steroids and live testing that much. Speaking of testing, I am now also in a position to write tests for individual Functions.

### Updated Functions & Bugfixes

- `Get-TeamsCallQueue`: Reworked Output completely. Get-CsCallQueue has surfaced more parameters and displays File parameters better. After changing the design principle from *expansive-by-default* to *concise-by-default* for GET-Commands, the following change was necessary to bring it in line. Removed Parameter `ConciseView` as the default Output now displays a concise object and added Added Parameter `Detailed` instead.
- `Get-TeamsAutoAttendant`: Expanded on the existing output. Added Switch `Detailed` which additionally displays all nested Objects (and their nested Objects)
- `Get-TeamsUserVoiceConfig`: Slightly restructured output
- `Find-TeamsUserVoiceConfig`: Better output for the `-TelephoneNumber` switch
- `New-TeamsCallQueue`: Extended the waiting period between Applying a License and adding the Phone Number to 10 mins (600s) as it takes longer than 6 mins to come back ok.
- `Set-TeamsCallQueue`: Same as above
- `Import-TeamsAudioFile`: Fixed a few issues with this one. First, the OutputType was not liked, then my use of the Return-Command meant that the only Output was the word "HuntGroup".
- Multiple Scripts now don't stop when they shouldn't
- `Get-TeamsResourceAccountAssociation`: Performance improvements, code cleanup & added StatusType to Output
- `Get-TeamsResourceAccount`: Performance improvements
- `Show-FunctionStatus` now also has the Level RC. Pre-Live will now log verbose messages quietly, thus  significantly reducing Verbose noise. RC will display more. Order: Alpha > Beta > RC > PreLive > Live | Unmanaged, Deprecated

### Other Improvements

- Pester Testing
  - Current Status: Tests Passed: 779, Failed: 0, Skipped: 0 NotRun: 0<br />These are for the most part structural Module tests to enforce design principals and lets me not forget to use CmdLetBinding and other goodies in my code. More individual tests still to come.
  - I excluded the test to validate all files have Tests-Files, otherwise I would have 70+ Failures here...
  - These are - mostly Module related tests, meaning verifying that I have CmdLetBinding, Begin/Process/End blocks, etc.
  - More tests will be added once I have figured out Mocking.
- Code Signing - The Module itself is now code-signed, this means:
- PowerShell 7 support. Having installed v7.1.0-RC2 (which solves the issue with SkypeOnlineConnector not being able to be loaded), I will now test on both v5.1 and v7.1

## v20.10 - October 2020 release

*More, we need more!*

### NEW: Teams Voice Configuration Scripts

- `Get-TeamsTenantVoiceConfig` - Displays Tenant Voice Configuration Information, like number of Gateways, Voice Policies, etc.
- `Get-TeamsUserVoiceConfig` (Alias: `Get-TeamsUVC`) - Displays all Voice related parameters from the AD-Object, CS-Object and AD-Licensing-Object
- `Find-TeamsUserVoiceConfig` (Alias: `Find-TeamsUVC`) - This is the long overdue port of one of my oldest Skype Scripts, the "SfB Oracle". Answering the age old question of "where is this Number assigned...?" and more.
- `Set-TeamsUserVoiceConfig` (Alias: `Set-TeamsUVC`) - TBA - Not built yet. Writing on the Use Case/Design right now.
- `Remove-TeamsUserVoiceConfig` (Alias: `Remove-TeamsUVC`) - Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set. This is handy when moving from Calling Plans to Direct Routing or vice versa
- `Test-TeamsUserVoiceConfig` (Alias: `Test-TeamsUVC`) - TBC - Tests an individual VoiceConfig Package against the provided Identity. (not fully functional yet, will need a bit more love, sorry)

### NEW: Auto Attendant Scripts

- `Get-TeamsAutoAttendant` (Alias: `Get-TeamsAA`) - A wrap for Get-CsAutoAttendant with slightly better output, or so I think. The display of Names with the Display-Parameters (Cs-Command) is something I want to learn and understand. I currently help myself by showing that the Name only hinting that there *is* an Object behind some parameters
- `New-TeamsAutoAttendant` (Alias: `New-TeamsAA`) - A wrap for New-CsAutoAttendant with improved functionality. Only Name is required to stand up an AA now. Defaults are available for Language (en-US), TimeZone (UTC) and Schedule (Mon-Fri 9-5). Input for Business Hours and After Hours Greeting and Call Flow are available. Override with specific Object available for all options (passed through to New-CsAutoAttendant)
- `Set-TeamsAutoAttendant` (Alias: `Set-TeamsAA`) - A wrap for Set-CsAutoAttendant with better usability. Enables limited parameterized input instead of instancing. Planned, but not yet built!.
- `Remove-TeamsAutoAttendant` (Alias: `Remove-TeamsAA`) - A wrap for Remove-CsAutoAttendant
- **Support CmdLets**
  - `New-TeamsAutoAttendantDialScope`: Creates a Dial Scope Object to be fed into Auto Attendants. Input: Office 365 Group Names
  - `New-TeamsCallableEntity`: Creates a Callable Entity Object to be fed into Auto Attendants. Input: CallTargetType & CallTarget.
  - `New-TeamsAutoAttendantPrompt`: Creates a Prompt Object to be fed into Auto Attendants. Input: String. CmdLet decides whether it is a Text-to-Voice string or an AudioFile :)
  - `New-TeamsAutoAttendantSchedule`: Creates a Schedule Object to be fed into Auto Attendants. Input: Business Days, Business Hours. Many examples available to chose from. This should cover 95% of all Schedules

### NEW: Aliases

- All `TeamsAutoAttendant` CmdLets now also listen to `TeamsAA` (incl. their support functions)
- All `TeamsCallQueue` CmdLets now also listen to `TeamsCQ` as well
- All `TeamsResourceAccount` CmdLets now also listen to `TeamsRA`
- All `TeamsResourceAccountAssociation` CmdLets now also listen to `TeamsRAAssoc`
- All `TeamsUserVoiceConfig` CmdLets now also listen to `TeamsUVC`
- Existing Aliases `con`, `dis`, `pol`, etc. have not been changed.
- Alias and Function Name have swapped for `Connect-Me` and `Disconnect-Me` - Please note: The old `Connect-SkypeTeamsAndAAD` will be removed in v20.11

### NEW: More support Functions

- `Resolve-AdGroupObjectFromName` and other support functions have been broken out.
- This is in line with my learning to have "one function to one thing". PowerShell in a month of lunches and PowerShell Toolmaking improves the way I write :D
- `Test-TeamsUserHasCallPlan` was added to gain feedback of whether remnant Calling Plan configuration may be present

### Improvements

- Adopted better Style guides to help clarify script exit scenarios and provide better output.
- Added this file - VERSION.md - to collect a detailed change log.
- Updated README.md to include all functions.
- Spell checker has been activated (Boy, do I make mistakes. :))
- Switched most functions (except some Test-Functions) to advanced Functions
- Added `OUTPUTTYPE`, `PARAM`, `BEGIN`, `PROCESS` and `END` blocks now consistently to all advanced Functions (Test-Functions which may be basic functions, still have `OUTPUTTYPE` for example)
- Verbose output has been added to all Scripts with `BEGIN`, `PROCESS` and `END` blocks
- Replaced all `BREAK` keywords that are not in switches or loops (43) with a terminating Write-Error that was there in the first place.
- Replaced all `RETURN` keywords (15) that accumulated multiple objects into one to behave better for pipeline output (Write-Output is now displayed within the ForEach)
- WarningAction is now applied to all `GET`-Commands except where explicitly desired to bleed through warnings. This should quieten down the Scripts a bit. WarningVariable is added to my repertoire.
- Assert Functions have been added to more consistently trigger the "you have to construct additional Pylons" warning of having to connect to AzureAD or SkypeOnline first.
- Better and more consistent display of Script maturity now added with a Helper function. Four main levels and two additional informational Levels are available:
  - **ALPHA**: Not all Function not built. Functionality may lacking (DEBUG output, with confirm)
  - **BETA**: Functions built but not tested (DEBUG output, without confirm)
  - **Pre-Live**: Functions built and tested, but not all and not as thoroughly as I would want (VERBOSE output, visible)
  - **Live**: All Systems go. (VERBOSE output, visible only when using -Verbose)
  - *Unmanaged*: The odd Function that I have ported from Skype but not yet manage to validate against Teams (VERBOSE output, visible)
  - *Deprecated*: Functions that are scheduled to be removed soon (VERBOSE output, visible)
- **NOTE**: With the exception of Boolean Output Test scripts, all Functions can reach only **Pre-Live Status**. Once I am able to provide some basic Pester integration, these will be able to 'mature' more :)
- **NOTE**: Feedback is appreciated for all scripts. Please send verbose output of the Scripts that generate errors to TeamsFunctions@outlook.com. Thanks!

### Fixes

- Multiple iterations of testing fixed a lot of small things across the board.

## v20.09 - September 2020 release

Another month of bugfixing and stabilisation

### NEW: Assert-CmdLets for Connections

- The Test-Commands only verify whether a session exists but do not action anything. As I didn't want to touch them, I have created their corresponding Assert-Commands (Output: OnScreen display and returns Boolean value)
- `Assert-AzureADConnection` executes Test-AzureADConnection and if unsuccessful, displays output to run Connect-AzureAD (as all AzureAD scripts do already, preempting issues with AzureAD)
- `Assert-MicrosoftTeamsConnection`  executes Test-MicrosoftTeamsConnection and if unsuccessful, displays output to run Connect-MicrosoftTeams (I am currently not using it, so don't know whether it behaves the same as for AzureAD...)
- `Assert-SkypeOnlineConnection` executes Test-SkypeOnlineConnection and if unsuccessful, **tries to reconnect** the session with Get-CsTenant because of the caveat listed below. <br/>If this too proves unsuccessful, it will request to disconnect and reconnect manually using `Connect-Me`. The Alias '`pol`' is available. PoL for *Ping-of-life* as it it either resets the timeout counter or reconnects the session for you.
- **NOTE**: The behavior of the Scripts did not change, I merely pulled the existing pre-check functionality into a separate function and linked them in the Script as a one-liner, this brought the line count of the module down by 300 :)

### CHANGED: Teams Call Queue Handling

- `New-/Set-TeamsCallQueue` will now try to enable Users for EnterpriseVoice if they are Licensed, but not enabled yet.
  This affects User Objects added as agents with the *Users* Parameter as well as the *OverflowActionTarget* and *TimeoutActionTarget* if the respective *OverflowAction* or *TimeoutAction* if set to *'Forward'*
- If the *OverflowActionTarget* could not be enumerated and the OverflowAction is not *'DisconnectWithBusy'* the OverflowAction will be removed from the parameter stack (reducing errors)
- If the *TimeoutActionTarget* could not be enumerated and the TimeoutAction is not *'Disconnect'* the TimeoutAction will be removed from the parameter stack (reducing errors)
- `Get-TeamsCallQueue` output has received a revamp. Order improved for readability, parameter *ConciseView* delivers less (similar to Get-CsCallQueue -ExcludeContent, but developed without knowing about this switch). <br/>Added parameters that Microsoft now exposes due to requests from myself and others in Uservoice. For Example: *DistributionGroupsLastExpanded* gives feedback on when the agent list was last updated. <br/>**NOTE**: This is still on an 8 hour cadence without an option to trigger other than to remove the Group and re-attach it to the CallQueue

### Bugfixes

- `Get-TeamsCallQueue` now returns a result again. Mea culpa.
- Many small improvements in all `TeamsCallQueue` CmdLets
- `New-TeamsResourceAccount` now correctly handles PhoneNumber assignments.
- `Set-TeamsResourceAccount` now should be a tad faster as it does not query the Object for every single piece of information.
- Typos fixed. 'timout' will be the bane of my existence.

### **Caveats**

Consistency of ability to reconnect sessions is dependent on the Security settings in the Tenant. On some tenants this works fine and commands are executed correctly after re-authenticating yourself. On other tenants, most notably ones with PIM activated, Error-messages are received with 'Session assertion' or other seemingly abstruse messages. Just run `Connect-Me` again to recreate a session (this will cleanly disconnect the session prior). The Assert-CmdLets should help with this :)

## v20.08 - August 2020 Release

July was "quiet" because I only published pre-releases with bugfixes (mostly). Here the full log:

### NEW: Teams Licensing Application

- `Set-TeamsUserLicense` - Replacement function for Add-TeamsUserLicense (which now is deprecated). Add or Remove Licenses with an array. Accepted values are found in the accompanying variable `$TeamsLicenses.ParameterName`
- Added Variables containing all relevant information for 38 Products and 13 ServicePlans! They are threaded into the TeamsUserLicense CmdLets as well as Get-TeamsTenantLicense. Translating a friendly Name (Property `ParameterName`, `FriendlyName`& `ProductName`) to the `SkuPartNumber`or `SkuID`is what I am trying to bridge (who wants to remember a 36 digit GUID for each Product?)
- Accompanying this, changes to `Get-TeamsUserLicense` have been made to report a uniform feedback of Licenses (based on the same variable)
  - `Get-TeamsTenantLicense` (replaces Get-TeamsTenantLicense**s**) has been completely reworked. A

### NEW: Teams Call Queue Handling

- Added SharedVoicemail-Parameters are processed for `New-TeamsCallQueue` and `Set-TeamsCallQueue`
- **New**: `Import-TeamsAudioFile` - Generic helper function for Importing Audio Files. Returns ID of the File for processing. TeamsCallQueue CmdLets are using it.
- **Changed: Default behaviour of Scripts that require a valid Session to SkypeOnline**
- This now has changed from *REQUIRE VALID SESSION (ERROR)* to *TRYING TO RECONNECT (VERBOSE)*. This was made possible by the quality work of the Exchange-Team (publishing [Module ExchangeOnlineManagement](https://www.powershellgallery.com/packages/ExchangeOnlineManagement/1.0.1)) which inspired me to deploy the same for Scripts that require connections to SkypeOnline
- All CmdLets that can try a reconnect (SkypeOnline and ExchangeOnline) will try. This is done with Get-CsTenant and Get-UnifiedGroup respectively.
- NOTE: AzureAD and MicrosoftTeams should not time out and therefore do not need to be reconnected to.
- `Connect-SkypeTeamsAndAAD` (`Connect-Me` for short) now supports a connection to Exchange, though manually to select with the Switch `-ExchangeOnline`.

### Improved

- Behind the scenes improvements and Performance
- Proper application of `ShouldProcess` for all State Changing Functions
- Performance for all `Test`-CmdLets (and some `Get`-CmdLets)
- Verification for Sessions

### Fixed

- Plenty of Bugs squashed for `TeamsCallQueue` CmdLets (Plenty more to come, I am sure)
- Fixes applied for `TeamsResourceAccount` Scripts - These have now lost the BETA-Moniker and are live :)

We are now in line with all but a few recommendations from PS Script Analyzer. Invoke-Expression is still in there, but now wrapped in a ShouldProcess should you need to process it.

This modules row count is OVER 9000! ;)

## v20.6.29.1 - July 2020 Release

added Resource Account Association Scripts

- Updated this ReadMe.MD - About time, I agree :D
- More improvements curtesy of PSScriptanalyzer
  - Added **ShouldProcess** for all State changing functions.
  - Created new Snippets for the **Begin**-Block in order to support proper application of  `$ConfirmPreference`, `$WhatIfPreference` and `$VerbosePreference` for Functions that are calling the ones in this Module (will adhere to the values if defined)
  - Added proper application of **-Force** switches in conjunction with the above
- Added Scripts to connect Resource Accounts to Call Queues or Auto Attendants. These are fully tested and functional
  - `New-TeamsResourceAccountAssociation`
  - `Get-TeamsResourceAccountAssociation`
  - `Remove-TeamsResourceAccountAssociation`

Making a tactical halt here to add some Pester tests (once I figure them out :))

Celebrating 7500 lines of code

## v20.6.22.0

- More Improvements for Resource Accounts Scripts - LIVE
- More Improvements for Call Queue Scripts - Still BETA
- Added `Find-TeamsResourceAccount` to complete the set and remove some complexity from the GET-Command. It works similar, though the output is more detailed then its equivalent (Find-CsOnlineApplicationInstance)
- Incorporating Script Analyzer and starting to implement some suggestions:
- Renamed Remove-StringSpecialCharacter to `Format-StringRemoveSpecialCharacter`

## v20.6.17.1

- More Improvements for Resource Accounts Scripts - Still BETA
- More Improvements for Call Queue Scripts - Still BETA
- Added helper function `Write-ErrorRecord` to improve the output for Error Messages in a more readable format.

## v20.6.9.1 - June 2020 Release

- Added `Get-AzureAdUserFromUpn` to simplify looking up Users in AzureAD by providing the UserPrincipalName (now renamed to `Find-AzureAdUser`)
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
  - `Get-SkuIdFromSkuPartNumber` - Tiny little helper translating SkuID to their SkuPartNumber (License Name)
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

Revamping existing scripts. No Additions.

## v20.5.3.1 - May 2020 Release

TeamsFunctions. A module. A way to collect relevant Scipts and Functions for Administration of SkypeOnline (Teams Backend), Voice and Direct Routing, Resource Accounts, Call Queues, etc.

### Origins

This module is a collection of Teams-related PowerShell scripts and functions based on [**SkypeFunctions** by Jeff Brown](https://github.com/JeffBrownTech/Skype). Please show your love. This is published separately (and with permission) rather than updated because I couldn't figure out Forks and Pull-Requests and by the time I had, I had substantially altered the code...

The first goal was to refresh what needs adding (for example, License names for Microsoft 365). The second goal was to learn and understand PowerShell better and test all Functions for applicability in Teams. Once vetted, some functions have been renamed from "SkypeOnline" to "Teams" (others, like the "Connect"-scripts have been retained).

Enjoy,
David
