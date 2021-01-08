---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Enable-AzureAdAdminRole

## SYNOPSIS
Enables eligible Admin Roles

## SYNTAX

```
Enable-AzureAdAdminRole [[-Identity] <String>] [[-Reason] <String>] [[-Duration] <Int32>] [[-TicketNr] <Int32>]
 [[-ProviderId] <String>] [-Extend] [-PassThru] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Azure Ad Privileged Identity Management can require you to activate Admin Roles.
Eligibe roles or groups can be activated with this Command

## EXAMPLES

### EXAMPLE 1
```
Enable-AzureAdAdminRole John@domain.com
```

Enables all eligible Teams Admin roles for User John@domain.com

### EXAMPLE 2
```
Enable-AzureAdAdminRole John@domain.com -EnableAll -Reason "Need to provision Users" -Duration 4
```

Enables all eligible Admin roles for User John@domain.com with the reason provided.

### EXAMPLE 3
```
Enable-AzureAdAdminRole John@domain.com -EnableAll -ProviderId azureResources -Confirm
```

Enables all eligible Azure Resources for User John@domain.com with confirmation for each Resource.

### EXAMPLE 4
```
Enable-AzureAdAdminRole John@domain.com -Extend -Duration 3
```

If already activated, will extend the Azure Resources for User John@domain.com for up to 3 hours.

## PARAMETERS

### -Identity
Username of the Admin Account to enable roles for

```yaml
Type: String
Parameter Sets: (All)
Aliases: UPN, UserPrincipalName, Username

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Reason
Optional.
Small statement why these roles are requested
By default, "admin" is used as the reason.

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

### -Duration
Optional.
Integer.
By default, enables Roles for 4 hours.
Depending on your Administrators settings, values between 1 and 24 hours can be specified

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TicketNr
Optional.
Integer.
Only used if provided
Depending on your Administrators settings, a ticket number may be required to process the request

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
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
Position: 5
Default value: AadRoles
Accept pipeline input: False
Accept wildcard characters: False
```

### -Extend
Optional.
Switch.
If an assignment is already active, it can be extended.
This will leave an open request which can be closed manually.

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

### None
## NOTES
Limitations: MFA must be authorised first
Currently no way to trigger it via PowerShell.
If the activation fails, please sign into Office.com
Once Authorised, this command can be used to activate your eligible Admin Roles.
AzureResources provider activation is not yet tested.

Thanks to Nathan O'Bryan, MVP|MCSM - nathan@mcsmlab.com for inspiring this script through Activate-PIMRole.ps1

## RELATED LINKS

[Enable-AzureAdAdminRole
Get-AzureAdAdminRole]()

