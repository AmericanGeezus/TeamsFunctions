---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCallQueue.md
schema: 2.0.0
---

# Remove-TeamsCallQueue

## SYNOPSIS
Removes a Call Queue

## SYNTAX

```
Remove-TeamsCallQueue [-Name] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove-CsCallQueue for friendly Names

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsCallQueue -Name "My Queue"
```

Prompts for removal for all queues found with the string "My Queue"

## PARAMETERS

### -Name
DisplayName of the Call Queue

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCallQueue.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCallQueue.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

