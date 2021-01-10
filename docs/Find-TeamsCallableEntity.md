---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Find-TeamsCallableEntity

## SYNOPSIS
Finds all Call Queues where a specific User is an Agent

## SYNTAX

```
Find-TeamsCallableEntity [-Identity] <String[]> [-Scope <String>] [<CommonParameters>]
```

## DESCRIPTION
Finding all Call Queues where a User is linked as an Agent, as an OverflowActionTarget or as a TimeoutActionTarget

## EXAMPLES

### EXAMPLE 1
```
Find-TeamsCallableEntity "John@domain.com" [-Scope All]
```

Finds all Call Queues or Auto Attendants in which John is an Agent, OverflowTarget or TimeoutTarget, Menu Option, Operator, etc.

### EXAMPLE 2
```
Find-TeamsCallableEntity "MyGroup@domain.com" -Scope CallQueue
```

Finds all Call Queues in which My Group is linked as an Agent Group, OverflowTarget or TimeoutTarget

### EXAMPLE 3
```
Find-TeamsCallableEntity "tel:+15551234567" -Scope AutoAttendant
```

Finds all Auto Attendants in which the Tel URI is linked as an Operator, Menu Option, etc.

## PARAMETERS

### -Identity
Required.
Callable Entity Object to be found (Tel URI, User, Group, Resource Account)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ObjectId, UserPrincipalName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Scope
Optional.
Limits searches to Call Queues, Auto Attendants or both (All) - Currently Hardcoded to CallQueue until development finishes

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
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
Finding linked agents is useful if the Call Queues are in an unusable state.
This happens if a User is unlicensed, disabled for Enterprise Voice or disabled completely
while still being targeted as an Agent or for Overflow or Timeout.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-TeamsCallableEntity]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

[Get-TeamsObjectType]()

[Get-TeamsCallQueue]()

[Get-TeamsAutoAttendant]()

