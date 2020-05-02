# Teams Scripts and Functions

This module is a collection of Teams-related PowerShell scripts and functions based on [SkypeFunctions by JeffBrown](https://github.com/JeffBrownTech/Skype). Please show your love. This is published separately (and with permission) rather than updated because I couldn't figure out Forks and Pull-Requests and by the time I had, I had substancially altered the code... 

Added improvements where sensible and updates where needed (Microsoft 365 License names). Renamed most Functions from "SkypeOnline" to "Teams" (Alias available for Backwards compatibility). Functions are relevant to Teams Backend Administration, focused on provisioning for Voice, especially Teams Direct Routing

## Available Functions

### Azure AD Related

- `Test-AzureAdModule`:       Verifying the Module is loaded
- `Test-AzureAdConnection`:   Verifying a Session exists
- `Test-AzureAdObject`:       Verifying the Object exists in AzureAd

### Skype Online Related

- `Test-SkypeOnlineModule`:       Verifying the Module is loaded
- `Test-SkypeOnlinedConnection`:  Verifying a Session exists
- `Test-SkypeOnlineObject`:       Verifying the Object exists in SkypeOnline

### PowerShell Session Creation

- `Connect-AzureAd`:              Not part of this Module, but a dependency: [`Install-Module AzureAd`](https://www.powershellgallery.com/packages/AzureAd)
- `Connect-SkypeOnline`:          Creates a Session to SkypeOnline/Teams (v7 also extends TimeOut Limit!)
- `Disconnect-SkypeOnline`:       Disconnects from a Session to SkypeOnline/Teams
- `Connect-MicrosoftTeams`:       Not part of this Module, not a dependency. Purely listed for distinction: [`Install-Module MicrosoftTeams`](https://www.powershellgallery.com/packages/MicrosoftTeams)

### Licensing related Functions

- `Get-TeamsUserLicense`:         Queries licenses assigned to a User and displays visual output
- `Get-TeamsTenantLicenses`:      Queries licenses present on the Tenant
- `Add-TeamsUserLicense`:         Adds one or more Licenses specified per Switch to the provided Identity
- `Test-TeamsUserLicense`:        Tests an individual Service Plan or a License Package against the provided Identity

### Policy related Functions

- `Set-TeamsUserPolicy`:          Assigns specific Policies to a User
- `Test-TeamsTenantPolicy`:       Tests whether any Policy is present in the Tenant 

### Other Functions

- `Get-SkypeOnlineConferenceDialInNumbers`:
                                Gathers Dial-In Conferencing Numbers for a specific Domain
- `Remove-TenantDialPlanNormalizationRule`:
                                Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove
- `Test-TeamsExternalDNS`:      Tests DNS Records for Skype for Business Online and Teams 

## Update/Extension plans

- Adding all Policies to `Set-TeamsUserPolicy` - currently only 6 are supported.
- Simplifying creation and provisioning of Resource Accounts for Call Queues and Auto Attendants
