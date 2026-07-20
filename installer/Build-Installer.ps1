#Requires -Version 5.1
param(
    [string]$SourceRoot = $PSScriptRoot,
    [string]$IsccPath
)

$ErrorActionPreference = 'Stop'

function Resolve-IsccPath {
    param(
        [string]$ExplicitPath
    )

    if ($ExplicitPath) {
        return $ExplicitPath
    }

    $candidates = @(
        'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
        'C:\Program Files\Inno Setup 6\ISCC.exe',
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

# dotnet publish
$projectFile = Join-Path $SourceRoot '..\SlideShow.csproj'
$publishRoot = Join-Path $SourceRoot 'publish'

if (-not (Test-Path $projectFile)) {
    throw "Project file not found: $projectFile"
}

Write-Host ">>> dotnet publish ..."
New-Item -ItemType Directory -Force -Path $publishRoot | Out-Null

dotnet publish $projectFile `
    -c Release `
    -r win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:PublishTrimmed=false `
    -o $publishRoot | Out-Host

if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed." }

# Inno Setup compile
 $IsccPath = Resolve-IsccPath -ExplicitPath $IsccPath
if (-not (Test-Path $IsccPath)) {
    throw "Inno Setup compiler not found: $IsccPath`nInno Setup 6 をインストールしてから再実行してください。`nhttps://jrsoftware.org/isdl.php"
}

$issFile = Join-Path $SourceRoot 'SlideShow.iss'
Write-Host ">>> Inno Setup compile ..."
& $IsccPath $issFile

if ($LASTEXITCODE -ne 0) { throw "Inno Setup compile failed." }

Write-Host "Done. Installer is in: $SourceRoot\output"
