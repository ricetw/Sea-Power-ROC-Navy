$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot 'generate_rocn_hf3_highpoly.py'
python $scriptPath

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$assetFolder = Join-Path $repoRoot 'mod\assets\rocn\weapons\hf-3'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'rocn_hf-3_game.obj') -Destination $assetFolder -Force
& (Join-Path $repoRoot 'tools\generate_hf3_material_textures.ps1')
