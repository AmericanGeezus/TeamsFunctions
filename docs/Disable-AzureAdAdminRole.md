---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Disable-AzureAdAdminRole

## SYNOPSIS
Disables active Admin Roles

## SYNTAX

```
Disable-AzureAdAdminRole [[-Identity] <String>] [[-Reason] <String>] [[-ProviderId] <String>] [-PassThru]
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Azure Ad Privileged Identity Management can require you to activate Admin Roles.
Active roles or groups can be deactivated with this Command

## EXAMPLES

### EXAMPLE 1
```
Disable-AzureAdAdminRole John@domain.com
```

Disables all active Teams Admin roles for User John@domain.com

### EXAMPLE 2
```
Disable-AzureAdAdminRole John@domain.com -Reason "Finished"
```

Disables all active Admin roles for User John@domain.com with the reason provided.

## PARAMETERS

### -Identity
Username of the Admin Account to disable roles for

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName, ObjectId

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Reason
Optional.
Small statement why these roles are disabled
By default, "Administration finished" is used as the reason.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProviderId
Optional.
Default is 'aadRoles' for the ProviderId, however, this script could also be used for activating
Azure Resources ('azureResources').
Use with Confirm and EnableAll.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: AadRoles
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Optional.
Displays output object for each activated Role
Used for further processing to verify command was successful

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
Overrides confirmation dialog and enables all eligible roles

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

### System.Void - Default Behaviour
### System.Object - With Switch PassThru
### Boolean - If called by other CmdLets
## NOTES
Limitations: MFA must be authorised first
Currently no way to trigger it via PowerShell.
If the activation fails, please sign into Office.com
Once Authorised, this command can be used to activate your eligible Admin Roles.
AzureResources provider activation is not yet tested.

Thanks to Nathan O'Bryan, MVP|MCSM - nathan@mcsmlab.com for inspiring this script through Activate-PIMRole.ps1

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[Enable-AzureAdAdminRole]()

[Enable-MyAzureAdAdminRole]()

[Get-AzureAdAdminRole]()

[Get-MyAzureAdAdminRole]()

