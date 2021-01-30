# AzureAd and Teams User Management

## about_UserManagement

## SHORT DESCRIPTION

Managing AzureAdUsers, Groups, ResourceAccounts for use in CQs and AAs.

## LONG DESCRIPTION

User Management CmdLets are covering a range of topics, from Analog Devices, Common Area Phones, Resource Accounts to Users and Groups. This page focuses on uncategorised CmdLets that supplement the User Management aspect. Please see section 'See Also' for links to related topics.

Finding Users, Groups or other objects is sometimes too complex for my taste. Using `Get-AzureAdUser -Searchstring "$UPN"` is fine, but sometimes I just want to bash in the UserPrincipalName or Group Name and get a result. Some helper functions that simplify input a bit and expand on the functionality of Callable Entity:

## CmdLets

| Function                                                  | Description                                                                                                                             |
| ---------------------------------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------- |
| [`Find-AzureAdGroup`](../docs/Find-AzureAdGroup.md)               | Helper Function to find AzureAd Groups. Returns Objects if found. Simplifies Lookup and Search of Objects                               |
| [`Find-AzureAdUser`](../docs/Find-AzureAdUser.md)                 | Helper Function to find AzureAd Users. Returns Objects if found. Simplifies Lookup and Search of Objects                                |

> [!Note] On first run, Find-AzureAdGroup (and other CmdLets that are working with AzureAd Groups) will load all Groups available in the Tenant into a Global variable. This is done as searches against AzureAd Groups are somewhat clunky and overall performance is improved when validating and looking up information.
> <br />All global variables will be removed when closing the PowerShell window or disconnecting from the Tenant with `Disconnect-Me`

## Support CmdLet

| Function                                                    | Description                                                                                 |
| -----------------------------------------------------------: | ------------------------------------------------------------------------------------------- |
| [`Test-AzureAdGroup`](../docs/Test-AzureAdGroup.md)                 | Testing whether the Group exists in AzureAd                                                 |
| [`Test-AzureAdUser`](../docs/Test-AzureAdUser.md)                   | Testing whether the User exists in AzureAd (NOTE: Resource Accounts are AzureAd Users too!) |
| [`Test-TeamsResourceAccount`](../docs/Test-TeamsResourceAccount.md) | Testing whether a Resource Account exists in AzureAd                                        |
| [`Test-TeamsUser`](../docs/Test-TeamsUser.md)                       | Testing whether the User exists in SkypeOnline/Teams                                        |

## EXAMPLES

These CmdLets do not require explicit use cases reflected here. Please see the Examples for the individual CmdLets in the [DOCs](../docs/)

## NOTE

This page only lists the CmdLets that are not categorised further. See below for Callable Entities, Common Area Phones and Analog Devices, etc.

## TROUBLESHOOTING NOTE

There might be a few cases where the Output displays too much or too little. The Find-CmdLets took a while to properly be fine tuned. If you do not find something that you know is there, please let me know

## SEE ALSO

- [about_TeamsCallableEntity](about_TeamsCallableEntity.md)
- [about_TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)
- [about_TeamsAnalogDevice](about_TeamsAnalogDevice.md)
- [about_TeamsResourceAccount](about_TeamsResourceAccount.md)
- [about_Licensing](about_Licensing.md)

## KEYWORDS

- User, AzureAdUser, CsOnlineUser
- Group, AzureAdGroup
- Resource, Resource Account, CsOnlineApplicationInstance
- Common Area Phone
- Analog Device
- IP Phone
