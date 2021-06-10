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
Behaviour like: Get-CsOnlineVoiceRoute

### EXAMPLE 2
```
Get-TeamsMGW -Identity PstnGateway1.domain.com
```

Lists Online Pstn Gateway as Get-CsOnlinePstnGateway does (provided it exists).
Behaviour like: Get-CsOnlineVoiceRoute -Identity "PstnGateway1.domain.com"

### EXAMPLE 3
```
Get-TeamsOVR -Identity EMEA*
```

Lists Online Voice Routes with "EMEA" in the Name
Behaviour like: Get-CsOnlineVoiceRoute -Filter "*EMEA*"

## PARAMETERS

### -Identity
String.
FQDN or part of the FQDN for a Pstn Gateway.
Can be omitted to list Names of all Gateways
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

### None
### System.String
## OUTPUTS

### System.Object
## NOTES
This script is indulging the lazy admin.
It behaves like Get-CsTeamsCallingPolicy with a twist:
If more than three results are found, a reduced set of Parameters are shown for better visibility:
Get-CsOnlinePSTNGateway | Select-Object Identity, SipSignalingPort, Enabled, MediaByPass

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_VoiceConfiguration]()

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

[Get-TeamsTDP]()

[Get-TeamsVNR]()

[Get-TeamsIPP]()

[Get-TeamsCP]()

[Get-TeamsECP]()

[Get-TeamsECRP]()

