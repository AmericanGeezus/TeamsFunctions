# TeamsFunctions - An Overview

## about_TeamsFunctions

## SHORT DESCRIPTION

Teams Voice CmdLets adding and improving on AzureAd and MicrosoftTeams CmdLets

## LONG DESCRIPTION

All CmdLets are designed to help with Administration of Users, Common Area Phones, Resource Accounts, Call Queues and Auto Attendants, incl. Licensing, User Voice Configuration with Calling Plans and Direct Routing.

## TOPICS COVERED

This module currently contains over 85 Functions covering a broad area of Teams Functions for Admins: From Session Connection and activating Admin Roles in PIM to User Administration, Licensing and Voice Configuration all the way to Resource Accounts, Call Queues, Auto Attendants

Each topic will get its own ABOUT file soon, diving deeper into the Scripts.

- SkypeOnline Session connection, reconnection and verification
- AzureAd Licensing: Tenant queries, User assignments and verification
- AzureAd Privileged Identity Management: Role Activation
- Object Preparation for EnterpriseVoice Configuration
- Teams Voice Configuration: Direct Routing and Calling Plans
- Teams Common Area Phone: New CmdLets (currently in testing!)
- Teams Analog Contact Object: New CmdLets (coming soon)
- Teams Resource Account: Improvements on existing CmdLets
- Teams Call Queue: Improvements on existing CmdLets
- Teams Auto Attendant: Improvements on existing CmdLets
- Support and Helper functions for Admin tasks

## EXAMPLES

Until proper maturity has been reached, updates are released monthly. Bugfixes are added to as pre-releases in a weekly cadence.

- Monthly Cycle: `Update-Module TeamsFunctions`
- Weekly Cycle: `Update-Module TeamsFunctions -AllowPrerelease`

## NOTE

This seems to be a constant work-in progress so please bear with me with any issues you may find. I am addressing them pretty rapidly, but I am doing this alone and outside my day-job in my spare time. Cheers.

## REQUIREMENTS

- PowerShell v5.1 is required, v7.1 works though is still being tested
- Module `AzureAd` or `AzureAdPreview`
Some functions are only available with the Preview module until they become generally available and move to the AzureAd Module
- Module `MicrosoftTeams` or `SkypeOnlineConnector`
The OnlineConnector is deprecated, but the replacement function (`New-CsOnlineSession`) does not replace all functionality. The Username parameter is gone and with it seamless single-sign on.

## TROUBLESHOOTING NOTE

[Help Files](/help) are available for all topics as well as automatically generated [docs](/docs) for each exported function.

If you find bugs, please report them by raising an Issue on this repo or send me a message to [TeamsFunctions@outlook.com](mailto:TeamsFunctions@outlook.com)

Please attach `Verbose` and/or `Debug` output of the Script in question and anonymise the output to remove personally identifiable data.

## SEE ALSO

[about_TeamsFunctionsAliases](about_TeamsFunctionsAliases.md)

[about_TeamsSession](about_TeamsSession.md)

[about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)

[about_TeamsCallQueue](about_TeamsCallQueue.md)

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

[about_Licensing](about_Licensing.md)

[about_UserManagement](about_UserManagement.md)

[about_VoiceConfiguration](about_VoiceConfiguration.md)

[about_Supporting_Functions](about_Supporting_Functions.md)

## KEYWORDS

- Functions
- CmdLets
- ReadMe
