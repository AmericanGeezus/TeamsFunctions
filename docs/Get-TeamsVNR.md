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

```
Get-TeamsVNR [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsVNR
```

Returns the Object for all Tenant Dial Plans (except "Global")
Behaviour like: Get-CsTenantDialPlan, showing only a few Parameters (no Normalization Rules)

### EXAMPLE 2
```
Get-TeamsVNR -Identity DP-HUN
```

Returns Voice Normalisation Rules from the Tenant Dial Plan DP-HUN (provided it exists).
Behaviour like: (Get-CsTenantDialPlan -Identity "DP-HUN").NormalizationRules

### EXAMPLE 3
```
Get-TeamsVNR -Filter DP-HUN
```

Filters all Tenant Dial Plans that contain the string "DP-HUN" in the Name.
Returns Tenant Dial Plans if more than 3 results are found.
Behaviour like: Get-CsTenantDialPlan -Identity "*DP-HUN*"
Returns Voice Normalisation Rules from the Tenant Dial Plan DP-HUN (provided it exists).
Behaviour like: (Get-CsTenantDialPlan -Identity "*DP-HUN*").NormalizationRules

## PARAMETERS

### -Identity
String.
Name or part of the Teams Dial Plan.
If not provided, lists Identities of all Tenant Dial Plans (except "Global")
If provided without a '*' in the name, an exact match is sought.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Without parameters, it executes the following string:
Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Name, Pattern, Translation, Description

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsTDP]()

[Get-TeamsVNR]()

[Get-TeamsIPP]()

[Get-TeamsCP]()

[Get-TeamsECP]()

[Get-TeamsECRP]()

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

