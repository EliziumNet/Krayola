---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# New-Line

## SYNOPSIS

Helper factory function that creates Line instance.

## SYNTAX

```powershell
New-Line [[-couplets] <couplet[]>] [<CommonParameters>]
```

## DESCRIPTION

A Line is a wrapper around a collection of couplets.

## EXAMPLES

### Example 1

```powershell
  New-Line -Couplets @(
        $(New-Pair('four', '(Paradise Regained)')),
        $(New-Pair('five', "Submission", $true)),
        $(New-Pair('six', "Sumerland (What Dreams May Come)", $true))
      );
```

Create a line from an array of couplets using New-Pair.

## PARAMETERS

### -couplets

Collection of couplets to create Line with.

```yaml
Type: couplet[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### line

A new line instance.

## NOTES

## RELATED LINKS
