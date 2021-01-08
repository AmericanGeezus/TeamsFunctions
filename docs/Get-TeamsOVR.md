---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Get-TeamsOVR

## SYNOPSIS
Lists all Online Voice Routes by Name

## SYNTAX

```
Get-TeamsOVR [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Online Voice Routes to troubleshoot, an Alias-Function to Get-CsOnlineVoiceRoute

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsOVR
```

Lists Identities (Names) of all Online Voice Route (except "LocalRoute")

### EXAMPLE 2
```
Get-TeamsOVP -Identity OVR-EMEA-National
```

Lists Online Voice Route "OVR-EMEA-National" as Get-CsOnlineVoiceRoute does (provided it exists).

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsOnlineVoiceRoute, listing one Route
If not provided, lists Identities of all Online Voice Route (except "LocalRoute")

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
Get-CsOnlineVoiceRoute | Where-Object Identity -NE "LocalRoute"  | Select-Object Name -ExpandProperty Name

## RELATED LINKS
