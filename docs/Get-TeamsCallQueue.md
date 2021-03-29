---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsCallQueue

## SYNOPSIS
Queries Call Queues and displays friendly Names (UPN or Displayname)

## SYNTAX

```
Get-TeamsCallQueue [[-Name] <String[]>] [[-SearchString] <String>] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Same functionality as Get-CsCallQueue, but display reveals friendly Names,
like UserPrincipalName or DisplayName for the following connected Objects
  OverflowActionTarget, TimeoutActionTarget, Agents, DistributionLists and ApplicationInstances (Resource Accounts)

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsCallQueue
```

Same result as Get-CsCallQueue

### EXAMPLE 2
```
Get-TeamsCallQueue -Name "My CallQueue"
```

Returns an Object for every Call Queue found with the exact Name "My CallQueue"

### EXAMPLE 3
```
Get-TeamsCallQueue -Name "My CallQueue" -Detailed
```

Returns an Object for every Call Queue found with the String "My CallQueue"
  Displays additional Parameters used for Diagnostics & Shared Voicemail.

### EXAMPLE 4
```
Get-TeamsCallQueue -SearchString "My CallQueue"
```

Returns an Object for every Call Queue matching the String "My CallQueue"
  Synonymous with Get-CsCallQueue -NameFilter "My CallQueue", but output shown differently.

### EXAMPLE 5
```
Get-TeamsCallQueue -Name "My CallQueue" -SearchString "My CallQueue"
```

Returns an Object for every Call Queue found with the exact Name "My CallQueue" and
  Returns an Object for every Call Queue matching the String "My CallQueue"

## PARAMETERS

### -Name
Optional.
Searches all Call Queues for this name (unique results).
  If omitted, Get-TeamsCallQueue acts like an Alias to Get-CsCallQueue (no friendly names)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SearchString
Optional.
Searches all Call Queues for this string (multiple results possible).

```yaml
Type: String
Parameter Sets: (All)
Aliases: NameFilter

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detailed
Optional Switch.
Displays all Parameters of the CallQueue
This also shows parameters relating to Ids and Diagnostic Parameters.

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
Without any parameters, Get-TeamsCallQueue will show names only
Agents, DistributionLists, Targets and Resource Accounts are displayed with friendly name.
Main difference to Get-CsCallQueue (apart from the friendly names) is that the
Output view more concise

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsCallQueue]()

[New-TeamsCallQueue]()

[Get-TeamsCallQueue]()

[Set-TeamsCallQueue]()

[Remove-TeamsCallQueue]()

[Get-TeamsAutoAttendant]()

[Get-TeamsResourceAccount]()

[Get-TeamsResourceAccountAssociation]()

