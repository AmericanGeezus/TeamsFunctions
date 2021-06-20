---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendant.md
schema: 2.0.0
---

# New-TeamsAutoAttendant

## SYNOPSIS
Support function wrapping around New-CsAutoAttendant

## SYNTAX

```
New-TeamsAutoAttendant [-Name] <String> [[-TimeZone] <String>] [[-LanguageId] <String>] [[-Operator] <String>]
 [[-BusinessHoursGreeting] <String>] [[-BusinessHoursCallFlowOption] <String>]
 [[-BusinessHoursCallTarget] <String>] [[-BusinessHoursMenu] <Object>] [[-AfterHoursGreeting] <String>]
 [[-AfterHoursCallFlowOption] <String>] [[-AfterHoursCallTarget] <String>] [[-AfterHoursMenu] <Object>]
 [[-AfterHoursSchedule] <String>] [[-Schedule] <Object>] [-EnableVoiceResponse] [[-DefaultCallFlow] <Object>]
 [[-CallFlows] <Object>] [[-CallHandlingAssociations] <Object>] [[-InclusionScope] <Object>]
 [[-ExclusionScope] <Object>] [-EnableTranscription] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This script handles select and limited variety for what Auto Attendants have to offer
It should be seen as an extension rather than a replacement of New-CsAutoAttendant.
It is currently still in development!
UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendant -Name "My Auto Attendant"
```

Creates a new Auto Attendant "My Auto Attendant" with Defaults
TimeZone is UTC, Language is en-US and Schedule is Mon-Fri 9to5.
Business hours and After Hours action is Disconnect

### EXAMPLE 2
```
New-TeamsAutoAttendant -Name "My Auto Attendant" -TimeZone UTC-05:00 -LanguageId pt-BR -AfterHoursSchedule MonToFri8to12and13to18 -EnableVoiceResponse
```

Creates a new Auto Attendant "My Auto Attendant" and sets the TimeZone to UTC-5 and the language to Portuguese (Brazil)
The Schedule of Mon-Fri 8to12 and 13to18 will be applied.
Also enables VoiceResponses

### EXAMPLE 3
```
New-TeamsAutoAttendant -Name "My Auto Attendant" -Operator "tel:+1555123456"
```

Creates a new Auto Attendant "My Auto Attendant" with default TimeZone and Language, but defines an Operator as a Callable Entity (Forward to Pstn)

### EXAMPLE 4
```
New-TeamsAutoAttendant -Name "My Auto Attendant" -BusinessHoursGreeting "Welcome to Contoso" -BusinessHoursCallFlowOption TransferCallToTarget -BusinessHoursCallTarget $CallTarget
```

Creates a new Auto Attendant "My Auto Attendant" with defaults, but defines a Text-to-Voice Greeting, then forwards the Call to the Call Target.
The CallTarget is queried based on input and created as required.
UserPrincipalname for Users or ResourceAccount, Group Name for SharedVoicemail, provided as a string in the Variable $UPN
This example is equally applicable to AfterHours.

### EXAMPLE 5
```
New-TeamsAutoAttendant -Name "My Auto Attendant" -DefaultCallFlow $DefaultCallFlow -CallFlows $CallFlows -InclusionScope $InGroups -ExclusionScope $OutGroups
```

Creates a new Auto Attendant "My Auto Attendant" and passes through all objects provided.
In this example, provided Objects are
passed on through tto New-CsAutoAttendant and override other respective Parmeters provided:
- A DefaultCallFlow Object is passed on which overrides all "-BusinessHours"-Parmeters
- One or more CallFlows Objects are passed on which override all "-AfterHours"-Parameters
- One or more CallHandlingAssociation Objects are passed on which override all "-AfterHours"-Parameters
- An InclusionScope and an ExclusionScope are defined.
These are passed on as-is
All other values, like Language and TimeZone are defined with their defaults and can still be defined with the Objects.

## PARAMETERS

### -Name
Name of the Auto Attendant.
Name will be normalised (unsuitable characters are filtered)
Used as the DisplayName - Visible in Teams

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TimeZone
Required.
TimeZone Identifier based on Get-CsAutoAttendantSupportedTimeZone, but abbreviated for easier input.
Warning: Due to multiple time zone names with in the same relative difference to UTC this MAY produce incongruent output
The time zone will be correct, but only specifying "UTC+01:00" for example will select the first entry.
Default Value: "UTC"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: UTC
Accept pipeline input: False
Accept wildcard characters: False
```

### -LanguageId
Required.
Language Identifier indicating the language that is used to play text and identify voice prompts.
Default Value: "en-US"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### -Operator
Optional.
Creates a Callable entity for the Operator
Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursGreeting
Optional.
Creates a Greeting for the Default Call Flow (during business hours) utilising New-TeamsAutoAttendantPrompt
A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
The last 4 digits will determine the type.
For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
If DefaultCallFlow is provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursCallFlowOption
Optional.
Disconnect, TransferCallToTarget, Menu.
Default is Disconnect.
TransferCallToTarget requires BusinessHoursCallTarget.
Menu requires BusinessHoursMenu
If DefaultCallFlow is provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursCallTarget
Optional.
Requires BusinessHoursCallFlowOption to be TransferCallToTarget.
Creates a Callable entity for this Call Target.
Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
If DefaultCallFlow is provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursMenu
Optional.
Requires BusinessHoursCallFlowOption to be Menu and a BusinessHoursCallTarget
If DefaultCallFlow is provided, this parameter will be ignored.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterHoursGreeting
Optional.
Creates a Greeting for the After Hours Call Flow utilising New-TeamsAutoAttendantPrompt
A supported Audio File or a text string that is parsed by the text-to-voice engine in the Language specified
The last 4 digits will determine the type.
For an AudioFile they are expected to be the file extension: '.wav', '.wma' or 'mp3'
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterHoursCallFlowOption
Optional.
Disconnect, TransferCallToTarget, Menu.
Default is Disconnect.
TransferCallToTarget requires AfterHoursCallTarget.
Menu requires AfterHoursMenu
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterHoursCallTarget
Optional.
Requires AfterHoursCallFlowOption to be TransferCallToTarget.
Creates a Callable entity for this Call Target
Expected are UserPrincipalName (User, ApplicationEndPoint), a TelURI (ExternalPstn), an Office 365 Group Name (SharedVoicemail)
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterHoursMenu
Optional.
Requires AfterHoursCallFlowOption to be Menu and a AfterHoursCallTarget
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterHoursSchedule
Optional.
Default Schedule to apply: One of: MonToFri9to5 (default), MonToFri8to12and13to18, Open24x7
A more granular Schedule can be used with the Parameter -Schedule
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Schedule
Optional.
Custom Schedule object to apply for After Hours Call Flow
Object created with New-TeamsAutoAttendantSchedule or New-CsAutoAttendantSchedule
If CallFlows or CallHandlingAssociations are provided, this parameter will be ignored.
Using this parameter to define the Schedule will override the Parameter -AfterHoursSchedule

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableVoiceResponse
Optional Switch to be passed to New-CsAutoAttendant

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultCallFlow
Optional.
Call Flow Object to pass to New-CsAutoAttendant (used as the Default Call Flow)
Using this parameter to define the default Call Flow overrides all -BusinessHours Parameters

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallFlows
Optional.
Call Flow Object to pass to New-CsAutoAttendant
Using this parameter to define additional Call Flows overrides all -AfterHours Parameters
Requires Parameter CallHandlingAssociations in conjunction

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallHandlingAssociations
Optional.
Call Handling Associations Object to pass to New-CsAutoAttendant
Using this parameter to define additional Call Flows overrides all -AfterHours Parameters
Requires Parameter CallFlows in conjunction

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InclusionScope
Optional.
DialScope Object to pass to New-CsAutoAttendant
Object created with New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExclusionScope
Optional.
DialScope Object to pass to New-CsAutoAttendant
Object created with New-TeamsAutoAttendantDialScope or New-CsAutoAttendantDialScope

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableTranscription
Optional.
Where possible, tries to enable Voicemail Transcription.
Effective only for SharedVoicemail Targets as an Operator or MenuOption.
Otherwise has no effect.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Suppresses confirmation prompt to enable Users for Enterprise Voice, if Users are specified
Currently no other impact

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsAutoAttendant]()

[New-TeamsCallQueue]()

[New-TeamsAutoAttendant]()

[Set-TeamsAutoAttendant]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

[New-TeamsAutoAttendantCallFlow]()

[New-TeamsAutoAttendantMenu]()

[New-TeamsAutoAttendantMenuOption]()

[New-TeamsAutoAttendantPrompt]()

[New-TeamsAutoAttendantSchedule]()

[New-TeamsAutoAttendantDialScope]()

[Remove-TeamsAutoAttendant]()

[New-TeamsResourceAccount]()

[New-TeamsResourceAccountAssociation]()

