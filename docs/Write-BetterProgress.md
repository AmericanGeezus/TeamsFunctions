---
external help file: TeamsFunctions-help.xml
Module Name: TeamsFunctions
online version: https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Write-BetterProgress.md
schema: 2.0.0
---

# Write-BetterProgress

## SYNOPSIS
Wrapper for Write-Progress to improve consistency with output

## SYNTAX

```
Write-BetterProgress [-ID] <Int32> [[-ParentId] <Int32>] [-Activity] <String> [-Status] <String>
 [[-CurrentOperation] <String>] [-Step] <Int32> [[-Of] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This function improves upon Write-Progress to display more consistent and meaningful progress bars

## EXAMPLES

### EXAMPLE 1
```
Write-BetterProgress -Id 0 -Activity $MyInvocation.MyCommand -Status "Step $i" -Step $i -of 10
```

Assumes running an a foreach loop of 'foreach ($i in (1..10)) {Write-BetterProgress -Id 0...}'
Displays the Progress for ID 0 - with the activity set to the calling command (useful when used in a Function)

### EXAMPLE 2
```
Write-BetterProgress -Id 1 -Activity "Processing Item #$i" -Status "Step $i - Substep $j" -Step $j -of 10
```

Assumes running an a foreach loop of 'foreach ($j in (1..10)) {Write-BetterProgress -Id 1...}'
Displays the Progress for ID 1 - with the activity set to the calling command (useful when used in a Function)
NOTE: The ParentId is set to 0 automatically (one less than the ID provided, unless Parameter ParentId is used)

### EXAMPLE 3
```
Write-BetterProgress -Id 2 -ParentId 1 -Activity 'Looping through Activities' -CurrentOperation 'Displaying Level 3' -Status "Step $i - Substep $j - iteration $k" -Step $k -of 10
```

Assumes running an a foreach loop of 'foreach ($k in (1..10)) {Write-BetterProgress -Id 2...}'
Displays the Progress for ID 2 - with the Parent ID set to 1 (this is calculated to 1 anyway, but can be overridden)
CurrentOperation is optional and will display another line below if needed for more granularity.

## PARAMETERS

### -ID
Required.
Synonymous with Write-Progress Parameter Id
Id to bind it to.
Could have been omitted, but for consistent input it should be clearly stated.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentId
Optional.
Synonymous with Write-Progress Parameter ParentId
Parent Id to bind it to.
If not provided will be assumed one less than the ID provided.
For Example: Id 2 will result in the Parent ID being calculated as ParentId 1

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Activity
Required.
Synonymous with Write-Progress Parameter Activity
When called in Functions, $MyInvocation.MyCommand is a good activity.
When called in ID higher than 0, the activity should display what is being worked on (Loop item, etc.)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Required.
Synonymous with Write-Progress Parameter Status
Message to display as a Status.
This can be the current operation if this level of granularity is enough

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentOperation
Optional.
Synonymous with Write-Progress Parameter CurrentOperation
Provides more granularity over the Status if required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Step
Required.
Current Step to display progress for
Calculates Write-Progress Parameter PercentComplete with (StepNumber / StepTotal ) * 100

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Of
Required.
Total Steps to calculate from
Calculates Write-Progress Parameter PercentComplete with (StepNumber / StepTotal ) * 100
If not provided or received as 0, will be assumed as 100 to avoid running into errors

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Progress
## NOTES
Inspired by Adam Betrams wonderful take on 'A Better Way to Use Write-Progress'
https://adamtheautomator.com/write-progress/

This wrapper functions supports all parameters except Completed.
Please use the following to cleanly complete your progress bar (swap ID and Activity as required):
Write-Progress -Id 0 -Activity $MyInvocation.MyCommand -Completed

NOTE: Run this BEFORE Write-Output or RETURN commands as some terminals suffer from a bleed-through effect that
super-imposes the Progress over the output: https://github.com/microsoft/vscode/issues/118661

## RELATED LINKS

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Write-BetterProgress.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Write-BetterProgress.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md)

[https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/](https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/)

