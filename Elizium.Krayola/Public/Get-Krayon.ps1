
function Get-Krayon {
  param(
    [Parameter()]
    [hashtable]$theme = $(Get-KrayolaTheme)
  )
  return New-Krayon -Theme $theme;
}
