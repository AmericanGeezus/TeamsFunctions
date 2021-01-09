---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsTenantVoiceConfig

## SYNOPSIS
Displays Information about available Voice Configuration in the Tenant

## SYNTAX

```
Get-TeamsTenantVoiceConfig [-DisplayUserCounters] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION
Displays all Voice relevant information configured in the Tenant incl.
counters for free Licenses and Numbers

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsTenantVoiceConfig
```

Displays Licenses for Call Plans, available Numbers, as well as
  Counters for all relevant Policies, available VoiceRoutingPolicies

### EXAMPLE 2
```
Get-TeamsTenantVoiceConfig -Detailed
```

Displays a detailed view also listing Names for DialPlans, PSTN Usages, Voice Routes and PSTN Gateways
  Also displays diagnostic parameters for troubleshooting

## PARAMETERS

### -DisplayUserCounters
Optional.
Displays information about Users enabled for Teams and for EnterpriseVoice
This extends Script execution depending on number of Users in the Tenant

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

### -Detailed
Optional.
Displays more information about Voice Routing Policies, Dial Plans, etc.

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

## OUTPUTS

## NOTES
General notes

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-TeamsUserVoiceConfig]()

[Get-TeamsTenantVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

[Remove-TeamsUserVoiceConfig]()

[Test-TeamsUserVoiceConfig]()

