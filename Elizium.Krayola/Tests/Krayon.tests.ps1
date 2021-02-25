
Describe 'Krayon' {
  BeforeAll {
    InModuleScope Elizium.Krayola {
      Get-Module Elizium.Krayola | Remove-Module -Force
      Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
        -ErrorAction 'stop' -DisableNameChecking
    }
  }

  BeforeEach {
    InModuleScope Elizium.Krayola {
      [hashtable]$script:_theme = $(Get-KrayolaTheme);
      [Krayon]$script:_krayon = New-Krayon -Theme $_theme;
    }
  }

  Context 'given: ad-hoc' {
    It 'should: write in colour' {
      InModuleScope Elizium.Krayola {
        $_krayon.red().Text('Are you master of your domain? '). `
          blue().TextLn('Yeah, Im still king of the county!').End();

        $_krayon.red().bgMagenta().Text('Are you master of your domain? '). `
          blue().bgDarkCyan().TextLn('Yeah, Im still lord of the manner!').End();
      }
    } # should: write in colour

    It 'should: write in theme colours' {
      InModuleScope Elizium.Krayola {
        $_krayon.ThemeColour('affirm').TextLn('This is affirmed text');
        $_krayon.ThemeColour('key').TextLn('This is key text');
        $_krayon.ThemeColour('message').TextLn('This is message text');
        $_krayon.ThemeColour('meta').TextLn('This is meta text');
        $_krayon.ThemeColour('value').TextLn('This is value text');        
      }
    } # should: write in theme colours

    Context 'and: style' {
      It 'should: not affect text display' {
        InModuleScope Elizium.Krayola {
          $_krayon.bold().TextLn('This is *bold* text');
          $_krayon.italic().TextLn('This is /italic/ text');
          $_krayon.strike().TextLn('This is s-t-r-i-k-e--t-h-r-u text');
          $_krayon.under().TextLn('This is _underlined_ text');
        }
      }
    } # and: style

    Context 'and: text with background colour and new line' {
      It 'should: write text with background without flooding with background colour' {
        InModuleScope Elizium.Krayola {
          $_krayon.black().bgCyan().TextLn('Text with background colour')
        }
      }
    }
  } # given: ad-hoc

  Context 'given: pair' {
    Context 'and: pair is PSCustomObject' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          $_krayon.Pair(@{ Key = 'Album'; Value = 'Pungent Effulgent'; Affirm = $true; }).Ln();
          $_krayon.PairLn(@{ Key = 'Nine'; Value = 'Wreltch'; });
        }
      }
    }

    Context 'and: pair created via default constructor' {
      It 'should: write pair' {
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
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [string[]]$properties = @('One', 'Disolution (The Clouds Disperse)', $true);
          [couplet]$couplet = [couplet]::new($properties);
          $_krayon.Pair($couplet).Ln();

          [string[]]$properties = @('Two', '0-1');
          [couplet]$couplet = [couplet]::new($properties);

          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via array constructor

    Context 'and: pair created via discrete parameter constructor' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = [couplet]::new('Three', 'Phalarn Dawn', $true);
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = [couplet]::new('Four', '04 - The Domes of G''Bal', $false);
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via discrete parameter constructor

    Context 'and: pair created via New-Pair' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = $(New-Pair @('Five', 'Shaping the Pelm', $true));
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = $(New-Pair @('six', '06 - Ayurvedic'));
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via New-Pair

    Context 'and: pair created via kp alias' {
      It 'should: write pair' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = $(kp(@('Seven', 'Kick Muck', $true)));
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = $(kp(@('Eight', 'Agog in the Ether')));
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via kp alias
  } # given: pair

  Context 'given: line' {
    Context 'and: without message' {
      It 'should: write line' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'art vanderlay')),
            $(kp('occupation', 'architect')),
            $(kp('quip', "i'm back baby, i'm back", $true))
          );

          $_krayon.Line($(kl($pairs)));
        }
      }
    } # and: without message

    Context 'and: with message' {
      It 'should: write line' {
        InModuleScope Elizium.Krayola {
          [array]$pairs = @(
            $(kp('name', 'frank')),
            $(kp('festivity', "The airance of grievances", $true))
          );

          [string]$message = 'Festivus for the rest of us';
          $_krayon.Line($message, $(kl($pairs)));
        }
      }
    } # and: with message

    Context 'and: append to line' {
      It 'should: write line' {
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

      It 'should: write line' {
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
  } # given: line

  Describe 'Scribble' {
    Context 'given: Custom expression' {
      It 'should: perform structured write' {
        InModuleScope Elizium.Krayola {
          [regex]$expression = [regex]::new('`\((?<api>[\w]+)(,(?<p>[^\)]+))?\)');
          [string]$formatWithArg = '`({0},{1})';
          [string]$format = '`({0})';
          [regex]$nativeExpression = [regex]::new('');
          $Krayon = New-Krayon $_theme $expression $formatWithArg $format $nativeExpression;
          [string]$source = '`(red)Fields `(blue)Of The `(cyan)`(bgDarkMagenta)Nephilim, Love `(green)Under Will`(Ln)';
          $Krayon.Scribble($source);

          [PSCustomObject []]$operations = $Krayon._parse($source);
          $operations | Should -HaveCount 10;
        
        }
      }
    } # given: Custom expression

    Context 'and: valid structured string' {
      Context 'and: leading text snippet' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = 'I need to be alone &[red]today';
              $_krayon.Scribble($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 3;
              Write-Host '';        
            }
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = 'Smother &[cyan]me or &[blue]suffer &[green]me';
              $_krayon.Scribble($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
              Write-Host '';
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = 'Lay &[red]&[bgMagenta]down I''ll die today';
              $_krayon.ScribbleLn($source);

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
                $_krayon.Message($message);
                Write-Host '';        
              }
            }

            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$message = '!!! Love under will';
                $_krayon.MessageLn($message);        
              }
            }
          }

          Context 'and: ThemeColour' {
            It 'should: perform message write' {
              InModuleScope Elizium.Krayola {
                [string]$source = '&[ThemeColour, affirm]$$$ Love under will';
                $_krayon.ScribbleLn($source);        
              }
            }
          }
        } # and: api invoke with param
      } # and: leading text snippet

      Context 'given: leading api call' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = '&[cyan]Smother me or suffer me';
              $_krayon.ScribbleLn($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;
            }
          }

          Context 'and: with api param' {
            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = '&[message,Love Under Will]';  
                $_krayon.ScribbleLn($source);

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 1;
              }
            }
          }
        } # and: single api call

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = '&[cyan]When &[red]I''m gone &[yellow]wait here';
              $_krayon.ScribbleLn($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 6;        
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = '&[cyan]Discover &[red]&[bgYellow]all of &[magenta]life''s surprises';
              $_krayon.ScribbleLn($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          Context 'and: with api param' {
            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = 'The Nephilim; &[message,Love Under Will]&[red]*The Winter Solstace';
                $_krayon.ScribbleLn($source);

                [PSCustomObject []]$operations = $_krayon._parse($source);
                $operations | Should -HaveCount 4;
              }
            }

            It 'should: invoke api with param' {
              InModuleScope Elizium.Krayola {
                [string]$source = '&[ThemeColour,meta][🚀] ====== [ &[ThemeColour,message]Children of the Damned&[ThemeColour,meta] ] ==='
                $_krayon.ScribbleLn($source);

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
              [string]$source = 'When I''m gone wait here&[Ln]';
              $_krayon.Scribble($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 2;        
            }
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = '&[white]When &[green]I''m gone &[yellow]wait here&[Ln]';
              $_krayon.Scribble($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;
            }
          }

          It 'should: perform structured write' {
            InModuleScope Elizium.Krayola {
              [string]$source = 'I''ll &[green]send my child my last &[yellow]&[bgDarkBlue]good smile&[Ln]';
              $_krayon.Scribble($source);

              [PSCustomObject []]$operations = $_krayon._parse($source);
              $operations | Should -HaveCount 7;        
            }
          }
        }
      } # given: trailing api call

      Context 'and: empty string' {
        It 'should: ignore' -Tag 'Current' {
          InModuleScope Elizium.Krayola {
            {
              [string]$source = [string]::Empty;
              $_krayon.Scribble($source);
            } | Should -Not -Throw;
          }
        }
      }
    } # and: valid structured string

    Context 'and: invalid structured string' {
      Context 'and: invalid colour' {
        It 'should: throw' {
          InModuleScope Elizium.Krayola {
            {
              [string]$source = 'I''ll love her ''til i &[orange]die[Ln]';
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
              [string]$source = 'Then rest in peace can''t you &[Text]see[Ln]';
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
          [string]$source = '&[bgRed]If you pass &[reset]through my soul tonight&[Ln]';
          $_krayon.Scribble($source);

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 5;
        }
      }
    }

    Context 'given: Vanilla string' {
      It 'should: write test as is' {
        InModuleScope Elizium.Krayola {
          [string]$source = 'Gather all his troubles';
          $_krayon.ScribbleLn($source).End();

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 1;
        }
      }
    }

    Context 'given: unusual string' {
      It 'should: should not write any text' {
        InModuleScope Elizium.Krayola {
          [string]$source = '&[red]&[red]&[red]&[red]&[red]&[red]';
          $_krayon.ScribbleLn($source);

          [PSCustomObject []]$operations = $_krayon._parse($source);
          $operations | Should -HaveCount 6;
        }
      }
    }
  } # Scribble

  Describe 'given: native' {
    Context 'and: structured string with api invokes without arguments' {
      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = '&[red]hello world';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'hello world&[blue]';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'hello &[green]world';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'who &[magenta]watches &[cyan]the &[gray]watchers';
          [string]$expected = 'who watches the watchers';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }
    }

    Context 'and: structured string with api invokes without arguments' {
      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = '&[fore,red]hello world';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'hello world&[back,blue]';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'hello &[ThemeColour,green]world';
          [string]$expected = 'hello world';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }

      It 'should: return native string' {
        InModuleScope Elizium.Krayola {
          [string]$structured = 'who &[ThemeColour,magenta]watches &[Message,Silk Spectre]the &[gray]watchers';
          [string]$expected = 'who watches the watchers';
          $_krayon.Native($structured) | Should -BeExactly $expected;
        }
      }
    }
  }

  Describe 'Snippets' {
    Context 'given: single api' {
      It 'should: return snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red');
          [string]$expected = '&[red]';
          $_krayon.Snippets($source) | Should -BeExactly $expected;
        }
      }
    }

    Context 'given: double api' {
      It 'should: return double snippet' {
        InModuleScope Elizium.Krayola {
          [string[]]$source = @('red', 'bgRed');
          [string]$expected = '&[red]&[bgRed]';
          $_krayon.Snippets($source) | Should -BeExactly $expected;
        }
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
