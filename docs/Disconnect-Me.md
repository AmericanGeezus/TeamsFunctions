---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Disconnect-Me.md
schema: 2.0.0
---

# Disconnect-Me

## SYNOPSIS
Disconnects all sessions for AzureAD & MicrosoftTeams

## SYNTAX

```
Disconnect-Me [-DisableAdminRoles] [<CommonParameters>]
```

## DESCRIPTION
Helper function to disconnect from AzureAD & MicrosoftTeams
By default Office 365 allows two (!) concurrent sessions per User.
Session exhaustion may occur if sessions hang or incorrectly closed.
Avoid this by cleanly disconnecting the sessions with this function before timeout

## EXAMPLES

### EXAMPLE 1
```
Disconnect-Me
```

Disconnects from AzureAD, MicrosoftTeams
Errors and Warnings are suppressed as no verification of existing sessions is undertaken

## PARAMETERS

### -DisableAdminRoles
Disables activated Admin roles before disconnecting from Azure Ad

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

### None
## OUTPUTS

### System.Void
## NOTES
Helper function to disconnect from AzureAD & MicrosoftTeams
To disconnect from ExchangeOnline, please run Disconnect-ExchangeOnline
By default Office 365 allows two (!) concurrent sessions per User.
If sessions hang or are incorrectly closed (not properly disconnected),
this can lead to session exhaustion which results in not being able to connect again.
An admin can sign-out this user from all Sessions through the Office 365 Admin Center
This process may take up to 15 mins and is best avoided, through proper disconnect after use
An Alias is available for this function: dis

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Disconnect-Me.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Disconnect-Me.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsSession.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_TeamsSession]()

[Connect-Me]()

[Connect-AzureAD]()

[Connect-MicrosoftTeams]()

[Disconnect-Me]()

[Disconnect-AzureAD]()

[Disconnect-MicrosoftTeams]()

