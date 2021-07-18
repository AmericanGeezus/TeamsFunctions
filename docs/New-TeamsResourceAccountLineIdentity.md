---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccountLineIdentity.md
schema: 2.0.0
---

# New-TeamsResourceAccountLineIdentity

## SYNOPSIS
Creates a new Calling Line Identity for a Resource Account

## SYNTAX

```
New-TeamsResourceAccountLineIdentity [-UserPrincipalName] <String> [-BlockIncomingPstnCallerID]
 [-EnableUserOverride] [-CompanyName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a CsCallingLineIdentity Object for the Phone Number assigned to a Resource Account

## EXAMPLES

### EXAMPLE 1
```
New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com
```

Creates a new Line Identity for the Resource Account provided.

### EXAMPLE 2
```
New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -BlockIncomingPstnCallerID
```

Creates a new Line Identity for the Resource Account provided and suppresses the inbound Caller ID

### EXAMPLE 3
```
New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -EnableUserOverride
```

Creates a new Line Identity for the Resource Account provided and allows the User to choose which Caller ID to display

### EXAMPLE 4
```
New-TeamsResourceAccountLineIdentity -Identity ResourceAccount@domain.com -CompanyName "Contoso Domain Services"
```

Creates a new Line Identity for the Resource Account provided and sets the outbound display name to 'Contoso Domain Services'

## PARAMETERS

### -UserPrincipalName
Required.
Identifies the Resource Account for which the Line Identity is being created

```yaml
Type: String
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -BlockIncomingPstnCallerID
Blocks incoming PSTN Caller ID for inbound calls to the Call Queue or Auto Attendant

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

### -EnableUserOverride
Allows the User to choose the Caller Line Id before placing the call.

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

### -CompanyName
Sets the Company Name displayed for outbound calls.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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
The Calling Line Identity is created with New-CsCallingLineIdentity.
The Parameters Identity, Description and
CallingIDSubstitute are populated by the Resource Account data
Identity is populated with the UPN of the Resource Account
Description is "CLI for RA: " plus the Display Name of the Resource Account
CallingIDSubstitute is "Resource".

$ObjId = (Get-CsOnlineApplicationInstance -Identity dkcq@contoso.com).ObjectId
New-CsCallingLineIdentity  -Identity DKCQ -CallingIDSubstitute Resource -EnableUserOverride $false -ResourceAccount $ObjId -CompanyName "Contoso"
https://docs.microsoft.com/en-us/powershell/module/skype/new-cscallinglineidentity?view=skype-ps

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccountLineIdentity.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/New-TeamsResourceAccountLineIdentity.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsFunctions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

