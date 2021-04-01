---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Remove-TenantDialPlanNormalizationRule

## SYNOPSIS
Removes a normalization rule from a tenant dial plan.

## SYNTAX

```
Remove-TenantDialPlanNormalizationRule [-DialPlan] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This command will display the normalization rules for a tenant dial plan in a list with
index numbers.
After choosing one of the rule index numbers, the rule will be removed from
the tenant dial plan.
This command requires a remote PowerShell session to Teams.
Note: The Module name is still referencing Skype for Business Online (SkypeOnlineConnector).

## EXAMPLES

### EXAMPLE 1
```
Remove-TenantDialPlanNormalizationRule -DialPlan US-OK-OKC-DialPlan
```

Displays available normalization rules to remove from dial plan US-OK-OKC-DialPlan.

## PARAMETERS

### -DialPlan
This is the name of a valid dial plan for the tenant.
To view available tenant dial plans,
use the command Get-TeamsTDP.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### System.Void - Default Behavior
###   System.Object - With Switch PassThru
## NOTES
The dial plan rules will display in format similar the example below:
RuleIndex Name            Pattern    Translation
--------- ----            -------    -----------
0 Intl Dialing    ^011(\d+)$ +$1
1 Extension Rule  ^(\d{5})$  +155512$1
2 Long Distance   ^1(\d+)$   +1$1
3 Default         ^(\d+)$    +1$1

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_Unmanaged]()

