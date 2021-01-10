---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsUserLicense

## SYNOPSIS
Returns License information for an Object in AzureAD

## SYNTAX

```
Get-TeamsUserLicense [-Identity] <String[]> [-DisplayAll] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all Teams related Licenses found for a specific Object
This script lists the UPN, Name, currently O365 Plan, Calling Plan, Communication Credit, and Audio Conferencing Add-On License

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsUserLicense -Identity John@domain.com
```

Displays all licenses assigned to User John@domain.com

### EXAMPLE 2
```
Get-TeamsUserLicense -Identity John@domain.com,Jane@domain.com
```

Displays all licenses assigned to Users John@domain.com and Jane@domain.com

### EXAMPLE 3
```
Import-Csv User.csv | Get-TeamsUserLicense
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
Aliases: UPN, UserPrincipalName, Username

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DisplayAll
Displays all ServicePlans, not only relevant Teams Plans

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

[Set-TeamsUserLicense]()

[Test-TeamsUserLicense]()

[Get-TeamsLicense]()

[Get-TeamsLicenseServicePlan]()

[Get-AzureAdLicense]()

[Get-AzureAdLicenseServicePlan]()

