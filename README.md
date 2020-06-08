# Teams Scripts and Functions

## Origins

This module is a collection of Teams-related PowerShell scripts and functions based on [SkypeFunctions by JeffBrown](https://github.com/JeffBrownTech/Skype). Please show your love. This is published separately (and with permission) rather than updated because I couldn't figure out Forks and Pull-Requests and by the time I had, I had substantially altered the code...

The first goal was to refresh what needs adding (for example, License names for Microsoft 365). The second goal was to learn and understand PowerShell better and test all Functions for applicability in Teams. Once vetted, some functions have been renamed from "SkypeOnline" to "Teams" (others, like the "Connect"-scripts have been retained).

## Current Scope

Provisioning Users for Enterprise Voice (Direct Routing), covering Licensing, Policy Assignment, etc.
Backup and Restore for EV and Tenant.

Building a baseline to add more.

## Planned Scope

As this develops, I try to incorporate more and more to manage and maintain your Teams Tenant.
Anything related to Voice functionality has priority, Resource Accounts and Call Queues being the first.
Auto Attendants will have to be evaluated, as they are very complex and require multiple single steps from File management to Schedules, Call Flows etc. Scripts, if started need to solve a particularly nasty issue or simplify steps by verifying and combining steps.

Scripts related to creating Direct Routing implementation are present already, but created in Excel which I cannot currently transfer easily to a better PS script

Bulk provisioning steps are also evaluated, once I figure out how Begin/Process/End factor in to Pipeline input, I will be able to start bulking up some more. Reading from Excel is a start

## Submitting Scripts

If you have something that could cover the above and want to submit it to be integrated here, please get in touch. I already have Backup Scripts from Ken Lasko that solve what I needed. I am grateful for every small addition to the Module. :)

## Available Functions

### Connecting, Disconnecting and Testing PowerShell Sessions

- `Connect-AzureAd`:                Not part of this Module, but a dependency: [`Install-Module AzureAd`](https://www.powershellgallery.com/packages/AzureAd)
- `Connect-MicrosoftTeams`:         Not part of this Module, not a dependency. Purely listed for distinction: [`Install-Module MicrosoftTeams`](https://www.powershellgallery.com/packages/MicrosoftTeams)
- `Connect-SkypeOnline`:            Creates a Session to SkypeOnline (v7 also extends TimeOut Limit!)
- `Connect-SkypeTeamsAndAAD`*:      Creates a Session to SkypeOnline, MicrosoftTeams and AzureAD in one go (one authentication only!)
- `Disconnect-SkypeOnline`:         Disconnects from a Session to SkypeOnline
- `Disconnect-SkypeTeamsAndAAD`:    Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD
- `Test-AzureAdConnection`:         Verifying a Session to AzureAD exists
- `Test-MicrosoftTeamsConnection`:  Verifying a Session to MicrosoftTeams exists
- `Test-SkypeOnlineConnection`:     Verifying a Session to SkypeOnline exists
- `Test-AzureAdModule`:             Verifying the Module is loaded, deprecated due to performance (not needed)
- `Test-MicrosoftTeamsModule`:      Verifying the module is loaded.
- `Test-SkypeOnlineModule`:         Verifying the Module is loaded, deprecated due to performance (needed, but not really)

*) Aliases are available: Connect-Me and CON (because I don't want to type as much :))

### Adding value to AzureAD

I am missing some functionality in Azure AD, hence me creating some scripts to help me out:

#### Lookup

- `Get-AzureADUserFromUPN`:         Get-AzureADUser does not accept UserPrincipalName as input. This fixes that :)

#### Licensing related Functions

- `Get-TeamsUserLicense`:           Queries licenses assigned to a User and displays visual output
- `Get-TeamsTenantLicenses`:        Queries licenses present on the Tenant. Output needs improving (Objectification)
- `Add-TeamsUserLicense`:           Adds one or more Licenses specified per Switch to the provided Identity
- `Test-TeamsUserLicense`:          Tests an individual Service Plan or a License Package against the provided Identity

### Adding value to Skype Online

The following are introduced to help with SkypeOnline/Teams related features:

#### Resource Accounts

- `New-TeamsResourceAccount`:       Creates a Resource Account in Teams (CsOnlineApplicationInstance)
- `Get-TeamsResourceAccount`:       Queries Resource Accounts based on input: SearchString, Identity (UPN), PhoneNumber, Type (Call Queue or Auto Attendant)
- `Set-TeamsResourceAccount`:       Changes settings for a Resource Accounts, swapping License (doesn't work right now...), Type (experimental, 'should work' according to Microsoft)
- `Remove-TeamsResourceAccount`:    Removes a Resource Account and optionally (with -Force) also the Associations this account has.

#### Call Queues

- `New-TeamsCallQueue`:             Creates a Call Queue like New-CsCallQueue, but with friendly inputs (File Names, UPNs, etc.)
- `Get-TeamsCallQueue`:             Queries a Call Queue like Get-CsCallQueue, but with friendly inputs (UPN) and output
- `Set-TeamsCallQueue`:             Changes a Call Queue like Set-CsCallQueue, but with friendly inputs (File Names, UPNs, etc.)
- `Remove-TeamsCallQueue`:          Removes a Call Queue like Remove-CsUser does. Just here to complete the set :)

#### Policy related Functions

- `Set-TeamsUserPolicy`:            Assigns specific Policies to a User
- `Test-TeamsTenantPolicy`:         Tests whether any Policy is present in the Tenant

#### Backup and Restore

- `Backup-TeamsEV`:                 Curtesy of Ken Lasko, takes a backup of all EnterpriseVoice related features in Teams.
- `Restore-TeamsEV`:                Curtesy of Ken Lasko, makes a full authoritative restore of all EnterpriseVoice related features. Handle with care!
- `Backup-TeamsTenant`:             An adaptation of the above, backing up the whole tenant in the process.

#### Other Functions

- `Get-SkypeOnlineConferenceDialInNumbers`:
                                    Gathers Dial-In Conferencing Numbers for a specific Domain
- `Remove-TenantDialPlanNormalizationRule`:
                                    Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove

#### Continue Testing

- `Test-TeamsExternalDNS`:          Tests DNS Records for Skype for Business Online and Teams
- `Test-TeamsUser`:                 Testing whether the User exists in SkypeOnline/Teams
- `Test-AzureAdUser`:               Testing whether the User exists in AzureAd
- `Test-AzureAdGroup`:              Testing whether the Group exists in AzureAd

#### Helper Functions

The following are exported, there are a handful of other ones that help with smaller tasks around Licensing and lookup but do not qualify to be exported.

- `Get-AzureAdAssignedAdminRoles`:  Queries Admin Roles assigned to one User (UPN). Somehow that wasn't as easy to do...
- `New-AzureAdLicenseObject`:       Creates a new License Object to be used with `Set-AzureADUserLicense`
- `Get-SkuPartNumberFromSkuID`:     Tiny little helper translating SkuPartNumber (License Name) to their SkuID
- `Get-SkuIDFromSkuPartNumber`:     Tiny little helper translating SkuID to their SkuPartNumber (License Name)
- `Remove-StringSpecialCharacter`:  By Francois-Xavier Cat. Removes special characters from strings. Incorporated here only because I need to rely on it.
- `Format-StringForUse`:            Same as above, though my own approach based on an anonymous coder. Applies rules for DisplayName and UPN respectively.

## A look ahead

### Update/Extension plans

- Adding all Policies to `Set-TeamsUserPolicy` - currently only 6 are supported.
- Simplifying creation and provisioning of Resource Accounts for Call Queues and Auto Attendants
- Comparing backups, changed elements for Change control... Looking at Lee Fords backup scripts :)

### Limitations

- `Connect-SkypeOnline` still seems to be timing out, despite `Enable-CsOnlineSessionForReconnection` set - odd
- **ResourceAccount**-Scripts are still being tested. GET is good. REMOVE seems to work fine too.
- Association between Resource Account and CallQueue/AutoAttendant is not yet built. `Remove-TeamsResourceAccount` -Force tries to sever the connection. Experimental still.
- **CallQueue**-Scripts are untested. Handle with Care! Will have a closer look in the coming weeks to iron them out.

Enjoy
