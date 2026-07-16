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
