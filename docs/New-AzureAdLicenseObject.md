---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-AzureAdLicenseObject.md
schema: 2.0.0
---

# New-AzureAdLicenseObject

## SYNOPSIS
Creates a new License Object for processing

## SYNTAX

```
New-AzureAdLicenseObject [[-SkuId] <String[]>] [[-RemoveSkuId] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Helper function to create a new License Object

## EXAMPLES

### EXAMPLE 1
```
New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd
```

Will create a license Object for the MCOEV license .

### EXAMPLE 2
```
New-AzureAdLicenseObject -SkuId e43b5b99-8dfb-405f-9987-dc307f34bcbd -RemoveSkuId 440eaaa8-b3e0-484b-a8be-62870b9ba70a
```

Will create a license Object based on the existing users License
Adding the MCOEV license, removing the MCOEV_VIRTUALUSER license.

## PARAMETERS

### -SkuId
SkuId(s) of the License to be added

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: AddSkuId

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveSkuId
SkuId(s) of the License to be removed

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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

### Microsoft.Open.AzureAD.Model.AssignedLicenses
## NOTES
This function does not require any connections to AzureAD.
However, applying the output of this Function does.
Used in Set-TeamsUserLicense and Add-TeamsUserLicense

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-AzureAdLicenseObject.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-AzureAdLicenseObject.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[Set-TeamsUserLicense]()

