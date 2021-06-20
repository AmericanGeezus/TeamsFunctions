---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTDP.md
schema: 2.0.0
---

# Get-TeamsTDP

## SYNOPSIS
Lists all Tenant Dial Plans by Name

## SYNTAX

```
Get-TeamsTDP [[-Identity] <String>] [<CommonParameters>]
```

## DESCRIPTION
To quickly find Tenant Dial Plans to assign, an Alias-Function to Get-CsTenantDialPlan

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsTDP
```

Returns the Object for all Tenant Dial Plans (except "Global")
Behaviour like: Get-CsTenantDialPlan, showing only a few Parameters (no Normalization Rules)

### EXAMPLE 2
```
Get-TeamsTDP -Identity DP-HUN
```

Lists Tenant Dial Plan DP-HUN as Get-CsTenantDialPlan does.

### EXAMPLE 3
```
Get-TeamsTDP -Filter DP-HUN
```

Lists all Tenant Dials that contain the strign "*DP-HUN*" in the Name.

## PARAMETERS

### -Identity
If provided, acts as an Alias to Get-CsTenantDialPlan, listing one Dial Plan
If not provided, lists Identities of all Tenant Dial Plans (except "Global")

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
### System.String
## OUTPUTS

### System.Object
## NOTES
This script is indulging the lazy admin.
It behaves like Get-CsTenantDialPlan with a twist:
If used without Parameter, a reduced set of Parameters are shown for better visibility:
Without parameters, it executes the following string:
Get-CsTenantDialPlan | Where-Object Identity -NE "Global" | Select-Object Identity, SimpleName, OptimizeDeviceDialing, Description

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTDP.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsTDP.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

[about_TeamsUserVoiceConfiguration]()

[Get-TeamsTDP]()

[Get-TeamsVNR]()

[Get-TeamsIPP]()

[Get-TeamsCP]()

[Get-TeamsECP]()

[Get-TeamsECRP]()

[Get-TeamsOVP]()

[Get-TeamsOPU]()

[Get-TeamsOVR]()

[Get-TeamsMGW]()

