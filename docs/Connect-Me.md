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
Connect-Me [-AccountId] <String> [-ExchangeOnline] [-OverrideAdminDomain <String>] [-NoFeedback]
 [<CommonParameters>]
```

## DESCRIPTION
One function to connect them all.
  This CmdLet solves the requirement for individual authentication prompts for AzureAD, MicrosoftTeams, SkypeOnline
  (and optionally also to ExchangeOnline) when multiple connections are required.

## EXAMPLES

### EXAMPLE 1
```
Connect-Me [-AccountId] admin@domain.com
```

Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams

### EXAMPLE 2
```
Connect-Me -AccountId admin@domain.com -NoFeedBack
```

Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
  Does not display Session Information Object at the end - This is useful if called by other functions.

### EXAMPLE 3
```
Connect-Me -AccountId admin@domain.com -ExchangeOnline
```

Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
  Also connects to ExchangeOnline

### EXAMPLE 4
```
Connect-Me -AccountId admin@domain.com -OverrideAdminDomain tenantdomain.onmicrosoft.com
```

Creates a session to AzureAD, SkypeOnline (Teams Backend) prompting (once) for a Password for 'admin@domain.com'
  If using the Module MicrosoftTeams, this will also connect you to MicrosoftTeams
  The OverrideAdminDomin is queried from the AzureAd Tenant once the connection has been established.
  If used explicitly, this will use the provided OverrideAdminDomain

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
Only required if managing multiple Tenants or Skype On-Premesis Hybrid configuration uses DNS records.

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
This CmdLet can be used to establish a session to: AzureAD, MicrosoftTeams, SkypeOnline and ExchangeOnline
Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
For AzureAD, no particular role is needed for connection and query.
Get-CmdLets are available without an Admin-role.
For MicrosoftTeams, a Teams Administrator Role is required (ideally Teams Communication or Service Administrator)
For SkypeOnline, the Skype for Business Legacy Administrator Roles is required to connect, a Teams Admin role to action.
Actual administrative capabilities are dependent on actual Office 365 admin role assignments (displayed as output)
Disconnects current sessions (if found) in order to establish a clean new session to each desired service.

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

