# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2195-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### Draft - Look ahead

- `Disable-AzureAdUserLicense`: Draft Status
- Buildout of Set-TeamsAutoAttendant - for limited functions
- `Assert-TeamsResourceAccount`: Querying ResourceAccount requirements are met based on Associated Entity functionality used (ExternalPstn, License, PhoneNumber, etc.)
- `Set-TeamsUserVoiceMail`: Draft/ALPHA/Incubator - Setting Voicemail parameters for a Teams User

### New

- `Get-TeamsAutoAttendantAudioFile` (`Get-TeamsAAAudioFile`): New Support function for Auto Attendants, parsing Audio Files for an Auto Attendant.

### Updated

- `Find-TeamsUserVoiceConfig`: Addressed an issue with search by VP, OVP & TDP
- All `TeamsCallQueue` CmdLets: Added "INFO: " for informational output
- Some `TeamsUserVoiceConfig` CmdLets: Added "INFO: " for informational output
- `[ArgumentCompleter]` now returns values sorted. For some reason, I missed this, sorry.
- `Get-TeamsAutoAttendant` circumvented a bug in parsing the Auto Attendant entity by Name (nested Objects display differently)

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
