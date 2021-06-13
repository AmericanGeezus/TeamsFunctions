# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## unreleased/vNext

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2145-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- `New-TeamsHolidaySchedule`: Creating a new Schedule Object for Holiday Sets based on Public Holidays for Country & Year
- `Get-TeamsAutoAttendantSchedule`: Querying Schedule Objects by Id, Name and/or Association and resolving Auto Attendants names.
- `Disable-AzureAdUserLicense`: Draft Status
- `Disable-MyAzureAdUserLicense`: Draft Status
- `Disable-AzureAdUserAdminRole`: Disabling activated privileged AzureAd Admin Roles for any provided UserPrincipalName.
- `Disable-MyAzureAdUserAdminRole`: Disabling activated privileged AzureAd Admin Roles for the currently logged on user.
- Private Function `Get-ErrorMessageFromErrorString`: Reworking Output from REST API to display Message only (for Try/Catch)

### Updated

- Caught Errors for `Get-AzureAdUser` - Results are now uniformly displayed as required.
- ErrorActions and WarningActions added to multiple queries to quieten execution
- `Get-TeamsCallQueue`:
  - Users linked to Call Queues that are no longer queryable via Get-AzureAdUser (i.E. have been disabled/deleted) are now highlighted with a Warning
- `Get-TeamsAutoAttendant`: Added DialByNameResourceId - as-is for now
- `Get-AzureAdUserAdminRole`:
  - Reworked output: Group Membership is now only queried if Module AzureAdPreview is not available
  - Parameter Type now accepts All, Active & Eligible as input and will filter accordingly
- `Enable-AzureAdUserAdminRole`:
  - Removed activation of SfB Legacy Admin role if MicrosoftTeams v2.3.1 is used as it is no longer needed.
  - Fixed an issue with Output if only one role has been activated - sorry!
  - NOTE: TicketNumber can currently not be processed, it is merely added to the Reason statement if provided
- `Connect-Me`: Refactored counter of activated Admin Roles to accurately report feedback
- `New-TeamsResourceAccountAssociation`: Fixed an issue with Resource Account Lookup - Apologies
- `Assert-TeamsCallableEntity`:
  - Fixed an issue with Resource Accounts not being enumerated.
- Suppressed InformationAction to all Calls to Get-TeamsUserVoiceConfig where applicable (User queries)
- `Set-TeamsResourceAccount`:
  - Fixed an issue with Number application to itself
- `Set-TeamsUserLicense`:
  - Improved output for duplicate licenses - this will require more deliberation on the Input side as well.
  - Improved output for error-states. Exception message now displayed as intended.
- `Set-TeamsUserVoiceConfig`:
  - Reduced output for duplicated licenses - no need to know license counters here.
- `New-TeamsCallQueue`:
  - Quietened Assertion of Callable Entities - no warnings are displayed as that is not the goal of this script.
- `Set-TeamsCallQueue`:
  - Quietened Assertion of Callable Entities - no warnings are displayed as that is not the goal of this script.
- `Set-TeamsUserVoiceConfig`:
  - Quietened output for InformationActions as this is not the goal of this script and not needed.

## v21.6.9 - prerelease to test AudioFiles

[![Passed Tests](https://img.shields.io/badge/Tests%20Passed-2061-blue.svg)](https://github.com/DEberhardt/TeamsFunctions)

### New

- New private function: `Assert-TeamsAudioFile`: Validating requirements for AudioFiles before importing them.

### Updated

- `New-TeamsResourceAccount`:
  - Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Set-TeamsResourceAccount`:
  - Adding Parameter `OnlineVoiceRoutingPolicy` to allow provisioning of OVPs for ResourceAccounts
- `Import-TeamsAudioFile`:
  - Integrated Size and Format check here to simplify all AudioFile imports to Call Queues or Auto Attendants
  - Returns error if File size is above limit or not in the correct format (in addition to file not found)
- `New-TeamsAutoAttendant`:
  - Fixed an issue with very long Auto Attendant names: Now consistently cutting off after 38 characters
  - Added a random number to the Call Flow name to enable creation for multiple Auto Attendants with similar names.
- `Get-TeamsCallQueue`:
  - Renamed Parameter ApplicationInstances to `ResourceAccountsAssociated` for consistency
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds translated
  - Adding Parameter `ChannelUsers` (enumerated and displayed only with Switch `Detailed`): ChannelUserObjectId translated
- `New-TeamsCallQueue`:
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds simplified
  - Adding Parameter `ChannelUsers`: ChannelUserObjectId simplified. (NOTE: Currently use for this is unknown)
  - Clarifying warning for unusable User Objects - If `Assert-TeamsCallableEntity` does not return a usable object.
  - Refreshed processing of AudioFiles, delegating validation to using Assert-TeamsAudioFile
  - Reworked processing of SharedVoicemail parameters
- `Set-TeamsCallQueue`:
  - Adding Parameter `ResourceAccountsForCallerId`: OboResourceAccountIds simplified
  - Adding Parameter `ChannelUsers`: ChannelUserObjectId simplified. (NOTE: Currently use for this is unknown)
  - Clarifying warning for unusable User Objects - If `Assert-TeamsCallableEntity` does not return a usable object.
  - Refreshed processing of AudioFiles, delegating validation to using Assert-TeamsAudioFile
  - Reworked processing of SharedVoicemail parameters
- `Get-TeamsTenantLicense`:
  - Fixed an issue with the enumeration of available units: Now the sum of Units in the Status Enabled and Warning is taken
  <br />NOTE: The Status 'Suspended' has not been considered among the available units. This will need to be validated still!
  - Improved Lookup of unknown licenses - Now consistently adds license counters instead of just populating non-existent parameters (and writing errors)
- `Set-TeamsUserLicense`:
  - Re-ordered validation for selected Licenses: Now checking for already assigned license first before querying available units
  - Validated License assignments together with queries with `Get-TeamsTenantLicense`
- Quieten errors and warnings for all calls to `Get-AzureAdLicense` for functions using this to validate input
- Improved validation to all Cmdlets where the PhoneNumber is validated against Microsoft Numbers (utilising search rather than global variable!)

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
