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

## LONG DESCRIPTION

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them is not implemented very nicely. The introduction of Privileged Identity Management and Privileged Access Groups further requires some manual steps that the following are trying to make simpler and provide an easier way to connect and activate your roles

## CmdLets

| Function                 | Description                                                                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Connect-SkypeOnline`    | Creates a Session to SkypeOnline (v7 also extends Timeout Limit!)                                                                            |
| `Connect-Me` (con)       | Creates a Session to SkypeOnline and AzureAD in one go. Only displays **ONE** authentication prompt, and, if applicable, **ONE** MFA prompt! |
| `Disconnect-SkypeOnline` | Disconnects from a Session to SkypeOnline. This prevents timeouts and hanging sessions                                                       |
| `Disconnect-Me` (dis)    | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD

## Admin Roles

Activating Admin Roles made easier. Please note that Privileged Access Groups are not yet integrated as there are no PowerShell commands available yet in the AzureAdPreview Module. This will be added as soon as possible. Commands are used with `Connect-Me`, but can be used on its own just as well.

> [!NOTE] Please note, that Privileged Admin Groups are currently not covered by these CmdLets. This will be added as soon as possible

| Function                  | Description                                                                                                                                     |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `Enable-AzureAdAdminRole` | Enables Admin Roles assigned directly to the AccountId provided. If no accountId is provided, the currently connected User to AzureAd is taken. |
| `Get-AzureAdAdminRole`    | Displays all (active or eligible) Admin Roles assigned to an AzureAdUser

### Support Functions

| Function                          | Description                                                                                                 |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Assert-AzureAdConnection`        | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-MicrosoftTeamsConnection` | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-SkypeOnlineConnection`    | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*               |
| `Test-AzureAdConnection`          | Verifying a Session to AzureAD exists                                                                       |
| `Test-MicrosoftTeamsConnection`   | Verifying a Session to MicrosoftTeams exists                                                                |
| `Test-SkypeOnlineConnection`      | Verifying a Session to SkypeOnline exists                                                                   |
| `Test-ExchangeOnlineConnection`   | Verifying a Session to ExchangeOnline exists                                                                |

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
