
function Get-DefaultHostUiColours {

  <#
  .NAME
    Get-DefaultHostUiColours

  .SYNOPSIS
    Get the default foreground and background colours of the console host.

  .DESCRIPTION
    Currently there is an open issue <https://github.com/PowerShell/PowerShell/issues/14727>
  which means that on a mac, the default colours obtained from the host are both incorrectly
  set to -1. This function takes this deficiency into account and will ensure that sensible
  colour values are always returned.

  #>
  [OutputType([string[]])]
  param()

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
