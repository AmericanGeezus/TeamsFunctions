# ToDo List

## Auto Attendant

### New-TeamsAutoAttendant

Add features, operator, Call target, default forward to CQ (Build also wrapper to create the construct of 1 AA and 1 CQ)

### New-TeamsAutoAttendantMenu

Add Menu builder with selector for x options 1-9 (default: Forward To PSTN? with dummy number?).
Optionally add operator on 0 (separate Operator function (New-TeamsAutoAttendantOperator?) or hooking into New-TeamsAutoAttendant)

## Support Functions

Abstract Functionality that is used more than twice into generic helper function

### New-TeamsAutoAttendantCallableEntity and its functionality

Evaluate whether functionality of New-TeamsAutoAttendantCallableEntity would be better off in a helper function (and used in CQ or the CE-Function) rather than adding the switch to the CE-Function!

## Code Improvements

Disable Positional Binding for CQ and AA scripts https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-5.1

Add Supports Paging for Get Commands Get-TeamsCallQueue and Get-TeamsAutoAttendant at least!

Add Aliases into Functions? Just under CmdLetBinding! Do I have to export them afterwards separately still?

Add Timestamp to Verbose steps when Processing multiple elements (just before ForEach)

Add Argument Completer to some functions, where appropriate: [ArgumentCompleter({(Get-Eventlog -List).log})]

Use dynamic parameters instead of having to verify conjoint use of multiple parameter and ensure mutual exclusivity

Create Function Template

Break out Functions into separate PS1 scripts
Link them as PS1 files in the module
Export all with Get-ChildItem | Export-ModuleMember

Change all Assert Scripts Verbose output to display/run only if called directly (runspace)
if ($MyInvocation.CommandOrigin -eq "Runspace") {
    #Assert
}

#TODO Change Stop to $ErrorAction and query/set in Begin to adhere to value being used. Same for Warningaction
#TODO Repeat for EVERY Script!
Template: Get-TeamsUserVoiceConfig


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