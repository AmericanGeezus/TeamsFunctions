---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendant.md
schema: 2.0.0
---

# Get-TeamsAutoAttendant

## SYNOPSIS
Queries Auto Attendants and displays friendly Names (UPN or DisplayName)

## SYNTAX

### Name (Default)
```
Get-TeamsAutoAttendant [[-Name] <String[]>] [-Detailed] [<CommonParameters>]
```

### Search
```
Get-TeamsAutoAttendant [-SearchString <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Same functionality as Get-CsAutoAttendant, but display reveals friendly Names,
like UserPrincipalName or DisplayName for the following connected Objects
Operator and ApplicationInstances (Resource Accounts)

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsAutoAttendant
```

Same result as Get-CsAutoAttendant

### EXAMPLE 2
```
Get-TeamsAutoAttendant -Name "My AutoAttendant"
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"

### EXAMPLE 3
```
Get-TeamsAutoAttendant -Name "My AutoAttendant" -Detailed
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
Detailed view will display all nested Objects indented as a tree

### EXAMPLE 4
```
Get-TeamsAutoAttendant -Name "My AutoAttendant" -SearchString "My AutoAttendant"
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant" and
Returns an Object for every Auto Attendant matching the String "My AutoAttendant"

### EXAMPLE 5
```
Get-TeamsAutoAttendant -SearchString "My AutoAttendant"
```

Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
Synonymous with Get-CsAutoAttendant -NameFilter "My AutoAttendant", but output shown differently.

## PARAMETERS

### -Name
Required for ParameterSet Name.
Finds all Auto Attendants with this name (unique results).
If not provided, all Auto Attendants are queried, returning only the name

```yaml
Type: String[]
Parameter Sets: Name
Aliases: Identity

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SearchString
Required for ParameterSet Search.
Searches all Auto Attendants for this string (multiple results possible).

```yaml
Type: String
Parameter Sets: Search
Aliases: NameFilter

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detailed
Optional Switch.
Displays nested Objects for all Parameters of the Auto Attendant
By default, only Names of nested Objects are shown.

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

### System.Object
## NOTES
Without any parameters, Get-TeamsAutoAttendant will show names only.
Operator and Resource Accounts, etc.
are displayed with friendly name.
Main difference to Get-CsAutoAttendant (apart from the friendly names) is how the Objects are shown.
The connected Objects DefaultCallFlow, CallFlows, Schedules, CallHandlingAssociations and DirectoryLookups
are all shown with Name only, but can be queried with .\<ObjectName\>
This also works with Get-CsAutoAttendant, but with the help of "Display" Parameters.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

