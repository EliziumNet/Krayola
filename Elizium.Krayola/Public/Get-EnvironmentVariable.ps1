function Get-EnvironmentVariable {
  <#
    .NAME
      Get-EnvironmentVariable

    .Synopsis
      Wrapper around [System.Environment]::GetEnvironmentVariable to support
    unit testing.

    .DESCRIPTION
      Retrieve the value of the environment variable specified. Returns
    $null if variable is not found.

    .EXAMPLE
      Get-EnvironmentVariable 'KRAYOLA-THEME-NAME'
  #>
  [CmdletBinding()]
  [OutputType([string])]
  Param
  (
    [Parameter(Mandatory = $true, Position=0)]
    [string]$Variable,

    [Parameter(Position = 1)]
    $Default
  )
  $value = [System.Environment]::GetEnvironmentVariable($Variable);

  if (-not($value) -and ($Default)) {
    $value = $Default;
  }
  return $value;
}
