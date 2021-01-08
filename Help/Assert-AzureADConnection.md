---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Assert-AzureADConnection

## SYNOPSIS
Asserts an established Connection to AzureAD

## SYNTAX

```
Assert-AzureADConnection [<CommonParameters>]
```

## DESCRIPTION
Tests a connection to SkypeOnline is established.

## EXAMPLES

### EXAMPLE 1
```
Assert-AzureADConnection
```

Will run Test-AzureADConnection and, if successful, stops.
  If unsuccessful, displays request to create a new session and stops.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS
