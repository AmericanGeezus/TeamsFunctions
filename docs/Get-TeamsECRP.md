---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsECRP

## SYNOPSIS
Lists all Emergency Voice Routing Policies by Name

## SYNTAX

```
Get-TeamsECRP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Emergency Voice Routing Policies to assign, an Alias-Function to Get-CsTeamsEmergencyCallRoutingPolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsECRP
```

Returns the Object for all Emergency Voice Routing Policies (including "Global")
Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy

### EXAMPLE 2
```
Get-TeamsECRP -Identity ECRP-US
```

Returns the Object for the Emergency Voice Route "ECRP-US" (provided it exists).
Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy -Identity "ECRP-US"

### EXAMPLE 3
```
Get-TeamsECRP -Identity ECRP-US-*
```

Lists Emergency Voice Routes with "ECRP-US-" in the Name
Behaviour like: Get-CsTeamsEmergencyCallRoutingPolicy -Filter "*ECRP-US-*"

## PARAMETERS

### -Identity
String.
Name or part of the Voice Routing Policy.
Can be omitted to list Names of all Policies (including "Global").
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
If more than three results are found, a reordered set of Parameters are shown for better visibility:
Get-CsTeamsEmergencyCallRoutingPolicy | Select-Object Identity, Description, AllowEnhancedEmergencyServices, EmergencyNumbers

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

[Get-TeamsECRP]()

[Get-TeamsECRP]()

