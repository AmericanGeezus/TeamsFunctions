---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Grant-TeamsEmergencyAddress.md
schema: 2.0.0
---

# Grant-TeamsEmergencyAddress

## SYNOPSIS
Grants an existing Emergency Address (CivicAddress) to a User

## SYNTAX

```
Grant-TeamsEmergencyAddress [-Identity] <String> [-Address] <String> [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Civic Address used as an Emergency Address is assigned to the CsOnlineVoiceUser Object
This is done by Name (Description) of the Address instead of the Id

## EXAMPLES

### EXAMPLE 1
```
Grant-TeamsEmergencyAddress -Identity John@domain.com -Address "3rd Floor Cafe"
```

Searches for the Civic Address with the Exact description of "3rd Floor Cafe" and assigns this Address to the User

### EXAMPLE 2
```
Grant-TeamsEmergencyAddress -Identity +15551234567 -Address "3rd Floor Cafe"
```

Searches for the Civic Address with the Exact description of "3rd Floor Cafe" and
assigns this Address to the Number +15551234567 if found in the Business Voice Directory
AddressDescription is an Alias for Address

### EXAMPLE 3
```
Grant-TeamsEmergencyAddress -Identity John@domain.com -LocationId 0000000-0000-000000000000
```

Searches for the Civic Address with the LocationId 0000000-0000-000000000000 and assigns this Address to the User
LocationId is an Alias for Address

### EXAMPLE 4
```
Grant-TeamsEmergencyAddress -Identity +15551234567 -PolicyName 0000000-0000-000000000000
```

Searches for the Civic Address with the LocationId 0000000-0000-000000000000 and
assigns this Address to the Number +15551234567 if found in the Business Voice Directory
PolicyName is an Alias for Address (as it fits the theme)

## PARAMETERS

### -Identity
Required.
UserPrincipalName or ObjectId of the User Object or a TelephoneNumber

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName, ObjectId, PhoneNumber

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Address
Required.
Friendly name of the Address as specified in the Tenant or LocationId of the Address.
LocationIds are taken as-is, friendly names are queried against Get-CsOnlineLisLocation for a defined Location

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### System.Void
## NOTES
This script looks up the Civic Address in the Lis-Database and feeds the Address Object to Set-CsOnlineVoiceUser
This treats the Address like a Policy and behaves in the same way as the EmergencyCallingPolicy or the
EmergencyCallRoutingPolicy to assign to a user.
Accepts the Address Description or a LocationId directly.
Can be utilised like any other policy.
Aliases to Address are: AddressDescription, LocationId, PolicyName.
https://docs.microsoft.com/en-us/microsoftteams/manage-emergency-call-routing-policies
https://docs.microsoft.com/en-us/microsoftteams/configure-dynamic-emergency-calling

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Grant-TeamsEmergencyAddress.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Grant-TeamsEmergencyAddress.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

