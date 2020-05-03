
function Split-KeyValuePairFormatter {
  <#
    .NAME
      Split-KeyValuePairFormatter

    .SYNOPSIS
      Splits an input string which should conform to the format string containing
      <%KEY%> and <%VALUE%> constituents.

    .DESCRIPTION
      The format string should contain key and value token place holders. This function,
      will split the input returning an array of 5 strings representing the constituents.

    .PARAMETER Format
      Format specifier for each key/value pair encountered. The string must contain the tokens
      whatever is defined in KeyPlaceHolder and ValuePlaceHolder.

    .PARAMETER KeyConstituent
      The value of the Key.

    .PARAMETER ValueConstituent
      The value of the Value!

    .PARAMETER KeyPlaceHolder
      The place holder that identifies the Key in the Format parameter.

    .PARAMETER ValuePlaceHolder
      The place holder that identifies the Value in the Format parameter.
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $Format,

    [string]
    $KeyConstituent,

    [string]
    $ValueConstituent,
  
    [string]
    $KeyPlaceHolder = "<%KEY%>",

    [string]
    $ValuePlaceHolder = "<%VALUE%>"
  )

  [string[]]$constituents = @();

  [int]$keyPosition = $Format.IndexOf($KeyPlaceHolder);
  [int]$valuePosition = $Format.IndexOf($ValuePlaceHolder);

  if ($keyPosition -eq -1) {
    Write-Error -ErrorAction Stop `
      -Message "Invalid formatter: '$($Format)', key: '$({$KeyPlaceHolder})' not found";
  }

  if ($valuePosition -eq -1) {
    Write-Error -ErrorAction Stop `
      -Message "Invalid formatter: '$($Format)', value: '$({$ValuePlaceHolder})' not found";
  }

  # Need this check just in case the user wants Value=Key!!!, or perhaps something
  # exotic like [Value(Key)], ie; it's bad to make the assumption that the key comes
  # before the value in the format sring.
  #
  if ($keyPosition -lt $valuePosition) {
    [string]$header = "";

    if ($keyPosition -ne 0) {
      # Insert everything up to the KeyFormat (the header)
      #
      $header = $Format.Substring(0, $keyPosition);
    }

    $constituents += $header;

    # Insert the KeyFormat
    #
    $constituents += $KeyConstituent;

    # Insert everything in between the key and value formats, typically the
    # equal sign (key=value), but it could be anything eg --> (key-->value)
    #
    [int]$midStart = $header.Length + $KeyPlaceHolder.Length;
    [int]$midLength = $valuePosition - $midStart;
    if ($midLength -lt 0) {
      Write-Error -ErrorAction Stop `
        -Message "Internal error, couldn't get the middle of the formatter: '$Format'";
    }
    [string]$middle = $Format.Substring($midStart, $midLength);
    $constituents += $middle;

    # Insert the value
    #
    $constituents += $ValueConstituent;

    # Insert everything after the ValueFormat (the tail)
    # 0         1         2
    # 012345678901234567890
    # [<%KEY%>=<%VALUE%>]
    #
    [int]$tailStart = $valuePosition + $ValuePlaceHolder.Length; # 9 + 9
    [int]$tailEnd = $Format.Length - $tailStart; # 19 -18
    [string]$tail = $Format.Substring($tailStart, $tailEnd);

    $constituents += $tail;
  }
  else {
    [string]$header = "";

    if ($valuePosition -ne 0) {
      # Insert everything up to the ValueFormat (the header)
      #
      $header = $Format.Substring(0, $valuePosition);
    }

    $constituents += $header;

    # Insert the ValueFormat
    #
    $constituents += $ValueConstituent;

    # Insert everything in between the value and key formats, typically the
    # equal sign (value=key), but it could be anything eg --> (value-->key)
    #
    [int]$midStart = $header.Length + $ValuePlaceHolder.Length;
    [int]$midLength = $keyPosition - $midStart;
    if ($midLength -lt 0) {
      Write-Error -ErrorAction Stop `
        -Message "Internal error, couldnt get the middle of the formatter: '$Format'";
    }
    [string]$middle = $Format.Substring($midStart, $midLength);
    $constituents += $middle;

    # Insert the key
    #
    $constituents += $KeyConstituent;

    # Insert everything after the KeyFormat (the tail)
    #
    [int]$tailStart = $keyPosition + $KeyPlaceHolder.Length;
    [int]$tailEnd = $Format.Length - $tailStart;
    [string]$tail = $Format.Substring($tailStart, $tailEnd);

    $constituents += $tail;
  }

  return $constituents;
}
