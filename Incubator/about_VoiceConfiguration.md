# ABOUT

## about_ABOUT

```
ABOUT TOPIC NOTE:
The first header of the about topic should be the topic name.
The second header contains the lookup name used by the help system.

IE:
# Some Help Topic Name
## SomeHelpTopicFileName

This will be transformed into the text file
as `about_SomeHelpTopicFileName`.
Do not include file extensions.
The second header should have no spaces.
```

## SHORT DESCRIPTION

Querying and setting Teams Voice Configuration, both for Direct Routing and Calling Plans

## LONG DESCRIPTION

{{ Long Description Placeholder }}

## CmdLets

| Function                             | Description                                                                                                                                       |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Enable-TeamsUserForEnterpriseVoice` | Validates User License requirements and enables a User for Enterprise Voice (I needed a shortcut)                                                 |
| `Find-TeamsUserVoiceRoute`           | Queries a users Voice Configuration chain to finding a route a call takes for a User (more granular with a `-DialedNumber`)                       |
| `Find-TeamsUserVoiceConfig`          | Queries Voice Configuration parameters against all Users on the tenant. Finding assignments of a number, usage of a specific OVP or TDP, etc.     |
| `Get-TeamsTenantVoiceConfig`         | Queries Voice Configuration present on the Tenant. Switches are available for better at-a-glance visibility                                       |
| `Get-TeamsUserVoiceConfig`           | Queries Voice Configuration assigned to a User and displays visual output. At-a-glance concise output, extensible through `-DiagnosticLevel`      |
| `Remove-TeamsUserVoiceConfig`        | Removes a Voice Configuration set from the provided Identity. User will become "un-configured" for Voice in order to apply a new Voice Config set |
| `Set-TeamsUserVoiceConfig`           | Applies a full Set of Voice Configuration (Number, Online Voice Routing Policy, Tenant Dial Plan, etc.) to the provided Identity                  |
| `Test-TeamsUserVoiceConfig`          | Tests an individual VoiceConfig Package against the provided Identity                                                                             |

### Support CmdLets

The others are mainly helping to cut down on typing when doing stuff quickly. Sometimes knowing just enough is enough, like knowing only the names of the Tenant Dial Plan or the Online Voice Routing Policy in question is just what I need, nothing more.

| Function          | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| `Get-TeamsTenant` | Get-CsTenant gives too much output? This can help.                                  |
| `Get-TeamsOVP`    | Get-CsOnlineVoiceRoutingPolicy is too long to type? Here is a shorter one :)        |
| `Get-TeamsOPU`    | Get-CsOnlinePstnUsage is too clunky. Here is a shorter one, with a search function! |
| `Get-TeamsOVR`    | Get-CsOnlineVoiceRoute                                                              |
| `Get-TeamsMGW`    | Get-CsOnlinePstnGateway                                                             |
| `Get-TeamsTDP`    | Get-TeamsTenantDialPlan is too long to type. Also, we only want the names...        |
| `Get-TeamsVNR`    | Displays all Voice Normalization Rules (VNR) for a given Dial Plan                  |

### Legacy support CmdLets

These are the last remnants of the old SkypeFunctions module. Their functionality has been barely touched.
| Function                                 | Description                                                                              |
| ---------------------------------------- | ---------------------------------------------------------------------------------------- |
| `Get-SkypeOnlineConferenceDialInNumbers` | Gathers Dial-In Conferencing Numbers for a specific Domain                               |
| `Remove-TenantDialPlanNormalizationRule` | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove |

>[NOTE] These commands are being evaluated for revival and re-integration.

## EXAMPLES

````powershell
# Example 1 - Teams User Voice Route
Find-TeamsUserVoiceRoute -Identity John@domain.com -DialedNumber +15551234567
````

Evaluating the Voice Routing for one user based on the Number being dialed

````powershell
# Example 1 - Output

````

````powershell
# Example 2 - Teams User Voice Config
Find-TeamsUserVoiceConfig [-PhoneNumber] "555-1234 567"
````

Finding the provided Phone number in a normalised form (removing special characters) assigned to any User, returning output based on number of objects returned.
Get-TeamsUserVoiceConfig and Find-TeamsUserVoiceConfig return the same base output, however the Get-Command does have the option to expand on the output object and drill deeper.

- Get-TeamsUserVoiceConfig targets an Identity (UserPrincipalName)
- Find-TeamsUserVoiceConfig can search for PhoneNumbers, Extensions, ID or commonalities like OVP or TDPs
- Pipeline is available for both CmdLets

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

{{ Note Placeholder - Additional information that a user needs to know.}}

## Development Status

- The main CmdLets are pretty mature, tough may find to be tweaked here and there.
- The Support CmdLets are fine, they are doing what they are supposed to do
- The Legacy CmdLets are in need or re-evaluation and come as-is.

## TROUBLESHOOTING NOTE

{{ Troubleshooting Placeholder - Warns users of bugs}}

{{ Explains behavior that is likely to change with fixes }}

## SEE ALSO

{{ See also placeholder }}

{{ You can also list related articles, blogs, and video URLs. }}

## KEYWORDS

{{List alternate names or titles for this topic that readers might use.}}

- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
