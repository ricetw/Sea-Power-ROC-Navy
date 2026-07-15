$ErrorActionPreference = 'Stop'
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$objPath = Join-Path $outDir 'rocn_hf-3.obj'
$mtlPath = Join-Path $outDir 'rocn_hf-3.mtl'
$readmePath = Join-Path $outDir 'README.md'

$vertices = [System.Collections.Generic.List[string]]::new()
$faces = [System.Collections.Generic.List[string]]::new()
$currentMaterial = ''
$currentGroup = ''
$faceCount = 0
$minX = [double]::PositiveInfinity
$maxX = [double]::NegativeInfinity
$minY = [double]::PositiveInfinity
$maxY = [double]::NegativeInfinity
$minZ = [double]::PositiveInfinity
$maxZ = [double]::NegativeInfinity

function Add-Vertex([double]$x, [double]$y, [double]$z) {
    $script:vertices.Add(('v {0:F6} {1:F6} {2:F6}' -f $x, $y, $z))
    if ($x -lt $script:minX) { $script:minX = $x }
    if ($x -gt $script:maxX) { $script:maxX = $x }
    if ($y -lt $script:minY) { $script:minY = $y }
    if ($y -gt $script:maxY) { $script:maxY = $y }
    if ($z -lt $script:minZ) { $script:minZ = $z }
    if ($z -gt $script:maxZ) { $script:maxZ = $z }
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

function Add-Face([int[]]$idx) {
    if ($idx.Count -lt 3) { return }
    $script:faces.Add(('f ' + ($idx -join ' ')))
    $script:faceCount++
}
function Convert-PolarYZ([double]$radial, [double]$tangent, [double]$theta) {
    $ct = [Math]::Cos($theta)
    $st = [Math]::Sin($theta)
    $y = $ct * $radial - $st * $tangent
    $z = $st * $radial + $ct * $tangent
    return @($y, $z)
}

function New-BodyProfile([double]$x0, [double]$x1, [double]$radius, [int]$rings) {
    $profile = @()
    for ($i = 0; $i -lt $rings; $i++) {
        $t = [double]$i / [double]($rings - 1)
        $x = $x0 + ($x1 - $x0) * $t
        $r = $radius
        if ($t -lt 0.08) {
            $r = 0.208 + ($radius - 0.208) * ($t / 0.08)
        }
        elseif ($t -gt 0.94) {
            $r = $radius - 0.010 * (($t - 0.94) / 0.06)
        }
        else {
            $r = $radius + 0.003 * [Math]::Sin([Math]::PI * $t)
        }
        $profile += @{ x = $x; r = $r }
    }
    return $profile
}

function New-ConstantProfile([double]$x0, [double]$x1, [double]$radius, [int]$rings) {
    $profile = @()
    for ($i = 0; $i -lt $rings; $i++) {
        $t = [double]$i / [double]($rings - 1)
        $profile += @{ x = $x0 + ($x1 - $x0) * $t; r = $radius }
    }
    return $profile
}

function Add-LatheXOffset([string]$group, [string]$mat, [object[]]$profile, [int]$seg, [double]$cy = 0, [double]$cz = 0, [bool]$capStart = $true, [bool]$capEnd = $true) {
    Set-Part $group $mat $true
    $rings = @()
    for ($k = 0; $k -lt $profile.Count; $k++) {
        $x = [double]$profile[$k]['x']
        $r = [double]$profile[$k]['r']
        $ring = @()
        for ($i = 0; $i -lt $seg; $i++) {
            $ang = 2.0 * [Math]::PI * $i / $seg
            $ring += Add-Vertex $x ($cy + $r * [Math]::Cos($ang)) ($cz + $r * [Math]::Sin($ang))
        }
        $rings += ,$ring
    }
    for ($k = 0; $k -lt ($rings.Count - 1); $k++) {
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($rings[$k][$i], $rings[$k][$j], $rings[$k + 1][$j], $rings[$k + 1][$i])
        }
    }
    if ($capStart) {
        $c = Add-Vertex ([double]$profile[0]['x']) $cy $cz
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($c, $rings[0][$j], $rings[0][$i])
        }
    }
    if ($capEnd) {
        $last = $rings.Count - 1
        $c = Add-Vertex ([double]$profile[$profile.Count - 1]['x']) $cy $cz
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($c, $rings[$last][$i], $rings[$last][$j])
        }
    }
}

function Add-OgiveNoseX([string]$group, [string]$mat, [double]$xBase, [double]$xTip, [double]$radius, [int]$rings, [int]$seg) {
    Set-Part $group $mat $true
    $all = @()
    for ($k = 0; $k -lt $rings; $k++) {
        $t = [double]$k / [double]$rings
        $x = $xBase + ($xTip - $xBase) * $t
        $r = $radius * [Math]::Pow((1.0 - $t), 0.56)
        $ring = @()
        for ($i = 0; $i -lt $seg; $i++) {
            $ang = 2.0 * [Math]::PI * $i / $seg
            $ring += Add-Vertex $x ($r * [Math]::Cos($ang)) ($r * [Math]::Sin($ang))
        }
        $all += ,$ring
    }
    for ($k = 0; $k -lt ($all.Count - 1); $k++) {
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($all[$k][$i], $all[$k][$j], $all[$k + 1][$j], $all[$k + 1][$i])
        }
    }
    $tip = Add-Vertex $xTip 0 0
    $last = $all.Count - 1
    for ($i = 0; $i -lt $seg; $i++) {
        $j = ($i + 1) % $seg
        Add-Face @($all[$last][$i], $all[$last][$j], $tip)
    }
}

function Add-EllipseLoftPolarX([string]$group, [string]$mat, [object[]]$profile, [double]$theta, [int]$seg, [bool]$capStart = $false, [bool]$capEnd = $false) {
    Set-Part $group $mat $true
    $rings = @()
    for ($k = 0; $k -lt $profile.Count; $k++) {
        $x = [double]$profile[$k]['x']
        $off = [double]$profile[$k]['off']
        $rr = [double]$profile[$k]['rr']
        $tr = [double]$profile[$k]['tr']
        $ring = @()
        for ($i = 0; $i -lt $seg; $i++) {
            $ang = 2.0 * [Math]::PI * $i / $seg
            $localRadial = $off + $rr * [Math]::Cos($ang)
            $localTangent = $tr * [Math]::Sin($ang)
            $yz = Convert-PolarYZ $localRadial $localTangent $theta
            $ring += Add-Vertex $x $yz[0] $yz[1]
        }
        $rings += ,$ring
    }
    for ($k = 0; $k -lt ($rings.Count - 1); $k++) {
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($rings[$k][$i], $rings[$k][$j], $rings[$k + 1][$j], $rings[$k + 1][$i])
        }
    }
    if ($capStart) {
        $p = $profile[0]
        $yz = Convert-PolarYZ ([double]$p['off']) 0 $theta
        $c = Add-Vertex ([double]$p['x']) $yz[0] $yz[1]
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($c, $rings[0][$j], $rings[0][$i])
        }
    }
    if ($capEnd) {
        $last = $rings.Count - 1
        $p = $profile[$profile.Count - 1]
        $yz = Convert-PolarYZ ([double]$p['off']) 0 $theta
        $c = Add-Vertex ([double]$p['x']) $yz[0] $yz[1]
        for ($i = 0; $i -lt $seg; $i++) {
            $j = ($i + 1) % $seg
            Add-Face @($c, $rings[$last][$i], $rings[$last][$j])
        }
    }
}

function Add-EllipseCapPolarX([string]$group, [string]$mat, [double]$x, [double]$off, [double]$rr, [double]$tr, [double]$theta, [int]$seg, [bool]$flip = $false) {
    Set-Part $group $mat $true
    $yz = Convert-PolarYZ $off 0 $theta
    $c = Add-Vertex $x $yz[0] $yz[1]
    $ring = @()
    for ($i = 0; $i -lt $seg; $i++) {
        $ang = 2.0 * [Math]::PI * $i / $seg
        $localRadial = $off + $rr * [Math]::Cos($ang)
        $localTangent = $tr * [Math]::Sin($ang)
        $pt = Convert-PolarYZ $localRadial $localTangent $theta
        $ring += Add-Vertex $x $pt[0] $pt[1]
    }
    for ($i = 0; $i -lt $seg; $i++) {
        $j = ($i + 1) % $seg
        if ($flip) { Add-Face @($c, $ring[$i], $ring[$j]) } else { Add-Face @($c, $ring[$j], $ring[$i]) }
    }
}

function Add-LocalBoxPolar([string]$group, [string]$mat, [double]$x0, [double]$x1, [double]$r0, [double]$r1, [double]$t0, [double]$t1, [double]$theta, [bool]$smooth = $false) {
    Set-Part $group $mat $smooth
    $corners = @(
        @($x0,$r0,$t0), @($x1,$r0,$t0), @($x1,$r1,$t0), @($x0,$r1,$t0),
        @($x0,$r0,$t1), @($x1,$r0,$t1), @($x1,$r1,$t1), @($x0,$r1,$t1)
    )
    $v = @()
    foreach ($c in $corners) {
        $yz = Convert-PolarYZ ([double]$c[1]) ([double]$c[2]) $theta
        $v += Add-Vertex ([double]$c[0]) $yz[0] $yz[1]
    }
    Add-Face @($v[0], $v[1], $v[2], $v[3])
    Add-Face @($v[4], $v[7], $v[6], $v[5])
    Add-Face @($v[0], $v[4], $v[5], $v[1])
    Add-Face @($v[1], $v[5], $v[6], $v[2])
    Add-Face @($v[2], $v[6], $v[7], $v[3])
    Add-Face @($v[3], $v[7], $v[4], $v[0])
}

function Add-RectPlatePolar([string]$group, [string]$mat, [double]$x0, [double]$x1, [double]$radial, [double]$t0, [double]$t1, [double]$theta) {
    Set-Part $group $mat $false
    $a = Convert-PolarYZ $radial $t0 $theta
    $b = Convert-PolarYZ $radial $t0 $theta
    $c = Convert-PolarYZ $radial $t1 $theta
    $d = Convert-PolarYZ $radial $t1 $theta
    $v0 = Add-Vertex $x0 $a[0] $a[1]
    $v1 = Add-Vertex $x1 $b[0] $b[1]
    $v2 = Add-Vertex $x1 $c[0] $c[1]
    $v3 = Add-Vertex $x0 $d[0] $d[1]
    Add-Face @($v0, $v1, $v2, $v3)
}

function Add-DiscPlatePolar([string]$group, [string]$mat, [double]$cx, [double]$tc, [double]$rx, [double]$rt, [double]$radial, [double]$theta, [int]$seg) {
    Set-Part $group $mat $true
    $yz = Convert-PolarYZ $radial $tc $theta
    $center = Add-Vertex $cx $yz[0] $yz[1]
    $ring = @()
    for ($i = 0; $i -lt $seg; $i++) {
        $ang = 2.0 * [Math]::PI * $i / $seg
        $x = $cx + $rx * [Math]::Cos($ang)
        $t = $tc + $rt * [Math]::Sin($ang)
        $pt = Convert-PolarYZ $radial $t $theta
        $ring += Add-Vertex $x $pt[0] $pt[1]
    }
    for ($i = 0; $i -lt $seg; $i++) {
        $j = ($i + 1) % $seg
        Add-Face @($center, $ring[$i], $ring[$j])
    }
}

function Add-FinPolar([string]$group, [string]$mat, [double]$xRoot0, [double]$xRoot1, [double]$xTip0, [double]$xTip1, [double]$rRoot, [double]$rTip, [double]$halfThickness, [double]$theta) {
    Set-Part $group $mat $false
    $local = @(
        @($xRoot0,$rRoot,-$halfThickness), @($xRoot1,$rRoot,-$halfThickness), @($xTip1,$rTip,-$halfThickness*0.25), @($xTip0,$rTip,-$halfThickness*0.25),
        @($xRoot0,$rRoot,$halfThickness), @($xRoot1,$rRoot,$halfThickness), @($xTip1,$rTip,$halfThickness*0.25), @($xTip0,$rTip,$halfThickness*0.25)
    )
    $v = @()
    foreach ($p in $local) {
        $yz = Convert-PolarYZ ([double]$p[1]) ([double]$p[2]) $theta
        $v += Add-Vertex ([double]$p[0]) $yz[0] $yz[1]
    }
    Add-Face @($v[0], $v[1], $v[2], $v[3])
    Add-Face @($v[4], $v[7], $v[6], $v[5])
    Add-Face @($v[0], $v[4], $v[5], $v[1])
    Add-Face @($v[1], $v[5], $v[6], $v[2])
    Add-Face @($v[2], $v[6], $v[7], $v[3])
    Add-Face @($v[3], $v[7], $v[4], $v[0])
}

function Add-BlockTextPolar([string]$prefix, [string]$text, [double]$theta, [double]$radial, [double]$xStart, [double]$tTop, [double]$cellX, [double]$cellT, [string]$mat) {
    $font = @{
        'H' = @('101','101','111','101','101')
        'S' = @('111','100','111','001','111')
        'I' = @('111','010','010','010','111')
        'U' = @('101','101','101','101','111')
        'N' = @('101','111','111','111','101')
        'G' = @('111','100','101','101','111')
        'F' = @('111','100','110','100','100')
        'E' = @('111','100','110','100','111')
        '0' = @('111','101','101','101','111')
        '1' = @('010','110','010','010','111')
        '2' = @('111','001','111','100','111')
        '3' = @('111','001','111','001','111')
        ' ' = @('000','000','000','000','000')
    }
    $x = $xStart
    $chars = $text.ToCharArray()
    for ($ci = 0; $ci -lt $chars.Count; $ci++) {
        $ch = [string]$chars[$ci]
        if (-not $font.ContainsKey($ch)) { $x += 4.0 * $cellX; continue }
        $rows = $font[$ch]
        for ($row = 0; $row -lt 5; $row++) {
            for ($col = 0; $col -lt 3; $col++) {
                if ($rows[$row][$col] -eq '1') {
                    $x0 = $x + $col * $cellX
                    $x1 = $x0 + $cellX * 0.72
                    $t0 = $tTop - ($row + 1) * $cellT
                    $t1 = $tTop - $row * $cellT - $cellT * 0.18
                    Add-RectPlatePolar ("${prefix}_${ci}_${row}_${col}") $mat $x0 $x1 $radial $t0 $t1 $theta
                }
            }
        }
        $x += 4.0 * $cellX
    }
}

$anglePi = [double][Math]::PI
$bodySeg = 384
$ramjetSeg = 192
$boosterSeg = 224

# 1:1 public dimensions: 6.1 m length, 0.46 m main body diameter.
$bodyRadius = 0.230
$bodyProfile = New-BodyProfile -x0 -2.75 -x1 2.16 -radius $bodyRadius -rings 136
Add-LatheXOffset 'main_61m_body_highpoly_046m_diameter' 'hf3_body_dark_gray' $bodyProfile $bodySeg 0 0 $true $false
Add-OgiveNoseX 'white_ogive_radar_seeker_nose' 'hf3_nose_white' 2.16 3.05 $bodyRadius 96 $bodySeg

# Main aft solid rocket body and nozzles.
$mainNozzleProfile = @(
    @{x=-3.05; r=0.166}, @{x=-3.00; r=0.190}, @{x=-2.92; r=0.205}, @{x=-2.75; r=0.210}
)
Add-LatheXOffset 'main_solid_rocket_aft_skirt' 'hf3_booster_brown' $mainNozzleProfile $bodySeg 0 0 $true $true
Add-LatheXOffset 'recessed_main_nozzle_black' 'hf3_nozzle_black' @(@{x=-3.050;r=0.142},@{x=-2.975;r=0.142}) 160 0 0 $true $true
Add-LatheXOffset 'deep_inner_main_nozzle_shadow' 'hf3_nozzle_inner' @(@{x=-3.050;r=0.075},@{x=-3.010;r=0.075}) 128 0 0 $true $true

# Raised body bands and panel rings.
Add-LatheXOffset 'nose_gray_interface_band' 'hf3_panel_dark' @(@{x=2.115;r=0.235},@{x=2.190;r=0.235}) $bodySeg 0 0 $false $false
Add-LatheXOffset 'aft_body_interface_band' 'hf3_panel_dark' @(@{x=-2.780;r=0.235},@{x=-2.660;r=0.235}) $bodySeg 0 0 $false $false
foreach ($x in @(-2.30,-1.95,-1.55,-1.15,-0.75,-0.35,0.05,0.45,0.85,1.25,1.70)) {
    $name = ('thin_circumferential_panel_ring_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p')))
    Add-LatheXOffset $name 'hf3_panel_line' @(@{x=$x-0.006;r=0.234},@{x=$x+0.006;r=0.234}) $bodySeg 0 0 $false $false
}

# Four external ramjet/air intake structures around the main missile body.
$ramjetProfile = @(
    @{x=-2.58; off=0.310; rr=0.047; tr=0.052},
    @{x=-2.42; off=0.333; rr=0.070; tr=0.070},
    @{x=-1.85; off=0.350; rr=0.086; tr=0.076},
    @{x=-1.15; off=0.356; rr=0.092; tr=0.079},
    @{x=-0.45; off=0.358; rr=0.094; tr=0.080},
    @{x=0.25;  off=0.356; rr=0.092; tr=0.079},
    @{x=0.95;  off=0.348; rr=0.086; tr=0.076},
    @{x=1.32;  off=0.338; rr=0.080; tr=0.072},
    @{x=1.50;  off=0.325; rr=0.072; tr=0.064}
)
$ramjets = @(
    @{name='upper_starboard_ramjet_structure'; theta=($anglePi / 4.0)},
    @{name='upper_port_ramjet_structure'; theta=(3.0 * $anglePi / 4.0)},
    @{name='lower_port_ramjet_structure'; theta=(5.0 * $anglePi / 4.0)},
    @{name='lower_starboard_ramjet_structure'; theta=(7.0 * $anglePi / 4.0)}
)
foreach ($rj in $ramjets) {
    $theta = [double]$rj['theta']
    $name = [string]$rj['name']
    Add-LocalBoxPolar "${name}_root_fillet" 'hf3_ramjet_fillet' -2.48 1.33 0.224 0.318 -0.045 0.045 $theta $false
    Add-EllipseLoftPolarX $name 'hf3_ramjet_outer_gray' $ramjetProfile $theta $ramjetSeg $false $false
    Add-EllipseCapPolarX "${name}_front_black_intake_opening" 'hf3_intake_black' 1.505 0.325 0.056 0.050 $theta $ramjetSeg $false
    Add-EllipseCapPolarX "${name}_aft_dark_ramjet_exit" 'hf3_nozzle_black' -2.585 0.310 0.036 0.042 $theta $ramjetSeg $true
    Add-LocalBoxPolar "${name}_sharp_outer_lip" 'hf3_body_light_gray' 1.22 1.52 0.395 0.420 -0.060 0.060 $theta $false
}

# Two large side booster rockets, visible as the left/right tan cylinders in public display photos.
$sideBoosterProfile = @(
    @{x=-3.02; r=0.055}, @{x=-2.94; r=0.095}, @{x=-2.65; r=0.102}, @{x=-2.10; r=0.104},
    @{x=-1.55; r=0.104}, @{x=-0.95; r=0.102}, @{x=-0.35; r=0.100}, @{x=0.20; r=0.096},
    @{x=0.48; r=0.082}, @{x=0.64; r=0.040}, @{x=0.73; r=0.000}
)
$boosterMounts = @(
    @{name='starboard_lower_side_booster_rocket'; theta=(11.0 * $anglePi / 6.0)},
    @{name='port_lower_side_booster_rocket'; theta=(7.0 * $anglePi / 6.0)}
)
foreach ($b in $boosterMounts) {
    $theta = [double]$b['theta']
    $name = [string]$b['name']
    $axis = Convert-PolarYZ 0.455 0 $theta
    Add-LatheXOffset $name 'hf3_side_booster_gold' $sideBoosterProfile $boosterSeg $axis[0] $axis[1] $true $true
    $nozAxis = Convert-PolarYZ 0.455 0 $theta
    Add-LatheXOffset "${name}_black_rear_nozzle" 'hf3_nozzle_black' @(@{x=-3.050;r=0.076},@{x=-2.975;r=0.076}) 96 $nozAxis[0] $nozAxis[1] $true $true
    Add-LocalBoxPolar "${name}_forward_pylon" 'hf3_booster_mount' 0.22 0.52 0.252 0.372 -0.028 0.028 $theta $false
    Add-LocalBoxPolar "${name}_aft_pylon" 'hf3_booster_mount' -2.45 -2.16 0.252 0.372 -0.030 0.030 $theta $false
    Add-FinPolar "${name}_small_aft_fin_upper" 'hf3_body_light_gray' -2.95 -2.62 -2.90 -2.70 0.555 0.700 0.020 ($theta + ($anglePi / 9.0))
    Add-FinPolar "${name}_small_aft_fin_lower" 'hf3_body_light_gray' -2.95 -2.62 -2.90 -2.70 0.555 0.700 0.020 ($theta - ($anglePi / 9.0))
}

# Control wings and stabilizing fins.
foreach ($theta in @([double]0.0, ($anglePi / 2.0), $anglePi, (3.0 * $anglePi / 2.0))) {
    $label = ('{0:D3}' -f [int]([Math]::Round($theta * 180.0 / $anglePi)))
    Add-FinPolar "red_tail_control_fin_${label}" 'hf3_fin_red' -2.98 -2.32 -2.86 -2.50 0.226 0.640 0.033 $theta
    Add-FinPolar "mid_body_stabilizer_${label}" 'hf3_body_light_gray' -0.60 0.25 -0.43 0.05 0.238 0.520 0.026 $theta
    Add-FinPolar "forward_control_canard_${label}" 'hf3_body_light_gray' 0.82 1.32 0.92 1.18 0.235 0.405 0.018 $theta
}

# Seeker windows, inspection hatches, roundels, and raised block lettering.
foreach ($theta in @([double]0.0, $anglePi)) {
    $side = $(if ($theta -eq 0.0) { 'starboard' } else { 'port' })
    Add-RectPlatePolar "${side}_dark_seeker_window_upper" 'hf3_sensor_black' 2.38 2.54 0.236 0.055 0.105 $theta
    Add-RectPlatePolar "${side}_dark_seeker_window_lower" 'hf3_sensor_black' 2.23 2.38 0.236 -0.120 -0.078 $theta
    Add-DiscPlatePolar "${side}_blue_rocn_roundel_disc" 'hf3_roundel_blue' -0.58 -0.080 0.065 0.065 0.239 $theta 64
    Add-DiscPlatePolar "${side}_white_roundel_core" 'hf3_text_white' -0.58 -0.080 0.030 0.030 0.240 $theta 48
    Add-RectPlatePolar "${side}_white_s001_plate" 'hf3_text_white' 1.15 1.62 0.239 -0.012 0.055 $theta
    Add-BlockTextPolar "${side}_hsiung_feng_iii_text" 'HSIUNG FENG III' $theta 0.241 0.22 -0.020 0.024 0.012 'hf3_text_white'
    Add-BlockTextPolar "${side}_s001_text" 'S001' $theta 0.242 1.20 0.045 0.030 0.014 'hf3_body_dark_gray'
}

foreach ($x in @(-1.95,-1.52,-1.08,-0.64,-0.20,0.24,0.68,1.10)) {
    Add-RectPlatePolar ('starboard_flush_panel_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p'))) 'hf3_panel_light' $x ($x+0.22) 0.236 0.065 0.112 0.0
    Add-RectPlatePolar ('port_flush_panel_{0}' -f ($x.ToString('F2').Replace('-','m').Replace('.','p'))) 'hf3_panel_light' $x ($x+0.22) 0.236 0.065 0.112 $anglePi
}

$mtl = @(
'# Materials for high-poly ROCN Hsiung Feng III OBJ.',
'newmtl hf3_body_dark_gray','Kd 0.205 0.235 0.245','Ka 0.045 0.052 0.055','Ks 0.170 0.180 0.180','Ns 72','',
'newmtl hf3_body_light_gray','Kd 0.665 0.705 0.715','Ka 0.150 0.160 0.165','Ks 0.220 0.220 0.220','Ns 68','',
'newmtl hf3_nose_white','Kd 0.925 0.900 0.835','Ka 0.220 0.210 0.190','Ks 0.240 0.230 0.210','Ns 76','',
'newmtl hf3_panel_dark','Kd 0.330 0.360 0.370','Ka 0.075 0.082 0.085','Ks 0.120 0.125 0.125','Ns 38','',
'newmtl hf3_panel_line','Kd 0.120 0.135 0.140','Ka 0.030 0.034 0.036','Ks 0.060 0.060 0.060','Ns 28','',
'newmtl hf3_panel_light','Kd 0.560 0.605 0.615','Ka 0.125 0.135 0.138','Ks 0.130 0.135 0.135','Ns 34','',
'newmtl hf3_ramjet_outer_gray','Kd 0.305 0.335 0.345','Ka 0.070 0.076 0.078','Ks 0.155 0.160 0.160','Ns 58','',
'newmtl hf3_ramjet_fillet','Kd 0.235 0.260 0.270','Ka 0.054 0.060 0.063','Ks 0.110 0.115 0.115','Ns 40','',
'newmtl hf3_intake_black','Kd 0.010 0.012 0.014','Ka 0.002 0.002 0.003','Ks 0.030 0.030 0.030','Ns 18','',
'newmtl hf3_sensor_black','Kd 0.020 0.025 0.030','Ka 0.004 0.005 0.006','Ks 0.180 0.190 0.200','Ns 90','',
'newmtl hf3_booster_brown','Kd 0.420 0.235 0.115','Ka 0.094 0.052 0.025','Ks 0.110 0.075 0.045','Ns 26','',
'newmtl hf3_side_booster_gold','Kd 0.610 0.480 0.265','Ka 0.135 0.105 0.056','Ks 0.205 0.165 0.092','Ns 52','',
'newmtl hf3_booster_mount','Kd 0.675 0.685 0.630','Ka 0.150 0.150 0.135','Ks 0.110 0.110 0.100','Ns 30','',
'newmtl hf3_fin_red','Kd 0.790 0.060 0.035','Ka 0.180 0.014 0.008','Ks 0.115 0.030 0.020','Ns 30','',
'newmtl hf3_nozzle_black','Kd 0.004 0.004 0.005','Ka 0.000 0.000 0.000','Ks 0.035 0.035 0.035','Ns 16','',
'newmtl hf3_nozzle_inner','Kd 0.000 0.000 0.000','Ka 0.000 0.000 0.000','Ks 0.010 0.010 0.010','Ns 8','',
'newmtl hf3_text_white','Kd 0.940 0.935 0.890','Ka 0.205 0.200 0.185','Ks 0.130 0.130 0.120','Ns 32','',
'newmtl hf3_roundel_blue','Kd 0.020 0.135 0.520','Ka 0.004 0.025 0.120','Ks 0.080 0.085 0.120','Ns 30'
)

$obj = [System.Collections.Generic.List[string]]::new()
$obj.Add('# ROCN Hsiung Feng III high-poly visual OBJ')
$obj.Add('# Procedural exterior model for Sea Power mod prototyping.')
$obj.Add('# Units: meters. Nose points along +X. Public scale basis: length 6.1 m, main body diameter 0.46 m.')
$obj.Add('# Exterior includes four ramjet/intake structures around the main body and two lower side booster rockets.')
$obj.Add('mtllib rocn_hf-3.mtl')
$obj.AddRange($vertices)
$obj.AddRange($faces)

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllLines($objPath, $obj, $utf8NoBom)
[IO.File]::WriteAllLines($mtlPath, $mtl, $utf8NoBom)

$vCount = $vertices.Count
$fCount = $faceCount

$readme = @(
'# ROCN Hsiung Feng III High-Poly OBJ Model','',
'Files:','',
'- rocn_hf-3.obj','- rocn_hf-3.mtl','- generate_rocn_hf3_highpoly.ps1','',
'Scale and orientation:','',
'- Units: meters','- Nose direction: +X','- Overall length: 6.1 m','- Main body diameter: 0.46 m',('- OBJ vertices: ' + $vCount),('- OBJ faces: ' + $fCount),('- X bounds: ' + ('{0:F3} .. {1:F3}' -f $minX,$maxX)),('- Y bounds: ' + ('{0:F3} .. {1:F3}' -f $minY,$maxY)),('- Z bounds: ' + ('{0:F3} .. {1:F3}' -f $minZ,$maxZ)),'',
'Modeled exterior features:','',
'- 1:1 visual scale based on public 6.1 m length and 0.46 m main body diameter.','- White radar seeker nose and dark gray main body.','- Four separate external ramjet/intake structures around the main body.','- Two lower side booster rockets with gold-brown casings, pointed front caps, black aft nozzles, and mounting pylons.','- Red aft control fins, mid-body stabilizers, and forward canards with finite thickness.','- Panel rings, hatches, seeker windows, ROCN roundel discs, and simplified raised block lettering.','',
'Note:','',
'This is a high-poly game-art exterior reconstruction from public dimensions and photos. It is not CAD-accurate or suitable for manufacturing. To use it in Sea Power, move the OBJ/MTL into a mod asset path and reference the model from an ammunition ini.'
)
[IO.File]::WriteAllLines($readmePath, $readme, $utf8NoBom)

'Generated vertices={0} faces={1} length={2:F3}m x={3:F3}..{4:F3} y={5:F3}..{6:F3} z={7:F3}..{8:F3}' -f $vCount, $fCount, ($maxX - $minX), $minX, $maxX, $minY, $maxY, $minZ, $maxZ
'Output: {0}' -f $objPath