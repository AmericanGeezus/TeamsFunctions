---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Assert-MicrosoftTeamsConnection

## SYNOPSIS

Asserts an established Connection to MicrosoftTeams

## SYNTAX

```
Assert-MicrosoftTeamsConnection [<CommonParameters>]
```

## DESCRIPTION

Tests a connection to MicrosoftTeams is established.

## EXAMPLES

### Example 1: EXAMPLE 1

```
Assert-MicrosoftTeamsConnection
```

Will run Test-MicrosoftTeamsConnection and, if successful, stops.
If unsuccessful, displays request to create a new session and stops.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Void - If called directly; On-Screen output only
### Boolean - If called by other CmdLets, On-Screen output for the first call only
## NOTES

None

## RELATED LINKS

[] (https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsSession] ()

[Assert-AzureAdConnection] ()

[Assert-MicrosoftTeamsConnection] ()

[Get-CurrentConnectionInfo] ()

