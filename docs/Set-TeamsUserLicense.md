---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
schema: 2.0.0
---

# Set-TeamsUserLicense

## SYNOPSIS
Changes the License of an AzureAD Object

## SYNTAX

### Add (Default)
```
Set-TeamsUserLicense [-Identity] <String[]> -Add <String[]> [-UsageLocation <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### RemoveAll
```
Set-TeamsUserLicense [-Identity] <String[]> [-Add <String[]>] [-RemoveAll] [-UsageLocation <String>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Remove
```
Set-TeamsUserLicense [-Identity] <String[]> [-Add <String[]>] -Remove <String[]> [-UsageLocation <String>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds, removes or purges teams related Licenses from an AzureAD Object
Supports all Licenses listed in Get-TeamsLicense
Uses friendly Names for Parameter Values, supports Arrays.
Calls New-AzureAdLicenseObject from this Module in order to run Set-AzureADUserLicense.
This will work with ANY AzureAD Object, not just for Teams, but only Licenses relevant to Teams are covered.
Will verify major Licenses and their exclusivity, but not all.
Verifies whether the Licenses selected are available on the Tenant before executing

## EXAMPLES

### EXAMPLE 1
```
Set-TeamsUserLicense -Identity Name@domain.com -Add MS365E5
```

Applies the Microsoft 365 E5 License (SPE_E5) to Name@domain.com

### EXAMPLE 2
```
Set-TeamsUserLicense -Identity Name@domain.com -Add PhoneSystem
```

Applies the PhoneSystem Add-on License (MCOEV) to Name@domain.com
This requires a main license to be present as PhoneSystem is an add-on license

### EXAMPLE 3
```
Set-TeamsUserLicense -Identity Name@domain.com -Add MS365E3,PhoneSystem
```

Set-TeamsUserLicense -Identity Name@domain.com -Add @('MS365E3','PhoneSystem')
Applies the Microsoft 365 E3 License (SPE_E3) and PhoneSystem Add-on License (MCOEV) to Name@domain.com

### EXAMPLE 4
```
Set-TeamsUserLicense -Identity Name@domain.com -Add O365E5 -Remove SFBOP2
```

Special Case Scenario to replace a specific license with another.
Replaces Skype for Business Online Plan 2 License (MCOSTANDARD) with the Office 365 E5 License (ENTERPRISEPREMIUM).

### EXAMPLE 5
```
Set-TeamsUserLicense -Identity Name@domain.com -Add PhoneSystem_VirtualUser -RemoveAll
```

Special Case Scenario for Resource Accounts to swap licenses for a Phone System VirtualUser License
Replaces all Licenses currently on the User Name@domain.com with the Phone System Virtual User (MCOEV_VIRTUALUSER) License

### EXAMPLE 6
```
Set-TeamsUserLicense -Identity Name@domain.com -Remove PhoneSystem
```

Removes the Phone System License from the Object.

### EXAMPLE 7
```
Set-TeamsUserLicense -Identity Name@domain.com -RemoveAll
```

Removes all licenses the Object is currently provisioned for!

## PARAMETERS

### -Identity
Required.
UserPrincipalName of the Object to be manipulated

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UPN, UserPrincipalName, Username

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Add
Optional.
Licenses to be added (main function)
Accepted Values can be retrieved with Get-TeamsLicense (Column ParameterName)

```yaml
Type: String[]
Parameter Sets: Add
Aliases: License, AddLicense, AddLicenses

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: RemoveAll, Remove
Aliases: License, AddLicense, AddLicenses

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
Optional.
Licenses to be removed (alternative function)
Accepted Values can be retrieved with Get-TeamsLicense (Column ParameterName)

```yaml
Type: String[]
Parameter Sets: Remove
Aliases: RemoveLicense, RemoveLicenses

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveAll
Optional Switch.
Removes all licenses currently assigned (intended for replacements)

```yaml
Type: SwitchParameter
Parameter Sets: RemoveAll
Aliases: RemoveAllLicenses

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsageLocation
Optional String.
ISO3166-Alpha2 CountryCode indicating the Country for the User.
Required for Licensing
If required, the script will try to apply the UsageLocation (pending right).
If not provided, defaults to 'US'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: US
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Optional.
Displays User License Object after action.

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

## OUTPUTS

### System.Void
## NOTES
Many license packages are available, the following Licenses are most predominant:
# Main License Packages
- Microsoft 365 E5 License - Microsoft365E5 (SPE_E5)
- Microsoft 365 E3 License - Microsoft365E3 (SPE_E3)  #NOTE: For Teams EV this requires PhoneSystem as an add-on!
- Office 365 E5 License - Microsoft365E5 (ENTERPRISEPREMIUM)
- Office 365 E5 without Audio Conferencing License - Microsoft365E5noAudioConferencing (ENTERPRISEPREMIUM_NOPSTNCONF)  #NOTE: For Teams EV this requires AudioConferencing and PhoneSystem as an add-on!
- Office 365 E3 License - Microsoft365E3 (ENTERPRISEPACK) #NOTE: For Teams EV this requires PhoneSystem as an add-on!
- Skype for Business Online (Plan 2) (MCOSTANDARD)   #NOTE: For Teams EV this requires PhoneSystem as an add-on!

# Add-On Licenses (Require Main License Package from above)
- Audio Conferencing License - AudioConferencing (MCOMEETADV)
- Phone System - PhoneSystem (MCOEV)

# Standalone Licenses (Special)
- Common Area Phone License (MCOCAP)  #NOTE: Cheaper, but limits the Object to a Common Area Phone (no mailbox)
- Phone System Virtual User License (PHONESYSTEM_VIRTUALUSER)  #NOTE: Only use for Resource Accounts!

# Microsoft Calling Plan Licenses
- Domestic Calling Plan - DomesticCallingPlan (MCOPSTN1)
- Domestic and International Calling Plan - InternationalCallingPlan (MCOPSTN2)

# Data in Get-TeamsLicense as per Microsoft Docs Article: Published Service Plan IDs for Licensing
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference#service-plans-that-cannot-be-assigned-at-the-same-time

## RELATED LINKS

[Get-TeamsTenantLicense
Get-TeamsUserLicense
Set-TeamsUserLicense
Test-TeamsUserLicense
Add-TeamsUserLicense (deprecated)
Get-TeamsLicense
Get-TeamsLicenseServicePlan
Get-AzureAdLicense
Get-AzureAdLicenseServicePlan]()

