
function Write-RawPairsInColour {
  <#
    .NAME
      Write-RawPairsInColour

    .SYNOPSIS

    .DESCRIPTION
      !! DEPRECATED, use Scribbler/Krayon instead.

      The snippets passed in as element of $Pairs are in the same format as
      those passed into Write-InColour as TextSnippets. The only difference is that
      each snippet can only have 2 entries, the first being the key and the second being
      the value.

    .PARAMETER Pairs
      A 3 dimensional array representing a sequence of key/value pairs where each key and value
      are in themselves a sub-sequence of 2 or 3 items representing text, foreground colour &
      background colours.

      Eg:

      $PairsToWriteInColour = @(
        @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
        @(@("Star", "Green"), @("Martina Hingis", "Cyan"))
      );

    .PARAMETER Format
      A string containing a placeholder for the Key and the Value. It represents how the whole
      key/value pair should be represented. It must contain the KEY-PLACE-HOLDER and VALUE-PLACE-HOLDER strings

    .PARAMETER KeyPlaceHolder
      The place holder that identifies the Key in the FORMAT string

    .PARAMETER ValuePlaceHolder
      The place holder that identifies the Value in the FORMAT string.

    .PARAMETER KeyColours
      Array of 1 or 2 items only, the first is the foreground colour and the optional second
      value is the background colour, that specifies how Keys are displayed.

    .PARAMETER ValueColours
      The same as KEY-COLOURS but it applies to Values.

    .PARAMETER Open
      Specifies the leading wrapper around the whole key/value pair collection, typically '('.

    .PARAMETER Close
      Specifies the tail wrapper around the whole key/value pair collection typically ')'.

    .PARAMETER Separator
      Specifies a sequence of characters that separates the Key/Vale pairs, typically ','.

    .PARAMETER MetaColours
      This is the colour specifier for any character that is not the key or the value. Eg: if
      the format is defined as ['<%KEY%>'='<%VALUE%>'], then [' '=' '] will be written in
      this colour. As with other write in clour functionality, the user can specify just a
      single colour (in a single item array), which would represent the foreground colour, or
      2 colours can be specified, representing the foreground and background colours in
      that order inside the 2 element array (a pair). These meta colours will also apply
      to the Open, Close and Separator tokens.

    .PARAMETER MessageColours
      An optional message that appears preceding the Key/Value pair collection and this array
      describes the colours used to write that message.

    .PARAMETER MessageSuffix
      Specifies a sequence of characters that separates the MESSAGE (if present) from the
      Key/Value pair collection.
  #>

  # This function is supposed to write to the host, because the output is in colour.
  # Using Write-Host is Krayola's raison d'etre!
  #
  [Alias('Write-RawPairsInColor')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [string[][][]]
    $Pairs,

    [Parameter(Mandatory = $false)]
    [string]
    $Format = '("<%KEY%>"="<%VALUE%>")',

    [Parameter(Mandatory = $false)]
    [string]
    $KeyPlaceHolder = '<%KEY%>',

    [Parameter(Mandatory = $false)]
    [string]
    $ValuePlaceHolder = '<%VALUE%>',

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    $Open = '=== [',

    [AllowEmptyString()]
    [Parameter(Mandatory = $false)]
    $Close = '] ===',

    [AllowEmptyString()]
    [Parameter(Mandatory = $false)]
    $Separator = ', ',

    [Parameter(Mandatory = $false)]
    [string[]]
    $MetaColours = @('White'),

    [Parameter(Mandatory = $false)]
    [string]
    $Message,

    [Parameter(Mandatory = $false)]
    [string[]]
    $MessageColours = @('White'),

    [AllowEmptyString()]
    [Parameter(Mandatory = $false)]
    [string]
    $MessageSuffix = ' // ',

    [Switch]$NoNewLine
  )

  if ($Pairs.Length -eq 0) {
    return;
  }

  if (($MetaColours.Length -lt 1) -or ($MetaColours.Length -gt 2)) {
    Write-Error -Message "Bad meta colours spec, aborting (No of colours specified: $($MetaColours.Length))";
  }

  # Write the leading message
  #
  if (-not([String]::IsNullOrEmpty($Message))) {
    [string[]]$messageSnippet = @($Message) + $MessageColours;
    [string[][]]$wrapper = @(, $messageSnippet);
    Write-InColour -TextSnippets $wrapper -NoNewLine;

    if (-not([String]::IsNullOrEmpty($MessageSuffix))) {
      [string[]]$suffixSnippet = @($MessageSuffix) + $MessageColours;
      [string[][]]$wrapper = @(, $suffixSnippet);
      Write-InColour -TextSnippets $wrapper -NoNewLine;
    }
  }

  # Add the Open snippet
  #
  if (-not([String]::IsNullOrEmpty($Open))) {
    [string[]]$openSnippet = @($Open) + $MetaColours;
    [string[][]]$wrapper = @(, $openSnippet);
    Write-InColour -TextSnippets $wrapper -NoNewLine;
  }

  [int]$fieldCounter = 0;
  foreach ($field in $Pairs) {
    [string[][]]$displayField = @();

    # Each element of a pair is an instance of a snippet that is compatible with Write-InColour
    # which we can defer to. We need to create the 5 snippets that represents the field pair.
    #
    if ($field.Length -ge 2) {
      # Get the key and value
      #
      [string[]]$keySnippet = $field[0];
      $keyText, $keyColours = $keySnippet;

      [string[]]$valueSnippet = $field[1];
      $valueText, $valueColours = $valueSnippet;

      [string[]]$constituents = Split-KeyValuePairFormatter -Format $Format `
        -KeyConstituent $keyText -ValueConstituent $valueText `
        -KeyPlaceHolder $KeyPlaceHolder -ValuePlaceHolder $ValuePlaceHolder;

      [string[]]$constituentSnippet = @();
      # Now create the 5 snippets (header, key/value, mid, value/key, tail)
      #

      # header
      #
      $constituentSnippet = @($constituents[0]) + $MetaColours;
      $displayField += , $constituentSnippet;

      # key
      #
      $constituentSnippet = @($constituents[1]) + $keyColours;
      $displayField += , $constituentSnippet;

      # mid
      #
      $constituentSnippet = @($constituents[2]) + $MetaColours;
      $displayField += , $constituentSnippet;

      # value
      #
      $constituentSnippet = @($constituents[3]) + $valueColours;
      $displayField += , $constituentSnippet;

      # tail
      #
      $constituentSnippet = @($constituents[4]) + $MetaColours;
      $displayField += , $constituentSnippet;

      Write-InColour -TextSnippets $displayField -NoNewLine;

      if ($field.Length -gt 2) {
        Write-Warning ' * Ignoring excess snippets *';
      }
    }
    else {
      Write-Warning ' * Insufficient snippet pair, 2 required, skipping *';
    }

    # Field Separator snippet
    #
    if (($fieldCounter -lt ($Pairs.Length - 1)) -and (-not([String]::IsNullOrEmpty($Separator)))) {
      [string[]]$separatorSnippet = @($Separator) + $MetaColours;
      Write-InColour -TextSnippets @(, $separatorSnippet) -NoNewLine;
    }

    $fieldCounter++;
  }

  # Add the Close snippet
  #
  if (-not([String]::IsNullOrEmpty($Close))) {
    [string[]]$closeSnippet = @($Close) + $MetaColours;
    [string[][]]$wrapper = @(, $closeSnippet);
    Write-InColour -TextSnippets $wrapper -NoNewLine;
  }

  if (-not($NoNewLine.ToBool())) {
    Write-Host '';
  }
}
