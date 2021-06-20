---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsCallableEntity.md
schema: 2.0.0
---

# Assert-TeamsCallableEntity

## SYNOPSIS
Verifies User is ready for Voice Config

## SYNTAX

```
Assert-TeamsCallableEntity [-Identity] <String> [-Terminate] [<CommonParameters>]
```

## DESCRIPTION
Tests whether a the Object can be used as a Callable Entity in Call Queues or Auto Attendant

## EXAMPLES

### EXAMPLE 1
```
Assert-TeamsCallableEntity -Identity Jane@domain.com
```

Verifies Jane has a valid PhoneSystem License (Provisioning Status: Success) and is enabled for Enterprise Voice
Enables Jane for Enterprise Voice if not yet done.

## PARAMETERS

### -Identity
Required.
UserPrincipalName, Group Name or Tel URI

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserPrincipalName, GroupName, TelUri

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Terminate
Optional.
By default, the Command will not throw terminating errors.
Using this switch a terminating error is generated.
Useful for scripting to try/catch and silently treat the received error.

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

### System.String
## OUTPUTS

### Boolean
## NOTES
Returns Boolean Result

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsCallableEntity.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Assert-TeamsCallableEntity.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsAutoAttendant.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_TeamsCallQueue.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_UserManagement.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

[about_UserManagement]()

[about_TeamsAutoAttendant]()

[about_TeamsCallQueue]()

[Assert-TeamsCallableEntity]()

[Find-TeamsCallableEntity]()

[Get-TeamsCallableEntity]()

[New-TeamsCallableEntity]()

