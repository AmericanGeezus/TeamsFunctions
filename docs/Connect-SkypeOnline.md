---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Connect-SkypeOnline

## SYNOPSIS
Creates a remote PowerShell session to Teams (SkypeOnline)

## SYNTAX

```
Connect-SkypeOnline [[-AccountId] <String>] [[-OverrideAdminDomain] <String>] [[-IdleTimeout] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
The Connect-SkypeOnline cmdlet connects an account to use for Microsoft Teams (SkypeOnline) cmdlet requests.
Establishing a remote PowerShell session to Microsoft Teams (SkypeOnline)
A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect and execute GET-commands.
To execute other commands against Teams, a Teams Admin roles with appropriate rights is required.

## EXAMPLES

### EXAMPLE 1
```
Connect-SkypeOnline
```

Prompt for the Username and password of an administrator with permissions to connect to Microsoft Teams (SkypeOnline).
  Additional prompts for Multi Factor Authentication are displayed as required

### EXAMPLE 2
```
Connect-SkypeOnline -AccountId admin@contoso.com
```

When using the Module SkypeOnlineConnector, will pre-fill the authentication prompt with admin@contoso.com
  and only ask for the password for the account to connect out to Microsoft Teams (SkypeOnline).
  When using the Module MicrosoftTeams, the Username cannot be passed on and has to be entered manually.
  The OverrideAdminDomain is not provided, so it is constructed from the domain part.
Please see Notes for details.
  Additional prompts for Multi Factor Authentication are displayed as required.

### EXAMPLE 3
```
Connect-SkypeOnline -AccountId admin@contoso.com -OverrideAdminDomain contoso.onmicrosoft.com
```

When using the Module SkypeOnlineConnector, will pre-fill the authentication prompt with admin@contoso.com
  and only ask for the password for the account to connect out to Microsoft Teams (SkypeOnline).
  When using the Module MicrosoftTeams, the Username cannot be passed on and has to be entered manually.
  The provided OverrideAdminDomain will be used to establish the connection.
If not provided, it is constructed.

## PARAMETERS

### -AccountId
Optional String.
The Username or sign-in address to use when making the remote PowerShell session connection.
  If the AccountId is provided, the OverrideAdminDomain is constructed from the domain part of the AccountId.
  Please see Notes for a detailed example

```yaml
Type: String
Parameter Sets: (All)
Aliases: Username

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverrideAdminDomain
Optional.
Only required if managing multiple Tenants or Skype On-Premesis Hybrid configuration uses DNS records.
If a Session to AzureAd exists, the TenantDomain will be used as the OverrideAdminDomain.
Please see notes for details

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

### -IdleTimeout
Optional.
Defines the IdleTimeout of the session in full hours between 1 and 8.
Default is 4 hrs.
  By default, creating a session with New-CsOnlineSession results in a Timeout of 15mins!
  Please note that this setting could not be verified working.
SessionOptions seem to be ignored by the CmdLet.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 4
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
Connection to SkypeOnline is done by creating a Session with New-CsOnlineSession, which later needs to be imported.
A temporary Module "tmp_*" will be loaded, importing all CmdLets to administer the Teams Tenant (i.E.
SkypeOnline)

New-CsOnlineSession is available in the Module MicrosoftTeams or the MSI-Installer SkypeOnlineConnector which is
now deprecated and no longer actively supported.
This CmdLet uses the Command from the Module MicrosoftTeams,
which always establishes a connection to both Teams and SkypeOnline!

Background:
In order to retire the SkypeOnlineConnector, the CmdLet New-CsOnlineSession was ported to MicrosoftTeams (in v1.1.6)
However, not all functionality was made available:
The Parameter Username has been retired, resulting in seamless single-sign-on currently not being available.
Multiple connection prompts will be displayed, but already signed-in accounts can be used (Password required only once)
Enable-CsOnlineSessionForReconnection is not available in MicrosoftTeams either, but thanks to the original author
Andrés Gorzelany, the command is now offered with this module and is available consistently.
Established Sessions will now always be enabled for reconnection.
The ability to reconnect a session depends on the settings in the Tenant.
Re-Authentication may be required.

OverrideAdminDomain Handling and Example:
AccountId John@domain.com -
If a Session to AzureAd is already established, the TenantDomain from Get-AzureAdCurrentSessionInfo is used.
If no Session to AzureAd exists, 'Domain.com' is tried first as the OverrideAdminDomain
If unsuccessful, 'domain.onmicrosoft.com' is tried.
If this too is unsuccessful, the OverrideAdminDomain is queried from the User for input.

Session Timeout & Reconnection:
The session timeout is currently not adhered to correctly and does not work as intended!
It has therefore been disabled.
The parameter IdleTimeout is without effect.

To help reconnect sessions, Assert-SkypeOnlineConnection is integrated into every CmdLet in the module.
It can be triggered manually as well, with the alias 'pol' (Ping-of-life) to trigger the reconnection.
This will require re-authentication and its success is dependent on the Tenant settings.
Sometimes even the reconnection fails, if so, please disconnect the current session (Disconnect-SkypeOnline) and
re-run Connect-SkypeOnline to recreate the session cleanly.
Please note that hanging sessions can cause lockout (session exhaustion)

This CmdLet is preforming the following Tasks:
- Prompting for Username and password to establish the session
- Prompting for MFA if required
- Prompting for OverrideAdminDomain ONLY if connection fails to establish (connection attempt is retried afterwards)

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsSession]()

[Connect-Me]()

[Connect-SkypeOnline]()

[Connect-AzureAD]()

[Connect-MicrosoftTeams]()

[Assert-SkypeOnlineConnection]()

[Disconnect-Me]()

[Disconnect-SkypeOnline]()

[Disconnect-AzureAD]()

[Disconnect-MicrosoftTeams]()

