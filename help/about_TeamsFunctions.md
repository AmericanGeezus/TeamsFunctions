# TeamsFunctions

## about_TeamsFunctions

## SHORT DESCRIPTION

Teams Voice CmdLets adding and improving on AzureAd and MicrosoftTeams CmdLets

## LONG DESCRIPTION

All CmdLets are designed to help with Administration of Users, Common Area Phones, Resource Accounts, Call Queues and Auto Attendants, incl. Licensing, User Voice Configuration with Calling Plans and Direct Routing.

## RELEASE CYCLE

Until proper maturity has been reached, updates are released monthly.

Bugfixes are added to as `prerelease` in a weekly cadence.

## TOPICS COVERED

This module currently contains over 85 Functions covering a broad area of Teams Functions for Admins: From Session Connection and activating Admin Roles in PIM to User Administration, Licensing and Voice Configuration all the way to Resource Accounts, Call Queues, Auto Attendants

Each topic will get its own ABOUT file soon, diving deeper into the Scripts.

- SkypeOnline Session connection
- AzureAd Licensing (Tenant queries and User assignments)
- AzureAd Privileged Identity Management (Role Activation)
- AzureAd Object Preparation for Voice Configuration (EnterpriseVoice)
- Teams Voice Configuration (Direct Routing and Calling Plans)
- Teams Common Area Phone (new CmdLets)
- Teams Analog Contact Object (new CmdLets coming soon)
- Teams Resource Account (wrappers for existing CmdLets)
- Teams Call Queue (wrappers for existing CmdLets)
- Teams Auto Attendant (wrappers for existing CmdLets)
- Support and Helper functions for Admin tasks

## EXAMPLES

- Monthly Cycle: `Update-Module TeamsFunctions`
- Weekly Cycle: `Update-Module TeamsFunctions -AllowPrerelease`

## NOTE

This seems to be a constant work-in progress so please bear with me with any issues you may find. I am to fix them quickly, but I am doing this outside my day-job in my spare time. Cheers.

## REQUIREMENTS

- PowerShell v5.1 (Support for PowerShell v7 is being tested right now)
- Module `AzureAd` or `AzureAdPreview`
Some functions are only available with the Preview module until they become generally available and move to the AzureAd Module
- Module `MicrosoftTeams` or `SkypeOnlineConnector`
The OnlineConnector is deprecated, but the replacement function (`New-CsOnlineSession`) does not replace all functionality. The Username parameter is gone and with it seamless single-sign on.

## TROUBLESHOOTING NOTE

Help Files are available for all topics (soon) as well as automatically generated [DOCs](/docs) for each exported function.

If you find bugs, please report them by raising an Issue on this repo or send me a message to [TeamsFunctions@outlook.com](mailto:TeamsFunctions@outlook.com)

Please attach Verbose and/or Debug output of the Script in question and ideally anonymise the output if it contains PII.

## SEE ALSO

[about_TeamsFunctionsAliases](about_TeamsFunctionsAliases.md)

## KEYWORDS

- Functions
- CmdLets
- ReadMe
