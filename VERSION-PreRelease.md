# TeamsFunctions - Change Log - PreReleases

Pre-releases are documented here and will be transferred to VERSION.md monthly in cadence with the release cycle

## v20.11.07-prerelease

- **Updated**
  - `Test-AzureAdUser`: Small update to gain more accurate results (Was reporting `$true` if no error received, but the command could come back empty handed as well!).
  - `Test-AzureAdGroup`: Small update to gain more accurate results (Was reporting `$true` if no error received, but the command could come back empty handed as well!).
  - `Test-TeamsUserLicense`: Now writes a warning when multiple assignments have been found. Returns $true if one of them is "Success"
  - `Get-TeamsUserLicense`: Added parameter `PhoneSystemStatus` which will display display the values of ProvisioningStatus for all assignments as an array.
  - `Get-TeamsUserVoiceConfig`:
    - Added parameter `ObjectType` (Level 0) to identify the ObjectType, shown just before the `InterpretedUserType`
    - Added parameter `PhoneSystemStatus` (Level 0) to list of Parameters to identify VoiceConfig capabilities better (Assigned but Disabled)
    - Parameter "ObjectType" has been renamed to `AdObjectType` to indicate where the value is from
    - Parameter "ObjectClass" has followed suit: `AdObjectClass` for consistency.
  - `Set-TeamsUserVoiceConfig`: Script has advanced to BETA Status. All functions scripted. Testing OK for Direct Routing.

- **New**
  - `Test-CsOnlineApplicationInstance`: New Script to test whether an Object is a ResourceAccount (used in `Get-TeamsUserVoiceConfig`)

---------------------------------------------

## v20.11

- **Updated**
  - `Get-TeamsAutoAttendant`: Expanded on the existing output. Added Switch `Detailed` which additionally displays all nested Objects (and their nested Objects). Full AutoAttendant configuration at (nearly) one glance.
  - `Get-TeamsCallQueue`: Reworked Output completely. Get-CsCallQueue has surfaced more parameters and displays File parameters better.
    - After changing the design principle from *expansive-by-default* to *concise-by-default* for GET-Commands, the following change was necessary to bring it in line.
    - Removed Parameter `ConciseView` as the default Output now displays a concise object.
    - Added Parameter `Detailed` which will display all Parameters for the Call Queue. This includes *SharedVoiceMail*-Parameters and *Diagnostic*-Parameters.
    - NOTE: SharedVoicemail Parameters are always shown with `Detailed`. They are, however shown if the Target is actually 'SharedVoicemail'
- **Fixed**
  - `Import-TeamsAudioFile`: Fixed an issue where the Output was only the word "HuntGroup". Mea culpa.
- **Improvements**
  - `Get-TeamsResourceAccountAssociation` and `Get-TeamsResourceAccount`: Performance improvements, code cleanup
  - `Get-TeamsResourceAccountAssociation`: Added StatusType to Output Object

## v20.10.25-prerelease

- **NEW Functions**
  - `Get-TeamsOVP`: Querying OnlineVoiceRoutingPolicies quickly (Names only, excluding Global)
  - `Get-TeamsTDP`: Querying TenantDialPlans quickly (Names only, excluding Global)
- **Fixes for VoiceConfig Scripts**
  - `Get-TeamsUserVoiceConfig`: Slightly restructured output (added TeamsUpgradePolicy into the Main output to avoid having to use -Level 1 all the time myself). <br />Improved output and pipelining. Script does not perform a hard stop on the first incorrect UPN (by using `Continue` inside ForEach blocks to skip current item and move to the next in ForEach). This will have to be applied to all Scripts that work with lookups to improve stability
  - `Find-TeamsUserVoiceConfig`: Better output for the `-TelephoneNumber` switch
- **Fixes for CallQueue Scripts**
  - `New-TeamsCallQueue`: Extended the waiting period between Applying a License and adding the Phone Number to 10 mins (600s) as it takes longer than 6 mins to come back ok.
  - `Set-TeamsCallQueue`: Same as above
- **Fixes for ResourceAccount Scripts**
  - `Set-TeamsResourceAccount`: Catch block for `ApplicationInstanceManagementException` removed
- **Fixes for License Scripts**
  - `Set-TeamsUserLicense`: Major overhaul of the function. Now working correctly for multiple licenses on Add and Remove. Updated documentation and corrected a few issues discovered due to renaming VariableNames.
- **Fixes for Helper Functions**
  - `Import-TeamsAudioFile`: Output type was not recognised properly with led to File Imports in AutoAttendants and CallQueues not working as intended. Temporarily fixed.
- **Fixes for Private Functions**
  - `Show-FunctionStatus` now also has the Level RC. Pre-Live will now log verbose messages quietly, thus significantly reducing Verbose noise. RC will display more. Order: Alpha > Beta > RC > PreLive > Live | Unmanaged, Deprecated
  - `Get-SkuIdFromSkuPartNumber` now provides multiple Outputs for multiple inputs (used in Licensing)
  - `Get-SkuPartNumberFromSkuId` now provides multiple Outputs for multiple inputs
  - New-AzureAdLicenseObject now correctly provides a License Object for Add and Remove licenses. Remove requires SkuIds only. Add requires a License Object. That Object only supported singular licenses for it to work. Pipelined properly now. :)
  -
- **Testing**
  - Pester testing on PowerShell 7.1.0-rc.2 - Currently hampered by `Unblock-File` not working as intended. [Issue #13869](https://github.com/PowerShell/PowerShell/issues/13869) raised
  - Preparation to use CodeCoverage

## v20.10.18-prerelease

This is a big internal shift from a Module of ONE file of 13k+ lines of code to separate PS1 files dot-sourced into the main Module.
While the one-file approach was managable with regions, it was a bit tiresome to scroll all the time...

Limiting the Scope to one function per file also means that I can - finally - use the debugger in VScode. This will help me find variable states easier and not rely on the ISE Steroids and live testing that much. Speaking of testing, I am now also in a position to write tests for individual Functions.

### Restructuring

E unum pluribus - Out of one, there are many :) - Moving from one file containing all functions to multiple individual .ps1 files (one file per function).

- Functions are split into *Public* and *Private* Functions, Public functions are exported, Private functions are not.
- One file per function. Every Function file *should* have an accompanying Tests-File (ending in .Tests.ps1)
- Introducing a folder structure to represent this: Root: Private, Public. Each folder has a sub-folder *Functions* and *Tests*.
- To group Public functions more meaningfully together, Private\Functions has a sub-folder per Topic covered: *AutoAttendant*, *CallQueue*, *Licensing*, *ResourceAccount*, *Session*, *VoiceConfig* & *Support*. The latter has more subfolders, as required.

### Other Improvements

- Pester Testing
  - Current Status: Tests Passed: 757, Failed: 0, Skipped: 0 NotRun: 0
  - I excluded the test to validate all files have Tests-Files, otherwise I would have 70+ Failures here...
  - These are - mostly Module related tests, meaning verifying that I have CmdLetBinding, Begin/Process/End blocks, etc.
  - More tests will be added once I have figured out Mocking.
- Code Signing - The Module itself is now code-signed, this means:
- PowerShell 7 support. Having installed v7.1.0-RC1 (which solves the issue with SkypeOnlineConnector not being able to be loaded), I will now test on both v5.1 and v7.1

### Pipeline

- More module related Tests to really make this one as sturdy as I can
- More function tests, again, once I figure out Mocking
- Automated Testing for multiple PowerShell versions
- AppVeyor CI/CD build
- Automated Workflow for releases and prereleases (like posting this update on my blog :))
