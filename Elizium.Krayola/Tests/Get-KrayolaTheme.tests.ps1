Set-StrictMode -Version Latest

Describe 'Get-KrayolaTheme' {
  BeforeAll {
    Get-Module Elizium.Krayola | Remove-Module
    Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 -ErrorAction 'stop' -DisableNameChecking

    [System.Collections.Hashtable]$Global:DefaultKrayolaTheme = @{
      'FORMAT'             = 'def:"<%KEY%>"="<%VALUE%>"';
      'KEY-PLACE-HOLDER'   = '<%KEY%>';
      'VALUE-PLACE-HOLDER' = '<%VALUE%>';
      'KEY-COLOURS'        = @('DarkCyan');
      'VALUE-COLOURS'      = @('DarkBlue');
      'OPEN'               = '••• (';
      'CLOSE'              = ') •••';
      'SEPARATOR'          = ' @@ ';
      'META-COLOURS'       = @('Yellow');
      'MESSAGE-COLOURS'    = @('Cyan');
      'MESSAGE-SUFFIX'     = ' ~~ '
    }

    [System.Collections.Hashtable]$Global:TestThemes = @{
      'THEME-ONE'         = @{
        'FORMAT'             = 'one:"<%KEY%>"="<%VALUE%>"';
        'KEY-PLACE-HOLDER'   = '<%KEY%>';
        'VALUE-PLACE-HOLDER' = '<%VALUE%>';
        'KEY-COLOURS'        = @('DarkCyan');
        'VALUE-COLOURS'      = @('DarkBlue');
        'OPEN'               = '••• (';
        'CLOSE'              = ') •••';
        'SEPARATOR'          = ' @@ ';
        'META-COLOURS'       = @('Yellow');
        'MESSAGE-COLOURS'    = @('Cyan');
        'MESSAGE-SUFFIX'     = ' ~~ '
      };

      'ENVIRONMENT-THEME' = @{
        'FORMAT'             = 'env:"<%KEY%>"="<%VALUE%>"';
        'KEY-PLACE-HOLDER'   = '<%KEY%>';
        'VALUE-PLACE-HOLDER' = '<%VALUE%>';
        'KEY-COLOURS'        = @('DarkCyan');
        'VALUE-COLOURS'      = @('DarkBlue');
        'OPEN'               = '--- [';
        'CLOSE'              = '] ---';
        'SEPARATOR'          = ' ## ';
        'META-COLOURS'       = @('Black');
        'MESSAGE-COLOURS'    = @('DarkGreen');
        'MESSAGE-SUFFIX'     = ' == '
      };
    }
  }

  Context 'Dark Theme, "KRAYOLA-THEME-NAME" not defined in Environment' {
    Context 'Given: Theme not specified' {
      it 'Should: return default valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme -DefaultTheme $DefaultKrayolaTheme
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable
      }
    }

    Context 'Given: Named theme exists' {
      it 'Should: return requested pre-defined valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme -KrayolaThemeName 'THEME-ONE' -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable
      }
    }

    Context 'Named theme does not exist' {
      it 'Should: return default valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme -KrayolaThemeName 'MISSING' -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable
      }
    }
  } # Dark Theme, "KRAYOLA-THEME-NAME" not defined in Environment

  Context 'Light Theme, "KRAYOLA-THEME-NAME" not defined in Environment' {
    Context 'Given: Theme not specified' {
      it 'Should: return default valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $true }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['KEY-COLOURS'][0] | Should -Match 'Dark'
        $result['META-COLOURS'][0] | Should -Match 'Dark'
      }
    }

    Context 'Given: Named theme exists' {
      it 'Should: return requested pre-defined valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $true }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme -KrayolaThemeName 'THEME-ONE' -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['FORMAT'] | Should -Match 'one'
        # $result['KEY-COLOURS'] | Should -Match 'Dark'
        # $result['META-COLOURS'] | Should -Match 'Dark'
      }
    }

    Context 'Named theme does not exist' {
      it 'Should: return default valid theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $true }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return $null }

        $result = Get-KrayolaTheme -KrayolaThemeName 'MISSING' -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['KEY-COLOURS'] | Should -Match 'Dark'
        $result['META-COLOURS'] | Should -Match 'Dark'
      }
    }
  } # Light Theme, "KRAYOLA-THEME-NAME" not defined in Environment

  Context 'Themed defined in environment' {
    Context 'Given: KrayolaThemeName not specified' {
      It 'Should: return the Environment theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return 'ENVIRONMENT-THEME' }

        $result = Get-KrayolaTheme -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['FORMAT'] | Should -Match 'env'
      }
    }

    Context 'Given: Valid KrayolaThemeName specified' {
      It 'Should: return the specified theme, not Environment theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return 'ENVIRONMENT-THEME' }

        $result = Get-KrayolaTheme -KrayolaThemeName 'THEME-ONE' -Themes $TestThemes
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['FORMAT'] | Should -Match 'one'
      }
    }

    Context 'Given: non-existent KrayolaThemeName specified' {
      It 'Should: return the default theme' {
        Mock -ModuleName Elizium.Krayola Get-IsKrayolaLightTerminal { return $false }
        Mock -ModuleName Elizium.Krayola Get-EnvironmentVariable { return 'ENVIRONMENT-THEME' }

        $result = Get-KrayolaTheme -KrayolaThemeName 'MISSING' -Themes $TestThemes `
          -DefaultTheme $DefaultKrayolaTheme
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType System.Collections.Hashtable

        $result['FORMAT'] | Should -Match 'def'
      }
    }
  } # Themed defined in environment
} # Get-KrayolaTheme
