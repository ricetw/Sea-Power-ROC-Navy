$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$output = Join-Path $PSScriptRoot '..\mod\assets\rocn\weapons\hf-3\textures'
$colors = [ordered]@{
    'hf3_body_dark.png'       = '#0E1210'
    'hf3_duct_graphite.png'   = '#222625'
    'hf3_light_gray.png'      = '#A8B0AC'
    'hf3_panel_gray.png'      = '#5D6563'
    'hf3_black.png'           = '#040506'
    'hf3_nose_white.png'      = '#E6DFCD'
    'hf3_booster_gold.png'    = '#9C7C41'
    'hf3_pylon_offwhite.png'  = '#BBB89F'
    'hf3_fin_red.png'         = '#C20E08'
    'hf3_roundel_blue.png'    = '#052185'
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
foreach ($entry in $colors.GetEnumerator()) {
    $bitmap = [System.Drawing.Bitmap]::new(4, 4)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml($entry.Value))
        $bitmap.Save((Join-Path $output $entry.Key), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}


$atlasMaterials = @(
    @{ Name = 'hf3_body_dark';      Color = '#0E1210' },
    @{ Name = 'hf3_nose_white';     Color = '#E6DFCD' },
    @{ Name = 'hf3_nozzle_black';   Color = '#040506' },
    @{ Name = 'hf3_light_gray';     Color = '#A8B0AC' },
    @{ Name = 'hf3_panel_gray';     Color = '#5D6563' },
    @{ Name = 'hf3_panel_line';     Color = '#121514' },
    @{ Name = 'hf3_duct_graphite';  Color = '#222625' },
    @{ Name = 'hf3_intake_black';   Color = '#040506' },
    @{ Name = 'hf3_booster_gold';   Color = '#9C7C41' },
    @{ Name = 'hf3_panel_black';    Color = '#040506' },
    @{ Name = 'hf3_pylon_offwhite'; Color = '#BBB89F' },
    @{ Name = 'hf3_fin_red';        Color = '#C20E08' },
    @{ Name = 'hf3_decal_side_text'; Color = '#0E1210'; Image = 'hf3_side_marking.png' },
    @{ Name = 'hf3_decal_s001';      Color = '#0E1210'; Image = 'hf3_s001.png' },
    @{ Name = 'hf3_roundel_blue';   Color = '#052185' }
)

$atlasSize = 1024
$gridSize = 4
$cellSize = [int]($atlasSize / $gridSize)
$padding = [int]($cellSize * 0.025)
$atlas = [System.Drawing.Bitmap]::new($atlasSize, $atlasSize)
$atlasGraphics = [System.Drawing.Graphics]::FromImage($atlas)
$atlasGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$atlasGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
try {
    $atlasGraphics.Clear([System.Drawing.Color]::Black)
    for ($index = 0; $index -lt $atlasMaterials.Count; $index++) {
        $material = $atlasMaterials[$index]
        $column = $index % $gridSize
        $row = [Math]::Floor($index / $gridSize)
        $cell = [System.Drawing.Rectangle]::new($column * $cellSize, $row * $cellSize, $cellSize, $cellSize)
        $brush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($material.Color))
        try {
            $atlasGraphics.FillRectangle($brush, $cell)
        }
        finally {
            $brush.Dispose()
        }

        if ($material.Image) {
            $sourcePath = Join-Path $output $material.Image
            $source = [System.Drawing.Image]::FromFile($sourcePath)
            try {
                $target = [System.Drawing.Rectangle]::new(
                    $cell.X + $padding,
                    $cell.Y + $padding,
                    $cell.Width - 2 * $padding,
                    $cell.Height - 2 * $padding
                )
                $atlasGraphics.DrawImage($source, $target)
            }
            finally {
                $source.Dispose()
            }
        }
    }
    $atlas.Save((Join-Path $output 'hf3_atlas.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $atlasGraphics.Dispose()
    $atlas.Dispose()
}
