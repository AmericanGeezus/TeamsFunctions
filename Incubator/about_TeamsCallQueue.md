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

# SHORT DESCRIPTION
{{ Short Description Placeholder }# ABOUT

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

{{ Short Description Placeholder }}

```
ABOUT TOPIC NOTE:
About topics can be no longer than 80 characters wide when rendered to text.
Any topics greater than 80 characters will be automatically wrapped.
The generated about topic will be encoded UTF-8.
```

## LONG DESCRIPTION

Microsoft has selected a GUID as the Identity the `CsCallQueue` scripts are a bit cumbersome for the average admin. Though the Searchstring parameter is available, enabling me to utilise it as a basic input method for `TeamsCallQueue` CmdLets. They query by *DisplayName*, which comes with a drawback for the `Set`-command: It requires a unique result. Also uses Filenames instead of IDs when adding Audio Files. Microsoft is continuing to improve these scripts, so I hope these can stand the test of time and make managing Call Queues easier.

## CmdLets

| Function                | Underlying Function | Description                                                        |
| ----------------------- | ------------------- | ------------------------------------------------------------------ |
| `Get-TeamsCallQueue`    | Get-CsCallQueue     | Queries a Call Queue with friendly inputs (UPN) and output         |
| `New-TeamsCallQueue`    | New-CsCallQueue     | Creates a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Set-TeamsCallQueue`    | Set-CsCallQueue     | Changes a Call Queue with friendly inputs (File Names, UPNs, etc.) |
| `Remove-TeamsCallQueue` | Remove-CsCallQueue  | Removes a Call Queue from the Tenant                               |

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
}

```
ABOUT TOPIC NOTE:
About topics can be no longer than 80 characters wide when rendered to text.
Any topics greater than 80 characters will be automatically wrapped.
The generated about topic will be encoded UTF-8.
```

# LONG DESCRIPTION
{{ Long Description Placeholder }}

## Optional Subtopics
{{ Optional Subtopic Placeholder }}

# EXAMPLES
{{ Code or descriptive examples of how to leverage the functions described. }}

# NOTE
{{ Note Placeholder - Additional information that a user needs to know.}}

# TROUBLESHOOTING NOTE
{{ Troubleshooting Placeholder - Warns users of bugs}}

{{ Explains behavior that is likely to change with fixes }}

# SEE ALSO
{{ See also placeholder }}

{{ You can also list related articles, blogs, and video URLs. }}

# KEYWORDS
{{List alternate names or titles for this topic that readers might use.}}

- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
