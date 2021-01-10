---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Test-TeamsUserHasCallPlan

## SYNOPSIS
Tests an AzureAD-Object for a CallingPlan License

## SYNTAX

```
Test-TeamsUserHasCallPlan [-Identity] <String> [<CommonParameters>]
```

## DESCRIPTION
Any assigned Calling Plan found on the User (with exception of the Communication Credits license, which is add-on)
will let this function return $TRUE

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsUserHasCallPlan -Identity User@domain.com -ServicePlan MCOEV
```

Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
This can be a part of a License.

### EXAMPLE 2
```
Test-TeamsUserHasCallPlan -Identity User@domain.com
```

Will Return $TRUE only if one of the following license Packages are assigned:
  InternationalCallingPlan, DomesticCallingPlan, DomesticCallingPlan120, DomesticCallingPlan120b

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
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES
This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Test-TeamsUserLicense]()

