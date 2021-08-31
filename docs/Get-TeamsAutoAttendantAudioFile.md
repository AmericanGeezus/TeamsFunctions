---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantAudioFile.md
schema: 2.0.0
---

# Get-TeamsAutoAttendantAudioFile

## SYNOPSIS
Queries Auto Attendants and displays all Audio Files found on the Object

## SYNTAX

### Name (Default)
```
Get-TeamsAutoAttendantAudioFile [[-Name] <String[]>] [-Detailed] [<CommonParameters>]
```

### Search
```
Get-TeamsAutoAttendantAudioFile [-SearchString <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Managing Audio Files for an Auto Attendant is limited in the Admin Center.
Files cannot be downloaded there.
This CmdLet tries to plug that gap by exposing Download Links for all Audio Files
linked on a given Auto Attendant

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant"
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"

### EXAMPLE 2
```
Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant" -Detailed
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant"
Detailed view will display all nested Objects indented as a tree

### EXAMPLE 3
```
Get-TeamsAutoAttendantAudioFile -Name "My AutoAttendant" -SearchString "My AutoAttendant"
```

Returns an Object for every Auto Attendant found with the exact Name "My AutoAttendant" and
Returns an Object for every Auto Attendant matching the String "My AutoAttendant"

### EXAMPLE 4
```
Get-TeamsAutoAttendantAudioFile -SearchString "My AutoAttendant"
```

Returns an Object for every Auto Attendant matching the String "My AutoAttendant"
Synonymous with Get-CsAutoAttendant -NameFilter "My AutoAttendant", but output shown differently.

## PARAMETERS

### -Name
Required for ParameterSet Name.
Finds all Auto Attendants with this name (unique results).

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
Displays all information for the nested Audio File Objects of the Auto Attendant
By default, only Names and Download URI of nested Objects are shown.

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
Managing Audio Files for an Auto Attendant is limited in the Admin Center.
Files cannot be downloaded there.
This CmdLet tries to plug that gap by exposing Download Links for all Audio Files
linked on a given Auto Attendant

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantAudioFile.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsAutoAttendantAudioFile.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

