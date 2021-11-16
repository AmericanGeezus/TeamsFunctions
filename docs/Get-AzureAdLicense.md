---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdLicense.md
schema: 2.0.0
---

# Get-AzureAdLicense

## SYNOPSIS
License information for AzureAD Licenses related to Teams

## SYNTAX

```
Get-AzureAdLicense [[-SearchString] <String>] [-FilterRelevantForTeams] [<CommonParameters>]
```

## DESCRIPTION
Returns an Object containing all Teams related Licenses

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdLicense
```

Returns Azure AD Licenses that relate to Teams for use in other commands

## PARAMETERS

### -SearchString
Optional.
Filters output for String found in Parameters ProductName or SkuPartNumber

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
This CmdLet can assign one of Azure Ad Licenses.
(see ParameterName)
Please raise an issue on Github if you require additional Licenses for assignment

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdLicense.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-AzureAdLicense.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Licensing.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

