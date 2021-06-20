---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOPU.md
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

Lists all PstnUsages with the String 'PstnUsageName' in the name of the Online Pstn Usage

## PARAMETERS

### -Usage
String.
Name or part of the Online Pstn Usage.
Can be omitted to list Names of all Usages.
Searches for Usages with Get-CsOnlinePstnUsage, listing all that match.

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

### None
### System.String
## OUTPUTS

### System.Object
## NOTES
This script is indulging the lazy admin.
It behaves like (Get-CsOnlinePstnUsage).Usage
This CmdLet behaves slightly different than the others, due to the nature of Pstn Usages.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOPU.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsOPU.md)

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

