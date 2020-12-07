# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.12.07 pre-release

### New

- `Get-TeamsOPU`: Get-CsOnlinePstnUsage is too clunky. It doesn't have a filter/search function. This one does.
- `Get-TeamsOVR`: Get-CsOnlineVoiceRoute, expanding the Name property
- `Get-TeamsMGW`: Get-CsOnlinePstnGateway, expanding the Identity property

### Updated

- `Get-TeamsOVP`: Updated to more consistently display Names instead of individual records (with more than 2)
- `Get-TeamsTDP`: Updated to more consistently display Names instead of individual records (with more than 2)
- `Get-TeamsTenant` now displays the HostedMigrationOverrideUrl needed to move users

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
