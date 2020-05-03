
[int]$MandatoryNoOfThemeEntries = 11;

function Write-ColouredPairs {
  <#
    .NAME
      Write-ColouredPairs

    .SYNOPSIS
      Writes a collection of key/value pairs in colour according to a specified Theme.

    .DESCRIPTION
      The Pairs defined here are colour-less, instead colours coming from the KEY-COLOURS
      and VALUE-COLOURS in the theme. The implications of this are firstly, the Pairs are
      simpler to specify. However, the colour representation is more restricted, becauuse
      all Keys displayed must be of the same colour and the same goes for the values.

      When using Write-PairsInColour directly, the user has to specify each element of a
      pair with 2 or 3 items; text, foreground colour & background colour, eg:

        @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow"))

      Now, each pair is specified as a simply a pair of strings:
        @("Sport", "Tennis")

      The purpose of this function is to generate a single call to Write-PairsInColour in
      the form:

      $PairsToWriteInColour = @(
        @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
        @(@("Star", "Green"), @("Martina Hingis", "Cyan"))
      );
      Write-PairsInColour -Message ">>> Greetings" -MessageColours @("Magenta") `
        -Pairs $PairsToWriteInColour -Format "'<%KEY%>'<--->'<%VALUE%>'" `
        -MetaColours @(,"Blue") -Open " ••• <<" -Close ">> •••"


      You can create your own theme, using this template for assistance:

      $YourTheme = @{
        "FORMAT" = "'<%KEY%>' = '<%VALUE%>'";
        "KEY-PLACE-HOLDER" = "<%KEY%>";
        "VALUE-PLACE-HOLDER" = "<%VALUE%>";
        "KEY-COLOURS" = @("Red");
        "VALUE-COLOURS" = @("Magenta");
        "OPEN" = "(";
        "CLOSE" = ")";
        "SEPARATOR" = ", ";
        "META-COLOURS" = @("Blue");
        "MESSAGE-COLOURS" = @("Green");
        "MESSAGE-SUFFIX" = " // "
      }

    .PARAMETER Pairs
      A 2 dimesional array representing the key/value pairs to be rendered.

    .PARAMETER Theme
      Hastable that must contain all the following fields
      FORMAT
      KEY-PLACE-HOLDER
      VALUE-PLACE-HOLDER
      KEY-COLOURS
      VALUE-COLOURS
      OPEN
      CLOSE
      SEPARATOR
      META-COLOURS
      MESSAGE-COLOURS
      MESSAGE-SUFFIX

    .PARAMETER Message
      An optional message that precedes the display of the Key/Value sequence.
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string[][]]
    $Pairs,

    [Parameter(Mandatory = $true)]
    [System.Collections.Hashtable]
    $Theme,

    [Parameter(Mandatory = $false)]
    [string]
    $Message
  )

  [boolean]$inEmergency = $false;

  if ($Theme.Count -lt $MandatoryNoOfThemeEntries) {
    $Theme = $DefinedThemes["EMERGENCY-THEME"];
    $inEmergency = $true;
  }

  [string[][][]] $PairsToWriteInColour = @();

  # Construct the pairs
  #
  [string[]]$keyColours = $Theme["KEY-COLOURS"];
  [string[]]$valueColours = $Theme["VALUE-COLOURS"];

  foreach ($pair in $Pairs) {
    if ($pair.Length -ne 2) {
      Write-Error -ErrorAction Stop "Found pair that does not contain 2 items (pair: $($pair))";
    }

    [string[]]$transfomedKey = @($pair[0]) + $keyColours;
    [string[]]$transfomedValue = @($pair[1]) + $valueColours;
    $transformedPair = , @($transfomedKey, $transfomedValue);
    $PairsToWriteInColour += $transformedPair;
  }

  [string]$expression = 'Write-PairsInColour -Pairs $PairsToWriteInColour `
    -Format $Theme["FORMAT"] `
    -KeyPlaceHolder $Theme["KEY-PLACE-HOLDER"] `
    -ValuePlaceHolder $Theme["VALUE-PLACE-HOLDER"] `
    -Open $Theme["OPEN"] `
    -Close $Theme["CLOSE"] `
    -Separator $Theme["SEPARATOR"] `
    -MetaColours $Theme["META-COLOURS"]';

  [string]$messageExpression = "";
  # Finally do the invoke
  #
  if ([String]::IsNullOrEmpty($Message)) {
    if ($inEmergency) {
      $Message = '💩💩💩 ';
      $messageExpression = ' -Message $Message -MessageColours $Theme["MESSAGE-COLOURS"] -MessageSuffix $Theme["MESSAGE-SUFFIX"]';
    } 
  }
  else {
    if ($inEmergency) {
      $Message = '💩💩💩 ' + $Message;
    }
    $messageExpression = ' -Message $Message -MessageColours $Theme["MESSAGE-COLOURS"] -MessageSuffix $Theme["MESSAGE-SUFFIX"]';
  }

  if (-not([String]::IsNullOrEmpty($messageExpression))) {
    $expression += $messageExpression;
  }

  Invoke-Expression -Command $expression;
}

Set-Alias -Name Write-ColoredPairs -Value Write-ColouredPairs
