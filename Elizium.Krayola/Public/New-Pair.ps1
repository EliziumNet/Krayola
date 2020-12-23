
function New-Pair {
  [Alias('kp')]
  param(
    [Parameter()]
    [string[]]$couplet
  )

  return [couplet]::new($couplet);
}
