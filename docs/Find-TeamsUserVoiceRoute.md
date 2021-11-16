---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md
schema: 2.0.0
---

# Find-TeamsUserVoiceRoute

## SYNOPSIS
Returns Voice Route for a User and a dialed number

## SYNTAX

### UserPrincipalName (Default)
```
Find-TeamsUserVoiceRoute [-UserPrincipalName] <String[]> [-DialedNumber <String[]>] [<CommonParameters>]
```

### Object
```
Find-TeamsUserVoiceRoute [-Object] <Object[]> [-DialedNumber <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Returns a custom object detailing voice routing information for a User
If a Dialed Number is provided, also normalises the number and returns the effective Tenant Dial Plan

## EXAMPLES

### EXAMPLE 1
```
Find-TeamsUserVoiceRoute -Identity John@domain.com
```

Finds the Voice Route any call for this user may take.
First match (Voice Route with the highest priority) will be returned

### EXAMPLE 2
```
Find-TeamsUserVoiceRoute -Identity John@domain.com -DialledNumber "+1(555) 1234-567"
```

Finds the Voice Route a call to the normalised Number +15551234567 for this user may take.
The matching Voice Route will be returned

### EXAMPLE 3
```
Find-TeamsUserVoiceRoute -Identity John@domain.com -DialledNumber "911","+1(555) 1234-567"
```

Finds the Voice Route a call to 911 and the normalised Number +15551234567 for this user may take.
The matching Voice Route will be returned
Returns one object for each number as they might be routed through different entities

## PARAMETERS

### -Object
Required for Parameterset Object.
CsOnlineUser Object passed to the function to reduce query time.
User must have a valid Voice Configuration applied for this script to return a valuable result

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
UserPrincipalName of the User to query.
User must have a valid Voice Configuration applied for this script to return a valuable result

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

### -DialedNumber
Optional.
Number entered in the Dial Pad.
If not provided, the first Voice Route will be chosen.
If provided, number will be normalised and the effective Dial Plan queried.
A matching Route will be found for this number will be queried
Accepts multiple Numbers to dial - one object returned for each number dialed.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Number

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
This is a slightly more intricate on Voice routing, enabling comparisons for multiple users.
Based on and inspired by Test-CsOnlineUserVoiceRouting by Lee Ford - https://www.lee-ford.co.uk

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

