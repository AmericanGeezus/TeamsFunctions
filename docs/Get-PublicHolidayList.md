---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayList.md
schema: 2.0.0
---

# Get-PublicHolidayList

## SYNOPSIS
Returns a list of Public Holidays for a country for a given year

## SYNTAX

```
Get-PublicHolidayList [-CountryCode] <String> [[-Year] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Queries the Nager.Date API for public Holidays and returns a list per country and year.

## EXAMPLES

### EXAMPLE 1
```
Get-PublicHolidayList [-CountryCode] CA [-Year] 2022
```

Lists the Holidays for Canada in 2022.
The Parameters are positional, so can be omitted

## PARAMETERS

### -CountryCode
Required.
ISO3166-Alpha-2 Country Code

```yaml
Type: String
Parameter Sets: (All)
Aliases: CC

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Year
Optional.
Year for which the Holidays are to be listed.
One or more Years between 2000 and 3000
If not provided, the current year is taken.
If the current month is December, the coming year is taken.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Y

Required: False
Position: 2
Default value: 0
Accept pipeline input: True (ByValue)
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayList.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayList.md)

[about_SupportingFunction]()

[about_TeamsAutoAttendant]()

[Get-PublicHolidayList]()

[Get-PublicHolidayCountry]()

