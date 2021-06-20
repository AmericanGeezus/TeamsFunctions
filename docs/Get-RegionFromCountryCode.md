---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-RegionFromCountryCode.md
schema: 2.0.0
---

# Get-RegionFromCountryCode

## SYNOPSIS
Ever wondered in which Region a ZW is?

## SYNTAX

```
Get-RegionFromCountryCode [-CountryCode] <String> [-Output <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns a Global Region or Country Name for any given CountryCode

## EXAMPLES

### EXAMPLE 1
```
Get-RegionFromCountryCode -CountryCode UZ
```

Returns Region "APAC" for CountryCode UZ ("Uzbekistan")

### EXAMPLE 2
```
Get-RegionFromCountryCode AW -Output Country
```

Returns Country "Aruba" for CountryCode AW

## PARAMETERS

### -CountryCode
This is the CountryCode in the format ISO 3166-alpha2 (2-digit)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Output
Optional.
By Default the Region is returned.
With this Parameter, you can get the CountryName instead.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Region
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.String
## NOTES
CountryCode must be provided otherwise InvalidData Error will be thrown
FullyQualifiedErrorId: ParameterArgumentValidationErrorEmptyStringNotAllowed

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-RegionFromCountryCode.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-RegionFromCountryCode.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

