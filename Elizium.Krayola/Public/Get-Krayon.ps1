
function Get-Krayon {
  <#
  .NAME
    Get-Krayon

  .SYNOPSIS
    Helper factory function that creates Krayon instance.

  .DESCRIPTION
    Creates a new krayon instance with the optional krayola theme provided. The krayon contains various methods for writing text directly to the console (See online documentation for more information).
  #>

  [OutputType([Krayon])]
  param(
    [Parameter()]
    [hashtable]$theme = $(Get-KrayolaTheme)
  )
  return New-Krayon -Theme $theme;
}
