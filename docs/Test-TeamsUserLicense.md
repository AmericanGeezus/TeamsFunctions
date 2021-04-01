---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Test-TeamsUserLicense

## SYNOPSIS
Tests a License or License Package assignment against an AzureAD-Object

## SYNTAX

### ServicePlan (Default)
```
Test-TeamsUserLicense [-Identity] <String> -ServicePlan <String> [<CommonParameters>]
```

### License
```
Test-TeamsUserLicense [-Identity] <String> -License <String> [<CommonParameters>]
```

## DESCRIPTION
Teams requires a specific License combination (License) for a User.
Teams Direct Routing requires a specific License (ServicePlan), namely 'Phone System'
to enable a User for Enterprise Voice
This Script can be used to ascertain either.

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsUserLicense -Identity User@domain.com -ServicePlan MCOEV
```

Will Return $TRUE only if the ServicePlan is assigned and ProvisioningStatus is SUCCESS!
This can be a part of a License.

### EXAMPLE 2
```
Test-TeamsUserLicense -Identity User@domain.com -License Microsoft365E5
```

Will Return $TRUE only if the license Package is assigned.
Specific Names have been assigned to these Licenses

## PARAMETERS

### -Identity
Mandatory.
The sign-in address or User Principal Name of the user account to modify.

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ServicePlan
Defined and descriptive Name of the Service Plan to test.
Only ServicePlanNames pertaining to Teams are tested.
Returns $TRUE only if the ServicePlanName was found and the ProvisioningStatus is "Success" at least once.
ServicePlans can be part of multiple licenses, for Example MCOEV (PhoneSystem) is part of any E5 license.
For Testing against a full License Package, please use Parameter License

```yaml
Type: String
Parameter Sets: ServicePlan
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -License
Defined and descriptive Name of the License Combination to test.
This will test whether one more more individual Service Plans are present on the Identity

```yaml
Type: String
Parameter Sets: License
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Boolean
## NOTES
This Script is indiscriminate against the User Type, all AzureAD User Objects can be tested.
ServicePlans can be part of multiple licenses, for Example MCOEV (PhoneSystem) is part of any E5 license.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[Get-TeamsTenantLicense]()

[Get-TeamsUserLicense]()

[Get-TeamsUserLicenseServicePlan]()

[Set-TeamsUserLicense]()

