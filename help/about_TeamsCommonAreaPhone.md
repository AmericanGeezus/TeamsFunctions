# Teams Common Area Phones

## about_TeamsCommonAreaPhone

## SHORT DESCRIPTION

There are currently no native commands for this, so I tried creating them.

## LONG DESCRIPTION

Common Area Phone being User Accounts could be managed with the normal Voice Configuration CmdLets, though not very well. The object returned by GET is tailored more towards the needs of a Common ara Phone

## CmdLets

| Function                                                           | Underlying Function | Description                                                                                             |
| ------------------------------------------------------------------ | ------------------- | ------------------------------------------------------------------------------------------------------- |
| [`New-TeamsCommonAreaPhone`](../docs/New-TeamsCommonAreaPhone.md)       | New-AzureAdUser     | Creates a Common Area Phone and applies settings to it as provided.                                     |
| [`Get-TeamsCommonAreaPhone`](../docs/Get-TeamsCommonAreaPhone.md)       | Get-CsOnlineUser    | Queries a Common Area Phone with friendly inputs (UPN) and output                                       |
| [`Set-TeamsCommonAreaPhone`](../docs/Set-TeamsCommonAreaPhone.md)       | Set-CsUser          | Changes a Common Area Phone                                                                             |
| [`Remove-TeamsCommonAreaPhone`](../docs/Remove-TeamsCommonAreaPhone.md) | Remove-AzureAdUser  | Removes configuration (with `Remove-TeamsUserVoiceConfig`), then removes the User (requires User Admin) |

## EXAMPLES

````powershell
# Example 1 - Querying the Common Area Phone Lobby Phone
Get-TeamsCommonAreaPhone -Identity LobbyPhone@domain.com
````

Querying the Common Area Phone Lobby Phone

````powershell
# Output
TBC
````

## NOTE

The most recent addition to the fold, they need some serious testing before they are ready for prime time.

## Development Status

CmdLets are not tested yet.

## TROUBLESHOOTING NOTE

CmdLets are in Beta still, please be patient with me on these and submit issues as you find them.

## SEE ALSO

VoiceConfig

{{ You can also list related articles, blogs, and video URLs. }}

## KEYWORDS

{{List alternate names or titles for this topic that readers might use.}}

- VoiceConfig
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
- {{ Keyword Placeholder }}
