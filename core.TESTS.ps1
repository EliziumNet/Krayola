
$PairsToWriteInColour = @(
  @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
  @(@("Star", "Green"), @("Anna Hournikova", "Cyan"))
);
Write-PairsInColour -Message ">>> Greetings 😈" -MessageColours @("Magenta") `
  -Pairs $PairsToWriteInColour -Format "😉'<%KEY%>'<--->👄'<%VALUE%>'" `
  -MetaColours @(, "Blue") -Open " ••• <<" -Close ">> •••"

Write-Host ".................";
$PairsToWriteInColour = @(
  @(@("Sport", "Red"), @("Tennis", "Blue", "Yellow")),
  @(@("Star", "Green"), @("Anna Hournikova", "Cyan"))
);
Write-PairsInColour -Pairs $PairsToWriteInColour -Format "'<%KEY%>'<--->'<%VALUE%>'" `
  -MetaColours @(, "Blue") -Open "            ••• {" -Close "} •••"

Write-Host ".................";
$PairsToWriteInColour = @(
  @(@("Band", "Red"), @("Nephilim", "White", "Black")),
  @(@("Song", "Green"), @("For Her Light", "Cyan", "Black"))
);
Write-PairsInColour -Pairs $PairsToWriteInColour -Format "'<%VALUE%>'~~~>'<%KEY%>'" -MetaColours @(, "Black")

Write-Host ".................";
Write-InColour -ColouredTextLine @( @("Write-InColour: ", "Green"), @("Band: ", "Red"), @("Nephilim", "White", "Black"), @(", ", "Green "), @("Song: ", "Red"), @("For Her Light", "Cyan", "Black") )
Write-Host ".................";

$SunshineTheme = @{
  "FORMAT"             = "'<%KEY%>' +++ '<%VALUE%>'";
  "KEY-PLACE-HOLDER"   = "<%KEY%>";
  "VALUE-PLACE-HOLDER" = "<%VALUE%>";
  "KEY-COLOURS"        = @("DarkYellow");
  "VALUE-COLOURS"      = @("Yellow");
  "OPEN"               = "{";
  "CLOSE"              = "}";
  "SEPARATOR"          = " | ";
  "META-COLOURS"       = @("DarkGray");
  "MESSAGE-COLOURS"    = @("DarkRed", "White");
  "MESSAGE-SUFFIX"     = " // "
}

$PairsToWriteInColour = @(
  @("Activity", "Yoga"),
  @("Posture", "Marychiasana D"),
  @("Difficulty", "Advanced")
)
Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $SunshineTheme
Write-Host ".................";
$HotTheme = @{
  "FORMAT"             = "'<%KEY%>' == '<%VALUE%>'";
  "KEY-PLACE-HOLDER"   = "<%KEY%>";
  "VALUE-PLACE-HOLDER" = "<%VALUE%>";
  "KEY-COLOURS"        = @("Red");
  "VALUE-COLOURS"      = @("Magenta");
  "OPEN"               = "••• {";
  "CLOSE"              = "} •••";
  "SEPARATOR"          = ", ";
  "META-COLOURS"       = @("Blue");
  "MESSAGE-COLOURS"    = @("Green");
  "MESSAGE-SUFFIX"     = " >> "
}

Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $HotTheme -Message "The heat is on ";
Write-Host ".................";

[System.Collections.Hashtable]$DuffTheme = @{ }
Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $DuffTheme
Write-Host ".................";
Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $DuffTheme -Message "Emergency 🌀"

Write-Host ".................";
Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $DefinedThemes["LOVE-EMOJI-THEME"] -Message "Smooch 💖"

Write-Host ".................";
Write-ColouredPairs -Pairs $PairsToWriteInColour -Theme $DefinedThemes["COOL-EMOJI-THEME"] -Message "Cool:"

