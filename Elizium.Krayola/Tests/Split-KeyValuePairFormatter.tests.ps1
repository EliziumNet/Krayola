
Describe 'Split-KeyValuePairFormatter' {
  BeforeAll {
    InModuleScope Elizium.Krayola {
      Get-Module Elizium.Krayola | Remove-Module
      Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
        -ErrorAction 'stop' -DisableNameChecking
    }
  }

  InModuleScope Elizium.Krayola {
    Context 'Format is Key before Value' {
      Context 'Given: minimal format' {
        It 'Should: return formatted string' {
          InModuleScope Elizium.Krayola {
            [string]$format = '<%KEY%><%VALUE%>';
            [string]$keyConstituent = 'Band';
            [string]$valueConstituent = 'The Nephilim';

            $result = Split-KeyValuePairFormatter -Format $format `
              -KeyConstituent $keyConstituent -ValueConstituent $valueConstituent;

            $result.Count | Should -Be 5;
            $result[0] | Should -Be '';
            $result[1] | Should -Be 'Band';
            $result[2] | Should -Be '';
            $result[3] | Should -Be 'The Nephilim';
            $result[4] | Should -Be '';
          }
        }
      }

      Context 'Given: format with leading, mid and trailing tokens' {
        It 'Should: return formatted string' {
          InModuleScope Elizium.Krayola {
            [string]$format = '===(<%KEY%>=<%VALUE%>)===';
            [string]$keyConstituent = 'Band';
            [string]$valueConstituent = 'The Nephilim';

            $result = Split-KeyValuePairFormatter -Format $format `
              -KeyConstituent $keyConstituent -ValueConstituent $valueConstituent;

            $result.Count | Should -Be 5;
            $result[0] | Should -Be '===(';
            $result[1] | Should -Be 'Band';
            $result[2] | Should -Be '=';
            $result[3] | Should -Be 'The Nephilim';
            $result[4] | Should -Be ')===';
          }
        }
      }
    }

    Context 'Format is Value before Key' {
      Context 'Given: minimal format' {
        It 'Should: return formatted string' {
          InModuleScope Elizium.Krayola {
            [string]$format = '<%VALUE%><%KEY%>';
            [string]$keyConstituent = 'Band';
            [string]$valueConstituent = 'The Nephilim';

            $result = Split-KeyValuePairFormatter -Format $format `
              -KeyConstituent $keyConstituent -ValueConstituent $valueConstituent;

            $result.Count | Should -Be 5;
            $result[0] | Should -Be '';
            $result[1] | Should -Be 'The Nephilim';
            $result[2] | Should -Be '';
            $result[3] | Should -Be 'Band';
            $result[4] | Should -Be '';
          }
        }
      }

      Context 'Given: format with leading, mid and trailing tokens' {
        It 'Should: return formatted string' {
          InModuleScope Elizium.Krayola {
            [string]$format = '===(<%VALUE%>=<%KEY%>)===';
            [string]$keyConstituent = 'Band';
            [string]$valueConstituent = 'The Nephilim';

            $result = Split-KeyValuePairFormatter -Format $format `
              -KeyConstituent $keyConstituent -ValueConstituent $valueConstituent;

            $result.Count | Should -Be 5;
            $result[0] | Should -Be '===(';
            $result[1] | Should -Be 'The Nephilim';
            $result[2] | Should -Be '=';
            $result[3] | Should -Be 'Band';
            $result[4] | Should -Be ')===';
          }
        }
      }  
    }
  }
} # Split-KeyValuePairFormatter
