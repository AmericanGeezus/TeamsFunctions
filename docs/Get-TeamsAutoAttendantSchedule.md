---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantSchedule.md
schema: 2.0.0
---

# Get-TeamsAutoAttendantSchedule

## SYNOPSIS
Returns Teams Schedule Objects by Id or Name and/or Association

## SYNTAX

### Identity
```
Get-TeamsAutoAttendantSchedule [-Id <String>] [-ParseAutoAttendants] [<CommonParameters>]
```

### UnAssociatedOnly
```
Get-TeamsAutoAttendantSchedule [-Name <String>] [-UnAssociatedOnly] [<CommonParameters>]
```

### AssociatedOnly
```
Get-TeamsAutoAttendantSchedule [-Name <String>] [-AssociatedOnly] [-ParseAutoAttendants] [<CommonParameters>]
```

### Search
```
Get-TeamsAutoAttendantSchedule -Name <String> [-ParseAutoAttendants] [<CommonParameters>]
```

## DESCRIPTION
Queries the Nager.Date API for public Holidays for Country and year and creates a CsOnlineSchedule object for each.

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsAutoAttendantSchedule -Id abcd1234-5678-efg9-0123-4567890abcd
```

Returns the Schedules with the Id  abcd1234-5678-efg9-0123-4567890abcd - Same behaviour as Get-CsOnlineSchedule

### EXAMPLE 2
```
Get-TeamsAutoAttendantSchedule -Name "CAN","MEX"
```

Returns all Schedules with "CAN" or "MEX" in the Name

### EXAMPLE 3
```
Get-TeamsAutoAttendantSchedule -Name "Canada 202*"
```

Returns all Schedules with the String "Canada 202" in the name (like)

### EXAMPLE 4
```
Get-TeamsAutoAttendantSchedule -Name "Canada 202*" -UnassociatedOnly
```

Returns all Schedules with the String "Canada 202" in the name (like) that are not associated to any Auto Attendant Call Flow

### EXAMPLE 5
```
Get-TeamsAutoAttendantSchedule -Name "Canada 202*" -AssociatedOnly
```

Returns all Schedules with the String "Canada 202" in the name (like) that are associated to any Auto Attendant Call Flow

### EXAMPLE 6
```
Get-TeamsAutoAttendantSchedule -UnassociatedOnly
```

Returns all Schedules that are not associated to any Auto Attendant Call Flow

## PARAMETERS

### -Id
Id of the Schedule Object

```yaml
Type: String
Parameter Sets: Identity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
String to search for (partial or full match)

```yaml
Type: String
Parameter Sets: UnAssociatedOnly, AssociatedOnly
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Search
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AssociatedOnly
Optional.
Considers only associated Schedules

```yaml
Type: SwitchParameter
Parameter Sets: AssociatedOnly
Aliases: Assigned, InUse

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnAssociatedOnly
Optional.
Considers only unassociated Schedules

```yaml
Type: SwitchParameter
Parameter Sets: UnAssociatedOnly
Aliases: Unassigned, Free

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParseAutoAttendants
Optional.
Resolves Auto Attendant Names

```yaml
Type: SwitchParameter
Parameter Sets: Identity, AssociatedOnly, Search
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

### System.String
## OUTPUTS

### System.Object
## NOTES
Schedule Object can be queried by Name or Id (partent CmdLet).
Additionally filtered by Association

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantSchedule.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantSchedule.md)

[about_SupportingFunction]()

[about_TeamsAutoAttendant]()

[Get-TeamsAutoAttendantSchedule]()

[New-TeamsAutoAttendantSchedule]()

[New-TeamsHolidaySchedule]()

[New-TeamsAutoAttendant]()

[Set-TeamsAutoAttendant]()

[Get-PublicHolidayList]()

[Get-PublicHolidayCountry]()

