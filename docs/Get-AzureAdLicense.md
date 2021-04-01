---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-AzureAdLicense

## SYNOPSIS
License information for AzureAD Licenses related to Teams

## SYNTAX

```
Get-AzureAdLicense [-FilterRelevantForTeams] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all Teams related Licenses

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdLicense
```

Returns 39 Azure AD Licenses that relate to Teams for use in other commands

## PARAMETERS

### -FilterRelevantForTeams
Optional.
By default, shows all 365 Licenses
Using this switch, shows only Licenses relevant for Teams

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
Reads:  https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
Source: https://scripting.up-in-the.cloud/licensing/o365-license-names-its-a-mess.html
With very special thanks to Philip

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_Licensing]()

[about_UserManagement]()

[Get-TeamsTenantLicense]()

[Get-TeamsUserLicense]()

[Get-TeamsUserLicenseServicePlan]()

[Set-TeamsUserLicense]()

[Test-TeamsUserLicense]()

[Get-AzureAdUserLicense]()

[Get-AzureAdUserLicenseServicePlan]()

[Get-AzureAdLicense]()

[Get-AzureAdLicenseServicePlan]()

