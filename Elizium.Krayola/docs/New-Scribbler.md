---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# New-Scribbler

## SYNOPSIS

Helper factory function that creates a Scribbler instance.

## SYNTAX

```powershell
New-Scribbler [[-Krayon] <Krayon>] [-Test] [-Save] [-Silent] [<CommonParameters>]
```

## DESCRIPTION

Creates a new Scribbler instance with the optional krayon provided.

## PARAMETERS

### -Krayon

The underlying krayon instance that performs real writes to the host.

```yaml
Type: Krayon
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Save

switch to indicate if the Scribbler should record all output which will be
saved to file for future playback.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Silent

switch to force the creation of a Quiet Scribbler. Can not be specified at the
same time as Test (although not currently enforced). Silent overrides Test.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Test

switch to indicate if this is being invoked from a test case, so that the
output can be suppressed if appropriate. By default, the test cases should be
quiet. During development and test stage, the user might want to see actual
output in the test output. The presence of variable 'EliziumTest' in the
environment will enable verbose tests. When invoked by an interactive user in
production environment, the Test flag should not be set. Doing so will suppress
the output depending on the presence 'EliziumTest'. ALL test cases should
specify this Test flag. This also applies to third party users building tests for commands
that use the Scribbler.

```yaml
Type: SwitchParameter
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

### Scribbler

A new Scribbler instance.

## NOTES

## RELATED LINKS
