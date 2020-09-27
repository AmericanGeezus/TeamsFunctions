# TeamsFunctions - Change Log

I decided to break this out into its own file as it grows ever so consistently as the Module itself.
Pre-releases are documented within the Module comment block and will be transferred here monthly in cadence with the release cycle

## v20.10 - October 2020 release

*More, we need more!*

### NEW: Teams Voice Configuration Scripts

- `Get-TeamsTenantVoiceConfig` - TBC
- `Get-TeamsUserVoiceConfig` (Alias: `Get-TeamsUVC`) - Displays all Voice related parameters from the AD-Object, CS-Object and AD-Licensing-Object
- `Find-TeamsUserVoiceConfig` (Alias: `Find-TeamsUVC`) - This is the long overdue port of one of my oldest Skype Scripts, the "SfB Oracle". Answering the age old question of "where is this Number assigned...?" and more.
- `New-TeamsUserVoiceConfig` (Alias: `New-TeamsUVC`) - TBA - Not built yet. Writing on the Use Case/Design right now.
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
  - `New-TeamsAutoAttendantCallableEntity`: Creates a Callable Entity Object to be fed into Auto Attendants. Input: CallTargetType & CallTarget.
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
- Added `OUTPUTTYPE`, `PARAM`, `BEGIN`, `PROCESS` and `END` blocks now consistently added to all advanced Functions (Test-Functions which may be basic functions, still have `OUTPUTTYPE` for example)
- Verbose output has been added to all Scripts with `BEGIN`, `PROCESS` and `END` prefixes
- Replaced all `BREAK` keywords that are not in switches or loops (43) with a terminating Write-Error that was there in the first place.
- Replaced all `RETURN` keywords (15) that accumulated multiple objects into one to behave better for pipeline output (Write-Output is now displayed within the ForEach)
- WarningAction is now applied to all `GET`-Commands except where explicitely desired to bleed through warnings. This should quieten down the Scripts a bit. WarningVariable is added to my repertoire.
- Assert Functions have been added to more consistently trigger the "you have to construct additional Pylons" warning of having to connect to AzureAD or SkypeOnline first.
- Better and more consistent display of Script maturity now added with a Helper function. Four levels available:
  - **ALPHA**: Not all Function not built. Functionality may lacking (DEBUG output, with confirm)
  - **BETA**: Functions built but not tested (DEBUG output, without confirm)
  - **Pre-Live**: Functions built and tested, but not all and not as thoroughly as I would want (VERBOSE output, visible)
  - **Live**: All Systems go. (VERBOSE output, visible only when using -Verbose)
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
- Added Variables containing all relevant information for `$TeamsLicenses`(38!) and `$TeamsServicePlans`(13). They are threaded into the TeamsUserLicense CmdLets as well as Get-TeamsTenantLicense. Translating a friendly Name (Property `ParameterName`, `FriendlyName`& `ProductName`) to the `SkuPartNumber`or `SkuID`is what I am trying to bridge (who wants to remember a 36 digit GUID for each Product?)
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
