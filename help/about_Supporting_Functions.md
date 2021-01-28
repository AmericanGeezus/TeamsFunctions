# Support Functions

## about_Supporting_Functions

## SHORT DESCRIPTION

Support Functions not part of the main focus

## LONG DESCRIPTION

Functions that do not build the core of this module, but nevertheless are usefull additions to it. Covering Backup, Testing, Assertions and other Helper functions for public use. Private Functions are not listed.

## CmdLets

### Backup and Restore

Taking a backup of every outputable CmdLet that Teams has to offer. Curtesy of Ken Lasko

| Function                                            | Description                                                                                                         |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [`Backup-TeamsEV`](../docs/Backup-TeamsEV.md)         | Takes a backup of all EnterpriseVoice related features in Teams.                                                    |
| [`Restore-TeamsEV`](../docs/Restore-TeamsEV.md)       | Makes a full authoritative restore of all EnterpriseVoice related features. Handle with care!                       |
| [`Backup-TeamsTenant`](../docs/Backup-TeamsTenant.md) | An adaptation of the above, backing up as much as can be gathered through available `Get`-Commands from the tenant. |

> [!NOTE] The Get-Commands in this function is currently static. While this is fine for Backup-TeamsEV, `Backup-TeamsTenant` may see drift as a result. If additional Get-Commands are added to Teams, this command will need an update. Please let me know. An Automatic mechanism to discover these is desired.

### Helper functions

String reformatting is needed to normalise Numbers as E.164 numbers and allow a more diverse input (like: `'+1(555)-1234 567'`) it also serves to normalise DisplayNames and UPNs should characters be used that are not allowed.

| Function                                                                              | Description                                                                                                                  |
| ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| [`Format-StringForUse`](../docs/Format-StringForUse.md)                                 | Prepares a string for use as DisplayName, UserPrincipalName, LineUri or E.164 Number, removing special characters as needed. |
| [`Format-StringRemoveSpecialCharacter`](../docs/Format-StringRemoveSpecialCharacter.md) | Formats a String and removes special characters (harmonising Display Names)                                                  |
| [`Get-RegionFromCountryCode`](../docs/Get-RegionFromCountryCode.md)                     | Just a little helper figuring out which geographical region (AMER, EMEA, APAC) a specific country is in.                     |
| [`Get-TeamsObjectType`](../docs/Get-TeamsObjectType.md)                                 | Little brother to `Get-TeamsCallableEntity` Returns the type of any given Object to identify its use in CQs and AAs.         |

### Test & Assert Functions

These are helper functions for testing Connections and Modules. All Functions return boolean output. Asserting the Status of the SkypeOnline Connection however also tries to reconnect a broken session in the hope of reducing downtime.

| Function                                                                      | Description                                                                                                 |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| [`Assert-AzureAdConnection`](../docs/Assert-AzureAdConnection.md)               | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| [`Assert-MicrosoftTeamsConnection`](../docs/Assert-MicrosoftTeamsConnection.md) | Tests connection and visual feedback in the Verbose stream if called directly.                              |
| [`Assert-SkypeOnlineConnection`](../docs/Assert-SkypeOnlineConnection.md)       | Tests connection and **Attempts to reconnect** a *broken* session. Alias `PoL` *Ping-of-life*               |
| [`Test-AzureAdConnection`](../docs/Test-AzureAdConnection.md)                   | Verifying a Session to AzureAD exists                                                                       |
| [`Test-MicrosoftTeamsConnection`](../docs/Test-MicrosoftTeamsConnection.md)     | Verifying a Session to MicrosoftTeams exists                                                                |
| [`Test-SkypeOnlineConnection`](../docs/Test-SkypeOnlineConnection.md)           | Verifying a Session to SkypeOnline exists                                                                   |
| [`Test-ExchangeOnlineConnection`](../docs/Test-ExchangeOnlineConnection.md)     | Verifying a Session to ExchangeOnline exists                                                                |
| [`Test-AzureAdGroup`](../docs/Test-AzureAdGroup.md)                             | Testing whether the Group exists in AzureAd                                                                 |
| [`Test-AzureAdUser`](../docs/Test-AzureAdUser.md)                               | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!)                 |
| [`Test-TeamsResourceAccount`](../docs/Test-TeamsResourceAccount.md)             | Testing whether a Resource Account exists in AzureAd                                                        |
| [`Test-TeamsUser`](../docs/Test-TeamsUser.md)                                   | Testing whether the User exists in SkypeOnline/Teams                                                        |
| [`Test-TeamsUserLicense`](../docs/Test-TeamsUserLicense.md)                     | Testing whether the User has a specific Teams License                                                       |
| [`Test-TeamsUserHasCallPlan`](../docs/Test-TeamsUserHasCallPlan.md)             | Testing whether the User has any Call Plan License                                                          |
| [`Test-Module`](../docs/Test-Module.md)                                         | Verifying the specified Module is loaded                                                                    |
| [`Test-TeamsExternalDNS`](../docs/Test-TeamsExternalDNS.md)                     | Tests DNS Records for Skype for Business Online and Teams<br />NOTE: This command is evaluated for revival. |

## EXAMPLES

```powershell
# Example 1 will format numbers as E.164 Number
'+1(555)-1234 567' | Format-StringForUse -As E164
```

This will return `+15551234567`

```powershell
# Example 2 will format numbers as a TEL URI
'+1(555)-1234 567' | Format-StringForUse -As E164
```

This will return `tel:+15551234567`. This could also have an extension set.

## NOTE

{{ Note Placeholder - Additional information that a user needs to know.}}

## Development Status

Mature

All of these CmdLets are pretty static and only receive minor updates. The String manipulation ones even have Pester tests defined already.

## TROUBLESHOOTING NOTE

{{ Troubleshooting Placeholder - Warns users of bugs}}

{{ Explains behavior that is likely to change with fixes }}

## SEE ALSO

{{ See also placeholder }}

{{ You can also list related articles, blogs, and video URLs. }}

## KEYWORDS

- Test Functions
- Asserting
- Formatting
