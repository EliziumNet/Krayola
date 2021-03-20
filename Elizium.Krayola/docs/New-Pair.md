---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# New-Pair

## SYNOPSIS

Helper factory function that creates a couplet instance.

## SYNTAX

```powershell
New-Pair [[-couplet] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

A couplet is logically 2 items, but can contain a 3rd element representing
its 'affirmed' status. An couplet that is affirmed is one that can be highlighted
according to the Krayola theme (AFFIRM-COLOURS).

## EXAMPLES

### Example 1

```powershell
New-Pair('six', "Sumerland (What Dreams May Come)", 'True');
```

Create a new 'affirmed' pair.

## PARAMETERS

### -couplet

A 2 or 3 item array representing a key/value pair and optional affirm boolean.

```yaml
Type: String[]
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

### couplet

A new pair instance.

## NOTES

## RELATED LINKS
