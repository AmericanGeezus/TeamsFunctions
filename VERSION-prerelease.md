# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2061-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- New private function: `Assert-TeamsAudioFile`: Validating requirements for AudioFiles before importing them.

### Updated

- `New-TeamsResourceAccount`:
  - Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Set-TeamsResourceAccount`:
  - Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Import-TeamsAudioFile`:
  - Integrated Size and Format check here to simplify all AudioFile imports to Call Queues or Auto Attendants
  - Returns error if File size is above limit or not in the correct format (in addition to file not found)
- `Get-TeamsCallQueue`:
  - Renamed Parameter ApplicationInstances to `ResourceAccountsAssociated` for consistency
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds translated
  - Adding Parameter `ChannelUsers` (enumerated and displayed only with Switch `Detailed`): ChannelUserObjectId translated
- `New-TeamsCallQueue`:
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds simplified
  - Adding Parameter `ChannelUsers`: ChannelUserObjectId simplified. (NOTE: Currently use for this is unknown)
  - Refreshed processing of AudioFiles, delegating validation to using Assert-TeamsAudioFile
  - Reworked processing of SharedVoicemail parameters
- `Set-TeamsCallQueue`:
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds simplified
  - Adding Parameter `ChannelUsers`: ChannelUserObjectId simplified. (NOTE: Currently use for this is unknown)
  - Refreshed processing of AudioFiles, delegating validation to using Assert-TeamsAudioFile
  - Reworked processing of SharedVoicemail parameters

### Limitations

- `Connect-MicrosoftTeams`: Scenario observed where a Session has been opened, but Skype Commands cannot be used.
<br />Mitigation: Disconnect, then close PowerShell session completely, ensure Admin Roles are activated and re-run `Connect-Me`

### ToDo

- Pipeline tests:
  - Test piping objects with UserprincipalName and Identity to GET-CmdLets and SET-CmdLets
  - Test output of objects with and without Identity against Microsoft CmdLets
- Rework Get-TeamsCallQueue and Get-TeamsAutoAttendant to also accept the ObjectId as input
- Refactoring use of Switches across the board (using ".IsPresent" instead of the variable only)

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
