# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2145-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### Draft - Look ahead

- `Disable-AzureAdUserLicense`: Draft Status
- Adding more (GOV) Licenses to Get-AzureAdLicense - Issue #80
- Buildout of Holiday Set functionality. Creating a HolidaySet for Auto Attendants
- Buildout of Set-TeamsAutoAttendant - for limited functions
- `Assert-TeamsResourceAccount`: Querying ResourceAccount requirements are met based on Associated Entity functionality used (ExternalPstn, License, PhoneNumber, etc.)

### New

- TBC

### Updated

- TBC

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
