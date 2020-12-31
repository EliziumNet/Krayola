
function New-Line {
  [Alias('kl')]
  param(
    [Parameter()]
    [couplet[]]$couplets = @()
  )
  return [line]::new($couplets);
}
