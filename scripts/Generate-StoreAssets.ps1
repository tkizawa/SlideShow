# Generate Microsoft Store Visual Assets from app.ico raw PNG frames

Add-Type -AssemblyName System.Drawing

$IcoPath = Resolve-Path "$PSScriptRoot\..\assets\app.ico"
$OutputDir = "$PSScriptRoot\..\assets\store"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$bytes = [System.IO.File]::ReadAllBytes($IcoPath)
$count = [BitConverter]::ToUInt16($bytes, 4)

# Find largest PNG frame
$bestOffset = 0
$bestSize = 0
$maxDimension = 0

for ($i = 0; $i -lt $count; $i++) {
    $offset = 6 + ($i * 16)
    $w = $bytes[$offset]
    if ($w -eq 0) { $w = 256 }
    $size = [BitConverter]::ToUInt32($bytes, $offset + 8)
    $imgOffset = [BitConverter]::ToUInt32($bytes, $offset + 12)
    
    $magic = [System.Text.Encoding]::ASCII.GetString($bytes, $imgOffset + 1, 3)
    if ($magic -eq "PNG" -and $w -ge $maxDimension) {
        $maxDimension = $w
        $bestOffset = $imgOffset
        $bestSize = $size
    }
}

Write-Host "Found best PNG frame: ${maxDimension}x${maxDimension} (Offset: $bestOffset, Size: $bestSize)"

# Extract raw PNG bytes
$pngBytes = new-object byte[] $bestSize
[Array]::Copy($bytes, $bestOffset, $pngBytes, 0, $bestSize)

$ms = New-Object System.IO.MemoryStream(,$pngBytes)
$sourceBitmap = [System.Drawing.Bitmap]::FromStream($ms)

function Save-StoreAsset {
    param(
        [System.Drawing.Bitmap]$Source,
        [int]$TargetWidth,
        [int]$TargetHeight,
        [string]$DestinationPath,
        [bool]$FillBackground = $false
    )

    $target = New-Object System.Drawing.Bitmap($TargetWidth, $TargetHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($target)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    if ($FillBackground) {
        # Fill sleek dark background (#111111 matching SlideShow theme)
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 17, 17, 17))
        $g.FillRectangle($brush, 0, 0, $TargetWidth, $TargetHeight)
        $brush.Dispose()
        
        $aspectSource = $Source.Width / $Source.Height
        $aspectTarget = $TargetWidth / $TargetHeight

        if ($aspectSource -gt $aspectTarget) {
            $drawWidth = [int]($TargetWidth * 0.75)
            $drawHeight = [int]($drawWidth / $aspectSource)
        } else {
            $drawHeight = [int]($TargetHeight * 0.75)
            $drawWidth = [int]($drawHeight * $aspectSource)
        }

        $x = [int](($TargetWidth - $drawWidth) / 2)
        $y = [int](($TargetHeight - $drawHeight) / 2)

        $g.DrawImage($Source, $x, $y, $drawWidth, $drawHeight)
    } else {
        # Clear transparent canvas
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($Source, 0, 0, $TargetWidth, $TargetHeight)
    }

    $target.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $target.Dispose()
    Write-Host "Generated clean asset: $DestinationPath ($TargetWidth x $TargetHeight)"
}

Save-StoreAsset -Source $sourceBitmap -TargetWidth 44 -TargetHeight 44 -DestinationPath "$OutputDir\Square44x44Logo.png" -FillBackground $false
Save-StoreAsset -Source $sourceBitmap -TargetWidth 150 -TargetHeight 150 -DestinationPath "$OutputDir\Square150x150Logo.png" -FillBackground $false
Save-StoreAsset -Source $sourceBitmap -TargetWidth 310 -TargetHeight 150 -DestinationPath "$OutputDir\Wide310x150Logo.png" -FillBackground $true
Save-StoreAsset -Source $sourceBitmap -TargetWidth 50 -TargetHeight 50 -DestinationPath "$OutputDir\StoreLogo.png" -FillBackground $false
Save-StoreAsset -Source $sourceBitmap -TargetWidth 300 -TargetHeight 300 -DestinationPath "$OutputDir\LargeTile.png" -FillBackground $false

$sourceBitmap.Dispose()
$ms.Dispose()

Write-Host "All Microsoft Store assets generated with crystal clear 32-bit PNG quality!" -ForegroundColor Green
