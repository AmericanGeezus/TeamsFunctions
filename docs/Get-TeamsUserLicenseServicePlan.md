---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsUserLicenseServicePlan

## SYNOPSIS
Returns License information (ServicePlans) for an Object in AzureAD

## SYNTAX

```
Get-TeamsUserLicenseServicePlan [-Identity] <String[]> [-DisplayAll] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all Teams related ServicePlans (for Licenses assigned) for a specific Object

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsUserLicenseServicePlan [-Identity] John@domain.com
```

Displays all licenses assigned to User John@domain.com

### EXAMPLE 2
```
Get-TeamsUserLicenseServicePlan -Identity John@domain.com,Jane@domain.com
```

Displays all licenses assigned to Users John@domain.com and Jane@domain.com

### EXAMPLE 3
```
Import-Csv User.csv | Get-TeamsUserLicenseServicePlan
```

Displays all licenses assigned to Users from User.csv, Column Identity.
  The input file must have a single column heading of "Identity" with properly formatted UPNs.

## PARAMETERS

### -Identity
The Identity/UPN/sign-in address for the user entered in the format \<name\>@\<domain\>.
  Aliases include: "UPN","UserPrincipalName","Username"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UserPrincipalName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DisplayAll
Displays all ServicePlans, not only relevant Teams Service Plans
Also displays AllLicenses and AllServicePlans object for further processing

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
