
function New-Writer {
  param(
    [Parameter()]
    [hashtable]$Theme = $(Get-KrayolaTheme),

    [Parameter()]
    [regex]$Expression = [regex]::new('&\[(?<api>[\w]+)(,(?<p>[^\]]+))?\]'),

    [Parameter()]
    [string]$WriterFormatWithArg = '&[{0},{1}]',

    [Parameter()]
    [string]$WriterFormat = '&[{0}]'
  )

  [string]$dummyWithArg = $WriterFormatWithArg -replace "\{\d{1,2}\}", 'dummy';
  if (-not($Expression.IsMatch($dummyWithArg))) {
    throw "New-Writer: invalid WriterFormatWithArg ('$WriterFormatWithArg'), does not match the provided Expression: '$($Expression.ToString())'";
  }

  [string]$dummy = $WriterFormat -replace "\{\d{1,2}\}", 'dummy';
  if (-not($Expression.IsMatch($dummy))) {
    throw "New-Writer: invalid WriterFormat ('$WriterFormat'), does not match the provided Expression: '$($Expression.ToString())'";
  }
  return [writer]::new($Theme, $Expression, $WriterFormatWithArg, $WriterFormat);
}
