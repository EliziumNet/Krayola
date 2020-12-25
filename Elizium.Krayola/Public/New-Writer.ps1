
function New-Writer {
  param(
    [Parameter()]
    [hashtable]$Theme = $(Get-KrayolaTheme),

    [Parameter()]
    [regex]$Expression = [regex]::new('&\[(?<api>[\w]+)(,(?<p>[^\]]+))?\]')
  )

  return [writer]::new($Theme, $Expression);
}
