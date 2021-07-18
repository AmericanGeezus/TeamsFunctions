---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdLicenseContainsServicePlan.md
schema: 2.0.0
---

# Test-AzureAdLicenseContainsServicePlan

## SYNOPSIS
Tests whether a specific ServicePlan is included in an AzureAd License

## SYNTAX

```
Test-AzureAdLicenseContainsServicePlan [-License] <String> [-ServicePlan] <String> [<CommonParameters>]
```

## DESCRIPTION
If an AzureAd License contains a specific Service Plan thi function will return $TRUE, otherwise $FALSE

## EXAMPLES

### EXAMPLE 1
```
Test-AzureAdLicenseContainsServicePlan -License Office365E5 -ServicePlan MCOEV
```

Will Return $TRUE only if the ServicePlan is part of the License 'Office365E5'

## PARAMETERS

### -License
Mandatory.
The License to test

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServicePlan
AzureAd Service Plan

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Boolean
## NOTES
This CmdLet is a helper function to delegate validation tasks

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdLicenseContainsServicePlan.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdLicenseContainsServicePlan.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

