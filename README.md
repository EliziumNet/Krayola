
# :rainbow: Elizium.Krayola

[![A B](https://img.shields.io/badge/branching-commonflow-informational?style=flat)](https://commonflow.org)
[![A B](https://img.shields.io/badge/merge-rebase-informational?style=flat)](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)
[![A B](https://img.shields.io/github/license/eliziumnet/krayola)](https://github.com/eliziumnet/krayola/blob/master/LICENSE)
[![A B](https://img.shields.io/powershellgallery/p/Elizium.Krayola)](https://www.powershellgallery.com/packages/Elizium.Krayola)

Colourful console writing with PowerShell

:warning: A lot of the documentation here is now out of date, it will be updated in due course and work is currently taking place to produce more comprehensive documentation at github pages. Also, the write in colour functions are now deprecated. The new write functionality is implemented in the Scribbler and Krayon objects; information coming ...

## Table of contents

[Introduction](#Introduction)

+ [Provide a sequence of text snippets each with their own colour descriptions](#Provide-a-sequence-of-text-snippets-each-with-their-own-colour-descriptions)
+ [Provide sequence of colour described key/value pairs](#Provide-sequence-of-colour-described-key/value-pairs)
+ [Provide a theme describing how key/value pairs should be rendered](#Provide-a-theme-describing-how-key/value-pairs-should-be-rendered)

[Using The API](#Using-the-API)

+ [The Theme parameter](#The-Theme-parameter)
  + [The Public API](#The-Public-API)
    + [Write-InColour](#Write-InColour)
    + [Write-RawPairsInColour](#Write-RawPairsInColour)
    + [Write-ThemedPairsInColour](#Write-ThemedPairsInColour)
    + [Helper function Get-IsKrayolaLightTerminal](#Helper-function-Get-IsKrayolaLightTerminal)
    + [Helper function Get-KrayolaTheme](#Helper-function-Get-KrayolaTheme)
    + [Helper function Show-ConsoleColours](#Helper-function-Show-ConsoleColours)

  + [Invalid Theme](#Invalid-Theme)
  + [Global pre-defined Themes](#Global-pre-defined-Themes)

[Trouble shooting](#Trouble-shooting)

+ [Use the correct array dimensions when invoking the writer functions](#Use-the-correct-array-dimensions-when-invoking-the-writer-functions)
+ [A reminder about single item arrays in PowerShell](#A-reminder-about-single-item-arrays-in-PowerShell)
+ [Creating Pairs iteratively using Array.Add()](#Creating-Pairs-iteratively-using-Array.Add())

## Introduction

The module can be installed using the standard **install-module** command:

> PS> install-module -Name Elizium.Krayola

Krayola provides the capability to write consistent and colourful PowerShell console applications. The key here is that it produces structured output according to user defined formats. There are 3 main ways of writing output:

1. [**Provide a sequence of text snippets each with their own colour descriptions**](##Provide-a-sequence-of-text-snippets-each-with-their-own-colour-descriptions) - [*(Write-InColour)*](#Write-InColour)
2. [**Provide sequence of colour described key/value pairs**](#Provide-sequence-of-colour-described-key/value-pairs) - [*(Write-RawPairsInColour)*](#Write-RawPairsInColour)
3. [**Provide a theme describing how key/value pairs should be rendered**](#Provide-a-theme-describing-how-key/value-pairs-should-be-rendered) - [*(Write-ThemedColoursInPairs)*](#Write-ThemedPairsInColour)

First, follows a description of the data that needs to be provided to the api, next a full description of the api itself.

### Provide a sequence of text snippets each with their own colour descriptions

(**api:** *Write-InColour*)

The sequence provided is just a collection of snippets, where each snippet is a sub collection of 2 or 3 items:

 a) The text to be written (mandatory)
 b) The foreground colour of the text (mandatory)
 c) The background colour (optional)

So for example, consider the collection of text snippets that need to be displayed in different colours:

```powershell
@(
  @("Artist"), @("Plastikman"), @("Song"), @("Marbles"), @("Genre"), @("Minimal")
);
```

Lets say we want to render those values in foreground colours "Red", "Green", "Blue", "Yellow", "Black" and "Cyan" respectively (note, no mention yet of any background colours). We would apply those colours to the collection by altering the collection as follows:

```powershell
@(
  @("Artist", "Red"), @("Plastikman", "Green"), @("Song", "Blue"),
  @("Marbles", "Yellow"), @("Genre", "Black"), @("Minimal", "Cyan")
);
```

:warning: Note, that this collection is a 2 dimensional array.

We can optionally add background colours to any item, by providing a 3rd entry, eg. if we wanted **Artist** to have a "Black" background colour we would specify:

```powershell
@(
  @("Artist", "Red", "Black"), @("Plastikman", "Green"), @("Song", "Blue"),
  @("Marbles", "Yellow"), @("Genre", "Black"), @("Minimal", "Cyan")
);
```

### Provide sequence of colour described key/value pairs

(**api:** *Write-RawPairsInColour*)

We describe the key/value pair data that needs to be rendered. This is done as a collection of key/value pairs where each part of the pair must contain the same 2 or 3 items previously described:

1. The text to be written (mandatory)
2. The foreground colour of the text (mandatory)
3. The background colour (optional)

The difference here is that items need to be organised into key/value pairs, as opposed to being a sequence of snippets. So organising the previous example as a list of key value pairs we get this:

```powershell
@(
  @(@("Artist", "Red", "Black"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow")),
  @(@("Genre", "Black"), @("Minimal", "Cyan"))
);
```

where the keys are **Artist**, **Song** and **Genre** and the values are **Plastikman**, **Marbles** and **Minimal**

:warning: Note, that this collection is now a 3 dimensional array, because each top level entry is a key/value pair.

### Provide a theme describing how key/value pairs should be rendered

(**api:** *Write-ThemedColoursInPairs*)

If we didn't want the overhead of specify colours for each individual key and value, we can use a theme instead, which helps us keep the output consistent with less overhead.

So for the same collection of key/value pairs mentioned above, we can just say, we want all our keys in "Red" and the values in "Blue". To do so, we use a collection of key/value pairs without colours:

```powershell
@(
  @(@("Artist"), @("Plastikman")),
  @(@("Song"), @("Marbles")),
  @(@("Genre"), @("Minimal"))
);
```

:warning: Note, that this collection is a 2 dimensional array, because we don't include colour information.

and then we pass in a theme parameter to the api (described later), but essentially, we populate the key foreground colour to be "Red" and the value foreground colour to be "Blue". This will be made clearer in the following sections.

## Using the API

### The Theme parameter

This is just a hash table, which must contain the following items:

| KEY-NAME           | TYPE     | DESCRIPTION
| -----------------  | ---------| -----------
| FORMAT             | string   | A string containing a placeholder for the Key and the Value. It represents how the whole key/value pair should be represented. It must contain the KEY-PLACE-HOLDER and VALUE-PLACE-HOLDER strings.
| KEY-PLACE-HOLDER   | string   | The place holder that identifies the Key in the FORMAT string.
| VALUE-PLACE-HOLDER | string   | The place holder that identifies the Value in the FORMAT string.
| KEY-COLOURS        | string[] | Array of 1 or 2 items only, the first is the foreground colour and the optional second value is the background colour, that specifies how Keys are displayed
| VALUE-COLOURS      | string[] | The same as KEY-COLOURS but it applies to Values
| AFFIRM-COLOURS     | string[] | The highlight colour applied to affirmed Values
| OPEN               | string   | Specifies the leading wrapper around the whole key/value pair collection, typically '('
| CLOSE              | string   | Specifies the tail wrapper around the whole key/value pair collection typically ')'
| SEPARATOR          | string   | Specifies a sequence of characters that separates the Key/Vale pairs, typically ','
| META-COLOURS       | string[] | Meta characters include OPEN, CLOSE, SEPARATOR and any other character in the FORMAT which is not the KEY or VALUE
| MESSAGE-COLOURS    | string[] | The colours that describe the optional message that appears preceding the Key/Value pair collection.
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

### The Public API

#### Write-InColour

This is the function to call to invoke the functionality described in section *"A sequence of text snippets each with their own colour descriptions"* previously. Each Key/Value pair can have it's own colour description.

The parameters:

+ TextSnippets: (a 2 dimensional array) the collection of text fields with their colour descriptions
+ NoNewLine: switch indicating not to render a new line

Example:

```powershell
$line = @(
  @("Artist", "Red"), @("Plastikman", "Green"),
  @("Song", "Blue"), @("Marbles", "Yellow")
)
Write-InColour -TextSnippets $line;
```

which displays this (colour not shown):

> ArtistPlastikmanSongMarbles

#### Write-RawPairsInColour

This is the raw function to call (described in *"A sequence of colour described key/value pairs"*) That requires a colour description to be included with each key *value* and value *value*. This function would not usually be called by the client but can be if so required, since there are sensible defaults for most of the parameters.

The parameters (Most of these are in Theme parameters table above, please see for their descriptions):

+ Pairs: (a 3 dimensional array) representing Key/Value pairs, where each Key and Value are themselves an array of 2 or 3 items (*Text, Foreground Colour, Background Colour*), eg:

```powershell
$line = @(
  @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
  @(@("Star", "Green"), @("Agnieszka Radwanska", "Cyan"))
);

Write-RawPairsInColour $line
```

using other defaulted parameters would display this:

> === [('Sport'='Tennis'), ('Star'='Agnieszka Radwanska')] ===

+ Format
+ KeyPlaceHolder (This MUST be present in Format)
+ ValuePlaceHolder (This MUST be present in Format)
+ Open
+ Close
+ Separator
+ MetaColours
+ Message: (Optional) The textual message to be displayed preceding the Key/Value pair collection
+ MessageColours
+ MessageSuffix

#### Write-ThemedPairsInColour

This is the function to call to invoke the functionality described in section *"Provide a theme describing how key/value pairs should be rendered"*.

The parameters

+ Pairs
+ Theme
+ Message

Eg:

```powershell
$ExampleTheme = @{
  "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
  "KEY-PLACE-HOLDER"   = "<%KEY%>";
  "VALUE-PLACE-HOLDER" = "<%VALUE%>";
  "KEY-COLOURS"        = @("Red");
  "VALUE-COLOURS"      = @("Blue");
  "AFFIRM-COLOURS"     = @("Yellow");
  "OPEN"               = "{";
  "CLOSE"              = "}";
  "SEPARATOR"          = " | ";
  "META-COLOURS"       = @("Cyan");
  "MESSAGE-COLOURS"    = @("DarkRed", "White");
  "MESSAGE-SUFFIX"     = " // "
}

$PairsToWrite = @(@("Artist", "Plastikman"), @("Song", "Marbles"))

Write-ThemedPairsInColour -Pairs $PairsToWrite -Theme $ExampleTheme
```

The above would display as follows:

> {'Artist'='Plastikman' | 'Song'='Marbles'}

and with a custom message:

```powershell
Write-ThemedPairsInColour -Pairs $PairsToWrite -Theme $ExampleTheme -Message "Catalogue entry: "
```

A value can be highlighted by specifying a boolean affirmation value after the
key/value pair. So the 'value' of a pair, eg 'Tennis' of @("Sport", "Tennis") can
be highlighted by the addition of a boolean value: @("Sport", "Tennis", $true),
will result in 'Tennis' being highlighted; written with a different colour
value. This colour value is taken from the 'AFFIRM-COLOURS' entry in the theme. If
the affirmation value is false, eg @("Sport", "Tennis", $false), then the value
'Tennis' will be written as per-normal using the 'VALUE-COLOURS' entry.

> Catalogue entry:  // {'Artist'='Plastikman' | 'Song'='Marbles'}

#### Helper function Get-IsKrayolaLightTerminal

Gets the value of the environment variable *KRAYOLA_LIGHT_TERMINAL* as a boolean.

For use by applications that need to use a Krayola theme that is dependent on whether a light or dark background colour is in effect in the current terminal.

#### Helper function Get-KrayolaTheme

Helper function that makes it easier for client applications to get a Krayola theme from the environment, which is compatible with the terminal colours being used. This helps keep output from different applications consistent.

The parameters:

+ KrayolaThemeName (optional)

If $KrayolaThemeName is specified, then it is used to lookup the theme in the global $KrayolaThemes hash table exposed by the Krayola module. If either the theme specified does not exist or not specified, then a default theme is used. The default theme created should be compatible with the dark/lightness of the background of the terminal currently in use. By default, a dark terminal is assumed and the colours used show up clearly against a dark background. If *KRAYOLA_LIGHT_TERMINAL* is defined as an environment variable (can be set to any string apart from empty string/white space), then the colours chosen show up best against a light background.

#### Helper function Show-ConsoleColours

The module exports a function *Show-ConsoleColours* that simply displays all the available console colours as they are represented in text in the colour they represent. This will aid in defining custom themes. Just invoke the function with no arguments in your PowerShell session.

### Invalid Theme

If an invalid Theme is passed into *Write-ThemedPairsInColour*, (eg, 1 of the elements is missing) then it will revert to using an alternative 'emergency theme'.

Eg

```powershell
$InvalidTheme = @{}
$PairsToWrite = @(@("Sport", "Tennis"), @("Star", "Elena Dementieva"))
Write-ThemedPairsInColour -Pairs $PairsToWrite -Theme $InvalidTheme
```

is displayed as:

> 💩💩💩  💥 ('Sport'='Tennis'👻 'Star'='Elena Dementieva')

### Global pre-defined Themes

The module exports a global variable *$KrayolaThemes* hash-table, which contains some predefined themes. The user can use one of these (currently defined as "EMERGENCY-THEME", "ROUND-THEME", "SQUARE-THEME" and "ANGULAR-THEME"). This list may be added to in the future. *$KrayolaThemes*, is not a read only variable, so if the client requires, they can add their own.

For example:

```powershell
Write-ThemedPairsInColour -Pairs $PairsToWrite -Theme $KrayolaThemes["SQUARE-THEME"]
```

## Trouble shooting

The following a description of some of the pitfalls that I encountered writing this module mainly due to the esoteric implementation of arrays in PowerShell, that I hope can be avoided by others.

### Use the correct array dimensions when invoking the writer functions

Owing to the nature of how arrays have been implemented in PowerShell, it very easy to tie yourself up in knots when defining multi dimensional arrays as the $Pairs parameter (to Write-ThemedPairsInColour and Write-RawPairsInColour) or $TextSnippets parameter (to Write-InColour). It's incumbent on you to make appropriate use of @() and comma operators to get the result you intended. In fact, in writing this documentation I actually made this silly mistake that highlights this very issue.

An example I was attempting to illustrate is as follows:

```powershell

$line = @(
  @(@("Artist", "Red"), @("Plastikman", "Green")),
  @(@("Song", "Blue"), @("Marbles", "Yellow"))
)
Write-InColour -TextSnippets $line
```

You run this and you'll see it blow up :bomb: in your face :rage: :

```powershell
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

+ The important thing you need to remember when using Write-InColour, is that it is not working with Key/Value pairs ($TextSnippets is simply a 2 dimensional array). Its working with a collection of *snippets*, where each snippet is a sub sequence of 2 or 3 items (text, foreground colour & background colour).
+ The Pairs parameter passed into Write-RawPairsInColours is a series of key/value pairs, and since the key and the value are multiple entry *snippets*, Pairs is a 3 dimensional array.
+ However, the Pairs passed into Write-ThemedPairsInColour is a series of Key/Value pairs, where the key and the value are individual strings; but because no colours are passed in, the array is simply 2 dimensional.

If you keep these points in mind, then hopefully you'll avoid getting errors like the one just illustrated.

### A reminder about single item arrays in PowerShell

Taking the following example,

```powershell
$PairsToWrite = @(@("Gotchya", "wot no comma op for a single item array?"));
Write-ThemedPairsInColour -Pairs $PairsToWrite -Theme $SunshineTheme;
```

Assuming that $SunshineTheme is valid theme (which it is), this will blow up at run-time as follows:

> Write-ThemedPairsInColour: Found pair that does not contain 2 items (pair: Gotchya) [!!! Reminder: you need to use the comma op for a single item array]

> Write-ThemedPairsInColour: Found pair that does not contain 2 items (pair: wot no comma op for a single item array?) [!!! Reminder: you need to use the comma op for a single item array]
{'Gotchya' +++ '' | 'wot no comma op for a single item array?' +++ ''}

We can see that an attempt is being made to pass in a single item array into *Write-ThemedPairsInColour*, and PowerShell being the way it is as previously described, flattens out the array, breaking the structure expected by the function.

To preserve the array structure, ie a single item array, we need to use the comma operator as follows:

```powershell
$PairsToWrite = @(, @("Gotchya", "ah, that's much better"));
```

and now this behaves as expected and displays:

> {'Gotchya' +++ 'ah, that's much better'}

### Creating Pairs iteratively using Array.Add()

Remember, this (even though it is the most intuitive way of doing this) won't work on a fixed item array:

```powershell
$PairsToWrite.Add(@("Another", "Item"))
```

will blow up with this error message:

> MethodInvocationException: Exception calling "Add" with "1" argument(s): "Collection was of a fixed size."

To resolve this, one should use the += operator which returns a new array

```powershell
$PairToWrite += , @("Gotchya", "ah, that's much better");
```

*Note the use of the comma op here! If you omit the preceding comma, the array will be appended to with no issue, but the call to Write-ThemedPairsInColour will fail with the same error as previously described.*
