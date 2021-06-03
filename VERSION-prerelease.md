# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2053-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- TBC

### Updated

- `New-TeamsResourceAccount`: Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Set-TeamsResourceAccount`: Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Get-TeamsCallQueue`:
  - Renamed Parameter ApplicationInstances to `ResourceAccountsAssociated` for consistency
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccounts translated
  - Adding Parameter `ChannelUsers` (enumerated and displayed only with Switch `Detailed`): ChannelUserObjectId translated

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
