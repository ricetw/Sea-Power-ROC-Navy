$ErrorActionPreference = 'Stop'
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$objPath = Join-Path $outDir 'rocn_hf-3.obj'
$mtlPath = Join-Path $outDir 'rocn_hf-3.mtl'
$readmePath = Join-Path $outDir 'README.md'
$vertices = New-Object System.Collections.Generic.List[string]
$faces = New-Object System.Collections.Generic.List[string]
$currentMaterial = ''
$currentGroup = ''

function Add-Vertex([double]$x, [double]$y, [double]$z) {
    $script:vertices.Add(('v {0:F6} {1:F6} {2:F6}' -f $x, $y, $z))
    return $script:vertices.Count
}
function Set-Part([string]$group, [string]$material, [bool]$smooth = $true) {
    if ($script:currentGroup -ne $group) {
        $script:faces.Add('')
        $script:faces.Add("g $group")
        $script:faces.Add($(if ($smooth) { 's 1' } else { 's off' }))
        $script:currentGroup = $group
    }
    if ($script:currentMaterial -ne $material) {
        $script:faces.Add("usemtl $material")
        $script:currentMaterial = $material
    }
}
function Add-Face([int[]]$idx) { $script:faces.Add(('f ' + ($idx -join ' '))) }

function Add-CylinderX([string]$group, [string]$mat, [double]$x0, [double]$x1, [double]$radius, [int]$seg, [double]$cy = 0, [double]$cz = 0, [bool]$caps = $true) {
    Set-Part $group $mat $true
    $a = @(); $b = @()
    for ($i = 0; $i -lt $seg; $i++) {
        $ang = 2.0 * [Math]::PI * $i / $seg
        $y = $cy + $radius * [Math]::Cos($ang)
        $z = $cz + $radius * [Math]::Sin($ang)
        $a += Add-Vertex $x0 $y $z
        $b += Add-Vertex $x1 $y $z
    }
    for ($i = 0; $i -lt $seg; $i++) {
        $j = ($i + 1) % $seg
        Add-Face @($a[$i], $a[$j], $b[$j], $b[$i])
    }
    if ($caps) {
        $ca = Add-Vertex $x0 $cy $cz
        $cb = Add-Vertex $x1 $cy $cz
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($ca, $a[$i], $a[$j])
            Add-Face @($cb, $b[$j], $b[$i])
        }
    }
}

function Add-TaperedCylinderX([string]$group, [string]$mat, [double[]]$xs, [double[]]$rs, [int]$seg) {
    Set-Part $group $mat $true
    $rings = @()
    for ($k = 0; $k -lt $xs.Count; $k++) {
        $ring = @()
        for ($i = 0; $i -lt $seg; $i++) {
            $ang = 2.0 * [Math]::PI * $i / $seg
            $ring += Add-Vertex $xs[$k] ($rs[$k] * [Math]::Cos($ang)) ($rs[$k] * [Math]::Sin($ang))
        }
        $rings += ,$ring
    }
    for ($k = 0; $k -lt ($rings.Count - 1); $k++) {
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($rings[$k][$i], $rings[$k][$j], $rings[$k+1][$j], $rings[$k+1][$i])
        }
    }
}

function Add-OgiveNoseX([string]$group, [string]$mat, [double]$xBase, [double]$xTip, [double]$radius, [int]$rings, [int]$seg) {
    Set-Part $group $mat $true
    $all = @()
    for ($k = 0; $k -lt $rings; $k++) {
        $t = [double]$k / [double]$rings
        $x = $xBase + ($xTip - $xBase) * $t
        $r = $radius * [Math]::Pow((1.0 - $t), 0.58)
        $ring = @()
        for ($i = 0; $i -lt $seg; $i++) {
            $ang = 2.0 * [Math]::PI * $i / $seg
            $ring += Add-Vertex $x ($r * [Math]::Cos($ang)) ($r * [Math]::Sin($ang))
        }
        $all += ,$ring
    }
    $tip = Add-Vertex $xTip 0 0
    for ($k = 0; $k -lt ($all.Count - 1); $k++) {
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($all[$k][$i], $all[$k][$j], $all[$k+1][$j], $all[$k+1][$i])
        }
    }
    $last = $all[$all.Count - 1]
    for ($i = 0; $i -lt $seg; $i++) {
        $j = ($i + 1) % $seg
        Add-Face @($last[$i], $last[$j], $tip)
    }
}

function Add-Box([string]$group, [string]$mat, [double]$x0, [double]$x1, [double]$y0, [double]$y1, [double]$z0, [double]$z1, [bool]$smooth = $false) {
    Set-Part $group $mat $smooth
    $v = @()
    $v += Add-Vertex $x0 $y0 $z0; $v += Add-Vertex $x1 $y0 $z0; $v += Add-Vertex $x1 $y1 $z0; $v += Add-Vertex $x0 $y1 $z0
    $v += Add-Vertex $x0 $y0 $z1; $v += Add-Vertex $x1 $y0 $z1; $v += Add-Vertex $x1 $y1 $z1; $v += Add-Vertex $x0 $y1 $z1
    Add-Face @($v[0], $v[1], $v[2], $v[3]); Add-Face @($v[4], $v[7], $v[6], $v[5])
    Add-Face @($v[0], $v[4], $v[5], $v[1]); Add-Face @($v[1], $v[5], $v[6], $v[2])
    Add-Face @($v[2], $v[6], $v[7], $v[3]); Add-Face @($v[3], $v[7], $v[4], $v[0])
}

function Add-AirfoilFinZ([string]$group, [string]$mat, [double]$xRoot0, [double]$xRoot1, [double]$xTip0, [double]$xTip1, [double]$zRoot, [double]$zTip, [double]$halfThickness, [double]$sign) {
    Set-Part $group $mat $false
    $zr = $sign * $zRoot; $zt = $sign * $zTip
    $midX0 = ($xRoot0 + $xTip0) / 2.0; $midX1 = ($xRoot1 + $xTip1) / 2.0
    $v = @()
    $v += Add-Vertex $xRoot0 (-$halfThickness) $zr
    $v += Add-Vertex $xRoot1 (-$halfThickness) $zr
    $v += Add-Vertex $xTip1  0 $zt
    $v += Add-Vertex $xTip0  0 $zt
    $v += Add-Vertex $xRoot0 $halfThickness $zr
    $v += Add-Vertex $xRoot1 $halfThickness $zr
    $v += Add-Vertex $midX1 ($halfThickness*0.35) ($sign*($zRoot*0.65+$zTip*0.35))
    $v += Add-Vertex $midX0 ($halfThickness*0.35) ($sign*($zRoot*0.65+$zTip*0.35))
    Add-Face @($v[0], $v[1], $v[2], $v[3])
    Add-Face @($v[4], $v[7], $v[6], $v[5])
    Add-Face @($v[0], $v[4], $v[5], $v[1])
    Add-Face @($v[1], $v[5], $v[6], $v[2])
    Add-Face @($v[2], $v[6], $v[7], $v[3])
    Add-Face @($v[3], $v[7], $v[4], $v[0])
}

function Add-AirfoilFinY([string]$group, [string]$mat, [double]$xRoot0, [double]$xRoot1, [double]$xTip0, [double]$xTip1, [double]$yRoot, [double]$yTip, [double]$halfThickness, [double]$sign) {
    Set-Part $group $mat $false
    $yr = $sign * $yRoot; $yt = $sign * $yTip
    $midX0 = ($xRoot0 + $xTip0) / 2.0; $midX1 = ($xRoot1 + $xTip1) / 2.0
    $v = @()
    $v += Add-Vertex $xRoot0 $yr (-$halfThickness)
    $v += Add-Vertex $xRoot1 $yr (-$halfThickness)
    $v += Add-Vertex $xTip1  $yt 0
    $v += Add-Vertex $xTip0  $yt 0
    $v += Add-Vertex $xRoot0 $yr $halfThickness
    $v += Add-Vertex $xRoot1 $yr $halfThickness
    $v += Add-Vertex $midX1 ($sign*($yRoot*0.65+$yTip*0.35)) ($halfThickness*0.35)
    $v += Add-Vertex $midX0 ($sign*($yRoot*0.65+$yTip*0.35)) ($halfThickness*0.35)
    Add-Face @($v[0], $v[1], $v[2], $v[3])
    Add-Face @($v[4], $v[7], $v[6], $v[5])
    Add-Face @($v[0], $v[4], $v[5], $v[1])
    Add-Face @($v[1], $v[5], $v[6], $v[2])
    Add-Face @($v[2], $v[6], $v[7], $v[3])
    Add-Face @($v[3], $v[7], $v[4], $v[0])
}

$seg = 128
$bodyXs = @(-2.50,-2.35,-1.80,-1.20,-0.60,0.00,0.60,1.20,1.80,2.16)
$bodyRs = @(0.205,0.230,0.230,0.231,0.231,0.231,0.231,0.230,0.230,0.230)
Add-TaperedCylinderX 'main_body_highpoly' 'hf3_body_gray' $bodyXs $bodyRs $seg
Add-OgiveNoseX 'smooth_white_ogive_nose' 'hf3_nose_white' 2.16 3.05 0.230 28 $seg
Add-CylinderX 'aft_booster_case' 'hf3_booster_brown' -3.05 -2.50 0.205 96 0 0 $true
Add-CylinderX 'recessed_black_nozzle_outer' 'hf3_nozzle_black' -3.05 -2.94 0.160 96 0 0 $true
Add-CylinderX 'inner_nozzle_shadow' 'hf3_nozzle_inner' -3.045 -2.965 0.095 96 0 0 $true

# Panel rings and nose/body bands.
Add-CylinderX 'nose_gray_band' 'hf3_panel_dark' 2.10 2.18 0.233 128 0 0 $false
Add-CylinderX 'aft_gray_band' 'hf3_panel_dark' -2.43 -2.34 0.233 128 0 0 $false
foreach ($x in @(-1.65,-0.90,-0.15,0.65,1.42)) { Add-CylinderX ('thin_panel_ring_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p'))) 'hf3_panel_line' ($x-0.010) ($x+0.010) 0.234 128 0 0 $false }

# Ramjet/duct assemblies and lower fairing.
Add-Box 'port_long_dark_ramjet_channel' 'hf3_dark_intake' -2.05 1.50 -0.306 -0.242 -0.122 0.045
Add-Box 'starboard_long_dark_ramjet_channel' 'hf3_dark_intake' -2.05 1.50 0.242 0.306 -0.122 0.045
Add-Box 'port_channel_lip_upper' 'hf3_body_light' -1.85 1.42 -0.326 -0.306 -0.090 0.055
Add-Box 'starboard_channel_lip_upper' 'hf3_body_light' -1.85 1.42 0.306 0.326 -0.090 0.055
Add-Box 'lower_center_body_fairing' 'hf3_body_light' -1.85 1.05 -0.058 0.058 -0.330 -0.242
Add-Box 'lower_dark_slot' 'hf3_dark_intake' -1.55 0.85 -0.034 0.034 -0.342 -0.322

# Side launch boosters.
Add-CylinderX 'port_side_booster_highpoly' 'hf3_booster_brown' -2.86 0.42 0.075 64 -0.190 -0.330 $true
Add-CylinderX 'starboard_side_booster_highpoly' 'hf3_booster_brown' -2.86 0.42 0.075 64 0.190 -0.330 $true
Add-CylinderX 'port_side_booster_black_nozzle' 'hf3_nozzle_black' -2.96 -2.84 0.064 64 -0.190 -0.330 $true
Add-CylinderX 'starboard_side_booster_black_nozzle' 'hf3_nozzle_black' -2.96 -2.84 0.064 64 0.190 -0.330 $true
Add-CylinderX 'port_side_booster_front_cap' 'hf3_body_light' 0.42 0.54 0.068 64 -0.190 -0.330 $true
Add-CylinderX 'starboard_side_booster_front_cap' 'hf3_body_light' 0.42 0.54 0.068 64 0.190 -0.330 $true

# Tail fins and mid/forward stabilizers.
Add-AirfoilFinZ 'tail_fin_top_red' 'hf3_fin_red' -3.02 -2.38 -2.90 -2.48 0.205 0.650 0.035 1
Add-AirfoilFinZ 'tail_fin_bottom_red' 'hf3_fin_red' -3.02 -2.38 -2.90 -2.48 0.205 0.650 0.035 -1
Add-AirfoilFinY 'tail_fin_port_red' 'hf3_fin_red' -3.02 -2.38 -2.90 -2.48 0.205 0.650 0.035 -1
Add-AirfoilFinY 'tail_fin_starboard_red' 'hf3_fin_red' -3.02 -2.38 -2.90 -2.48 0.205 0.650 0.035 1
Add-AirfoilFinZ 'mid_fin_top_gray' 'hf3_body_light' -0.42 0.36 -0.28 0.22 0.225 0.460 0.024 1
Add-AirfoilFinZ 'mid_fin_bottom_gray' 'hf3_body_light' -0.42 0.36 -0.28 0.22 0.225 0.460 0.024 -1
Add-AirfoilFinY 'mid_fin_port_gray' 'hf3_body_light' -0.42 0.36 -0.28 0.22 0.225 0.460 0.024 -1
Add-AirfoilFinY 'mid_fin_starboard_gray' 'hf3_body_light' -0.42 0.36 -0.28 0.22 0.225 0.460 0.024 1
Add-AirfoilFinZ 'forward_canard_top' 'hf3_body_light' 0.78 1.24 0.85 1.15 0.222 0.390 0.018 1
Add-AirfoilFinZ 'forward_canard_bottom' 'hf3_body_light' 0.78 1.24 0.85 1.15 0.222 0.390 0.018 -1
Add-AirfoilFinY 'forward_canard_port' 'hf3_body_light' 0.78 1.24 0.85 1.15 0.222 0.390 0.018 -1
Add-AirfoilFinY 'forward_canard_starboard' 'hf3_body_light' 0.78 1.24 0.85 1.15 0.222 0.390 0.018 1

# Raised marking plates and small inspection details.
Add-Box 'starboard_white_marking_plate' 'hf3_marking_white' 0.82 1.46 0.233 0.241 -0.095 0.062
Add-Box 'port_white_marking_plate' 'hf3_marking_white' 0.82 1.46 -0.241 -0.233 -0.095 0.062
Add-Box 'starboard_blue_roundel_plate' 'hf3_roundel_blue' -0.62 -0.40 0.235 0.243 -0.090 0.090
Add-Box 'port_blue_roundel_plate' 'hf3_roundel_blue' -0.62 -0.40 -0.243 -0.235 -0.090 0.090
foreach ($x in @(-1.35,-0.85,-0.35,0.15,0.65,1.15)) { Add-Box ('starboard_panel_hatch_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p'))) 'hf3_panel_light' $x ($x+0.18) 0.232 0.239 0.045 0.092 }
foreach ($x in @(-1.20,-0.70,-0.20,0.30,0.80)) { Add-Box ('port_panel_hatch_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p'))) 'hf3_panel_light' $x ($x+0.16) -0.239 -0.232 0.045 0.088 }

$mtl = @(
'# Materials for high-poly ROCN Hsiung Feng III approximate OBJ.',
'newmtl hf3_body_gray','Kd 0.48 0.53 0.55','Ka 0.12 0.13 0.14','Ks 0.18 0.18 0.18','Ns 52','',
'newmtl hf3_body_light','Kd 0.70 0.74 0.76','Ka 0.16 0.17 0.18','Ks 0.20 0.20 0.20','Ns 58','',
'newmtl hf3_panel_dark','Kd 0.34 0.38 0.40','Ka 0.08 0.09 0.09','Ks 0.12 0.12 0.12','Ns 34','',
'newmtl hf3_panel_line','Kd 0.26 0.29 0.30','Ka 0.06 0.06 0.07','Ks 0.08 0.08 0.08','Ns 24','',
'newmtl hf3_panel_light','Kd 0.60 0.65 0.67','Ka 0.13 0.14 0.15','Ks 0.15 0.15 0.15','Ns 36','',
'newmtl hf3_nose_white','Kd 0.92 0.90 0.84','Ka 0.22 0.21 0.20','Ks 0.22 0.22 0.22','Ns 64','',
'newmtl hf3_dark_intake','Kd 0.045 0.050 0.055','Ka 0.01 0.01 0.012','Ks 0.05 0.05 0.05','Ns 20','',
'newmtl hf3_booster_brown','Kd 0.46 0.25 0.12','Ka 0.10 0.06 0.03','Ks 0.10 0.07 0.04','Ns 22','',
'newmtl hf3_fin_red','Kd 0.78 0.08 0.04','Ka 0.18 0.02 0.01','Ks 0.10 0.03 0.02','Ns 26','',
'newmtl hf3_nozzle_black','Kd 0.01 0.01 0.012','Ka 0.0 0.0 0.0','Ks 0.04 0.04 0.04','Ns 14','',
'newmtl hf3_nozzle_inner','Kd 0.0 0.0 0.0','Ka 0.0 0.0 0.0','Ks 0.01 0.01 0.01','Ns 8','',
'newmtl hf3_marking_white','Kd 0.94 0.94 0.90','Ka 0.20 0.20 0.18','Ks 0.14 0.14 0.14','Ns 28','',
'newmtl hf3_roundel_blue','Kd 0.02 0.16 0.55','Ka 0.0 0.03 0.12','Ks 0.08 0.08 0.12','Ns 28'
)
$obj = New-Object System.Collections.Generic.List[string]
$obj.Add('# ROCN Hsiung Feng III high-poly anti-ship missile approximate OBJ')
$obj.Add('# Generated from public dimensions and user-provided visual references.')
$obj.Add('# Units: meters. Nose points along +X. Length approx 6.1 m, body diameter approx 0.46 m.')
$obj.Add('mtllib rocn_hf-3.mtl')
$obj.AddRange($vertices)
$obj.AddRange($faces)
$readme = @(
'# ROCN Hsiung Feng III High-Poly OBJ Prototype','',
'Files:','',
'- rocn_hf-3.obj','- rocn_hf-3.mtl','- generate_rocn_hf3_highpoly.ps1','',
'This is a procedural, high-poly approximate Hsiung Feng III anti-ship missile model for mod prototyping. It is not a CAD-accurate reconstruction.','',
'Scale and orientation:','',
'- Units: meters','- Nose direction: +X','- Approximate length: 6.1 m','- Approximate missile body diameter: 0.46 m','',
'Modeled visual features:','',
'- Smooth high-segment cylindrical missile body','- Smooth ogive-style white nose cone','- Body panel bands and thin panel rings','- Dark side ramjet/intake channel strips with raised lips','- Lower body fairing and dark slot','- Brown aft booster and two side booster tubes','- Recessed black nozzle details','- Red tail fins with finite thickness','- Mid-body stabilizers and forward canards','- Raised side marking plates and simple hatch details','',
'Reference basis:','',
'- Public specification data for HF-3 length/diameter/mass/speed from Wikipedia/Wikimedia-derived public pages.','- User-provided launch and static-display photos for broad visual layout and color blocking.','',
'Next integration step:','',
'Sea Power usually needs the OBJ plus material paths referenced from an ammunition ini. This file is currently stored as a source model under models; it is not yet wired into mod/ammunition.'
)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines($objPath, $obj, $utf8NoBom)
[IO.File]::WriteAllLines($mtlPath, $mtl, $utf8NoBom)
[IO.File]::WriteAllLines($readmePath, $readme, $utf8NoBom)
$xs=@(); $ys=@(); $zs=@(); $v=0; $f=0
foreach($line in $obj){
  if($line -like 'v *'){ $p=$line.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries); $xs += [double]$p[1]; $ys += [double]$p[2]; $zs += [double]$p[3]; $v++ }
  elseif($line -like 'f *'){ $f++ }
}
$minX=($xs|Measure-Object -Minimum).Minimum; $maxX=($xs|Measure-Object -Maximum).Maximum
'Generated vertices={0} faces={1} length={2:F3}m x={3:F3}..{4:F3} y={5:F3}..{6:F3} z={7:F3}..{8:F3}' -f $v,$f,($maxX-$minX),$minX,$maxX,($ys|Measure-Object -Minimum).Minimum,($ys|Measure-Object -Maximum).Maximum,($zs|Measure-Object -Minimum).Minimum,($zs|Measure-Object -Maximum).Maximum