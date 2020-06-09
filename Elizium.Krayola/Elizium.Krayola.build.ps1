
task . Clean, Build, Tests, Stats
task Tests ImportCompiledModule, Pester
task CreateManifest CopyPSD, UpdatePublicFunctionsToExport
task Build Compile, CreateManifest, Ana
task Stats RemoveStats, WriteStats
task Ana Analyse
task Fix ApplyFix

$script:ModuleName = Split-Path -Path $PSScriptRoot -Leaf
$script:ModuleRoot = $PSScriptRoot
$script:OutPutFolder = "$PSScriptRoot/Output"
$script:ImportFolders = @('Public', 'Internal', 'Classes') 
$script:PsmPath = Join-Path -Path $PSScriptRoot -ChildPath "Output/$($script:ModuleName)/$($script:ModuleName).psm1"
$script:PsdPath = Join-Path -Path $PSScriptRoot -ChildPath "Output/$($script:ModuleName)/$($script:ModuleName).psd1"

$script:PublicFolder = 'Public'
$script:DSCResourceFolder = 'DSCResources'

$script:SourcePsdPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:ModuleName).psd1"

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

  foreach ($folder in $script:ImportFolders) {
    $currentFolder = Join-Path -Path $script:ModuleRoot -ChildPath $folder
    Write-Verbose -Message "Checking folder [$currentFolder]"

    if (Test-Path -Path $currentFolder) {
      $files = Get-ChildItem -Path $currentFolder -File -Filter '*.ps1'
      foreach ($file in $files) {
        Write-Verbose -Message "Adding $($file.FullName)"
        Get-Content -Path (Resolve-Path $file.FullName) >> $script:PsmPath
      }
    }
  }

  $sourceDefinition = Import-PowerShellDataFile -Path $script:SourcePsdPath

  if ($sourceDefinition -and $sourceDefinition.ContainsKey('VariablesToExport')) {
    [string[]]$exportVariables = $sourceDefinition['VariablesToExport'];
    Write-Verbose "Found VariablesToExport: $exportVariables in source Psd file: $script:SourcePsdPath";

    [string]$variablesArgument = $($exportVariables -join ",") + [System.Environment]::NewLine;
    [string]$contentToAdd = "Export-ModuleMember -Variable $variablesArgument";
    Write-Verbose "Adding content: $contentToAdd";

    Add-Content $script:PsmPath "Export-ModuleMember -Variable $variablesArgument";
  }
}

task CopyPSD {
  New-Item -Path (Split-Path $script:PsdPath) -ItemType Directory -ErrorAction 0
  $copy = @{
    Path        = "$($script:ModuleName).psd1"
    Destination = $script:PsdPath
    Force       = $true
    Verbose     = $true
  }
  Copy-Item @copy
}

task UpdatePublicFunctionsToExport -if (Test-Path -Path $script:PublicFolder) {
  $publicFunctions = (Get-ChildItem -Path $script:PublicFolder |
    Select-Object -ExpandProperty BaseName) -join "', '"

    $publicFunctions = "FunctionsToExport = @('{0}')" -f $publicFunctions

  (Get-Content -Path $script:PsdPath) -replace "FunctionsToExport = '/*'", $publicFunctions |
  Set-Content -Path $script:PsdPath
}



task ImportCompiledModule -if (Test-Path -Path $script:PsmPath) {
  Get-Module -Name $script:ModuleName |
  Remove-Module -Force
  Import-Module -Name $script:PsdPath -Force
}

task Pester {
  $resultFile = "{0}/testResults{1}.xml" -f $script:OutPutFolder, (Get-date -Format 'yyyyMMdd_hhmmss')
  $testFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Tests/*'

  $configuration = [PesterConfiguration]::Default
  $configuration.Run.Path = $testFolder
  $configuration.TestResult.Enabled = $true
  $configuration.TestResult.OutputFormat = 'NUnitxml'
  $configuration.TestResult.OutputPath = $resultFile;

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
  Invoke-ScriptAnalyzer -Path .\Output\ -Recurse
}

task ApplyFix {
  Invoke-ScriptAnalyzer -Path .\ -Recurse -Fix
}
