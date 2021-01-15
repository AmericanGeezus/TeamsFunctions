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

My take on AutoAttendants

## LONG DESCRIPTION

The complexity of the AutoAttendants and design principles of PowerShell ("one function does one thing and one thing only") means that the `CsAutoAttendant` CmdLets are feeling to be all over the place. Multiple CmdLets have to be used in conjunction in order to create an Auto Attendant. No defaults are available. The `TeamsAutoAttendant` CmdLets try to address that. From the basic NEW-Command that - without providing *any* Parameters (except the name of course) can create an Auto Attendant entity. This simplifies things a bit and tries to get you 80% there without lifting much of a finger. Amending it afterwards in the Admin Center is my current mantra. See Support Functions for more versatility!

## CmdLets

| Function                    | Underlying Function    | Description                                                                                  |
| --------------------------- | ---------------------- | -------------------------------------------------------------------------------------------- |
| `Get-TeamsAutoAttendant`    | Get-CsAutoAttendant    | Queries an Auto Attendant                                                                    |
| `New-TeamsAutoAttendant`    | New-CsAutoAttendant    | Creates an Auto Attendant with defaults (Disconnect, Standard Business Hours schedule, etc.) |
| Set-TeamsAutoAttendant      | Set-CsAutoAttendant    | Changes an Auto Attendant with friendly input. Alias to Set-CsAutoAttendant only!            |
| `Remove-TeamsAutoAttendant` | Remove-CsAutoAttendant | Removes an Auto Attendant from the Tenant                                                    |

## Support CmdLets

Creating a Menu or a Call Flow feels clunky to me, the commands require excessive chaining in order to create a full Auto Attendant. The complexity of the AutoAttendants also has spawned a few support functions. Keeping in step with them and simplifying their use a bit is what my take on them represents.

| Function                                      | Underlying Function                        | Description                                                                                                         |
| --------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `Import-TeamsAudioFile`                       | Import-CsOnlineAudioFile                   | Imports an Audio File for use within Call Queues or Auto Attendants                                                 |
| `Get-PublicHolidayCountry`                    |                                            | Lists all supported Countries for Public Holidays (from Nager.Date)                                                 |
| `Get-PublicHolidayList`                       |                                            | Lists all Public Holidays for a specific Country (from Nager.Date)                                                  |
| `New-TeamsAutoAttendantCallFlow`              | New-CsAutoAttendantCallFlow                | Creates a `CallFlow` Object with a Prompt and Menu and some default options.                                        |
| New-TeamsAutoAttendantCallHandlingAssociation | New-CsAutoAttendantCallHandlingAssociation | Not written yet, a CallHandlingAssociation is created with only contain a `Schedule` object and a `CallFlow` object |
| `New-TeamsAutoAttendantDialScope`             | New-CsAutoAttendantDialScope               | Creates a `DialScope` Object for provided Office 365 Group Names                                                    |
| `New-TeamsAutoAttendantMenu`                  | New-CsAutoAttendantMenu                    | Creates a `Menu` Object for Menu Options in two possible inputs                                                     |
| `New-TeamsAutoAttendantMenuOption`            | New-CsAutoAttendantMenuOption              | Creates a `MenuOption` Object for easier use                                                                        |
| `New-TeamsAutoAttendantPrompt`                | New-CsAutoAttendantPrompt                  | Creates a `Prompt` Object and simplifies usage as it determines the type based on the input string.                 |
| `New-TeamsAutoAttendantSchedule`              | New-CsAutoAttendantSchedule                | Creates a `Schedule` Object and simplifies input for use in AA CHA. Multiple default options are available          |
| `New-TeamsCallableEntity`                     | New-CsAutoAttendantCallableEntity          | Creates a `CallableEntity` Object given a CallTarget (type is enumerated)                                           |

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
