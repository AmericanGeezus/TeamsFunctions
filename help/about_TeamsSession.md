# ABOUT

## about_ABOUT

## SHORT DESCRIPTION

Connecting to the Teams Backend is, for now, still done via SkypeOnline

## LONG DESCRIPTION

SkypeOnline and MSOnline (AzureADv1) are the two oldest Office 365 Services. Creating a Session to them is not implemented very nicely. The introduction of Privileged Identity Management and Privileged Access Groups further requires some manual steps that the following are trying to make simpler and provide an easier way to connect and activate your roles

## CmdLets

| Function                                                    | Description                                                                                                                                  |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Connect-SkypeOnline`](/docs/Connect-SkypeOnline.md)       | Creates a Session to SkypeOnline (v7 also extends Timeout Limit!)                                                                            |
| [`Connect-Me`](/docs/Connect-Me.md) (con)                   | Creates a Session to SkypeOnline and AzureAD in one go. Only displays **ONE** authentication prompt, and, if applicable, **ONE** MFA prompt! |
| [`Disconnect-SkypeOnline`](/docs/Disconnect-SkypeOnline.md) | Disconnects from a Session to SkypeOnline. This prevents timeouts and hanging sessions                                                       |
| [`Disconnect-Me`](/docs/Disconnect-Me.md) (dis)             | Disconnects form all Sessions to SkypeOnline, MicrosoftTeams and AzureAD                                                                     |

## Admin Roles

Activating Admin Roles made easier. Please note that Privileged Access Groups are not yet integrated as there are no PowerShell commands available yet in the AzureAdPreview Module. This will be added as soon as possible. Commands are used with `Connect-Me`, but can be used on its own just as well.

> [!NOTE] Please **note**, that Privileged Admin Groups are currently not covered by these CmdLets. This will be added as soon as possible

| Function                                                      | Description                                                                                                                                     |
| ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Enable-AzureAdAdminRole`](/docs/Enable-AzureAdAdminRole.md) | Enables Admin Roles assigned directly to the AccountId provided. If no accountId is provided, the currently connected User to AzureAd is taken. |
| [`Get-AzureAdAdminRole`](/docs/Get-AzureAdAdminRole.md)       | Displays all (active or eligible) Admin Roles assigned to an AzureAdUser                                                                        |

### Support Functions

| Function                                                                      | Description                                                                                   |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [`Assert-AzureAdConnection`](/docs/Assert-AzureAdConnection.md)               | Tests connection and visual feedback in the Verbose stream if called directly.                |
| [`Assert-MicrosoftTeamsConnection`](/docs/Assert-MicrosoftTeamsConnection.md) | Tests connection and visual feedback in the Verbose stream if called directly.                |
| [`Assert-SkypeOnlineConnection`](/docs/Assert-SkypeOnlineConnection.md)       | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life* |
| [`Test-AzureAdConnection`](/docs/Test-AzureAdConnection.md)                   | Verifying a Session to AzureAD exists                                                         |
| [`Test-MicrosoftTeamsConnection`](/docs/Test-MicrosoftTeamsConnection.md)     | Verifying a Session to MicrosoftTeams exists                                                  |
| [`Test-SkypeOnlineConnection`](/docs/Test-SkypeOnlineConnection.md)           | Verifying a Session to SkypeOnline exists                                                     |
| [`Test-ExchangeOnlineConnection`](/docs/Test-ExchangeOnlineConnection.md)     | Verifying a Session to ExchangeOnline exists                                                  |

## EXAMPLES

````powershell
# Example 1 - Teams User Voice Route
Connect-SkypeOnline -Identity John@domain.com [-OverrideAdminDomain domain.onmicrosoft.com]
````

Establishes a session to SkypeOnline (aka the Teams BackEnd). The Override Admin Domain is optional and only needed for Hybrid Scenarios where the DNS entries point to the Skype OnPrem Platform.

- If the SkypeOnlineConnector is used, enables the session for reconnection.
- If the MicrosoftTeams Module is used, an authentication dialog is shown.

## NOTE

To properly administer Teams, a connection to `AzureAd` is most likely needed. Privileged Identity Management and Role Activation are currently only available with the Module `AzureAdPreview` installed in Version `2.0.2.24` or higher, until the functions become generally available through the AzureAd Module.

Initially, this module was built around the use of the `SkypeOnlineConnector`(v7). The Connector is now deprectated and will be replaced by end of FEB 2021.
The command to establish a connection has been ported to `MicrosoftTeams` in `v1.1.6`. Starting with **TeamsFunctions v21.01**, the requirement for SkypeOnlineConnector is lifted. Either module can be used, with some drawbacks: Using MicrosoftTeams does currently not allow seamless Single-Sign-On as no Username can be passed on to the Session command and Session Reconnection is currently not possible as the Command `Enable-CsOnlineSessionForReconnection` was not ported over. Some further testing is required still.

## Development Status

Mature, but a moving target - Continuous in Progress. An update to the MicrosoftTeams Command and documentation is anticipated that would enable Single-sign-on with MFA enabled. Issues have been raised via Github to address.

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
