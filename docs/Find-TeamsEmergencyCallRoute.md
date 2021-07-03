---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md
schema: 2.0.0
---

# Find-TeamsEmergencyCallRoute

## SYNOPSIS
Returns Voice Route for a Site or Subnet and a dialed emergency number

## SYNTAX

### Site (Default)
```
Find-TeamsEmergencyCallRoute [-UserPrincipalName <String[]>] -DialedNumber <String> -NetworkSite <String[]>
 [<CommonParameters>]
```

### Subnet
```
Find-TeamsEmergencyCallRoute [-UserPrincipalName <String[]>] -DialedNumber <String> -NetworkSubnet <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
Returns a custom object detailing voice routing information for one or more Sites or Subnets and a dialed Emergency number.
User information also adds validation for static emergency calling options and validates configuration of the users Tenant Dial Plan.

## EXAMPLES

### EXAMPLE 1
```
Find-TeamsEmergencyCallRoute -NetworkSite Bogota -DialedNumber 112
```

Finds the route for an emergency call to 112 for the Site Bogota.
Only determines dynamic assignments

### EXAMPLE 2
```
Find-TeamsEmergencyCallRoute -NetworkSite Bogota -DialedNumber 112 -UserPrincipalName John@domain.com
```

Finds the route for an emergency call to 112 for the Site Bogota for the User John@domain.com.
Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)

### EXAMPLE 3
```
Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0 -DialedNumber 112
```

Finds the route for an emergency call to 112 for the Site in which the Subnet 10.1.15.0 is linked in

### EXAMPLE 4
```
Find-TeamsEmergencyCallRoute -NetworkSubnet Bogota -DialedNumber 112 -UserPrincipalName John@domain.com
```

Finds the route for an emergency call to 112 for the Site in which the Subnet 10.1.15.0 is linked in for the User John@domain.com.
Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)

### EXAMPLE 5
```
Find-TeamsEmergencyCallRoute -NetworkSite Bogota,Lima,Quito -DialedNumber 112
```

Finds the route for an emergency call to 112 for the Sites Bogota, Lima & Quito.
Only determines dynamic assignments

### EXAMPLE 6
```
Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0,10.1.20.0,10.1.27.0 -DialedNumber 112
```

Finds the route for an emergency call to 112 for the Sites each of these subnets are linked in.
Only determines dynamic assignments

### EXAMPLE 7
```
Find-TeamsEmergencyCallRoute -NetworkSite Bogota,Lima,Quito -DialedNumber 112 -UserPrincipalName John@domain.com
```

Finds the route for an emergency call to 112 for the Sites Bogota, Lima & Quito for the User John@domain.com.
Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)

### EXAMPLE 8
```
Find-TeamsEmergencyCallRoute -NetworkSubnet 10.1.15.0,10.1.20.0,10.1.27.0 -DialedNumber 112 -UserPrincipalName John@domain.com
```

Finds the route for an emergency call to 112 for the Sites each of these subnets are linked in for the User John@domain.com.
Determines dynamic assignments (ECRP assigned to Site) as well as static assignments (ECRP assigned to user)

## PARAMETERS

### -UserPrincipalName
Optional.
Username or UserPrincipalname of the User to query Online Voice Routing Policy and Tenant Dial Plan
User must have a valid Voice Configuration applied for this script to return a valuable result
If not provided, only dynamic assignment of Emergency Call Routing Policy (through Network Site) is queried.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ObjectId, Identity

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DialedNumber
Required.
Emergency Number as entered in the Dial Pad.
The effective Dial Plan is queried as a start.
Then, application of an Emergency Call Routing Policy is determined through static (User) or dynamic (Site/Subnet) assignment
Accepts multiple Numbers to dial - one object is returned for each number dialed and each Site or Subnet provided.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Number

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NetworkSite
Required for ParameterSet NetworkSite.
Name of a Network Site configured in the Network Topology of the Teams Tenant
One or more exact names (NetworkSiteId) are required.

```yaml
Type: String[]
Parameter Sets: Site
Aliases: Site

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NetworkSubnet
Required for ParameterSet NetworkSubnet.
Name of a Network Subnet configured in the Network Topology of the Teams Tenant
One or more exact names (Subnet Id) are required to determine the corresponding Network Site(s).
Site is used going forward.

```yaml
Type: String[]
Parameter Sets: Subnet
Aliases: Subnet

Required: True
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
This is an evolution to Find-TeamsUserVoiceRouting, focusing solely on Emergency Services calls.
Inspired by Test-CsOnlineUserVoiceRouting by Lee Ford - https://www.lee-ford.co.uk

Emergency Call Routing can be performed multiple ways.
This CmdLet tries to determine the effective state for the
given combination of Dialed Emergency Number

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsEmergencyCallRoute.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Find-TeamsUserVoiceRoute.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

