---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Find-AzureAdGroup

## SYNOPSIS
Returns an Object if an AzureAd Group has been found

## SYNTAX

### Search (Default)
```
Find-AzureAdGroup [-Identity] <String> [-Search] [<CommonParameters>]
```

### Exact
```
Find-AzureAdGroup [-Identity] <String> [-Exact] [<CommonParameters>]
```

### All
```
Find-AzureAdGroup [-Identity] <String> [-All] [<CommonParameters>]
```

## DESCRIPTION
Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing

## EXAMPLES

### EXAMPLE 1
```
Find-AzureAdGroup -Identity "My Group"
```

Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName

### EXAMPLE 2
```
Find-AzureAdGroup -Identity "My Group" -Search
```

Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName

### EXAMPLE 3
```
Find-AzureAdGroup -Identity "My Group" -Exact
```

Will return ONE Group that has "My Group" set as the DisplayName

### EXAMPLE 4
```
Find-AzureAdGroup -Identity $UPN -All
```

Parses the whole Tenant for Groups, which may take some time, but yield complete results.
  Will return all Groups that have "My Group" in the DisplayName, ObjectId or MailNickName

## PARAMETERS

### -Identity
Mandatory.
String to search.
Depending on Search method, provide Full Name (exact),
Part of the Name (Search, default; All) or even the UserPrincipalName (MailNickName) to find the Group.

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

### -Exact
Optional.
Utilises SearchString for DisplayName and MailNickname
Queries ObjectId and Mail in case no result has been found for the provided string.
Returns only exact matches

```yaml
Type: SwitchParameter
Parameter Sets: Exact
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
Optional (default).
Utilises SearchString for DisplayName and MailNickname
Queries ObjectId and Mail in case no result has been found for the provided string.
Returns all Objects that have the string in the Name.

```yaml
Type: SwitchParameter
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Optional.
Loads all Groups on the tenant to find groups matching the provided string.
Queries Displayname, Description, ObjectId and MailNickname
This will take some time, depending on the size of the Tenant.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-AzureAdGroup]()

[Find-AzureAdUser]()

[Test-AzureAdGroup]()

[Test-AzureAdUser]()

[Test-TeamsUser]()

