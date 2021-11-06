---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCP.md
schema: 2.0.0
---

# Get-TeamsCP

## SYNOPSIS
Lists all Teams Calling Policies by Name

## SYNTAX

```
Get-TeamsCP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Teams Calling Policies to assign, an Alias-Function to Get-CsTeamsCallingPolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsCP
```

Returns the Object for all Teams Calling Policies (including "Global")
Behaviour like: Get-CsTeamsCallingPolicy, showing only a few Parameters

### EXAMPLE 2
```
Get-TeamsCP -Identity AllowCallingPreventTollBypass
```

Returns the Object for the Teams Calling Policy "AllowCallingPreventTollBypass" (provided it exists).
Behaviour like: Get-CsTeamsCallingPolicy -Identity "AllowCallingPreventTollBypass"

### EXAMPLE 3
```
Get-TeamsCP -Identity Allow*
```

Lists Online Voice Routes with "Allow" in the Name
Behaviour like: Get-CsTeamsCallingPolicy -Filter "*Allow*"

## PARAMETERS

### -Identity
String.
Name or part of the Teams Calling Policy.
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
It behaves like Get-CsTeamsCallingPolicy with a twist:
If more than three results are found, a reduced set of Parameters are shown for better visibility:
Get-CsTeamsCallingPolicy | Select-Object Identity, Description, BusyOnBusyEnabledType

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCP.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCP.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

