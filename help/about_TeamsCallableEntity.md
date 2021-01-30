# Teams Callable Entity

## about_TeamsCallableEntity

## SHORT DESCRIPTION

Callable Entities are Objects that CQs or AAs can direct calls to.

## LONG DESCRIPTION

Each type of Object has different requirement to meet before they can be used. Users, for example need to be Licensed with Teams and PhoneSystem, which not only has to be assigned but the respective ServicePlan must be enabled before they can be enabled for Enterprise Voice. Once enabled, they can receive a Phone Number in order to place or receive calls via the PhoneSystem.

These scripts aim to address all these requirements and validate them before allowing them to be used. They feed into Call Queue and Auto Attendant CmdLets that make heavy use of them.

## CmdLets

| Function                                                  | Description                                                                                                                             |
| ---------------------------------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------- |
| [`Find-TeamsCallableEntity`](../docs/Find-TeamsCallableEntity.md) | Searches all Call Queues and/or all Auto Attendants for a connected/targeted `Callable Entity` (TelURI, User, Group, Resource Account). |
| [`Get-TeamsCallableEntity`](../docs/Get-TeamsCallableEntity.md)   | Creates a new Object emulating the output of a `Callable Entity`, validating the Object type and its usability for CQs or AAs.          |
| [`New-TeamsCallableEntity`](../docs/New-TeamsCallableEntity.md)   | Used for Auto Attendants, creates a `Callable Entity` Object given a CallTarget (the type is enumerated through lookup)                 |

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

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

## KEYWORDS

- Creation
- Configuration
- Management
- AzureAdUser
- AzureAdGroup
- CsOnlineUser
- CsOnlineApplicationInstance
- TeamsResourceAccount
