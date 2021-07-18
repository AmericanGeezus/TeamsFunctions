---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccountLineIdentity.md
schema: 2.0.0
---

# Get-TeamsResourceAccountLineIdentity

## SYNOPSIS
Queries Calling Line Identity Objects for Resource Accounts

## SYNTAX

### RA (Default)
```
Get-TeamsResourceAccountLineIdentity -UserPrincipalName <String[]> [<CommonParameters>]
```

### Id
```
Get-TeamsResourceAccountLineIdentity -Identity <String[]> [<CommonParameters>]
```

### Filter
```
Get-TeamsResourceAccountLineIdentity -Filter <String> [<CommonParameters>]
```

## DESCRIPTION
Get-CsCallingLineIdentity with resolving Resource Account Ids to Names and displaying the underlying Phone Number

## EXAMPLES

### EXAMPLE 1
```
Get-TeamsResourceAccountLineIdentity -UserPrincipalName ResourceAccount@domain.com
```

Queries a Line Identity for the Resource Account provided and displays this Object - Default

### EXAMPLE 2
```
Get-TeamsResourceAccountLineIdentity -Identity 'My Calling Line Identity'
```

Queries a Line Identity with the Name 'My Calling Line Identity'.

### EXAMPLE 3
```
Get-TeamsResourceAccountLineIdentity -Filter '*Calling*'
```

Queries all Line Identities with 'Calling' in the Name.

## PARAMETERS

### -UserPrincipalName
Required.
Identifies the Resource Account for which the Line Identity was created

```yaml
Type: String[]
Parameter Sets: RA
Aliases: ResourceAccount

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Identity
Required - Parameter set CLI.
Identifies the CsCallingLineIdentity to be queried

```yaml
Type: String[]
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Filter String for the Calling Line Identity

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
The Calling Line Identity is created with New-TeamsResourceAccountLineIdentity (or with New-CsCallingLineIdentity).
This CmdLet queries these objects and (provided the CallingIDSubstitute is 'Resource') resolves Resource Account ID
to the Display Name and displays the Resource Accounts Phone Number.
https://docs.microsoft.com/en-us/powershell/module/skype/Get-cscallinglineidentity?view=skype-ps

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccountLineIdentity.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-TeamsResourceAccountLineIdentity.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

