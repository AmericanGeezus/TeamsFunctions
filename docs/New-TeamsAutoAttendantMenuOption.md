---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantMenuOption.md
schema: 2.0.0
---

# New-TeamsAutoAttendantMenuOption

## SYNOPSIS
Creates a Menu Options Object

## SYNTAX

### DisconnectCall (Default)
```
New-TeamsAutoAttendantMenuOption [-DisconnectCall] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### CallTarget
```
New-TeamsAutoAttendantMenuOption [-Press <Int32>] [-OrSay <String>] [-CallTarget <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Operator
```
New-TeamsAutoAttendantMenuOption [-Press <Int32>] [-TransferToOperator] [-OrSay <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a Menu Options Object to be used in Auto Attendants
Wrapper for New-CsAutoAttendantMenuOption with friendly names

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantMenuOption -Disconnect
```

Creates a default Menu Option to be used for disconnecting the call.

### EXAMPLE 2
```
New-TeamsAutoAttendantMenuOption -Press 0 -TransferToOperator
```

Creates a Menu Option on pressing 0 (voice response is 'Operator' by default) to Transfer to the Operator.
Note: The Operator must be specified in the AutoAttendant!

### EXAMPLE 3
```
New-TeamsAutoAttendantMenuOption -Press 1 -CallTarget "My Group"
```

Creates a Menu Option on pressing 1 or saying 'one' (default) to Transfer to the Call Target (Shared Voicemail)

### EXAMPLE 4
```
New-TeamsAutoAttendantMenuOption -Press 2 -CallTarget Sales@domain.com -OrSay "Sales"
```

Creates a Menu Option on pressing 2 or saying 'Sales' to Transfer to the Call Target (User).

### EXAMPLE 5
```
New-TeamsAutoAttendantMenuOption -Press 3 -CallTarget MyCQ@domain.com -OrSay "Queue"
```

Creates a Menu Option on pressing 3 or saying 'Queue' to Transfer to the Call Target (Call Queue).

### EXAMPLE 6
```
New-TeamsAutoAttendantMenuOption -Press 4 -CallTarget MyAA@domain.com -OrSay "Menu"
```

Creates a Menu Option on pressing 4 or saying 'Menu' to Transfer to the Call Target (Auto Attendant).

### EXAMPLE 7
```
New-TeamsAutoAttendantMenuOption -Press 5 -CallTarget "tel:+15551234567" -OrSay "Engineer"
```

Creates a Menu Option on pressing 5 or saying 'Engineer' to Transfer to the Call Target (ExternalPstn).

## PARAMETERS

### -DisconnectCall
Required to create a basic 'Disconnect' option.
Switch.
Default.

```yaml
Type: SwitchParameter
Parameter Sets: DisconnectCall
Aliases:

Required: True
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Press
Required for Option TransferToOperator and TransferToCallTarget.
Integer.
Dtmf Tone (digit) to be pressed for this option

```yaml
Type: Int32
Parameter Sets: CallTarget, Operator
Aliases: DtmfResponseTone

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TransferToOperator
Option to transfer the Call to the Operator defined

```yaml
Type: SwitchParameter
Parameter Sets: Operator
Aliases: Operator

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrSay
Optional for Option TransferToCallTarget.
String.
Voice Response to be used for this option.
Expected: Single word

```yaml
Type: String
Parameter Sets: CallTarget, Operator
Aliases: VoiceResponses, Say

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallTarget
CallTarget

```yaml
Type: String
Parameter Sets: CallTarget
Aliases:

Required: False
Position: Named
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantMenuOption.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantMenuOption.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

