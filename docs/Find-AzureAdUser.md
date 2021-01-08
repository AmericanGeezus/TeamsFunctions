---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Find-AzureAdUser

## SYNOPSIS
Returns User Objects from Azure AD based on a search string or UserPrincipalName

## SYNTAX

### Search (Default)
```
Find-AzureAdUser [-SearchString] <String> [<CommonParameters>]
```

### Id
```
Find-AzureAdUser [-Identity] <String[]> [<CommonParameters>]
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
Required for ParameterSet Search: A 3-255 digit string to be found on any Object.

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
Required for ParameterSet Id: The sign-in address or User Principal Name of the user account to query.

```yaml
Type: String[]
Parameter Sets: Id
Aliases: UserPrincipalName, Id

Required: True
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

### Microsoft.Open.AzureAD.Model.User
## NOTES

## RELATED LINKS
