
function Get-DefaultHostUiColours {

  [string]$rawFgc, [string]$rawBgc = get-RawHostUiColours;
  [boolean]$isLight = Get-IsKrayolaLightTerminal;

  [string]$defaultFgc = $isLight ? 'black' : 'gray';
  [string]$defaultBgc = $isLight ? 'gray' : 'black';

  [string]$fore = Get-EnvironmentVariable 'KRAYOLA_FORE' -Default $rawFgc;
  [string]$back = Get-EnvironmentVariable 'KRAYOLA_BACK' -Default $rawBgc;

  [string[]]$colours = [enum]::GetNames("System.ConsoleColor");

  if (-not($( $colours -contains $fore ))) {
    $fore = $defaultFgc;
  }

  if (-not($( $colours -contains $back ))) {
    $back = $defaultBgc;
  }

  return $fore, $back;
}
