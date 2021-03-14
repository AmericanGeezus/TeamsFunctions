# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v21.03.x pre-release

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-1181-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- Module: Handling of Strict Mode (if activated) and switching it off.
- `Enable-MyAzureAdAdminRole`: Wrap for `Enable-AzureAdAdminRole` which works on its own too, but makes it available to be called in other functions

### Updated

- `Get-TeamsUserLicense`: Now allows for piping the output to other CmdLets (Added AzureAdUser Identity)
- `Use-MicrosoftTeamsConnection`: New private function to reconnect a broken PS-Session by running a GET-Command before `Test-MicrosoftTeamsConnection`
- `Test-MicrosoftTeamsConnection`: Updated (reduced) to actual testing (extracted trigger into `Use-MicrosoftTeamsConnection`)
- `Assert-MicrosoftTeamsConnection`: Updated to use and test the Connection properly and run Connect-MicrosoftTeams or Connect-Me dependent on Status
- `Connect-Me`: Reworked data gathering at the end and output for `-NoFeedback` (now returns a barebones Account, Connection and TeamsUpgradeEffectiveMode) for use in `Assert-MicrosoftTeamsConnection`.
- `Enable-AzureAdAdminRole`: Added Debug function & Call Stack
- `Get-AzureAdAdminRole`: Added Debug function, Corrected ActiveUntil and Added ActiveSince

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
