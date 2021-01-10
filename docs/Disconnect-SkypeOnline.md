---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Disconnect-SkypeOnline

## SYNOPSIS
Disconnects Sessions established to SkypeOnline

## SYNTAX

```
Disconnect-SkypeOnline [<CommonParameters>]
```

## DESCRIPTION
Disconnects any current Skype for Business Online remote PowerShell sessions and removes any imported modules.
By default Office 365 allows two (!) concurrent sessions per User.
Session exhaustion may occur if sessions hang or incorrectly closed.
Avoid this by cleanly disconnecting the sessions with this function before timeout

## EXAMPLES

### EXAMPLE 1
```
Disconnect-SkypeOnline
```

Removes any current Skype for Business Online remote PowerShell sessions and removes any imported modules.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Helper function to disconnect from SkypeOnline
By default Office 365 allows two (!) concurrent sessions per User.
If sessions hang or are incorrectly closed (not properly disconnected),
this can lead to session exhaustion which results in not being able to connect again.
An admin can sign-out this user from all Sessions through the Office 365 Admin Center
This process may take up to 15 mins and is best avoided, through proper disconnect after use

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

