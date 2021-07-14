---
external help file: Elizium.Krayola-help.xml
Module Name: Elizium.Krayola
online version:
schema: 2.0.0
---

# New-Krayon

## SYNOPSIS

Helper factory function that creates Krayon instance.

## SYNTAX

```powershell
New-Krayon [[-Theme] <Hashtable>] [[-Expression] <Regex>] [[-WriterFormatWithArg] <String>]
 [[-WriterFormat] <String>] [[-NativeExpression] <String>] [<CommonParameters>]
```

## DESCRIPTION

The client can specify a custom regular expression and corresponding
formatters which together support the scribble functionality (the ability
to invoke krayon functions via a 'structured' string as opposed to calling
the methods explicitly). Normally, the client can accept the default
expression and formatter arguments. However, depending on circumstance,
a custom pattern can be supplied along with corresponding formatters. The
formatters specified MUST correspond to the pattern and if they don't, then
an exception is thrown.
The default tokens used are as follows:

* lead: 'µ'
* open: '«'
* close: '»'

So this means that to invoke the 'red' function on the Krayon, the client
should invoke the Scribble function with the following 'structured' string:

'µ«red»'.

To invoke a command which requires a parameter eg 'Message', the client needs
to specify a string like: 'µ«Message,Greetings Earthlings»'. (NB: instructions
are case insensitive). (Please note, that custom regular expressions do not have
to have 'lead', 'open' and 'close' tokens as illustrated here; these are just
what are used by default. The client can define any expression with formatters
as long as it able to capture method calls with a single optional parameter.)

However, please do not specify a literal string like this. If scribble functionality
is required, then the Scribbler object should be used. The scribbler
contains helper functions 'Snippets' and 'WithArgSnippet'.
'Snippets', which when given an array of instructions will return the correct
structured string. So to 'Reset', set the foreground colour to red and the
background colour to black:

$scribbler.Snippets(@('Reset', 'red', 'black'));

which would return 'µ«Reset»µ«red»µ«black»'.

And 'WithArgSnippet' for the above Message example, the client should use the following:

[string]$snippet = $scribbler.WithArgSnippet('Message', 'Greetings Earthlings');

$scribbler.Scribble($snippet);

This is so that if for any reason, the expression and corresponding formatters
need to be changed, then no other client code would be affected.

And for completeness, an invoke requiring compound param representation eg to invoke
the 'Line' method would be defined as:

'one,Eve of Destruction;two,Bango' => this is a line with 2 couplets
which would be invoked like so:

[string]$snippet = $scribbler.WithArgSnippet('one,Eve of Destruction;two,Bango');

and to Invoke 'Line' with a message:

'Greetings Earthlings;one,Eve of Destruction;two,Bango'

if you look at the first segment, you will see that it contains no comma. The scribbler
will interpret the first segment as a message with subsequent segments containing
valid comma separated values, split by semi-colons.

And if the message required, includes a comma, then it should be escaped with a
back slash '\':

'Greetings\, Earthlings;one,Eve of Destruction;two,Bango'.

## PARAMETERS

### -Expression

A custom regular expression pattern that can capture a Krayon method call and an optional
parameter. The expression MUST contain the following 2 named capture groups:

* 'method': string to represent a method call on the Krayon instance.
* 'p': optional string to represent a parameter passed into the function denoted by 'method'.

Instructions can either have 0 or 1 argument. When an argument is specified that must represent
a compound value (multiple items), then a compound representation must be used,
eg a couplet is represented by a comma separated string and a line is represented
by a semi-colon separated value, where the value inside each semi-colon segment is
a pair represented by a comma separated value.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NativeExpression

A custom regular expression pattern that recognises the content interpreted by the Krayon Scribble
method. The pattern 'inverse' parses a structured string and returns the core text stripped
of any method tokens.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Theme

A hashtable instance containing the Krayola theme.

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

### -WriterFormat

Format string that represents a Krayon method call without an argument. This format needs to conform
to the regular expression pattern specified by Expression.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WriterFormatWithArg

  Format string that represents a Krayon method call with an argument. This format needs to conform
to the regular expression pattern specified by Expression. This format must accommodate a single parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

A new krayon instance.

## NOTES

## RELATED LINKS
