---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# New-TeamsResourceAccountAssociation

## SYNOPSIS
Connects one or more Resource Accounts to a single CallQueue or AutoAttendant

## SYNTAX

### CallQueue (Default)
```
New-TeamsResourceAccountAssociation [-UserPrincipalName] <String[]> -CallQueue <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### AutoAttendant
```
New-TeamsResourceAccountAssociation [-UserPrincipalName] <String[]> -AutoAttendant <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Associates one or more existing Resource Accounts to a Call Queue or Auto Attendant
Resource Account Type is checked against the ApplicationType.
User is prompted if types do not match

## EXAMPLES

### EXAMPLE 1
```
New-TeamsResourceAccountAssociation -UserPrincipalName Account1@domain.com -
```

Explanation of what the example does

## PARAMETERS

### -UserPrincipalName
Required.
UPN(s) of the Resource Account(s) to be associated to a Call Queue or AutoAttendant

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

### -CallQueue
Optional.
Specifies the connection to be made to the provided Call Queue Name

```yaml
Type: String
Parameter Sets: CallQueue
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AutoAttendant
Optional.
Specifies the connection to be made to the provided Auto Attendant Name

```yaml
Type: String
Parameter Sets: AutoAttendant
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Optional.
Suppresses Confirmation dialog if -Confirm is not provided
Used to override prompts for alignment of ApplicationTypes.
The Resource Account is changed to have the same type as the associated Object (CallQueue or AutoAttendant)!

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

### System.Object
## NOTES
Connects multiple Resource Accounts to ONE CallQueue or AutoAttendant
The Type of the Resource Account has to corellate to the entity connected.
Parameter Force can be used to change the type of RA to align to the entity if possible.

## RELATED LINKS

[Get-TeamsResourceAccountAssociation
New-TeamsResourceAccountAssociation
Remove-TeamsResourceAccountAssociation
New-TeamsResourceAccount
Get-TeamsResourceAccount
Set-TeamsResourceAccount
Remove-TeamsResourceAccount]()

