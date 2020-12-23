using namespace System.Text.RegularExpressions;

task . Clean, Build, Tests, Stats
task Tests ImportCompiledModule, Pester
task CreateManifest CopyPSD, UpdatePublicFunctionsToExport
task Build Compile, CreateManifest
task Stats RemoveStats, WriteStats
task Ana Analyse
task Fix ApplyFix
task BuildHelp Docs

$script:ModuleName = Split-Path -Path $PSScriptRoot -Leaf
$script:ModuleRoot = $PSScriptRoot
$script:OutPutFolder = "$PSScriptRoot/Output"
$script:ImportFolders = @('Public', 'Internal', 'Classes')
$script:PsmPath = Join-Path -Path $PSScriptRoot -ChildPath "Output/$($script:ModuleName)/$($script:ModuleName).psm1"
$script:PsdPath = Join-Path -Path $PSScriptRoot -ChildPath "Output/$($script:ModuleName)/$($script:ModuleName).psd1"

$script:PublicFolder = 'Public'
$script:DSCResourceFolder = 'DSCResources'

$script:SourcePsdPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:ModuleName).psd1"
$script:TestHelpers = "$PSScriptRoot/Tests/Helpers"

if (Test-Path -Path $script:TestHelpers) {
  $helpers = Get-ChildItem -Path $script:TestHelpers -Recurse -File -Filter '*.ps1';
  $helpers | ForEach-Object { Write-Verbose "sourcing helper $_"; . $_; }
}

function Get-FunctionExportList {
  (Get-ChildItem -Path $script:PublicFolder | Where-Object { $_.Name -like '*-*' } |
    Select-Object -ExpandProperty BaseName)
}

function Get-PublicFunctionAliasesToExport {
  [string]$expression = 'Alias\((?<aliases>((?<quote>[''"])[\w-]+\k<quote>\s*,?\s*)+)\)';
  [System.Text.RegularExpressions.RegexOptions]$options = 'IgnoreCase, SingleLine';

  [System.Text.RegularExpressions.RegEx]$aliasesRegEx = `
    New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList ($expression, $options);

  [string]$publicPath = "$PSScriptRoot/Public";

  [string[]]$aliases = @();

  Get-ChildItem -Recurse -File -Filter '*.ps1' -Path $publicPath | Foreach-Object {
    [string]$content = Get-Content $_;

    [System.Text.RegularExpressions.Match]$contentMatch = $aliasesRegEx.Match($content);

    if ($contentMatch.Success) {
      $al = $contentMatch.Groups['aliases'];
      $al = $($al -split ',' | ForEach-Object { $_.Trim().replace('"', '').replace("'", "") });
      $aliases += $al;
    }
  };

  $aliases;
}

task Clean {
  if (-not(Test-Path $script:OutPutFolder)) {
    New-Item -ItemType Directory -Path $script:OutPutFolder > $null
  }
  else {
    $resolvedOutputContents = Resolve-Path $script:OutPutFolder;
    if ($resolvedOutputContents) {
      Remove-Item -Path (Resolve-Path $resolvedOutputContents) -Force -Recurse
    }
  }
}

$compileParams = @{
  Inputs = {
    foreach ($folder in $script:ImportFolders) {
      Get-ChildItem -Path $folder -Recurse -File -Filter '*.ps1'
    }
  }

  Output = {
    $script:PsmPath
  }
}

task Compile @compileParams {
  if (Test-Path -Path $script:PsmPath) {
    Remove-Item -Path (Resolve-Path $script:PsmPath) -Recurse -Force
  }
  New-Item -Path $script:PsmPath -Force > $null

  "Set-StrictMode -Version 1.0" >> $script:PsmPath
  # !!!BUG: This should be using whatever is yielded by @compileParams
  #
  foreach ($folder in $script:ImportFolders) {
    $currentFolder = Join-Path -Path $script:ModuleRoot -ChildPath $folder
    Write-Verbose -Message "Checking folder [$currentFolder]"

    if (Test-Path -Path $currentFolder) {

      $files = Get-ChildItem -Path $currentFolder -File -Recurse -Filter '*.ps1'
      foreach ($file in $files) {
        Write-Verbose -Message "Adding $($file.FullName)"
        Get-Content -Path (Resolve-Path $file.FullName) >> $script:PsmPath
      }
    }
  }

  [hashtable]$sourceDefinition = Import-PowerShellDataFile -Path $script:SourcePsdPath

  if ($sourceDefinition) {
    if ($sourceDefinition.ContainsKey('VariablesToExport')) {
      [string[]]$exportVariables = $sourceDefinition['VariablesToExport'];
      Write-Verbose "Found VariablesToExport: $exportVariables in source Psd file: $script:SourcePsdPath";

      if (-not([string]::IsNullOrEmpty($exportVariables))) {
        [string]$variablesArgument = $($exportVariables -join ", ") + [System.Environment]::NewLine;
        [string]$contentToAdd = "Export-ModuleMember -Variable $variablesArgument";
        Write-Verbose "Adding content: $contentToAdd";

        Add-Content $script:PsmPath "Export-ModuleMember -Variable $variablesArgument";
      }
    }

    if ($sourceDefinition.ContainsKey('AliasesToExport')) {
      [string[]]$functionAliases = Get-PublicFunctionAliasesToExport;

      if ($functionAliases.Count -gt 0) {
        [string]$aliasesArgument = $($functionAliases -join ", ") + [System.Environment]::NewLine;

        Write-Verbose "Found AliasesToExport: $aliasesArgument in source Psd file: $script:SourcePsdPath";
        [string]$contentToAdd = "Export-ModuleMember -Alias $aliasesArgument";

        Add-Content $script:PsmPath "Export-ModuleMember -Alias $aliasesArgument";
      } 
    }
  }

  $publicFunctions = Get-FunctionExportList;

  if ($publicFunctions.Length -gt 0) {
    Add-Content $script:PsmPath "Export-ModuleMember -Function $($publicFunctions -join ', ')";
  }

  # Insert custom module initialisation (./Init/module.ps1)
  #
  $initFolder = Join-Path -Path $script:ModuleRoot -ChildPath 'Init'
  if (Test-Path -Path $initFolder) {
    Write-Verbose "Injecting custom module initialisation code";
    "" >> $script:PsmPath;
    "# Custom Module Initialisation" >> $script:PsmPath;
    "#" >> $script:PsmPath;
    $moduleInitPath = Join-Path -Path $initFolder -ChildPath 'module.ps1';
    $moduleInitContent = Get-Content -LiteralPath $moduleInitPath;
    $moduleInitContent >> $script:PsmPath;
  }
}

task CopyPSD {
  if (-not(Test-Path (Split-Path $script:PsdPath))) {
    New-Item -Path (Split-Path $script:PsdPath) -ItemType Directory -ErrorAction 0
  }
  $copy = @{
    Path        = "$($script:ModuleName).psd1"
    Destination = $script:PsdPath
    Force       = $true
    Verbose     = $true
  }
  Copy-Item @copy
}

task UpdatePublicFunctionsToExport -if (Test-Path -Path $script:PublicFolder) {
  # This task only updates the psd file. The compile task updates the psm file
  #
  $publicFunctions = (Get-FunctionExportList) -join "', '"

  if (-not([string]::IsNullOrEmpty($publicFunctions))) {
    Write-Verbose "Functions to export: $publicFunctions"

    $publicFunctions = "FunctionsToExport = @('{0}')" -f $publicFunctions

    # Make sure in your source psd1 file, FunctionsToExport  is set to ''.
    # PowerShell has a problem with trying to replace (), so @() does not
    # work without jumping through hoops. (Same goes for AliasesToExport)
    #
    (Get-Content -Path $script:PsdPath) -replace "FunctionsToExport = ''", $publicFunctions |
    Set-Content -Path $script:PsdPath
  }

  [hashtable]$sourceDefinition = Import-PowerShellDataFile -Path $script:PsdPath
  if ($sourceDefinition.ContainsKey('AliasesToExport')) {
    [string[]]$aliases = Get-PublicFunctionAliasesToExport;

    if ($aliases.Count -gt 0) {      
      [string]$aliasesArgument = $($aliases -join "', '");
      $aliasesStatement = "AliasesToExport = @('{0}')" -f $aliasesArgument
      Write-Verbose "AliasesToExport statement: $aliasesStatement"

      (Get-Content -Path $script:PsdPath) -replace "AliasesToExport = ''", $aliasesStatement |
      Set-Content -Path $script:PsdPath
    }
  }
}

task ImportCompiledModule -if (Test-Path -Path $script:PsmPath) {
  Get-Module -Name $script:ModuleName | Remove-Module -Force
  Import-Module -Name $script:PsdPath -Force -DisableNameChecking
}

task Pester {
  $resultFile = "{0}/testResults{1}.xml" -f $script:OutPutFolder, (Get-date -Format 'yyyyMMdd_hhmmss')
  $testFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Tests/*'

  $configuration = [PesterConfiguration]::Default
  $configuration.Run.Path = $testFolder
  $configuration.TestResult.Enabled = $true
  $configuration.TestResult.OutputFormat = 'NUnitxml'
  $configuration.TestResult.OutputPath = $resultFile;
  # $configuration.Filter.Tag = 'Current'
  Invoke-Pester -Configuration $configuration
}

task RemoveStats -if (Test-Path -Path "$($script:OutPutFolder)/stats.json") {
  # Remove-Item -Force -Verbose -Path (Resolve-Path "$($script:OutPutFolder)/stats.json")
}

task WriteStats {
  $folders = Get-ChildItem -Directory |
  Where-Object { $PSItem.Name -ne 'Output' }

  $stats = foreach ($folder in $folders) {
    $files = Get-ChildItem "$($folder.FullName)/*" -File
    if ($files) {
      Get-Content -Path (Resolve-Path $files) |
      Measure-Object -Word -Line -Character |
      Select-Object -Property @{N = "FolderName"; E = { $folder.Name } }, Words, Lines, Characters
    }
  }
  $stats | ConvertTo-Json > "$script:OutPutFolder/stats.json"
}

task Analyse {
  if (Test-Path -Path .\Output\) {
    Invoke-ScriptAnalyzer -Path .\Output\ -Recurse
  }
}

task ApplyFix {
  Invoke-ScriptAnalyzer -Path .\ -Recurse -Fix
}

# Before this can be run, this must be run first
# New-MarkdownHelp -Module <Module> -OutputFolder .\docs
# (run from the module root, not the repo root)
# Then update the {{ ... }} place holders in the md files.
# the docs task generates the external help from the md files
#
task Docs {
  New-ExternalHelp $script:ModuleRoot\docs `
    -OutputPath $script:OutPutFolder\$script:ModuleName\en-GB
}
