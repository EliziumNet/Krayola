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

      [string]$global:_lnSnippet = $_scribbler.Snippets(@('Ln'));
      [string]$global:_resetSnippet = $_scribbler.Snippets(@('Reset'));

      [string]$global:_redSnippet = $_scribbler.Snippets(@('red'));
      [string]$global:_blueSnippet = $_scribbler.Snippets(@('blue'));
      [string]$global:_greenSnippet = $_scribbler.Snippets(@('green'));
      [string]$global:_magentaSnippet = $_scribbler.Snippets(@('magenta'));
      [string]$global:_cyanSnippet = $_scribbler.Snippets(@('cyan'));
      [string]$global:_graySnippet = $_scribbler.Snippets(@('gray'));
    }
  }

  AfterEach {
    InModuleScope Elizium.Krayola {
      $_scribbler.Flush();
    }
  }

  Context 'given: pair' {
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

          [couplet]$couplet = [couplet]::new('Four', 'The Domes of G''Bal', $false);
          $_krayon.PairLn($couplet);
        }
      }
    } # and: pair created via discrete parameter constructor

    Context 'and: pair created via New-Pair' {
      It 'should: write pair' -Tag 'Host' {
        InModuleScope Elizium.Krayola {
          [couplet]$couplet = $(New-Pair @('Five', 'Shaping the Pelm', $true));
          $_krayon.Pair($couplet).Ln();

          [couplet]$couplet = $(New-Pair @('six', 'Ayurvedic'));
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
  } # given: line

  Describe 'Scribble' {
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
    } # invalid structured string
  } # Scribble

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

