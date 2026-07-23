# MSIX Staging Script

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$StagingDir = "$ProjectRoot\output\msix_layout"

Write-Host "1. Building release binary with dotnet publish..." -ForegroundColor Cyan
Set-Location $ProjectRoot
dotnet publish -c Release -r win-x64 --self-contained true -o "$StagingDir"

Write-Host "2. Copying Store assets and AppxManifest.xml to staging directory..." -ForegroundColor Cyan
$StoreAssetDir = "$StagingDir\assets\store"
if (-not (Test-Path $StoreAssetDir)) {
    New-Item -ItemType Directory -Path $StoreAssetDir -Force | Out-Null
}

Copy-Item "$ProjectRoot\assets\store\*" -Destination $StoreAssetDir -Force
Copy-Item "$ProjectRoot\Package.appxmanifest" -Destination "$StagingDir\AppxManifest.xml" -Force

Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "MSIX Staging Directory created successfully: $StagingDir" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "Next Steps:"
Write-Host "1. Update Package.appxmanifest with your Publisher ID from Partner Center."
Write-Host "2. Use MSIX Packaging Tool to create the .msix package from output/msix_layout."
