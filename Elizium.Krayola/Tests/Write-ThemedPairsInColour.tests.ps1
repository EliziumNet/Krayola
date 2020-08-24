
Describe 'Write-ThemedPairsInColour' {
  BeforeAll {
    Get-Module Elizium.Krayola | Remove-Module
    Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 -ErrorAction 'stop' -DisableNameChecking

    Mock -ModuleName Elizium.Krayola -Verifiable Write-Error {}

    $script:theme = @{
      "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
      "KEY-PLACE-HOLDER"   = "<%KEY%>";
      "VALUE-PLACE-HOLDER" = "<%VALUE%>";
      "KEY-COLOURS"        = @("Red");
      "VALUE-COLOURS"      = @("Blue");
      "AFFIRM-COLOURS"     = @("Yellow");
      "OPEN"               = "{";
      "CLOSE"              = "}";
      "SEPARATOR"          = " | ";
      "META-COLOURS"       = @("Cyan");
      "MESSAGE-COLOURS"    = @("DarkRed", "White");
      "MESSAGE-SUFFIX"     = " // "
    }

    $script:themeWithoutAffirm = @{
      "FORMAT"             = "'<%KEY%>'='<%VALUE%>'";
      "KEY-PLACE-HOLDER"   = "<%KEY%>";
      "VALUE-PLACE-HOLDER" = "<%VALUE%>";
      "KEY-COLOURS"        = @("Red");
      "VALUE-COLOURS"      = @("Blue");
      "OPEN"               = "{";
      "CLOSE"              = "}";
      "SEPARATOR"          = " | ";
      "META-COLOURS"       = @("Cyan");
      "MESSAGE-COLOURS"    = @("DarkRed", "White");
      "MESSAGE-SUFFIX"     = " // "
    }
  }

  Context 'given: valid' {
    Context 'and: single pair' {
      It 'should: write to host' {
        Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {
          $pairs[0][0][0] | Should -BeExactly 'Artist';
          $pairs[0][1][0] | Should -BeExactly 'Plastikman';
        }

        Write-ThemedPairsInColour -Theme $theme -Pairs @(, @("Artist", "Plastikman"));
      }

      Context 'and: with positive affirmation' {
        It 'should: write with affirmation colour' {
          Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {
            $pairs[0][1][1] | Should -BeExactly $theme['AFFIRM-COLOURS'][0];
          }

          Write-ThemedPairsInColour -Theme $theme -Pairs @(, @("Artist", "Plastikman", $true));
        }
      } # and: with positive affirmation

      Context 'and: with negative affirmation' {
        It 'should: write with value colour' {
          Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {
            $pairs[0][1][1] | Should -BeExactly $theme['VALUE-COLOURS'][0];
          }

          Write-ThemedPairsInColour -Theme $theme -Pairs @(, @("Artist", "Plastikman", $false));
        }
      } # and: with negative affirmation

      Context 'and: theme without affirmation colour' {
        Context 'and: with positive affirmation' {
          It 'should: write asterisked value with value colour' {
            Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {
              $pairs[0][1][1] | Should -BeExactly $themeWithoutAffirm['VALUE-COLOURS'][0];
              $pairs[0][1][0] | Should -BeExactly '*Plastikman*';
            }

            Write-ThemedPairsInColour -Theme $themeWithoutAffirm `
              -Pairs @(, @("Artist", "Plastikman", $true));
          }
        }
      } # and: theme without affirmation colour
    } # and: single pair

    Context 'and: multiple pairs' {
      It 'should: write to host' {
        Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {

          $pairs[0][0][0] | Should -BeExactly 'Artist';
          $pairs[0][1][0] | Should -BeExactly 'Plastikman';

          $pairs[1][0][0] | Should -BeExactly 'Genre';
          $pairs[1][1][0] | Should -BeExactly 'Minimal';

          $pairs[2][0][0] | Should -BeExactly 'Format';
          $pairs[2][1][0] | Should -BeExactly 'Vinyl';
        }

        Write-ThemedPairsInColour -Theme $theme `
          -Pairs @(@("Artist", "Plastikman"), @("Genre", "Minimal"), @("Format", "Vinyl"));
      }
    } # and: multiple pairs
  } # given: valid

  Context 'given: invalid' {
    Context 'and: incorrectly defined single item array' {
      It 'should: belch' {
        Mock -ModuleName Elizium.Krayola -Verifiable Write-RawPairsInColour {
          $pairs[0][0][0] | Should -BeExactly '!INVALID!';
          $pairs[0][1][0] | Should -BeExactly '---';
        }

        # This is a typical array programming error, where comma op should
        # have been used, but was missed out. Should be @(, @("Artist", "Plastikman")
        #
        Write-ThemedPairsInColour -Theme $theme -Pairs @(@("Artist", "Plastikman"));
      }
    } # and: incorrectly defined single item array

    Context 'and: empty array' {
      It 'should: do nothing' {
        Write-ThemedPairsInColour -Theme $theme -Pairs @();
      }
    }
  } # given: invalid
} # Write-ThemedPairsInColour
