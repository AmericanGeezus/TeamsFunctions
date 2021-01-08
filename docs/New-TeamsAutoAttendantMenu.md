---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# New-TeamsAutoAttendantMenu

## SYNOPSIS
Creates a Menu Object to be used in Auto Attendants

## SYNTAX

### Disconnect (Default)
```
New-TeamsAutoAttendantMenu [-Name <String>] -Action <String> [-EnableDialByName]
 [-DirectorySearchMethod <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### MenuOptions2
```
New-TeamsAutoAttendantMenu [-Name <String>] -Action <String> -Prompts <Object> -CallTargetsInOrder <String[]>
 [-AddOperatorOnZero] [-EnableDialByName] [-DirectorySearchMethod <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### MenuOptions
```
New-TeamsAutoAttendantMenu [-Name <String>] -Action <String> -Prompts <Object> -MenuOptions <Object[]>
 [-EnableDialByName] [-DirectorySearchMethod <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### TransferToCallTarget
```
New-TeamsAutoAttendantMenu [-Name <String>] -Action <String> -CallTarget <String> [-EnableDialByName]
 [-DirectorySearchMethod <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a Menu Object with Prompt and/or MenuOptions to be used in Auto Attendants
Wrapper for New-CsAutoAttendantMenu with friendly names
Combines New-CsAutoAttendantMenu, New-CsAutoAttendantPrompt and New-CsAutoAttendantMenuOption

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantMenu -Name "My Menu" -Action MenuOptions -Prompts $Prompts -MenuOptions $MenuOptions [-EnableDialByName] [-DirectorySearchMethod ByName]
```

Classic behaviour, mostly synonymous with functionality provided by New-CsAutoAttendantMenu.
Please see parameters there.
Creates Menu with the MenuOptions Objects provided and applies the Prompts Object as the Greeting.
Parameters EnableDialByName and DirectorySearchMethod can be used as outlined in New-CsAutoAttendantMenu

### EXAMPLE 2
```
New-TeamsAutoAttendantMenu -Action MenuOptions -Prompts "Press 1 for Sales..." -MenuOptions $MenuOptions -DirectorySearchMethod ByExtension
```

Creates a Menu with a Prompt and MenuOptions.
Creates a Prompts Object with the provided Text-to-voice string.
Creates Menu with the MenuOptions Objects provided.
DirectorySearchMethod is set to ByExtension

### EXAMPLE 3
```
New-TeamsAutoAttendantMenu -Action MenuOptions -Prompts "C:\temp\Menu.wav" -CallTargetsInOrder "MyCQ@domain.com","MyAA@domain.com","$null","tel:+15551234567"
```

Creates a Menu with a Prompt and MenuOptions.
Creates a Prompts Object with the provided Path to the Audio File.
Creates a Menu Object with the Call Targets provided in order of application depending on identified ObjectType:
Option 1 and 2 will be TransferToCallTarget (ApplicationEndpoint), Call Queue and Auto Attendant respectively.
Option 3 will not be assigned ($null), Option 4 will be TransferToCallTarget (ExternalPstn)
Maximum 10 options are supported, if more than 9 are provided, the Switch AddOperatorOnZero (if used) is ignored.
NOTE: This method does not allow specifying User Object that are intended to forward to the Users Voicemail!

### EXAMPLE 4
```
New-TeamsAutoAttendantMenu -Action MenuOptions -Prompts "Press 1 for John, Press 3 for My Group" -CallTargetsInOrder "John@domain.com","","My Group"
```

Creates a Menu with a Prompt and MenuOptions.
Creates a Prompts Object with the provided Text-to-voice string.
Creates a Menu with MenuOptions Objects provided in order with the Parameter CallTargetsInOrder depending on identified ObjectType:
Option 1 will be TransferToCallTarget (User), Option 2 is unassigned (empty string),
Option 3 is TransferToCallTarget (Shared Voicemail)
Maximum 10 options are supported, if more than 9 are provided, the Switch AddOperatorOnZero (if used) is ignored.
NOTE: This method does not allow specifying User Object that are intended to forward to the Users Voicemail!

### EXAMPLE 5
```
New-TeamsAutoAttendantMenu -Action Disconnect
```

Creates a default Menu, disconnecting the Call

### EXAMPLE 6
```
New-TeamsAutoAttendantMenu -Action TransferToOperator
```

Creates a default Menu, transferring the Call to the Operator

### EXAMPLE 7
```
New-TeamsAutoAttendantMenu -Action TransferToCallTarget -CallTarget "John@domain.com"
```

Creates a default Menu, transferring the Call to the Call target.
Expected UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)

## PARAMETERS

### -Name
Optional.
Name of the Menu if desired.
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

### -Action
Required.
MenuOptions, Disconnect, TransferToCallTarget.
Determines the type of Menu to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompts
Required for Action "MenuOptions" only.
A Prompts Object, String or Full path to AudioFile.
A Prompts Object will be used as is, otherwise it will be created dependent of the provided String
A String will be used as Text-to-Voice.
A File path ending in .wav, .mp3 or .wma will be used to create a recording.

```yaml
Type: Object
Parameter Sets: MenuOptions2, MenuOptions
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MenuOptions
Required for Action "MenuOptions" only.
Mutually exclusive with CallTargetsInOrder.
MenuOptions objects created with either New-TeamsAutoAttendantMenuOption or New-CsAutoAttenantMenuOption.

```yaml
Type: Object[]
Parameter Sets: MenuOptions
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallTargetsInOrder
Required for Action "MenuOptions" only.
Mutually exclusive with MenuOptions.
Call Targets for Menu Options.
Expected UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)
Allows to skip options with empty strings ("") or "$null".
See Examples for details

```yaml
Type: String[]
Parameter Sets: MenuOptions2
Aliases: MenuOptionsInOrder

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallTarget
Required for Action "TransferToCallTarget" only.
Single Call Target to redirect Calls to.
UserPrincipalName (User, ApplicationEndpoint), Group Name (Shared Voicemail), Tel Uri (ExternalPstn)

```yaml
Type: String
Parameter Sets: TransferToCallTarget
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddOperatorOnZero
Optional for Action MenuOptions when used with CallTargetsInOrder only.
This switch is ignored if more than nine (9) CallTargetsInOrder are specified
Adds one more menu option to Transfer the Call to the Operator on pressing 0.
NOTE: The AutoAttendant which will receive a Menu with this option, must have an Operator defined.
Errors may occur if no operator is present.

```yaml
Type: SwitchParameter
Parameter Sets: MenuOptions2
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableDialByName
Required for Action "MenuOptions" only.
Hashtable of Routing Targets.
DTMF tones are assigned in order with 0 being TransferToOperator

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

### -DirectorySearchMethod
Required for Action "MenuOptions" only.
Hashtable of Routing Targets.
DTMF tones are assigned in order with 0 being TransferToOperator

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
Limitations: CallTargetsInOrder are Menu Options integrated and their type is parsed with Get-TeamsCallableEntity
This provides the following limitations:
1) Operator can only be specified as a redirection target on "Press 0" with Switch AddOperatorOnZero, not as an option in CallTargetsInOrder.
2) Provided UPNs that are found to be AzureAdUsers are limited to be used as "Person in the Organisation"
If forwarding to the Users Voicemail is required, please change this in the Admin Center afterwards.
To overcome either limitation, please define MenuOptions yourself and use with the MenuOptions Parameter.

To define Menu Options manually, please see:
https://docs.microsoft.com/en-us/powershell/module/skype/new-csautoattendantmenuoption?view=skype-ps

Please see 'Set up an auto attendant' for details:
https://docs.microsoft.com/en-us/MicrosoftTeams/create-a-phone-system-auto-attendant?WT.mc_id=TeamsAdminCenterCSH

## RELATED LINKS

[New-TeamsAutoAttendant
Set-TeamsAutoAttendant
New-TeamsCallableEntity
New-TeamsAutoAttendantCallFlow
New-TeamsAutoAttendantMenu
New-TeamsAutoAttendantMenuOption
New-TeamsAutoAttendantPrompt
New-TeamsAutoAttendantSchedule
New-TeamsAutoAttendantDialScope
https://docs.microsoft.com/en-us/MicrosoftTeams/create-a-phone-system-auto-attendant?WT.mc_id=TeamsAdminCenterCSH
https://docs.microsoft.com/en-us/powershell/module/skype/new-csautoattendantmenuoption?view=skype-ps]()

