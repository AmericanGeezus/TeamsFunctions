---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOVP.md
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

Returns the Object for all Online Voice Routing Policies (except "Global")
Behaviour like: Get-CsOnlineVoiceRoutingPolicy, if more than 3 results are found, only names are returned

### EXAMPLE 2
```
Get-TeamsOVP -Identity OVP-EMEA-National
```

Returns the Object for the Online Voice Routing Policy "OVP-EMEA-National" (provided it exists).
Behaviour like: Get-CsOnlineVoiceRoutingPolicy -Identity "OVP-EMEA-National"

### EXAMPLE 3
```
Get-TeamsOVP -Identity OVP-EMEA-*
```

Lists Online Voice Routes with "OVP-EMEA-" in the Name
Behaviour like: Get-CsOnlineVoiceRoutingPolicy -Filter "*OVP-EMEA-*"

## PARAMETERS

### -Identity
String.
Name or part of the Voice Routing Policy.
Can be omitted to list Names of all Policies (except "Global").
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
It behaves like Get-CsOnlineVoiceRoutingPolicy with a twist:
If more than three results are found, a reduced set of Parameters are shown for better visibility:
Get-CsOnlineVoiceRoutingPolicy | Where-Object Identity -NE 'Global' | Select-Object Identity, Description, OnlinePstnUsages

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOVP.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOVP.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_TeamsUserVoiceConfiguration]()

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

