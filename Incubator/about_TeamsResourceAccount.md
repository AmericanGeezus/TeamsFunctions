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

{{ Short Description Placeholder }}

```
ABOUT TOPIC NOTE:
About topics can be no longer than 80 characters wide when rendered to text.
Any topics greater than 80 characters will be automatically wrapped.
The generated about topic will be encoded UTF-8.
```

## LONG DESCRIPTION

Though you can now also provide a UserPrincipalName for `CsOnlineApplicationInstance` scripts, they are, I think, not telling you enough. IDs are used for the Application Type. These Scripts are wrapping around them, bind to the *UserPrincipalName* and offer more required information for properly managing Resource Accounts for Call Queues and Auto Attendants.

## CmdLets

| Function                      | Underlying Function                 | Description                                                                                                 |
| ----------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccount`    | Creates a Resource Account in Teams |                                                                                                             |
| `Find-TeamsResourceAccount`   | Find-CsOnlineApplicationInstance    | Finds Resource Accounts based on provided SearchString                                                      |
| `Get-TeamsResourceAccount`    | Get-CsOnlineApplicationInstance     | Queries Resource Accounts based on input: SearchString, Identity (UserPrincipalName), PhoneNumber, Type     |
| `Set-TeamsResourceAccount`    | Set-CsOnlineApplicationInstance     | Changes settings for a Resource Accounts, applying UsageLocation, Licenses and Phone Numbers, swapping Type |
| `Remove-TeamsResourceAccount` | Remove-AzureAdUser                  | Removes a Resource Account and optionally (with -Force) also the Associations this account has.             |


## CmdLets for Association

| Function                                 | Underlying Function                           | Description                                                                                          |
| ---------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `New-TeamsResourceAccountAssociation`    | New-CsOnlineApplicationInstanceAssociation    | Links one or more Resource Accounts to a Call Queue or an Auto Attendant                             |
| `Get-TeamsResourceAccountAssociation`    | Get-CsOnlineApplicationInstanceAssociation    | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants. Also shows Status |
| `Remove-TeamsResourceAccountAssociation` | Remove-CsOnlineApplicationInstanceAssociation | Removes a link for one or more Resource Accounts                                                     |

### Support CmdLets

| Function                                 | Underlying Function                           | Description                                                                                          |
| ---------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `Test-TeamsResourceAccount`       | Testing whether a Resource Account exists in AzureAd                                                        |

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
