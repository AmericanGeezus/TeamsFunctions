---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Get-AzureAdLicenseServicePlan

## SYNOPSIS
License information for AzureAD Service Plans related to Teams

## SYNTAX

```
Get-AzureAdLicenseServicePlan [-FilterRelevantForTeams] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all Teams related License Service Plans

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsLicense
```

Returns 39 Azure AD Licenses that relate to Teams for use in other commands

## PARAMETERS

### -FilterRelevantForTeams
{{ Fill FilterRelevantForTeams Description }}

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

## OUTPUTS

### System.Object[]
## NOTES
Source
https://scripting.up-in-the.cloud/licensing/o365-license-names-its-a-mess.html
With very special thanks to Philip
Reads
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference

## RELATED LINKS

[Get-TeamsTenantLicense
Get-TeamsUserLicense
Set-TeamsUserLicense
Test-TeamsUserLicense
Add-TeamsUserLicense (deprecated)
Get-TeamsLicense
Get-TeamsLicenseServicePlan
Get-AzureAdLicense
Get-AzureAdLicenseServicePlan]()

