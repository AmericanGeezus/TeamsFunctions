---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-ISO3166Country.md
schema: 2.0.0
---

# Get-ISO3166Country

## SYNOPSIS
ISO 3166 Country table.
Period.

## SYNTAX

```
Get-ISO3166Country [<CommonParameters>]
```

## DESCRIPTION
Returns the full ISO3166 Country table with Name, -alpha2, -alpha3 & NUM code.

## EXAMPLES

### EXAMPLE 1
```
Get-ISO3166Country
```

Returns the full table of Countries including TwoLetterCode (alpha2) & ThreeLetterCode (alpha3) and NumericCode (NUM)

### EXAMPLE 2
```
Get-ISO3166Country | Where-Object TwoLetterCode -eq "AW"
```

Returns entry for Country "Aruba" queried from the TwoLetterCode (ISO3166-Alpha2) AW

### EXAMPLE 3
```
(Get-ISO3166Country).TwoLetterCode
```

Returns the column TwoLetterCode (ISO3166-Alpha2) for all countries

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Void
## OUTPUTS

### System.Object
## NOTES
This CmdLet is created based on the C# definition of https://github.com/schourode/iso3166
Manually translated into PowerShell from source file https://raw.githubusercontent.com/schourode/iso3166/master/Country.cs
Dataset last queried 31 JUL 2021 (based on last update of Github repo 08 JAN 2020)
ISO3166-alpha2 is used as the Usage Location in Office 365

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-ISO3166Country.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-ISO3166Country.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

