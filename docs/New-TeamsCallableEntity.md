---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
schema: 2.0.0
---

# New-TeamsCallableEntity

## SYNOPSIS
Creates a Callable Entity for Auto Attendants

## SYNTAX

```
New-TeamsCallableEntity [-Identity] <String> [-EnableTranscription] [-Type <String>] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Wrapper for New-CsAutoAttendantCallableEntity with verification
Requires a licensed User or ApplicationEndpoint an Office 365 Group or Tel URI

## EXAMPLES

### EXAMPLE 1
```
New-TeamsAutoAttendantEntity -Type ExternalPstn -Identity "tel:+1555123456"
```

Creates a callable Entity for the provided string, normalising it into a Tel URI

### EXAMPLE 2
```
New-TeamsAutoAttendantEntity -Type User -Identity John@domain.com
```

Creates a callable Entity for the User John@domain.com

## PARAMETERS

### -Identity
Required.
Tel URI, Group Name or UserPrincipalName, depending on the Entity Type

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EnableTranscription
Optional.
Enables Transcription.
Available only for Groups (Type SharedVoicemail)

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

### -Type
Optional.
Type of Callable Entity to create.
Expected User, ExternalPstn, SharedVoicemail, ApplicationEndPoint
If not provided, the Type is queried with Get-TeamsCallableEntity

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

### -Force
Suppresses confirmation prompt to enable Users for Enterprise Voice, if required and $Confirm is TRUE

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

### System.Object - Default behaviour
## NOTES
For Users, it will verify the Objects eligibility.
Requires a valid license but can enable the User Object for Enterprise Voice if needed.
For Groups, it will verify that the Group exists in AzureAd (but not in Exchange)
For ExternalPstn it will construct the Tel URI

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[about_TeamsAutoAttendant]()

[about_TeamsCallQueue]()

[Assert-TeamsCallableEntity]()

[Find-TeamsCallableEntity]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

[New-TeamsAutoAttendant]()

[Set-TeamsAutoAttendant]()

[New-TeamsAutoAttendantDialScope]()

[New-TeamsAutoAttendantMenu]()

[New-TeamsAutoAttendantPrompt]()

[New-TeamsAutoAttendantSchedule]()

