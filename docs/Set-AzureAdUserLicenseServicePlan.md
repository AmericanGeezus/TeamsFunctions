---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Set-AzureAdUserLicenseServicePlan

## SYNOPSIS
Changes one or more Service Plans for Licenses assigned to an AzureAD Object

## SYNTAX

```
Set-AzureAdUserLicenseServicePlan [-Identity] <String[]> [-Enable <String[]>] [-Disable <String[]>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enables or disables a ServicePlan from all assigned Licenses to an AzureAD Object
Supports all Service Plans listed in Get-AzureAdLicenseServicePlan

## EXAMPLES

### EXAMPLE 1
```
Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Enable MCOEV
```

Enables the Service Plan Phone System (MCOEV) on all Licenses assigned to Name@domain.com

### EXAMPLE 2
```
Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Disable MCOEV,TEAMS1
```

Disables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com

### EXAMPLE 3
```
Set-AzureAdUserLicenseServicePlan -Identity Name@domain.com -Enable MCOEV,TEAMS1 -PassThru
```

Enables the Service Plans Phone System (MCOEV) and Teams (TEAMS1) on all Licenses assigned to Name@domain.com
Displays User License Object after application

## PARAMETERS

### -Identity
Required.
UserPrincipalName of the Object to be manipulated

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UPN, UserPrincipalName, Username

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Enable
Optional.
Service Plans to be enabled (main function)
Accepted Values can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
No action is taken for any Licenses not containing this Service Plan

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disable
Optional.
Service Plans to be disabled (alternative function)
Accepted Values can be retrieved with Get-AzureAdLicenseServicePlan (Column ServicePlanName)
No action is taken for any Licenses not containing this Service Plan

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Optional.
Displays User License Object after action.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void
## NOTES
Data in Get-AzureAdLicenseServicePlan as per Microsoft Docs Article: Published Service Plan IDs for Licensing
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsTenantLicense]()

[Get-TeamsUserLicense]()

[Set-TeamsUserLicense]()

[Get-AzureAdLicense]()

[Get-AzureAdLicenseServicePlan]()

