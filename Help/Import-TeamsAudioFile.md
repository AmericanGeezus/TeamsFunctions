---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Import-TeamsAudioFile

## SYNOPSIS
Imports an AudioFile for CallQueues or AutoAttendants

## SYNTAX

```
Import-TeamsAudioFile [-File] <String> [-ApplicationType] <String> [<CommonParameters>]
```

## DESCRIPTION
Imports an AudioFile for CallQueues or AutoAttendants with Import-CsOnlineAudioFile

## EXAMPLES

### EXAMPLE 1
```
Import-TeamsAudioFile -File C:\Temp\MyMusicOnHold.wav -ApplicationType CallQueue
```

Imports MyMusicOnHold.wav into Teams, assigns it the type CallQueue and returns the imported Object for further use.

## PARAMETERS

### -File
File to be imported

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

### -ApplicationType
ApplicationType of the entity it is for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Microsoft.Rtc.Management.Hosted.Online.Models.AudioFile
## NOTES
Translation of Import-CsOnlineAudioFile to process with New/Set-TeamsResourceAccount
Simplifies the ApplicationType input for friendly names
Captures different behavior of Get-Content (ByteStream syntax) in PowerShell 6 and above VS PowerShell 5 and below

## RELATED LINKS

[New-TeamsCallQueue
Set-TeamsCallQueue]()

