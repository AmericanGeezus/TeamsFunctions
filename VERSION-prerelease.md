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

- `Find-TeamsEmergencyCallRoute` (`Find-TeamsECR`):
  - New CmdLet to determine the route for emergency Services calls.
  - Validating configuration in Teams Network Topology (by Subnet or Site)
  - Optionally validating user configuration and Tenant Dial Plan to find issues with effectiveness of Emergency Call Routing Policies.
- `Set-TeamsUserVoiceMail`: ALPHA/Incubator - Setting Voicemail parameters for a Teams User

### Updated

- General:
  - All CmdLets now have appropriate Links to their own online help-file as well as the corresponding `about_`-Files
- `Connect-Me`: Added 'user cancelled operation' as a terminating condition.
- `Set-TeamsUserLicense`: Improved feedback for 'Objects' (rather than for 'User')
- `Enable-AzureAdAdminRole`:
  - Skype For Business Legacy Admin Role is no longer needed for MicrosoftTeams v2.3.1 and higher.
  - Role will now only be enabled if older module versions have been detected (loaded) or with switch `Force`
- `Get-TeamsAutoAttendant`: Added parsing with ObjectId
- `Get-TeamsCallQueue`: Added parsing with ObjectId
- `Remove-TeamsAutoAttendant`: Added parsing with ObjectId
- `Get-TeamsCallQueue`: Added parsing with ObjectId
- `Get-TeamsUserVoiceConfig`:
  - Reports `PhoneSystem` now as TRUE for Assignment of Phone System Virtual User License (Resource Accounts) for a more harmonious experience
- `Set-TeamsUserVoiceConfig`:
  - Fixed an issue which resulted in Phone Number being removed if switch `PhoneNumber` was not provided. Now only removed if Phonenumber is specified as empty or NULL.
  - Refactored execution policy towards Resource Accounts. Allowed execution based on ObjectType. Supports Users & ResourceAccounts only.
  - Execution against Resource Accounts now feeds back verbose information for non-applicable settings. Supports OVP & Number, but not HostedVoicemail and TDP
  - Refactored script execution to provide better output for switch `WriteErrorLog`.
  - Refactored error log file written to create one file per hour, rather than for each individual User Name (easier for bulk execution)
  - Current performance for full application is between 15-30s per Object (averages around 2.5 Objects per min or 150 Objects per hour)
- `Remove-TeamsUserVoiceConfig`:
  - Quietened output of License Removals
- `Find-TeamsUserVoiceRoute`:
  - Refactored DialedNumber into an Array - Multiple numbers can now be provided. An object is returned for each Number
  - Added validation and caveats (Warnings) for Emergency Services Numbers if detected (~95% coverage for 3-digit EMS numbers)

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
