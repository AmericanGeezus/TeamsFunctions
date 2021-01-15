# Teams Call Queue

## about_TeamsCallQueue

## SHORT DESCRIPTION

Administering Call Queues with friendlier names.

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

[about_TeamsAutoAttendant](about_TeamsAutoAttendant.md)

[about_TeamsResourceAccount](about_TeamsResourceAccount.md)

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
