# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2069-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- `New-TeamsUserVoiceConfig`:
  - New Function. Same as Set-TeamsUserVoiceConfig, although all required parameters are required.
  - Will always return an Object after applying configuration.
- `Get-TeamsTeamChannel` (Alias `Get-Channel`): My take on Get-Team and Get-TeamChannel. One Command to get the Channel
  - Provid Name or Id for Team and Channel to lookup a match
  - v1 only provides basic lookup. It does not (yet) account for multiple Teams or Channels with the provided DisplayName
- `Grant-TeamsEmergencyAddress` (Alias `Grant-TeamsEA`): My take on Set-CsOnlineVoiceUser to apply an Emergency Location
- New private Function `Get-TeamAndChannel` to query Team Object and Channel Object for use in Get-TeamsCallQueue and Get-TeamsCallableEntity

### Updated

- `Assert-TeamsUserVoiceConfig`:
  - Added Parameter ExtensionState to validate whether an Extension has to be present or not.
  - Refactored calls to Test-TeamsUserVoiceConfig with multiple parameters.
- `Test-TeamsUserVoiceConfig`:
  - Refactored use of switches.
  - Added Parameter ExtensionState to validate whether an Extension has to be present or not.
  - Added validation of InterpretedUserType. Known error-states are now fed back as a Warning
- `Get-TeamsUserVoiceConfig`:
  - Changed default output of Licenses to List of License Names only if no DiagnosticLevel is provided. This allows for Export as CSV.
  - Added DiagnosticLevel 0 to display the same as without, though with nested Object.
  - Added Feedback from Test-TeamsUserVoiceconfig to indicate misconfiguration for the Object.
  - Added secondary query if CsOnlineUser is not found. If an AzureAdUser can be found, Warning and Information output followed by a limited Object are returned.
- `Set-TeamsUserVoiceConfig`:
  - Excluding "self" when validating Phone Number in use (Warning is only displayed if the UserPrincipalName is different)
- `Test-TeamsUserVoiceConfig`:
  - Fixed an issue with Partial Configuration - Will return FALSE now if Object is NOT partially configured (but fully)
  NOTE: Using `-Partial` now properly returns false if it is fully configured
  - Included Debug output after tests. Changed Verbose output to Information output (displayed only if it isn't called or `-Verbose` is used)
- `Get-TeamsObjectType`: Added 'Channel' as an ObjectType for a certain match.
- `Get-TeamsCallableEntity`: Added match for '\' triggering query for TeamAndChannel.<br \>This should not be part of any other Object
- `Get-TeamsCallQueue`: Added Parameter TeamAndChannel to display the Team & Channel in the format 'Team\Channel'
- `New-TeamsCallQueue`:
  - Added Parameter TeamAndChannel (input in the format 'Team\Channel')
  - Added Validation of mutual exclusivity for TeamAndChannel VS (Users or Groups)
- `Set-TeamsCallQueue`:
  - Added Parameter TeamAndChannel (input in the format 'Team\Channel')
  - Added Validation of mutual exclusivity for TeamAndChannel VS (Users or Groups)
- `Get-TeamsResourceAccountAssociation`: Fixed an issue with lookup that resulted in forced lookup of all Associations. Mea Culpa!
- `New-TeamsResourceAccount`: Increased waiting time after creating an account from 20 to 30 seconds to get more accurate feedback.
- `Set-TeamsUserLicense`:
  - Improved Debug output and catching known Errors (License already assigned (i.E. no changes), Dependency issue, User not found)
- `Connect-Me`: Tweaked the waiting time after enabling Admin roles from 8 to 10s - Connect-MicrosoftTeams sometimes fails if run too shortly after enabling roles
- `Set-AzureAdUserLicenseServicePlan`: Added feedback for when no changes have been made (i.E. no License did contain any of the Service plans to enable/disable)
- `Get-TeamsCommonAreaPhone`:
  - Changed Query based on input (this now enables proper pipeline input for UserPrincipalNames)
  -
- `New-TeamsCommonAreaPhone`:
  - Fixed an issue with the Password (ValidatePattern doesn't mix well with a SecureString)
  - Removed reverse engineering of applied password
  - Increased wait time for an AzureAdUser from 20 to 30s
  - Removed hard-wired License (CommonAreaPhone). If not provided, no policies are applied as Object is not enabled for Teams
- `Set-TeamsCommonAreaPhone`:
  - Added secondary lookup for AzureAdUser
  - Built out License application (analog to Set-TeamsResourceAccount).
  - Gated Policy Assignment for licensed objects only
- `Remove-TeamsCommonAreaPhone`:
  - Added Switch Force
  - Rebound lookup to AzureAdUser
  - Removed Removal of Voice Configuration if CsOnlineUser Object is not found
- `Remove-TeamsResourceAccount`:
  - Added Switch Force
- General / Multiple Scripts (43):
  - Piping by Property Name now consequently done by UserPrincipalName first, then ObjectId, then Identity. Bindings improved
  - When passing a UserPrincipalName, an error is encountered if this string contains an apostrophe. Patches O'Hoolahan will be proud ;)

### ToDo

- Pipeline tests:
  - Test piping objects with UserprincipalName and Identity to GET-CmdLets and SET-CmdLets
  - Test output of objects with and without Identity against Microsoft CmdLets
- Rework Get-TeamsCallQueue and Get-TeamsAutoAttendant to also accept the ObjectId as input
- `Assert-MicrosoftTeamsConnection`: Evaluate Reconnection with Connect-MicrosoftTeams if unsuccessful.
- Refactoring use of Switches across the board (using ".IsPresent" instead of the variable only)

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
