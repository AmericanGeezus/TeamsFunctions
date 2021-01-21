---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsVNR

## SYNOPSIS
Lists all Normalization Rules for a Tenant Dial Plan

## SYNTAX

### Identity (Default)
```
Get-TeamsVNR [[-Identity] <String>] [<CommonParameters>]
```

### Filter
```
Get-TeamsVNR [-Filter <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsVNR
```

Lists Identities (Names) of all Tenant Dial Plans (except "Global")

### EXAMPLE 2
```
Get-TeamsVNR -Identity DP-HUN
```

Lists Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does.

### EXAMPLE 3
```
Get-TeamsVNR -Filter DP-HUN
```

Lists all Tenant Dials that contain the strign "DP-HUN" in the Name.

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsTenantDialPlan, listing Normalisation Rules for this Dial Plan
If not provided, lists Identities of all Tenant Dial Plans (except "Global")

```yaml
Type: String
Parameter Sets: Identity
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Filter
Searches for all Tenant Dial Plans that contains the string in the Name.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

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

## NOTES
Without parameters, it executes the following string:
Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsTDP]()

[Get-TeamsVNR]()

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

