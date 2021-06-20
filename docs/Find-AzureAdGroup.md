---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-AzureAdGroup.md
schema: 2.0.0
---

# Find-AzureAdGroup

## SYNOPSIS
Returns an Object if an AzureAd Group has been found

## SYNTAX

```
Find-AzureAdGroup [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing

## EXAMPLES

### EXAMPLE 1
```
Find-AzureAdGroup [-Identity] "My Group"
```

Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName

### EXAMPLE 2
```
Find-AzureAdGroup -Identity "MyGroup@domain.com"
```

Will return all Groups that match "MyGroup@domain.com" in the DisplayName, ObjectId or MailNickName

## PARAMETERS

### -Identity
Mandatory.
String to search.
Provide part or full DisplayName, MailAddress or MailNickName
Returns all matching groups

```yaml
Type: String
Parameter Sets: (All)
Aliases: GroupName, Name

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Microsoft.Open.AzureAD.Model.Group
## NOTES
None

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-AzureAdGroup.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-AzureAdGroup.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

