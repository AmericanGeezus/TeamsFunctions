---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
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
Get-TeamsTDP
```

Lists Identities (Names) of all Tenant Dial Plans (except "Global")

### EXAMPLE 2
```
Get-TeamsTDP -Identity DP-HUN
```

Lists Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does (provided it exists).

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsTenantDialPlan, listing one Dial Plan
If not provided, lists Identities of all Tenant Dial Plans (except "Global")

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

## NOTES
Without parameters, it executes the following string:
Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

## RELATED LINKS
