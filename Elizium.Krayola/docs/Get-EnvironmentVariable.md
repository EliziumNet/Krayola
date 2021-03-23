---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# Get-EnvironmentVariable

## SYNOPSIS

Wrapper around [System.Environment]::GetEnvironmentVariable to support
unit testing.

## SYNTAX

```powershell
Get-EnvironmentVariable [-Variable] <String> [[-Default] <Object>] [<CommonParameters>]
```

## DESCRIPTION

Retrieve the value of the environment variable specified. Returns
$null if variable is not found.

## PARAMETERS

### -Default

The value returned if the environment variable requested does not exist.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Variable

The name of the environment variable to request.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### System.String

Returns the value of the environment variable requested if it exists, otherwise $null unless the Default parameter has been specified in which case that is returned instead.

## NOTES

## RELATED LINKS
