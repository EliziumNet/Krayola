
function Write-ThemedPairsInColour {
  <#
    .NAME
      Write-ThemedPairsInColour

    .SYNOPSIS
      Writes a collection of key/value pairs in colour according to a specified Theme.

    .DESCRIPTION
      The Pairs defined here are colour-less, instead colours coming from the KEY-COLOURS
      and VALUE-COLOURS in the theme. The implications of this are firstly, the Pairs are
      simpler to specify. However, the colour representation is more restricted, because
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

      A value can be highlighted by specifying a boolean affirmation value after the
      key/value pair. So the 'value' of a pair, eg 'Tennis' of @("Sport", "Tennis") can
      be highlighted by the addition of a boolean value: @("Sport", "Tennis", $true),
      will result in 'Tennis' being highlighted; written with a different colour
      value. This colour value is taken from the 'AFFIRM-COLOURS' entry in the theme. If
      the affirmation value is false, eg @("Sport", "Tennis", $false), then the value
      'Tennis' will be written as per-normal using the 'VALUE-COLOURS' entry.

      You can create your own theme, using this template for assistance:

      $YourTheme = @{
        "FORMAT" = "'<%KEY%>' = '<%VALUE%>'";
        "KEY-PLACE-HOLDER" = "<%KEY%>";
        "VALUE-PLACE-HOLDER" = "<%VALUE%>";
        "KEY-COLOURS" = @("Red");
        "VALUE-COLOURS" = @("Magenta");
        "AFFIRM-COLOURS" = @("White");
        "OPEN" = "(";
        "CLOSE" = ")";
        "SEPARATOR" = ", ";
        "META-COLOURS" = @("Blue");
        "MESSAGE-COLOURS" = @("Green");
        "MESSAGE-SUFFIX" = " // "
      }

    .PARAMETER Pairs
      A 2 dimensional array representing the key/value pairs to be rendered.

    .PARAMETER Theme
      Hash-table that must contain all the following fields
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
  [Alias('Write-ThemedPairsInColor')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [string[][]]
    $Pairs,

    [Parameter(Mandatory = $true)]
    [System.Collections.Hashtable]
    $Theme,

    [Parameter(Mandatory = $false)]
    [string]
    $Message
  )

  if (0 -eq $Pairs.Length) {
    return;
  }

  [boolean]$inEmergency = $false;

  function isThemeValid {
    param(
      [System.Collections.Hashtable]$themeToValidate
    )

    [int]$minimumNoOfThemeEntries = 11;
    return ($themeToValidate -and ($themeToValidate.Count -ge $minimumNoOfThemeEntries))
  }

  if (-not(isThemeValid($Theme))) {
    $Theme = $KrayolaThemes['EMERGENCY-THEME'];

    # In case the user has compromised the EMERGENCY theme, which should be modify-able (because we
    # can't be sure that the emergency theme we have defined is suitable for their console),
    # we'll use this internal emergency theme ...
    #
    if (-not(isThemeValid($Theme))) {
      $Theme = @{
        'FORMAT'             = '{{<%KEY%>}}={{<%VALUE%>}}';
        'KEY-PLACE-HOLDER'   = '<%KEY%>';
        'VALUE-PLACE-HOLDER' = '<%VALUE%>';
        'KEY-COLOURS'        = @('White');
        'VALUE-COLOURS'      = @('DarkGray');
        'OPEN'               = '{';
        'CLOSE'              = '}';
        'SEPARATOR'          = '; ';
        'META-COLOURS'       = @('Black');
        'MESSAGE-COLOURS'    = @('Gray');
        'MESSAGE-SUFFIX'     = '  ֎ '
      }
    }

    $inEmergency = $true;
  }

  [string[][][]] $pairsToWriteInColour = @();

  # Construct the pairs
  #
  [string[]]$keyColours = $Theme['KEY-COLOURS'];
  [string[]]$valueColours = $Theme['VALUE-COLOURS'];

  foreach ($pair in $Pairs) {
    if (1 -ge $pair.Length) {
      [string[]]$transformedKey = @('!INVALID!') + $keyColours;
      [string[]]$transformedValue = @('---') + $valueColours;

      Write-Error "Found pair that does not contain 2 items (pair: $($pair)) [!!! Reminder: you need to use the comma op for a single item array]";
    } else {
      [string[]]$transformedKey = @($pair[0]) + $keyColours;
      [string[]]$transformedValue = @($pair[1]) + $valueColours;

      # Apply affirmation
      #
      if ((3 -eq $pair.Length)) {
        if (($pair[2] -ieq 'true')) {
          if ($Theme.ContainsKey('AFFIRM-COLOURS')) {
            $transformedValue = @($pair[1]) + $Theme['AFFIRM-COLOURS'];
          }
          else {
            # Since the affirmation colour is missing, use another way of highlighting the value
            # ie, surround in asterisks
            # 
            $transformedValue = @("*{0}*" -f $pair[1]) + $valueColours;
          }
        }
        elseif (-not($pair[2] -ieq 'false')) {
          Write-Error "Invalid affirm value found; not boolean value, found: $($pair[2]) [!!! Reminder: you need to use the comma op for a single item array]"
        } 
      } elseif (3 -lt $pair.Length) {
        Write-Error "Found pair with excess items (pair: $($pair)) [!!! Reminder: you need to use the comma op for a single item array]"
      }
    }

    $transformedPair = , @($transformedKey, $transformedValue);
    $pairsToWriteInColour += $transformedPair;  
  }

  [System.Collections.Hashtable]$parameters = @{
    'Pairs'            = $pairsToWriteInColour;
    'Format'           = $Theme['FORMAT'];
    'KeyPlaceHolder'   = $Theme['KEY-PLACE-HOLDER'];
    'ValuePlaceHolder' = $Theme['VALUE-PLACE-HOLDER'];
    'Open'             = $Theme['OPEN'];
    'Close'            = $Theme['CLOSE'];
    'Separator'        = $Theme['SEPARATOR'];
    'MetaColours'      = $Theme['META-COLOURS'];
  }

  if ([String]::IsNullOrEmpty($Message)) {
    if ($inEmergency) {
      $Message = 'ϞϞϞ ';
    }
  }
  else {
    if ($inEmergency) {
      $Message = 'ϞϞϞ ' + $Message;
    }
  }

  if (-not([String]::IsNullOrEmpty($Message))) {
    $parameters['Message'] = $Message;
    $parameters['MessageColours'] = $Theme['MESSAGE-COLOURS'];
    $parameters['MessageSuffix'] = $Theme['MESSAGE-SUFFIX'];
  }

  & 'Write-RawPairsInColour' @parameters;
}
