---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
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
Get-PublicHolidayList [-Country] CA [-Year] 2022
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
Required.
Year for which the Holidays are to be listed

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
I am working on an extension to this by reading from https://www.timeanddate.com/holidays/
For Example: https://www.timeanddate.com/holidays/uk/2022?hol=9

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_TeamsAutoAttendant]()

[Get-PublicHolidayList]()

[Get-PublicHolidayCountry]()

