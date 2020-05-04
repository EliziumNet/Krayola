
# :rainbow: Krayola

Colourful console writing with PowerShell

## Introduction

Krayola provides the capability to write consistent and colourful PowerShell console applications. The key here is that it produces structured output according to user defined formats. There are 2 main ways of writing output:

1. Provide a collection consisting of text and colour descriptions as key value pairs
2. Provide a collection of key value pairs and a theme containing the colour descriptions

First, there follows a description of the data that needs to be provided to the api, next a full description of the api itself.

## On the fly colour descriptions for key/value pairs

We describe the key/value pair data that needs to be rendered. This is done as a collection of key/value pairs where each part of the pair must contain either 2 or 3 items, in this order:

1. The text to be written (mandatory)
2. The foreground colour of the text (mandatory)
3. The background colour (optional)

So for example, consider the collection of key value pairs:

```powershell
@(@("Artist", "Plastikman"), @("Song", "Marbles"))
```

where the keys are **Artist** and **Song** and the values are **Plastikman** and **Marbles**

Lets say we want to render those values in foreground colours "Red", "Green", "Blue" and "Yellow" respectively (note, no mention yet of any background colours). We would apply those colours to the collection by altering the collection as follows:

```powershell
@(
  @(@("Artist", "Red"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow"))
);
```

We can optionally add background colours to any item, by providing a 3rd entry, eg. if we wanted **Artist** to have a "Black" background colour we would specify:

```powershell
@(
  @(@("Artist", "Red", "Black"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow"))
);
```

## Provide a theme describing how key/value pairs should be rendered

If we didn't want the overhead of specify colours for each individual key and value, we can use a theme instead, which helps us keep the output consistent with less overhead.

So for the same collection of key/value pairs mentioned above, we can just say, we want all our keys in "Red" and the values in "Blue". To do so, we use the collection as is:

```powershell
@(@("Artist", "Plastikman"), @("Song", "Marbles"))
```

and then we pass in a theme parameter to the api (described later), but essentially, we populate the key foreground colour to be "Red" and the value foreground colour to be "Blue". This will be made clearer in the following sections.

## The Theme parameter

This is just a hash table, which must contain the following items:

| KEY-NAME           | TYPE     | DESCRIPTION
| -----------------  | ---------| -----------
| FORMAT             | string   | A string containing a placeholder for the Key and the Value. It represents how the whole key/value pair should be represented. It must contain the KEY-PLACE-HOLDER and VALUE-PLACE-HOLDER strings.
| KEY-PLACE-HOLDER   | string   | The place holder that identifies the Key in the FORMAT string.
| VALUE-PLACE-HOLDER | string   | The place holder that identifies the Value in the FORMAT string.
| KEY-COLOURS        | string[] | Array of 1 or 2 items only, the first is the foreground colour and the optional second value is the background colour, that specifies how Keys are displayed
| VALUE-COLOURS      | string[] | The same as KEY-COLOURS but it applies to Values
| OPEN               | string   | Specifies the leading wrapper around the whole key/value pair collection, typically '('
| CLOSE              | string   | Specifies the tail wrapper around the whole key/value pair collection typically ')'
| SEPARATOR          | string   | Specifies a sequence of characters that separates the Key/Vale pairs, typically ','
| META-COLOURS       | string[] | Meta characters include OPEN, CLOSE, SEPARATOR and any other character in the FORMAT which is not the KEY or VALUE
| MESSAGE-COLOURS    | string[] | An optional message that appears preceding the Key/Value pair collection and this array describes the colours used to write that message.
| MESSAGE-SUFFIX     | string   | Specifies a sequence of characters that separates the MESSAGE (if present) from the Key/Value pair collection.

An example Theme is as follows:

```powershell
$ExampleTheme = @{
  "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
  "KEY-PLACE-HOLDER"   = "<%KEY%>";
  "VALUE-PLACE-HOLDER" = "<%VALUE%>";
  "KEY-COLOURS"        = @("Red");
  "VALUE-COLOURS"      = @("Blue");
  "OPEN"               = "{";
  "CLOSE"              = "}";
  "SEPARATOR"          = " | ";
  "META-COLOURS"       = @("Cyan");
  "MESSAGE-COLOURS"    = @("DarkRed", "White");
  "MESSAGE-SUFFIX"     = " // "
}
```

:warning: Note that the tokens <%KEY%> and <%VALUE%> are also defined inside the FORMAT. You will see an error if the FORMAT does not contain these place holders.

## The Public API

### Write-InColour

This is the function to call to invoke the functionality described in section *"On the fly colour descriptions for key/value pairs"* previously. Each Key/Value pair can have it's own colour description.

The parameters:

* TextSnippets: the collection of text fields with their colour descriptions
* NoNewLine: switch indicating not to render a new line

Example:

```powershell
$line = @(
  @(@("Artist", "Red"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow"))
);

Write-InColour -TextSnippets $line;
```

### Write-RawPairsInColour

This is the raw function to call that applies the same colour specification to all Keys and Values consistently without the use of a Theme object. This function would not usually be called by the client but can be if so required, since there are sensible defaults for most of the parameters.

The parameters (See the Theme parameters table above for their descriptions):

* Pairs
* Format
* KeyPlaceHolder (This MUST be present in Format)
* ValuePlaceHolder (This MUST be present in Format)
* Open
* Close
* Separator
* MetaColours
* Message
* MessageColours
* MessageSuffix

### Write-ThemedColouredPairs

This is the function to call is invoke the functionality describe in section *"Provide a theme describing how key/value pairs should be rendered"*.

The parameters

* Pairs
* Theme
* Message

Eg:

```powershell
$ExampleTheme = @{
  "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
  "KEY-PLACE-HOLDER"   = "<%KEY%>";
  "VALUE-PLACE-HOLDER" = "<%VALUE%>";
  "KEY-COLOURS"        = @("Red");
  "VALUE-COLOURS"      = @("Blue");
  "OPEN"               = "{";
  "CLOSE"              = "}";
  "SEPARATOR"          = " | ";
  "META-COLOURS"       = @("Cyan");
  "MESSAGE-COLOURS"    = @("DarkRed", "White");
  "MESSAGE-SUFFIX"     = " // "
}

$PairsToWrite = @(@("Artist", "Plastikman"), @("Song", "Marbles"))

Write-ThemedColouredPairs -Pairs $PairsToWrite -Theme $ExampleTheme
```

The above would display as follows (actual colours not represented!):

> {'Artist'='Plastikman' | 'Song'='Marbles'}

and with a custom message:

```powershell
Write-ThemedColouredPairs -Pairs $PairsToWrite -Theme $ExampleTheme -Message "Catalogue entry: "
```

> Catalogue entry:  // {'Artist'='Plastikman' | 'Song'='Marbles'}

## Invalid Theme

If an invalid Theme is passed into *Write-ThemedColouredPairs*, (eg, 1 of the elements is missing) then it will revert to using an alternative 'emergency theme'.

Eg

```powershell
$InvalidTheme = @{}
$PairsToWrite = @(@("Artist", "Plastikman"), @("Song", "Marbles"))
Write-ThemedColouredPairs -Pairs $PairsToWrite -Theme $InvalidTheme
```

is displayed as:

> 💩💩💩  💥 ('Artist'='Plastikman'👻 'Song'='Marbles')

## Global pre-defined Themes

The module exports a global variable *$KrayolaThemes* hash-table, which contains some predefined themes. The user can use one of these (currently defined as "EMERGENCY-THEME", "ROUND-THEME", "SQUARE-THEME" and "ANGULAR-THEME"). This list may be added to in the future. *$KrayolaThemes*, is not a read only variable, so if the client requires, they can add their own.

For example:

```powershell
Write-ThemedColouredPairs -Pairs $PairsToWrite -Theme $KrayolaThemes["SQUARE-THEME"]
```

## Helper function Show-ConsoleColours

The module exports a function *Show-ConsoleColours* that simply displays all the available console colours as they are represented in text in the colour they represent. This will aid in defining custom themes. Just invoke the function with no arguments in your PowerShell session.

## Trouble shooting

Owing to the nature of how arrays have been implemented in PowerShell, it very easy to tie yourself up in knots when defining multi dimensional arrays as the $Pairs parameter (to Write-ThemedColouredPairs and Write-RawPairsInColour) or $TextSnippets parameter (to Write-InColour). It's incumbent on you to make appropriate use of @() and comma operators to get the result you intended. In fact, in writing this documentation I actually made this silly mistake that highlights this very issue.

An example I was attempting to illustrate is as follows:

```powershell

$line = @(
  @(@("Artist", "Red"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow"))
)
Write-InColour -TextSnippets $line
```

You run this and you'll see it blow up :bomb: in your face :rage: :

```
Write-Host: /Users/Plastikfan/.local/share/powershell/Modules/Krayola/Public/write-in-colour.ps1:74
Line |
  74 |        Write-Host $snippet[0] -NoNewline -ForegroundColor $snippet[1];
     |                                                           ~~~~~~~~~~~
     | Cannot bind parameter 'ForegroundColor'. Cannot convert value "Plastikman Green" to type "System.ConsoleColor". Error: "Unable to match the identifier name Plastikman Green to a valid enumerator name. Specify one of the following enumerator names
     | and try again: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White"

```

This happened because array elements were incorrectly merged: "Plastikman" and "Green"; there is clearly no such colour as "Plastikman Green"!.

What I actually meant to write was:

```powershell
$line = @(
  @("Artist", "Red"), @("Plastikman", "Green"),
  @("Song", "Blue"), @("Marbles", "Yellow")
)
Write-InColour -TextSnippets $line
```

which actually displays this:

> ArtistPlastikmanSongMarbles

* The important thing you need to remember when using Write-InColour, is that it is not working with Key/Value pairs ($TextSnippets is simply a 2 dimensional array). Its working with a collection of *snippets*, where each snippet is a sub sequence of 2 or 3 items (text, foreground colour & background colour).
* The Pairs parameter passed into Write-PairsInColours is a series of key/value pairs, and since the key and the value is a multiple entry *snippet*, it is a 3 dimensional array.
* However, the Pairs passed into Write-ThemedColouredPairs is a series of Key/Value pairs, where the key and the value are individual strings; but because no colours are passed in, the array is simply 2 dimensional.

If you keep these points in mind, then hopefully you'll avoid getting errors like the one just illustrated.
