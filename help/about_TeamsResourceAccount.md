# Teams Resource Account

## about_TeamsResourceAccount

## SHORT DESCRIPTION

`CsOnlineApplicationInstance` is a mouthful, `TeamsResourceAccount` is easier

## LONG DESCRIPTION

Though you can now also provide a UserPrincipalName for `CsOnlineApplicationInstance` scripts, they are, I think, not telling you enough. IDs are used for the Application Type. These Scripts are wrapping around them, bind to the *UserPrincipalName* and offer more required information for properly managing Resource Accounts for Call Queues and Auto Attendants.

## CmdLets

| Function                                                              | Underlying Function                 | Description                                                                                                 |
| ---------------------------------------------------------------------: | ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| [`New-TeamsResourceAccount`](../docs/New-TeamsResourceAccount.md)       | Creates a Resource Account in Teams |                                                                                                             |
| [`Find-TeamsResourceAccount`](../docs/Find-TeamsResourceAccount.md)     | Find-CsOnlineApplicationInstance    | Finds Resource Accounts based on provided SearchString                                                      |
| [`Get-TeamsResourceAccount`](../docs/Get-TeamsResourceAccount.md)       | Get-CsOnlineApplicationInstance     | Queries Resource Accounts based on input: SearchString, Identity (UserPrincipalName), PhoneNumber, Type     |
| [`Set-TeamsResourceAccount`](../docs/Set-TeamsResourceAccount.md)       | Set-CsOnlineApplicationInstance     | Changes settings for a Resource Accounts, applying UsageLocation, Licenses and Phone Numbers, swapping Type |
| [`Remove-TeamsResourceAccount`](../docs/Remove-TeamsResourceAccount.md) | Remove-AzureAdUser                  | Removes a Resource Account and optionally (with -Force) also the Associations this account has.             |

## CmdLets for Association

Connecting these Resource Accounts to their Call Queues or Auto Attendants, while ironing out a few quirks, like being able to change the type of ResourceAccount (from CQ to AA or vice versa) before assigning or using friendly words rather than GUIDs for the Type or cleanly disconnecting accounts that have gone stuck is what additional value they bring on top of their main functionality.

| Function                                                                                    | Underlying Function                           | Description                                                                                          |
| -------------------------------------------------------------------------------------------: | --------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [`New-TeamsResourceAccountAssociation`](../docs/New-TeamsResourceAccountAssociation.md)       | New-CsOnlineApplicationInstanceAssociation    | Links one or more Resource Accounts to a Call Queue or an Auto Attendant                             |
| [`Get-TeamsResourceAccountAssociation`](../docs/Get-TeamsResourceAccountAssociation.md)       | Get-CsOnlineApplicationInstanceAssociation    | Queries links for one or more Resource Accounts to Call Queues or Auto Attendants. Also shows Status |
| [`Remove-TeamsResourceAccountAssociation`](../docs/Remove-TeamsResourceAccountAssociation.md) | Remove-CsOnlineApplicationInstanceAssociation | Removes a link for one or more Resource Accounts                                                     |

### Support CmdLets

| Function                                                          | Underlying Function | Description                                          |
| -----------------------------------------------------------------: | ------------------- | ---------------------------------------------------- |
| [`Test-TeamsResourceAccount`](../docs/Test-TeamsResourceAccount.md) |                     | Testing whether a Resource Account exists in AzureAd |

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

[about_TeamsCallQueue](about_TeamsCallQueue.md)

[about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)

[about_TeamsCallableEntity](about_TeamsCallableEntity.md)

## KEYWORDS

- Creation
- Configuration
- Management
- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
