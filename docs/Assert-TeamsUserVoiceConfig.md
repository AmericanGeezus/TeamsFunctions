---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsUserVoiceConfig.md
schema: 2.0.0
---

# Assert-TeamsUserVoiceConfig

## SYNOPSIS
Tests the validity of the Voice Configuration for one or more Users

## SYNTAX

### UserPrincipalName (Default)
```
Assert-TeamsUserVoiceConfig [-UserPrincipalName] <String[]> [-IncludeTenantDialPlan] [-ExtensionState <String>]
 [<CommonParameters>]
```

### Object
```
Assert-TeamsUserVoiceConfig [-Object] <Object[]> [-IncludeTenantDialPlan] [-ExtensionState <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Validates Object Type, enablement for Enterprise Voice, and optionally also the Tenant Dial Plan
For Calling Plans, validates Calling Plan License and presence of Telephone Number
For Direct Routing, validates Online Voice Routing Policy and OnPremLineUri
For Skype Hybrid PSTN, validate Voice Routing Policy and OnPremLineUri
Configuration is always done on the assumption that a full configuration is desired.
Any partial configuration is fed back on screen.

## EXAMPLES

### EXAMPLE 1
```
Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com
```

If incorrect/missing, writes information output about every tested parameter
Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration

### EXAMPLE 2
```
Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -IncludeTenantDialPlan
```

If incorrect/missing, writes information output about every tested parameter including the Tenant Dial Plan
Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration

### EXAMPLE 3
```
Assert-TeamsUserVoiceConfig -UserPrincipalName John@domain.com -ExtensionState MustBePopulated
```

If incorrect/missing, writes information output about every tested parameter including the Extension.
With MustBePopulated an Extension is expected.
If no Extension is present, it is flagged as misconfigured
Returns output of Get-TeamsUserVoiceConfig for all Objects that have an incorrectly configured Voice Configuration

## PARAMETERS

### -Object
Required for Parameterset Object.
CsOnlineUser Object passed to the function to reduce query time.

```yaml
Type: Object[]
Parameter Sets: Object
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserPrincipalName
Required for Parameterset UserPrincipalName.
UserPrincipalName or ObjectId of the Object

```yaml
Type: String[]
Parameter Sets: UserPrincipalName
Aliases: ObjectId, Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -IncludeTenantDialPlan
Optional.
By default, only the core requirements for Voice Routing are verified.
This extends the requirements to also include the Tenant Dial Plan.

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

### -ExtensionState
Optional.
For DirectRouting, enforces the presence (or absence) of an Extension.
Default: NotMeasured
No effect for Microsoft Calling Plans

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: NotMeasured
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Void - If called directly and no errors are found - Information Text only
### System.Object - If called directly and errors are found (Get-TeamsUserVoiceConfig)
### Boolean - If called by other CmdLets
## NOTES
Verbose output is available, though all required information is fed back directly to the User.
If no objections are found, nothing is returned.
Piping the Output to Export-Csv can give the best result for investigation into misconfigured users.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsUserVoiceConfig.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsUserVoiceConfig.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating)

