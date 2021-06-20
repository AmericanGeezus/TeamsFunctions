---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCommonAreaPhone.md
schema: 2.0.0
---

# Remove-TeamsCommonAreaPhone

## SYNOPSIS
Removes a Common Area Phone from AzureAD

## SYNTAX

```
Remove-TeamsCommonAreaPhone [-UserPrincipalName] <String[]> [-PassThru] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function allows you to remove Common Area Phones (AzureAdUser) from AzureAD

## EXAMPLES

### EXAMPLE 1
```
Remove-TeamsCommonAreaPhone -UserPrincipalName "Common Area Phone@TenantName.onmicrosoft.com"
```

Removes a CommonAreaPhone
Removes in order: Phone Number, License and Account

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

### -Force
Optional.
Suppresses Confirmation prompt to remove User.

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

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCommonAreaPhone.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Remove-TeamsCommonAreaPhone.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsUserVoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[about_TeamsUserVoiceConfiguration]()

[Get-TeamsCommonAreaPhone]()

[New-TeamsCommonAreaPhone]()

[Set-TeamsCommonAreaPhone]()

[Remove-TeamsCommonAreaPhone]()

[Find-TeamsUserVoiceConfig]()

[Get-TeamsUserVoiceConfig]()

[New-TeamsUserVoiceConfig]()

[Set-TeamsUserVoiceConfig]()

