using namespace System.Text;

Describe 'Scribbler' -Tag 'Scribbler' {
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

      [string]$global:_lnSn = $_scribbler.Snippets(@('Ln'));
      [string]$global:_resetSn = $_scribbler.Snippets(@('Reset'));

      [string]$global:_redSn = $_scribbler.Snippets(@('red'));
      [string]$global:_blueSn = $_scribbler.Snippets(@('blue'));
      [string]$global:_cyanSn = $_scribbler.Snippets(@('cyan'));
      [string]$global:_yellowSn = $_scribbler.Snippets(@('yellow'));
      [string]$global:_magentaSn = $_scribbler.Snippets(@('magenta'));
      [string]$global:_blackSn = $_scribbler.Snippets(@('black'));
      [string]$global:_greenSn = $_scribbler.Snippets(@('green'));
      [string]$global:_whiteSn = $_scribbler.Snippets(@('white'));
      [string]$global:_bgDarkCyanSn = $_scribbler.Snippets(@('bgDarkCyan'));
      [string]$global:_bgMagentaSn = $_scribbler.Snippets(@('bgMagenta'));
      [string]$global:_bgCyanSn = $_scribbler.Snippets(@('bgCyan'));
      [string]$global:_bgYellowSn = $_scribbler.Snippets(@('bgYellow'));
      [string]$global:_bgDarkBlueSn = $_scribbler.Snippets(@('bgDarkBlue'));
      [string]$global:_bgRedSn = $_scribbler.Snippets(@('bgRed'));

      [string]$global:_structuredSoloLn = $(
        "$($_resetSn){0}$($_lnSn)"
      );

      [string]$global:_structuredSolo = $(
        "$($_resetSn){0}"
      );

      [string]$global:_ThemeColourAffirmSn = $_scribbler.WithArgSnippet('ThemeColour', 'affirm');
      [string]$global:_ThemeColourKeySn = $_scribbler.WithArgSnippet('ThemeColour', 'key');
      [string]$global:_ThemeColourMessageSn = $_scribbler.WithArgSnippet('ThemeColour', 'message');
      [string]$global:_ThemeColourMetaSn = $_scribbler.WithArgSnippet('ThemeColour', 'meta');
      [string]$global:_ThemeColourValueSn = $_scribbler.WithArgSnippet('ThemeColour', 'value');
    }
  }

  AfterEach {
    InModuleScope Elizium.Krayola {
      $_scribbler.Flush();
    }
  }

  Describe 'Scribble' {
    Context 'given: ad-hoc' {
      It 'should: write in colour' {
        InModuleScope Elizium.Krayola {
          $_scribbler.Scribble(
            "$($_resetSn)$($_redSn)Are you master of your domain? " +
            "$($_blueSn)Yeah, I'm still king of the county!$($_lnSn)" +

            "$($_redSn)$($_bgMagentaSn)Are you master of your domain? " +
            "$($_blueSn)$($_bgDarkCyanSn)Yeah, Im still lord of the manner!$($_lnSn)"
          );
        }
      } # should: write in colour

      It 'should: write in theme colours' {
        InModuleScope Elizium.Krayola {
          $_scribbler.Scribble(
            "$($_resetSn)" +
            "$($_ThemeColourAffirmSn)This is affirmed text$($_lnSn)" +
            "$($_ThemeColourKeySn)This is key text$($_lnSn)" +
            "$($_ThemeColourMessageSn)This is message text$($_lnSn)" +
            "$($_ThemeColourMetaSn)This is meta text$($_lnSn)" +
            "$($_ThemeColourValueSn)This is value text$($_lnSn)"
          )
        }
      } # should: write in theme colours

      Context 'and: style' {
        It 'should: not affect text display' {
          InModuleScope Elizium.Krayola {
            [string]$boldSn = $_scribbler.Snippets(@('bold'));
            [string]$italicSn = $_scribbler.Snippets(@('italic'));
            [string]$strikeSn = $_scribbler.Snippets(@('strike'));
            [string]$underSn = $_scribbler.Snippets(@('under'));

            $_scribbler.Scribble(
              "$($_resetSn)" +
              "$($boldSn)This is *bold* text$($_lnSn)" +
              "$($italicSn)This is /italic/ text$($_lnSn)" +
              "$($strikeSn)This is s-t-r-i-k-e--t-h-r-u text$($_lnSn)" +
              "$($underSn)This is _underlined_ text$($_lnSn)"
            );
          }
        }
      } # and: style

      Context 'and: text with background colour and new line' {
        It 'should: write text with background without flooding with background colour' {
          InModuleScope Elizium.Krayola {
            $_scribbler.Scribble(
              "$($_resetSn)" +
              "$($_blackSn)$($_bgCyanSn)Text with background colour$($_lnSn)"
            );
          }
        }
      }
    } # given: ad-hoc

    Context 'given: pair' {
      Context 'and: WithArgSnippet' {
        Context 'and: pair is PSCustomObject' {
          It 'should: write pair' {
            InModuleScope Elizium.Krayola {          
              [string]$pairSn = $_scribbler.WithArgSnippet('Pair', 'Album,Pungent Effulgent,true');
              $_scribbler.Scribble(
                ($_structuredSoloLn -f $pairSn)
              );

              [string]$pairSn = $_scribbler.WithArgSnippet('PairLn', 'Nine,Wreltch');
              $_scribbler.Scribble(
                ($_structuredSolo -f $pairSn)
              );
            }
          }
        } # pair is PSCustomObject

        Context 'and: Scribbled Pair' {
          It 'should: write pair' {
            InModuleScope Elizium.Krayola {
              [string]$pairSn = $_scribbler.WithArgSnippet('Pair', 'Blue Amazon,Long Way home');

              $_scribbler.Scribble(
                ($_structuredSoloLn -f $pairSn)
              );
            }
          }
        } # Scribbled Pair

        Context 'and: Scribbled Pair with escaped comma' {
          It 'should: write pair' {
            InModuleScope Elizium.Krayola {
              [string]$pairSn = $_scribbler.WithArgSnippet('Pair', $(
                  'Subversive,Blue Amazon\,Long Way home,true'
                ));

              $_scribbler.Scribble(
                ($_structuredSoloLn -f $pairSn)
              );
            }
          }

          It 'should: write pair' {
            InModuleScope Elizium.Krayola {
              [string]$pairSn = $_scribbler.WithArgSnippet('Pair', $(
                  'Subversive\,Blue Amazon,Long Way home'
                ));

              $_scribbler.Scribble(
                ($_structuredSoloLn -f $pairSn)
              );
            }
          }
        } # Scribbled Pair with escaped comma
      }
    } # pair

    Context 'given: line' {
      Context 'and: Scribbled Line' {
        It 'should: write line' {
          InModuleScope Elizium.Krayola {
            [string]$lineSn = `
              $_scribbler.WithArgSnippet('Line', $(
                'one,MoonChild;two,Infinite Dreams;three,Can I Play With Madness'
              ));

            $_scribbler.Scribble(
              ($_structuredSolo -f $lineSn)
            );
          }
        }
      }

      Context 'and: Scribbled Line with message' {
        It 'should: write line' {
          InModuleScope Elizium.Krayola {
            [string]$lineSn = `
              $_scribbler.WithArgSnippet('Line', $(
                'greetings earthlings;four,The Evil That Men Do;five,Seventh Son;six,The Prophecy'
              ));

            $_scribbler.Scribble(
              ($_structuredSolo -f $lineSn)
            );
          }
        }
      }

      Context 'and: Scribbled Line with escaped semi-colon' {
        It 'should: write line' {
          InModuleScope Elizium.Krayola {
            [string]$lineSn = `
              $_scribbler.WithArgSnippet('Line', $(
                'seven,The Clairvoyant;eight,Only The Good Die Young\; Iron Maiden'
              ));

            $_scribbler.Scribble(
              ($_structuredSolo -f $lineSn)
            );
          }
        }
      }
    } # line

    Context 'given: Custom expression' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          [regex]$expression = [regex]::new('`\((?<method>[\w]+)(,(?<p>[^\)]+))?\)');
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
    } # Custom expression

    Context 'given: Default expression using special UTF-8 code-points' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          #
          # http://www.wizcity.com/Computers/Characters/CommonUTF8.php

          [string]$lead = 'µ'; # (micro sign)
          [string]$open = '«'; # (left pointing guillemet)
          [string]$close = '»'; # (right pointing guillemet)

          # "µ«(?<method>[\w]+)(,(?<p>[^»]+))?»"
          #
          [regex]$expression = [regex]::new(
            "$($lead)$($open)(?<method>[\w]+)(,(?<p>[^$($close)]+))?$($close)"
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

          [string]$redSn = $scribbler.Snippets(@('red'));
          [string]$blueSn = $scribbler.Snippets(@('blue'));
          [string]$cyanSn = $scribbler.Snippets(@('cyan'));
          [string]$bgDarkMagentaSn = $scribbler.Snippets(@('bgDarkMagenta'));
          [string]$greenSn = $scribbler.Snippets(@('green'));
          [string]$lnSnippet = $scribbler.Snippets(@('Ln'));

          [string]$source = $(
            "$($redSn)Fields $($blueSn)Of The $($cyanSn)$($bgDarkMagentaSn)" +
            "Nephilim, Love $($greenSn)Under Will$($lnSnippet)"
          );

          $scribbler.Scribble($source);
          $scribbler.Flush();

          [PSCustomObject []]$operations = $krayon._parse($source);
          $operations | Should -HaveCount 10;
        }
      }
    } # Default expression using special UTF-8 code-points

    Context 'given: valid structured string' {
      Context 'and: leading text snippet' {
        Context 'and: single method call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "I need to be alone $($_redSn)today";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 3;
            }
          }
        }

        Context 'and: multiple method calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "Smother $($_cyanSn)me or $($_blueSn)suffer $($_greenSn)me";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "Lay $($_redSn)$($_magentaSn)down I'll die today";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 4;
            }
          }
        } # and: multiple method calls

        Context 'and: method invoke with param' {
          Context 'and: Message' {
            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$message = '*** Love under will';
                [string]$messageSn = $_scribbler.WithArgSnippet('Message', $message);

                $_scribbler.Scribble(
                  "$($_resetSn)$($messageSn)$($_lnSn)"
                );
              }
            }

            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$message = '!!! Love under will';
                [string]$messageSn = $_scribbler.WithArgSnippet('MessageLn', $message);

                $_scribbler.Scribble(
                  "$($_resetSn)$($messageSn)"
                );
              }
            }
          }

          Context 'and: ThemeColour' {
            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$source = 'Love under will';
                [string]$themeColourSn = $_scribbler.WithArgSnippet('ThemeColour', 'affirm');

                $_scribbler.Scribble(
                  "$($_resetSn)$($themeColourSn)$($source)$($_lnSn)"
                );
              }
            }
          }
        } # and: method invoke with param
      } # and: leading text snippet

      Context 'given: leading method call' {
        Context 'and: single method call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_cyanSn)Smother me or suffer me";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;
            }
          }

          Context 'and: with method param' {
            It 'should: invoke method with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = $_scribbler.WithArgSnippet('message', 'Love Under Will');

                $_scribbler.Scribble(
                  "$($_resetSn)$($source)$($_lnSn)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 1;
              }
            }
          }
        } # and: single method call

        Context 'and: multiple method calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_cyanSn)When $($_redSn)I'm gone $($_yellowSn)wait here";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 6;               
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = $(
                "$($_cyanSn)Discover $($_redSn)$($_bgYellowSn)all of $($_magentaSn)life's surprises"
              );

              $_scribbler.Scribble(
                "$($_resetSn)$($source)$($_lnSn)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          Context 'and: with method param' {
            It 'should: invoke method with param' {
              InModuleScope Elizium.Krayola {
                [string]$messageSn = $_scribbler.WithArgSnippet('Message', 'Love Under Will');
                [string]$source = "The Nephilim; $($messageSn)$($_redSn)*The Winter Solstace";

                $_scribbler.Scribble(
                  "$($_resetSn)$($source)$($_lnSn)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 4;
              }
            }

            It 'should: invoke method with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = $(
                  "$($_ThemeColourMetaSn)[🚀] ====== [ $($_ThemeColourMessageSn)Children of the Damned$($($_ThemeColourMetaSn)) ] ==="
                );

                $_scribbler.Scribble(
                  "$($_resetSn)$($source)$($_lnSn)"
                );

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 6;
              }
            }
          }
        } # and: multiple method calls
      } # given: leading method call

      Context 'given: trailing method call' {
        Context 'and: single method call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "When I'm gone wait here$($_lnSn)";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;        
            }
          }
        }

        Context 'and: multiple method calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = "$($_whiteSn)When $($_greenSn)I'm gone $($_yellowSn)wait here$($_lnSn)";

              $_scribbler.Scribble(
                "$($_resetSn)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = $(
                "I'll $($_greenSn)send my child my last $($_yellowSn)$($_bgDarkBlueSn)good smile$($_lnSn)"
              );

              $_scribbler.Scribble(
                "$($_resetSn)$($source)"
              );

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;        
            }
          }
        }
      } # given: trailing method call

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
    } # valid structured string

    Context 'given: non colour method calls' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          [string]$source = "$($_bgRedSn)If you pass $($_resetSn)through my soul tonight$($_lnSn)";

          $_scribbler.Scribble(
            "$($_resetSn)$($source)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 5;
        }
      }
    } # non colour method calls

    Context 'given: Vanilla string' {
      It 'should: write test as is' {
        InModuleScope Elizium.Krayola {
          [string]$source = 'Gather all his troubles';

          $_scribbler.Scribble(
            "$($_resetSn)$($source)$($_lnSn)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 1;
        }
      }
    } # Vanilla string

    Context 'given: string without core text' {
      It 'should: should not write any text' {
        InModuleScope Elizium.Krayola {
          [string]$source = "$($_redSn)" * 6;
          $_scribbler.Scribble(
            "$($_resetSn)Should be no text inside square brackets: " +
            "[$($source)$($_resetSn)]$($_lnSn)"
          );

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 6;
        }
      }
    } # string without core text
  } # Scribble

  Describe 'Snippets' {
    Context 'given: single method' {
      It 'should: return snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red');
          [string]$expected = "µ«red»";
          $_scribbler.Snippets($source) | Should -BeExactly $expected;
        }
      }
    }

    Context 'given: double method' {
      It 'should: return double snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red', 'bgRed');
          [string]$expected = 'µ«red»µ«bgRed»';
          $_scribbler.Snippets($source) | Should -BeExactly $expected;
        }
      }
    }
  } # Snippets

  Describe '[Accelerators]' {
    Describe 'Pair' {
      Context 'and: Pair' {
        It 'should: buffer pair' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = New-Pair @('Gift', 'For Her Light');
            $_scribbler.PairLn($pair).End();
          }
        }
      }

      Context 'and: PairLn' {
        It 'should: buffer pair' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = New-Pair @('Gift', 'From My Mind To Yours');
            $_scribbler.PairLn($pair).End();
          }
        }
      }

      Context 'and: Pair with PSCustomObject' {
        It 'should: buffer pair' {
          InModuleScope Elizium.Krayola {
            [PSCustomObject]$pairObj = [PSCustomObject]@{
              Key    = 'Gift';
              Value  = 'Ex';
              Affirm = $true;
            }
            $_scribbler.Pair($pairObj).Ln().End();
          }
        }
      }

      Context 'and: Pair with PSCustomObject' {
        It 'should: buffer pair' {
          InModuleScope Elizium.Krayola {
            [PSCustomObject]$pairObj = [PSCustomObject]@{
              Key    = 'Gift';
              Value  = 'Closer';
              Affirm = $true;
            }
            $_scribbler.PairLn($pairObj).End();
          }
        }
      }
    } # Pair
    Describe 'Line' {
      Context 'given: line with pair Key containing a comma' {
        It 'should: escape and scribble line' {
          InModuleScope Elizium.Krayola {
            [line]$line = $(New-Line(@(
                  $(New-Pair('What is the answer to life, love and unity', 'Fourty Two'))
                )));

            $_scribbler.Line($line).End();
            $_scribbler.Builder | Should -Match 'life\\,';
          }
        }
      }

      Context 'given: line with pair Value containing a comma' {
        It 'should: escape and scribble line' {
          InModuleScope Elizium.Krayola {
            [line]$line = $(New-Line(@(
                  $(New-Pair('Fourty Two', 'What is the answer to life, love and unity'))
                )));

            $_scribbler.Line($line).End();
            $_scribbler.Builder | Should -Match 'life\\,';
          }
        }
      }

      Context 'given: line with pair Key containing a semi-colon' {
        It 'should: escape and scribble line' {
          InModuleScope Elizium.Krayola {
            [line]$line = $(New-Line(@(
                  $(New-Pair('What is the answer to life; love and unity', 'Fourty Two'))
                )));

            $_scribbler.Line($line).End();
            $_scribbler.Builder | Should -Match 'life\\;';
          }
        }
      }

      Context 'given: line with pair Value containing a semi-colon' {
        It 'should: escape and scribble line' {
          InModuleScope Elizium.Krayola {
            [line]$line = $(New-Line(@(
                  $(New-Pair('Fourty Two', 'What is the answer to life; love and unity'))
                )));

            $_scribbler.Line($line).End();
            $_scribbler.Builder | Should -Match 'life\\;';
          }
        }
      }

      Context 'given: line with message' {
        It 'should: scribble line with message' {
          InModuleScope Elizium.Krayola {
            [string]$message = 'Greetings Happy Scripters';
            [line]$line = $(New-Line(@(
                  $(New-Pair('Liquid Refreshment', 'Milk')),
                  $(New-Pair('Biscuit Refreshment', 'Cookies'))
                )));

            $_scribbler.Line($message, $line).End();
            $_scribbler.Builder | Should -Match 'Liquid Refreshment';
            $_scribbler.Builder | Should -Match 'Milk';
            $_scribbler.Builder | Should -Match 'Biscuit Refreshment';
            $_scribbler.Builder | Should -Match 'Cookies';
          }
        }
      }
    } # Line

    Describe 'NakedLine' {
      Context 'given: line' {
        It 'should: render line without open and close' {
          InModuleScope Elizium.Krayola {
            [line]$line = $(New-Line(@(
                  $(New-Pair('Naked', 'The Emperor has no clothes'))
                )));

            $_scribbler.NakedLine($line).End();

            $_scribbler.Builder | Should -Match 'Naked';
            $_scribbler.Builder | Should -Match 'The Emperor has no clothes';
            $_scribbler.Builder | Should -Not -Match '\[';
            $_scribbler.Builder | Should -Not -Match '\]';
          }
        }
      }

      Context 'given: line with message' {
        It 'should: scribble line with message' {
          InModuleScope Elizium.Krayola {
            [string]$message = 'Greetings Earthlings';
            [line]$line = $(New-Line(@(
                  $(New-Pair('Treat', 'Recycled Plastik')),
                  $(New-Pair('Treat', 'Musik'))
                )));

            $_scribbler.NakedLine($message, $line).End();
            $_scribbler.Builder | Should -Match 'Treat';
            $_scribbler.Builder | Should -Match 'Recycled Plastik';
            $_scribbler.Builder | Should -Match 'Musik';
            $_scribbler.Builder | Should -Not -Match '\[';
            $_scribbler.Builder | Should -Not -Match '\]';
          }
        }
      }
    } # NakedLine

    Describe 'ThemeColour' {
      Context 'given: Theme colour' {
        It 'should: Set colour to <theme>' -TestCases @(
          @{ Theme = 'affirm' },
          @{ Theme = 'key' },
          @{ Theme = 'message' },
          @{ Theme = 'meta' },
          @{ Theme = 'value' }
        ) {
          $_scribbler.ThemeColour($Theme).End();
          $_scribbler.TextLn('That''s all folks');

          $_scribbler.Builder | Should -match "ThemeColour,$Theme"
        }
      }
    } # ThemeColour

    Describe 'Message' {
      Context 'given: Message' {
        It 'should: set a message' {
          $_scribbler.Reset().Message('... in a bottle').End();
          $_scribbler.Ln();

          $_scribbler.Builder | Should -match 'Message,... in a bottle';
        }
      } # Message

      Context 'given: MessageLn' {
        It 'should: set a message' {
          $_scribbler.Reset().MessageLn('The World Is My Oyster').End();

          $_scribbler.Builder | Should -match 'Message,The World Is My Oyster';
        }
      } # MessageLn

      Context 'given: MessageNoSuffix' {
        It 'should: set a message' {
          $_scribbler.Reset().MessageNoSuffix('The Only Star In Heaven').End();
          $_scribbler.Ln();

          $_scribbler.Builder | Should -match 'MessageNoSuffix,The Only Star In Heaven';
        }
      } # MessageNoSuffix

      Context 'given: MessageNoSuffixLn' {
        It 'should: set a message' {
          $_scribbler.Reset().MessageNoSuffixLn('Black Night White Light').End();

          $_scribbler.Builder | Should -match 'MessageNoSuffix,Black Night White Light';
        }
      } # MessageNoSuffix
    } # Message

    Describe '[Colours]' {
      Context 'given: explicit foreground' {
        It 'should: explicitly set foreground colour' {
          [System.ConsoleColor[]]$colours = [ConsoleColor]::GetValues([ConsoleColor]);

          $colours | ForEach-Object {
            [System.ConsoleColor]$foregroundColour = $_;
            $_scribbler.$foregroundColour().Text('[Where Eagles Dare] ').End();
          }
          $_scribbler.Ln();
        }
      } # explicit foreground

      Context 'given: explicit background' {
        It 'should: explicitly set background colour' {
          [System.ConsoleColor[]]$colours = [ConsoleColor]::GetValues([ConsoleColor]);

          $colours | ForEach-Object {
            [string]$backgroundColour = "bg$($_)";
            $_scribbler.$backgroundColour().Text('[Flight Of Icarus] ').End();
          }
          $_scribbler.Ln();
        }
      } # explicit background

      Context 'given: foreground' {
        It 'should: set colour foreground' {
          [System.ConsoleColor[]]$colours = [ConsoleColor]::GetValues([ConsoleColor]);

          $colours | ForEach-Object {
            [System.ConsoleColor]$colour = $_;
            $_scribbler.fore($colour).Text('[Rainbow Islands]').End();
          }
          $_scribbler.Ln();
        }
      } # foreground

      Context 'given: background' {
        It 'should: set colour foreground' {
          [System.ConsoleColor[]]$colours = [ConsoleColor]::GetValues([ConsoleColor]);

          $colours | ForEach-Object {
            [System.ConsoleColor]$colour = $_;
            $_scribbler.back($colour).Text('[Island Rainbows]').End();
          }
          $_scribbler.Ln();
        }
      } # background

      Context 'given: default foreground' {
        It 'should: explicitly set foreground colour' {
          $_scribbler.defaultFore('red').Reset().TextLn('Hell Fire').End();
        }
      }

      Context 'given: default background' {
        It 'should: explicitly set foreground colour' {
          $_scribbler.defaultBack('blue').Reset().TextLn('The Walls Of Jericho').End();
        }
      }

      Context 'given: Get defaults' {
        It 'should: return default foreground colour' {

        }
      }
    } # [Colours]

    Context 'given: PairSnippet' {
      Context 'and: Key containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('two, Never Forget', 'Blue Amazon'));

            [string]$pairSn = $_scribbler.PairSnippet($pair);
            $pairSn | Should -Match 'two\\,';

            $_scribbler.Scribble("$($pairSn)$($_lnSn)");
          }
        }
      }

      Context 'and: Value containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('three', 'Searching, Blue Amazon'));

            [string]$pairSn = $_scribbler.PairSnippet($pair);
            $pairSn | Should -Match 'Searching\\,';

            $_scribbler.Scribble("$($pairSn)$($_lnSn)");
          }
        }
      }

      Context 'and: Key containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('four; The Runner', 'Blue Amazon'));

            [string]$pairSn = $_scribbler.PairSnippet($pair);
            $pairSn | Should -Match 'four\\;';

            $_scribbler.Scribble("$($pairSn)$($_lnSn)");
          }
        }
      }

      Context 'and: Value containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('five', 'The Javelin; Blue Amazon'));

            [string]$pairSn = $_scribbler.PairSnippet($pair);
            $pairSn | Should -Match 'The Javelin\\;';

            $_scribbler.Scribble("$($pairSn)$($_lnSn)");
          }
        }
      }
    } # PairSnippet

    Context 'given: LineSnippet' {
      Context 'and: Key containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('one, Doubleplusgood', 'Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSn = $_scribbler.LineSnippet($line);
            $lineSn | Should -Match 'one\\,';

            $_scribbler.Scribble("$($lineSn)");
          }
        }
      }

      Context 'and: Value containing a comma' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('two', 'For The Love Of Big Brother, Eurythmics')); ;
            [line]$line = New-Line(@($pair));

            [string]$lineSn = $_scribbler.LineSnippet($line);
            $lineSn | Should -Match 'Brother\\,';

            $_scribbler.Scribble("$($lineSn)");
          }
        }
      }

      Context 'and: Key containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('three; The Runner', 'Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSn = $_scribbler.LineSnippet($line);
            $lineSn | Should -Match 'three\\;';

            $_scribbler.Scribble("$($lineSn)");
          }
        }
      }

      Context 'and: Value containing a semi-colon' {
        It 'should: escape and scribble ok' {
          InModuleScope Elizium.Krayola {
            [couplet]$pair = $(New-Pair @('four', 'I Did It Just The Same; Eurythmics'));
            [line]$line = New-Line(@($pair));

            [string]$lineSn = $_scribbler.LineSnippet($line);
            $lineSn | Should -Match 'Same\\;';

            $_scribbler.Scribble("$($lineSn)");
          }
        }
      }
    } # LineSnippet
  } # [Accelerators]

  Describe 'Save' {
    It 'should: write scribbled content' {
      InModuleScope Elizium.Krayola {
        [Scribbler]$scribbler = New-Scribbler -Test -Save;

        [string]$lineSn = `
          $scribbler.WithArgSnippet('Line', $(
            'seven,The Clairvoyant;eight,Only The Good Die Young\; Iron Maiden'
          ));

        [string]$lineSn = `
          $scribbler.WithArgSnippet('Line', $(
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
          $scribbler.WithArgSnippet('Line', $l);
        }

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
  } # Save
} # Scribbler

Describe 'Scribbler code generator' {
  It 'should: generate custom colour methods' -Skip {
    # Use this test to make updates to colour methods, without having to code up
    # every method manually.
    #
    [array]$fgColours = @('black', 'darkBlue', 'darkGreen', 'darkCyan',
      'darkRed', 'darkMagenta', 'darkYellow', 'gray', 'darkGray', 'blue', 'green',
      'cyan', 'red', 'magenta', 'yellow', 'white');

    [array]$bgColours = @('bgBlack', 'bgDarkBlue', 'bgDarkGreen', 'bgDarkCyan',
      'bgDarkRed', 'bgDarkMagenta', 'bgDarkYellow', 'bgGray', 'bgDarkGray', 'bgBlue', 'bgGreen',
      'bgCyan', 'bgRed', 'bgMagenta', 'bgYellow', 'bgWhite');
      
    foreach ($col in $($fgColours + $bgColours)) {
      # [Scribbler] black() {
      # [string]$snippet = $this.Snippets($colour);
      # $this.Scribble($snippet);

      # return $this;
      # }
      # -----------------------------------------------

      $code = '[Scribbler] {0}()';
      Write-Host "$($code -f $col) {";

      $code = '   [string]$snippet = $this.Snippets(''{0}'');';
      Write-Host "$($code -f $col)";

      Write-Host '$this.Scribble($snippet);';
      Write-Host "";

      $code = '   return $this;';
      Write-Host "$code";
      Write-Host "}";

      Write-Host "";
    }
  }
} # Scribbler code generator
