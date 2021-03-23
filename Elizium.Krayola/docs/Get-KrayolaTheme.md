---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# Get-KrayolaTheme

## SYNOPSIS

Helper function that makes it easier for client applications to get a Krayola theme
from the environment, which is compatible with the terminal colours being used.
This helps keep output from different applications consistent.

## SYNTAX

```powershell

Get-KrayolaTheme [[-KrayolaThemeName] <String>] [-Themes <Hashtable>] [-DefaultTheme <Hashtable>]
 [<CommonParameters>]

```

## DESCRIPTION

If $KrayolaThemeName is specified, then it is used to lookup the theme in the global
$KrayolaThemes hash-table exposed by the Krayola module. If either the theme specified
does not exist or not specified, then a default theme is used. The default theme created
should be compatible with the dark/lightness of the background of the terminal currently
in use. By default, a dark terminal is assumed and the colours used show up clearly
against a dark background. If KRAYOLA_LIGHT_TERMINAL is defined as an environment
variable (can be set to any string apart from empty string/white space), then the colours
chosen show up best against a light background. Typically, a user would create their
own custom theme and then populate this into the $KrayolaThemes collection. This should
be done in the user profile so as to become available in all powershell sessions.

## PARAMETERS

### -DefaultTheme

If the request Theme does not exist, then this theme will be used. Generally, does not need to be specified by user as it is itself defaulted.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KrayolaThemeName

The name of the Krayola theme to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Themes

Clients does not need to supply this as its defaulted to the global $KrayolaThemes variable.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Collections.Hashtable

Krayola theme instance.

## NOTES

## RELATED LINKS
