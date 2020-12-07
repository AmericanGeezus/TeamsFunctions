# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

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
