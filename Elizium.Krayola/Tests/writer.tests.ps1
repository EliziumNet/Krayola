
Describe 'writer' {
  BeforeAll {
    Get-Module Elizium.Krayola | Remove-Module
    Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [hashtable]$script:_theme = $(Get-KrayolaTheme);
  }

  BeforeEach {
    $script:_writer = New-Writer ($_theme);
  }

  Context 'given: ad-hoc' {
    It 'should: write in colour' {
      $_writer.red().Text('Are you master of your domain? '). `
        blue().TextLn('Yeah, Im still king of the county!');

      $_writer.red().bgMagenta().Text('Are you master of your domain? '). `
        blue().bgDarkCyan().TextLn('Yeah, Im still lord of the manner!');
    }

    It 'should: write in theme colours' {
      $_writer.ThemeColour('affirm').TextLn('This is affirmed text');
      $_writer.ThemeColour('key').TextLn('This is key text');
      $_writer.ThemeColour('message').TextLn('This is message text');
      $_writer.ThemeColour('meta').TextLn('This is meta text');
      $_writer.ThemeColour('value').TextLn('This is value text');
    }

    Context 'and: style' {
      It 'should: not affect text display' {
        $_writer.bold().TextLn('This is *bold* text');
        $_writer.italic().TextLn('This is /italic/ text');
        $_writer.strike().TextLn('This is s-t-r-i-k-e--t-h-r-u text');
        $_writer.under().TextLn('This is _underlined_ text');
      }
    }
  }

  Context 'given: pair' {
    Context 'and: pair is PSCustomObject' {
      It 'should: write pair' {
        $_writer.Pair(@{ Key = 'Greetings'; Value = 'Earthlings'; Affirm = $true; }).Ln();
        $_writer.PairLn(@{ Key = 'Greetings'; Value = 'Earthlings'; });
      }
    }

    Context 'and: pair is couplet' {
      It 'should: write pair' {
        $_writer.Pair($(kp('a-key', 'a-value'))).Ln();
        $_writer.PairLn($(kp('a-key', 'a-value', $true)));
      }
    }
  } # given: pair

  Context 'given: line' {
    Context 'and: without message' {
      It 'should: write line' {
        [array]$pairs = @(
          $(kp('name', 'art vanderlay')),
          $(kp('occupation', 'architect')),
          $(kp('quip', "i'm back baby, i'm back", $true))
        );

        $_writer.Line($(kl($pairs)));
      }
    }

    Context 'and: with message' {
      It 'should: write line' {
        [array]$pairs = @(
          $(kp('name', 'frank')),
          $(kp('festivity', "The airance of grievances", $true))
        );

        [string]$message = 'Festivus for the rest of us';
        $_writer.Line($message, $(kl($pairs)));
      }
    }
  }

  Context 'and: structured write' {
    Context 'and: Custom expression' {
      It 'should: perform structured write' {
        [regex]$expression = [regex]::new('`\{(?<api>[\w]+)\}');
        $writer = New-Writer $_theme $expression;
        [string]$source = '`{red}Fields `{blue}Of The `{cyan}`{bgDarkMagenta}Nephilim, Love `{green}Under Will`{Ln}';
        $writer.Scribble($source);

        [PSCustomObject []]$operations = $writer._parse($source);
        $operations | Should -HaveCount 10;
      }
    }

    Context 'and: valid structured string' {
      Context 'and: leading text snippet' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            [string]$source = 'I need to be alone &[red]today';
            $_writer.Scribble($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 3;
            Write-Host '';
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            [string]$source = 'Smother &[cyan]me or &[blue]suffer &[green]me';
            $_writer.Scribble($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 7;
            Write-Host '';
          }

          It 'should: perform structured write' {
            [string]$source = 'Lay &[red]&[bgMagenta]down I''ll die today';
            $_writer.ScribbleLn($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 4;
          }
        }
      }

      Context 'and: Message' {
        It 'should: perform message write' {
          [string]$message = '*** Love under will';
          $_writer.Message($message);
          Write-Host '';
        }
      }

      Context 'given: leading api call' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            [string]$source = '&[cyan]Smother me or suffer me';
            $_writer.ScribbleLn($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 2;
          }

          Context 'and: with api param' {
            It 'should: invoke api with param' {
              [string]$source = '&[message,Love Under Will]';  
              $_writer.ScribbleLn($source);

              [PSCustomObject []]$operations = $_writer._parse($source);
              $operations | Should -HaveCount 1;
            }
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            [string]$source = '&[cyan]When &[red]I''m gone &[yellow]wait here';
            $_writer.ScribbleLn($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 6;
          }

          It 'should: perform structured write' {
            [string]$source = '&[cyan]Discover &[red]&[bgYellow]all of &[magenta]life''s surprises';
            $_writer.ScribbleLn($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 7;
          }

          Context 'and: with api param' {
          It 'should: invoke api with param' {
              [string]$source = 'The Nephilim; &[message,Love Under Will]&[red]*The Winter Solstace';
              $_writer.ScribbleLn($source);

              [PSCustomObject []]$operations = $_writer._parse($source);
              $operations | Should -HaveCount 4;
            }
          }
        }
      }

      Context 'given: trailing api call' {
        Context 'and: single api call' {
          It 'should: perform structured write' {
            [string]$source = 'When I''m gone wait here&[Ln]';
            $_writer.Scribble($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 2;
          }
        }

        Context 'and: multiple api calls' {
          It 'should: perform structured write' {
            [string]$source = '&[white]When &[green]I''m gone &[yellow]wait here&[Ln]';
            $_writer.Scribble($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 7;
          }

          It 'should: perform structured write' {
            [string]$source = 'I''ll &[green]send my child my last &[yellow]&[bgDarkBlue]good smile&[Ln]';
            $_writer.Scribble($source);

            [PSCustomObject []]$operations = $_writer._parse($source);
            $operations | Should -HaveCount 7;
          }
        }
      }
    }

    Context 'and: invalid structured string' {
      Context 'and: invalid colour' {
        It 'should: throw' {
          {
            [string]$source = 'I''ll love her ''til i &[orange]die[Ln]';
            $_writer.Scribble($source);
          } | Should -Throw;
          Write-Host '';
        }
      }

      Context 'and: structure string contains an invalid call to "Text"' {
        It 'should: throw' {
          {
            [string]$source = 'Then rest in peace can''t you &[Text]see[Ln]';
            $_writer.Scribble($source);
          } | Should -Throw;
          Write-Host '';
        }
      }
    }

    Context 'given: non colour api calls' {
      It 'should: perform structured write' {
        [string]$source = '&[red]If you pass &[reset]through my soul today&[Ln]';
        $_writer.Scribble($source);

        [PSCustomObject []]$operations = $_writer._parse($source);
        $operations | Should -HaveCount 5;
      }
    }

    Context 'given: unusual string' {
      It 'should: should not write any text' {
        [string]$source = '&[red]&[red]&[red]&[red]&[red]&[red]';
        $_writer.ScribbleLn($source);

        [PSCustomObject []]$operations = $_writer._parse($source);
        $operations | Should -HaveCount 6;
      }
    }
  }
} # writer

Describe 'Writer code generator' {
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
      # [writer] black() {
      #   $this._fgc = 'black';
      #   return $this;
      # }
      # -----------------------------------------------

      $code = '[writer] {0}()';
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
      $code = '[writer] {0}()';
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
} # Writer code generator
