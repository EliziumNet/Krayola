
function Get-IsKrayolaLightTerminal {
  <#
    .NAME
      Get-IsKrayolaLightTerminal

    .SYNOPSIS
      Gets the value of KRAYOLA-LIGHT-TERMINAL as a boolean

    .DESCRIPTION
      For use by applications that need to use a Krayola theme that is dependent
    on whether a light or dark background colour is in effect in the current
    terminal.
  #>
  [OutputType([boolean])]
  param()

  return -not([string]::IsNullOrWhiteSpace(
    (Get-EnvironmentVariable 'KRAYOLA-LIGHT-TERMINAL')));
}
