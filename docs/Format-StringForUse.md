---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Format-StringForUse

## SYNOPSIS
Formats a string by removing special characters usually not allowed.

## SYNTAX

### Manual (Default)
```
Format-StringForUse [-InputString] <String> [-Replacement <String>] [-SpecialChars <String>]
 [<CommonParameters>]
```

### Specific
```
Format-StringForUse [-InputString] <String> [-Replacement <String>] [-As <String>] [<CommonParameters>]
```

## DESCRIPTION
Special Characters in strings usually lead to terminating errors.
This function gets around that by formating the string properly.
Use is limited, but can be used for UPNs and Display Names
Adheres to Microsoft recommendation of special Characters

## EXAMPLES

### EXAMPLE 1
```
\Test(String)"
```

Returns "\<my\>\TestString".
All SpecialChars defined will be removed.

### EXAMPLE 2
```
\Test(String)" -SpecialChars "\"
```

Returns "myTest(String)".
All SpecialChars defined will be removed.

### EXAMPLE 3
```
\Test(String)" -As UserPrincipalName
```

Returns "myTestString" for UserPrincipalName does not support any of the special characters

### EXAMPLE 4
```
\Test(String)" -As DisplayName
```

Returns "myTest(String)" for DisplayName does not support some special characters

### EXAMPLE 5
```
Format-StringForUse  -InputString "1 (555) 1234-567" -As E164
```

Returns "+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "+"

### EXAMPLE 6
```
Format-StringForUse  -InputString "1 (555) 1234-567" -As LineURI
```

Returns "tel:+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "tel:+"

## PARAMETERS

### -InputString
Mandatory.
The string to be reformatted

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

### -Replacement
Optional String.
Manually replaces removed characters with this string.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -As
Optional String.
DisplayName or UserPrincipalName.
Uses predefined special characters to remove
Cannot be used together with -SpecialChars

```yaml
Type: String
Parameter Sets: Specific
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SpecialChars
Default, Optional String.
Manually define which special characters to remove.
If not specified, only the following characters are removed: ?()\[\]{}
Cannot be used together with -As

```yaml
Type: String
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: ?()[]{}
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

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Format-StringRemoveSpecialCharacter]()

