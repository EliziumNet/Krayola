
function Show-ConsoleColours {

  [Alias('Show-ConsoleColors')]
  param ()
  <#
    .NAME
      Show-ConsoleColours

    .SYNOPSIS
      Helper function that shows all the available console colours in the colour
      they represent. This will assist in the development of colour Themes.
  #>

  [Array]$colours = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', `
      'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White');

  foreach ($col in $colours) {
    Write-Host -ForegroundColor $col $col;
  }
}
