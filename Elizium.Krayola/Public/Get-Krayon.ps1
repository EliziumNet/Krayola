
function Get-Krayon {
  <#
  .NAME
    Get-Krayon

  .SYNOPSIS
    Helper factory function that creates Krayon instance.

  .DESCRIPTION
    Creates a new krayon instance with the optional krayola theme provided.
  #>

  [OutputType([Krayon])]
  param(
    [Parameter()]
    [hashtable]$theme = $(Get-KrayolaTheme)
  )
  return New-Krayon -Theme $theme;
}
