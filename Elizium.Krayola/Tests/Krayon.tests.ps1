using namespace System.Text;

Describe 'Krayon' {
  BeforeAll {
    InModuleScope Elizium.Krayola {
      Get-Module Elizium.Krayola | Remove-Module -Force
      Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
        -ErrorAction 'stop' -DisableNameChecking;

      # There are some tests (tagged 'Host') in this suite which do not use the scribbler
      # which means their output is sent to the console, making the tests noisy. This has
      # been keep to a minimum, but those tests in this category would become invalid tests
      # if they were modified to not send the output to the console.
      #
    }
  }

  BeforeEach {
    InModuleScope Elizium.Krayola {
      [hashtable]$global:_theme = $(Get-KrayolaTheme);
      [Krayon]$global:_krayon = New-Krayon -Theme $_theme;
      [Scribbler]$global:_scribbler = New-Scribbler -Krayon $_krayon -Test;

      [string]$global:_redSnippet = $_scribbler.Snippets(@('red'));
      [string]$global:_blueSnippet = $_scribbler.Snippets(@('blue'));
      [string]$global:_yellowSnippet = $_scribbler.Snippets(@('yellow'));
      [string]$global:_greenSnippet = $_scribbler.Snippets(@('green'));
      [string]$global:_whiteSnippet = $_scribbler.Snippets(@('white'));
      [string]$global:_magentaSnippet = $_scribbler.Snippets(@('magenta'));
      [string]$global:_cyanSnippet = $_scribbler.Snippets(@('cyan'));
      [string]$global:_graySnippet = $_scribbler.Snippets(@('gray'));
      [string]$global:_blackSnippet = $_scribbler.Snippets(@('black'));
      [string]$global:_bgDarkMagentaSnippet = $_scribbler.Snippets(@('bgDarkMagenta'));
      [string]$global:_bgDarkCyanSnippet = $_scribbler.Snippets(@('bgDarkCyan'));
      [string]$global:_bgDarkBlueSnippet = $_scribbler.Snippets(@('bgDarkBlue'));
      [string]$global:_bgMagentaSnippet = $_scribbler.Snippets(@('bgMagenta'));
      [string]$global:_bgCyanSnippet = $_scribbler.Snippets(@('bgCyan'));
      [string]$global:_bgRedSnippet = $_scribbler.Snippets(@('bgRed'));
      [string]$global:_bgYellowSnippet = $_scribbler.Snippets(@('bgYellow'));

      [string]$global:_lnSnippet = $_scribbler.Snippets(@('Ln'));
      [string]$global:_resetSnippet = $_scribbler.Snippets(@('Reset'));

      [string]$global:_structuredSoloLn = $(
        "$($_resetSnippet){0}$($_lnSnippet)"
      );

      [string]$global:_structuredSolo = $(
        "$($_resetSnippet){0}"
      );

      [string]$global:_ThemeColourAffirmSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'affirm');
      [string]$global:_ThemeColourKeySnippet = $_scribbler.WithArgSnippet('ThemeColour', 'key');
      [string]$global:_ThemeColourMessageSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'message');
      [string]$global:_ThemeColourMetaSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'meta');
      [string]$global:_ThemeColourValueSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'value');
    }
  }

  AfterEach {
    InModuleScope Elizium.Krayola {
      $_scribbler.Flush();
    }
  }

  Context 'given: ad-hoc' {
    It 'should: write in colour' {
      InModuleScope Elizium.Krayola {
        $_scribbler.Scribble(
          "$($_resetSnippet)$($_redSnippet)Are you master of your domain? " +
          "$($_blueSnippet)Yeah, I'm still king of the county!$($_lnSnippet)" +

          "$($_redSnippet)$($_bgMagentaSnippet)Are you master of your domain? " +
          "$($_blueSnippet)$($_bgDarkCyanSnippet)Yeah, Im still lord of the manner!$($_lnSnippet)"
        );
      }
    } # should: write in colour

    It 'should: write in theme colours' {
      InModuleScope Elizium.Krayola {
        $_scribbler.Scribble(
          "$($_resetSnippet)" +
          "$($_ThemeColourAffirmSnippet)This is affirmed text$($_lnSnippet)" +
          "$($_ThemeColourKeySnippet)This is key text$($_lnSnippet)" +
          "$($_ThemeColourMessageSnippet)This is message text$($_lnSnippet)" +
          "$($_ThemeColourMetaSnippet)This is meta text$($_lnSnippet)" +
          "$($_ThemeColourValueSnippet)This is value text$($_lnSnippet)"
        )
      }
    } # should: write in theme colours

    Context 'and: style' {
      It 'should: not affect text display' {
        InModuleScope Elizium.Krayola {
          [string]$boldSnippet = $_scribbler.Snippets(@('bold'));
          [string]$italicSnippet = $_scribbler.Snippets(@('italic'));
          [string]$strikeSnippet = $_scribbler.Snippets(@('strike'));
          [string]$underSnippet = $_scribbler.Snippets(@('under'));

          $_scribbler.Scribble(
            "$($_resetSnippet)" +
            "$($boldSnippet)This is *bold* text$($_lnSnippet)" +
            "$($italicSnippet)This is /italic/ text$($_lnSnippet)" +
            "$($strikeSnippet)This is s-t-r-i-k-e--t-h-r-u text$($_lnSnippet)" +
            "$($underSnippet)This is _underlined_ text$($_lnSnippet)"
          );
        }
      }
    } # and: style

    Context 'and: text with background colour and new line' {
      It 'should: write text with background without flooding with background colour' {
        InModuleScope Elizium.Krayola {
          $_scribbler.Scribble(
            "$($_resetSnippet)" +
            "$($_blackSnippet)$($_bgCyanSnippet)Text with background colour$($_lnSnippet)"
          );
        }
      }
    }
  } # given: ad-hoc

  Context 'given: pair' {
    Context 'and: pair is PSCustomObject' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {          
          [string]$pairSnippet = $_scribbler.WithArgSnippet('Pair', 'Album,Pungent Effulgent,true');
          $_scribbler.Scribble(
            ($_structuredSoloLn -f $pairSnippet)
          );

          [string]$pairSnippet = $_scribbler.WithArgSnippet('PairLn', 'Nine,Wreltch');
          $_scribbler.Scribble(
            ($_structuredSolo -f $pairSnippet)
          );
        }
      }
    }

    Context 'and: pair created via default constructor' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = [couplet]::new();
          $couplet.Key = 'Album';
          $couplet.Value = 'Pungent Effulgent';
          $couplet.Affirm = $true;
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = [couplet]::new();
          $couplet.Key = 'Artist';
          $couplet.Value = 'Ozric Tentacles';

          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via default constructor

    Context 'and: pair created via array constructor' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [string[]]$properties = @('One', 'Dissolution (The Clouds Disperse)', $true);
          [couplet]$couplet = [couplet]::new($properties);
          $_krayon.Pair($couplet).Ln();

          [string[]]$properties = @('Two', '0-1');
          [couplet]$couplet = [couplet]::new($properties);

          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via array constructor

    Context 'and: pair created via discrete parameter constructor' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = [couplet]::new('Three', 'Phalarn Dawn', $true);
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = [couplet]::new('Four', '04 - The Domes of G''Bal', $false);
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via discrete parameter constructor

    Context 'and: pair created via New-Pair' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = $(New-Pair @('Five', 'Shaping the Pelm', $true));
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = $(New-Pair @('six', '06 - Ayurvedic'));
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via New-Pair

    Context 'and: pair created via kp alias' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = $(kp(@('Seven', 'Kick Muck', $true)));
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = $(kp(@('Eight', 'Agog in the Ether')));
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via kp alias

    Context 'and: Scribbled Pair' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [string]$pairSnippet = $_scribbler.WithArgSnippet('Pair', 'Blue Amazon,Long Way home');

          $_scribbler.Scribble(
            ($_structuredSoloLn -f $pairSnippet)
          );
        }
      }
    }

    Context 'and: Scribbled Pair with escaped comma' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [string]$pairSnippet = $_scribbler.WithArgSnippet('Pair', $(
              'Subversive,Blue Amazon\,Long Way home,true'
            ));

          $_scribbler.Scribble(
            ($_structuredSoloLn -f $pairSnippet)
          );
        }
      }

      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [string]$pairSnippet = $_scribbler.WithArgSnippet('Pair', $(
              'Subversive\,Blue Amazon,Long Way home'
            ));

          $_scribbler.Scribble(
            ($_structuredSoloLn -f $pairSnippet)
          );
        }
      }
    }
  } # given: pair

  Context 'given: line' {
    Context 'and: without message' {
      It 'should: write line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'art vanderlay')),
            $(kp('occupation', 'architect')),
            $(kp('quip', "i'm back baby, i'm back", $true))
          );

          $_krayon.Line($(kl($pairs)));
        }
      }

      It 'should: write naked line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'art vanderlay')),
            $(kp('occupation', 'architect')),
            $(kp('quip', "i'm back baby, i'm back", $true)),
            $(kp('radiccio ', "the naked and the dead", $true))
          );

          $_krayon.NakedLine($(kl($pairs)));
        }
      }
    } # and: without message

    Context 'and: with message' {
      It 'should: write line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'frank')),
            $(kp('festivity', "The airance of grievances", $true))
          );

          [string]$message = 'Festivus for the rest of us';
          $_krayon.Line($message, $(kl($pairs)));
        }
      }

      It 'should: write naked line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'frank')),
            $(kp('festivity', "The airance of grievances", $true)),
            $(kp('radiccio ', "the naked and the dub", $true))
          );

          [string]$message = 'Festivus for the rest of us';
          $_krayon.NakedLine($message, $(kl($pairs)));
        }
      }
    } # and: with message

    Context 'and: append to line' {
      It 'should: write line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [array]$originalLine = @(
            $(kp('one', '(Dead But Dreaming)')),
            $(kp('two', "For her light", $true))
          );
          $appendLine = $(kl($originalLine));
          $appendLine.append($(kp('three', 'At The Gates Of Silent Memory')));

          [array]$otherAppend = @(
            $(kp('four', '(Paradise Regained)')),
            $(kp('five', "Submission", $true)),
            $(kp('six', "Sumerland (What Dreams May Come)", $true))
          );
          $otherLine = $(kl($otherAppend));        
          $appendLine.append($otherLine.Line);

          $_krayon.Line($appendLine);
          $appendLine.Line.Length | Should -Be 6;
        }
      } # should: write line

      It 'should: write line' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [line]$originalLine = kl(@(
              $(kp('one', 'Eve of Destruction')),
              $(kp('two', 'Bango', $true)),
              $(kp('three', "No Geography"))
            ));

          [line]$appendLine = kl(@(
              $(kp('four', 'Got to Keep On', $true)),
              $(kp('five', 'Gravity Drops')),
              $(kp('six', 'No Geography', $true))
            ));
          $originalLine.append($appendLine);

          $_krayon.Line($originalLine);
          $originalLine.Line.Length | Should -Be 6;
        }
      } # should: write line
    } # and: append to line

    Context 'and: Scribbled Line' {
      It 'should: write line' {
        InModuleScope Elizium.Krayola {
          [string]$lineSnippet = `
            $_scribbler.WithArgSnippet('Line', $(
              'one,MoonChild;two,Infinite Dreams;three,Can I Play With Madness'
            ));

          $_scribbler.Scribble(
            ($_structuredSolo -f $lineSnippet)
          );
        }
      }
    }

    Context 'and: Scribbled Line with message' {
      It 'should: write line' {
        InModuleScope Elizium.Krayola {
          [string]$lineSnippet = `
            $_scribbler.WithArgSnippet('Line', $(
              'greetings earthlings;four,The Evil That Men Do;five,Seventh Son;six,The Prophecy'
            ));

          $_scribbler.Scribble(
            ($_structuredSolo -f $lineSnippet)
          );
        }
      }
    }

    Context 'and: Scribbled Line with escaped semi-colon' {
      It 'should: write line' {
        InModuleScope Elizium.Krayola {
          [string]$lineSnippet = `
            $_scribbler.WithArgSnippet('Line', $(
              'seven,The Clairvoyant;eight,Only The Good Die Young\; Iron Maiden'
            ));

          $_scribbler.Scribble(
            ($_structuredSolo -f $lineSnippet)
          );
        }
      }
    }
  } # given: line

  Describe 'Scribble' {
    Context 'given: Custom expression' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          [regex]$expression = [regex]::new('`\((?<api>[\w]+)(,(?<p>[^\)]+))?\)');
          [string]$formatWithArg = '`({0},{1})';
          [string]$format = '`({0})';
          [regex]$nativeExpression = [regex]::new('');
          [krayon]$Krayon = New-Krayon $_theme $expression $formatWithArg $format $nativeExpression;

          [string]$source = $(
            '`(red)Fields `(blue)Of The `(cyan)`(bgDarkMagenta)Nephilim, Love `(green)Under Will`(Ln)'
          );

          [Scribbler]$scribbler = New-Scribbler -Krayon $krayon -Test;

          $scribbler.Scribble($source);
          $scribbler.Flush();

          [PSCustomObject []]$operations = $Krayon._parse($source);
          $operations | Should -HaveCount 10;
        
        }
      }
    } # given: Custom expression

    Context 'given: Default expression using special UTF-8 code-points' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          #
          # http://www.wizcity.com/Computers/Characters/CommonUTF8.php

          [string]$lead = 'µ'; # (micro sign)
          [string]$open = '«'; # (left pointing guillemet)
          [string]$close = '»'; # (right pointing guillemet)

          # "µ«(?<api>[\w]+)(,(?<p>[^»]+))?»"
          #
          [regex]$expression = [regex]::new(
            "$($lead)$($open)(?<api>[\w]+)(,(?<p>[^$($close)]+))?$($close)"
          );

          # "µ«{0},{1}»"
          #
          [string]$formatWithArg = $(
            "$($lead)$($open){0},{1}$($close)"
          );

          # "µ«{0}»"
          #
          [string]$format = $("$($lead)$($open){0}$($close)");

          # "µ«[\w\s\-_]+(?:,\s*[\w\s\-_]+)?»"
          #
          [regex]$nativeExpression = [regex]::new(
            "$($lead)$($open)[\w\s\-_]+(?:,\s*[\w\s\-_]+)?$($close)"
          );
          [krayon]$krayon = New-Krayon $_theme $expression $formatWithArg $format $nativeExpression;

          [Scribbler]$scribbler = New-Scribbler -Krayon $krayon -Test;

          [string]$source = $(
            "`(red)Fields `(blue)Of The `(cyan)`(bgDarkMagenta)Nephilim, Love `(green)Under Will`(Ln)"
          );

          [string]$redSnippet = $scribbler.Snippets(@('red'));
          [string]$blueSnippet = $scribbler.Snippets(@('blue'));
          [string]$cyanSnippet = $scribbler.Snippets(@('cyan'));
          [string]$bgDarkMagentaSnippet = $scribbler.Snippets(@('bgDarkMagenta'));
          [string]$greenSnippet = $scribbler.Snippets(@('green'));
          [string]$lnSnippet = $scribbler.Snippets(@('Ln'));

          [string]$source = $(
            "$($redSnippet)Fields $($blueSnippet)Of The $($cyanSnippet)$($bgDarkMagentaSnippet)" +
            "Nephilim, Love $($greenSnippet)Under Will$($lnSnippet)"
          );

          $scribbler.Scribble($source);
          $scribbler.Flush();

          [PSCustomObject []]$operations = $krayon._parse($source);
          $operations | Should -HaveCount 10;
        }
      }
    }

    Context 'and: valid structured string' {
      Context 'and: leading text snippet' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "I need to be alone $($_redSnippet)today";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 3;
            }
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "Smother $($_cyanSnippet)me or $($_blueSnippet)suffer $($_greenSnippet)me";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "Lay $($_redSnippet)$($_magentaSnippet)down I'll die today";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 4;
            }
          }
        } # and: multiple api calls

        Context 'and: api invoke with param' {
          Context 'and: Message' {
            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$message = '*** Love under will';
                [string]$messageSnippet = $_scribbler.WithArgSnippet('Message', $message);

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($messageSnippet)$($_lnSnippet)"
                );
              }
            }

            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$message = '!!! Love under will';
                [string]$messageSnippet = $_scribbler.WithArgSnippet('MessageLn', $message);

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($messageSnippet)"
                );
              }
            }
          }

          Context 'and: ThemeColour' {
            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$source = 'Love under will';
                [string]$themeColourSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'affirm');

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($themeColourSnippet)$($source)$($_lnSnippet)"
                );
              }
            }
          }
        } # and: api invoke with param
      } # and: leading text snippet

      Context 'given: leading api call' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_cyanSnippet)Smother me or suffer me";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;
            }
          }

          Context 'and: with api param' {
            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = $_scribbler.WithArgSnippet('message', 'Love Under Will');

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($source)$($_lnSnippet)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 1;
              }
            }
          }
        } # and: single api call

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_cyanSnippet)When $($_redSnippet)I'm gone $($_yellowSnippet)wait here";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 6;        
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = $(
                "$($_cyanSnippet)Discover $($_redSnippet)$($_bgYellowSnippet)all of $($_magentaSnippet)life's surprises"
              );

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)$($_lnSnippet)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          Context 'and: with api param' {
            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$messageSnippet = $_scribbler.WithArgSnippet('Message', 'Love Under Will');
                [string]$source = "The Nephilim; $($messageSnippet)$($_redSnippet)*The Winter Solstace";

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($source)$($_lnSnippet)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 4;
              }
            }

            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = $(
                  "$($_ThemeColourMetaSnippet)[🚀] ====== [ $($_ThemeColourMessageSnippet)Children of the Damned$($($_ThemeColourMetaSnippet)) ] ==="
                );

                $_scribbler.Scribble(
                  "$($_resetSnippet)$($source)$($_lnSnippet)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 6;
              }
            }
          }
        } # and: multiple api calls
      } # given: leading api call

      Context 'given: trailing api call' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "When I'm gone wait here$($_lnSnippet)";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;        
            }
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_whiteSnippet)When $($_greenSnippet)I'm gone $($_yellowSnippet)wait here$($_lnSnippet)";

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = $(
                "I'll $($_greenSnippet)send my child my last $($_yellowSnippet)$($_bgDarkBlueSnippet)good smile$($_lnSnippet)"
              );

              $_scribbler.Scribble(
                "$($_resetSnippet)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;        
            }
          }
        }
      } # given: trailing api call

      Context 'and: empty string' {
        It 'should: ignore' {
          InModuleScope Elizium.Krayola {
            {
              [string]$source = [string]::Empty;
              $_krayon.Scribble($source);
            } | Should -Not -Throw;
          }
        }
      }
    } # and: valid structured string

    Context 'and: Scribble.Pair' {
      Context 'and: Key containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('two, Never Forget', 'Blue Amazon'));

            [string]$pairSnippet = $_scribbler.Pair($pair);
            $pairSnippet | Should -Match 'two\\,';

            $_scribbler.Scribble("$($pairSnippet)$($_lnSnippet)");
          }
        }
      }

      Context 'and: Value containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('three', 'Searching, Blue Amazon'));

            [string]$pairSnippet = $_scribbler.Pair($pair);
            $pairSnippet | Should -Match 'Searching\\,';

            $_scribbler.Scribble("$($pairSnippet)$($_lnSnippet)");
          }
        }
      }

      Context 'and: Key containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('four; The Runner', 'Blue Amazon'));

            [string]$pairSnippet = $_scribbler.Pair($pair);
            $pairSnippet | Should -Match 'four\\;';

            $_scribbler.Scribble("$($pairSnippet)$($_lnSnippet)");
          }
        }
      }

      Context 'and: Value containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('five', 'The Javelin; Blue Amazon'));

            [string]$pairSnippet = $_scribbler.Pair($pair);
            $pairSnippet | Should -Match 'The Javelin\\;';

            $_scribbler.Scribble("$($pairSnippet)$($_lnSnippet)");
          }
        }
      }
    } # Scribble.Pair

    Context 'Scribble.Line' {
      Context 'and: Key containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('one, Doubleplusgood', 'Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSnippet = $_scribbler.Line($line);
            $lineSnippet | Should -Match 'one\\,';

            $_scribbler.Scribble("$($lineSnippet)");
          }
        }
      }

      Context 'and: Value containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('two', 'For The Love Of Big Brother, Eurythmics')); ;
            [line]$line = New-Line(@($pair));

            [string]$lineSnippet = $_scribbler.Line($line);
            $lineSnippet | Should -Match 'Brother\\,';

            $_scribbler.Scribble("$($lineSnippet)");
          }
        }
      }

      Context 'and: Key containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('three; The Runner', 'Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSnippet = $_scribbler.Line($line);
            $lineSnippet | Should -Match 'three\\;';

            $_scribbler.Scribble("$($lineSnippet)");
          }
        }
      }

      Context 'and: Value containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('four', 'I Did It Just The Same; Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSnippet = $_scribbler.Line($line);
            $lineSnippet | Should -Match 'Same\\;';

            $_scribbler.Scribble("$($lineSnippet)");
          }
        }
      }
    } # Scribble.Line

    Context 'and: invalid structured string' {
      Context 'and: invalid colour' {
        It 'should: throw' {
          InModuleScope Elizium.Krayola {
            {
              [string]$orangeSnippet = $_scribbler.Snippets(@('orange'));
              [string]$source = "I'll love her 'til i $($orangeSnippet)die$($_lnSnippet)";
              $_krayon.Scribble($source);
            } | Should -Throw;
            Write-Host '';        
          }
        }
      }

      Context 'and: structure string contains an invalid call to "Text"' {
        It 'should: throw' {
          InModuleScope Elizium.Krayola {
            {
              [string]$textSnippet = $_scribbler.Snippets(@('Text'));
              [string]$source = "Then rest in peace can't you $($textSnippet)see$($_lnSnippet)";
              $_krayon.Scribble($source);
            } | Should -Throw;
            Write-Host '';        
          }
        }
      }
    }

    Context 'given: non colour api calls' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          [string]$source = "$($_bgRedSnippet)If you pass $($_resetSnippet)through my soul tonight$($_lnSnippet)";

          $_scribbler.Scribble(
            "$($_resetSnippet)$($source)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 5;
        }
      }
    }

    Context 'given: Vanilla string' {
      It 'should: write test as is' {
        InModuleScope Elizium.Krayola {
          [string]$source = 'Gather all his troubles';

          $_scribbler.Scribble(
            "$($_resetSnippet)$($source)$($_lnSnippet)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 1;
        }
      }
    }

    Context 'given: unusual string' {
      It 'should: should not write any text' {
        InModuleScope Elizium.Krayola {
          [string]$source = "$($_redSnippet)" * 6;
          $_scribbler.Scribble(
            "$($_resetSnippet)$($source)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 6;
        }
      }
    }
  } # Scribble

  Describe 'ScribbleLine' {
    Context 'given: line with with pair Key containing a comma' {
      It 'should: escape and scribble line' {
        InModuleScope Elizium.Krayola {
          [line]$line = $(New-Line(@(
                $(New-Pair('What is the answer to life, love and unity', 'Fourty Two'))
              )));

          $_scribbler.ScribbleLine($line);
          $_scribbler.Builder | Should -Match 'life\\,';
        }
      }
    }

    Context 'given: line with with pair Value containing a comma' {
      It 'should: escape and scribble line' {
        InModuleScope Elizium.Krayola {
          [line]$line = $(New-Line(@(
                $(New-Pair('Fourty Two', 'What is the answer to life, love and unity'))
              )));

          $_scribbler.ScribbleLine($line);
          $_scribbler.Builder | Should -Match 'life\\,';
        }
      }
    }

    Context 'given: line with with pair Key containing a semi-colon' {
      It 'should: escape and scribble line' {
        InModuleScope Elizium.Krayola {
          [line]$line = $(New-Line(@(
                $(New-Pair('What is the answer to life; love and unity', 'Fourty Two'))
              )));

          $_scribbler.ScribbleLine($line);
          $_scribbler.Builder | Should -Match 'life\\;';
        }
      }
    }

    Context 'given: line with with pair Value containing a semi-colon' {
      It 'should: escape and scribble line' {
        InModuleScope Elizium.Krayola {
          [line]$line = $(New-Line(@(
                $(New-Pair('Fourty Two', 'What is the answer to life; love and unity'))
              )));

          $_scribbler.ScribbleLine($line);
          $_scribbler.Builder | Should -Match 'life\\;';
        }
      }
    }
  } # ScribbleLine

  Describe 'ScribbleNakedLine' {
    Context 'given: line' {
      It 'should: render line without open and close' {
        InModuleScope Elizium.Krayola {
          [line]$line = $(New-Line(@(
                $(New-Pair('Naked', 'The Emperor has no clothes'))
              )));

          $_scribbler.ScribbleNakedLine($line);

          $_scribbler.Builder | Should -Match 'Naked';
          $_scribbler.Builder | Should -Match 'The Emperor has no clothes';
          $_scribbler.Builder | Should -Not -Match '\[';
          $_scribbler.Builder | Should -Not -Match '\]';
        }
      }
    }
  }

  Describe 'given: native' {
    Context 'and: structured string with api invokes without arguments' {
      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = "$($_redSnippet)hello world";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = "hello world$($_blueSnippet)";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = "hello $($_greenSnippet)world";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = "who $($_magentaSnippet)watches $($_cyanSnippet)the $($_graySnippet)watchers";
          [string]$expected = 'who watches the watchers';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }
    }

    Context 'and: structured string with api invokes without arguments' {
      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$snippet = $_scribbler.WithArgSnippet('fore', 'red');
          [string]$structured = "$($snippet)hello world";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$snippet = $_scribbler.WithArgSnippet('back', 'blue');
          [string]$structured = "hello world$($snippet)";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$snippet = $_scribbler.WithArgSnippet('ThemeColour', 'green');
          [string]$structured = "hello $($snippet)world";
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$themeMagentaSnippet = $_scribbler.WithArgSnippet('ThemeColour', 'magenta');
          [string]$messageSnippet = $_scribbler.WithArgSnippet('Message', 'Silk Spectre');
          [string]$graySnippet = $_scribbler.Snippets(@('gray'));
          [string]$structured = "who $($themeMagentaSnippet)watches $($messageSnippet)the $($graySnippet)watchers";
          [string]$expected = 'who watches the watchers';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }
    }
  }

  Describe 'Scribbler.Snippets' {
    Context 'given: single api' {
      It 'should: return snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red');
          [string]$expected = "µ«red»";
          $_scribbler.Snippets($source) | Should -BeExactly $expected;
        }
      }
    }

    Context 'given: double api' {
      It 'should: return double snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red', 'bgRed');
          [string]$expected = 'µ«red»µ«bgRed»';
          $_scribbler.Snippets($source) | Should -BeExactly $expected;
        }
      }
    }
  }

  Describe 'Scribbler.Save' {
    It 'should: write scribbled content' {
      InModuleScope Elizium.Krayola {
        [string]$lineSnippet = `
          $_scribbler.WithArgSnippet('Line', $(
            'seven,The Clairvoyant;eight,Only The Good Die Young\; Iron Maiden'
          ));

        [string]$lineSnippet = `
          $_scribbler.WithArgSnippet('Line', $(
            'one,MoonChild;two,Infinite Dreams;three,Can I Play With Madness'
          ));

        [string[]]$source = @(
          'artist,Kraftwerk',
          'album,3-D / AutoBahn',
          'one,AutoBahn;two,Kometenmelodie 1',
          'three,Kometenmelodie 2;four,Mitternacht',
          'five,Morganspaziergang'
        );

        [string[]]$content = foreach ($l in $source) {
          $_scribbler.WithArgSnippet('Line', $l);
        }

        [Scribbler]$scribbler = New-Scribbler -Krayon $_krayon -Test -Save;

        foreach ($c in $content) {
          $scribbler.Scribble(
            ($_structuredSolo -f $c)
          );
        }
        $scribbler.Flush();

        [string]$date = Get-Date -Format 'dd-MMM-yyyy_HH-mm-ss'
        [string]$filename = "session_$($date).ps1";
        [string]$fullPath = Join-Path -Path $TestDrive -ChildPath $filename;
        $scribbler.Save($fullPath);
      }
    }
  }
} # Krayon

Describe 'line' {
  BeforeAll {
    InModuleScope Elizium.Krayola {
      Get-Module Elizium.Krayola | Remove-Module -Force
      Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
        -ErrorAction 'stop' -DisableNameChecking
    }
  }

  Context 'given: 2 equal lines' {
    It 'should: compare equal' {
      InModuleScope Elizium.Krayola {
        [line]$originalLine = $(kl(@(
              $(kp('one', 'Eve of Destruction')),
              $(kp('two', 'Bango', $true)),
              $(kp('three', "No Geography"))
            )));

        [line]$otherLine = $(kl(@(
              $(kp('one', 'Eve of Destruction')),
              $(kp('two', 'Bango', $true)),
              $(kp('three', "No Geography"))
            )));

        [boolean]$result = $originalLine.equal($otherLine);
        $result | Should -BeTrue;
      }
    }
  }

  Context 'given: 2 non equal lines' {
    It 'should: NOT compare equal' {
      InModuleScope Elizium.Krayola {
        [line]$originalLine = $(kl(@(
              $(kp('one', 'Eve of Destruction')),
              $(kp('two', 'Bango', $true)),
              $(kp('three', "No Geography"))
            )));

        [line]$otherLine = $(kl(@(
              $(kp('four', '(Paradise Regained)')),
              $(kp('five', "Submission", $true)),
              $(kp('six', "Sumerland (What Dreams May Come)", $true))
            )));

        [boolean]$result = $originalLine.equal($otherLine);
        $result | Should -BeFalse;
      }
    }
  }
}

Describe 'couplet' {
  BeforeAll {
    InModuleScope Elizium.Krayola {
      Get-Module Elizium.Krayola | Remove-Module -Force
      Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
        -ErrorAction 'stop' -DisableNameChecking
    }
  }

  Context 'given: 2 equal couplets' {
    It 'should: compare equal' {
      InModuleScope Elizium.Krayola {
        [couplet]$first = $(kp('one', 'Eve of Destruction'));
        [couplet]$second = $(kp('one', 'Eve of Destruction'));
        [boolean]$result = $first.cequal($second);
        $result | Should -BeTrue;

      }
    }
  }

  Context 'given: 2 non equal couplets' {
    It 'should: NOT compare equal' {
      InModuleScope Elizium.Krayola {
        [couplet]$first = $(kp('one', 'Eve of Destruction'));
        [couplet]$second = $(kp('two', 'Bango'));
        [boolean]$result = $first.cequal($second);
        $result | Should -BeFalse;
      }
    }

    Context 'and: differs by case only' {
      It 'should: NOT compare equal' {
        InModuleScope Elizium.Krayola {
          [couplet]$first = $(kp('one', 'Eve of Destruction'));
          [couplet]$second = $(kp('ONE', 'EVE of Destruction'));
          [boolean]$result = $first.cequal($second);
          $result | Should -BeFalse;
        }
      }
    }
  }
}

Describe 'Krayon code generator' {
  It 'should: generate colour methods' -Skip {
    # Use this test to make updates to colour methods, without having to code up
    # every method manually.
    #
    [array]$fgColours = @('black', 'darkBlue', 'darkGreen', 'darkCyan',
      'darkRed', 'darkMagenta', 'darkYellow', 'gray', 'darkGray', 'blue', 'green',
      'cyan', 'red', 'magenta', 'yellow', 'white');

    [array]$bgColours = @('bgBlack', 'bgDarkBlue', 'bgDarkGreen', 'bgDarkCyan',
      'bgDarkRed', 'bgDarkMagenta', 'bgDarkYellow', 'bgGray', 'bgDarkGray', 'bgBlue', 'bgGreen',
      'bgCyan', 'bgRed', 'bgMagenta', 'bgYellow', 'bgWhite');
      
    foreach ($col in $fgColours) {
      # Current state:
      #
      # [Krayon] black() {
      #   $this._fgc = 'black';
      #   return $this;
      # }
      # -----------------------------------------------

      $code = '[Krayon] {0}()';
      Write-Host "$($code -f $col)";
      Write-Host "{"

      $code = '   $this._fgc = ''{0}'';';
      Write-Host "$($code -f $col)";

      $code = '   return $this;';
      Write-Host "$code";
      Write-Host "}";

      Write-Host ""
    }

    foreach ($col in $bgColours) {
      $code = '[Krayon] {0}()';
      Write-Host "$($code -f $col)";
      Write-Host "{"

      $code = '   $this._bgc = ''{0}'';';
      Write-Host "$($code -f $col.Substring(2))";

      $code = '   return $this;';
      Write-Host "$code";
      Write-Host "}";

      Write-Host ""
    }
  }  
} # Krayon code generator
