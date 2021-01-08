---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Test-TeamsUserVoiceConfig

## SYNOPSIS
Tests whether any Voice Configuration has been applied to one or more Users

## SYNTAX

```
Test-TeamsUserVoiceConfig [-Identity] <String[]> -Scope <String> [-Partial] [<CommonParameters>]
```

## DESCRIPTION
For Microsoft Call Plans: Tests for EnterpriseVoice enablement, License AND Phone Number
For Direct Routing: Tests for EnterpriseVoice enablement, Online Voice Routing Policy AND Phone Number

## EXAMPLES

### EXAMPLE 1
```
Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope DirectRouting
```

Tests for Direct Routing and returns TRUE if FULL configuration is found

### EXAMPLE 2
```
Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope DirectRouting -Partial
```

Tests for Direct Routing and returns TRUE if ANY configuration is found

### EXAMPLE 3
```
Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope CallPlans
```

Tests for Call Plans and returns TRUE if FULL configuration is found

### EXAMPLE 4
```
Test-TeamsUserVoiceConfig -Identity $UserPrincipalName -Scope CallPlans -Partial
```

Tests for Call Plans but returns TRUE if ANY configuration is found

## PARAMETERS

### -Identity
Required.
UserPrincipalName of the User to be tested

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Scope
Required.
Value to focus the Script on.
Allowed Values are DirectRouting,CallingPlans,SkypeHybridPSTN
Tested Parameters for DirectRouting: EnterpriseVoiceEnabled, VoicePolicy, OnlineVoiceRoutingPolicy, OnPremLineURI
Tested Parameters for CallPlans: EnterpriseVoiceEnabled, VoicePolicy, User License (Domestic or International Calling Plan), TelephoneNumber
Tested Parameters for SkypeHybridPSTN: EnterpriseVoiceEnabled, VoicePolicy, VoiceRoutingPolicy, OnlineVoiceRoutingPolicy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Partial
Optional.
By default, returns TRUE only if all required Parameters for the Scope are configured (User is fully provisioned)
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Boolean
## NOTES
All conditions require EnterpriseVoiceEnabled to be TRUE (disabled Users will always return FALSE)
Partial configuration provides insight for incorrectly de-provisioned configuration that could block configuration for the other.
For Example: Set-CsUser -Identity $UserPrincipalName -OnPremLineURI
  This will fail if a Domestic Call Plan is assigned OR a TelephoneNumber is remaining assigned to the Object.
  "Remove-TeamsUserVoiceConfig -Force" can help

## RELATED LINKS

[Find-TeamsUserVoiceConfig
Get-TeamsTenantVoiceConfig
Get-TeamsUserVoiceConfig
Set-TeamsUserVoiceConfig
Remove-TeamsUserVoiceConfig
Test-TeamsUserVoiceConfig]()

