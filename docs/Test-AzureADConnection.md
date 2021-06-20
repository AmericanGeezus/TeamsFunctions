---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdConnection.md
schema: 2.0.0
---

# Test-AzureADConnection

## SYNOPSIS
Tests whether a valid PS Session exists for Azure Active Directory (v2)

## SYNTAX

```
Test-AzureADConnection [<CommonParameters>]
```

## DESCRIPTION
A connection established via Connect-AzureAD is parsed.

## EXAMPLES

### EXAMPLE 1
```
Test-AzureADConnection
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
Calls Get-AzureADCurrentSessionInfo to determine whether a Connection exists

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdConnection.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdConnection.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

