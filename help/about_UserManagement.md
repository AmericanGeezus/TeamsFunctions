# AzureAd and Teams User Management

## about_UserManagement

## SHORT DESCRIPTION

Managing AzureAdUsers, Groups, ResourceAccounts for use in CQs and AAs.

## LONG DESCRIPTION

Finding Users, Groups or other objects is sometimes too complex for my taste. Using `Get-AzureAdUser -Searchstring "$UPN"` is fine, but sometimes I just want to bash in the UserPrincipalName or Group Name and get a result. Some helper functions that simplify input a bit and expand on the functionality of Callable Entity:

## CmdLets

| Function                                                  | Description                                                                                                                             |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| [`Find-AzureAdGroup`](../docs/Find-AzureAdGroup.md)               | Helper Function to find AzureAd Groups. Returns Objects if found. Simplifies Lookup and Search of Objects                               |
| [`Find-AzureAdUser`](../docs/Find-AzureAdUser.md)                 | Helper Function to find AzureAd Users. Returns Objects if found. Simplifies Lookup and Search of Objects                                |
| [`Find-TeamsCallableEntity`](../docs/Find-TeamsCallableEntity.md) | Searches all Call Queues and/or all Auto Attendants for a connected/targeted `Callable Entity` (TelURI, User, Group, Resource Account). |
| [`Get-TeamsCallableEntity`](../docs/Get-TeamsCallableEntity.md)   | Creates a new Object emulating the output of a `Callable Entity`, validating the Object type and its usability for CQs or AAs.          |
| [`New-TeamsCallableEntity`](../docs/New-TeamsCallableEntity.md)   | Used for Auto Attendants, creates a `Callable Entity` Object given a CallTarget (the type is enumerated through lookup)                 |

## Support CmdLet

| Function                                                    | Description                                                                                 |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| [`Test-AzureAdGroup`](../docs/Test-AzureAdGroup.md)                 | Testing whether the Group exists in AzureAd                                                 |
| [`Test-AzureAdUser`](../docs/Test-AzureAdUser.md)                   | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!) |
| [`Test-TeamsResourceAccount`](../docs/Test-TeamsResourceAccount.md) | Testing whether a Resource Account exists in AzureAd                                        |
| [`Test-TeamsUser`](../docs/Test-TeamsUser.md)                       | Testing whether the User exists in SkypeOnline/Teams                                        |

## EXAMPLES

{{ Code or descriptive examples of how to leverage the functions described. }}

## NOTE

{{ Note Placeholder - Additional information that a user needs to know.}}

## TROUBLESHOOTING NOTE

{{ Troubleshooting Placeholder - Warns users of bugs}}

{{ Explains behavior that is likely to change with fixes }}

## SEE ALSO

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

[about_TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)

## KEYWORDS

{{List alternate names or titles for this topic that readers might use.}}

- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
- TeamsCommonAreaPhone
- TeamsIPPhone
- TeamsAnalogDevice
