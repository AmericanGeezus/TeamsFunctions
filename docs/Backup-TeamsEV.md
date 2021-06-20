---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Backup-TeamsEV.md
schema: 2.0.0
---

# Backup-TeamsEV

## SYNOPSIS
A script to automatically back-up a Microsoft Teams Enterprise Voice configuration.

## SYNTAX

```
Backup-TeamsEV [[-OverrideAdminDomain] <String>] [<CommonParameters>]
```

## DESCRIPTION
Automates the backup of Microsoft Teams Enterprise Voice normalization rules, dialplans, voice policies, voice routes, PSTN usages and PSTN GW translation rules for various countries.

## EXAMPLES

### EXAMPLE 1
```
Backup-TeamsEV
```

Takes a backup of the Teams Enterprise Voice Configuration and stores it as a ZIP file with the Tenant Name and Current Date in the current directory.

## PARAMETERS

### -OverrideAdminDomain
OPTIONAL: The FQDN your Office365 tenant.
Use if your admin account is not in the same domain as your tenant (ie.
doesn't use a @tenantname.onmicrosoft.com address)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
### System.String
## OUTPUTS

### System.File
## NOTES
Version 1.10
Build: Feb 04, 2020

Copyright © 2020  Ken Lasko
klasko@ucdialplans.com
https://www.ucdialplans.com

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Backup-TeamsEV.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Backup-TeamsEV.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

