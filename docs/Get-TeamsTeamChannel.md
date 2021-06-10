---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsTeamChannel

## SYNOPSIS
Returns a Channel Object from Team & Channel Names or IDs

## SYNTAX

```
Get-TeamsTeamChannel [-Team] <String> [-Channel] <String> [<CommonParameters>]
```

## DESCRIPTION
Combining lookup for Team (Get-Team) and Channel (Get-TeamChannel) into one function to return the channel object.

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsTeamChannel -Team "My Team" -Channel "CallQueue"
```

Searches for Teams with the DisplayName of "My Team".
If found, looking for a channel with the DisplayName "CallQueue"
If found, the Channel Object will be returned
Multiple Objects could be returned if multiple Teams called "My Team" with Channels called "CallQueue" exist.

### EXAMPLE 2
```
Get-TeamsTeamChannel -Team 1234abcd-1234-1234-1234abcd5678 -Channel "CallQueue"
```

Searches for Teams with the GroupId of 1234abcd-1234-1234-1234abcd5678.
If found, looking for a channel with the DisplayName "CallQueue"
If found, the Channel Object will be returned

### EXAMPLE 3
```
Get-TeamsTeamChannel -Team "My Team" -Channel 19:1234abcd567890ef1234abcd567890ef@thread.skype
```

Searches for Teams with the DisplayName of "My Team".
If found, looking for a channel with the ID "19:1234abcd567890ef1234abcd567890ef@thread.skype"
If found, the Channel Object will be returned

### EXAMPLE 4
```
Get-TeamsTeamChannel -Team 1234abcd-1234-1234-1234abcd5678 -Channel 19:1234abcd567890ef1234abcd567890ef@thread.skype
```

If a Team with the GroupId 1234abcd-1234-1234-1234abcd5678 is found and this team has a channel with the ID "19:1234abcd567890ef1234abcd567890ef@thread.skype", the Channel Object will be returned
This is the safest option as it will always find a correct result provided the entities exist.

## PARAMETERS

### -Team
Required.
Name or GroupId (Guid).
As the name might not be unique, validation is performed for unique matches.
If the input matches a 36-digit GUID, lookup is performed via GroupId, otherwise via DisplayName

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Channel
Required.
Name or Id (Guid).
If multiple Teams have been discovered, all Channels with this name in each team are returned.
If the input matches a GUID (starting with "19:"), lookup is performed via Id, otherwise via DisplayName

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
This CmdLet combines two lookups in order to find a valid channel by Name(s).
It is used to determine usability for Call Queues (Forward to Channel)

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsCallQueue]()

[New-TeamsCallQueue]()

[Get-TeamsCallQueue]()

[Set-TeamsCallQueue]()

[Assert-TeamsTeamChannel]()

[Get-TeamsTeamChannel]()

[Test-TeamsTeamChannel]()

