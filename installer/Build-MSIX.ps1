# MSIX Automated Build Script

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$StagingDir = "$ProjectRoot\output\msix_layout"
$OutputFile = "$ProjectRoot\output\WoodStreamSlideShow.msix"

Write-Host "1. Building release binary with dotnet publish..." -ForegroundColor Cyan
Set-Location $ProjectRoot
dotnet publish -c Release -r win-x64 --self-contained true -o "$StagingDir"

Write-Host "2. Copying Store assets and Package.appxmanifest..." -ForegroundColor Cyan
$StoreAssetDir = "$StagingDir\assets\store"
if (-not (Test-Path $StoreAssetDir)) {
    New-Item -ItemType Directory -Path $StoreAssetDir -Force | Out-Null
}

Copy-Item "$ProjectRoot\assets\store\*" -Destination $StoreAssetDir -Force
Copy-Item "$ProjectRoot\Package.appxmanifest" -Destination "$StagingDir\AppxManifest.xml" -Force

Write-Host "3. Packaging MSIX with makeappx.exe..." -ForegroundColor Cyan
$MakeAppx = Get-ChildItem -Path "$env:USERPROFILE\.nuget\packages\microsoft.windows.sdk.buildtools" -Recurse -Filter "makeappx.exe" | Where-Object { $_.FullName -like "*x64*" } | Select-Object -First 1 -ExpandProperty FullName

if (-not $MakeAppx) {
    throw "makeappx.exe not found!"
}

& $MakeAppx pack /d "$StagingDir" /p "$OutputFile" /o

Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "WoodStreamSlideShow.msix created successfully!" -ForegroundColor Green
Write-Host "File location: $OutputFile" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Green
