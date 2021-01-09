---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Backup-TeamsTenant

## SYNOPSIS
A script to automatically backup a Microsoft Teams Tenant configuration.

## SYNTAX

```
Backup-TeamsTenant [[-OverrideAdminDomain] <String>] [<CommonParameters>]
```

## DESCRIPTION
Automates the backup of Microsoft Teams.

## EXAMPLES

### EXAMPLE 1
```
Backup-TeamsTenant
```

Takes a backup of the entire Teams Tenant configuration and stores it as a ZIP file with the Tenant Name and Current Date in the current directory.

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

## OUTPUTS

## NOTES
Version 1.10
Build: Feb 04, 2020

Copyright © 2020  Ken Lasko
klasko@ucdialplans.com
https://www.ucdialplans.com

Expanded to cover more elements
David Eberhardt
https://github.com/DEberhardt/
https://davideberhardt.wordpress.com/

14-MAY 2020

The list of command is not dynamic, meaning addded commandlets post publishing date are not captured

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

