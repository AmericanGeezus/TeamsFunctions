---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# New-TeamsCallQueue

## SYNOPSIS
New-CsCallQueue with UPNs instead of IDs

## SYNTAX

```
New-TeamsCallQueue [-Name] <String> [-UseMicrosoftDefaults] [[-AgentAlertTime] <Int16>]
 [[-AllowOptOut] <Boolean>] [[-OverflowAction] <String>] [[-OverflowActionTarget] <String>]
 [[-OverflowSharedVoicemailTextToSpeechPrompt] <String>] [[-OverflowSharedVoicemailAudioFile] <String>]
 [[-EnableOverflowSharedVoicemailTranscription] <Boolean>] [[-OverflowThreshold] <Int16>]
 [[-TimeoutAction] <String>] [[-TimeoutActionTarget] <String>]
 [[-TimeoutSharedVoicemailTextToSpeechPrompt] <String>] [[-TimeoutSharedVoicemailAudioFile] <String>]
 [[-EnableTimeoutSharedVoicemailTranscription] <Boolean>] [[-TimeoutThreshold] <Int16>]
 [[-RoutingMethod] <String>] [[-PresenceBasedRouting] <Boolean>] [[-UseDefaultMusicOnHold] <Boolean>]
 [[-ConferenceMode] <Boolean>] [[-WelcomeMusicAudioFile] <String>] [[-MusicOnHoldAudioFile] <String>]
 [[-DistributionLists] <String[]>] [[-Users] <String[]>] [[-ChannelUsers] <String[]>]
 [[-TeamAndChannel] <String>] [[-ResourceAccountsForCallerId] <String[]>] [[-LanguageId] <String>] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Does all the same things that New-CsCallQueue does, but differs in a few significant respects:
UserPrincipalNames can be provided instead of IDs, FileNames (FullName) can be provided instead of IDs
File Import is handled by this Script
Small changes to defaults (see Parameter UseMicrosoftDefaults for details)
Partial implementation is possible, output will show differences.

## EXAMPLES

### EXAMPLE 1
```
New-TeamsCallQueue -Name "My Queue"
```

Creates a new Call Queue "My Queue" with the Default Music On Hold
All other values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)

### EXAMPLE 2
```
New-TeamsCallQueue -Name "My Queue" -UseMicrosoftDefaults
```

Creates a new Call Queue "My Queue" with the Default Music On Hold
All values not specified default to Microsoft defaults for New-CsCallQueue (See Parameter UseMicrosoftDefaults)

### EXAMPLE 3
```
New-TeamsCallQueue -Name "My Queue" -OverflowThreshold 5 -TimeoutThreshold 90
```

Creates a new Call Queue "My Queue" and sets it to overflow with more than 5 Callers waiting and a timeout window of 90s
All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)

### EXAMPLE 4
```
New-TeamsCallQueue -Name "My Queue" -MusicOnHoldAudioFile C:\Temp\Moh.wav -WelcomeMusicAudioFile C:\Temp\WelcomeMessage.wmv
```

Creates a new Call Queue "My Queue" with custom Audio Files
All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)

### EXAMPLE 5
```
New-TeamsCallQueue -Name "My Queue" -AgentAlertTime 15 -RoutingMethod Serial -AllowOptOut:$false -DistributionLists @(List1@domain.com,List2@domain.com)
```

Creates a new Call Queue "My Queue" alerting every Agent nested in Azure AD Groups List1@domain.com and List2@domain.com in sequence for 15s.
All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults

### EXAMPLE 6
```
New-TeamsCallQueue -Name "My Queue" -OverflowAction Forward -OverflowActionTarget SIP@domain.com -TimeoutAction Voicemail
```

Creates a new Call Queue "My Queue" forwarding to SIP@domain.com for Overflow and to Voicemail when it times out.
All values not specified default to optimised defaults (See Parameter UseMicrosoftDefaults)

## PARAMETERS

### -Name
Name of the Call Queue.
Name will be normalised (unsuitable characters are filtered)
Used as the DisplayName - Visible in Teams

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

### -UseMicrosoftDefaults
This script uses different default values for some parameters than New-CsCallQueue
Using this switch will instruct the Script to adhere to Microsoft defaults.
ChangedPARAMETER:      This Script   Microsoft    Reason:
- OverflowThreshold:      10            50          Smaller Queue Size (Waiting Callers) more universally useful
- TimeoutThreshold:       30s           1200s       Shorter Threshold for timeout more universally useful
- UseDefaultMusicOnHold:  TRUE*         NONE        ONLY if neither UseDefaultMusicOnHold nor MusicOnHoldAudioFile are specificed
This only affects parameters which are NOT specified when running the script.

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
Position: 2
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
Position: 3
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
Position: 4
Default value: DisconnectWithBusy
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
Position: 5
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
Position: 6
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
Aliases: OfVMFile

Required: False
Position: 7
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
Aliases: TranscribeOfVm

Required: False
Position: 8
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverflowThreshold
Optional.
Time in Seconds for the OverflowAction to trigger
Default:  30s,   Microsoft Default:   50s (See Parameter UseMicrosoftDefaults)

```yaml
Type: Int16
Parameter Sets: (All)
Aliases: OfThreshold, OfQueueLength

Required: False
Position: 9
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
Position: 10
Default value: Disconnect
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
Position: 11
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
Position: 12
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
Aliases: ToVMFile

Required: False
Position: 13
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
Aliases: TranscribeToVm

Required: False
Position: 14
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutThreshold
Optional.
Time in Seconds for the TimeoutAction to trigger
Default:  30s,   Microsoft Default:  1200s (See Parameter UseMicrosoftDefaults)

```yaml
Type: Int16
Parameter Sets: (All)
Aliases: ToThreshold

Required: False
Position: 15
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
Position: 16
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
Position: 17
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
Position: 18
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
Position: 19
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WelcomeMusicAudioFile
Optional.
Path to Audio File to be used as a Welcome message
Accepted Formats: MP3, WAV or WMA format, max 5MB

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MusicOnHoldAudioFile
Optional.
Path to Audio File to be used as Music On Hold.
Accepted Formats: MP3, WAV or WMA format, max 5MB
If not provided, UseDefaultMusicOnHold is set to TRUE

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

### -DistributionLists
Optional.
Display Names of DistributionLists or Groups.
Their members are to become Agents in the Queue.
Mutually exclusive with TeamAndChannel.
Can be combined with Users.
Will be parsed after Users if they are specified as well.
To be considered for calls, members of the DistributionsLists must be Enabled for Enterprise Voice.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users
Optional.
UserPrincipalNames of Users that are to become Agents in the Queue.
Mutually exclusive with TeamAndChannel.
Can be combined with DistributionLists.
Will be parsed first.
Order is only important if Serial Routing is desired (See Parameter RoutingMethod)
Users are only added if they have a PhoneSystem license and are or can be enabled for Enterprise Voice.

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

### -ChannelUsers
Optional.
UserPrincipalNames of Users.
Unknown use-case right now.
Feeds Parameter ChannelUserObjectId
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

### -TeamAndChannel
Optional.
Uses a Channel to route calls to.
Members of the Channel become Agents in the Queue.
Mutually exclusive with Users and DistributionLists.
Acceptable format for Team and Channel is "TeamIdentifier\ChannelIdentifier".
Acceptable Identifier for Teams are GroupId (GUID) or DisplayName.
NOTE: DisplayName may not be unique.
Acceptable Identifier for Channels are Id (GUID) or DisplayName.

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

### -ResourceAccountsForCallerId
Optional.
Resource Account to be used for allowing Agents to use its number as a Caller Id.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 26
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
Position: 27
Default value: None
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
Audio Files, if not found will result in this option not being configured.
Warnings are displayed, but default options or none are taken.
WelcomeMusicAudioFile - No Greeting is played (default)
MusicOnHoldAudioFile - No custom MusicOnHold is played (UseDefaultMusicOnHold is used)
OverflowSharedVoicemailAudioFile - SharedVoicemail will not be configured
TimeoutSharedVoicemailAudioFile - SharedVoicemail will not be configured

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsCallQueue]()

[New-TeamsCallQueue]()

[Get-TeamsCallQueue]()

[Set-TeamsCallQueue]()

[Remove-TeamsCallQueue]()

[New-TeamsAutoAttendant]()

[New-TeamsResourceAccount]()

[New-TeamsResourceAccountAssociation]()

