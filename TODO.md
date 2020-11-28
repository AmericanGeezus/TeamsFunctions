# ToDo List

## Test Plan

### Progress Bars

All: ResourceAccount, Call Queue, etc.

## Auto Attendant

### New-TeamsAutoAttendant

Add features, operator, Call target, default forward to CQ (Build also wrapper to create the construct of 1 AA and 1 CQ)

Continue to test Scripts

### New-TeamsAutoAttendantMenu

Add Menu builder with selector for x options 1-9 (default: Forward To PSTN? with dummy number?).
Optionally add operator on 0 (separate Operator function (New-TeamsAutoAttendantOperator?) or hooking into New-TeamsAutoAttendant)

## Licensing

Figure out a way to enable individual ServicePlans (PhoneSystem) for a User which has a E5 License assigned.
Enable-AzureAdLicenseServicePlan PhoneSystem
Alias: Enable-ServicePlan PhoneSystem

## Call Queue

New Function: Find-TeamsCallQueueAgent $UPN
Parse all Call Queues and their agent for the ObjectId of this User.
Return Call Queue Names
Also search all Overflow and Timeout Objects of the same call queues (if Type is User)
Return as what they are set?

## Support Functions

### New-TeamsAutoAttendantCallableEntity and its functionality

Evaluate whether functionality of New-TeamsAutoAttendantCallableEntity would be better off in a helper function (and used in CQ or the CE-Function) rather than adding the switch to the CE-Function!

## Code Improvements

Evaluate adding PassThru to all Set and Remove parameters, outputting the Object (instead of Silent or other things)

Disable Positional Binding for CQ and AA scripts https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-5.1

Add Supports Paging for Get Commands Get-TeamsCallQueue and Get-TeamsAutoAttendant at least!

Add Timestamp to Verbose steps when Processing multiple elements (just before ForEach)

Add Argument Completer to some functions, where appropriate: [ArgumentCompleter({(Get-Eventlog -List).log})]

Use dynamic parameters instead of having to verify conjoint use of multiple parameter and ensure mutual exclusivity?

Create Function Template

Change all Assert Scripts Verbose output to display/run only if called directly (runspace)
if ($MyInvocation.CommandOrigin -eq "Runspace") {
    #Assert
}

## Evaluate Export to CLIXML

UCaaSMsolBackup - Module to import

$i = Import-Clixml -Path "XML FILE"

$i = Import-Clixml -Path E:\TMSBackups\iprad.onmicrosoft.com\20200511\2239__State.xml

$commandresult = $i['Get-CsOnlineUser']

$commandresult | Where-Object SipAddress -eq _____sip:p.cassin@iprad.com

## Evaluate sturdier licensing

Remove only if found on user for example / check whether it is in the tenant first...
#CHECK solve how to remove disabled plans?
https://www.reddit.com/r/Office365/comments/9kpmok/assign_office_365_licenses_with_powershell/

#CHECK Display disabled plans?

## PowerShell 7

v7.1-rc1 works with SkypeOnlineConnector
Start Testing on PS7
Integrate PS7 into VScode

## Test Module MicrosoftTeams as baseline

New-CsOnlineSession does not have -Username anymore. Test MFA with Credential instead (also interoperability with Connect-Me/AzureAD and MicrosoftTeams)

## Pester

Change Module checks to this format:
https://vexx32.github.io/2020/07/08/Verify-Module-Help-Pester/
