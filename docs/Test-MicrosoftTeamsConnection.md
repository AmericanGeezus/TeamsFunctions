---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-MicrosoftTeamsConnection.md
schema: 2.0.0
---

# Test-MicrosoftTeamsConnection

## SYNOPSIS
Tests whether a valid PS Session exists for MicrosoftTeams

## SYNTAX

```
Test-MicrosoftTeamsConnection [<CommonParameters>]
```

## DESCRIPTION
A connection established via Connect-MicrosoftTeams is parsed.

## EXAMPLES

### EXAMPLE 1
```
Test-MicrosoftTeamsConnection
```

Will Return $TRUE only if a session is found.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Void
## OUTPUTS

### System.Boolean
## NOTES
Calls Get-PsSession to determine whether a Connection to MicrosoftTeams (SkypeOnline) exists

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-MicrosoftTeamsConnection.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-MicrosoftTeamsConnection.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

