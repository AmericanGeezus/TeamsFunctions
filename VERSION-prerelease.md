# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-1987-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- `Get-TeamsTeamChannel` (Alias `Get-Channel`): My take on Get-Team and Get-TeamChannel. One Command to get the Channel
  - Provid Name or Id for Team and Channel to lookup a match
  - v1 only provides basic lookup. It does not (yet) account for multiple Teams or Channels with the provided DisplayName

### Updated

TBC

### ToDo

- Pipeline tests:
  - Test piping objects with UserprincipalName and Identity to GET-CmdLets and SET-CmdLets
  - Test output of objects with and without Identity against Microsoft CmdLets
- Rework Get-TeamsCallQueue and Get-TeamsAutoAttendant to also accept the ObjectId as input
- `Assert-MicrosoftTeamsConnection`: Evaluate Reconnection with Connect-MicrosoftTeams if unsuccessful.

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
