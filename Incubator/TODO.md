# ToDo List

## Documentation

TeamsFunctions-help.xml

Update Markdown files with Platypus does not automatically update .MD files...

Pester tests do fail still - Test "doc" (Update-DocsAndPester)

- [x] Create Docs
- [x] Create Help
- [x] Populate about-help
- [ ] Add Examples to each About
  - [x] Examples for Licensing
  - [ ] Examples for SupportFunctions
  - [ ] Examples for AutoAttendant
  - [ ] Examples for CallableEntities
  - [x] Examples for CallQueue
  - [ ] Examples for CommonAreaPhone
  - [ ] Examples for ResourceAccount
  - [ ] Examples for Session
  - [x] Examples for UserManagement
  - [ ] Examples for VoiceConfiguration

## Auto Attendant

### New-TeamsAutoAttendant

Add features, operator, Call target, default forward to CQ
Build also wrapper to create the construct of 1 AA and 1 CQ, 2 RA, 2 RAA

Continue to test Scripts

## Code Improvements

Disable Positional Binding for CQ and AA scripts https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-5.1

Add Supports Paging (First, Last) for Get Commands Get-TeamsCallQueue and Get-TeamsAutoAttendant at least!

Add Timestamp to Verbose steps when Processing multiple elements (just inside the ForEach)

Add Argument Completer to some functions, where appropriate: [ArgumentCompleter({(Get-Eventlog -List).log})]

Create Function Template

## Evaluate Export to CLIXML

UCaaSMsolBackup - Module to import

$i = Import-Clixml -Path "XML FILE"

$i = Import-Clixml -Path E:\TMSBackups\iprad.onmicrosoft.com\20200511\2239__State.xml

$commandresult = $i['Get-CsOnlineUser']

$commandresult | Where-Object SipAddress -eq _____sip:p.cassin@iprad.com

## Evaluate sturdier licensing

Remove only if found on user for example / check whether it is in the tenant first...

### CHECK solve how to remove disabled plans?
https://www.reddit.com/r/Office365/comments/9kpmok/assign_office_365_licenses_with_powershell/

Figure out a way to enable individual ServicePlans (PhoneSystem) for a User which has a E5 License assigned.
Enable-AzureAdLicenseServicePlan PhoneSystem
Alias: Enable-ServicePlan PhoneSystem

## PowerShell 7

Start Testing on PS7
Integrate PS7 into VScode

## Test Module MicrosoftTeams as baseline

New-CsOnlineSession does not have -Username anymore. Test MFA with Credential instead (also interoperability with Connect-Me/AzureAD and MicrosoftTeams)
Done, only needs stabilisation for SSO

## Pester

Change Module checks to this format:
https://vexx32.github.io/2020/07/08/Verify-Module-Help-Pester/
