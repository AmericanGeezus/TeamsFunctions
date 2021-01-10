---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsObjectType

## SYNOPSIS
Resolves the type of the object

## SYNTAX

```
Get-TeamsObjectType [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Helper function to find the Callable Entity Type of Teams Objects
Returns ObjectType: User (AzureAdUser), Group (AzureAdGroup), ResourceAccount (ApplicationInstance) or TelURI String (ExternalPstn)

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsObjectType -Identity John@domain.com -Type User
```

Creates a callable Entity for the User John@domain.com

### EXAMPLE 2
```
Get-TeamsObjectType -Identity "John@domain.com"
```

Returns "User" as the type of Entity if an AzureAdUser with the UPN "John@domain.com" is found

### EXAMPLE 3
```
Get-TeamsObjectType -Identity "Accounting"
```

Returns "Group" as the type of Entity if a AzureAdGroup with the Name "Accounting" is found.

### EXAMPLE 4
```
Get-TeamsObjectType -Identity "Accounting@domain.com"
```

Returns "Group" as the type of Entity if a AzureAdGroup with the Mailnickname "Accounting@domain.com" is found.

### EXAMPLE 5
```
Get-TeamsObjectType -Identity "ResourceAccount@domain.com"
```

Returns "ResourceAccount" as the type of Entity if a CsOnlineApplicationInstance with the UPN "ResourceAccount@domain.com" is found

### EXAMPLE 6
```
Get-TeamsObjectType -Identity "tel:+1555123456"
```

Returns "TelURI" as the type of Entity

### EXAMPLE 7
```
Get-TeamsObjectType -Identity "+1555123456"
```

Returns an Error as the type of Entity cannot be determined correctly

## PARAMETERS

### -Identity
Required.
String for the TelURI, Group Name or Mailnickname, UserPrincipalName, depending on the Entity Type

```yaml
Type: String
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

### System.String
## NOTES

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsCallableEntity]()

