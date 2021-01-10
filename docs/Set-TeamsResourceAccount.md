---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Set-TeamsResourceAccount

## SYNOPSIS
Changes a new Resource Account

## SYNTAX

```
Set-TeamsResourceAccount [-UserPrincipalName] <String> [-DisplayName <String>] [-ApplicationType <String>]
 [-UsageLocation <String>] [-License <String>] [-PhoneNumber <String>] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function allows you to update Resource accounts for Teams Call Queues and Auto Attendants.
It can carry a license and optionally also a phone number.
This Function was designed to service the ApplicationInstance in AD,
the corresponding AzureAD User and its license and enable use of a phone number, all with one Command.

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsResourceAccount -UserPrincipalName ResourceAccount@TenantName.onmicrosoft.com -Displayname "My {ResourceAccount}"
```

Will normalize the Display Name (i.E.
remove special characters), then set it as "My ResourceAccount"

### EXAMPLE 2
```
Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -UsageLocation US
```

Sets the UsageLocation for the Account in AzureAD to US.

### EXAMPLE 3
```
Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -License PhoneSystem_VirtualUser
```

Requires the Account to have a UsageLocation populated.
Applies the License to Resource Account AA-Mainline.
If no license is assigned, will try to assign.
If the license is already applied, no action is taken.
NOTE: Swapping licenses is currently not possible.

### EXAMPLE 4
```
Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber +1555123456
```

Changes the Phone number of the Object.
Will cleanly remove the Phone Number first before reapplying it.
This will only succeed if the object is licensed correctly!

### EXAMPLE 5
```
Set-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -PhoneNumber $Null
```

Removes the Phone number from the Object

### EXAMPLE 6
```
Set-TeamsResourceAccount -UserPrincipalName MyRessourceAccount@TenantName.onmicrosoft.com -ApplicationType AutoAttendant
```

Switches MyResourceAccount to the Type AutoAttendant
NOTE: This is currently untested, errors might occur simply because not all caveats could be captured.
Handle with care!

## PARAMETERS

### -UserPrincipalName
Required.
Identifies the Object being changed

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

### -DisplayName
Optional.
The Name it will show up as in Teams.
Invalid characters are stripped from the provided string

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApplicationType
CallQueue or AutoAttendant.
Determines the association the account can have:
A resource Account of the type "CallQueue" can only be associated with to a Call Queue
A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
NOTE: Though switching the account type is possible, this is currently untested: Handle with Care!

```yaml
Type: String
Parameter Sets: (All)
Aliases: Type

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsageLocation
Two Digit Country Code of the Location of the entity.
Should correspond to the Phone Number.
Before a License can be assigned, the account needs a Usage Location populated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -License
Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
If not provided, will default to PhoneSystem_VirtualUser
Unlicensed Objects can exist, but cannot be assigned a phone number
If a license already exists, it will try to swap the license to the specified one.
NOTE: PhoneSystem is an add-on license and cannot be assigned on its own.
it has therefore been deactivated for now.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PhoneNumber
Changes the Phone Number of the object.
Can either be a Microsoft Number or a Direct Routing Number.
Requires the Resource Account to be licensed correctly
Required format is E.164, starting with a '+' and 10-15 digits long.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Tel, Number, TelephoneNumber

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
By default, no output is generated, PassThru will display the Object changed

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
