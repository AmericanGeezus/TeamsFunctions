---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCLI.md
schema: 2.0.0
---

# Get-TeamsCLI

## SYNOPSIS
Lists all Calling Line Identities by Name

## SYNTAX

```
Get-TeamsCLI [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Calling Line Identities to assign, an Alias-Function to Get-CsCallingLineIdentity

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsCLI
```

Returns the Object for all Calling Line Identities (including "Global")
Behaviour like: Get-CsCallingLineIdentity, showing only a few Parameters

### EXAMPLE 2
```
Get-TeamsCLI -Identity ResourceAccount@domain.com
```

Returns the Object for the Online Voice Route "ResourceAccount@domain.com" (provided it exists).
Behaviour like: Get-CsCallingLineIdentity -Identity "ResourceAccount@domain.com"

### EXAMPLE 3
```
Get-TeamsCLI -Identity ResourceAccount*
```

Lists Online Voice Routes with "ResourceAccount" in the Name
Behaviour like: Get-CsCallingLineIdentity -Filter "*ResourceAccount*"

## PARAMETERS

### -Identity
String.
Name or part of the Calling Line Identity.
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
It behaves like Get-CsCallingLineIdentity with a twist:
If more than three results are found, a reduced set of Parameters are shown for better visibility:
Get-CsCallingLineIdentity | Select-Object Identity, Description, SignInMode, HotDeskingIdleTimeoutInMinutes

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCLI.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsCLI.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

