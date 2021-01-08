---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# New-TeamsResourceAccount

## SYNOPSIS
Creates a new Resource Account

## SYNTAX

```
New-TeamsResourceAccount [-UserPrincipalName] <String> [-DisplayName <String>] -ApplicationType <String>
 -UsageLocation <String> [-License <String>] [-PhoneNumber <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Teams Call Queues and Auto Attendants require a resource account.
It can carry a license and optionally also a phone number.
This Function was designed to create the ApplicationInstance in AD,
apply a UsageLocation to the corresponding AzureAD User,
license the User and subsequently apply a phone number, all with one Command.

## EXAMPLES

### EXAMPLE 1
```
New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -ApplicationType CallQueue -UsageLocation US
```

Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
DisplayName will be taken from the User PrincipalName and normalised to "ResourceAccount"

### EXAMPLE 2
```
New-TeamsResourceAccount -UserPrincipalName "Resource Account@TenantName.onmicrosoft.com" -Displayname "My {ResourceAccount}" -ApplicationType CallQueue -UsageLocation US
```

Will create a ResourceAccount of the type CallQueue with a Usage Location for 'US'
User Principal Name will be normalised to: ResourceAccount@TenantName.onmicrosoft.com
DisplayName will be normalised to "My ResourceAccount"

### EXAMPLE 3
```
New-TeamsResourceAccount -UserPrincipalName AA-Mainline@TenantName.onmicrosoft.com -Displayname "Mainline" -ApplicationType AutoAttendant -UsageLocation US -License PhoneSystem -PhoneNumber +1555123456
```

Creates a Resource Account for Auto Attendants with a Usage Location for 'US'
Applies the specified PhoneSystem License (if available in the Tenant)
Assigns the Telephone Number if object could be licensed correctly.

## PARAMETERS

### -UserPrincipalName
Required.
The UPN for the new ResourceAccount.
Invalid characters are stripped from the provided string

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
Required.
CallQueue or AutoAttendant.
Determines the association the account can have:
A resource Account of the type "CallQueue" can only be associated with to a Call Queue
A resource Account of the type "AutoAttendant" can only be associated with an Auto Attendant
NOTE: The type can be switched later, though this is not recommended.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Type

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsageLocation
Required.
Two Digit Country Code of the Location of the entity.
Should correspond to the Phone Number.
Before a License can be assigned, the account needs a Usage Location populated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -License
Optional.
Specifies the License to be assigned: PhoneSystem or PhoneSystem_VirtualUser
If not provided, will default to PhoneSystem_VirtualUser
Unlicensed Objects can exist, but cannot be assigned a phone number
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
Optional.
Adds a Microsoft or Direct Routing Number to the Resource Account.
Requires the Resource Account to be licensed (License Switch)
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
Execution requires User Admin Role in Azure AD

## RELATED LINKS

[Get-TeamsResourceAccountAssociation
New-TeamsResourceAccountAssociation
Remove-TeamsResourceAccountAssociation
New-TeamsResourceAccount
Get-TeamsResourceAccount
Find-TeamsResourceAccount
Set-TeamsResourceAccount
Remove-TeamsResourceAccount]()

