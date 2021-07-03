---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantPrompt.md
schema: 2.0.0
---

# New-TeamsAutoAttendantPrompt

## SYNOPSIS
Creates a prompt

## SYNTAX

```
New-TeamsAutoAttendantPrompt [-String] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Wrapper for New-CsAutoAttendantPrompt for easier use

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantPrompt -String "Welcome to Contoso"
```

Creates a Text-to-Voice Prompt for the String
Warning: This will break if the String ends in a supported File extension

### EXAMPLE 2
```
New-TeamsAutoAttendantPrompt -String "myAudioFile.mp3"
```

Verifies the file exists, then imports it (with Import-TeamsAudioFile)
Creates a Audio File Prompt after import.

## PARAMETERS

### -String
Required.
String as a Path for a Recording or a Greeting (Text-to-Voice)

```yaml
Type: String
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
Warning: The Automatic detection of the String depends on the last 4 characters of the String.
This will break if the String ends in a supported File extension (WAV, WMA or MP3), for example.
This Cmdlet does not allow use of the ActiveType Parameter as the the type is inferred by the string provided.
Further development may see an addition of a secondary String (which would then make the provided -String the active type)

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantPrompt.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantPrompt.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

