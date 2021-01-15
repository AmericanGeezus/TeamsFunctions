# Licensing in AzureAd

## about_Licensing

## SHORT DESCRIPTION

Simplifying License assignment and validating requirements for Voice Config

## LONG DESCRIPTION

Querying Licensing on the Tenant to inform with names rather than IDs, assigning Licenses by Names and finding requirements for Voice Configuration.
In particular assignment and enablement of the PhoneSystem Service Plan.

## CmdLets

| Function                                                                  | Description                                                                                                    |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [`Get-TeamsTenantLicense`](/docs/Get-TeamsTenantLicense.md)               | Queries licenses present on the Tenant. Switches are available for better at-a-glance visibility               |
| [`Get-TeamsUserLicense`](/docs/Get-TeamsUserLicense.md)                   | Queries licenses assigned to a User and displays visual output                                                 |
| [`Set-TeamsUserLicense`](/docs/Set-TeamsUserLicense.md)                   | Adds or removes one or more Licenses against the provided Identity. Also can remove all Licenses.              |
| [`Get-AzureAdLicense`](/docs/Get-AzureAdLicense.md)                       | A Script to query all published Licenses and their Service Plans. Switch can filter for Teams related Licenses |
| [`Get-AzureAdLicenseServicePlan`](/docs/Get-AzureAdLicenseServicePlan.md) | Same as above, but displaying Service Plans only. Switch can filter for Teams related ServicePlans             |

> [!NOTE] Get-AzureAdLicense forms the baseline of the Licensing functions, reading directly from [Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference). This bears the risk that an update to the site may break all Licensing functions, but it also gives you the most up to date Licensing information available.

### Support CmdLets

| Function                                                          | Description                                                                         |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| [`Test-TeamsUserLicense`](/docs/Test-TeamsUserLicense.md)         | Tests an individual Service Plan or a License Package against the provided Identity |
| [`Test-TeamsUserHasCallPlan`](/docs/Test-TeamsUserHasCallPlan.md) | Tests an individual Calling Plains assigned against the provided Identity           |
| [`New-AzureAdLicenseObject`](/docs/New-AzureAdLicenseObject.md)   | Creates a License Object for application. Generic helper function.                  |

## EXAMPLES

````powershell
Set-TeamsUserLicense -Identity John@domain.com -Add Office365E3,PhoneSystem
````

Example 1 assigns the Office 365 E3 License and the PhoneSystem License to the User

````powershell
Get-TeamsUserLicense -Identity John@domain.com
````

Example 2 queries license related elements for a User and returns a custom Object incl.PhoneSystem and PhoneSystemStatus

## NOTE

{{ Note Placeholder - Additional information that a user needs to know.}}

## Development Status

Some gremlines might still lurk in my code, but otherwise these are quite mature.

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
