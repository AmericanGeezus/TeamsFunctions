---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantCallFlow.md
schema: 2.0.0
---

# New-TeamsAutoAttendantCallFlow

## SYNOPSIS
Creates a Call Flow Object to be used in Auto Attendants

## SYNTAX

### Disconnect (Default)
```
New-TeamsAutoAttendantCallFlow [-Name <String>] [-Greeting <Object>] [-Disconnect] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Menu
```
New-TeamsAutoAttendantCallFlow [-Name <String>] [-Greeting <Object>] [-Menu <Object>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### TransferToCallTarget
```
New-TeamsAutoAttendantCallFlow [-Name <String>] [-Greeting <Object>] [-TransferToCallTarget <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a Call Flow with optional Prompt and Menu to be used in Auto Attendants
Wrapper for New-CsAutoAttendantCallFlow with friendly names
Combines New-CsAutoAttendantMenu, New-CsAutoAttendantPrompt

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantCallFlow [-Name "Default Call Flow"] -Menu $MenuObject [-Greeting $PromptObject]
```

Classic behaviour, synonymous with functionality provided by New-CsAutoAttendantCallFlow.
Please see parameters there.
Creates Call Flow with the Menu Object provided and optionally applies the PromptObject as the Greeting.

### EXAMPLE 2
```
New-TeamsAutoAttendantCallFlow -Menu $MenuObject -Greeting "Welcome to Contoso"
```

Creates Call Flow with the Menu Object provided and creates the Greeting with the provided String (Text-to-voice)

### EXAMPLE 3
```
New-TeamsAutoAttendantCallFlow -TransferToCallTarget "John@domain.com"
```

Creates a Menu Object to transfer the Call to a call Target and no Greeting
UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)

### EXAMPLE 4
```
New-TeamsAutoAttendantCallFlow -Disconnect
```

Default.
Creates Call Flow with a default Disconnect and no Greeting

## PARAMETERS

### -Name
Optional.
Name of the Call Flow if desired.
Otherwise generated automatically.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Greeting
Optional.
A Prompts Object, String or Full path to AudioFile.
A Prompts Object will be used as is, otherwise it will be created dependent of the provided String
A String will be used as Text-to-Voice.
A File ending in .wav, .mp3 or .wma will be used to create a recording.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Menu
Optional.
Menu Object to be used.

```yaml
Type: Object
Parameter Sets: Menu
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disconnect
Optional.
Creates a default Menu, disconnecting the Call.

```yaml
Type: SwitchParameter
Parameter Sets: Disconnect
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TransferToCallTarget
Optional.
String.
Creates a default Menu, redirecting to the specified Call Target
UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)

```yaml
Type: String
Parameter Sets: TransferToCallTarget
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
Limitations: DialByName

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantCallFlow.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantCallFlow.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

