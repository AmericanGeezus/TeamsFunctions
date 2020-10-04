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
