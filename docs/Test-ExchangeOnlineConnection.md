---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-ExchangeOnlineConnection.md
schema: 2.0.0
---

# Test-ExchangeOnlineConnection

## SYNOPSIS
Tests whether a valid PS Session exists for ExchangeOnline

## SYNTAX

```
Test-ExchangeOnlineConnection [<CommonParameters>]
```

## DESCRIPTION
A connection established via Connect-ExchangeOnline is parsed.
This connection must be valid (Available and Opened)

## EXAMPLES

### EXAMPLE 1
```
Test-ExchangeOnlineConnection
```

Will Return $TRUE only if a session is found.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### Boolean
## NOTES
Calls Get-PsSession to determine whether a Connection to ExchangeOnline exists

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-ExchangeOnlineConnection.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-ExchangeOnlineConnection.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

