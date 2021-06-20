---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-Module.md
schema: 2.0.0
---

# Assert-Module

## SYNOPSIS
Tests whether a Module is loaded

## SYNTAX

```
Assert-Module [[-Module] <String[]>] [-UpToDate] [-PreRelease] [<CommonParameters>]
```

## DESCRIPTION
Tests whether a specific Module is loaded

## EXAMPLES

### EXAMPLE 1
```
Assert-Module -Module ModuleName
```

Will Return $TRUE if the Module 'ModuleName' is installed and loaded

### EXAMPLE 2
```
Assert-Module -Module ModuleName -UpToDate
```

Will Return $TRUE if the Module 'ModuleName' is installed in the latest release version and loaded

### EXAMPLE 3
```
Assert-Module -Module ModuleName -UpToDate -PreRelease
```

Will Return $TRUE if the Module 'ModuleName' is installed in the latest pre-release version and loaded

## PARAMETERS

### -Module
Names of one or more Modules to assert

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpToDate
Verifies Version installed is equal to the latest found online

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreRelease
Verifies Version installed is equal to the latest prerelease version found online

```yaml
Type: SwitchParameter
Parameter Sets: (All)
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

### Boolean
## NOTES
None

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-Module.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-Module.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

