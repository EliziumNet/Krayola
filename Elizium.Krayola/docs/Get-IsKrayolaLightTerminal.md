---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# Get-IsKrayolaLightTerminal

## SYNOPSIS

Gets the value of KRAYOLA_LIGHT_TERMINAL as a boolean.

## SYNTAX

```powershell
Get-IsKrayolaLightTerminal
```

## DESCRIPTION

For use by applications that need to use a Krayola theme that is dependent
on whether a light or dark background colour is in effect in the current
terminal.

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Boolean

$true if 'KRAYOLA_LIGHT_TERMINAL' is defined $false otherwise.

## NOTES

## RELATED LINKS

[Feature Request: Clients of terminal need a way to inquire about the capabilities of the terminal](https://github.com/microsoft/terminal/issues/1040)
