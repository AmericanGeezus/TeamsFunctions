---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsCallableEntity

## SYNOPSIS
Returns a callable Entity Object from an Identity/ObjectId or string

## SYNTAX

```
Get-TeamsCallableEntity [-Identity] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Helper function to prepare a nested Object of an Auto Attendant for display
Helper function to determine an Objects validity for use in an Auto Attendant or Call Queue
Used in Get-TeamsAutoAttendant

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsCallableEntity -Identity "My Group Name"
```

Queries whether "My Group Name" can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.

### EXAMPLE 2
```
Get-TeamsCallableEntity -Identity "John@domain.com","MyResourceAccount@domain.com"
```

Queries whether John or MyResourceAccount can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.

### EXAMPLE 3
```
Get-TeamsCallableEntity -Identity 00000000-0000-0000-0000-000000000000
```

Queries whether the provided ObjectId can be found as an AzureAdUser, AzureAdGroup or CsOnlineApplicationInstance.

### EXAMPLE 4
```
Get-TeamsCallableEntity -Identity "1 (555) 1234-567"
```

No Queries performed, number is normalised into a LineURI then passed on as the Tel URI.
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

### EXAMPLE 5
```
Get-TeamsCallableEntity -Identity "tel:+15551234567"
```

No Queries performed, as the Tel URI is passed on as-is.
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

## PARAMETERS

### -Identity
The ObjectId of the CallableEntity linked

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ObjectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
Queries the provided String against AzureAdUser, AzureAdGroup and CsOnlineApplicationInstance.
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

This script does not support the Types for legacy Hunt Group or Organisational Auto Attendant
If nothing can be found for the String, an Object is returned with the Entity being $null

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-TeamsCallableEntity]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

[Get-TeamsObjectType]()

[Get-TeamsCallQueue]()

[Get-TeamsAutoAttendant]()

[Get-TeamsObjectType]()

