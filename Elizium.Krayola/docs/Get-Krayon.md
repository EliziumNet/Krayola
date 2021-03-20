---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# Get-Krayon

## SYNOPSIS

Helper factory function that creates Krayon instance.

## SYNTAX

```powershell
Get-Krayon [[-theme] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Creates a new krayon instance with the optional krayola theme provided. The krayon contains various methods for writing text directly to the console (See online documentation for more information).

## PARAMETERS

### -theme

The Krayola theme to apply to the Krayon.

```yaml
Type: Hashtable
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

### Krayon

## NOTES

## RELATED LINKS

[Why should cmdlets not use the Console API?](https://stackoverflow.com/questions/40034278/why-should-cmdlets-not-use-the-console-api)
