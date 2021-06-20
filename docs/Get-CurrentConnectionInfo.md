---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-CurrentConnectionInfo.md
schema: 2.0.0
---

# Get-CurrentConnectionInfo

## SYNOPSIS
Queries AzureAd, MicrosoftTeams and ExchangeOnline for currently established Sessions

## SYNTAX

```
Get-CurrentConnectionInfo [<CommonParameters>]
```

## DESCRIPTION
Returns an object displaying all currently connected PowerShell Sessions and basic output about the Tenant.

## EXAMPLES

### EXAMPLE 1
```
Get-CurrentConnectionInfo
```

Will Test current connection to AzureAd, MicrosoftTeams and ExchangeOnline and displays simple output object.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES
Information about a Service is only displayed if an active connection can be found

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-CurrentConnectionInfo.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-CurrentConnectionInfo.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

