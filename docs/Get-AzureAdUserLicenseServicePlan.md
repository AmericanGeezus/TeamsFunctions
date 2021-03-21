---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-AzureAdUserLicenseServicePlan

## SYNOPSIS
Returns License information (ServicePlans) for an Object in AzureAD

## SYNTAX

```
Get-AzureAdUserLicenseServicePlan [-Identity] <String[]> [-FilterRelevantForTeams] [-FilterUnsuccessful]
 [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all ServicePlans (for Licenses assigned) for a specific Object

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdUserLicenseServicePlan [-Identity] John@domain.com
```

Displays all Service Plans assigned through Licenses to User John@domain.com

### EXAMPLE 2
```
Get-AzureAdUserLicenseServicePlan -Identity John@domain.com,Jane@domain.com
```

Displays all Service Plans assigned through Licenses to Users John@domain.com and Jane@domain.com

### EXAMPLE 3
```
Get-AzureAdUserLicenseServicePlan -Identity Jane@domain.com -FilterRelevantForTeams
```

Displays all relevant Teams Service Plans assigned through Licenses to Jane@domain.com

### EXAMPLE 4
```
Get-AzureAdUserLicenseServicePlan -Identity Jane@domain.com -FilterUnsuccessful
```

Displays all Service Plans assigned through Licenses to Jane@domain.com that are not provisioned successfully

### EXAMPLE 5
```
Import-Csv User.csv | Get-AzureAdUserLicenseServicePlan
```

Displays all Service Plans assigned through Licenses to Users from User.csv, Column Identity.
  The input file must have a single column heading of "Identity" with properly formatted UPNs.

## PARAMETERS

### -Identity
The Identity, UserPrincipalname or UserName for the user.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UserPrincipalName, Username, UPN

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FilterRelevantForTeams
Filters the output and displays only Licenses relevant Teams Service Plans

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

### -FilterUnsuccessful
Filters the output and displays only ServicePlans that don't have the ProvisioningStatus "Success"

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

### System.Management.Automation.PSObject
## NOTES
Requires a connection to Azure Active Directory

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsTenantLicense]()

[Get-TeamsUserLicense]()

[Get-TeamsUserLicenseServicePlan]()

[Set-TeamsUserLicense]()

[Test-TeamsUserLicense]()

[Get-AzureAdUserLicense]()

[Get-AzureAdUserLicenseServicePlan]()

[Get-AzureAdLicense]()

[Get-AzureAdLicenseServicePlan]()

