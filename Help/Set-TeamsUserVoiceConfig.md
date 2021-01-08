---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Set-TeamsUserVoiceConfig

## SYNOPSIS
Enables a User to consume Voice services in Teams (Pstn breakout)

## SYNTAX

### DirectRouting (Default)
```
Set-TeamsUserVoiceConfig [-Identity] <String> [-DirectRouting] -OnlineVoiceRoutingPolicy <String>
 [-TenantDialPlan <String>] -PhoneNumber <String> [-Force] [-PassThru] [-WriteErrorLog] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### CallingPlans
```
Set-TeamsUserVoiceConfig [-Identity] <String> [-TenantDialPlan <String>] -PhoneNumber <String> [-CallingPlan]
 [-CallingPlanLicense <String[]>] [-Force] [-PassThru] [-WriteErrorLog] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Enables a User for Direct Routing, Microsoft Callings or for use in Call Queues (EvOnly)
User requires a Phone System License in any case.

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsUserVoiceConfig -Identity John@domain.com -CallingPlans -PhoneNumber "+15551234567" -CallingPlanLicense DomesticCallingPlan
```

Provisions John@domain.com for Calling Plans with the Calling Plan License and Phone Number provided

### EXAMPLE 2
```
Set-TeamsUserVoiceConfig -Identity John@domain.com -CallingPlans -PhoneNumber "+15551234567" -WriteErrorLog
```

Provisions John@domain.com for Calling Plans with the Phone Number provided (requires Calling Plan License to be assigned already)
  If Errors are encountered, they are written to C:\Temp as well as on screen

### EXAMPLE 3
```
Set-TeamsUserVoiceConfig -Identity John@domain.com -DirectRouting -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
```

Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided

### EXAMPLE 4
```
Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER" -TenantDialPlan "DP-US"
```

Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy, Tenant Dial Plan and Phone Number provided

### EXAMPLE 5
```
Set-TeamsUserVoiceConfig -Identity John@domain.com -PhoneNumber "+15551234567" -OnlineVoiceRoutingPolicy "O_VP_AMER"
```

Provisions John@domain.com for DirectRouting with the Online Voice Routing Policy and Phone Number provided.

## PARAMETERS

### -Identity
UserPrincipalName (UPN) of the User to change the configuration for

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

### -DirectRouting
Optional (Default).
Limits the Scope to enable an Object for DirectRouting

```yaml
Type: SwitchParameter
Parameter Sets: DirectRouting
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlineVoiceRoutingPolicy
Required for DirectRouting.
Assigns an Online Voice Routing Policy to the User

```yaml
Type: String
Parameter Sets: DirectRouting
Aliases: OVP

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantDialPlan
Optional for DirectRouting.
Assigns a Tenant Dial Plan to the User

```yaml
Type: String
Parameter Sets: (All)
Aliases: TDP

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PhoneNumber
Required.
Phone Number in E.164 format to be assigned to the User.
For DirectRouting, will populate the OnPremLineUri
For CallingPlans, will populate the TelephoneNumber (must be present in the Tenant)

```yaml
Type: String
Parameter Sets: (All)
Aliases: Number, LineURI

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallingPlan
Enables an Object for Microsoft Calling Plans

```yaml
Type: SwitchParameter
Parameter Sets: CallingPlans
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallingPlanLicense
Optional for CallingPlans.
Assigns a Calling Plan License to the User.
Must be one of the set: InternationalCallingPlan DomesticCallingPlan DomesticCallingPlan120 CommunicationCredits DomesticCallingPlan120b

```yaml
Type: String[]
Parameter Sets: CallingPlans
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
By default, this script only applies changed elements.
Force overwrites configuration regardless of current status.
Additionally Suppresses confirmation inputs except when $Confirm is explicitly specified

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

### -PassThru
Optional.
Displays Object after action.

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

### -WriteErrorLog
If Errors are encountered, writes log to C:\Temp

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
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

### System.Void (without Switch PassThru)
### System.Object (with Switch PassThru)
### System.File (with Switch WriteErrorLog)
## NOTES
ParameterSet 'DirectRouting' will provision a User to use DirectRouting.
Enables User for Enterprise Voice,
assigns a Number and an Online Voice Routing Policy and optionally also a Tenant Dial Plan.
This is the default.
ParameterSet 'CallingPlans' will provision a User to use Microsoft CallingPlans.
Enables User for Enterprise Voice and assigns a Microsoft Number (must be found in the Tenant!)
Optionally can also assign a Calling Plan license prior.

## RELATED LINKS

[Find-TeamsUserVoiceConfig
Get-TeamsTenantVoiceConfig
Get-TeamsUserVoiceConfig
Set-TeamsUserVoiceConfig
Remove-TeamsUserVoiceConfig
Test-TeamsUserVoiceConfig]()

