---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsMGW

## SYNOPSIS
Lists all Online Pstn Gateways by Name

## SYNTAX

```
Get-TeamsMGW [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Online Pstn Gateways to assign, an Alias-Function to Get-CsOnlineVoiceRoutingPolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsMGW
```

Lists Identities (Names) of all Online Pstn Gateways

### EXAMPLE 2
```
Get-TeamsMGW -Identity PstnGateway1.domain.com
```

Lists Online Pstn Gateway as Get-CsOnlinePstnGateway does (provided it exists).

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsOnlineVoiceRoutingPolicy, listing one Policy
If not provided, lists Identities of all Online Pstn Gateways

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Without parameters, it executes the following string:
Get-CsOnlinePstnGateway | Select-Object Identity -ExpandProperty Identity

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

[Get-TeamsTDP]()

[Get-TeamsVNR]()

