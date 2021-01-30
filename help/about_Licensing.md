# Licensing in AzureAd

## about_Licensing

## SHORT DESCRIPTION

Simplifying License assignment and validating requirements for Voice Config

## LONG DESCRIPTION

Querying Licensing on the Tenant to inform with names rather than IDs, assigning Licenses by Names and finding requirements for Voice Configuration.
In particular assignment and enablement of the PhoneSystem Service Plan.

## CmdLets

| Function                                                                  | Description                                                                                                    |
| -------------------------------------------------------------------------: | -------------------------------------------------------------------------------------------------------------- |
| [`Get-AzureAdLicense`](/docs/Get-AzureAdLicense.md)                       | A Script to query all published Licenses and their Service Plans. Switch can filter for Teams related Licenses |
| [`Get-AzureAdLicenseServicePlan`](/docs/Get-AzureAdLicenseServicePlan.md) | Same as above, but displaying Service Plans only. Switch can filter for Teams related ServicePlans             |
| [`Get-TeamsTenantLicense`](/docs/Get-TeamsTenantLicense.md)               | Queries licenses present on the Tenant. Switches are available for better at-a-glance visibility               |
| [`Get-TeamsUserLicense`](/docs/Get-TeamsUserLicense.md)                   | Queries licenses assigned to a User and displays visual output                                                 |
| [`Set-AzureAdUserLicenseServicePlan`](/docs/Set-AzureAdUserLicenseServicePlan.md)                   | Enables or Disables a ServicePlan for assigned Licenses to a user.              |
| [`Set-TeamsUserLicense`](/docs/Set-TeamsUserLicense.md)                   | Adds or removes one or more Licenses against the provided Identity. Also can remove all Licenses.              |

> [!NOTE] Get-AzureAdLicense forms the baseline of the Licensing functions, reading directly from [Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference). This bears the risk that an update to the site may break all Licensing functions, but it also gives you the most up to date Licensing information available.

### Support CmdLets

| Function                                                          | Description                                                                         |
| -----------------------------------------------------------------: | ----------------------------------------------------------------------------------- |
| [`Test-TeamsUserLicense`](/docs/Test-TeamsUserLicense.md)         | Tests an individual Service Plan or a License Package against the provided Identity |
| [`Test-TeamsUserHasCallPlan`](/docs/Test-TeamsUserHasCallPlan.md) | Tests an individual Calling Plains assigned against the provided Identity           |
| [`New-AzureAdLicenseObject`](/docs/New-AzureAdLicenseObject.md)   | Creates a License Object for application. Generic helper function.                  |

## EXAMPLES

````powershell
Get-TeamsUserLicense -Identity John@domain.com
````

Example 1 queries license related elements for a User and returns a custom Object incl.PhoneSystem and PhoneSystemStatus

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add Office365E3,PhoneSystem
````

Example 2 assigns the Office 365 E3 License and the PhoneSystem License to the User

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add Office365E5 -Remove Office365E3
````

Example 3 replaces the Office 365 E3 License for an E5 License.

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add PhoneSystemVirtualUser -RemoveAll
````

Example 4 replaces all assigned licenses with a PhoneSystem Virtual User License.

> [!NOTE] When removing a License from a User, the Users will lose the functionality the license provides. For example, the E3 or E5 License contain a Service Plan for Exchange which will give the User a Mailbox. Completing a License Operation (in PowerShell or in the Admin Center) will trigger the subsystem to process these. When replacing a License, Microsoft recommend to do it in one step as the Example 3 and 4 above illustrate.

## NOTE

Replacing Licenses should be performed in one step to retain the functionality throughout the process.

Resource Accounts can be set up with any License, but ideally utilise the free PhoneSystem Virtual User License available in the Tenant. Should those license become available later, Resource Accounts may become unusable if the PhoneSystem licenses are not replaced in one step.

## Development Status

Development is complete. As always, some gremlins might still lurk in my code, please let me know.

## TROUBLESHOOTING NOTE

None.

## SEE ALSO

- [about_TeamsResourceAccount](about_TeamsResourceAccount.md)
- [about_TeamsCommonAreaPhone](about_TeamsCommonAreaPhone.md)

## KEYWORDS

- ServicePlan
- PhoneSystem
