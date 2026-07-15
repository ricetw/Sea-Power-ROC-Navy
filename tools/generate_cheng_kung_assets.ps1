param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Add-Type -AssemblyName System.Drawing

$hullNumberDir = Join-Path $RepositoryRoot 'mod\assets\rocn\ships\cheng_kung\hullnumbers'
$profileDir = Join-Path $RepositoryRoot 'mod\ui\profiles'
$sourceImage = Join-Path $RepositoryRoot 'reference\rocn\cheng_kung\official_cheng_kung_1106.jpg'

New-Item -ItemType Directory -Force -Path $hullNumberDir, $profileDir | Out-Null

$numbers = '1101', '1103', '1105', '1106', '1107', '1108', '1109', '1110'
$font = [System.Drawing.Font]::new('Arial', 36, [System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$format = [System.Drawing.StringFormat]::new()
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center
$shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(210, 20, 22, 24))
$numberBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 205, 208, 210))

foreach ($number in $numbers) {
    $bitmap = [System.Drawing.Bitmap]::new(128, 128, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.DrawString($number, $font, $shadowBrush, [System.Drawing.RectangleF]::new(12, 42, 108, 48), $format)
    $graphics.DrawString($number, $font, $numberBrush, [System.Drawing.RectangleF]::new(10, 40, 108, 48), $format)
    $output = Join-Path $hullNumberDir "roc_ffg_$number.png"
    $bitmap.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

$source = [System.Drawing.Image]::FromFile($sourceImage)
$profile = [System.Drawing.Bitmap]::new(512, 152, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$profileGraphics = [System.Drawing.Graphics]::FromImage($profile)
$profileGraphics.Clear([System.Drawing.Color]::Black)
$profileGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$profileGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$profileGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$sourceAspect = $source.Width / $source.Height
$targetAspect = $profile.Width / $profile.Height

if ($sourceAspect -gt $targetAspect) {
    $cropHeight = $source.Height
    $cropWidth = [int]($cropHeight * $targetAspect)
    $cropX = [int](($source.Width - $cropWidth) / 2)
    $cropY = 0
} else {
    $cropWidth = $source.Width
    $cropHeight = [int]($cropWidth / $targetAspect)
    $cropX = 0
    $cropY = [int](($source.Height - $cropHeight) * 0.58)
    $cropY = [Math]::Max(0, [Math]::Min($cropY, $source.Height - $cropHeight))
}

$destinationRect = [System.Drawing.Rectangle]::new(0, 0, $profile.Width, $profile.Height)
$sourceRect = [System.Drawing.Rectangle]::new($cropX, $cropY, $cropWidth, $cropHeight)
$profileGraphics.DrawImage($source, $destinationRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
$profile.Save((Join-Path $profileDir 'roc_ffg_cheng_kung.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$profile.Save((Join-Path $profileDir 'roc_ffg_tien_tan.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$profileGraphics.Dispose()
$profile.Dispose()
$source.Dispose()
$font.Dispose()
$format.Dispose()
$shadowBrush.Dispose()
$numberBrush.Dispose()
