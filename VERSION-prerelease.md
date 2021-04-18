# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-1200-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- TBC

### Updated

- `Connect-Me`:
  - Finetuning for Connection stability. (Try #2 now connects without Parameter increasing likelihood of successful connection)
  - Added TenantId to Connect-MicrosoftTeams to definitively connect to the same tenant as AzureAd
  - Feedback to User is added to look out for the Authentication Dialog as it sometimes can pop up without focus, hiding behind other open windows.
  - Switched Module MicrosoftTeams from `RequiredVersion` to `MinimumVersion` to allow for prereleases to be used. (Tested with v2.1.0-preview)
- `Get-TeamsUserLicense`: Switched lookup of User type from `Get-TeamsCallableEntity` to `Get-TeamsObjectType` to improve performance
- `Get-TeamsTDP`: Fixed output (selected parameters were not the ones desired (copy/paste error))
- `Get-CurrentConnectionInfo`: Reworked Tenant Name & Display Name based on type of connection present.

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
