# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2195-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

Major refactoring for support of MicrosoftTeams v2.6.0

### Draft - Look ahead

- `Disable-AzureAdUserLicense`: Draft Status
- Buildout of Set-TeamsAutoAttendant - for limited functions
- `Assert-TeamsResourceAccount`: Querying ResourceAccount requirements are met based on Associated Entity functionality used (ExternalPstn, License, PhoneNumber, etc.)
- `Set-TeamsUserVoiceMail`: Draft/ALPHA/Incubator - Setting Voicemail parameters for a Teams User

### New

- TBC

### Updated

- `Get-TeamsResourceAccount`: Added the Exception message to "Account not found" to feed back the error (RBAC)

### Limitations

- Azure Ad Admin Role activation for Groups does not work - Currently not possible due to missing command in AzureAdPreview/AzureAd
- `Connect-MicrosoftTeams`: Scenario observed where a Session has been opened, but Skype Commands cannot be used.
<br />Mitigation: Disconnect, then close PowerShell session completely, ensure Admin Roles are activated and re-run `Connect-Me`
<br />NOTE: This behaviour was not observed in v2.3.1 and later!

### ToDo

- Pipeline tests: More
- Pester tests: More
- Refactoring use of Switches across the board (using ".IsPresent" instead of the variable only)

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
