
function Write-InColour {
  <#
    .NAME
      Write-InColour

    .SYNOPSIS
      Writes a multiple snippets of a line in colour with the provided text, foreground & background
      colours.

    .DESCRIPTION
      The user passes in an array of 1,2 or 3 element arrays, which contains any number of text fragments
      with an optional colour specification (ConsoleColor enumeration). The function will then write a
      multi coloured text line to the console. 

      Element 0: text
      Element 1: foreground colour
      Element 2: background colour

      If the background colour is required, then the foreground colour must also be specified.

      Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red", "White") )
      Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text", "Red") )
      Write-InColour -colouredTextLine  @( ("some text", "Blue"),  ("some more text") )

      If you only need to write a single element, use an extra , preceding the array eg:

      Write-InColour -colouredTextLine  @( ,@("some text", "Blue") )

      Empty snippets, should not be passed in, it's up to the caller to ensure that this is
      the case. If an empty snippet is found and ugly warning message is emitted, so this
      should not go un-noticed.
    
    .PARAMETER ColouredTextLine
      An array of an array of strings (see description).

    .PARAMETER NoNewLine
      Switch to indicate if a new line should be written after the text.
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string[][]]
    $ColouredTextLine,

    [Switch]$NoNewLine
  )

  foreach ($snippet in $ColouredTextLine) {
    if ($snippet.Length -eq 0) {
      Write-Warning " * Found malformed line (empty snippet entry), skipping * ";
      continue;
    }

    if ($snippet.Length -eq 1) {
      Write-Warning " * No colour specified for snippet '$($snippet[0])', skipping * ";
      continue;
    }

    if ($null -eq $snippet[0]) {
      Write-Warning " * Found empty snippet text, skipping *";
      continue;
    }

    if ($snippet.Length -eq 2) {
      if ($null -eq $snippet[1]) {
        Write-Warning " * Foreground col is null, for snippet: '$($snippet[0])', skipping * ";
        continue;
      }

      # Foreground colour specified
      #
      Write-Host $snippet[0] -NoNewline -ForegroundColor $snippet[1];
    }
    else {
      # Foreground and background colours specified
      #
      Write-Host $snippet[0] -NoNewline -ForegroundColor $snippet[1] -BackgroundColor $snippet[2];

      if ($snippet.Length -gt 3) {
        Write-Warning " * Excess entries found for snippet: '$($snippet[0])' * ";
      }
    }
  }

  if (-not ($NoNewLine.ToBool())) {
    Write-Host "";
  }
}
