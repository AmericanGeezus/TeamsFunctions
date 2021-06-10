---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-AzureAdAdminRole

## SYNOPSIS
Queries Admin Roles assigned to an Object

## SYNTAX

```
Get-AzureAdAdminRole [-Identity] <String> [-Type <String>] [<CommonParameters>]
```

## DESCRIPTION
Azure Active Directory Admin Roles assigned to an Object
Requires a Connection to AzureAd
Querying '-Type Elibile' requires the Module AzureAdPreview installed

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdAdminRole [-Identity] user@domain.com [-Type Active]
```

Returns all active Admin Roles for the provided Identity

### EXAMPLE 2
```
Get-AzureAdAdminRole [-Identity] user@domain.com -Type Eligible
```

Returns all eligible Admin Roles for the provided Identity

## PARAMETERS

### -Identity
Required.
One or more UserPrincipalNames of the Office365 Administrator

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName, ObjectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
Optional.
Switches query to Active (Default) or Eligible Admin Roles
Eligibility can only be queried with Module AzureAdPreview installed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Active
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
Returns an Object containing all Admin Roles assigned to a User.
This is intended as an informational for the User currently connected to a specific PS session (whoami and whatcanido)
The Output can be used as baseline for other functions (-contains "Teams Service Admin")

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[Enable-AzureAdAdminRole]()

[Enable-MyAzureAdAdminRole]()

[Get-AzureAdAdminRole]()

[Get-MyAzureAdAdminRole]()

