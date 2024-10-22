---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantSchedule.md
schema: 2.0.0
---

# New-TeamsAutoAttendantSchedule

## SYNOPSIS
Creates a Schedule to be used in Auto Attendants

## SYNTAX

### WeeklyBusinessHours (Default)
```
New-TeamsAutoAttendantSchedule -Name <String> [-WeeklyRecurrentSchedule] -BusinessDays <String>
 -BusinessHours <String> [-Complement] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### WeeklyTimeRange
```
New-TeamsAutoAttendantSchedule -Name <String> [-WeeklyRecurrentSchedule] -BusinessDays <String>
 -DateTimeRanges <Object[]> [-Complement] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### WeeklyBusinessHours2
```
New-TeamsAutoAttendantSchedule -Name <String> [-WeeklyRecurrentSchedule] -BusinessDays <String>
 -BusinessHoursStart <String> [-BusinessHoursEnd <String>] [-Complement] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### FixedTimeRange
```
New-TeamsAutoAttendantSchedule -Name <String> [-Fixed] -DateTimeRanges <Object[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Wrapper for New-CsOnlineSchedule to simplify creation of Schedules with repeating patterns
Incorporates New-CsOnlineTimeRange with examples

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays MonToFri -BusinesHours 9to5
```

Creates a weekly recurring schedule for business hours Monday to Friday from 9am to 5pm

### EXAMPLE 2
```
New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays MonToSat -BusinessHoursStart 09:15 -BusinessHoursEnd 17:45
```

Creates a weekly recurring schedule for business hours Monday to Saturday from 09:15 to 17:45

### EXAMPLE 3
```
New-TeamsAutoAttendantSchedule -WeeklyRecurrentSchedule -BusinessDays SunToThu -DateTimeRange @($TR1, $TR2)
```

Creates a weekly recurring schedule for business hours Sunday to Thursday with custom TimeRange(s) provided with the Objects $TR1 and $TR2

### EXAMPLE 4
```
New-TeamsAutoAttendantSchedule -Fixed -DateTimeRange @($TR1, $TR2)
```

Adds a fixed schedule for the TimeRange(s) provided with the Objects $TR1 and $TR2

## PARAMETERS

### -Name
Provides a friendly Name to the Schedule (visible in the Auto Attendant Object)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WeeklyRecurrentSchedule
Defines a schedule that is recurring weekly with Business Hours for every day of the week.
This is suitable for an After Hours in an Auto Attendant.
New-TeamsAutoAttendant will utilise a Default Schedule
For simplicity, this command assumes the same hours of operation for each day that the business is open.
For a more granular approach, aim for a "best match", then amend the schedule afterwards in the Admin Center
If desired via PowerShell, please use BusinessHoursStart/BusinessHoursEnd or define manually with:
New-CsOnlineTimeRange and New-CsOnlineSchedule respectively.

```yaml
Type: SwitchParameter
Parameter Sets: WeeklyBusinessHours, WeeklyTimeRange, WeeklyBusinessHours2
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fixed
Defines a fixed schedule, suitable for Holiday Sets

```yaml
Type: SwitchParameter
Parameter Sets: FixedTimeRange
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessDays
Parameter for WeeklyReccurrentSchedule
Days defined as Business days.
Will be combined with BusinessHours to form a WeeklyReccurrentSchedule

```yaml
Type: String
Parameter Sets: WeeklyBusinessHours, WeeklyTimeRange, WeeklyBusinessHours2
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHours
Parameter for WeeklyReccurrentSchedule - Option 1: Choose from a predefined Time Frame
Predefined business hours.
Combined with BusinessDays, forms the WeeklyRecurrentSchedule
Covering most of regular working hour patterns to choose from.

```yaml
Type: String
Parameter Sets: WeeklyBusinessHours
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursStart
Parameter for WeeklyReccurrentSchedule - Option 2: Select a specific Start and End Time
Predefined business hours.
Combined with BusinessDays, forms the WeeklyRecurrentSchedule
Manual start and end time to be provided in 15 minute increments only, leading 0 can be omitted: "9:00 AM" or "08:45"

```yaml
Type: String
Parameter Sets: WeeklyBusinessHours2
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessHoursEnd
Parameter for WeeklyReccurrentSchedule - Option 2: Select a specific Start and End Time
Predefined business hours.
Combined with BusinessDays, forms the WeeklyRecurrentSchedule
Manual start and end time to be provided in 15 minute increments only, leading 0 can be omitted: "5:15 PM" or "17:30"

```yaml
Type: String
Parameter Sets: WeeklyBusinessHours2
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTimeRanges
Parameter for WeeklyReccurrentSchedule - Option 3: Provide a DateTimeRange Object
Object or Objects defined with New-CsOnlineTimeRange
Allows for more granular options then the provided BusinessHours examples or to provide Dates for Fixed

```yaml
Type: Object[]
Parameter Sets: WeeklyTimeRange, FixedTimeRange
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Complement
The Complement parameter indicates how the schedule is used.
When Complement is enabled, the schedule is used as the inverse of the provided configuration
For example, if Complement is enabled and the schedule only contains time ranges of Monday to Friday from 9AM to 5PM,
then the schedule is active at all times other than the specified time ranges.

```yaml
Type: SwitchParameter
Parameter Sets: WeeklyBusinessHours, WeeklyTimeRange, WeeklyBusinessHours2
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String, System.Object
## OUTPUTS

### System.Object
## NOTES
Combinations of BusinesHours and BusinessDays are numerous but not exhaustive.
For simplicity, this command assumes the same hours of operation for each day that the business is open.
With the following Parameters, these three options are available:
1.
BusinessHours - Choose time range from a predefined list (amend in Admin Center afterwards, if needed)
2.
BusinessHoursStart and BusinessHoursEnd - Provide a Start and End Time for the Time Range (15 minute increments)
3.
DateTimeRange - Provide a DateTimeRange Object manually defined with New-CsOnlineTimeRange and New-CsOnlineSchedule

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantSchedule.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsAutoAttendantSchedule.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

