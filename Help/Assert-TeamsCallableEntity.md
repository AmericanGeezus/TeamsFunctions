---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version:
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
UserPrincipalName, Group Name or Tel URI

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

### -Terminate
{{ Fill Terminate Description }}

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

### System.Boolean
## NOTES
Returns Boolean Result

## RELATED LINKS
