---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsECP

## SYNOPSIS
Lists all Online Emergency Calling Policies by Name

## SYNTAX

```
Get-TeamsECP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Emergency Calling Policies to assign, an Alias-Function to Get-CsTeamsEmergencyCallingPolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsECP
```

Returns the Object for all Emergency Calling Policies (including "Global")
Behaviour like: Get-CsTeamsEmergencyCallingPolicy

### EXAMPLE 2
```
Get-TeamsECP -Identity ECP-US
```

Returns the Object for the Online Voice Route "ECP-US" (provided it exists).
Behaviour like: Get-CsTeamsEmergencyCallingPolicy -Identity "ECP-US"

### EXAMPLE 3
```
Get-TeamsECP -Identity ECP-US-*
```

Lists Online Voice Routes with "ECP-US-" in the Name
Behaviour like: Get-CsTeamsEmergencyCallingPolicy -Filter "*ECP-US-*"

## PARAMETERS

### -Identity
String.
Name or part of the Emergency Calling Policy.
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
This script is indulging the lazy admin.
It behaves like Get-CsOnlineVoiceRoute with a twist:
If more than three results are found, a reordered set of Parameters are shown for better visibility:
Get-CsTeamsEmergencyCallingPolicy | Select-Object Identity, Description, NotificationMode, NotificationGroup

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

