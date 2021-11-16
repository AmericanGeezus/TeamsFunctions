---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsPhoneNumber.md
schema: 2.0.0
---

# Set-TeamsPhoneNumber

## SYNOPSIS
Applies a Phone Number to a User Object or Resource Account

## SYNTAX

### UserPrincipalName (Default)
```
Set-TeamsPhoneNumber [-UserPrincipalName] <String[]> [-PhoneNumber] <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Object
```
Set-TeamsPhoneNumber [-Object] <Object[]> [-PhoneNumber] <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Applies a Microsoft Calling Plans Number OR a Direct Routing Number to a User or Resource Account

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsPhoneNumber -UserPrincipalName John@domain.com -PhoneNumber +15551234567
```

Applies the Phone Number +1 (555) 1234-567 to the Account John@domain.com

## PARAMETERS

### -Object
Required for Parameterset Object.
CsOnlineUser Object passed to the function to reduce query time.
This can be a UPN of a User Account (CsOnlineUser Object) or a Resource Account (CsOnlineApplicationInstance Object)

```yaml
Type: Object[]
Parameter Sets: Object
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserPrincipalName
Required for Parameterset UserPrincipalName.
UserPrincipalName of the Object to be assigned the PhoneNumber.
This can be a UPN of a User Account (CsOnlineUser Object) or a Resource Account (CsOnlineApplicationInstance Object)

```yaml
Type: String[]
Parameter Sets: UserPrincipalName
Aliases: ObjectId, Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PhoneNumber
A Microsoft Calling Plans Number or a Direct Routing Number
Requires the Account to be licensed.
Able to enable PhoneSystem and the Account for Enterprise Voice
Required format is E.164 or LineUri, starting with a '+' and 10-15 digits long.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Tel, Number, TelephoneNumber

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Suppresses confirmation prompt unless -Confirm is used explicitly
Scavenges Phone Number from all accounts the PhoneNumber is currently assigned to including the current User

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

### System.Void - If called directly
### Boolean - If called by another CmdLet
## NOTES
Simple helper function to assign a Phone Number to any User or Resource Account
Returns boolean result and less communication if called by another function
Can be used providing either the UserPrincipalName or the already queried CsOnlineUser Object

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsPhoneNumber.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Set-TeamsPhoneNumber.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

