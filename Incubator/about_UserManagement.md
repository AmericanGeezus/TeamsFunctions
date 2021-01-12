# AzureAd and Teams User Management

## about_UserManagement

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

Finding Users, Groups or other objects is sometimes too complex for my taste. Using `Get-AzureAdUser -Searchstring "$UPN"` is fine, but sometimes I just want to bash in the UserPrincipalName or Group Name and get a result. Some helper functions that simplify input a bit and expand on the functionality of Callable Entity:

## CmdLets

| Function                   | Description                                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `Find-AzureAdGroup`        | Helper Function to find AzureAd Groups. Returns Objects if found. Simplifies Lookup and Search of Objects                               |
| `Find-AzureAdUser`         | Helper Function to find AzureAd Users. Returns Objects if found. Simplifies Lookup and Search of Objects                                |
| `Find-TeamsCallableEntity` | Searches all Call Queues and/or all Auto Attendants for a connected/targeted `Callable Entity` (TelURI, User, Group, Resource Account). |
| `Get-TeamsCallableEntity`  | Creates a new Object emulating the output of a `Callable Entity`, validating the Object type and its usability for CQs or AAs.          |
| `New-TeamsCallableEntity`  | Used for Auto Attendants, creates a `Callable Entity` Object given a CallTarget (the type is enumerated through lookup)                 |


## Support CmdLet

| Function                          | Description                                                                                                 |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Test-AzureAdGroup`               | Testing whether the Group exists in AzureAd                                                                 |
| `Test-AzureAdUser`                | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!)                 |
| `Test-TeamsResourceAccount`       | Testing whether a Resource Account exists in AzureAd                                                        |
| `Test-TeamsUser`                  | Testing whether the User exists in SkypeOnline/Teams                                                        |

## EXAMPLES

{{ Code or descriptive examples of how to leverage the functions described. }}

## NOTE

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
