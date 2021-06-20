---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-SkypeOnlineConnection.md
schema: 2.0.0
---

# Assert-SkypeOnlineConnection

## SYNOPSIS
Asserts an established Connection to SkypeOnline

## SYNTAX

```
Assert-SkypeOnlineConnection [<CommonParameters>]
```

## DESCRIPTION
Tests and tries to reconnect to a SkypeOnline connection already established.

## EXAMPLES

### EXAMPLE 1
```
Assert-SkypeOnlineConnection
```

Will run Test-SkypeOnlineConnection and, if successful, stops.
If unsuccessful, tries to reconnect by running Get-CsTenant to prompt for reconnection.
If that too is unsuccessful, displays request to reconnect with Connect-Me.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Void
## OUTPUTS

### System.Boolean
## NOTES
Calls Test-SkypeOnlineConnection to ascertain session.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-SkypeOnlineConnection.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-SkypeOnlineConnection.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

