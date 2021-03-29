---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsCommonAreaPhone

## SYNOPSIS
Returns Common Area Phones from AzureAD

## SYNTAX

### Identity (Default)
```
Get-TeamsCommonAreaPhone [[-UserPrincipalName] <String[]>] [<CommonParameters>]
```

### DisplayName
```
Get-TeamsCommonAreaPhone [-DisplayName <String>] [<CommonParameters>]
```

### Number
```
Get-TeamsCommonAreaPhone [-PhoneNumber <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns one or more AzureAdUser Accounts that are Common Area Phones
Accounts returned are strictly limited to having to have the Common Area Phone License assigned.

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsCommonAreaPhone
```

Returns all Common Area Phones.
NOTE: Depending on size of the Tenant, this might take a while.

### EXAMPLE 2
```
Get-TeamsCommonAreaPhone -Identity MyCAP@TenantName.onmicrosoft.com
```

Returns the Common Area Phone with the Identity specified, if found.

### EXAMPLE 3
```
Get-TeamsCommonAreaPhone -DisplayName "Lobby"
```

Returns all Common Area Phones with "Lobby" as part of their Display Name.

### EXAMPLE 4
```
Get-TeamsCommonAreaPhone -PhoneNumber +1555123456
```

Returns the Resource Account with the Phone Number specified, if found.

## PARAMETERS

### -UserPrincipalName
Default and positional.
One or more UserPrincipalNames to be queried

```yaml
Type: String[]
Parameter Sets: Identity
Aliases: Identity

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DisplayName
Optional.
Search parameter.
Use Find-TeamsUserVoiceConfig for more search options

```yaml
Type: String
Parameter Sets: DisplayName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PhoneNumber
Optional.
Returns all Common Area Phones with a specific string in the PhoneNumber

```yaml
Type: String
Parameter Sets: Number
Aliases: Tel, Number, TelephoneNumber

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
Displays similar output as Get-TeamsUserVoiceConfig, but more tailored to Common Area Phones

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[about_VoiceConfiguration]()

[Get-TeamsCommonAreaPhone]()

[New-TeamsCommonAreaPhone]()

[Set-TeamsCommonAreaPhone]()

[Remove-TeamsCommonAreaPhone]()

[Find-TeamsUserVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

