---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdGroup.md
schema: 2.0.0
---

# Test-AzureAdGroup

## SYNOPSIS
Tests whether an Group exists in Azure AD (record found)

## SYNTAX

```
Test-AzureAdGroup [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Simple lookup - does the Group Object exist - to avoid TRY/CATCH statements for processing

## EXAMPLES

### EXAMPLE 1
```
Test-AzureAdGroup -Identity "My Group"
```

Will Return $TRUE only if the object "My Group" is found.
Will Return $FALSE in any other case

## PARAMETERS

### -Identity
Mandatory.
The Name or User Principal Name (MailNickName) of the Group to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName, GroupName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Boolean
## NOTES
None

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdGroup.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-AzureAdGroup.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_UserManagement]()

[Find-AzureAdGroup]()

[Find-AzureAdUser]()

[Test-AzureAdGroup]()

[Test-AzureAdUser]()

[Test-TeamsUser]()

