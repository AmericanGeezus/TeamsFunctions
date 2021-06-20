---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantDialScope.md
schema: 2.0.0
---

# New-TeamsAutoAttendantDialScope

## SYNOPSIS
Creates a Dial Scope to be used in Auto Attendants

## SYNTAX

```
New-TeamsAutoAttendantDialScope [-GroupName] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Wrapper for New-CsAutoAttendantDialScope with friendly names

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantDialScope -GroupName "My Group"
```

Creates a Dial Scope for "My Group"

### EXAMPLE 2
```
New-TeamsAutoAttendantDialScope -GroupName "My Group","My other Group"
```

Creates a Dial Scope including "My Group" and "My other Group"

## PARAMETERS

### -GroupName
Required.
Name of one or more Office 365 groups to create a Dial Scope for

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
None

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantDialScope.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantDialScope.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

