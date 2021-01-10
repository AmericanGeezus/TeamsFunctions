---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Remove-TeamsResourceAccount

## SYNOPSIS
Removes a Resource Account from AzureAD

## SYNTAX

```
Remove-TeamsResourceAccount [-UserPrincipalName] <String[]> [-Force] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function allows you to remove Resource Accounts (Application Instances) from AzureAD

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com"
```

Removes a ResourceAccount
Removes in order: Phone Number, License and Account

### EXAMPLE 2
```
Remove-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com" -Force
```

Removes a ResourceAccount
Removes in order: Association, Phone Number, License and Account

## PARAMETERS

### -UserPrincipalName
Required.
Identifies the Object being changed

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Identity, ObjectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Force
Optional.
Will also sever all associations this account has in order to remove it
If not provided and the Account is connected to a Call Queue or Auto Attendant, an error will be displayed

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
Displays UserPrincipalName of removed objects.

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
Execution requires User Admin Role in Azure AD

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Get-TeamsResourceAccountAssociation]()

[New-TeamsResourceAccountAssociation]()

[Remove-TeamsResourceAccountAssociation]()

[New-TeamsResourceAccount]()

[Get-TeamsResourceAccount]()

[Find-TeamsResourceAccount]()

[Set-TeamsResourceAccount]()

[Remove-TeamsResourceAccount]()

