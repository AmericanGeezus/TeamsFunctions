# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2262-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

TBC

### New

- tbc

### Updated

- `Find-TeamsResourceAccount`: Fixed an issue with PhoneNumber not being displayed properly
- `New-TeamsResourceAccount`: Added Parameter `Sync` to synchronise Resource Account with the Agent Provisioning Service
- `Set-TeamsResourceAccount`: Added Parameter `Sync` to synchronise Resource Account with the Agent Provisioning Service
- `Assert-MicrosoftTeamsConnection`: Addressing an issue with timed out RBAC Roles and reconnection
- `Assert-TeamsUserVoiceConfig`: Refactored function to be able to receive an CsOnlineUser Object as well as a UserPrincipalName
- `Get-TeamsUserVoiceConfig`: Refactored address query to catch non-provisioned addresses not to error
- `Set-TeamsUserVoiceConfig`:
  - Fixed an issue with identifying "assigned to self" not being recognised
  - Added feedback for already assigned TDP and OVP
- `Set-TeamsPhoneNumber`: Fixed an issue with identifying "assigned to self" not being recognised
- `Assert-TeamsCallableEntity`: Increased the time to wait for License to be enabled successfully
- `Enable-TeamsUserForEnterpriseVoice`: Switched from UserPrincipalName to SIPaddress for the Identity (accommodating misaligned configuration)
- Fixed an issue with calculation of progress steps in multiple CmdLets
- `New-TeamsResourceAccount`: Refactored to use `Set-TeamsPhoneNumber`
- `Set-TeamsResourceAccount`: Refactored to use `Set-TeamsPhoneNumber`

### Draft - Look ahead

- `Disable-AzureAdUserLicense`: Draft Status
- Buildout of Set-TeamsAutoAttendant - for limited functions
- `Assert-TeamsResourceAccount`: Querying ResourceAccount requirements are met based on Associated Entity functionality used (ExternalPstn, License, PhoneNumber, etc.)
- `Set-TeamsUserVoiceMail`: Draft/ALPHA/Incubator - Setting Voicemail parameters for a Teams User

## v21.10.31-prerelease - Bugfixes, Progress bars, etc.

Bugfixes, major overhaul of all Progress Bars displayed and refactoring of `Set-TeamsUserVoiceConfig`
Supporting MicrosoftTeams v2.6.0 as `CsOnlineUser`-Object behaves differently beyond v2.3.1
Pre-released for testing purposes - Planned go-Live for 21.12

### Component Status

|           |                                                                                                                                                                                                                                                                                                                                                                   |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Functions | ![Public](https://img.shields.io/badge/Public-107-blue.svg) ![Private](https://img.shields.io/badge/Private-16-grey.svg) ![Aliases](https://img.shields.io/badge/Aliases-55-green.svg)                                                                                                                                                                            |
| Status    | ![Live](https://img.shields.io/badge/Live-94-blue.svg) ![RC](https://img.shields.io/badge/RC-7-green.svg) ![BETA](https://img.shields.io/badge/BETA-0-yellow.svg) ![ALPHA](https://img.shields.io/badge/ALPHA-0-orange.svg) ![Deprecated](https://img.shields.io/badge/Deprecated-0-grey.svg) ![Unmanaged](https://img.shields.io/badge/Unmanaged-6-darkgrey.svg) |
| Pester    | ![Passed](https://img.shields.io/badge/Passed-2239-blue.svg) ![Failed](https://img.shields.io/badge/Failed-0-red.svg) ![Skipped](https://img.shields.io/badge/Skipped-0-yellow.svg) ![NotRun](https://img.shields.io/badge/NotRun-0-grey.svg)                                                                                                                     |
| Focus     | MicrosoftTeams v2.6.0, Stability, Bugfixing, Refactoring of Progress bars                                                                                                                                                                                                                                                                  |

### New

- `Write-BetterProgress`: Write-Progress, just easier (I hope). Automatic Parenting, fewer errors in counting PercentageComplete. Does (deliberately) not support `-Complete`, but other than that, a full wrapper for Write-Progress
- `Get-WriteBetterProgressSteps`: Private function to utilise ScriptAST to find the number of Steps for a certain ID

### Updated

- All Functions that display Progress bars now utilise `Write-BetterProgress`. Testing commences still on them
- Addressed an issue with bleedthrough of Write-Progress output when used with Visual Studio Code. Not reproducible in Windows Terminal (Order of operations should stabilise this now)
- Testing on MicrosoftTeams v2.6.0 continues, a caveat is shown for some functions that interact with `Set-CsUser`. The `CsOnlineUser` Object can currently not piped to
- `Connect-Me`: Fixed the wording if PIM activation fails to now correctly state that.
- `Get-TeamsResourceAccount`: Added the Exception message to "Account not found" to feed back the error (RBAC)
- `New-TeamsResourceAccount`: Increased time to wait for Account creation to 60s
- `Get-TeamsUserVoiceConfig`: Updated output for better usability. DiagnosticLevel 3 will now add the Parameter `LicenseObject` that can be used to drill into Licenses.
- `Set-TeamsUserVoiceConfig`:
  - Refactored actions to use Identity directly rather than getting the CsOnlineUser piped to the Function (resulted in an error with v2.5.1 and following)
  - Refactored use of `Assert-TeamsCallableEntity` with `Force` to simplify the check for PhoneSystem and EnterpriseVoice Enablement.
- Fixed multiple typos and misalignments when `Write-Information` is used.
- `Set-AzureAdUserLicenseServicePlan`: Fixed a bug that resulted in ServicePlans being reported "already enabled" when more than one license was assigned. Now stable!
- `Assert-TeamsCallableEntity`:
  - Refactored to be able to enable a disabled PhoneSystem ServicePlan if found.


### Limitations

- Azure Ad Admin Role activation for Groups does not work - Currently not possible due to missing command in AzureAdPreview/AzureAd
- `Assert-MicrosoftTeamsConnection`: Checks for reconnection but the use of CmdLets is not validated correctly (when RBAC roles time out.)
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
