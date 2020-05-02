# Teams Scripts and Functions

This is a collection of Skype-related PowerShell scripts and modules JeffBrown has written. Please show your love https://github.com/JeffBrownTech/
I added Teams Functions and updated existing Functions to be relevant for Teams and Teams Direct Routing

## Available Scripts

### Testing Azure AD Information

- Test-AzureAdModule:       Verifying the Module is loaded
- Test-AzureAdConnection:   Verifying a Session exists
- Test-AzureAdObject:       Verifying the Object exists in AzureAd

### Testing Skype Online Information

- Test-SkypeOnlineModule:       Verifying the Module is loaded
- Test-SkypeOnlinedConnection:  Verifying a Session exists
- Test-SkypeOnlineObject:       Verifying the Object exists in SkypeOnline

### PowerShell Session Creation

- Connect-AzureAd:              Dependency. Not part of this Module. 
                                Install-Module AzureAd - https://www.powershellgallery.com/packages/AzureAd
- Connect-SkypeOnline:          Part of this Module
- Disconnect-SkypeOnline:       Part of this Module
- Connect-MicrosoftTeams:       Not required for functions. Not part of this Module. 
                                Install-Module MicrosoftTeams - https://www.powershellgallery.com/packages/MicrosoftTeams

### Licensing related Functions

- Get-TeamsUserLicense:         Queries licenses assigned to a User and displays visual output
- Get-TeamsTenantLicenses:      Queries licenses present on the Tenant
- Add-TeamsUserLicense:         Adds one or more Licenses specified per Switch to the provided Identity
- Test-TeamsUserLicense:        Tests an individual Service Plan or a License Package against the provided Identity

### Policy related Functions

- Set-TeamsUserPolicy:          Assigns specific Policies to a User
- Test-TeamsTenantPolicy:       Tests whether any Policy is present in the Tenant 

### Other Functions

- Get-SkypeOnlineConferenceDialInNumbers
                                Gathers Dial-In Conferencing Numbers for a specific Domain
- Remove-TenantDialPlanNormalizationRule
                                Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove
- Test-TeamsExternalDNS         Tests DNS Records for Skype for Business Online and Teams 