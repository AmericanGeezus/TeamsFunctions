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
The Connect-SkypeOnline cmdlet connects an authenticated account to use for Microsoft Teams (SkypeOnline) cmdlet requests.
Establishing a remote PowerShell session to Microsoft Teams (SkypeOnline)
A SkypeOnline Session requires the SkypeForBusiness Legacy Admin role to connect
To execute commands against Teams, one of the Teams Admin roles is required.

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

If supported, will pre-fill the authentication prompt with admin@contoso.com and only ask for the password for the account
  to connect out to Microsoft Teams (SkypeOnline).
Additional prompts for Multi Factor Authentication are displayed as required.

## PARAMETERS

### -AccountId
Optional String.
The Username or sign-in address to use when making the remote PowerShell session connection.

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
Only used if managing multiple Tenants or SkypeOnPrem Hybrid configuration uses DNS records.

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
Note, by default, creating a session with New-CsOnlineSession results in a Timeout of 15mins!

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

## OUTPUTS

## NOTES
Requires that the Module Microoft Teams (v1.1.6) or Skype Online Connector PowerShell module (v7.0.0.0 or higher) to be installed.
If the SkypeOnlineConnector is used, the Username can be passed to along and the Session can be reconnected (Enable-CsOnlineSessionForReconnection is run).
The following Tasks are preformed by this cmdlet:
- Verifying Module MicrosoftTeams or SkypeOnlineConnector are installed and imported
- Prompting for Username and password to establish the session
- Prompting for MFA if required
- Prompting for OverrideAdminDomain if connection fails to establish and retries connection attempt
- Extending the session time-out limit beyond 60mins (SkypeOnlineConnector only!)

Download v7 here: https://www.microsoft.com/download/details.aspx?id=39366
The SkypeOnline Session allows you to administer SkypeOnline and Teams respectively.
Note: A separate connection to MicrosoftTeams must be established when using SkypeOnlineConnector.

To manage Teams, Channels, etc.
within Microsoft Teams, use Connect-MicrosoftTeams
Connect-MicrosoftTeams requires a Teams Admin role and is part of the PowerShell Module MicrosoftTeams
https://www.powershellgallery.com/packages/MicrosoftTeams

Please note, that the session timeout is broken and does currently not work as intended
To help reconnect sessions, Assert-SkypeOnlineConnection can be used (Alias: pol) which runs Get-CsTenant to trigger the reconnect
This will require re-authentication and its success is dependent on the Tenant settings.
To reconnect fully, please re-run Connect-SkypeOnline to recreate the session cleanly.
Please note that hanging sessions can cause lockout (session exhaustion)

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[Connect-Me]()

[Connect-SkypeOnline]()

[Connect-AzureAD]()

[Connect-MicrosoftTeams]()

[Assert-SkypeOnlineConnection]()

[Disconnect-Me]()

[Disconnect-SkypeOnline]()

[Disconnect-AzureAD]()

[Disconnect-MicrosoftTeams]()

