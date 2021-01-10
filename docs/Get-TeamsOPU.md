---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsOPU

## SYNOPSIS
Lists all Online PSTN Usages by Name

## SYNTAX

```
Get-TeamsOPU [[-Usage] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Online PSTN Usages, an Alias-Function to Get-CsOnlinePstnUsage

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsOPU
```

Lists Identities (Names) of all Online Pstn Usages

### EXAMPLE 2
```
Get-TeamsOPU "PstnUsageName"
```

Lists all PstnUsages with the String PstnUsageName of all Online Pstn Usages

## PARAMETERS

### -Usage
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
It executes the following string:
Get-CsOnlinePstnUsage Global | Select-Object Usage -ExpandProperty Usage

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

[Get-TeamsTDP]()

[Get-TeamsVNR]()

