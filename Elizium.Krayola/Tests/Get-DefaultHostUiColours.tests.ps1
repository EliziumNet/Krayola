
Describe 'Get-DefaultHostUiColours' {
  InModuleScope Elizium.Krayola {
    Get-Module Elizium.Krayola | Remove-Module
    Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

  }

  Context 'given: light krayola theme' {
    BeforeEach {
      InModuleScope Elizium.Krayola {
        Mock Get-IsKrayolaLightTerminal -ModuleName Elizium.Krayola {
          $true;
        }
      }
    }

    Context 'given: valid environment colours' {
      It 'should: use environment colours' {
        InModuleScope Elizium.Krayola {
          Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
            'red', 'blue'
          }

          Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
            Param
            (
              [string]$Variable,
              $Default
            )
            if ($Variable -eq 'KRAYOLA_FORE') {
              'black';
            }
            elseif ($Variable -eq 'KRAYOLA_BACK') {
              'gray';
            }
          }

          [string]$fore, [string]$back = Get-DefaultHostUiColours;
          $fore | Should -BeExactly 'black';
          $back | Should -BeExactly 'gray';
        }
      }
    } # given: valid environment colours

    Context 'given: invalid environment colours' {
      Context 'and: valid raw colours' {
        It 'should: use raw colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              'black', 'gray'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              '-1';
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'black';
            $back | Should -BeExactly 'gray';
          }
        }
      }

      Context 'and: invalid raw colours' {
        It 'should: use default colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              '-1', '-1'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              '-1';
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'black';
            $back | Should -BeExactly 'gray';
          }
        }
      }
    } # given: invalid environment colours

    Context 'given: colours not defined in environment' {
      Context 'and: valid raw colours' {
        It 'should: use raw colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              'black', 'gray'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              $null;
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'black';
            $back | Should -BeExactly 'gray';
          }
        }
      }

      Context 'and: invalid raw colours' {
        It 'should: use default colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              '1', '-1'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              $null;
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'black';
            $back | Should -BeExactly 'gray';
          }
        }
      }
    } # given: colours not defined in environment
  } # given: light krayola theme

  Context 'given: dark krayola theme' {
    BeforeEach {
      InModuleScope Elizium.Krayola {
        Mock Get-IsKrayolaLightTerminal -ModuleName Elizium.Krayola {
          $false;
        }
      }
    }

    Context 'given: valid environment colours' {
      It 'should: use environment colours' {
        InModuleScope Elizium.Krayola {
          Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
            'red', 'blue'
          }

          Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
            Param
            (
              [string]$Variable,
              $Default
            )
            if ($Variable -eq 'KRAYOLA_FORE') {
              'gray';
            }
            elseif ($Variable -eq 'KRAYOLA_BACK') {
              'black';
            }
          }

          [string]$fore, [string]$back = Get-DefaultHostUiColours;
          $fore | Should -BeExactly 'gray';
          $back | Should -BeExactly 'black';
        }
      }
    } # given: valid environment colours

    Context 'given: invalid environment colours' {
      Context 'and: valid raw colours' {
        It 'should: use raw colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              'gray', 'black'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              '-1'
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'gray';
            $back | Should -BeExactly 'black';
          }
        }
      }

      Context 'and: invalid raw colours' {
        It 'should: use default colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              '-1', '-1'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              '-1'
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'gray';
            $back | Should -BeExactly 'black';
          }
        }
      }
    } # given: invalid environment colours

    Context 'given: colours not defined in environment' {
      Context 'and: valid raw colours' {
        It 'should: use raw colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              'gray', 'black'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              $null
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'gray';
            $back | Should -BeExactly 'black';
          }
        }
      }

      Context 'and: invalid raw colours' {
        It 'should: use default colours' {
          InModuleScope Elizium.Krayola {
            Mock get-RawHostUiColours -ModuleName Elizium.Krayola {
              '-1', '-1'
            }

            Mock Get-EnvironmentVariable -ModuleName Elizium.Krayola {
              Param
              (
                [string]$Variable,
                $Default
              )
              $null
            }

            [string]$fore, [string]$back = Get-DefaultHostUiColours;
            $fore | Should -BeExactly 'gray';
            $back | Should -BeExactly 'black';
          }
        }
      }
    } # given: colours not defined in environment
  } # given: dark krayola theme
} # Get-DefaultHostUiColours
