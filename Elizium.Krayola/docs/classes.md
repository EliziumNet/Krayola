
# :rainbow: Elizium.Krayola Classes

## Scribbler :snail: vs Krayon :smiley_cat:

The following tables shows the methods that are defined on both of these classes. The Scribbler is a wrapper around the Krayon, so most of the methods on the Krayon are replicated in the Scribbler.

*Legend*:

+ :heavy_check_mark:: class contains methods
+ :x:: class does not contain those methods
+ :heavy_plus_sign:: the methods defined are fluent (they return the instance so that method calls can be chained together)

### Scribblers

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| Scribble      | :heavy_check_mark:  | :heavy_check_mark: :heavy_plus_sign: |
| ScribbleLn    | :x:                 | :heavy_check_mark: :heavy_plus_sign: |

### Text

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| Text          | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| TextLn        | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Pair

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| Pair          | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| PairLn        | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Line

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| Line          | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| NakedLine     | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Message

| Method Name          | Scribbler           | Krayon             | Link
|----------------------|---------------------|--------------------|--------------------
| Message              | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| MessageLn            | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| MessageNoSuffix      | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| MessageNoSuffixLn    | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Foreground/Background

| Method Name    | Scribbler           | Krayon             | Link
|----------------|---------------------|--------------------|--------------------------
| fore           | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| back           | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| defaultFore    | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| defaultBack    | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| getDefaultFore | :x:                 | :heavy_check_mark: |
| getDefaultBack | :x:                 | :heavy_check_mark: |

### Control

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| End           | :heavy_check_mark: | :heavy_check_mark: |
| Flush         | :heavy_check_mark: | :x:                |
| Ln            | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| Reset         | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| Restart       | :heavy_check_mark: | :x:                |
| Save          | :heavy_check_mark: | :x:                |

### Theme

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| ThemeColour   | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Static Colours

All the static colour methods are of identical form, so for brevity, the following table
only shows the methods for 'blue' and its background counterpart.

| Method Name    | Scribbler           | Krayon             | Link
|----------------|---------------------|--------------------|--------------------------
| blue           | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |
| bgBlue         | :heavy_check_mark: :heavy_plus_sign: | :heavy_check_mark: :heavy_plus_sign: |

### Compounders (CSV/semi-colonSV)

| Method Name   | Scribbler           | Krayon             | Link
|---------------|---------------------|--------------------|---------------------------
| Line          | :x:                 | :heavy_check_mark: :heavy_plus_sign: |
| NakedLine     | :x:                 | :heavy_check_mark: :heavy_plus_sign: |
| Pair          | :x:                 | :heavy_check_mark: :heavy_plus_sign: |
| PairLn        | :x:                 | :heavy_check_mark: :heavy_plus_sign: |

### Utility

| Method Name     | Scribbler           | Krayon             | Link
|-----------------|---------------------|--------------------|---------------------------
| Escape          | :heavy_check_mark:  | :x:                |
| Snippets        | :heavy_check_mark:  | :x:                |
| WithArgSnippet  | :heavy_check_mark:  | :x:                |
| PairSnippet     | :heavy_check_mark:  | :x:                |
| LineSnippet     | :heavy_check_mark:  | :x:                |

## Scribbler Class

Generally, the user should only interact with the Scribbler class, not the Krayon.

### Scribbler Scribble methods

+ scribble

#### Scribbler.Scribble([string]$source)

### Scribbler Text methods

+ Text

#### Scribbler.Text([string]$value)

#### Scribbler.TextLn([string]$value)

### Scribbler Pair methods

+ pair

#### Scribbler.Pair([couplet]$couplet)

#### Scribbler.PairLn([couplet]$couplet)

#### Scribbler.Pair([PSCustomObject]$couplet)

#### Scribbler.PairLn([PSCustomObject]$couplet)

### Scribbler Line methods

+ Line

#### Scribbler.Line([line]$line)

#### Scribbler.NakedLine([line]$nakedLine)

#### Scribbler.Line([string]$message, [line]$line)

#### Scribbler.NakedLine([string]$message, [line]$line)

### Scribbler Message methods

+ Message

#### Scribbler.Message([string]$message)

#### Scribbler.MessageLn([string]$message)

#### Scribbler.MessageNoSuffix([string]$message)

#### Scribbler.MessageNoSuffixLn([string]$message)

### Scribbler Dynamic Colour methods

+ Dynamic

#### Scribbler.fore([string]$colour)

#### Scribbler.back([string]$colour)

#### Scribbler.defaultFore([string]$colour)

#### Scribbler.defaultBack([string]$colour)

### Scribbler Control methods

+ Control

#### Scribbler.End()

#### Scribbler.Flush()

#### Scribbler.Ln()

#### Scribbler.Reset()

#### Scribbler.Restart()

#### Scribbler.Save()

### Scribbler Theme methods

+ Theme

#### Scribbler.ThemeColour([string]$val)

### Scribbler Static Colour methods

+ Static

#### Scribbler.\<Colour\>()

### Scribbler utility methods

+ Utility

#### Scribbler.Escape([string]$value)

#### Scribbler.Snippets ([string[]]$Items)

#### Scribbler.WithArgSnippet([string]$api, [string]$arg)

#### Scribbler.PairSnippet([couplet]$pair)

#### Scribbler.LineSnippet([line]$line)

## Krayon Class

The workhorse that performs the actual writes to the console.

### Krayon Scribble methods

+ scribble

#### Krayon.Scribble([string]$source)

#### Krayon.ScribbleLn([string]$source) Accelerator

### Krayon Text methods

+ Text

#### Krayon.Text([string]$value)

#### Krayon.TextLn([string]$value)

### Krayon Pair methods

+ pair

#### Krayon.Pair([couplet]$couplet)

#### Krayon.PairLn([couplet]$couplet)

#### Krayon.Pair([PSCustomObject]$couplet)

#### Krayon.PairLn([PSCustomObject]$couplet)

### Krayon Line methods

+ Line

#### Krayon.Line([line]$line)

#### Krayon.NakedLine([line]$nakedLine)

#### Krayon.Line([string]$message, [line]$line)

#### Krayon.NakedLine([string]$message, [line]$line)

### Krayon Message methods

+ Message

#### Krayon.Message([string]$message)

#### Krayon.MessageLn([string]$message)

#### Krayon.MessageNoSuffix([string]$message)

#### Krayon.MessageNoSuffixLn([string]$message)

### Krayon Dynamic Colour methods

+ Dynamic

#### Krayon.fore([string]$colour)

#### Krayon.back([string]$colour)

#### Krayon.defaultFore([string]$colour)

#### Krayon.defaultBack([string]$colour)

#### Krayon.getDefaultFore()

#### Krayon.getDefaultBack()

### Krayon Control methods

+ Control

#### Krayon.End()

#### Krayon.Ln()

#### Krayon.Reset()

### Krayon Theme methods

+ Theme

#### Krayon.ThemeColour([string]$val)

### Krayon Static Colour methods

+ Static

#### Krayon.\<Colour\>()

### Krayon Compounders methods

+ Compounder

#### Krayon.Line([string]$semiColonSV)

#### Krayon.NakedLine([string]$semiColonSV)

#### Krayon.[Krayon] Pair([string]$csv)

#### Krayon.[Krayon] PairLn([string]$csv)

### Krayon Utility methods

+ Utility

#### Krayon.Native([string]$structured)
