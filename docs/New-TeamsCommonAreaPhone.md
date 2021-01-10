---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# New-TeamsCommonAreaPhone

## SYNOPSIS
Creates a new Common Area Phone

## SYNTAX

```
New-TeamsCommonAreaPhone [-UserPrincipalName] <String> [-DisplayName <String>] -UsageLocation <String>
 [-License <String>] [-Password <String>] [-IPPhonePolicy <String>] [-TeamsCallingPolicy <String>]
 [-TeamsCallParkPolicy <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
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
New-TeamsCommonAreaPhone -UserPrincipalName "My Lobby Phone@TenantName.onmicrosoft.com" -UsageLocation US
```

Will create a CommonAreaPhone with a Usage Location for 'US' and assign the CommonAreaPhone License
User Principal Name will be normalised to: MyLobbyPhone@TenantName.onmicrosoft.com
DisplayName will be taken from the User PrincipalName and normalised to "MyLobbyPhone"
  No Policies will be assigned to the Common Area Phone, the Global Policy will be in effect for this Phone

### EXAMPLE 2
```
New-TeamsCommonAreaPhone -UserPrincipalName "Lobby.@TenantName.onmicrosoft.com" -Displayname "Lobby {Phone}" -UsageLocation US -License CommonAreaPhone
```

Will create a CommonAreaPhone with a Usage Location for 'US' and assign the CommonAreaPhone License
User Principal Name will be normalised to: Lobby@TenantName.onmicrosoft.com
DisplayName will be normalised to "Lobby Phone"
  No Policies will be assigned to the Common Area Phone, the Global Policy will be in effect for this Phone

### EXAMPLE 3
```
New-TeamsCommonAreaPhone -UserPrincipalName "Lobby@TenantName.onmicrosoft.com" -Displayname "Lobby Phone" -UsageLocation US -License Office365E3,PhoneSystem
```

Will create a CommonAreaPhone with a Usage Location for 'US' and assign the Office 365 E3 License as well as PhoneSystem
  No Policies will be assigned to the Common Area Phone, the Global Policy will be in effect for this Phone

### EXAMPLE 4
```
New-TeamsCommonAreaPhone -UserPrincipalName "Lobby@TenantName.onmicrosoft.com" -Displayname "Lobby Phone" -UsageLocation US -IPPhonePolicy "My IPP" -TeamsCallingPolicy "CallP" -TeamsCallParkPolicy "CallPark"
```

Will create a CommonAreaPhone with a Usage Location for 'US' and assign the CommonAreaPhone License
  The supplied Policies will be assigned to the Common Area Phone

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

Required: True
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

### -Password
Optional.
String.
8 to 16 characters, at least one uppercase letter, one lowercase letter and one number.
If not provided a Password will be generated with the string "CAP-" and todays date in the format: "CAP-03-JAN-2021"

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

