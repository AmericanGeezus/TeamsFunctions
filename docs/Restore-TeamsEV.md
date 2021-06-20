---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Restore-TeamsEV.md
schema: 2.0.0
---

# Restore-TeamsEV

## SYNOPSIS
A script to automatically restore a backed-up Teams Enterprise Voice configuration.

## SYNTAX

```
Restore-TeamsEV [-File] <String> [-KeepExisting] [[-OverrideAdminDomain] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
A script to automatically restore a backed-up Teams Enterprise Voice configuration.
Requires a backup run using Backup-TeamsEV.ps1 in the same directory as the script.
Will restore the following items:
- Dialplans and associated normalization rules
- Voice routes
- Voice routing policies
- PSTN usages
- Outbound translation rules

## EXAMPLES

### EXAMPLE 1
```
Restore-TeamsEV -File C:\Temp\Backup.ZIP
```

Restores the Teams Enterprise Voice Configuration from Backup.ZIP file.

## PARAMETERS

### -File
REQUIRED.
Path to the zip file containing the backed up Teams EV config to restore

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KeepExisting
OPTIONAL.
Will not erase existing Enterprise Voice configuration before restoring.

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

### -OverrideAdminDomain
OPTIONAL: The FQDN your Office365 tenant.
Use if your admin account is not in the same domain as your tenant (ie.
doesn't use a @tenantname.onmicrosoft.com address)

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

### System.File
## OUTPUTS

### None
## NOTES
Version 1.10
Build: Feb 04, 2020

Copyright © 2020  Ken Lasko
klasko@ucdialplans.com
https://www.ucdialplans.com

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Restore-TeamsEV.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Restore-TeamsEV.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_SupportingFunction.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_SupportingFunction]()

