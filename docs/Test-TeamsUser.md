---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Test-TeamsUser

## SYNOPSIS
Tests whether an Object exists in Teams (record found)

## SYNTAX

```
Test-TeamsUser [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Simple lookup - does the Object exist - to avoid TRY/CATCH statements for processing

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsUser -Identity $UPN
```

Will Return $TRUE only if the object $UPN is found.
Will Return $FALSE in any other case, including if there is no Connection to MicrosoftTeams!

## PARAMETERS

### -Identity
Mandatory.
The sign-in address or User Principal Name of the user account to modify.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-AzureAdGroup]()

[Find-AzureAdUser]()

[Test-AzureAdGroup]()

[Test-AzureAdUser]()

[Test-TeamsUser]()

