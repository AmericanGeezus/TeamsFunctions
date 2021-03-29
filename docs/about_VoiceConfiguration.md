# Voice Configuration

## about_VoiceConfiguration

## SHORT DESCRIPTION

All things needed to configure Users for Direct Routing or Calling Plans

## LONG DESCRIPTION

Ascertaining accurate information about the Tenant and an individual user account (or resource account) is the cornerstone of these CmdLets. `Get-TeamsUserVoiceConfig` therefore carefully selects parameters from the `CsOnlineUser`-Object and, with the `DiagnosticLevel`-switch taps further and further into parameters that may be relevant for troubleshooting issues, finally also padding the object with keys from the `AzureAdUser`-Object.

Applying the required elements to enable a User for Direct Routing or Calling Plans should make this easier, more reliable and faster for all admins

## CmdLets

| Function                             | Description                                                                                                                                       |
| ------------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Enable-TeamsUserForEnterpriseVoice`](/docs/Enable-TeamsUserForEnterpriseVoice.md) | Validates User License requirements and enables a User for Enterprise Voice (I needed a shortcut)                                                 |
| [`Find-TeamsUserVoiceRoute`](/docs/Find-TeamsUserVoiceRoute.md)           | Queries a users Voice Configuration chain to finding a route a call takes for a User (more granular with a `-DialedNumber`)                       |
| [`Find-TeamsUserVoiceConfig`](/docs/Find-TeamsUserVoiceConfig.md)          | Queries Voice Configuration parameters against all Users on the tenant. Finding assignments of a number, usage of a specific OVP or TDP, etc.     |
| [`Get-TeamsTenantVoiceConfig`](/docs/Get-TeamsTenantVoiceConfig.md)         | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                       |
| [`Get-TeamsUserVoiceConfig`](/docs/Get-TeamsUserVoiceConfig.md)           | Queries Voice Configuration assigned to a User and displays visual output. At-a-glance concise output, extensible through `-DiagnosticLevel`      |
| [`Remove-TeamsUserVoiceConfig`](/docs/Remove-TeamsUserVoiceConfig.md)        | Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set |
| [`Set-TeamsUserVoiceConfig`](/docs/Set-TeamsUserVoiceConfig.md)           | Applies a full Set of Voice Configuration (Number, Online Voice Routing Policy, Tenant Dial Plan, etc.) to the provided Identity                  |
| [`Test-TeamsUserVoiceConfig`](/docs/Test-TeamsUserVoiceConfig.md)          | Tests an individual VoiceConfig Package against the provided Identity                                                                             |

### Support CmdLets

Diving more into Voice Configuration for the Tenant and defining Direct Routing breakouts, though the provided CmdLets are solid since its Lync days, getting information fast and without the hassle of piping, filtering and selecting was the goal behind creating the below shortcuts.

| Function          | Description                                                                         |
| -----------------: | ----------------------------------------------------------------------------------- |
| [`Get-TeamsTenant`](/docs/Get-TeamsTenant.md) | Get-CsTenant gives too much output? This can help.                                  |
| [`Get-TeamsOVP`](/docs/Get-TeamsOVP.md)    | Get-CsOnlineVoiceRoutingPolicy is too long to type? Here is a shorter one :)        |
| [`Get-TeamsOPU`](/docs/Get-TeamsOPU.md)    | Get-CsOnlinePstnUsage is too clunky. Here is a shorter one, with a search function! |
| [`Get-TeamsOVR`](/docs/Get-TeamsOVR.md)    | Get-CsOnlineVoiceRoute, just more concise                                                              |
| [`Get-TeamsMGW`](/docs/Get-TeamsMGW.md)    | Get-CsOnlinePstnGateway, but a bit nicer                                                             |
| [`Get-TeamsTDP`](/docs/Get-TeamsTDP.md)    | Get-TeamsTenantDialPlan is too long to type. Also, we only want the names...        |
| [`Get-TeamsVNR`](/docs/Get-TeamsVNR.md)    | Displays all Voice Normalization Rules (VNR) for a given Dial Plan                  |

### Legacy support CmdLets

These are the last remnants of the old SkypeFunctions module. Their functionality has been barely touched.
| Function                                 | Description                                                                              |
| ---------------------------------------: | ---------------------------------------------------------------------------------------- |
| [`Get-SkypeOnlineConferenceDialInNumbers`](/docs/Get-SkypeOnlineConferenceDialInNumbers.md) | Gathers Dial-In Conferencing Numbers for a specific Domain                               |
| [`Remove-TenantDialPlanNormalizationRule`](/docs/Remove-TenantDialPlanNormalizationRule.md) | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove |

>[!NOTE] These commands are being evaluated for revival and re-integration.

## EXAMPLES

### Example 1 - Teams User Voice Route

````powershell
Find-TeamsUserVoiceRoute -Identity John@domain.com -DialedNumber +15551234567
````

Evaluating the Voice Routing for one user based on the Number being dialed

```powershell
# Example 1 - Output
TBC
```

### Example 2 - Finding Objects with Find-TeamsUserVoiceConfig

````powershell
# The following are some examples for the Voice Config CmdLets
Find-TeamsUserVoiceConfig [-PhoneNumber] "555-1234 567"
# Finds Objects with the normalised number '*5551234567*' (removing special characters)

Find-TeamsUserVoiceConfig -Extension "12-345"
# Finds Objects which have any Extension starting with 12345 assigned (removing special characters)
# NOTE: The CmdLet is searching explicitely for '*;ext=12345*'

Find-TeamsUserVoiceConfig -ConfigurationType CallingPlans
Find-TeamsUserVoiceConfig -VoicePolicy BusinessVoice
# Finds all Objects configured for CallingPlans with two different metrics.

Find-TeamsUserVoiceConfig -Identity John@domain.com
Get-TeamsUserVoiceConfig [-Identity] John@domain.com
# FIND will return either a list of UserPrincipalNames found, or
# if limited results are found, executes GET to display the output.
````

Find can look for User Objects (Users, Common Area Phones or Resource Accounts) returning output based on number of objects returned.
Get-TeamsUserVoiceConfig and Find-TeamsUserVoiceConfig return the same base output, however the Get-Command does have the option to expand on the output object and drill deeper.

- Get-TeamsUserVoiceConfig targets an Identity (UserPrincipalName)
- Find-TeamsUserVoiceConfig can search for PhoneNumbers, Extensions, ID or commonalities like OVP or TDPs
- Pipeline is available for both CmdLets

### Example 3 - Voice Configuration Object with Get-TeamsUserVoiceConfig

````powershell
# Example 2 - Output shows a Direct Routing user correctly provisioned but not yet moved to Teams
UserPrincipalName          : John@domain.com
SipAddress                 : sip:John@domain.com
DisplayName                : John Doe
ObjectId                   : d13e9d53-5dd4-7392-b123-de45b16a7cb4
Identity                   : CN=d13e9d53-5dd4-7392-b123-de45b16a7cb4,OU=d23afe19-5a33-893a
                             -caf1-70b6cd9a8f6e,OU=OCS Tenants,DC=lync0e001,DC=local
HostingProvider            : SRV:
ObjectType                 : User
InterpretedUserType        : HybridOnpremTeamsOnlyUser
InterpretedVoiceConfigType : DirectRouting
TeamsUpgradeEffectiveMode  : TeamsOnly
VoicePolicy                : HybridVoice
UsageLocation              : US
LicensesAssigned           : Office 365 E5
CurrentCallingPlan         :
PhoneSystemStatus          : Success
PhoneSystem                : True
EnterpriseVoiceEnabled     : True
HostedVoiceMail            : True
TeamsUpgradePolicy         :
OnlineVoiceRoutingPolicy   : OVP-EMEA
TenantDialPlan             : DP-US
TelephoneNumber            :
LineURI                    : tel:+15551234567;ext=4567
OnPremLineURI              : tel:+15551234567;ext=4567
````

## NOTE

Voice Config CmdLets started out just limiting the output of Get-CsOnlineUser to retain an overview and avoid unnecessary scrolling and find information faster and in a more consistent way.

## Development Status

- Main CmdLets are complete, tough may find to be tweaked here and there.
- Support CmdLets are complete
- The Legacy CmdLets are in need or re-evaluation and come as-is.

## TROUBLESHOOTING NOTE

Thoroughly tested, but Unit-tests for these CmdLets are not yet available.

None needed. Edge-cases might still lurk that prevent Set-TeamsUserVoiceConfig to succeed. Please raise issues for them, happy to add more checks to validate specific scenarios.

## SEE ALSO

- [about_TeamsLicensing](about_TeamsLicensing.md)
- [about_UserManagement](about_UserManagement.md)
- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)
- [about_Supporting_Functions](about_Supporting_Functions.md)

## KEYWORDS

- Direct Routing
- Calling Plans
- Licensing
- PhoneSystem
- EnterpriseVoice
- Provisioning
