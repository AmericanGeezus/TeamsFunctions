# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.12 - December 2020 release

TBC

## v20.11.22-prerelease

- **Component Status**
  - Current Status: 15 Live, 32 PreLive, 11 RC Functions; 5 in Beta, 0 in Alpha
  - `TeamsUserVoiceConfig` Scripts have advanced to RC Status (some are already PreLive)
  - `TeamsResourceAccount` Scripts are still in RC Status - Multiple code improvements have been applied. See below.
  - `TeamsCallQueue` Scripts are still in to RC Status.
  - `TeamsAutoAttendant` Scripts remain in BETA Status as improvements are still ongoing.
- **Main Improvements**
  - *Faster*: Performance Improvements for multiple `Get` and `Test` commands
  - *Making Progress*: Added Status bars and Verbose output to indicate progress for most longer running scripts
  - *Better Lookup and feedback*: To ind the appropriate objects have improved in performance as well as received a clause for if no matches are found for the provided string
  - *PassThru*: Previously `-Silent` was used to suppress output. This has now reversed with `-PassThru` for 3 SET Commands and removed for 2 NEW commands. Going forward, the  `PassThru` Switch is added to SET and REMOVE Commands respectively.
- **New**
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
  - `Get-TeamsAutoAttendantCallableEntity`:
    - Command can be used to resolve existing callable entities linked to Auto Attendants: <br />Accepts a String which can be an ObjectId
    - Command can be used to determine type and usability for AutoAttendants or CallQueues: <br />Accepts a String which can be an Office 365 Group Name, Upn or TelUri
    - Returning a Custom Object with the same parameters (and more) as a CallableEntity Object
    - Adds `UsableInCqAs` to indicate which which OverflowAction or TimeoutAction this entity can be used.
    - Adds `UsableInAaAs` to indicate which type of CallableEntity can be created with it.
  - `Get-TeamsObjectType`: Helper script to determine the type of Object provided.

- **Updated**
  - `Assert-` Functions have now more simplified output, displaying only one Message in all but one case
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

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
