---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# Get-SkypeOnlineConferenceDialInNumbers

## SYNOPSIS
Gathers the audio conference dial-in numbers information for a Skype for Business Online tenant.

## SYNTAX

```
Get-SkypeOnlineConferenceDialInNumbers [-Domain] <String> [<CommonParameters>]
```

## DESCRIPTION
This command uses the tenant's conferencing dial-in number web page to gather a "user-readable" list of
the regions, numbers, and available languages where dial-in conferencing numbers are available.
This web
page can be access at https://dialin.lync.com/DialInOnline/Dialin.aspx?path=\<DOMAIN\> replacing "\<DOMAIN\>"
with the tenant's default domain name (i.e.
contoso.com).

## EXAMPLES

### EXAMPLE 1
```
Get-SkypeOnlineConferenceDialInNumbers -Domain contoso.com
```

Example 1 will gather the conference dial-in numbers for contoso.com based on their conference dial-in number web page.

## PARAMETERS

### -Domain
The Skype for Business Online Tenant domain to gather the conference dial-in numbers.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function was taken 1:1 from SkypeFunctions and remains untested for Teams

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

