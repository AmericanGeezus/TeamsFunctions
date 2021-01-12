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

## EXAMPLES

{{ Code or descriptive examples of how to leverage the functions described. }}

## NOTE

{{ Note Placeholder - Additional information that a user needs to know.}}

## Development Status

{{ Note Placeholder - Additional information that a user needs to know.}}


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
