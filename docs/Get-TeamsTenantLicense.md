---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsTenantLicense

## SYNOPSIS
Returns one or all Teams Tenant licenses from a Tenant

## SYNTAX

```
Get-TeamsTenantLicense [-Detailed] [-DisplayAll] [[-License] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing Teams related Licenses found in the Tenant
Teams services can be provisioned through several different combinations of individual
plans as well as add-on and grouped license SKUs.
This command displays these license SKUs in a more friendly
format with descriptive names, SkuPartNumber, active, consumed, remaining, and expiring licenses.

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsTenantLicense
```

Displays detailed information about all Teams related licenses found on the tenant.

### EXAMPLE 2
```
Get-TeamsTenantLicense -License PhoneSystem
```

Displays detailed information about the PhoneSystem license found on the tenant.

### EXAMPLE 3
```
Get-TeamsTenantLicense -ConciseView
```

Displays all Teams Licenses found on the tenant, but only Name and counters.

### EXAMPLE 4
```
Get-TeamsTenantLicense -DisplayAll
```

Displays detailed information about all licenses found on the tenant.

### EXAMPLE 5
```
Get-TeamsTenantLicense -ConciseView -DisplayAll
```

Displays a concise view of all licenses found on the tenant.

## PARAMETERS

### -Detailed
Displays all Parameters.
By default, only Parameters relevant to determine License availability are shown.

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

### -DisplayAll
Displays all Licenses, not only relevant Teams Licenses

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

### -License
Optional.
Limits the Output to one license.
Accepted Values can be retrieved with Get-TeamsLicense (Column ParameterName)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES
Requires a connection to Azure Active Directory

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsTenantLicense]()

[Get-TeamsUserLicense]()

[Set-TeamsUserLicense]()

[Test-TeamsUserLicense]()

[Get-TeamsLicense]()

[Get-TeamsLicenseServicePlan]()

[Get-AzureAdLicense]()

[Get-AzureAdLicenseServicePlan]()

