---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsIPP.md
schema: 2.0.0
---

# Get-TeamsIPP

## SYNOPSIS
Lists all IP Phone Policies by Name

## SYNTAX

```
Get-TeamsIPP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find IP Phone Policies to assign, an Alias-Function to Get-CsTeamsIPPhonePolicy

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsIPP
```

Returns the Object for all IP Phone Policies (including "Global")
Behaviour like: Get-CsTeamsIPPhonePolicy, showing only a few Parameters

### EXAMPLE 2
```
Get-TeamsIPP -Identity CommonAreaPhone
```

Returns the Object for the Online Voice Route "CommonAreaPhone" (provided it exists).
Behaviour like: Get-CsTeamsIPPhonePolicy -Identity "CommonAreaPhone"

### EXAMPLE 3
```
Get-TeamsIPP -Identity CommonAreaPhone-*
```

Lists Online Voice Routes with "CommonAreaPhone" in the Name
Behaviour like: Get-CsTeamsIPPhonePolicy -Filter "*CommonAreaPhone*"

## PARAMETERS

### -Identity
String.
Name or part of the IP Phone Policy.
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
It behaves like Get-CsTeamsIPPhonePolicy with a twist:
If more than three results are found, a reduced set of Parameters are shown for better visibility:
Get-CsTeamsIPPhonePolicy | Select-Object Identity, Description, SignInMode, HotDeskingIdleTimeoutInMinutes

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsIPP.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsIPP.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

