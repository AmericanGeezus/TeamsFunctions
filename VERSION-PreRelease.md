# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.12.27 pre-release - TBA

### New

- `Get-AzureAdAdminRole`: New script to find active or eligible Admin Roles for one or more users. <br \>NOTE: `Get-AzureAdAssignedAdminRoles` is now deprecated due to performance

### Updated

- `Enable-AzureAdAdminRole`:
  - Prepared to incorporate Privileged Admin Groups (this is in the code, but deactivated for now as no exact match could be found due to lacking Documentation)
  - Added Force and Confirm to enable all Roles and confirm activation of individual Roles respectively.
- `Connect-Me`: Complete overhaul
  - Integrated use of Module MicrosoftTeams (replacing SkypeOnlineConverter in FEB 2021). Connection can be made with either module present.<br />NOTE: If connected to multiple tenants, a dialog is shown to select the Account when connecting to SkypeOnline when using the MicrosoftTeams Module. There is no way this can be prevented currently.
  - Integrated Privileged Identity Management Role activation with `Enable-AzureAdAdminRole` (used only if Module AzureAdPreview is available PIM is used! )
  - Integrated `Get-AzureAdAdminRole` to query Admin Roles faster
  - Improved feedback by catching all output and displaying custom object at the end when Parameter `NoFeedback` is not chosen.
- `Connect-SkypeOnline`:
  - Update to support Module MicrosoftTeams (no Username)
  - Added Custom output object in line with Connect-AzureAd and Connect-MicrosoftTeams
- `Assert-TeamsCallableEntity`: Minor improvements
- `Get-TeamsCallableEntity`: Minor improvements
- `New-TeamsResourceAccountAssociation`: Added Parameter splatting, debug output and proper error handling for Association command.
- `New-TeamsCallQueue`:
  - Fixed an issue with Call Queues forwarding to Resource Accounts (were treated as users.)
  - Reworked OverflowAction Forward: OverflowActionTarget - Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`
  - Reworked TimeoutAction Forward: TimeoutActionTarget - Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`
  - Reworked Users - Integrated `Assert-TeamsCallableEntity`
- `Set-TeamsCallQueue`:
  - Fixed an issue with Call Queues forwarding to Resource Accounts (were treated as users.)
  - Reworked OverflowAction Forward: OverflowActionTarget - Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`
  - Reworked TimeoutAction Forward: TimeoutActionTarget - Integrated `Get-TeamsCallableEntity` and `Assert-TeamsCallableEntity`
  - Reworked Users - Integrated `Assert-TeamsCallableEntity`

## v20.12.20 pre-release

### New

- `Enable-AzureAdAdminRole`:
  - New script to Enable Assigned Admin roles. Requires Module AzureAdPreview.
  - Script in BETA still, though works with direct assignments already. Needs testing.
  - ToDo: Privileged Admin Groups need to be added/supported as well

### Updated

- `Connect-SkypeOnline`:
  - Reworked Completely to support Module MicrosoftTeams or SkypeOnlineConnector
  - Support for SkypeOnlineConnector in v6 or lower has been dropped
  - Preferred connection method is with MicrosoftTeams (v1.1.6 or higher)
- `Assert-SkypeOnlineConnection`: Performance improvement and integrated reconnection when used with the MicrosoftTeams Module
- `Test-SkypeOnlineConnection`: Updated to allow verification against new ComputerName: api.interfaces.records.teams.microsoft.com
- Multiple functions: Lookup improvements to gain unique Objects, ValueFromPipeline, correcting pipeline processing. Better debug output before applying settings.
- `Disconnect-SkypeOnline`: Updated for compatibility with MicrosoftTeams
- `Format-StringForUse`: Added more normalisation and verification for UserPrincipalname: ".@" is now properly caught and the dot removed.
- `Import-TeamsAudioFile`: File path can now have spaces, yay :)
- `Get-TeamsCallQueue`: Detailed results now are only displayed for the first 5 results. Beyond that, only Names are displayed. Pipe is unaffected.
- `Get-TeamsAutoAttendant`: Detailed results now are only displayed for the first 3 results. Beyond that, only Names are displayed. Pipe is unaffected.

## v20.12.13 pre-realease

### New

- New Helper functions behind the scenes to find Unique AzureAd Groups and Creating Callable Entities
- Completing the Set for AutoAttendants:
  - `New-TeamsAutoAttendantCallFlow` (New-TeamsAAFlow): Call Flow Object with default options
  - `New-TeamsAutoAttendantMenu` (New-TeamsAAMenu): Menu Object with default options
  - `New-TeamsAutoAttendantMenuOption` (New-TeamsAAOption): Menu Option Object with default options
- `Assert-TeamsCallableEntity`: New script to ensure a Callable Entity Object (User) can be used for Overflow and Timout Target as well as for Users in Call Queues and Auto Attendants.

### Updated

- `Get-TeamsUserLicense`: Better display for PhoneSystemStatus (String instead of Object)
- `Get-TeamsUserVoiceConfig`: Better display for PhoneSystemStatus (String instead of Object) - Using Get-TeamsUserLicense in the background
- `Set-TeamsUserVoiceConfig`:
  - Refined verification of PhoneSystemStatus. As the queried Object from Get-TeamsUserLicense changes, so needs the processing
  - Refined application of PhoneNumber. Now allowing an empty string and $null (removing the Number) - A warning is displayed as the Object is then not in the correct state to make outbound calls, but as it is a SET command, it shall allow for empty states.
- `Get-TeamsCallableEntity`: Added Parameter ObjectType to not interfere with Parameter Type (used in other scripts)
- `New-TeamsCallableEntity`: Added Parameter EnableTranscription
- `New-TeamsResourceAccountAssociation`: Fixed an issue removing a Resource Account from a stack of Accounts if it was already assigned.
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
