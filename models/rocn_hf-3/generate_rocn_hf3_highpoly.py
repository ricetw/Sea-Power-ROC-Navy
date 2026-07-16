#!/usr/bin/env python3
"""Generate a high-poly visual OBJ for the ROCN Hsiung Feng III missile.

This is a game-art exterior reconstruction from public dimensions and photos,
not engineering CAD.  Coordinate system: +X nose, Y starboard, Z up.
"""
from __future__ import annotations

import math
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parent
OBJ_PATH = OUT_DIR / "rocn_hf-3.obj"
GAME_OBJ_PATH = OUT_DIR / "rocn_hf-3_game.obj"
MTL_PATH = OUT_DIR / "rocn_hf-3.mtl"
README_PATH = OUT_DIR / "README.md"

PI = math.pi


class Mesh:
    def __init__(self) -> None:
        self.vertices: list[tuple[float, float, float]] = []
        self.texcoords: list[tuple[float, float]] = []
        self.faces: list[dict] = []
        self.bounds = [float("inf"), float("-inf"), float("inf"), float("-inf"), float("inf"), float("-inf")]

    def v(self, x: float, y: float, z: float) -> int:
        self.vertices.append((x, y, z))
        self.bounds[0] = min(self.bounds[0], x)
        self.bounds[1] = max(self.bounds[1], x)
        self.bounds[2] = min(self.bounds[2], y)
        self.bounds[3] = max(self.bounds[3], y)
        self.bounds[4] = min(self.bounds[4], z)
        self.bounds[5] = max(self.bounds[5], z)
        return len(self.vertices)

    def vt(self, u: float, v: float) -> int:
        self.texcoords.append((u, v))
        return len(self.texcoords)

    def f(self, verts: list[int], mat: str, group: str, smooth: bool = True, tex: list[int] | None = None) -> None:
        self.faces.append({"v": verts, "vt": tex, "mat": mat, "group": group, "smooth": smooth})

    def write_obj(self, path: Path) -> None:
        with path.open("w", encoding="utf-8", newline="\n") as fp:
            fp.write("# ROCN Hsiung Feng III high-poly visual OBJ\n")
            fp.write("# Game-art reconstruction from public dimensions/photos; not CAD.\n")
            fp.write("# Units: meters. Nose direction: +X. Overall length: 6.1 m. Main body diameter: 0.46 m.\n")
            fp.write("mtllib rocn_hf-3.mtl\n")
            for x, y, z in self.vertices:
                fp.write(f"v {x:.6f} {y:.6f} {z:.6f}\n")
            for u, v in self.texcoords:
                fp.write(f"vt {u:.6f} {v:.6f}\n")
            current_group = None
            current_mat = None
            current_smooth = None
            for face in self.faces:
                if face["group"] != current_group:
                    fp.write(f"\ng {face['group']}\n")
                    current_group = face["group"]
                    current_smooth = None
                if face["smooth"] != current_smooth:
                    fp.write("s 1\n" if face["smooth"] else "s off\n")
                    current_smooth = face["smooth"]
                if face["mat"] != current_mat:
                    fp.write(f"usemtl {face['mat']}\n")
                    current_mat = face["mat"]
                if face["vt"]:
                    terms = [f"{vi}/{ti}" for vi, ti in zip(face["v"], face["vt"])]
                else:
                    terms = [str(vi) for vi in face["v"]]
                fp.write("f " + " ".join(terms) + "\n")

    def write_game_obj(self, path: Path) -> None:
        """Write Sea Power's +Z-forward, 1:100-scale OBJ grouped by material."""
        material_order = list(dict.fromkeys(face["mat"] for face in self.faces))
        with path.open("w", encoding="utf-8", newline="\n") as fp:
            fp.write("# ROCN Hsiung Feng III Sea Power game OBJ\n")
            fp.write("# Scale: 1 model unit = 100 m. Axes: +X starboard, +Y up, +Z nose.\n")
            for forward, starboard, up in self.vertices:
                fp.write(f"v {starboard * 0.01:.8f} {up * 0.01:.8f} {forward * 0.01:.8f}\n")
            for u, v in self.texcoords:
                fp.write(f"vt {u:.6f} {v:.6f}\n")

            for material in material_order:
                fp.write(f"\no {material}\ng {material}\n")
                current_smooth = None
                for face in (item for item in self.faces if item["mat"] == material):
                    if face["smooth"] != current_smooth:
                        fp.write("s 1\n" if face["smooth"] else "s off\n")
                        current_smooth = face["smooth"]
                    if face["vt"]:
                        terms = [f"{vi}/{ti}" for vi, ti in zip(face["v"], face["vt"])]
                    else:
                        terms = [str(vi) for vi in face["v"]]
                    fp.write("f " + " ".join(terms) + "\n")


def polar_yz(radial: float, tangent: float, theta: float) -> tuple[float, float]:
    c = math.cos(theta)
    s = math.sin(theta)
    y = c * radial - s * tangent
    z = s * radial + c * tangent
    return y, z


def clamp(v: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, v))


def body_radius_at(x: float) -> float:
    if x <= -2.78:
        t = clamp((x + 3.05) / 0.27, 0.0, 1.0)
        return 0.205 + (0.230 - 0.205) * t
    if x >= 2.05:
        t = clamp((2.16 - x) / 0.11, 0.0, 1.0)
        return 0.220 + 0.010 * t
    return 0.230 + 0.002 * math.sin((x + 2.78) / 4.83 * math.pi)


def add_lathe(mesh: Mesh, group: str, mat: str, profile: list[tuple[float, float]], seg: int,
              center: tuple[float, float] = (0.0, 0.0), cap_start: bool = False, cap_end: bool = False,
              smooth: bool = True) -> None:
    rings: list[list[int]] = []
    cy, cz = center
    for x, r in profile:
        ring: list[int] = []
        for i in range(seg):
            a = 2.0 * PI * i / seg
            ring.append(mesh.v(x, cy + r * math.cos(a), cz + r * math.sin(a)))
        rings.append(ring)
    for k in range(len(rings) - 1):
        for i in range(seg):
            j = (i + 1) % seg
            mesh.f([rings[k][i], rings[k][j], rings[k + 1][j], rings[k + 1][i]], mat, group, smooth)
    if cap_start:
        c = mesh.v(profile[0][0], cy, cz)
        for i in range(seg):
            j = (i + 1) % seg
            mesh.f([c, rings[0][j], rings[0][i]], mat, group, smooth)
    if cap_end:
        c = mesh.v(profile[-1][0], cy, cz)
        last = rings[-1]
        for i in range(seg):
            j = (i + 1) % seg
            mesh.f([c, last[i], last[j]], mat, group, smooth)


def add_ogive(mesh: Mesh, group: str, mat: str, x_base: float, x_tip: float, radius: float,
              rings: int, seg: int) -> None:
    ring_ids: list[list[int]] = []
    for k in range(rings):
        t = k / rings
        x = x_base + (x_tip - x_base) * t
        r = radius * (1.0 - t) ** 0.58
        ring: list[int] = []
        for i in range(seg):
            a = 2.0 * PI * i / seg
            ring.append(mesh.v(x, r * math.cos(a), r * math.sin(a)))
        ring_ids.append(ring)
    for k in range(len(ring_ids) - 1):
        for i in range(seg):
            j = (i + 1) % seg
            mesh.f([ring_ids[k][i], ring_ids[k][j], ring_ids[k + 1][j], ring_ids[k + 1][i]], mat, group, True)
    tip = mesh.v(x_tip, 0.0, 0.0)
    last = ring_ids[-1]
    for i in range(seg):
        j = (i + 1) % seg
        mesh.f([last[i], last[j], tip], mat, group, True)


def add_loft_polar(mesh: Mesh, group: str, mat: str, sections: list[tuple[float, list[tuple[float, float]]]],
                   theta: float, smooth: bool = True, cap_start: bool = True, cap_end: bool = True) -> None:
    rings: list[list[int]] = []
    for x, pts in sections:
        ring: list[int] = []
        for radial, tangent in pts:
            y, z = polar_yz(radial, tangent, theta)
            ring.append(mesh.v(x, y, z))
        rings.append(ring)
    n = len(rings[0])
    for k in range(len(rings) - 1):
        for i in range(n):
            j = (i + 1) % n
            mesh.f([rings[k][i], rings[k][j], rings[k + 1][j], rings[k + 1][i]], mat, group, smooth)
    if cap_start:
        x, pts = sections[0]
        cr = sum(p[0] for p in pts) / len(pts)
        ct = sum(p[1] for p in pts) / len(pts)
        y, z = polar_yz(cr, ct, theta)
        c = mesh.v(x, y, z)
        for i in range(n):
            j = (i + 1) % n
            mesh.f([c, rings[0][j], rings[0][i]], mat, group, smooth)
    if cap_end:
        x, pts = sections[-1]
        cr = sum(p[0] for p in pts) / len(pts)
        ct = sum(p[1] for p in pts) / len(pts)
        y, z = polar_yz(cr, ct, theta)
        c = mesh.v(x, y, z)
        last = rings[-1]
        for i in range(n):
            j = (i + 1) % n
            mesh.f([c, last[i], last[j]], mat, group, smooth)


def duct_section(x: float) -> list[tuple[float, float]]:
    t = clamp((x + 2.55) / 4.02, 0.0, 1.0)
    base = body_radius_at(x) + 0.006
    height = 0.046 + 0.043 * math.sin(math.pi * t) ** 0.75
    half_w = 0.061 + 0.032 * math.sin(math.pi * t) ** 0.6
    if t > 0.83:
        height += 0.018 * (t - 0.83) / 0.17
        half_w += 0.010 * (t - 0.83) / 0.17
    outer = base + height
    return [
        (base, -half_w * 0.62),
        (base + height * 0.16, -half_w),
        (outer - height * 0.18, -half_w * 0.98),
        (outer + height * 0.06, -half_w * 0.58),
        (outer + height * 0.12, 0.0),
        (outer + height * 0.06, half_w * 0.58),
        (outer - height * 0.18, half_w * 0.98),
        (base + height * 0.16, half_w),
        (base, half_w * 0.62),
    ]


def add_ramjet_duct(mesh: Mesh, name: str, theta: float) -> None:
    xs = [-2.55 + 4.02 * i / 96 for i in range(97)]
    sections = [(x, duct_section(x)) for x in xs]
    add_loft_polar(mesh, f"{name}_conformal_outer_fairing", "hf3_duct_graphite", sections, theta, True, True, True)

    # Dark longitudinal slot on the outside of the duct; this is deliberately flat and narrow,
    # matching the visible black intake channel strips seen in public side photos.
    slot_sections = []
    for x in [-2.28 + 3.45 * i / 80 for i in range(81)]:
        t = clamp((x + 2.55) / 4.02, 0.0, 1.0)
        base = body_radius_at(x) + 0.006
        height = 0.046 + 0.043 * math.sin(math.pi * t) ** 0.75
        radial = base + height + 0.010
        half = 0.021 + 0.006 * math.sin(math.pi * t)
        slot_sections.append((x, [(radial, -half), (radial + 0.004, -half), (radial + 0.004, half), (radial, half)]))
    add_loft_polar(mesh, f"{name}_black_recessed_ramjet_slot", "hf3_intake_black", slot_sections, theta, False, True, True)

    # Forward scoop lip and black mouth.
    add_loft_polar(mesh, f"{name}_forward_scoop_lip", "hf3_light_gray", [(1.36, duct_section(1.36)), (1.49, duct_section(1.49))], theta, True, True, True)
    front_pts = duct_section(1.495)
    add_loft_polar(mesh, f"{name}_forward_black_intake_mouth", "hf3_intake_black", [(1.498, front_pts), (1.505, front_pts)], theta, True, True, True)


def add_local_box_polar(mesh: Mesh, group: str, mat: str, x0: float, x1: float,
                        r0: float, r1: float, t0: float, t1: float, theta: float) -> None:
    corners = [
        (x0, r0, t0), (x1, r0, t0), (x1, r1, t0), (x0, r1, t0),
        (x0, r0, t1), (x1, r0, t1), (x1, r1, t1), (x0, r1, t1),
    ]
    ids: list[int] = []
    for x, r, t in corners:
        y, z = polar_yz(r, t, theta)
        ids.append(mesh.v(x, y, z))
    for face in ([0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]):
        mesh.f([ids[i] for i in face], mat, group, False)


def add_surface_plate(mesh: Mesh, group: str, mat: str, x0: float, x1: float,
                      radial: float, t0: float, t1: float, theta: float,
                      uv: bool = False) -> None:
    coords = [(x0, radial, t0), (x1, radial, t0), (x1, radial, t1), (x0, radial, t1)]
    vids: list[int] = []
    for x, r, t in coords:
        y, z = polar_yz(r, t, theta)
        vids.append(mesh.v(x, y, z))
    if uv:
        vtids = [mesh.vt(0, 0), mesh.vt(1, 0), mesh.vt(1, 1), mesh.vt(0, 1)]
    else:
        vtids = None
    mesh.f(vids, mat, group, False, vtids)
    if vtids:
        mesh.f(list(reversed(vids)), mat, group, False, list(reversed(vtids)))
    else:
        mesh.f(list(reversed(vids)), mat, group, False, None)


def add_fin_polar(mesh: Mesh, group: str, mat: str, theta: float, x0: float, x1: float,
                  x_tip0: float, x_tip1: float, r_root: float, r_tip: float, thick: float) -> None:
    local = [
        (x0, r_root, -thick), (x1, r_root, -thick), (x_tip1, r_tip, -thick * 0.35), (x_tip0, r_tip, -thick * 0.35),
        (x0, r_root, thick), (x1, r_root, thick), (x_tip1, r_tip, thick * 0.35), (x_tip0, r_tip, thick * 0.35),
    ]
    ids: list[int] = []
    for x, r, t in local:
        y, z = polar_yz(r, t, theta)
        ids.append(mesh.v(x, y, z))
    for face in ([0, 1, 2, 3], [4, 7, 6, 5], [0, 4, 5, 1], [1, 5, 6, 2], [2, 6, 7, 3], [3, 7, 4, 0]):
        mesh.f([ids[i] for i in face], mat, group, False)


def add_booster(mesh: Mesh, side: str, theta: float) -> None:
    center = polar_yz(0.455, 0.0, theta)
    gold = [
        (-2.86, 0.083), (-2.68, 0.102), (-2.10, 0.106), (-1.40, 0.106),
        (-0.70, 0.105), (-0.05, 0.102), (0.42, 0.098), (0.55, 0.088),
    ]
    add_lathe(mesh, f"{side}_strap_on_booster_gold_casing", "hf3_booster_gold", gold, 192, center, True, False, True)
    white_nose = [(0.55, 0.088), (0.70, 0.070), (0.86, 0.035), (0.98, 0.000)]
    add_lathe(mesh, f"{side}_strap_on_booster_white_nose", "hf3_nose_white", white_nose, 192, center, False, True, True)
    add_lathe(mesh, f"{side}_strap_on_booster_rear_nozzle", "hf3_nozzle_black", [(-3.05, 0.058), (-2.86, 0.082)], 128, center, True, True, True)

    for n, x in enumerate([-2.24, -1.47, -0.70, 0.16]):
        add_lathe(mesh, f"{side}_booster_black_band_{n}", "hf3_panel_black", [(x - 0.015, 0.108), (x + 0.015, 0.108)], 160, center, False, False, True)

    add_local_box_polar(mesh, f"{side}_forward_booster_saddle", "hf3_pylon_offwhite", 0.16, 0.46, 0.255, 0.365, -0.035, 0.035, theta)
    add_local_box_polar(mesh, f"{side}_aft_booster_saddle", "hf3_pylon_offwhite", -2.38, -2.06, 0.255, 0.365, -0.038, 0.038, theta)

    add_fin_polar(mesh, f"{side}_booster_outer_aft_fin", "hf3_light_gray", theta, -2.93, -2.50, -2.84, -2.62, 0.545, 0.675, 0.018)
    add_fin_polar(mesh, f"{side}_booster_lower_aft_fin", "hf3_light_gray", theta - 0.23 if side == "starboard" else theta + 0.23,
                  -2.92, -2.52, -2.84, -2.63, 0.525, 0.640, 0.018)


def build_model() -> Mesh:
    mesh = Mesh()
    body_seg = 384

    body_profile: list[tuple[float, float]] = []
    for i in range(160):
        x = -3.05 + (2.16 + 3.05) * i / 159
        body_profile.append((x, body_radius_at(x)))
    add_lathe(mesh, "main_dark_graphite_body_046m_diameter", "hf3_body_dark", body_profile, body_seg, (0, 0), True, False, True)
    add_ogive(mesh, "white_ogive_radar_seeker_nose", "hf3_nose_white", 2.16, 3.05, 0.230, 112, body_seg)

    add_lathe(mesh, "aft_recessed_main_nozzle", "hf3_nozzle_black", [(-3.05, 0.150), (-2.92, 0.178)], 192, (0, 0), True, True, True)
    add_lathe(mesh, "nose_body_gray_transition_band", "hf3_light_gray", [(2.09, 0.234), (2.18, 0.234)], body_seg, (0, 0), False, False, True)
    add_lathe(mesh, "aft_body_gray_transition_band", "hf3_panel_gray", [(-2.82, 0.234), (-2.72, 0.234)], body_seg, (0, 0), False, False, True)

    for n, x in enumerate([-2.35, -1.92, -1.48, -1.04, -0.60, -0.16, 0.28, 0.72, 1.16, 1.60]):
        add_lathe(mesh, f"subtle_body_panel_ring_{n:02d}", "hf3_panel_line", [(x - 0.006, 0.235), (x + 0.006, 0.235)], body_seg, (0, 0), False, False, True)

    for name, theta in [
        ("top_ramjet", PI / 2),
        ("starboard_ramjet", 0.0),
        ("bottom_ramjet", 3 * PI / 2),
        ("port_ramjet", PI),
    ]:
        add_ramjet_duct(mesh, name, theta)

    # The two strap-on boosters sit in diagonal gaps between the four ramjet ducts.
    add_booster(mesh, "upper_starboard_diagonal", PI / 4)
    add_booster(mesh, "lower_port_diagonal", 5 * PI / 4)

    for label, theta in [("top", PI / 2), ("starboard", 0.0), ("bottom", 3 * PI / 2), ("port", PI)]:
        add_fin_polar(mesh, f"{label}_red_tail_clipped_delta_control_fin", "hf3_fin_red", theta,
                      -2.96, -2.34, -2.84, -2.48, 0.235, 0.650, 0.032)

    # Low-profile stabilizing strakes; much smaller than the tail fins, used to capture the subtle display-model strakes.
    for label, theta in [("upper_starboard", PI / 4), ("upper_port", 3 * PI / 4), ("lower_port", 5 * PI / 4), ("lower_starboard", 7 * PI / 4)]:
        add_fin_polar(mesh, f"{label}_low_profile_mid_body_strake", "hf3_light_gray", theta,
                      -0.62, 0.06, -0.48, -0.02, 0.242, 0.360, 0.015)

    for side, theta in [("starboard", 0.0), ("port", PI)]:
        add_surface_plate(mesh, f"{side}_side_marking_plate", "hf3_decal_side_text", 0.02, 1.35, 0.242, -0.105, 0.085, theta, True)
        add_surface_plate(mesh, f"{side}_s001_marking_plate", "hf3_decal_s001", 1.36, 1.82, 0.243, -0.018, 0.065, theta, True)
        # Small blue roundel is geometry so it stays visible in viewers that ignore alpha textures.
        add_lathe(mesh, f"{side}_small_rocn_roundel_blue_disc", "hf3_roundel_blue", [(-0.66, 0.040), (-0.655, 0.040)], 64, polar_yz(0.245, -0.088, theta), True, True, True)
        add_lathe(mesh, f"{side}_small_rocn_roundel_white_core", "hf3_nose_white", [(-0.652, 0.016), (-0.647, 0.016)], 48, polar_yz(0.247, -0.088, theta), True, True, True)

    for n, x in enumerate([-1.85, -1.36, -0.88, -0.40, 0.08, 0.56, 1.04]):
        add_surface_plate(mesh, f"starboard_flush_inspection_panel_{n}", "hf3_panel_gray", x, x + 0.18, 0.238, 0.108, 0.156, 0.0)
        add_surface_plate(mesh, f"port_flush_inspection_panel_{n}", "hf3_panel_gray", x, x + 0.18, 0.238, 0.108, 0.156, PI)

    return mesh


def write_mtl() -> None:
    mtl = """# Materials for ROCN Hsiung Feng III high-poly model.
newmtl hf3_body_dark
Kd 0.055 0.070 0.064
Ka 0.010 0.014 0.013
Ks 0.180 0.190 0.180
Ns 78

newmtl hf3_duct_graphite
Kd 0.135 0.150 0.145
Ka 0.028 0.032 0.031
Ks 0.160 0.170 0.165
Ns 62

newmtl hf3_light_gray
Kd 0.660 0.690 0.675
Ka 0.145 0.150 0.148
Ks 0.190 0.195 0.190
Ns 55

newmtl hf3_panel_gray
Kd 0.365 0.395 0.390
Ka 0.080 0.085 0.084
Ks 0.110 0.115 0.112
Ns 34

newmtl hf3_panel_line
Kd 0.018 0.020 0.020
Ka 0.003 0.004 0.004
Ks 0.040 0.040 0.040
Ns 18

newmtl hf3_panel_black
Kd 0.006 0.006 0.006
Ka 0.000 0.000 0.000
Ks 0.030 0.030 0.030
Ns 16

newmtl hf3_nose_white
Kd 0.900 0.875 0.805
Ka 0.200 0.190 0.175
Ks 0.250 0.235 0.205
Ns 78

newmtl hf3_intake_black
Kd 0.004 0.005 0.006
Ka 0.000 0.000 0.000
Ks 0.020 0.020 0.020
Ns 14


newmtl hf3_booster_gold
Kd 0.610 0.485 0.255
Ka 0.130 0.103 0.052
Ks 0.205 0.165 0.092
Ns 52

newmtl hf3_pylon_offwhite
Kd 0.735 0.720 0.625
Ka 0.160 0.155 0.135
Ks 0.120 0.112 0.095
Ns 28

newmtl hf3_fin_red
Kd 0.760 0.055 0.030
Ka 0.175 0.012 0.007
Ks 0.110 0.030 0.020
Ns 30

newmtl hf3_nozzle_black
Kd 0.000 0.000 0.000
Ka 0.000 0.000 0.000
Ks 0.016 0.016 0.016
Ns 8

newmtl hf3_roundel_blue
Kd 0.020 0.130 0.520
Ka 0.004 0.024 0.115
Ks 0.080 0.085 0.120
Ns 30

newmtl hf3_decal_side_text
Kd 1.000 1.000 1.000
Ka 0.000 0.000 0.000
Ks 0.000 0.000 0.000
Ns 1
map_Kd textures/hf3_side_marking.png

newmtl hf3_decal_s001
Kd 1.000 1.000 1.000
Ka 0.000 0.000 0.000
Ks 0.000 0.000 0.000
Ns 1
map_Kd textures/hf3_s001.png
"""
    MTL_PATH.write_text(mtl, encoding="utf-8", newline="\n")


def write_readme(mesh: Mesh) -> None:
    minx, maxx, miny, maxy, minz, maxz = mesh.bounds
    readme = f"""# ROCN Hsiung Feng III High-Poly Visual OBJ

Files:

- `rocn_hf-3.obj`
- `rocn_hf-3.mtl`
- `generate_rocn_hf3_highpoly.py`
- `generate_rocn_hf3_highpoly.ps1`
- `textures/hf3_side_marking.png`
- `textures/hf3_s001.png`

Scale and orientation:

- Units: meters
- Nose direction: `+X`
- Overall length: `{maxx - minx:.3f} m`
- Main body diameter basis: `0.46 m`
- Vertex count: `{len(mesh.vertices)}`
- Face count: `{len(mesh.faces)}`
- Bounds X: `{minx:.3f} .. {maxx:.3f}`
- Bounds Y: `{miny:.3f} .. {maxy:.3f}`
- Bounds Z: `{minz:.3f} .. {maxz:.3f}`

Modeled exterior features:

- Dark graphite main body with a white ogive radar seeker nose.
- Four conformal ramjet/intake duct fairings at the top, starboard, bottom, and port positions.
- Long black recessed intake slots and forward black intake mouths.
- Two diagonal strap-on booster rockets seated between the ramjet ducts, with gold casings, white nose caps, black aft nozzles, pylons, and small aft fins.
- Four red clipped-delta tail control fins.
- Low-profile mid-body strakes, panel rings, a clean white seeker nose, inspection panels, and simplified ROCN markings.

Reference basis:

- Public dimension commonly listed for HF-3: 6.1 m length and 0.46 m body diameter.
- Public exterior descriptions noting four inlet ducts, four clipped-delta control surfaces, a ramjet sustainer, and two strap-on boosters.
- Wikimedia Commons and user-provided photos for broad silhouette, color blocking, and booster/duct placement.

Limit:

This is a high-poly game-art exterior approximation for Sea Power modding, not a CAD-accurate reconstruction.
"""
    README_PATH.write_text(readme, encoding="utf-8", newline="\n")


def main() -> None:
    mesh = build_model()
    mesh.write_obj(OBJ_PATH)
    mesh.write_game_obj(GAME_OBJ_PATH)
    write_mtl()
    write_readme(mesh)
    minx, maxx, miny, maxy, minz, maxz = mesh.bounds
    print(f"Generated {OBJ_PATH}")
    print(f"Generated {GAME_OBJ_PATH}")
    print(f"vertices={len(mesh.vertices)} faces={len(mesh.faces)} length={maxx - minx:.3f}m")
    print(f"bounds x={minx:.3f}..{maxx:.3f} y={miny:.3f}..{maxy:.3f} z={minz:.3f}..{maxz:.3f}")


if __name__ == "__main__":
    main()
