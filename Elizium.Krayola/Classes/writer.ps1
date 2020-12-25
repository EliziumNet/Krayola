
class couplet {
  [string]$_key;
  [string]$_value;
  [boolean]$_affirm;

  couplet([string[]]$couplet) {
    $this._key = $couplet[0];
    $this._value = $couplet[1];
    $this._affirm = $couplet.Length -gt 2 ? [boolean]$couplet[2] : $false;
  }

  couplet([PSCustomObject]$couplet) {
    $this._key = $couplet.Key;
    $this._value = $couplet.Value;
    $this._affirm = $couplet.psobject.properties.match('Affirm') -and $couplet.Affirm;
  }
}

class line {
  [array]$_line;
  [string]$_message;

  line([couplet[]]$couplets) {
    $this._line = $couplets.Clone();
  }

  line([string]$message, [couplet[]]$couplets) {
    $this._message = $message;
    $this._line = $couplets.Clone();
  }
}

class writer {
  static [array]$ThemeColours = @('affirm', 'key', 'message', 'meta', 'value');

  [hashtable]$_theme;
  [string]$_fgc;
  [string]$_bgc;
  [string]$_defaultFgc;
  [string]$_defaultBgc;

  [array]$_affirmColours;
  [array]$_keyColours;
  [array]$_messageColours;
  [array]$_metaColours;
  [array]$_valueColours;

  [string]$_format;
  [string]$_keyPlaceHolder;
  [string]$_valuePlaceHolder;
  [string]$_open;
  [string]$_close;
  [string]$_separator;
  [string]$_messageSuffix;

  [regex]$_expression;

  writer([hashtable]$theme, [regex]$expression) {
    $this._theme = $theme;

    $this._defaultFgc = (Get-Host).ui.rawui.ForegroundColor;
    $this._defaultBgc = (Get-Host).ui.rawui.BackgroundColor;

    $this._fgc = $this._defaultFgc;
    $this._bgc = $this._defaultBgc;

    $this._affirmColours = $this._initThemeColours('AFFIRM-COLOURS');
    $this._keyColours = $this._initThemeColours('KEY-COLOURS');
    $this._messageColours = $this._initThemeColours('MESSAGE-COLOURS');
    $this._metaColours = $this._initThemeColours('META-COLOURS');
    $this._valueColours = $this._initThemeColours('VALUE-COLOURS');

    $this._format = $theme['FORMAT'];
    $this._keyPlaceHolder = $theme['KEY-PLACE-HOLDER'];
    $this._valuePlaceHolder = $theme['VALUE-PLACE-HOLDER'];
    $this._open = $theme['OPEN'];
    $this._close = $theme['CLOSE'];
    $this._separator = $theme['SEPARATOR'];
    $this._messageSuffix = $theme['MESSAGE-SUFFIX'];

    $this._expression = $expression;
  }

  [writer] Text([string]$value) {
    $this._print($value);
    return $this;
  }

  [writer] TextLn([string]$value) {
    return $this.Text($value).Ln();
  }

  [writer] Pair([couplet]$couplet) {
    $this._couplet($couplet);
    return $this;
  }

  [writer] PairLn([couplet]$couplet) {
    return $this.Pair($couplet).Ln();
  }

  [writer] Pair([PSCustomObject]$couplet) {
    $this._couplet([couplet]::new($couplet));     
    return $this;
  }

  [writer] PairLn([PSCustomObject]$couplet) {
    return $this.Pair([couplet]::new($couplet)).Ln();
  }

  [writer] Line([line]$line) {
    $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._open);

    [int]$count = 0;
    foreach ($couplet in $line._line) {
      $this.Pair($couplet);
      $count++;

      if ($count -lt $line._line.Count) {
        $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._separator);
      }
    }

    $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._close);
    return $this.Reset().Ln();
  }

  [writer] Line([string]$message, [line]$line) {
    $this.fore($this._messageColours[0]).back($this._messageColours[1]).Text($message);
    $this.fore($this._messageColours[0]).back($this._messageColours[1]).Text($this._messageSuffix);

    return $this.Line($line);
  }

  [writer] ThemeColour([string]$val) {
    if ([writer]::ThemeColours -contains $val) {
      [array]$cols = $this._theme[$($val.ToUpper() + '-COLOURS')];
      $this._fgc = $cols[0];
      $this._bgc = $cols.Length -eq 2 ? $cols[1] : $this._defaultBgc;
    }
    else {
      Write-Host "writer.ThemeColour: ignoring invalid theme colour: '$val'"
    }
    return $this;
  }

  [writer] Message([string]$message) {
    $this.ThemeColour('message');
    return $this.Text($message).Text($this._messageSuffix);
  }

  [writer] MessageLn([string]$message) {
    return $this.Message($message).Ln();
  }

  [writer] Reset() {
    $this._fgc = $this._defaultFgc;
    $this._bgc = $this._defaultBgc;
    return $this;
  }

  [writer] Ln() {
    # We need to reset the background colour before a CR to prevent the colour
    # from flooding the whole line because of the carriage return.
    #
    $this._bgc = $this._defaultBgc;
    $this._printLn('');

    return $this;
  }

  [writer] Scribble([string]$source) {
    [PSCustomObject []]$operations = $this._parse($source);

    if ($operations.Count -gt 0) {
      foreach ($op in $operations) {
        if ($op.psobject.properties.match('Arg') -and $op.Arg) {
          $this.($op.Api)($op.Arg);
        }
        else {
          $this.($op.Api)();
        }
      }
    }

    return $this;
  }

  [writer] ScribbleLn([string]$source) {
    return $this.Scribble($source).Ln();
  }

  # Foreground Colours
  #
  [writer] black() {
    $this._fgc = 'black';
    return $this;
  }

  [writer] darkBlue() {
    $this._fgc = 'darkBlue';
    return $this;
  }

  [writer] darkGreen() {
    $this._fgc = 'darkGreen';
    return $this;
  }

  [writer] darkCyan() {
    $this._fgc = 'darkCyan';
    return $this;
  }

  [writer] darkRed() {
    $this._fgc = 'darkRed';
    return $this;
  }

  [writer] darkMagenta() {
    $this._fgc = 'darkMagenta';
    return $this;
  }

  [writer] darkYellow() {
    $this._fgc = 'darkYellow';
    return $this;
  }

  [writer] gray() {
    $this._fgc = 'gray';
    return $this;
  }

  [writer] darkGray() {
    $this._fgc = 'darkGray';
    return $this;
  }

  [writer] blue() {
    $this._fgc = 'blue';
    return $this;
  }

  [writer] green() {
    $this._fgc = 'green';
    return $this;
  }

  [writer] cyan() {
    $this._fgc = 'cyan';
    return $this;
  }

  [writer] red() {
    $this._fgc = 'red';
    return $this;
  }

  [writer] magenta() {
    $this._fgc = 'magenta';
    return $this;
  }

  [writer] yellow() {
    $this._fgc = 'yellow';
    return $this;
  }

  [writer] white() {
    $this._fgc = 'white';
    return $this;
  }

  # Background Colours
  #
  [writer] bgBlack() {
    $this._bgc = 'Black';
    return $this;
  }

  [writer] bgDarkBlue() {
    $this._bgc = 'DarkBlue';
    return $this;
  }

  [writer] bgDarkGreen() {
    $this._bgc = 'DarkGreen';
    return $this;
  }

  [writer] bgDarkCyan() {
    $this._bgc = 'DarkCyan';
    return $this;
  }

  [writer] bgDarkRed() {
    $this._bgc = 'DarkRed';
    return $this;
  }

  [writer] bgDarkMagenta() {
    $this._bgc = 'DarkMagenta';
    return $this;
  }

  [writer] bgDarkYellow() {
    $this._bgc = 'DarkYellow';
    return $this;
  }

  [writer] bgGray() {
    $this._bgc = 'Gray';
    return $this;
  }

  [writer] bgDarkGray() {
    $this._bgc = 'DarkGray';
    return $this;
  }

  [writer] bgBlue() {
    $this._bgc = 'Blue';
    return $this;
  }

  [writer] bgGreen() {
    $this._bgc = 'Green';
    return $this;
  }

  [writer] bgCyan() {
    $this._bgc = 'Cyan';
    return $this;
  }

  [writer] bgRed () {
    $this._bgc = 'Red,';
    return $this;
  }

  [writer] bgMagenta() {
    $this._bgc = 'Magenta';
    return $this;
  }

  [writer] bgYellow() {
    $this._bgc = 'Yellow';
    return $this;
  }

  [writer] bgWhite() {
    $this._bgc = 'White';
    return $this;
  }

  # Dynamic
  #
  [writer] fore([string]$colour) {
    $this._fgc = $colour;
    return $this;
  }

  [writer] back([string]$colour) {
    $this._bgc = $colour;
    return $this;
  }

  # styles (don't exist yet; virtual terminal sequences?)
  #
  [writer] bold() {
    return $this;
  }

  [writer] italic() {
    return $this;
  }

  [writer] strike() {
    return $this;
  }

  [writer] under() {
    return $this;
  }

  # Logically private
  #
  [void] _couplet([couplet]$couplet) {
    [string[]]$constituents = Split-KeyValuePairFormatter -Format $this._format `
      -KeyConstituent $couplet._key -ValueConstituent $couplet._value `
      -KeyPlaceHolder $this._keyPlaceHolder -ValuePlaceHolder $this._valuePlaceHolder;

    # header
    #
    $this._fgc = $this._metaColours[0];
    $this._bgc = $this._metaColours[1];
    $this._print($constituents[0]);

    # key
    #
    $this._fgc = $this._keyColours[0];
    $this._bgc = $this._keyColours[1];
    $this._print($constituents[1]);

    # mid
    #
    $this._fgc = $this._metaColours[0];
    $this._bgc = $this._metaColours[1];
    $this._print($constituents[2]);

    # value
    #
    $this._fgc = ($couplet._affirm) ? $this._affirmColours[0] : $this._valueColours[0];
    $this._bgc = ($couplet._affirm) ? $this._affirmColours[1] : $this._valueColours[1];
    $this._print($constituents[3]);

    # tail
    #
    $this._fgc = $this._metaColours[0];
    $this._bgc = $this._metaColours[1];
    $this._print($constituents[4]);

    $this.Reset();
  } # _couplet

  [void] _print([string]$text) {
    Write-Host $text -ForegroundColor $this._fgc -BackgroundColor $this._bgc -NoNewline;
  }

  [void] _printLn([string]$text) {
    Write-Host $text -ForegroundColor $this._fgc -BackgroundColor $this._bgc;
  }

  [array] _initThemeColours([string]$coloursKey) {
    [array]$thc = $this._theme[$coloursKey];
    if ($thc.Length -eq 1) {
      $thc += $this._defaultBgc;
    }
    return $thc;
  }

  [array] _parse ([string]$source) {
    [System.Text.RegularExpressions.Match]$previousMatch = $null;
    [PSCustomObject []]$operations = @()

    if ($this._expression.IsMatch($source)) {
      [System.Text.RegularExpressions.MatchCollection]$mc = $this._expression.Matches($source);
      [int]$count = 0;
      foreach ($m in $mc) {
        [string]$api = $m.Groups['api'];
        [string]$parm = $m.Groups['p'];

        if ($previousMatch) {
          [int]$snippetStart = $previousMatch.Index + $previousMatch.Length;
          [int]$snippetEnd = $m.Index;
          [int]$snippetSize = $snippetEnd - $snippetStart;
          [string]$snippet = $source.Substring($snippetStart, $snippetSize);
          if (-not([string]::IsNullOrEmpty($parm))) {
            $operations += [PSCustomObject] @{ Api = $api; Arg = $parm; }
          }
          if (-not([string]::IsNullOrEmpty($snippet))) {
            $operations += [PSCustomObject] @{ Api = 'Text'; Arg = $snippet; }
          }
          $operations += [PSCustomObject] @{ Api = $api; }
        }
        else {
          [string]$snippet = if ($m.Index -eq 0) {
            [int]$snippetStart = -1;
            [int]$snippetEnd = -1;
            [string]::Empty
          }
          else {
            [int]$snippetStart = 0;
            [int]$snippetEnd = $m.Index;
            $source.Substring($snippetStart, $snippetEnd);
          }
          if (-not([string]::IsNullOrEmpty($snippet))) {
            $operations += [PSCustomObject] @{ Api = 'Text'; Arg = $snippet; }
          }

          if (-not([string]::IsNullOrEmpty($parm))) {
            $operations += [PSCustomObject] @{ Api = $api; Arg = $parm; }
          } else {
            $operations += [PSCustomObject] @{ Api = $api; }
          }
        }
        $previousMatch = $m;
        $count++;

        if ($count -eq $mc.Count) {
          [int]$lastSnippetStart = $m.Index + $m.Length;
          [string]$snippet = $source.Substring($lastSnippetStart);

          if (-not([string]::IsNullOrEmpty($snippet))) {
            $operations += [PSCustomObject] @{ Api = 'Text'; Arg = $snippet; }
          }
        }
      } # foreach $m
    }

    return $operations;
  }
}
