
function get-RawHostUiColours {
  # This function only really required to aid unit testing
  #
  [OutputType([array])]
  param()
  return (Get-Host).ui.rawUI.ForegroundColor, (Get-Host).ui.rawUI.BackgroundColor;
}
