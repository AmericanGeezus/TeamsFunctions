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
Determines an Objects validity for use in an Auto Attendant or Call Queue
Prepares output of Get-CsCallQueue by querying the Team and Channel (used in Get-TeamsCallQueue)
Prepares output of Get-CsAutoAttendant (nested Objects) for display (used in Get-TeamsAutoAttendant)
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

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

### EXAMPLE 6
```
Get-TeamsCallableEntity -Identity "00000000-0000-0000-0000-000000000000\19:abcdef1234567890abcdef1234567890@thread.tacv2"
```

Format provided is of in TeamId\ChannelId.
This is interpreted as a TeamsChannel.
Queries Team & Channel.
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

### EXAMPLE 7
```
Get-TeamsCallableEntity -Identity "My Team Name\My Channel Name"
```

Format provided is of in TeamDisplayName\ChannelDisplayName.
This is interpreted as a TeamsChannel.
Queries Team & Channel.
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
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
If a match for Team\Channel or PhoneNumber is found, these are treated as such.
For Team\Channel, the Id and DisplayName are interchangeable.
The first match is performed for '\', if it matches,
the string is split and individual matches are performed for Team and Channel respectively.
The PhoneNumber is found with a very flexible match based on multiple formats (Integer, E.164 or LineUri)
If no match is found, queries the string sequentially against AzureAdUser, CsOnlineApplicationInstance and AzureAdGroup.
Returns a custom Object mimiking a CallableEntity Object, returning Entity, Identity & Type

This script is used to determine the eligibility of an Object as a Callable Entity in Call Queues and Auto Attendants
This script does not yet support Announcements (sorry.
Working on it)
This script does not support the Types for legacy Hunt Group or Organisational Auto Attendant
If nothing can be found for the String, an Object is returned with the Entity being $null

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[about_TeamsAutoAttendant]()

[about_TeamsCallQueue]()

[Assert-TeamsCallableEntity]()

[Find-TeamsCallableEntity]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

[Get-TeamsCallQueue]()

[Get-TeamsAutoAttendant]()

[Get-TeamsObjectType]()

