---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Find-AzureAdUser

## SYNOPSIS
Returns User Objects from Azure AD based on a search string or UserPrincipalName

## SYNTAX

```
Find-AzureAdUser [-SearchString] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Simplifies lookups with Get-AzureAdUser by using and combining -SearchString and -ObjectId Parameters.
CmdLet can find uses by either query, if nothing is found with the Searchstring, another search is done via the ObjectId
This simplifies the query without having to rely multiple queries with Get-AzureAdUser

## EXAMPLES

### EXAMPLE 1
```
Find-AzureAdUser [-Search] "John"
```

Will search for the string "John" and return all Azure AD Objects found
  If nothing has been found, will try to search for by identity

### EXAMPLE 2
```
Find-AzureAdUser [-Search] "John@domain.com"
```

Will search for the string "John@domain.com" and return all Azure AD Objects found
  If nothing has been found, will try to search for by identity

### EXAMPLE 3
```
Find-AzureAdUser -Identity John@domain.com,Mary@domain.com
```

Will search for the string "John@domain.com" and return all Azure AD Objects found

## PARAMETERS

### -SearchString
Required.
A 3-255 digit string to be found on any Object.
Performs multiple searches against the Searches against this sting and parts thereof.
Uses Get-AzureAd-User -SearchString and Get-AzureAdUser -Filter and subsequently Get-AzureAdUser -ObjectType

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

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

### Microsoft.Open.AzureAD.Model.User
## NOTES

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-AzureAdGroup]()

[Get-AzureAdUser]()

