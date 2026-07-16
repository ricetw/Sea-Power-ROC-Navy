$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'generate_cheng_kung_additions.py'
python $scriptPath

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$assetFolder = Join-Path $repoRoot 'mod\assets\rocn\ships\cheng_kung'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'rocn_cheng_kung_additions.obj') -Destination $assetFolder -Force
