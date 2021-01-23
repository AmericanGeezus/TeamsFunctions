---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-AzureAdAssignedAdminRoles

## SYNOPSIS
Queries Admin Roles assigned to an Object

## SYNTAX

```
Get-AzureAdAssignedAdminRoles [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Azure Active Directory Admin Roles assigned to an Object
Requires a Connection to AzureAd

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdAssignedAdminRoles user@domain.com
```

Returns an Object for all Admin Roles assigned

## PARAMETERS

### -Identity
Enter the identity of the User to Query

```yaml
Type: String
Parameter Sets: (All)
Aliases: UPN, UserPrincipalName, Username

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

### PSCustomObject
## NOTES
Returns an Object containing all Admin Roles assigned to a User.
This is intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
The Output can be used as baseline for other functions (-contains "Teams Service Admin")

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Enable-AzureAdAdminRole]()

[Get-AzureAdAssignedAdminRoles]()

