---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Remove-TeamsUserVoiceConfig

## SYNOPSIS
Removes existing Voice Configuration for one or more Users

## SYNTAX

```
Remove-TeamsUserVoiceConfig [-UserPrincipalName] <String[]> [-Scope <String>] [-DisableEV] [-PassThru] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
De-provisions a user from Enterprise Voice, removes the Telephone Number, Tenant Dial Plan and Voice Routing Policy

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com [-Scope All]
```

Disables John for Enterprise Voice, then removes all Phone Numbers, Voice Routing Policy, Tenant Dial Plan and Call Plan licenses

### EXAMPLE 2
```
Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope DirectRouting
```

Disables John for Enterprise Voice, Removes Phone Number, Voice Routing Policy and Tenant Dial Plan if assigned

### EXAMPLE 3
```
Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope CallingPlans [-Confirm]
```

Disables John for Enterprise Voice, Removes Phone Number and subsequently removes all Call Plan Licenses assigned
  Prompts for Confirmation before removing Call Plan licenses

### EXAMPLE 4
```
Remove-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -Scope CallingPlans -Force
```

Disables John for Enterprise Voice, Removes Phone Number and subsequently removes all Call Plan Licenses assigned
  Does not prompt for Confirmation (unless -Confirm is specified explicitly)

## PARAMETERS

### -UserPrincipalName
Required.
UserPrincipalName of the User.

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
Optional.
Default is "All".
Definition of Scope for removal of Voice Configuration.
Allowed Values are: All, DirectRouting, CallingPlans

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableEV
Optional.
Instructs the Script to also disable the Enterprise Voice enablement of the User
By default the switch EnterpriseVoiceEnabled is left as-is.
Replication applies when re-enabling EnterPriseVoice.
This is useful for migrating already licensed Users between Voice Configurations as it does not impact the User Experience (Dial Pad)
EnterpriseVoiceEnabled will be disabled automatically if the PhoneSystem license is removed
NOTE: If enabled, but no valid Voice Configuration is applied, the User will have a dial pad, but will not have an option to use the PhoneSystem.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: DisableEnterpriseVoice

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

### -Force
Optional.
Suppresses Confirmation for license Removal unless -Confirm is specified explicitly.

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

### System.Void - Default behaviour
### System.Object - With Switch PassThru
## NOTES
Prompting for Confirmation for disabling of EnterpriseVoice
For DirectRouting, this Script does not remove any licenses.
For CallingPlans it will prompt for Calling Plan licenses to be removed.

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

