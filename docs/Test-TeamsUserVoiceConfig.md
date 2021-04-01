---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Test-TeamsUserVoiceConfig

## SYNOPSIS
Tests whether any Voice Configuration has been applied to one or more Users

## SYNTAX

```
Test-TeamsUserVoiceConfig [-Identity] <String[]> [-Partial] [-IncludeTenantDialPlan] [<CommonParameters>]
```

## DESCRIPTION
For Microsoft Call Plans: Tests for EnterpriseVoice enablement, License AND Phone Number
For Direct Routing: Tests for EnterpriseVoice enablement, Online Voice Routing Policy AND Phone Number

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName
```

Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if FULL configuration is found

### EXAMPLE 2
```
Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -Partial
```

Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if ANY configuration is found

### EXAMPLE 3
```
Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -IncludeTenantDialPlan
```

Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if FULL configuration is found
This requires a Tenant Dial Plan to be assigned as well.

### EXAMPLE 4
```
Test-TeamsUserVoiceConfig -UserPrincipalName $UserPrincipalName -Partial -IncludeTenantDialPlan
```

Tests a Users Voice Configuration (Direct Routing or Calling Plans) and returns TRUE if ANY configuration is found
This will treat any Object that only has a Tenant Dial Plan also as partially configured

## PARAMETERS

### -Identity
Required.
UserPrincipalName of the User to be tested

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UserPrincipalName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Partial
Optional.
By default, returns TRUE only if all required Parameters are configured (User is fully provisioned)
Using this switch, returns TRUE if some of the voice Parameters are configured (User has some or full configuration)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTenantDialPlan
Optional.
By default, only the core requirements for Voice Routing are verified.
This extends the requirements to also include the Tenant Dial Plan.
Returns FALSE if no or only a TenantDialPlan is assigned

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
All conditions require EnterpriseVoiceEnabled to be TRUE (disabled Users will always return FALSE)
Partial configuration provides insight for incorrectly provisioned configuration.
Tested Parameters for DirectRouting: EnterpriseVoiceEnabled, VoicePolicy, OnlineVoiceRoutingPolicy, OnPremLineURI
Tested Parameters for CallPlans: EnterpriseVoiceEnabled, VoicePolicy, User License (Domestic or International Calling Plan), TelephoneNumber
Tested Parameters for SkypeHybridPSTN: EnterpriseVoiceEnabled, VoicePolicy, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating)

[about_VoiceConfiguration]()

[about_UserManagement]()

[Assert-TeamsUserVoiceConfig]()

[Find-TeamsUserVoiceConfig]()

[Get-TeamsTenantVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

[Remove-TeamsUserVoiceConfig]()

[Test-TeamsUserVoiceConfig]()

