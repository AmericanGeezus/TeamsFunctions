---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Set-TeamsCallQueue

## SYNOPSIS
Set-CsCallQueue with UPNs instead of IDs

## SYNTAX

```
Set-TeamsCallQueue [-Name] <String> [[-DisplayName] <String>] [[-AgentAlertTime] <Int16>]
 [[-AllowOptOut] <Boolean>] [[-OverflowAction] <String>] [[-OverflowActionTarget] <String>]
 [[-OverflowSharedVoicemailTextToSpeechPrompt] <String>] [[-OverflowSharedVoicemailAudioFile] <String>]
 [[-EnableOverflowSharedVoicemailTranscription] <Boolean>] [[-OverflowThreshold] <Int16>]
 [[-TimeoutAction] <String>] [[-TimeoutActionTarget] <String>]
 [[-TimeoutSharedVoicemailTextToSpeechPrompt] <String>] [[-TimeoutSharedVoicemailAudioFile] <String>]
 [[-EnableTimeoutSharedVoicemailTranscription] <Boolean>] [[-TimeoutThreshold] <Int16>]
 [[-RoutingMethod] <String>] [[-PresenceBasedRouting] <Boolean>] [[-UseDefaultMusicOnHold] <Boolean>]
 [[-ConferenceMode] <Boolean>] [[-WelcomeMusicAudioFile] <String>] [[-MusicOnHoldAudioFile] <String>]
 [[-DistributionLists] <String[]>] [[-Users] <String[]>] [[-LanguageId] <String>] [-PassThru] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Does all the same things that Set-CsCallQueue does, but differs in a few significant respects:
UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
Set-CsCallQueue   is used to apply parameters dependent on specification.
Partial implementation is possible, output will show differences.

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsCallQueue -Name "My Queue" -DisplayName "My new Queue Name"
```

Changes the DisplayName of Call Queue "My Queue" to "My new Queue Name"

### EXAMPLE 2
```
Set-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
```

Changes the Call Queue "My Queue" to use Microsoft Default Values

### EXAMPLE 3
```
Set-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
```

Changes the Call Queue "My Queue" to overflow with more than 5 Callers waiting and a timeout window of 90s

### EXAMPLE 4
```
Set-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
```

Changes the Call Queue "My Queue" with custom Audio Files

### EXAMPLE 5
```
Set-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
```

Changes the Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.

### EXAMPLE 6
```
Set-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
```

Changes the Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.

## PARAMETERS

### -Name
Required.
Friendly Name of the Call Queue.
Used to Identify the Object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DisplayName
Optional.
Updates the Name of the Call Queue.
Name will be normalised (unsuitable characters are filtered)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentAlertTime
Optional.
Time in Seconds to alert each agent.
Works depending on Routing method
Size AgentAlertTime and TimeoutThreshold depending on Routing method and # of Agents available.

```yaml
Type: Int16
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowOptOut
Optional Switch.
Allows Agents to Opt out of receiving calls from the Call Queue

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowAction
Optional.
Action to be taken if the Queue size limit (OverflowThreshold) is reached
Forward requires specification of OverflowActionTarget
Default: DisconnectWithBusy, Values: DisconnectWithBusy, Forward, VoiceMail, SharedVoiceMail

```yaml
Type: String
Parameter Sets: (All)
Aliases: OA

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowActionTarget
Situational.
Required only if OverflowAction is not DisconnectWithBusy
UserPrincipalName of the Target

```yaml
Type: String
Parameter Sets: (All)
Aliases: OAT

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowSharedVoicemailTextToSpeechPrompt
Situational.
Text to be read for a Shared Voicemail greeting.
Requires LanguageId
Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailAudioFile is $null

```yaml
Type: String
Parameter Sets: (All)
Aliases: OfSVmTTS

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowSharedVoicemailAudioFile
Situational.
Path to the Audio File for a Shared Voicemail greeting
Required if OverflowAction is SharedVoicemail and OverflowSharedVoicemailTextToSpeechPrompt is $null

```yaml
Type: String
Parameter Sets: (All)
Aliases: OverflowSharedVMFile

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableOverflowSharedVoicemailTranscription
Situational.
Boolean Switch.
Requires specification of LanguageId
Enables a transcription of the Voicemail message to be sent to the Group mailbox

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: EnableOfSVmTranscript

Required: False
Position: 9
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowThreshold
Optional.
Time in Seconds for the OverflowAction to trigger

```yaml
Type: Int16
Parameter Sets: (All)
Aliases: OfThreshold, OfQueueLength

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutAction
Optional.
Action to be taken if the TimeoutThreshold is reached
Forward requires specification of TimeoutActionTarget
  Default: Disconnect, Values: Disconnect, Forward, VoiceMail, SharedVoiceMail

```yaml
Type: String
Parameter Sets: (All)
Aliases: TA

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutActionTarget
Situational.
Required only if TimeoutAction is not Disconnect
UserPrincipalName of the Target

```yaml
Type: String
Parameter Sets: (All)
Aliases: TAT

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSharedVoicemailTextToSpeechPrompt
Situational.
Text to be read for a Shared Voicemail greeting.
Requires LanguageId
Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailAudioFile is $null

```yaml
Type: String
Parameter Sets: (All)
Aliases: ToSVmTTS

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSharedVoicemailAudioFile
Situational.
Path to the Audio File for a Shared Voicemail greeting
Required if TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailTextToSpeechPrompt is $null

```yaml
Type: String
Parameter Sets: (All)
Aliases: TimeoutSharedVMFile

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableTimeoutSharedVoicemailTranscription
Situational.
Boolean Switch.
Requires specification of LanguageId
Enables a transcription of the Voicemail message to be sent to the Group mailbox

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: EnableToSVmTranscript

Required: False
Position: 15
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutThreshold
Optional.
Time in Seconds for the TimeoutAction to trigger

```yaml
Type: Int16
Parameter Sets: (All)
Aliases: ToThreshold

Required: False
Position: 16
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoutingMethod
Optional.
Describes how the Call Queue is hunting for an Agent.
Serial will Alert them one by one in order specified (Distribution lists will contact alphabethically)
Attendant behaves like Parallel if PresenceBasedRouting is used.
Default: Attendant, Values: Attendant, Serial, RoundRobin, LongestIdle

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: Attendant
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresenceBasedRouting
Optional.
Default: FALSE.
If used alerts Agents only when they are available (Teams status).

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseDefaultMusicOnHold
Optional Switch.
Indicates whether the default Music On Hold should be used.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConferenceMode
Optional.
Will establish a conference instead of a direct call and should help with connection time.
Default: TRUE,   Microsoft Default: FALSE

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WelcomeMusicAudioFile
Optional or $NULL.
Path to Audio File to be used as a Welcome message
Accepted Formats: MP3, WAV or WMA, max 5MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MusicOnHoldAudioFile
Optional.
Path to Audio File to be used as Music On Hold.
Accepted Formats: MP3, WAV or WMA, max 5MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DistributionLists
Optional.
Display Names of DistributionLists or Groups to be used as Agents.
Will be parsed after Users if they are specified as well.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users
Optional.
UPNs of Users.
  Will be parsed first.
Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
  Users are only added if they have a PhoneSystem license and are or can be enabled for Enterprise Voice.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 24
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LanguageId
Optional Language Identifier indicating the language that is used to play shared voicemail prompts.
This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 25
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
By default, no output is generated, PassThru will display the Object changed

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

### System.Object or None
## NOTES
Changes settings of an existing Call Queue

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsCallQueue]()

[New-TeamsCallQueue]()

[Get-TeamsCallQueue]()

[Set-TeamsCallQueue]()

[Remove-TeamsCallQueue]()

[Set-TeamsAutoAttendant]()

