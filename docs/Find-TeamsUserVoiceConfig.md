---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Find-TeamsUserVoiceConfig

## SYNOPSIS
Displays User Accounts matching a specific Voice Configuration Parameter

## SYNTAX

### Tel (Default)
```
Find-TeamsUserVoiceConfig [[-PhoneNumber] <String[]>] [<CommonParameters>]
```

### ID
```
Find-TeamsUserVoiceConfig [-UserPrincipalName <String>] [<CommonParameters>]
```

### Ext
```
Find-TeamsUserVoiceConfig [-Extension <String[]>] [<CommonParameters>]
```

### CT
```
Find-TeamsUserVoiceConfig [-ConfigurationType <String>] [-ValidateLicense] [<CommonParameters>]
```

### VP
```
Find-TeamsUserVoiceConfig [-VoicePolicy <String>] [<CommonParameters>]
```

### OVP
```
Find-TeamsUserVoiceConfig [-OnlineVoiceRoutingPolicy <String>] [<CommonParameters>]
```

### TDP
```
Find-TeamsUserVoiceConfig [-TenantDialPlan <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns UserPrincipalNames of Objects matching specific parameters.
For PhoneNumbers also displays their basic Voice Configuration
Search parameters are mutually exclusive, only one Parameter can be specified at the same time.
Available parameters are:
- PhoneNumber: Part of the LineURI (ideally without 'tel:','+' or ';ext=...')
- ConfigurationType: 'CallPlans' or 'DirectRouting'.
Will deliver partially configured accounts as well.
- VoicePolicy: 'BusinessVoice' (CallPlans) or 'HybridVoice' (DirectRouting or any other Hybrid PSTN configuration)
- OnlineVoiceRoutingPolicy: Any string value (incl.
$Null), but not empty ones.
- TenantDialPlan: Any string value (incl.
$Null), but not empty ones.

## EXAMPLES

### EXAMPLE 1
```
Find-TeamsUserVoiceConfig -UserPrincipalName John@domain.com
```

Shows Voice Configuration for John, returning the full Object

### EXAMPLE 2
```
Find-TeamsUserVoiceConfig -PhoneNumber "15551234567"
```

Shows all Users which have this String in their LineURI (TelephoneNumber or OnPremLineURI)
The expected ResultSize is limited, the full Object is returned (Get-TeamsUserVoiceConfig)
Please see NOTES for details

### EXAMPLE 3
```
Find-TeamsUserVoiceConfig -ConfigurationType CallingPlans
```

Shows all Users which are configured for CallingPlans (Full)
The expected ResultSize is big, therefore only Names (UPNs) of Users are returned
Pipe to Get-TeamsUserVoiceConfiguration for full output.
Please see NOTES for details

### EXAMPLE 4
```
Find-TeamsUserVoiceConfig -VoicePolicy BusinessVoice
```

Shows all Users which are configured for PhoneSystem with CallingPlans
The expected ResultSize is big, therefore only Names (UPNs) of Users are displayed
Pipe to Get-TeamsUserVoiceConfiguration for full output.
Please see NOTES and LINK for details

### EXAMPLE 5
```
Find-TeamsUserVoiceConfig -OnlineVoiceRoutingPolicy O_VP_EMEA
```

Shows all Users which have the OnlineVoiceRoutingPolicy "O_VP_EMEA" assigned
The expected ResultSize is big, therefore only Names (UPNs) of Users are displayed
Pipe to Get-TeamsUserVoiceConfiguration for full output.
Please see NOTES for details

### EXAMPLE 6
```
Find-TeamsUserVoiceConfig -TenantDialPlan DP-US
```

Shows all Users which have the TenantDialPlan "DP-US" assigned.
Please see NOTES for details

## PARAMETERS

### -UserPrincipalName
Optional.
UserPrincipalName (UPN) of the User
Behaves like Get-TeamsUserVoiceConfig, displaying the Users Voice Configuration

```yaml
Type: String
Parameter Sets: ID
Aliases: Identity

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PhoneNumber
Optional.
Searches all Users matching the given String in their LineURI.
The expected ResultSize is limited, the full Object is displayed (Get-TeamsUserVoiceConfig)
Please see NOTES for details

```yaml
Type: String[]
Parameter Sets: Tel
Aliases: Number, TelephoneNumber, Tel, LineURI, OnPremLineURI

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Extension
String to be found in any of the PhoneNumber fields as an Extension

```yaml
Type: String[]
Parameter Sets: Ext
Aliases: Ext

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationType
Optional.
Searches all enabled Users which are at least partially configured for 'CallingPlans', 'DirectRouting' or 'SkypeHybridPSTN'.
The expected ResultSize is big, therefore only UserPrincipalNames are returned
Please see NOTES for details

```yaml
Type: String
Parameter Sets: CT
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VoicePolicy
Optional.
Searches all enabled Users which are reported as 'BusinessVoice' or 'HybridVoice'.
The expected ResultSize is big, therefore only UserPrincipalNames are returned
Please see NOTES for details

```yaml
Type: String
Parameter Sets: VP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlineVoiceRoutingPolicy
Optional.
Searches all enabled Users which have the OnlineVoiceRoutingPolicy specified assigned.
Please specify full and correct name or '$null' to receive all Users without one
The expected ResultSize is big, therefore only UserPrincipalNames are returned
Please see NOTES for details

```yaml
Type: String
Parameter Sets: OVP
Aliases: OVP

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantDialPlan
Optional.
Searches all enabled Users which have the TenantDialPlan specified assigned.
Please specify full and correct name or '$null' to receive all Users without one
The expected ResultSize is big, therefore only UserPrincipalNames are returned
Please see NOTES for details

```yaml
Type: String
Parameter Sets: TDP
Aliases: TDP

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidateLicense
Optional.
Can be combined only with -ConfigurationType
In addition to validation of Parameters, also validates License assignment for the found user.
License Check is performed AFTER parameters are verified.

```yaml
Type: SwitchParameter
Parameter Sets: CT
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

### String (UPN)  - With any Parameter except Identity or PhoneNumber
### System.Object - With Parameter Identity or PhoneNumber
## NOTES
With the exception of Identity and PhoneNumber, all searches are filtering on Get-CsOnlineUser
This usually should not take longer than a minute to complete.
Identity is querying the provided UPN and only wraps Get-TeamsUserVoiceConfig
PhoneNumber has to do a full search with 'Where-Object' which will take time to complete
Depending on the number of Users in the Tenant, this may take a few minutes!

All Parameters except UserPrincipalName or PhoneNumber will only return UserPrincipalNames (UPNs)
- PhoneNumber: Searches against the LineURI parameter.
For best compatibility, provide in E.164 format (with or without the +)
This script can find duplicate assignments if the Number was assigned with and without an extension.
- ConfigurationType: This is determined with Test-TeamsUserVoiceConfig -Partial and will return all Accounts found
- VoicePolicy: BusinessVoice are PhoneSystem Users exclusively configured for Microsoft Calling Plans.
  HybridVoice are PhoneSystem Users who are configured for TDR, Hybrid SkypeOnPrem PSTN or Hybrid CloudConnector PSTN breakouts
- OnlineVoiceRoutingPolicy: Finds all users which have this particular Policy assigned
- TenantDialPlan: Finds all users which have this particular DialPlan assigned.
Please see Related Link for more information

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating)

[Assert-TeamsUserVoiceConfig]()

[Find-TeamsUserVoiceConfig]()

[Get-TeamsTenantVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

[Remove-TeamsUserVoiceConfig]()

[Test-TeamsUserVoiceConfig]()

