---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Remove-TeamsResourceAccountAssociation

## SYNOPSIS
Removes the connection between a Resource Account and a CQ or AA

## SYNTAX

```
Remove-TeamsResourceAccountAssociation [-UserPrincipalName] <String[]> [-Force] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes an associated Resource Account from a Call Queue or Auto Attendant

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsResourceAccountAssociation -UserPrincipalName ResourceAccount@domain.com
```

Removes the Association of the Account 'ResourceAccount@domain.com' from the identified Call Queue or Auto Attendant

## PARAMETERS

### -UserPrincipalName
Required.
UPN(s) of the Resource Account(s) to be removed from a Call Queue or AutoAttendant

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Force
Optional.
Suppresses Confirmation dialog if -Confirm is not provided

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

### -PassThru
Optional.
Displays Object after removal of association.

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

### None
## NOTES
Does the same as Remove-CsOnlineApplicationInstanceAssociation, but with friendly Names
General notes

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsResourceAccountAssociation]()

[New-TeamsResourceAccountAssociation]()

[Remove-TeamsResourceAccountAssociation]()

[Remove-TeamsResourceAccount]()

