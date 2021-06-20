---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsExternalDNS.md
schema: 2.0.0
---

# Test-TeamsExternalDNS

## SYNOPSIS
Tests a domain for the required external DNS records for a Teams deployment.

## SYNTAX

```
Test-TeamsExternalDNS [-Domain] <String> [<CommonParameters>]
```

## DESCRIPTION
Teams requires the use of several external DNS records for clients and federated
partners to locate services and users.
This function will look for the required external DNS records
and display their current values, if they are correctly implemented, and any issues with the records.

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsExternalDNS -Domain contoso.com
```

Example 1 will test the contoso.com domain for the required external DNS records for Teams.

## PARAMETERS

### -Domain
The domain name to test records.
This parameter is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
None

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsExternalDNS.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Test-TeamsExternalDNS.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Unmanaged.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Unmanaged.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

