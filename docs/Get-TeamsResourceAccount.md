---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsResourceAccount

## SYNOPSIS
Returns Resource Accounts from AzureAD

## SYNTAX

### Identity (Default)
```
Get-TeamsResourceAccount [[-UserPrincipalName] <String[]>] [<CommonParameters>]
```

### DisplayName
```
Get-TeamsResourceAccount [-DisplayName <String>] [<CommonParameters>]
```

### AppType
```
Get-TeamsResourceAccount [-ApplicationType <String>] [<CommonParameters>]
```

### Number
```
Get-TeamsResourceAccount [-PhoneNumber <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns one or more Resource Accounts based on input.
This runs Get-CsOnlineApplicationInstance but reformats the Output with friendly names

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsResourceAccount
```

Returns all Resource Accounts.
NOTE: Depending on size of the Tenant, this might take a while.

### EXAMPLE 2
```
Get-TeamsResourceAccount -Identity ResourceAccount@TenantName.onmicrosoft.com
```

Returns the Resource Account with the Identity specified, if found.

### EXAMPLE 3
```
Get-TeamsResourceAccount -DisplayName "Queue"
```

Returns all Resource Accounts with "Queue" as part of their Display Name.
Use Find-TeamsResourceAccount / Find-CsOnlineApplicationInstance for finer search

### EXAMPLE 4
```
Get-TeamsResourceAccount -ApplicationType AutoAttendant
```

Returns all Resource Accounts of the specified ApplicationType.

### EXAMPLE 5
```
Get-TeamsResourceAccount -PhoneNumber +1555123456
```

Returns the Resource Account with the Phone Number specified, if found.

## PARAMETERS

### -UserPrincipalName
User Principal Name of the Object.

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
Alternative to Find-TeamsResourceAccount
Use Find-TeamsUserVoiceConfig for more search options

```yaml
Type: String
Parameter Sets: DisplayName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ApplicationType
Optional.
Returns all Call Queues or AutoAttendants

```yaml
Type: String
Parameter Sets: AppType
Aliases: Type

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PhoneNumber
Optional.
Returns all ResourceAccount with a specific string in the PhoneNumber

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
Pipeline input possible, though untested.
Requires figuring out :)

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsResourceAccountAssociation]()

[New-TeamsResourceAccountAssociation]()

[Remove-TeamsResourceAccountAssociation]()

[New-TeamsResourceAccount]()

[Get-TeamsResourceAccount]()

[Find-TeamsResourceAccount]()

[Set-TeamsResourceAccount]()

[Remove-TeamsResourceAccount]()

