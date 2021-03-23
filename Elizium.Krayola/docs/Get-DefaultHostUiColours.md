---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# Get-DefaultHostUiColours

## SYNOPSIS

Get the default foreground and background colours of the console host.

## SYNTAX

```powershell
Get-DefaultHostUiColours
```

## DESCRIPTION

  Currently there is an open issue [ui.RawUI on result of 'Get-Host' contains ForegroundColor/BackgroundColor set to -1 on macOS](https://github.com/PowerShell/PowerShell/issues/14727)
which means that on a mac, the default colours obtained from the host are both incorrectly
set to -1. This function takes this deficiency into account and will ensure that sensible
colour values are always returned.

## INPUTS

### None

## OUTPUTS

### System.String[]

Returns a 2 item string array, the first is the foreground console colour and the second is the background.

## NOTES

## RELATED LINKS

[ui.RawUI on result of 'Get-Host' contains ForegroundColor/BackgroundColor set to -1 on macOS](https://github.com/PowerShell/PowerShell/issues/14727)
