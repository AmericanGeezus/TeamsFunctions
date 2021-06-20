---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsHolidaySchedule.md
schema: 2.0.0
---

# New-TeamsHolidaySchedule

## SYNOPSIS
Creates a Teams Schedule for each Country and Year specified

## SYNTAX

```
New-TeamsHolidaySchedule [-CountryCode] <String[]> [[-Year] <Int32[]>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Queries the Nager.Date API for public Holidays for Country and year and creates a CsOnlineSchedule object for each.

## EXAMPLES

### EXAMPLE 1
```
New-TeamsHolidaySchedule -CountryCode CA -Year 2022
```

Creates a Schedule Object in Teams for Canada for the year 2022.

### EXAMPLE 2
```
New-TeamsHolidaySchedule -CountryCode CA -Year 2022,2023,2024
```

Creates 3 Schedule Object in Teams for Canada for the years 2022 to 2024.

### EXAMPLE 3
```
New-TeamsHolidaySchedule -CountryCode CA,MX,GB,DE -Year 2022
```

Creates 4 Schedule Objects in Teams for the Canada, Mexico, Great Britain & Germany for the year 2022.

### EXAMPLE 4
```
New-TeamsHolidaySchedule -CountryCode CA,MX,GB,DE -Year 2022,2023,2024
```

Creates 12 Schedule Objects in Teams for the Canada, Mexico, Great Britain & Germany for the years 2022 to 2024.

## PARAMETERS

### -CountryCode
Required.
ISO3166-Alpha-2 Country Code.
One or more Countries from the list of Get-PublicHolidayCountry

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CC, Country

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Year
Optional.
Year for which the Holidays are to be listed.
One or more Years between 2000 and 3000
If not provided, the current year is taken.
If the current month is December, the coming year is taken.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: Y

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### System.String
## OUTPUTS

### System.Object
## NOTES
The Nager.Date API currently supports a bit over 100 Countries.
Please query with Get-PublicHolidayCountry
Evaluated the following APIs:
Nager.Date:   Decent coverage (100+ Countries).
Free & Used Coverage: https://date.nager.at/Home/RegionStatistic
TimeAndDate:  Great coverage.
Requires license.
Also a bit clunky.
Not considering implementation.
Calendarific: Great coverage.
Requires license for commercial use.
Currently not considering development
Utilising the Calendarific API could be integrated if licensed and the API key is passed/registered locally.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsHolidaySchedule.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsHolidaySchedule.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_TeamsAutoAttendant]()

[New-TeamsHolidaySchedule]()

[Get-PublicHolidayList]()

[Get-PublicHolidayCountry]()

