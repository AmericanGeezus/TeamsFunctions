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

Support Functions not part of the main focus

## LONG DESCRIPTION

Functions that do not build the core of this module, but nevertheless are usefull additions to it. Covering Backup, Testing, Assertions and other Helper functions for public use. Private Functions are not listed.

## CmdLets

### Backup and Restore

Taking a backup of every outputable CmdLet that Teams has to offer. Curtesy of Ken Lasko

| Function             | Description                                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `Backup-TeamsEV`     | Takes a backup of all EnterpriseVoice related features in Teams.                                                    |
| `Restore-TeamsEV`    | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care!                       |
| `Backup-TeamsTenant` | An adaptation of the above, backing up as much as can be gathered through available `Get`-Commands from the tenant. |

NOTE: `Backup-TeamsTenant` is currently static, if additional Get-Commands are added this command is not automatically covering this (yet)

### Helper functions

| Function                                 | Description                                                                                                                               |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `Format-StringForUse`                    | Prepares a string for use as DisplayName, UserPrincipalName, LineUri or E.164 Number, removing special characters as needed.              |
| `Format-StringRemoveSpecialCharacter`    | Formats a String and removes special characters (harmonising Display Names)                                                               |
| `Get-RegionFromCountryCode`              | Just a little helper figuring out which geographical region (AMER, EMEA, APAC) a specific country is in.                                  |
| `Get-TeamsObjectType`                    | Little brother to `Get-TeamsCallableEntity` Returns the type of any given Object to identify its use in CQs and AAs.                      |
| `Get-SkypeOnlineConferenceDialInNumbers` | Gathers Dial-In Conferencing Numbers for a specific Domain<br />NOTE: This command is evaluated for revival                               |
| `Remove-TenantDialPlanNormalizationRule` | Displays all Normalisation Rules of a provided Tenant Dial Plan and asks which to remove<br />NOTE: This command is evaluated for revival |

### Test & Assert Functions

These are helper functions for testing Connections and Modules. All Functions return boolean output.

| Function                          | Description                                                                                                 |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Assert-AzureAdConnection`        | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-MicrosoftTeamsConnection` | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| `Assert-SkypeOnlineConnection`    | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*               |
| `Test-AzureAdConnection`          | Verifying a Session to AzureAD exists                                                                       |
| `Test-MicrosoftTeamsConnection`   | Verifying a Session to MicrosoftTeams exists                                                                |
| `Test-SkypeOnlineConnection`      | Verifying a Session to SkypeOnline exists                                                                   |
| `Test-ExchangeOnlineConnection`   | Verifying a Session to ExchangeOnline exists                                                                |
| `Test-AzureAdGroup`               | Testing whether the Group exists in AzureAd                                                                 |
| `Test-AzureAdUser`                | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!)                 |
| `Test-TeamsResourceAccount`       | Testing whether a Resource Account exists in AzureAd                                                        |
| `Test-TeamsUser`                  | Testing whether the User exists in SkypeOnline/Teams                                                        |
| `Test-TeamsUserLicense`           | Testing whether the User has a specific Teams License                                                       |
| `Test-TeamsUserHasCallPlan`       | Testing whether the User has any Call Plan License                                                          |
| `Test-Module`                     | Verifying the specified Module is loaded                                                                    |
| `Test-TeamsExternalDNS`           | Tests DNS Records for Skype for Business Online and Teams<br />NOTE: This command is evaluated for revival. |

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
