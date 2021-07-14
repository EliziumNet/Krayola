
<#
.NAME
  couplet
#>
class couplet {
  [string]$Key;
  [string]$Value;
  [boolean]$Affirm;

  couplet () {
  }

  couplet([string[]]$props) {
    $this.Key = $props[0].Replace('\,', ',').Replace('\;', ';');
    $this.Value = $props[1].Replace('\,', ',').Replace('\;', ';');
    $this.Affirm = $props.Length -gt 2 ? [boolean]$props[2] : $false;
  }

  couplet ([string]$key, [string]$value, [boolean]$affirm) {
    $this.Key = $key.Replace('\,', ',').Replace('\;', ';');
    $this.Value = $value.Replace('\,', ',').Replace('\;', ';');
    $this.Affirm = $affirm;
  }

  couplet ([string]$key, [string]$value) {
    $this.Key = $key.Replace('\,', ',').Replace('\;', ';');
    $this.Value = $value.Replace('\,', ',').Replace('\;', ';');
    $this.Affirm = $false;
  }

  couplet([PSCustomObject]$custom) {
    $this.Key = $custom.Key;
    $this.Value = $custom.Value;
    $this.Affirm = $custom.psobject.properties.match('Affirm') -and $custom.Affirm;
  }

  [boolean] equal ([couplet]$other) {
    return ($this.Key -eq $other.Key) `
      -and ($this.Value -eq $other.Value) `
      -and ($this.Affirm -eq $other.Affirm);
  }

  [boolean] cequal ([couplet]$other) {
    return ($this.Key -ceq $other.Key) `
      -and ($this.Value -ceq $other.Value) `
      -and ($this.Affirm -ceq $other.Affirm);
  }

  [string] ToString() {
    return "[Key: '$($this.Key)', Value: '$($this.Value)', Affirm: '$($this.Affirm)']";
  }
} # couplet

<#
.NAME
  line
#>
class line {
  [couplet[]]$Line;
  [string]$Message;

  line() {
  }

  line([couplet[]]$couplets) {
    $this.Line = $couplets.Clone();
  }

  line([string]$message, [couplet[]]$couplets) {
    $this.Message = $message;
    $this.Line = $couplets.Clone();
  }

  line([line]$line) {
    $this.Line = $line.Line.Clone();
  }

  [line] append([couplet]$couplet) {
    $this.Line += $couplet;
    return $this;
  }

  [line] append([couplet[]]$couplet) {
    $this.Line += $couplet;
    return $this;
  }

  [line] append([line]$other) {
    $this.Line += $other.Line;
    return $this;
  }

  [boolean] equal ([line]$other) {
    [boolean]$result = $true;

    if ($this.Line.Length -eq $other.Line.Length) {
      for ($index = 0; ($index -lt $this.Line.Length -and $result); $index++) {
        $result = $this.Line[$index].equal($other.line[$index]);
      }
    }
    else {
      $result = $false;
    }
    return $result;
  }

  [boolean] cequal ([line]$other) {
    [boolean]$result = $true;

    if ($this.Line.Length -eq $other.Line.Length) {
      for ($index = 0; ($index -lt $this.Line.Length -and $result); $index++) {
        $result = $this.Line[$index].cequal($other.line[$index]);
      }
    }
    else {
      $result = $false;
    }
    return $result;
  }

  [string] ToString() {
    return $($this.Line -join '; ');
  }
} # line

<#
.NAME
  Krayon
#>
class Krayon {
  static [array]$ThemeColours = @('affirm', 'key', 'message', 'meta', 'value');

  # Logically public properties
  #
  [string]$ApiFormatWithArg;
  [string]$ApiFormat;
  [hashtable]$Theme;

  # Logically private properties
  #
  hidden [string]$_fgc;
  hidden [string]$_bgc;
  hidden [string]$_defaultFgc;
  hidden [string]$_defaultBgc;

  hidden [array]$_affirmColours;
  hidden [array]$_keyColours;
  hidden [array]$_messageColours;
  hidden [array]$_metaColours;
  hidden [array]$_valueColours;

  hidden [string]$_format;
  hidden [string]$_keyPlaceHolder;
  hidden [string]$_valuePlaceHolder;
  hidden [string]$_open;
  hidden [string]$_close;
  hidden [string]$_separator;
  hidden [string]$_messageSuffix;
  hidden [string]$_messageSuffixFiller;

  hidden [regex]$_expression;
  hidden [regex]$_nativeExpression;

  Krayon([hashtable]$theme, [regex]$expression, [string]$FormatWithArg, [string]$Format, [regex]$NativeExpression) {
    $this.Theme = $theme;

    $this._defaultFgc, $this._defaultBgc = Get-DefaultHostUiColours
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
    $this._messageSuffixFiller = [string]::new(' ', $this._messageSuffix.Length);

    $this._expression = $expression;
    $this._nativeExpression = $NativeExpression;
    $this.ApiFormatWithArg = $FormatWithArg;
    $this.ApiFormat = $Format;
  }

  # +Scribblers+ --------------------------------------------------------------
  #
  [Krayon] Scribble([string]$source) {
    if (-not([string]::IsNullOrEmpty($source))) {
      [PSCustomObject []]$operations = $this._parse($source);

      if ($operations.Count -gt 0) {
        foreach ($op in $operations) {
          if ($op.psobject.properties.match('Arg') -and $op.Arg) {
            $null = $this.($op.Method)($op.Arg);
          }
          else {
            $null = $this.($op.Method)();
          }
        }
      }
    }

    return $this;
  }

  [Krayon] ScribbleLn([string]$source) {
    return $this.Scribble($source).Ln();
  }

  # +Text+ --------------------------------------------------------------------
  #
  [Krayon] Text([string]$value) {
    $this._print($value);
    return $this;
  }

  [Krayon] TextLn([string]$value) {
    return $this.Text($value).Ln();
  }

  # +Pair+ (Couplet) ----------------------------------------------------------
  #
  [Krayon] Pair([couplet]$couplet) {
    $this._couplet($couplet);
    return $this;
  }

  [Krayon] PairLn([couplet]$couplet) {
    return $this.Pair($couplet).Ln();
  }

  [Krayon] Pair([PSCustomObject]$couplet) {
    $this._couplet([couplet]::new($couplet));
    return $this;
  }

  [Krayon] PairLn([PSCustomObject]$couplet) {
    return $this.Pair([couplet]::new($couplet)).Ln();
  }

  # +Line+ --------------------------------------------------------------------
  #
  [Krayon] Line([line]$line) {
    $null = $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._open);

    $this._coreLine($line);

    $null = $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._close);
    return $this.Ln();
  }

  [Krayon] NakedLine([line]$nakedLine) {
    $null = $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text(
      [string]::new(' ', $this._open.Length)
    );

    $this._coreLine($nakedLine);

    $null = $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text(
      [string]::new(' ', $this._open.Length)
    );
    return $this.Ln();
  }

  [void] _coreLine([line]$line) {
    [int]$count = 0;
    foreach ($couplet in $line.Line) {
      $null = $this.Pair($couplet);
      $count++;

      if ($count -lt $line.Line.Count) {
        $null = $this.fore($this._metaColours[0]).back($this._metaColours[1]).Text($this._separator);
      }
    }
  }

  [Krayon] Line([string]$message, [line]$line) {
    $this._lineWithMessage($message, $line);

    return $this.Line($line);
  }

  [Krayon] NakedLine([string]$message, [line]$line) {
    $this._lineWithMessage($message, $line);

    return $this.NakedLine($line);
  }

  [void] _lineWithMessage([string]$message, [line]$line) {
    $null = $this.fore($this._messageColours[0]).back($this._messageColours[1]).Text($message);
    $null = $this.fore($this._messageColours[0]).back($this._messageColours[1]).Text(
      [string]::IsNullOrEmpty($message.Trim()) ? $this._messageSuffixFiller : $this._messageSuffix
    );
  }

  # +Message+ -----------------------------------------------------------------
  #
  [Krayon] Message([string]$message) {
    $null = $this.ThemeColour('message');
    return $this.Text($message).Text($this._messageSuffix);
  }

  [Krayon] MessageLn([string]$message) {
    return $this.Message($message).Ln();
  }

  [Krayon] MessageNoSuffix([string]$message) {
    $null = $this.ThemeColour('message');
    return $this.Text($message).Text($this._messageSuffixFiller);
  }

  [Krayon] MessageNoSuffixLn([string]$message) {
    return $this.MessageNoSuffix($message).Ln();
  }

  # +Dynamic+ -----------------------------------------------------------------
  #
  [Krayon] fore([string]$colour) {
    $this._fgc = $colour;
    return $this;
  }

  [Krayon] back([string]$colour) {
    $this._bgc = $colour;
    return $this;
  }

  [Krayon] defaultFore([string]$colour) {
    $this._defaultFgc = $colour;
    return $this;
  }

  [Krayon] defaultBack([string]$colour) {
    $this._defaultBgc = $colour;
    return $this;
  }

  [string] getDefaultFore() {
    return $this._defaultFgc;
  }

  [string] getDefaultBack() {
    return $this._defaultBgc;
  }

  # +Control+ -----------------------------------------------------------------
  #
  [void] End() {}

  [Krayon] Ln() {
    # Write a non-breaking space (0xA0)
    # https://en.wikipedia.org/wiki/Non-breaking_space
    # (This is required because of a con-host bug in windows =>
    # https://github.com/microsoft/terminal/issues/1040)
    #
    Write-Host ([char]0xA0);
    return $this;
  }

  [Krayon] Reset() {
    $this._fgc = $this._defaultFgc;
    $this._bgc = $this._defaultBgc;
    return $this;
  }

  # +Theme+ -------------------------------------------------------------------
  #
  [Krayon] ThemeColour([string]$val) {
    [string]$trimmedValue = $val.Trim();
    if ([Krayon]::ThemeColours -contains $trimmedValue) {
      [array]$cols = $this.Theme[$($trimmedValue.ToUpper() + '-COLOURS')];
      $this._fgc = $cols[0];
      $this._bgc = $cols.Length -eq 2 ? $cols[1] : $this._defaultBgc;
    }
    else {
      Write-Debug "Krayon.ThemeColour: ignoring invalid theme colour: '$trimmedValue'"
    }
    return $this;
  }

  # +Static Foreground Colours+ -----------------------------------------------
  #
  [Krayon] black() {
    $this._fgc = 'black';
    return $this;
  }

  [Krayon] darkBlue() {
    $this._fgc = 'darkBlue';
    return $this;
  }

  [Krayon] darkGreen() {
    $this._fgc = 'darkGreen';
    return $this;
  }

  [Krayon] darkCyan() {
    $this._fgc = 'darkCyan';
    return $this;
  }

  [Krayon] darkRed() {
    $this._fgc = 'darkRed';
    return $this;
  }

  [Krayon] darkMagenta() {
    $this._fgc = 'darkMagenta';
    return $this;
  }

  [Krayon] darkYellow() {
    $this._fgc = 'darkYellow';
    return $this;
  }

  [Krayon] gray() {
    $this._fgc = 'gray';
    return $this;
  }

  [Krayon] darkGray() {
    $this._fgc = 'darkGray';
    return $this;
  }

  [Krayon] blue() {
    $this._fgc = 'blue';
    return $this;
  }

  [Krayon] green() {
    $this._fgc = 'green';
    return $this;
  }

  [Krayon] cyan() {
    $this._fgc = 'cyan';
    return $this;
  }

  [Krayon] red() {
    $this._fgc = 'red';
    return $this;
  }

  [Krayon] magenta() {
    $this._fgc = 'magenta';
    return $this;
  }

  [Krayon] yellow() {
    $this._fgc = 'yellow';
    return $this;
  }

  [Krayon] white() {
    $this._fgc = 'white';
    return $this;
  }

  # +Background Colours+ ------------------------------------------------------
  #
  [Krayon] bgBlack() {
    $this._bgc = 'Black';
    return $this;
  }

  [Krayon] bgDarkBlue() {
    $this._bgc = 'DarkBlue';
    return $this;
  }

  [Krayon] bgDarkGreen() {
    $this._bgc = 'DarkGreen';
    return $this;
  }

  [Krayon] bgDarkCyan() {
    $this._bgc = 'DarkCyan';
    return $this;
  }

  [Krayon] bgDarkRed() {
    $this._bgc = 'DarkRed';
    return $this;
  }

  [Krayon] bgDarkMagenta() {
    $this._bgc = 'DarkMagenta';
    return $this;
  }

  [Krayon] bgDarkYellow() {
    $this._bgc = 'DarkYellow';
    return $this;
  }

  [Krayon] bgGray() {
    $this._bgc = 'Gray';
    return $this;
  }

  [Krayon] bgDarkGray() {
    $this._bgc = 'DarkGray';
    return $this;
  }

  [Krayon] bgBlue() {
    $this._bgc = 'Blue';
    return $this;
  }

  [Krayon] bgGreen() {
    $this._bgc = 'Green';
    return $this;
  }

  [Krayon] bgCyan() {
    $this._bgc = 'Cyan';
    return $this;
  }

  [Krayon] bgRed () {
    $this._bgc = 'Red';
    return $this;
  }

  [Krayon] bgMagenta() {
    $this._bgc = 'Magenta';
    return $this;
  }

  [Krayon] bgYellow() {
    $this._bgc = 'Yellow';
    return $this;
  }

  [Krayon] bgWhite() {
    $this._bgc = 'White';
    return $this;
  }

  # +Compounders+ -------------------------------------------------------------
  #
  [Krayon] Line([string]$semiColonSV) {
    return $this._lineFromSemiColonSV($semiColonSV, 'Line');
  }

  [Krayon] NakedLine([string]$semiColonSV) {
    return $this._lineFromSemiColonSV($semiColonSV, 'NakedLine');
  }

  hidden [line] _convertToLine([string[]]$constituents) {
    [couplet[]]$couplets = ($constituents | ForEach-Object {
        New-Pair $($_ -split '(?<!\\),', 0, 'RegexMatch');
      });
    [line]$line = New-Line $couplets;

    return $line;
  }

  hidden [Krayon] _lineFromSemiColonSV([string]$semiColonSV, [string]$op) {
    [string[]]$constituents = $semiColonSV -split '(?<!\\);', 0, 'RegexMatch';
    [string]$message, [string[]]$remainder = $constituents;

    [string]$unescapedComma = '(?<!\\),';
    if ($message -match $unescapedComma) {
      [line]$line = $this._convertToLine($constituents);
      $null = $this.$op($line);
    }
    else {
      [line]$line = $this._convertToLine($remainder);
      $null = $this.$op($message, $line);
    }

    return $this;
  }

  [Krayon] Pair([string]$csv) {
    [string[]]$constituents = $csv -split '(?<!\\),';

    [couplet]$pair = New-Pair $constituents;
    $this._couplet($pair);

    return $this;
  }

  [Krayon] PairLn([string]$csv) {
    return $this.Pair($csv).Ln();
  }

  # +Utility+ -----------------------------------------------------------------
  #

  [string] Native([string]$structured) {
    return $this._nativeExpression.Replace($structured, '');
  }

  # styles (don't exist yet; virtual terminal sequences?)
  #
  [Krayon] bold() {
    return $this;
  }

  [Krayon] italic() {
    return $this;
  }

  [Krayon] strike() {
    return $this;
  }

  [Krayon] under() {
    return $this;
  }

  # Logically private
  #
  hidden [void] _couplet([couplet]$couplet) {
    [string[]]$constituents = Split-KeyValuePairFormatter -Format $this._format `
      -KeyConstituent $couplet.Key -ValueConstituent $couplet.Value `
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
    $this._fgc = ($couplet.Affirm) ? $this._affirmColours[0] : $this._valueColours[0];
    $this._bgc = ($couplet.Affirm) ? $this._affirmColours[1] : $this._valueColours[1];
    $this._print($constituents[3]);

    # tail
    #
    $this._fgc = $this._metaColours[0];
    $this._bgc = $this._metaColours[1];
    $this._print($constituents[4]);

    $null = $this.Reset();
  } # _couplet

  hidden [void] _print([string]$text) {
    Write-Host $text -ForegroundColor $this._fgc -BackgroundColor $this._bgc -NoNewline;
  } # _print

  hidden [void] _printLn([string]$text) {
    Write-Host $text -ForegroundColor $this._fgc -BackgroundColor $this._bgc;
  } # _printLn

  hidden [array] _initThemeColours([string]$coloursKey) {
    [array]$thc = $this.Theme[$coloursKey];
    if ($thc.Length -eq 1) {
      $thc += $this._defaultBgc;
    }
    return $thc;
  } # _initThemeColours

  hidden [array] _parse ([string]$source) {
    [System.Text.RegularExpressions.Match]$previousMatch = $null;

    [PSCustomObject []]$operations = if ($this._expression.IsMatch($source)) {
      [System.Text.RegularExpressions.MatchCollection]$mc = $this._expression.Matches($source);
      [int]$count = 0;
      foreach ($m in $mc) {
        [string]$method = $m.Groups['method'];
        [string]$parm = $m.Groups['p'];

        if ($previousMatch) {
          [int]$snippetStart = $previousMatch.Index + $previousMatch.Length;
          [int]$snippetEnd = $m.Index;
          [int]$snippetSize = $snippetEnd - $snippetStart;
          [string]$snippet = $source.Substring($snippetStart, $snippetSize);

          # If we find a text snippet, it must be applied before the current method invoke
          #
          if (-not([string]::IsNullOrEmpty($snippet))) {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = 'Text';
              Arg        = $snippet;
            }
          }

          if (-not([string]::IsNullOrEmpty($parm))) {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = $method;
              Arg        = $parm;
            }
          }
          else {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = $method;
            }
          }
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
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = 'Text';
              Arg        = $snippet;
            }
          }

          if (-not([string]::IsNullOrEmpty($parm))) {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = $method;
              Arg        = $parm;
            }
          }
          else {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = $method;
            }
          }
        }
        $previousMatch = $m;
        $count++;

        if ($count -eq $mc.Count) {
          [int]$lastSnippetStart = $m.Index + $m.Length;
          [string]$snippet = $source.Substring($lastSnippetStart);

          if (-not([string]::IsNullOrEmpty($snippet))) {
            [PSCustomObject] @{
              PSTypeName = 'Krayola.Krayon.Operation';
              #
              Method        = 'Text';
              Arg        = $snippet;
            }
          }
        }
      } # foreach $m
    }
    else {
      @([PSCustomObject] @{
          PSTypeName = 'Krayola.Krayon.Operation';
          #
          Method        = 'Text';
          Arg        = $source;
        });
    }

    return $operations;
  } # _parse
} # Krayon

<#
.NAME
  Scribbler
#>
class Scribbler {
  [System.Text.StringBuilder]$Builder;
  [Krayon]$Krayon;

  hidden [System.Text.StringBuilder]$_session;

  Scribbler([System.Text.StringBuilder]$builder, [Krayon]$krayon,
    [System.Text.StringBuilder]$Session) {
    $this.Builder = $builder;
    $this.Krayon = $krayon;
    $this._session = $Session;
  }

  # +Scribblers+ --------------------------------------------------------------
  #
  [void] Scribble([string]$structuredContent) {
    $null = $this.Builder.Append($structuredContent);
  }

  # +Text+ Accelerators -------------------------------------------------------
  #
  [Scribbler] Text([string]$value) {
    $this.Scribble($value);
    return $this;
  }

  [Scribbler] TextLn([string]$value) {
    return $this.Text($value).Ln();
  }

  # +Pair+ (Couplet) Accelerators ---------------------------------------------
  #
  [Scribbler] Pair([couplet]$couplet) {
    [string]$pairSnippet = $this.PairSnippet($couplet);
    $this.Scribble($pairSnippet);

    return $this;
  }

  [Scribbler] PairLn([couplet]$couplet) {
    return $this.Pair($couplet).Ln();
  }

  [Scribbler] Pair([PSCustomObject]$coupletObj) {
    [couplet]$couplet = [couplet]::new($coupletObj);

    return $this.Pair($couplet);
  }

  [Scribbler] PairLn([PSCustomObject]$coupletObj) {
    return $this.Pair([couplet]::new($coupletObj)).Ln();
  }

  # +Line+ Accelerators -------------------------------------------------------
  #
  [Scribbler] Line([string]$message, [line]$line) {
    $this._coreScribbleLine($message, $line, 'Line');

    return $this;
  }

  [Scribbler] Line([line]$line) {
    $this.Line([string]::Empty, $line);

    return $this;
  }

  [Scribbler] NakedLine([string]$message, [line]$nakedLine) {
    $this._coreScribbleLine($message, $nakedLine, 'NakedLine');

    return $this;
  }

  [Scribbler] NakedLine([line]$line) {
    $this.NakedLine([string]::Empty, $line);

    return $this;
  }

  hidden [void] _coreScribbleLine([string]$message, [line]$line, [string]$lineType) {
    [string]$structuredLine = $(($Line.Line | ForEach-Object {
          "$($this._escape($_.Key)),$($this._escape($_.Value)),$($_.Affirm)"
        }) -join ';');

    if (-not([string]::IsNullOrEmpty($message))) {
      $structuredLine = "$message;" + $structuredLine;
    }

    [string]$lineSnippet = $this.WithArgSnippet(
      $lineType, $structuredLine
    )
    $this.Scribble("$($lineSnippet)");
  } # _coreScribbleLine

  # +Message+ Accelerators ----------------------------------------------------
  #
  [Scribbler] Message([string]$message) {
    [string]$snippet = $this.WithArgSnippet('Message', $message);
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] MessageLn([string]$message) {
    return $this.Message($message).Ln();
  }

  [Scribbler] MessageNoSuffix([string]$message) {
    [string]$snippet = $this.WithArgSnippet('MessageNoSuffix', $message);
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] MessageNoSuffixLn([string]$message) {
    return $this.MessageNoSuffix($message).Ln();
  }

  # +Dynamic+ Accelerators ----------------------------------------------------
  #
  [Scribbler] fore([string]$colour) {
    [string]$snippet = $this.WithArgSnippet('fore', $colour);
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] back([string]$colour) {
    [string]$snippet = $this.WithArgSnippet('back', $colour);
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] defaultFore([string]$colour) {
    [string]$snippet = $this.WithArgSnippet('defaultFore', $colour);
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] defaultBack([string]$colour) {
    [string]$snippet = $this.WithArgSnippet('defaultBack', $colour);
    $this.Scribble($snippet);

    return $this;
  }

  # +Control+ Accelerators ----------------------------------------------------
  #
  [void] End() { }

  [void] Flush () {
    $this.Krayon.Scribble($this.Builder.ToString());

    $this._clear();
  }

  [Scribbler] Ln() {
    [string]$snippet = $this.Snippets('Ln');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] Reset() {
    [string]$snippet = $this.Snippets('Reset');
    $this.Scribble($snippet);

    return $this;
  }

  [void] Restart() {
    if ($this._session) {
      $this._session.Clear();
    }
    $this.Builder.Clear();
    $this.Krayon.Reset().End();
  }

  [void] Save([string]$fullPath) {
    [string]$directoryPath = [System.IO.Path]::GetDirectoryName($fullPath);
    [string]$fileName = [System.IO.Path]::GetFileName($fullPath) + '.struct.txt';
    [string]$writeFullPath = Join-Path -Path $directoryPath -ChildPath $fileName;

    if ($this._session) {
      if (-not(Test-Path -Path $writeFullPath)) {
        Set-Content -LiteralPath $writeFullPath -Value $this._session.ToString();
      }
      else {
        Write-Warning -Message $(
          "Can't write session to '$writeFullPath'. (file already exists)."
        );
      }
    }
    else {
      Write-Warning -Message $(
        "Can't write session to '$writeFullPath'. (session not set)."
      );
    }
  }

  # +Theme+ Accelerators ------------------------------------------------------
  #
  [Scribbler] ThemeColour([string]$val) {
    [string]$snippet = $this.WithArgSnippet('ThemeColour', $val);

    $this.Scribble($snippet);
    return $this;
  }

  # +Static Foreground Colours+ Accelerators ----------------------------------
  #
  [Scribbler] black() {
    [string]$snippet = $this.Snippets('black');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkBlue() {
    [string]$snippet = $this.Snippets('darkBlue');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkGreen() {
    [string]$snippet = $this.Snippets('darkGreen');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkCyan() {
    [string]$snippet = $this.Snippets('darkCyan');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkRed() {
    [string]$snippet = $this.Snippets('darkRed');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkMagenta() {
    [string]$snippet = $this.Snippets('darkMagenta');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkYellow() {
    [string]$snippet = $this.Snippets('darkYellow');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] gray() {
    [string]$snippet = $this.Snippets('gray');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] darkGray() {
    [string]$snippet = $this.Snippets('darkGray');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] blue() {
    [string]$snippet = $this.Snippets('blue');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] green() {
    [string]$snippet = $this.Snippets('green');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] cyan() {
    [string]$snippet = $this.Snippets('cyan');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] red() {
    [string]$snippet = $this.Snippets('red');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] magenta() {
    [string]$snippet = $this.Snippets('magenta');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] yellow() {
    [string]$snippet = $this.Snippets('yellow');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] white() {
    [string]$snippet = $this.Snippets('white');
    $this.Scribble($snippet);

    return $this;
  }

  # +Background Colours+ Accelerators -----------------------------------------
  #
  [Scribbler] bgBlack() {
    [string]$snippet = $this.Snippets('bgBlack');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkBlue() {
    [string]$snippet = $this.Snippets('bgDarkBlue');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkGreen() {
    [string]$snippet = $this.Snippets('bgDarkGreen');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkCyan() {
    [string]$snippet = $this.Snippets('bgDarkCyan');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkRed() {
    [string]$snippet = $this.Snippets('bgDarkRed');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkMagenta() {
    [string]$snippet = $this.Snippets('bgDarkMagenta');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkYellow() {
    [string]$snippet = $this.Snippets('bgDarkYellow');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgGray() {
    [string]$snippet = $this.Snippets('bgGray');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgDarkGray() {
    [string]$snippet = $this.Snippets('bgDarkGray');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgBlue() {
    [string]$snippet = $this.Snippets('bgBlue');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgGreen() {
    [string]$snippet = $this.Snippets('bgGreen');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgCyan() {
    [string]$snippet = $this.Snippets('bgCyan');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgRed() {
    [string]$snippet = $this.Snippets('bgRed');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgMagenta() {
    [string]$snippet = $this.Snippets('bgMagenta');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgYellow() {
    [string]$snippet = $this.Snippets('bgYellow');
    $this.Scribble($snippet);

    return $this;
  }

  [Scribbler] bgWhite() {
    [string]$snippet = $this.Snippets('bgWhite');
    $this.Scribble($snippet);

    return $this;
  }

  # +Utility+ -----------------------------------------------------------------
  #

  [string] Snippets ([string[]]$items) {
    [string]$result = [string]::Empty;
    foreach ($i in $items) {
      $result += $($this.Krayon.ApiFormat -f $i);
    }
    return $result;
  }

  [string] WithArgSnippet([string]$method, [string]$arg) {
    return "$($this.Krayon.ApiFormatWithArg -f $method, $arg)";
  }

  [string] PairSnippet([couplet]$pair) {
    [string]$key = $this._escape($pair.Key);
    [string]$value = $this._escape($pair.Value);

    [string]$csv = "$($key),$($value),$($pair.Affirm)";
    [string]$pairSnippet = $this.WithArgSnippet(
      'Pair', $csv
    )
    return $pairSnippet;
  }

  [string] LineSnippet([line]$line) {
    [string]$structuredLine = $(($line.Line | ForEach-Object {
          "$($this._escape($_.Key)),$($this._escape($_.Value)),$($_.Affirm)"
        }) -join ';');

    [string]$lineSnippet = $this.WithArgSnippet(
      'Line', $structuredLine
    )
    return $lineSnippet;
  }

  # Other internal
  #
  hidden [void] _clear() {
    if ($this._session) {
      $this._session.Append($this.Builder);
    }

    $this.Builder.Clear();
  }

  hidden [string] _escape([string]$value) {
    return $value.Replace(';', '\;').Replace(',', '\,');
  }
} # Scribbler

class QuietScribbler: Scribbler {
  QuietScribbler([System.Text.StringBuilder]$builder, [Krayon]$krayon,
    [System.Text.StringBuilder]$Session):base($builder, $krayon, $Session) { }

  [void] Flush () {
    $this._clear();
  }
} # QuietScribbler

function New-Krayon {
  <#
  .NAME
    New-Krayon

  .SYNOPSIS
    Helper factory function that creates Krayon instance.

  .DESCRIPTION
    The client can specify a custom regular expression and corresponding
  formatters which together support the scribble functionality (the ability
  to invoke krayon functions via a 'structured' string as opposed to calling
  the methods explicitly). Normally, the client can accept the default
  expression and formatter arguments. However, depending on circumstance,
  a custom pattern can be supplied along with corresponding formatters. The
  formatters specified MUST correspond to the pattern and if they don't, then
  an exception is thrown.
    The default tokens used are as follows:

  * lead: 'µ'
  * open: '«'
  * close: '»'

  So this means that to invoke the 'red' function on the Krayon, the client
  should invoke the Scribble function with the following 'structured' string:
  'µ«red»'.
  To invoke a command which requires a parameter eg 'Message', the client needs
  to specify a string like: 'µ«Message,Greetings Earthlings»'. (NB: instructions
  are case insensitive). (Please note, that custom regular expressions do not have
  to have 'lead', 'open' and 'close' tokens as illustrated here; these are just
  what are used by default. The client can define any expression with formatters
  as long as it able to capture method calls with a single optional parameter.)

  However, please do not specify a literal string like this. If scribble functionality
  is required, then the Scribbler object should be used. The scribbler
  contains helper functions 'Snippets' and 'WithArgSnippet'.
  'Snippets', which when given an array of instructions will return the correct
  structured string. So to 'Reset', set the foreground colour to red and the
  background colour to black: $scribbler.Snippets(@('Reset', 'red', 'black'))
  which would return 'µ«Reset»µ«red»µ«black»'.

  And 'WithArgSnippet' for the above Message example, the client should use
  the following:

  [string]$snippet = $scribbler.WithArgSnippet('Message', 'Greetings Earthlings');

  $scribbler.Scribble($snippet);

  This is so that if for any reason, the expression and corresponding formatters
  need to be changed, then no other client code would be affected.

  And for completeness, an invoke requiring compound param representation eg to invoke
  the 'Line' method would be defined as:

  'one,Eve of Destruction;two,Bango' => this is a line with 2 couplets
  which would be invoked like so:

  [string]$snippet = $scribbler.WithArgSnippet('one,Eve of Destruction;two,Bango');

  and to Invoke 'Line' with a message:

  'Greetings Earthlings;one,Eve of Destruction;two,Bango'

  if you look at the first segment, you will see that it contains no comma. The scribbler
  will interpret the first segment as a message with subsequent segments containing
  valid comma separated values, split by semi-colons. (Be careful to construct this string
  properly; if a segment does not contain a comma (except for the first segment), then
  will likely be an error).

  And if the message required, includes a comma, then it should be escaped with a
  back slash '\':

  'Greetings\, Earthlings;one,Eve of Destruction;two,Bango'.

  .PARAMETER Expression
  A custom regular expression pattern than capture a Krayon method method call and an optional
  parameter. The expression MUST contain the following 2 named capture groups:

  * 'method': string to represent a method call on the Krayon instance.
  * 'p': optional string to represent a parameter passed into the function denoted by 'method'.

  Instructions can either have 0 or 1 argument. When an argument is specified that must represent
  a compound value (multiple items), then a compound representation must be used,
  eg a couplet is represented by a comma separated string and a line is represented
  by a semi-colon separated value, where the value inside each semi-colon segment is
  a pair represented by a comma separated value.

  .PARAMETER NativeExpression
    A custom regular expression pattern that recognises the content interpreted by the Krayon Scribble
  method. The 'inverse' native expression parses a structured string and returns the core text stripped
  of any method tokens.

  .PARAMETER Theme
  A hashtable instance containing the Krayola theme.

  .PARAMETER WriterFormat
    Format string that represents a Krayon method method call without an argument. This format
  needs to conform to the regular expression pattern specified by Expression.

  .PARAMETER WriterFormatWithArg
    Format string that represents a Krayon method method call with an argument. This format needs
  to conform to the regular expression pattern specified by Expression. This format must
  accommodate a single parameter.
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  [OutputType([Krayon])]
  param(
    [Parameter()]
    [hashtable]$Theme = $(Get-KrayolaTheme),

    [Parameter()]
    # OLD: '&\[(?<method>[\w]+)(,(?<p>[^\]]+))?\]'
    [regex]$Expression = [regex]::new("µ«(?<method>[\w]+)(,(?<p>[^»]+))?»"),

    [Parameter()]
    # OLD: '&[{0},{1}]'
    [string]$WriterFormatWithArg = "µ«{0},{1}»",

    [Parameter()]
    # OLD: '&[{0}]'
    [string]$WriterFormat = "µ«{0}»",

    [Parameter()]
    # OLD: '&\[[\w\s\-_]+(?:,\s*[\w\s\-_]+)?\]'
    [string]$NativeExpression = [regex]::new("µ«[\w\s\-_]+(?:,\s*[\w\s\-_]+)?»")
  )

  [string]$dummyWithArg = $WriterFormatWithArg -replace "\{\d{1,2}\}", 'dummy';
  if (-not($Expression.IsMatch($dummyWithArg))) {
    throw "New-Krayon: invalid WriterFormatWithArg ('$WriterFormatWithArg'), does not match the provided Expression: '$($Expression.ToString())'";
  }

  [string]$dummy = $WriterFormat -replace "\{\d{1,2}\}", 'dummy';
  if (-not($Expression.IsMatch($dummy))) {
    throw "New-Krayon: invalid WriterFormat ('$WriterFormat'), does not match the provided Expression: '$($Expression.ToString())'";
  }
  return [Krayon]::new($Theme, $Expression, $WriterFormatWithArg, $WriterFormat, $NativeExpression);
} # New-Krayon

function New-Line {
  <#
  .NAME
    New-Line

  .SYNOPSIS
    Helper factory function that creates Line instance.

  .DESCRIPTION
    A Line is a wrapper around a collection of couplets.

  .PARAMETER Krayon
    The underlying krayon instance that performs real writes to the host.

  .PARAMETER couplets
    Collection of couplets to create Line with.
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  [OutputType([line])]
  [Alias('kl')]
  param(
    [Parameter()]
    [couplet[]]$couplets = @()
  )
  return [line]::new($couplets);
} # New-Line

<#
.NAME
  New-Pair

.SYNOPSIS
  Helper factory function that creates a couplet instance.

.DESCRIPTION
  A couplet is logically 2 items, but can contain a 3rd element representing
its 'affirmed' status. An couplet that is affirmed is one that can be highlighted
according to the Krayola theme (AFFIRM-COLOURS).

.PARAMETER couplet
  A 2 or 3 item array representing a key/value pair and optional affirm boolean.
#>
function New-Pair {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  [OutputType([couplet])]
  [Alias('kp')]
  param(
    [Parameter()]
    [string[]]$couplet
  )
  return ($couplet.Count -ge 3) `
    ? [couplet]::new($couplet[0], $couplet[1], [System.Convert]::ToBoolean($couplet[2])) `
    : [couplet]::new($couplet[0], $couplet[1]);
} # New-Pair

function New-Scribbler {
  <#
  .NAME
    New-Scribbler

  .SYNOPSIS
    Helper factory function that creates a Scribbler instance.

  .DESCRIPTION
    Creates a new Scribbler instance with the optional krayon provided. The scribbler acts
  like a wrapper around the Krayon so that control can be exerted over where the output is
  directed to. In an interactive environment, clearly, the user needs to see the output so
  the Scribbler will direct the Krayon to render output to the console. However, within the
  context of a unit test the output needs to be suppressed. This is achieved by creating
  a Quiet Scribbler achieved by setting the Test switch or forcing it via the Silent switch.

  .PARAMETER Krayon
    The underlying krayon instance that performs real writes to the host.

  .PARAMETER Test
    switch to indicate if this is being invoked from a test case, so that the
  output can be suppressed if appropriate. By default, the test cases should be
  quiet. During development and test stage, the user might want to see actual
  output in the test output. The presence of variable 'EliziumTest' in the
  environment will enable verbose tests. When invoked by an interactive user in
  production environment, the Test flag should not be set. Doing so will suppress
  the output depending on the presence 'EliziumTest'. ALL test cases should
  specify this Test flag. This also applies to third party users building tests for commands
  that use the Scribbler.

  .PARAMETER Save
    switch to indicate if the Scribbler should record all output which will be
  saved to file for future playback.

  .PARAMETER Silent
    switch to force the creation of a Quiet Scribbler. Can not be specified at the
  same time as Test (although not currently enforced). Silent overrides Test.
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  [OutputType([Scribbler])]
  param(
    [Parameter()]
    [Krayon]$Krayon = $(New-Krayon),

    [Parameter()]
    [switch]$Test,

    [Parameter()]
    [switch]$Save,

    [Parameter()]
    [switch]$Silent
  )
  [System.text.StringBuilder]$builder = [System.text.StringBuilder]::new();
  [System.text.StringBuilder]$session = $Save.IsPresent ? [System.text.StringBuilder]::new() : $null;

  [Scribbler]$scribbler = if ($Silent) {
    [QuietScribbler]::New($builder, $Krayon, $null);
  }
  elseif ($Test) {
    $($null -eq (Get-EnvironmentVariable 'EliziumTest')) `
      ? [QuietScribbler]::New($builder, $Krayon, $session) `
      : [Scribbler]::New($builder, $Krayon, $session);
  }
  else {
    [Scribbler]::New($builder, $Krayon, $session);
  }

  return $scribbler;
} # New-Scribbler
