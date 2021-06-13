---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-MyAzureAdAdminRole

## SYNOPSIS
Queries Admin Roles assigned to the currently connected User

## SYNTAX

```
Get-MyAzureAdAdminRole [[-Type] <String>] [<CommonParameters>]
```

## DESCRIPTION
Azure Active Directory Admin Roles assigned to the currently connected User
Requires a Connection to AzureAd
Querying '-Type Elibile' requires the Module AzureAdPreview installed

## EXAMPLES

### EXAMPLE 1
```
Get-AzureAdAdminRole [-Type Active]
```

Returns all active Admin Roles for the currently connected User

### EXAMPLE 2
```
Get-AzureAdAdminRole -Type Eligible
```

Returns all eligible Admin Roles for the currently connected User

## PARAMETERS

### -Type
Optional.
Switches query to Active (Default) or Eligible Admin Roles
Eligibility can only be queried with Module AzureAdPreview installed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### PSCustomObject
## NOTES
This is a wrapper for Get-AzureAdAdminRole targeting the currently connected User

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[Enable-AzureAdAdminRole]()

[Enable-MyAzureAdAdminRole]()

[Get-AzureAdAdminRole]()

[Get-MyAzureAdAdminRole]()

