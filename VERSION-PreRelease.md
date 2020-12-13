# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.12.13 pre-realease

### New

- New Helper functions behind the scenes to find Unique AzureAd Groups and Creating Callable Entities
- Completing the Set for AutoAttendants:
  - `New-TeamsAutoAttendantCallFlow` (New-TeamsAAFlow): Call Flow Object with default options
  - `New-TeamsAutoAttendantMenu` (New-TeamsAAMenu): Menu Object with default options
  - `New-TeamsAutoAttendantMenuOption` (New-TeamsAAOption): Menu Option Object with default options

### Updated

- Multiple functions: Lookup improvements to gain unique Objects
- `Get-TeamsUserLicense`: Better display for PhoneSystemStatus (String instead of Object)
- `Get-TeamsUserVoiceConfig`: Better display for PhoneSystemStatus (String instead of Object) - Using Get-TeamsUserLicense in the background
- `Set-TeamsUserVoiceConfig`:
  - Refined verification of PhoneSystemStatus. As the queried Object from Get-TeamsUserLicense changes, so needs the processing
  - Refined application of PhoneNumber. Now allowing an empty string and $null (removing the Number) - A warning is displayed as the Object is then not in the correct state to make outbound calls, but as it is a SET command, it shall allow for empty states.
- `Get-TeamsCallableEntity`: Added Parameter ObjectType to not interfere with Parameter Type (used in other scripts)
- `New-TeamsCallableEntity`: Added Parameter EnableTranscription
- `New-TeamsAutoAttendant`: **Major Overhaul**
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

## v20.12.07 pre-release

### New

- `Get-TeamsOPU`: Get-CsOnlinePstnUsage is too clunky. It doesn't have a filter/search function. This one does.
- `Get-TeamsOVR`: Get-CsOnlineVoiceRoute, expanding the Name property
- `Get-TeamsMGW`: Get-CsOnlinePstnGateway, expanding the Identity property

### Updated

- `Get-TeamsOVP`: Updated to more consistently display Names instead of individual records (with more than 2)
- `Get-TeamsTDP`: Updated to more consistently display Names instead of individual records (with more than 2)
- `Get-TeamsTenant` now displays the HostedMigrationOverrideUrl needed to move users
- `Remove-TeamsResourceAccount`: Added Parameter PassThru to display UPNs of removed Accounts
- `Remove-TeamsResourceAccountAssociation`: Added Parameter PassThru to display an Objects detailing the Status of the Account and its associations post change
- `Set-TeamsUserLicense`: Added Parameter PassThru to display the User License Object post change
- `New-TeamsResourceAccountAssociation`: Performance update: Now faster lookup of Objects (x10)
- `Get-TeamsCallQueue`: Small performance and accuracy improvement when parsing DLs
- `New-TeamsCallQueue`: Small improvement for enumeration of Voicemail Target (now treted the same as a User) and SharedVoicemail Target (now faster lookup)
- `Set-TeamsCallQueue`: Small improvement for enumeration of Voicemail Target (now treted the same as a User) and SharedVoicemail Target (now faster lookup)
- `New-TeamsAutoAttendant`:
  - Simplified requirements for Operator. Parameter OperatorType now obsolete as the Target is parsed with Get-TeamsCallableEntity
  - TODO: Identified a major design flaw in trying to build on top of New-CsAutoAttendant. Function flagged for complete overhaul!
  - Removed Parameter Schedule as it can only be with a CallHandlingAssociation

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
