---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-TeamsUserVoiceConfig

## SYNOPSIS
Displays Voice Configuration Parameters for one or more Users

## SYNTAX

```
Get-TeamsUserVoiceConfig [-Identity] <String[]> [-DiagnosticLevel <Int32>] [-SkipLicenseCheck]
 [<CommonParameters>]
```

## DESCRIPTION
Displays Voice Configuration Parameters with different Diagnostic Levels
ranging from basic Voice Configuration up to Policies, Account Status & DirSync Information

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsUserVoiceConfig -Identity John@domain.com
```

Shows Voice Configuration for John with a concise view of Parameters

### EXAMPLE 2
```
Get-TeamsUserVoiceConfig -Identity John@domain.com -DiagnosticLevel 2
```

Shows Voice Configuration for John with a extended list of Parameters (see NOTES)

## PARAMETERS

### -Identity
Required.
UserPrincipalName (UPN) of the User

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

### -DiagnosticLevel
Optional.
Value from 1 to 4.
Higher values will display more parameters
See NOTES below for details.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: DiagLevel, Level, DL

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipLicenseCheck
Optional.
Will not perform queries against User Licensing to improve performance

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: SkipLicense, SkipLic

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

### System.Object
## NOTES
DiagnosticLevel details:
1 Basic diagnostics for Hybrid Configuration or when moving users from On-prem Skype
2 Extended diagnostics displaying additional Voice-related Policies
3 Basic troubleshooting parameters from AzureAD like AccountEnabled, etc.
4 Extended troubleshooting parameters from AzureAD like LastDirSyncTime
Parameters are additive, meaning with each DiagnosticLevel more information is displayed

This script takes a select set of Parameters from AzureAD, Teams & Licensing.
For a full parameterset, please run:
- for AzureAD:    "Find-AzureAdUser $Identity | FL"
- for Licensing:  "Get-TeamsUserLicense $Identity"
- for Teams:      "Get-CsOnlineUser $Identity"

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Find-TeamsUserVoiceConfig]()

[Get-TeamsTenantVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

[Remove-TeamsUserVoiceConfig]()

[Test-TeamsUserVoiceConfig]()

