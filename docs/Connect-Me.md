---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Connect-Me

## SYNOPSIS
Connect to AzureAd, Teams and SkypeOnline and optionally also to Exchange

## SYNTAX

```
Connect-Me [-AccountId] <String> [-AzureAD] [-MicrosoftTeams] [-SkypeOnline] [-ExchangeOnline]
 [-OverrideAdminDomain <String>] [-NoFeedback] [<CommonParameters>]
```

## DESCRIPTION
One function to connect them all.
  This function solves the requirement for individual authentication prompts for
  AzureAD and MicrosoftTeams, SkypeOnline (and optionally also to ExchangeOnline) when multiple connections are required.
For AzureAD, no particular role is needed as GET-commands are available without a role.
For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Service Administrator or Teams Communication Admin)
For SkypeOnline, the Skype for Business Legacy Administrator Roles is required
Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
Disconnects current sessions (if found) in order to establish a clean new session to each desired service.
  By default SkypeOnline and AzureAD are selected (without parameters).
  Combine as desired, if Parameters are specified, only connections to these services are established.
  Available: AzureAD, MicrosoftTeams, SkypeOnline and ExchangeOnline
  Without parameters, connections are established to AzureAd and SkypeOnline/MicrosoftTeams

## EXAMPLES

### EXAMPLE 1
```
Connect-Me admin@domain.com
```

Connects to AzureAD and Teams (SkypeOnline) prompting ONCE for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams

### EXAMPLE 2
```
Connect-Me -AccountId admin@domain.com -SkypeOnline -AzureAD -MicrosoftTeams
```

Connects to AzureAD and Teams (SkypeOnline) & MicrosoftTeams prompting ONCE for a Password for 'admin@domain.com'

### EXAMPLE 3
```
Connect-Me -AccountId admin@domain.com -SkypeOnline -ExchangeOnline
```

Connects to Teams (SkypeOnline) and ExchangeOnline prompting ONCE for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams

### EXAMPLE 4
```
Connect-Me -AccountId admin@domain.com -SkypeOnline -OverrideAdminDomain domain.co.uk
```

Connects to Teams (SkypeOnline) prompting ONCE for a Password for 'admin@domain.com' using the explicit OverrideAdminDomain domain.co.uk
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams

## PARAMETERS

### -AccountId
Required.
UserPrincipalName or LoginName of the Office365 Administrator

```yaml
Type: String
Parameter Sets: (All)
Aliases: Username

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AzureAD
Optional.
Connects to Azure Active Directory (AAD).
Requires no Office 365 Admin roles (Read-only access to AzureAD)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: AAD

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MicrosoftTeams
Optional.
Connects to MicrosoftTeams.
Requires Office 365 Admin role for Teams, e.g.
Microsoft Teams Service Administrator

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Teams

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkypeOnline
Optional.
Connects to SkypeOnline.
Requires Office 365 Admin role Skype for Business Legacy Administrator

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: SfBO

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExchangeOnline
Optional.
Connects to Exchange Online Management.
Requires Exchange Admin Role

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Exchange

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverrideAdminDomain
Optional.
Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.
  NOTE: The OverrideAdminDomain is handled by Connect-SkypeOnline (prompts if no connection can be established)
  Using the Parameter here is using it explicitly

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

### -NoFeedback
Optional.
Suppresses output session information about established sessions.
Used for calls by other functions

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The base command (without any )

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Connect-Me]()

[Connect-SkypeOnline]()

[Connect-AzureAD]()

[Connect-MicrosoftTeams]()

[Disconnect-Me]()

[Disconnect-SkypeOnline]()

[Disconnect-AzureAD]()

[Disconnect-MicrosoftTeams]()

