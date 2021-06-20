---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsResourceAccount.md
schema: 2.0.0
---

# Find-TeamsResourceAccount

## SYNOPSIS
Finds Resource Accounts from AzureAD

## SYNTAX

### Search (Default)
```
Find-TeamsResourceAccount [-SearchQuery] <String> [<CommonParameters>]
```

### UnAssociatedOnly
```
Find-TeamsResourceAccount [-SearchQuery] <String> [-UnAssociatedOnly] [<CommonParameters>]
```

### AssociatedOnly
```
Find-TeamsResourceAccount [-SearchQuery] <String> [-AssociatedOnly] [<CommonParameters>]
```

## DESCRIPTION
Returns Resource Accounts based on input (Search String).
This runs Find-CsOnlineApplicationInstance but reformats the Output with friendly names

## EXAMPLES

### EXAMPLE 1
```
Find-TeamsResourceAccount -SearchQuery "Office"
```

Returns all Resource Accounts with "Office" as part of their DisplayName

### EXAMPLE 2
```
Find-TeamsResourceAccount -SearchQuery "Office" -AssociatedOnly
```

Returns all associated Resource Accounts with "Office" as part of their DisplayName

### EXAMPLE 3
```
Find-TeamsResourceAccount -SearchQuery "Office" -UnAssociatedOnly
```

Returns all unassociated Resource Accounts with "Office" as part of their DisplayName

## PARAMETERS

### -SearchQuery
Required.
Positional.
Part of the DisplayName of the Account.

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

### -AssociatedOnly
Optional.
Considers only associated Resource Accounts

```yaml
Type: SwitchParameter
Parameter Sets: AssociatedOnly
Aliases: Assigned, InUse

Required: True
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnAssociatedOnly
Optional.
Considers only unassociated Resource Accounts

```yaml
Type: SwitchParameter
Parameter Sets: UnAssociatedOnly
Aliases: Unassigned, Free

Required: True
Position: 2
Default value: False
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsResourceAccount.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsResourceAccount.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsResourceAccount.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

