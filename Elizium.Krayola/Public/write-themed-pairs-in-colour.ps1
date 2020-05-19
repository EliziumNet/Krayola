
[int]$MandatoryNoOfThemeEntries = 11;

function Write-ThemedPairsInColour {
  <#
    .NAME
      Write-ThemedPairsInColour

    .SYNOPSIS
      Writes a collection of key/value pairs in colour according to a specified Theme.

    .DESCRIPTION
      The Pairs defined here are colour-less, instead colours coming from the KEY-COLOURS
      and VALUE-COLOURS in the theme. The implications of this are firstly, the Pairs are
      simpler to specify. However, the colour representation is more restricted, becauuse
      all Keys displayed must be of the same colour and the same goes for the values.

      When using Write-RawPairsInColour directly, the user has to specify each element of a
      pair with 2 or 3 items; text, foreground colour & background colour, eg:

        @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow"))

      Now, each pair is specified as a simply a pair of strings:
        @("Sport", "Tennis")

      The purpose of this function is to generate a single call to Write-RawPairsInColour in
      the form:

      $PairsToWriteInColour = @(
        @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
        @(@("Star", "Green"), @("Martina Hingis", "Cyan"))
      );
      Write-RawPairsInColour -Message ">>> Greetings" -MessageColours @("Magenta") `
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
  [Alias("Write-ThemedPairsInColor")]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "")]
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

  function isThemeValid {
    param(
      [System.Collections.Hashtable]$themeToValidate
    )

    return ($themeToValidate -and ($themeToValidate.Count -eq $MandatoryNoOfThemeEntries))
  }

  if (-not(isThemeValid($Theme))) {
    $Theme = $KrayolaThemes["EMERGENCY-THEME"];

    # Incase the user has compromised the EMERGENCY theme, which should be modifyable (because we
    # can't be sure that the emergency theme we have defined is suitable for their console),
    # we'll use this internal emergency theme ...
    #
    if (-not(isThemeValid($Theme))) {
      $Theme = @{
        "FORMAT"             = "{{<%KEY%>}}={{<%VALUE%>}}";
        "KEY-PLACE-HOLDER"   = "<%KEY%>";
        "VALUE-PLACE-HOLDER" = "<%VALUE%>";
        "KEY-COLOURS"        = @("White");
        "VALUE-COLOURS"      = @("DarkGray");
        "OPEN"               = "{";
        "CLOSE"              = "}";
        "SEPARATOR"          = "; ";
        "META-COLOURS"       = @("Black");
        "MESSAGE-COLOURS"    = @("Gray");
        "MESSAGE-SUFFIX"     = "  ֎ "
      }
    }

    $inEmergency = $true;
  }

  [string[][][]] $pairsToWriteInColour = @();

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
    $pairsToWriteInColour += $transformedPair;
  }

  [System.Collections.Hashtable]$parameters = @{
    'Pairs'            = $pairsToWriteInColour;
    'Format'           = $Theme["FORMAT"];
    'KeyPlaceHolder'   = $Theme["KEY-PLACE-HOLDER"];
    'ValuePlaceHolder' = $Theme["VALUE-PLACE-HOLDER"];
    'Open'             = $Theme["OPEN"];
    'Close'            = $Theme["CLOSE"];
    'Separator'        = $Theme["SEPARATOR"];
    'MetaColours'      = $Theme["META-COLOURS"];
  }

  [string]$expression = 'Write-RawPairsInColour -Pairs $pairsToWriteInColour `
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
      $Message = 'ϞϞϞ ';
      $messageExpression = ' -Message $Message -MessageColours $Theme["MESSAGE-COLOURS"] -MessageSuffix $Theme["MESSAGE-SUFFIX"]';
    }
  }
  else {
    if ($inEmergency) {
      $Message = 'ϞϞϞ ' + $Message;
    }
    $messageExpression = ' -Message $Message -MessageColours $Theme["MESSAGE-COLOURS"] -MessageSuffix $Theme["MESSAGE-SUFFIX"]';
  }

  if (-not([String]::IsNullOrEmpty($messageExpression))) {
    $expression += $messageExpression;

    $parameters['Message'] = $Message;
    $parameters['MessageColours'] = $Theme["MESSAGE-COLOURS"];
    $parameters['MessageSuffix'] = $Theme["MESSAGE-SUFFIX"];
  }

  & "Write-RawPairsInColour" @parameters;
}
