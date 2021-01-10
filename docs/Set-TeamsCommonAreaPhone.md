---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Set-TeamsCommonAreaPhone

## SYNOPSIS
Creates a new Common Area Phone

## SYNTAX

```
Set-TeamsCommonAreaPhone [-UserPrincipalName] <String> [-DisplayName <String>] [-UsageLocation <String>]
 [-License <String>] [-IPPhonePolicy <String>] [-TeamsCallingPolicy <String>] [-TeamsCallParkPolicy <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Teams Call Queues and Auto Attendants require a Common Area Phone.
It can carry a license and optionally also a phone number.
This Function was designed to create the ApplicationInstance in AD,
apply a UsageLocation to the corresponding AzureAD User,
license the User and subsequently apply a phone number, all with one Command.

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -Displayname "Lobby {Phone}"
```

Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com.
DisplayName will be normalised to "Lobby Phone" and applied.

### EXAMPLE 2
```
Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -UsageLocation US -License CommonAreaPhone
```

Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com.
Usage Location is set to 'US' and the CommonAreaPhone License is assigned.

### EXAMPLE 3
```
Set-TeamsCommonAreaPhone -UserPrincipalName MyLobbyPhone@TenantName.onmicrosoft.com -License Office365E3,PhoneSystem
```

Changes the Object MyLobbyPhone@TenantName.onmicrosoft.com.
Usage Location is required to be set.
Assigns the Office 365 E3 License as well as PhoneSystem

### EXAMPLE 4
```
Set-TeamsCommonAreaPhone -UserPrincipalName "MyLobbyPhone@TenantName.onmicrosoft.com" -IPPhonePolicy "My IPP" -TeamsCallingPolicy "CallP" -TeamsCallParkPolicy "CallPark" -PassThru
```

Applies IPPhonePolicy, TeamsCallingPolicy and TeamsCallParkPolicy to the Common Area Phone
  Displays the Common Area Phone Object afterwards

## PARAMETERS

### -UserPrincipalName
Required.
The UPN for the new CommonAreaPhone.
Invalid characters are stripped from the provided string

```yaml
Type: String
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DisplayName
Optional.
The Name it will show up as in Teams.
Invalid characters are stripped from the provided string

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UsageLocation
Required.
Two Digit Country Code of the Location of the entity.
Should correspond to the Phone Number.
Before a License can be assigned, the account needs a Usage Location populated.

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

### -License
Optional.
Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
If not provided, will default to PhoneSystem_VirtualUser
Unlicensed Objects can exist, but cannot be assigned a phone number
  NOTE: PhoneSystem is an add-on license and cannot be assigned on its own.
it has therefore been deactivated for now.

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

### -IPPhonePolicy
Optional.
Adds an IP Phone Policy to the User

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

### -TeamsCallingPolicy
Optional.
Adds a Calling Policy to the User

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

### -TeamsCallParkPolicy
Optional.
Adds a Call Park Policy to the User

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
Execution requires User Admin Role in Azure AD
To assign a Phone Number to this Object, please apply a full Voice Configuration using Set-TeamsUserVoiceConfig
This includes Phone Number and Calling Plan or Online Voice Routing Policy and optionally a Tenant Dial Plan.
This Script only covers relevant elements for Common Area Phones themselves.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsCommonAreaPhone]()

[New-TeamsCommonAreaPhone]()

[Set-TeamsCommonAreaPhone]()

[Remove-TeamsCommonAreaPhone]()

[Find-TeamsUserVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

