# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2184-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### Draft - Look ahead

- `Disable-AzureAdUserLicense`: Draft Status
- Adding more (GOV) Licenses to Get-AzureAdLicense - Issue #80
- Buildout of Holiday Set functionality. Creating a HolidaySet for Auto Attendants
- Buildout of Set-TeamsAutoAttendant - for limited functions
- `Assert-TeamsResourceAccount`: Querying ResourceAccount requirements are met based on Associated Entity functionality used (ExternalPstn, License, PhoneNumber, etc.)
- `Set-TeamsUserVoiceMail`: Draft/ALPHA/Incubator - Setting Voicemail parameters for a Teams User

### New

- TBC

### Updated

- `New-TeamsAutoAttendant`: Now fully featured.
  - Added HolidaySet-Parameters.
  - Optimised validation of CallFlows and CallHandlingAssociations
  - Updated help and optimised order of Parameters
- `New-TeamsAutoAttendantDialScope`: Added small verification for Groups (previously only validated Call Targets)
- `New-TeamsAutoAttendantMenuOption`:
  - Added support for Announcements - both Text-to-Voice as well as AudioFile with Parameter `Announcement`
  - Refactored processing of Press/Say as it is now used in all but one Option
  - Optimised processing for Option 10
- `New-TeamsAutoAttendantPrompt`: Added parameter `AlternativeString` - Processing both strings if different (dual prompt)
- `New-TeamsCallableEntity`: Added parameter `EnableSharedVoicemailSystemPromptSuppression`
- `Get-TeamsObjectType`: Optimised code to have less duplication, caught an error if AzureAdUser was not found.
- `Get-TeamsAutoAttendant`: Added support for Announcements for switch Detailed (Prompts on MenuOptions)
- `Merge-TeamsAutoAttendantArtefact`:
  - Refactored code to populate with a failsafe (Original Object is retained if no translation happened). Improves visibility
  - Added support for Prompts on MenuOptions (enables display of configured Announcements in Get-TeamsAutoAttendant )
- `Assert-TeamsAudioFile`: Fixed an issue with proper termination if all conditions are met.
- `New-TeamsAutoAttendantPrompt`: Fixed an issue with AudioFiles being passed properly to the Prompt CmdLet.

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
