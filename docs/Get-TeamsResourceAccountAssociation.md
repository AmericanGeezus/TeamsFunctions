---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsResourceAccountAssociation

## SYNOPSIS
Queries a Resource Account Association

## SYNTAX

```
Get-TeamsResourceAccountAssociation [[-Identity] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Queries an existing Resource Account and lists its Association (if any)

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsResourceAccountAssociation
```

Queries all Resource Accounts and enumerates their Association as well as the Association Status

### EXAMPLE 2
```
Get-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
```

Queries the Association of the Account 'ResourceAccount@domain.com'

## PARAMETERS

### -Identity
UPN of the Object to manipulate.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UserPrincipalName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
Combination of Get-CsOnlineApplicationInstanceAssociation and Get-CsOnlineApplicationInstanceAssociationStatus but with friendly Names
Without any Parameters, can be used to enumerate all Resource Accounts
  This may take a while to calculate, depending on # of Accounts in the Tenant

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
