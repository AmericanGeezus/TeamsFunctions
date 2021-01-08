---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Get-TeamsOVP

## SYNOPSIS
Lists all Online Voice Routing Policies by Name

## SYNTAX

```
Get-TeamsOVP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Online Voice Routing Policies to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsOVP
```

Lists Identities (Names) of all Online Voice Routing Policies (except "Global")

### EXAMPLE 2
```
Get-TeamsOVP -Identity OVP-EMEA-National
```

Lists Online Voice Routing Policy "OVP-EMEA-National" as Get-CsOnlineVoiceRoutingPolicy does (provided it exists).

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsOnlineVoiceRoutingPolicy, listing one Policy
If not provided, lists Identities of all Online Voice Routing Policies (except "Global")

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
Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE "Global" | Select-Object Identity -ExpandProperty Identity

## RELATED LINKS
