# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v21.01.10 pre-release - TBA

### New

- Added Markdown help for every public function: [TeamsFunctions Docs](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs)
  - Using PlatyPS to add Markdown Help files. Special thanks to [Andrés Gorzelany](https://github.com/get-itips)
  - Updated Comment Based help and Helpmessages for all parameters (corrected LINK section)
- `Find-TeamsUserVoiceRoute`: Given a user and a Dialled Number, evaluates the Effective Dial Plan and Effective Voice Route and displays all with neat output
- `Set-AzureAdUserLicenseServicePlan`: Enabling and disabling a ServicePlan for all Licenses assigned to a User
- First Function writing to Information stream (finally!)

### Updated

- Updated all Functions:
  - PreferenceVariables (added DebugPreference to Continue if provided, no more individual confirmation)
  - Show-FunctionStatus was too quiet, functionality was repaired
  - Added .EXTERNALHELP, separated all .LINK

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
