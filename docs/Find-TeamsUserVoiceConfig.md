---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceConfig.md
schema: 2.0.0
---

# Find-TeamsUserVoiceConfig

## SYNOPSIS
Displays User Accounts matching a specific Voice Configuration Parameter

## SYNTAX

### Tel (Default)
```
Find-TeamsUserVoiceConfig [[-PhoneNumber] <String>] [-ValidateLicense] [-IncludeTotalCount] [-Skip <UInt64>]
 [-First <UInt64>] [<CommonParameters>]
```

### ID
```
Find-TeamsUserVoiceConfig [-UserPrincipalName <String>] [-ValidateLicense] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### Ext
```
Find-TeamsUserVoiceConfig [-Extension <String>] [-ValidateLicense] [-IncludeTotalCount] [-Skip <UInt64>]
 [-First <UInt64>] [<CommonParameters>]
```

### CT
```
Find-TeamsUserVoiceConfig [-ConfigurationType <String>] [-ValidateLicense] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### VP
```
Find-TeamsUserVoiceConfig [-VoicePolicy <String>] [-ValidateLicense] [-IncludeTotalCount] [-Skip <UInt64>]
 [-First <UInt64>] [<CommonParameters>]
```

### OVP
```
Find-TeamsUserVoiceConfig [-OnlineVoiceRoutingPolicy <String>] [-ValidateLicense] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### TDP
```
Find-TeamsUserVoiceConfig [-TenantDialPlan <String>] [-ValidateLicense] [-IncludeTotalCount] [-Skip <UInt64>]
 [-First <UInt64>] [<CommonParameters>]
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

Shows Voice Configuration for John, returning the full Object (query with Get-TeamsUserVoiceConfig)

### EXAMPLE 2
```
Find-TeamsUserVoiceConfig -PhoneNumber "15551234567"
```

Shows all Users which have this String in their LineURI (TelephoneNumber or OnPremLineURI)
The expected ResultSize is limited, if only one result is shown, the full Object is returned (Get-TeamsUserVoiceConfig)
Please see NOTES for details

### EXAMPLE 3
```
Find-TeamsUserVoiceConfig -ConfigurationType DirectRouting
```

Shows all Users which are configured for DirectRouting
The expected ResultSize is big
Please see NOTES for details

### EXAMPLE 4
```
Find-TeamsUserVoiceConfig -VoicePolicy BusinessVoice
```

Shows all Users which are configured for PhoneSystem with CallingPlans
The expected ResultSize is big, therefore only Names (UPNs) of Users are displayed
Please see NOTES and LINK for details

### EXAMPLE 5
```
Find-TeamsUserVoiceConfig -OnlineVoiceRoutingPolicy O_VP_EMEA -First 300
```

Shows all Users which have the OnlineVoiceRoutingPolicy "O_VP_EMEA" assigned
Depending on the Size of your tenant, the expected ResultSize is big, paging parameters can help reduce output
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
Aliases: ObjectId, Identity

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
Type: String
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
Type: String
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
Please note, that seaching with ConfigurationType does not support paging
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
In addition to validation of Parameters, also validates License assignment for the found user(s).
This Parameter will initiate a quick check against the PhoneSystem License of each found account and will only return
objects that are correctly configured
License Check is performed AFTER parameters are verified.

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

### -IncludeTotalCount
Reports the total number of objects in the data set (an integer) followed by the selected objects.
If the cmdlet cannot determine the total count, it displays "Unknown total count." The integer has an Accuracy property that indicates the reliability of the total count value.
The value of Accuracy ranges from 0.0 to 1.0 where 0.0 means that the cmdlet could not count the objects, 1.0 means that the count is exact, and a value between 0.0 and 1.0 indicates an increasingly reliable estimate.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skip
Ignores the specified number of objects and then gets the remaining objects.
Enter the number of objects to skip.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -First
Gets only the specified number of objects.
Enter the number of objects to get.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

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

### System.String - UserPrincipalName - With any Parameter except Identity or PhoneNumber
### System.Object - With Parameter Identity or PhoneNumber
## NOTES
All searches are filtering on Get-CsOnlineUser and are supporting paging
This usually should not take longer than a minute to complete.
If a single result is found, the object queries the full output through Get-TeamsUserVoiceConfig
If more than three results are found, a reduced output is displayed
If more than five results are found, only UserPrincipalName, SipAddress and LineUri are displayed

Search behaviour:
- PhoneNumber: Searches against the LineURI parameter.
For best compatibility, provide in E.164 format (with or without the +)
This script can find duplicate assignments if the Number was assigned with and without an extension.
- Extension: Searches against the LineURI parameter and considers all strings after ";ext=" an extension.
This script can find duplicate assignments if the Extension was assigned to multiple Numbers.
- ConfigurationType: Filtering based on Microsofts Documentation for DirectRouting, SkypeForBusiness Hybrid PSTN and CallingPlans
- VoicePolicy:
  - BusinessVoice are PhoneSystem Users exclusively configured for Microsoft Calling Plans.
  - HybridVoice are PhoneSystem Users who are configured for TDR, Hybrid SkypeOnPrem PSTN or Hybrid CloudConnector PSTN breakouts
- OnlineVoiceRoutingPolicy: Finds all users which have this particular Policy assigned
- TenantDialPlan: Finds all users which have this particular DialPlan assigned.
Please see Related Link for more information

Output is designed to be piped to Get-TeamsUserVoiceConfiguration for full evaluation of Licenses and configuration.

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceConfig.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceConfig.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-migrating)

