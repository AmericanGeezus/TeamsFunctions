# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

### New

- Module: Handling of Strict Mode (if activated) and switching it off.

### Updated

- `Connect-Me`: Catching non-activation of MFA for better feedback
- `Enable-MyAzureAdAdminRole`: Catching non-activation of MFA for better feedback
- `New-TeamsResourceAccount`: Adding `-Force` to the call of `Set-CsOnlineApplicationInstance` when removing Phone Numbers
- `Remove-TeamsResourceAccount`: Adding `-Force` to the call of `Set-CsOnlineApplicationInstance` when removing Phone Numbers
- `Set-TeamsResourceAccount`:
  - Rework of Number assignment. Separation of Validation, Removal, Scavenging and Application
    - Number validation happens first
    - Number removal is triggered if assigned and different, with `-Force` or if PhoneNumber is provided and is not NULL or Empty
    - Number scavenging (from other Users or Resource Accounts) can be performed with `-Force`
    - Number assignment is triggered if PhoneNumber is provided and it is not NULL or Empty
- `Set-TeamsUserVoiceConfig`:
  - Complete Rework of Number assignment. Separation of Validation, Removal, Scavenging and Application
    - Number validation happens first
    - Number removal is triggered if assigned and different, with `-Force` or if PhoneNumber is provided and is not NULL or Empty
    - Number scavenging (from other Users or Resource Accounts) can be performed with `-Force`
    - Number assignment is triggered if PhoneNumber is provided and it is not NULL or Empty
  - Tweaks for handling PhoneSystemStatus of PendingInput
- `Get-TeamsUserVoiceConfig`: Added nested Object for Licensing
- `Find-AzureAdUser`: Improved output by Sorting by DisplayName

### ToDo

- Evaluation of Pipeline Input by PropertyName - rebind Identity to UserPrincipalName
- Test piping objects with UserprincipalName and Identity to GET-CmdLets and SET-CmdLets
- Test output of objects with and without Identity against Microsoft CmdLets

## v21.03.21 pre-release

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-1181-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- Module: Handling of Strict Mode (if activated) and switching it off.
- `Enable-MyAzureAdAdminRole` (`ear`): Wrap for `Enable-AzureAdAdminRole` which works on its own too, but makes it available to be called in other functions
- `Get-MyAzureAdAdminRole`: Wrap for `Get-AzureAdAdminRole` to query Admin Roles for the currently connected User
- `Get-CurrentConnection` (`cur`): Helper Function for Connect-Me. Queries connections to AzureAd, MicrosoftTeams and Exchange and returns an Object with Information
- `Assert-TeamsUserVoiceConfig`: New Script to validate Configuration for TDR and Calling Plans
- `Get-TeamsCP`: Get-CsTeamsCallingPolicy in a new form
- `Get-TeamsIPP`: Get-CsTeamsIpPhonePolicy in a new form
- `Get-TeamsECP`: Get-CsTeamsEmergencyCallingPolicy in a new form
- `Get-TeamsECRP`: Get-CsTeamsEmergencyCallRoutingPolicy in a new form

### Updated

- `Get-TeamsUserLicense`: Now allows for piping the output to other CmdLets (Added AzureAdUser Identity)
- `Use-MicrosoftTeamsConnection`: New private function to reconnect a broken PS-Session by running a GET-Command before `Test-MicrosoftTeamsConnection`
- `Test-MicrosoftTeamsConnection`: Updated (reduced) to actual testing (extracted trigger into `Use-MicrosoftTeamsConnection`)
- `Assert-MicrosoftTeamsConnection`: Updated to use and test the Connection properly and run Connect-MicrosoftTeams or Connect-Me dependent on Status
- `Connect-Me`: Reworked data gathering at the end and output for `-NoFeedback` (now returns a barebones Account, Connection and TeamsUpgradeEffectiveMode) for use in `Assert-MicrosoftTeamsConnection`.
- `Enable-AzureAdAdminRole`: Added Debug function & Call Stack
- `Get-AzureAdAdminRole`: Added Debug function, Corrected ActiveUntil and Added ActiveSince
- `Test-TeamsUserVoiceConfig`: Finally lifting this one out of RC - Complete revamp based on Microsoft Configuration Guidelines. Simplified usage (removed Scope(TDR/CallingPlans)).
- All internal license queries are now performed by `Get-AzureAdUserLicense` because the default output for `Get-TeamsUserLicense` is now reduced to Teams only Licenses.
NOTE: The Output Object is the same, just the default behaviour between the two CmdLets is different
- Get-Helpers updated for OPU, OVP, OVR, MGW, TDP, VNR
- `Get-TeamsTenant`: Reworked output and updated (Domains) with ScriptMethod ToString

---------------------------------------------

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
