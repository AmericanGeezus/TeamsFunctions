---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsAutoAttendant.md
schema: 2.0.0
---

# Remove-TeamsAutoAttendant

## SYNOPSIS
Removes an Auto Attendant

## SYNTAX

```
Remove-TeamsAutoAttendant [-Name] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove-CsAutoAttendant for friendly Names

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsAutoAttendant -Name "My AutoAttendant"
```

Prompts for removal for all Auto Attendant found with the string "My AutoAttendant"

### EXAMPLE 2
```
Remove-TeamsAutoAttendant -Name 00000000-0000-0000-0000-000000000000
```

Prompts for removal for all Auto Attendant found with the ObjectId 00000000-0000-0000-0000-000000000000

## PARAMETERS

### -Name
DisplayName of the Auto Attendant

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

