---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayCountry.md
schema: 2.0.0
---

# Get-PublicHolidayCountry

## SYNOPSIS
Returns a list of Countries for which Public Holidays are available

## SYNTAX

```
Get-PublicHolidayCountry [<CommonParameters>]
```

## DESCRIPTION
Queries the Nager.Date API for supported Countries

## EXAMPLES

### EXAMPLE 1
```
Get-PublicHolidayCountry
```

Lists the Countries for which Public Holidays are available

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Void
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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayCountry.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-PublicHolidayCountry.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_TeamsAutoAttendant]()

[Get-PublicHolidayCountry]()

[Get-PublicHolidayList]()

