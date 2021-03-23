
function Get-KrayolaTheme {
  <#
  .NAME
    Get-KrayolaTheme

  .SYNOPSIS
    Helper function that makes it easier for client applications to get a Krayola theme
  from the environment, which is compatible with the terminal colours being used.
  This helps keep output from different applications consistent.

  .DESCRIPTION
    If $KrayolaThemeName is specified, then it is used to lookup the theme in the global
  $KrayolaThemes hash-table exposed by the Krayola module. If either the theme specified
  does not exist or not specified, then a default theme is used. The default theme created
  should be compatible with the dark/lightness of the background of the terminal currently
  in use. By default, a dark terminal is assumed and the colours used show up clearly
  against a dark background. If KRAYOLA_LIGHT_TERMINAL is defined as an environment
  variable (can be set to any string apart from empty string/white space), then the colours
  chosen show up best against a light background. Typically, a user would create their
  own custom theme and then populate this into the $KrayolaThemes collection. This should
  be done in the user profile so as to become available in all powershell sessions.
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
  [OutputType([hashtable])]
  param (
    [Parameter(
      Mandatory = $false,
      Position = 0
    )]
    [AllowEmptyString()]
    [string]$KrayolaThemeName,

    [Parameter(Mandatory = $false)]
    [hashtable]$Themes = $KrayolaThemes,

    [Parameter(Mandatory = $false)]
    [hashtable]$DefaultTheme = @{
      # DefaultTheme is compatible with dark consoles by default
      #
      'FORMAT'             = '"<%KEY%>" => "<%VALUE%>"';
      'KEY-PLACE-HOLDER'   = '<%KEY%>';
      'VALUE-PLACE-HOLDER' = '<%VALUE%>';
      'KEY-COLOURS'        = @('DarkCyan');
      'VALUE-COLOURS'      = @('White');
      "AFFIRM-COLOURS"     = @("Red");
      'OPEN'               = '[';
      'CLOSE'              = ']';
      'SEPARATOR'          = ', ';
      'META-COLOURS'       = @('Yellow');
      'MESSAGE-COLOURS'    = @('Cyan');
      'MESSAGE-SUFFIX'     = ' // ';
    }
  )
  [hashtable]$displayTheme = $DefaultTheme;

  # Switch to use colours compatible with light consoles if KRAYOLA_LIGHT_TERMINAL
  # is set.
  #
  if (Get-IsKrayolaLightTerminal) {
    $displayTheme['KEY-COLOURS'] = @('DarkBlue');
    $displayTheme['VALUE-COLOURS'] = @('Red');
    $displayTheme['AFFIRM-COLOURS'] = @('Magenta');
    $displayTheme['META-COLOURS'] = @('DarkMagenta');
    $displayTheme['MESSAGE-COLOURS'] = @('Green');
  }

  [string]$themeName = $KrayolaThemeName;

  # Get the theme name
  #
  if ([string]::IsNullOrWhiteSpace($themeName)) {
    $themeName = Get-EnvironmentVariable 'KRAYOLA_THEME_NAME';
  }

  if ($Themes -and $Themes.ContainsKey($themeName)) {
    $displayTheme = $Themes[$themeName];
  }

  return $displayTheme;
}
