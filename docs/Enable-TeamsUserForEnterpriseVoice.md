---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Enable-TeamsUserForEnterpriseVoice.md
schema: 2.0.0
---

# Enable-TeamsUserForEnterpriseVoice

## SYNOPSIS
Enables a User for Enterprise Voice

## SYNTAX

### UserPrincipalName (Default)
```
Enable-TeamsUserForEnterpriseVoice [-UserPrincipalName] <String[]> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Object
```
Enable-TeamsUserForEnterpriseVoice [-Object] <Object[]> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enables a User for Enterprise Voice and verifies its status

## EXAMPLES

### EXAMPLE 1
```
Enable-TeamsUserForEnterpriseVoice John@domain.com
```

Enables John for Enterprise Voice

## PARAMETERS

### -Object
Required for Parameterset Object.
CsOnlineUser Object passed to the function to reduce query time.

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
UserPrincipalName of the User to be enabled.

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

### -Force
Suppresses confirmation prompt unless -Confirm is used explicitly

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

### System.Void - If called directly
### Boolean - If called by another CmdLet
## NOTES
Simple helper function to enable and verify a User is enabled for Enterprise Voice
Returns boolean result and less communication if called by another function
Can be used providing either the UserPrincipalName or the already queried CsOnlineUser Object

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Enable-TeamsUserForEnterpriseVoice.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Enable-TeamsUserForEnterpriseVoice.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_VoiceConfiguration.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

