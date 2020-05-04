
# https://getemoji.com/
#
$KrayolaThemes = @{
  <#💩#>
  "EMERGENCY-THEME"  = @{
    "FORMAT"             = "{{<%KEY%>}}={{<%VALUE%>}}";
    "KEY-PLACE-HOLDER"   = "<%KEY%>";
    "VALUE-PLACE-HOLDER" = "<%VALUE%>";
    "KEY-COLOURS"        = @("White");
    "VALUE-COLOURS"      = @("DarkGray");
    "OPEN"               = "{";
    "CLOSE"              = "}";
    "SEPARATOR"          = "; ";
    "META-COLOURS"       = @("Black");
    "MESSAGE-COLOURS"    = @("Gray");
    "MESSAGE-SUFFIX"     = " !!!! " 
  };

  <#😍#>
  "ROUND-THEME" = @{
    "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
    "KEY-PLACE-HOLDER"   = "<%KEY%>";
    "VALUE-PLACE-HOLDER" = "<%VALUE%>";
    "KEY-COLOURS"        = @("DarkCyan");
    "VALUE-COLOURS"      = @("DarkBlue");
    "OPEN"               = "(";
    "CLOSE"              = ")";
    "SEPARATOR"          = " @@ ";
    "META-COLOURS"       = @("Yellow");
    "MESSAGE-COLOURS"    = @("Cyan");
    "MESSAGE-SUFFIX"     = " ~~ " 
  };
  
  <#😎#>
  "SQUARE-THEME" = @{
    "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
    "KEY-PLACE-HOLDER"   = "<%KEY%>";
    "VALUE-PLACE-HOLDER" = "<%VALUE%>";
    "KEY-COLOURS"        = @("DarkCyan");
    "VALUE-COLOURS"      = @("DarkBlue");
    "OPEN"               = "[";
    "CLOSE"              = "]";
    "SEPARATOR"          = " ## ";
    "META-COLOURS"       = @("Black");
    "MESSAGE-COLOURS"    = @("DarkGreen");
    "MESSAGE-SUFFIX"     = " == " 
  };

  <#🌀#>
  "ANGULAR-THEME" = @{
    "FORMAT"             = "'<%KEY%>'-->'<%VALUE%>'";
    "KEY-PLACE-HOLDER"   = "<%KEY%>";
    "VALUE-PLACE-HOLDER" = "<%VALUE%>";
    "KEY-COLOURS"        = @("DarkCyan");
    "VALUE-COLOURS"      = @("DarkBlue");
    "OPEN"               = "<";
    "CLOSE"              = ">";
    "SEPARATOR"          = " ^^ ";
    "META-COLOURS"       = @("Black");
    "MESSAGE-COLOURS"    = @("DarkGreen");
    "MESSAGE-SUFFIX"     = " // " 
  }
}

$null = $KrayolaThemes;
 