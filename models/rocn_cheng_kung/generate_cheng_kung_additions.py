"""Generate additive Cheng Kung-class platform meshes for Sea Power."""

from __future__ import annotations

import math
from pathlib import Path


OUTPUT = Path(__file__).with_name("rocn_cheng_kung_additions.obj")


def add(a: tuple[float, float, float], b: tuple[float, float, float]):
    return tuple(x + y for x, y in zip(a, b))


def sub(a: tuple[float, float, float], b: tuple[float, float, float]):
    return tuple(x - y for x, y in zip(a, b))


def mul(a: tuple[float, float, float], scale: float):
    return tuple(x * scale for x in a)


def dot(a: tuple[float, float, float], b: tuple[float, float, float]):
    return sum(x * y for x, y in zip(a, b))


def cross(a: tuple[float, float, float], b: tuple[float, float, float]):
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def normalize(a: tuple[float, float, float]):
    length = math.sqrt(dot(a, a))
    if length == 0:
        raise ValueError("Cannot normalize a zero-length vector")
    return mul(a, 1.0 / length)


class ObjMesh:
    def __init__(self) -> None:
        self.vertices: list[tuple[float, float, float]] = []
        self.faces: list[tuple[tuple[int, ...], bool]] = []

    def vertex(self, point: tuple[float, float, float]) -> int:
        self.vertices.append(point)
        return len(self.vertices)

    def box(
        self,
        minimum: tuple[float, float, float],
        maximum: tuple[float, float, float],
    ) -> None:
        x0, y0, z0 = minimum
        x1, y1, z1 = maximum
        indices = [
            self.vertex(point)
            for point in (
                (x0, y0, z0),
                (x1, y0, z0),
                (x1, y1, z0),
                (x0, y1, z0),
                (x0, y0, z1),
                (x1, y0, z1),
                (x1, y1, z1),
                (x0, y1, z1),
            )
        ]
        for face in (
            (0, 3, 2, 1),
            (4, 5, 6, 7),
            (0, 1, 5, 4),
            (3, 7, 6, 2),
            (0, 4, 7, 3),
            (1, 2, 6, 5),
        ):
            self.faces.append((tuple(indices[index] for index in face), False))

    def cylinder(
        self,
        start: tuple[float, float, float],
        end: tuple[float, float, float],
        radius: float,
        segments: int = 12,
    ) -> None:
        axis = normalize(sub(end, start))
        reference = (0.0, 1.0, 0.0) if abs(axis[1]) < 0.9 else (1.0, 0.0, 0.0)
        basis_u = normalize(cross(axis, reference))
        basis_v = normalize(cross(axis, basis_u))
        start_ring: list[int] = []
        end_ring: list[int] = []
        for index in range(segments):
            angle = 2.0 * math.pi * index / segments
            radial = add(mul(basis_u, math.cos(angle) * radius), mul(basis_v, math.sin(angle) * radius))
            start_ring.append(self.vertex(add(start, radial)))
            end_ring.append(self.vertex(add(end, radial)))
        start_center = self.vertex(start)
        end_center = self.vertex(end)
        for index in range(segments):
            following = (index + 1) % segments
            self.faces.append(((start_ring[index], start_ring[following], end_ring[following], end_ring[index]), True))
            self.faces.append(((start_center, start_ring[following], start_ring[index]), False))
            self.faces.append(((end_center, end_ring[index], end_ring[following]), False))

    def oriented_box(
        self,
        center: tuple[float, float, float],
        basis_u: tuple[float, float, float],
        basis_v: tuple[float, float, float],
        basis_w: tuple[float, float, float],
        half_u: float,
        half_v: float,
        half_w: float,
    ) -> None:
        indices: list[int] = []
        for u, v, w in (
            (-1, -1, -1),
            (1, -1, -1),
            (1, 1, -1),
            (-1, 1, -1),
            (-1, -1, 1),
            (1, -1, 1),
            (1, 1, 1),
            (-1, 1, 1),
        ):
            point = center
            point = add(point, mul(basis_u, u * half_u))
            point = add(point, mul(basis_v, v * half_v))
            point = add(point, mul(basis_w, w * half_w))
            indices.append(self.vertex(point))
        for face in (
            (0, 3, 2, 1),
            (4, 5, 6, 7),
            (0, 1, 5, 4),
            (3, 7, 6, 2),
            (0, 4, 7, 3),
            (1, 2, 6, 5),
        ):
            self.faces.append((tuple(indices[index] for index in face), False))

    def recenter(self) -> tuple[float, float, float]:
        minimum = tuple(min(vertex[axis] for vertex in self.vertices) for axis in range(3))
        maximum = tuple(max(vertex[axis] for vertex in self.vertices) for axis in range(3))
        center = tuple((low + high) * 0.5 for low, high in zip(minimum, maximum))
        self.vertices = [sub(vertex, center) for vertex in self.vertices]
        return center


def build_platform(side: int) -> ObjMesh:
    """Build one platform; side is -1 for port and +1 for starboard."""
    mesh = ObjMesh()
    inner_x = -side * 0.028
    outer_x = side * 0.028
    edge_x = side * 0.027

    # Six-by-six metre cantilevered deck, rooted at the gun platform centre.
    mesh.box((-0.028, -0.003, -0.030), (0.028, 0.0, 0.030))
    mesh.box((min(inner_x, outer_x), -0.005, -0.0015), (max(inner_x, outer_x), -0.003, 0.0015))

    # Outer guard rail plus short fore/aft returns; the inboard edge stays open to the ship.
    for z in (-0.028, 0.0, 0.028):
        mesh.cylinder((edge_x, 0.0, z), (edge_x, 0.011, z), 0.00045)
    for y in (0.0055, 0.011):
        mesh.cylinder((edge_x, y, -0.028), (edge_x, y, 0.028), 0.00042)
        mesh.cylinder((inner_x, y, -0.028), (edge_x, y, -0.028), 0.00042)
        mesh.cylinder((inner_x, y, 0.028), (edge_x, y, 0.028), 0.00042)

    # Four visible braces carry the outboard deck edge back into the superstructure.
    for z in (-0.022, 0.022):
        mesh.cylinder((outer_x, -0.003, z), (inner_x, -0.020, z), 0.00075)
        mesh.cylinder((outer_x, -0.003, z), (inner_x, -0.003, z), 0.00060)
    mesh.recenter()
    return mesh


def launcher_basis(side: int):
    angle = math.radians(35.0)
    launch_axis = (side * math.cos(angle), math.sin(angle), 0.0)
    stack_axis = (-side * math.sin(angle), math.cos(angle), 0.0)
    lateral_axis = (0.0, 0.0, 1.0)
    return launch_axis, stack_axis, lateral_axis


def add_launcher_canister(
    mesh: ObjMesh,
    side: int,
    missile: str,
    row: int,
    column_z: float,
) -> tuple[float, float, float]:
    launch_axis, stack_axis, lateral_axis = launcher_basis(side)
    if missile == "hf2":
        length, height, width = 0.0520, 0.0082, 0.0088
        rib_count = 8
    elif missile == "hf3":
        length, height, width = 0.0610, 0.0105, 0.0110
        rib_count = 9
    else:
        raise ValueError(f"Unsupported canister type: {missile}")

    row_offset = 0.0062 + row * 0.0118
    center = add(mul(launch_axis, length * 0.5), mul(stack_axis, row_offset))
    center = add(center, mul(lateral_axis, column_z))
    mesh.oriented_box(
        center,
        launch_axis,
        stack_axis,
        lateral_axis,
        length * 0.5,
        height * 0.5,
        width * 0.5,
    )

    # Raised front/rear caps and the transverse reinforcing ribs visible in photographs.
    for longitudinal in (-length * 0.5, length * 0.5):
        cap_center = add(center, mul(launch_axis, longitudinal))
        mesh.oriented_box(
            cap_center,
            launch_axis,
            stack_axis,
            lateral_axis,
            0.00045,
            height * 0.5 + 0.00035,
            width * 0.5 + 0.00035,
        )
    for index in range(1, rib_count):
        longitudinal = -length * 0.5 + length * index / rib_count
        rib_center = add(center, mul(launch_axis, longitudinal))
        mesh.oriented_box(
            rib_center,
            launch_axis,
            stack_axis,
            lateral_axis,
            0.00022,
            height * 0.5 + 0.00028,
            width * 0.5 + 0.00028,
        )

    # Longitudinal stiffeners create the characteristic gridded canister side panels.
    for stack_fraction in (-0.28, 0.28):
        for lateral_sign in (-1, 1):
            rail_center = center
            rail_center = add(rail_center, mul(stack_axis, stack_fraction * height))
            rail_center = add(rail_center, mul(lateral_axis, lateral_sign * (width * 0.5 + 0.00018)))
            mesh.oriented_box(
                rail_center,
                launch_axis,
                stack_axis,
                lateral_axis,
                length * 0.47,
                0.00022,
                0.00018,
            )
    for lateral_fraction in (-0.30, 0.30):
        for stack_sign in (-1, 1):
            rail_center = center
            rail_center = add(rail_center, mul(lateral_axis, lateral_fraction * width))
            rail_center = add(rail_center, mul(stack_axis, stack_sign * (height * 0.5 + 0.00018)))
            mesh.oriented_box(
                rail_center,
                launch_axis,
                stack_axis,
                lateral_axis,
                length * 0.47,
                0.00018,
                0.00022,
            )

    # Rear access-door latch and hinge blocks.
    rear_center = add(center, mul(launch_axis, -length * 0.5 - 0.00055))
    mesh.oriented_box(
        rear_center,
        launch_axis,
        stack_axis,
        lateral_axis,
        0.00035,
        height * 0.16,
        width * 0.18,
    )
    return add(center, mul(launch_axis, length * 0.5 + 0.0006))


def build_launcher(side: int) -> tuple[ObjMesh, dict[str, list[tuple[float, float, float]]]]:
    """Build a 2x2 HF-2/HF-3 mixed launcher aimed to the selected broadside."""
    mesh = ObjMesh()
    launch_axis, stack_axis, lateral_axis = launcher_basis(side)
    # Mirror the columns so each rack reads HF-2 left / HF-3 right from outboard.
    hf2_z = side * 0.00555
    hf3_z = -side * 0.00555
    launch_points = {"hf2": [], "hf3": []}

    for row in (0, 1):
        launch_points["hf2"].append(add_launcher_canister(mesh, side, "hf2", row, hf2_z))
        launch_points["hf3"].append(add_launcher_canister(mesh, side, "hf3", row, hf3_z))

    # Deck foundation and equipment cabinet.
    mesh.box((-0.016, 0.0, -0.014), (0.016, 0.0015, 0.014))
    cabinet_inner_x = -side * 0.010
    mesh.box(
        (min(cabinet_inner_x, cabinet_inner_x + side * 0.008), 0.0015, -0.0045),
        (max(cabinet_inner_x, cabinet_inner_x + side * 0.008), 0.0120, 0.0045),
    )

    # Paired lower rails and two A-frame supports carry the four canisters.
    for z in (-0.0115, 0.0115):
        rail_start = add(mul(launch_axis, -0.001), mul(stack_axis, 0.0015))
        rail_start = add(rail_start, mul(lateral_axis, z))
        rail_end = add(mul(launch_axis, 0.050), mul(stack_axis, 0.0015))
        rail_end = add(rail_end, mul(lateral_axis, z))
        mesh.cylinder(rail_start, rail_end, 0.00065, 14)

    for longitudinal in (0.008, 0.036):
        rack_center = add(mul(launch_axis, longitudinal), mul(stack_axis, 0.0020))
        left_rack = add(rack_center, mul(lateral_axis, -0.0115))
        right_rack = add(rack_center, mul(lateral_axis, 0.0115))
        mesh.cylinder(left_rack, right_rack, 0.00065, 14)
        for z in (-0.0115, 0.0115):
            upper = add(rack_center, mul(lateral_axis, z))
            lower_a = (-side * 0.010, 0.0015, z)
            lower_b = (side * 0.010, 0.0015, z)
            mesh.cylinder(lower_a, upper, 0.00058, 14)
            mesh.cylinder(lower_b, upper, 0.00058, 14)

    # Cross ties between the upper and lower rows keep the stack visibly connected.
    for longitudinal in (0.004, 0.028, 0.048):
        lower = add(mul(launch_axis, longitudinal), mul(stack_axis, 0.0015))
        upper = add(mul(launch_axis, longitudinal), mul(stack_axis, 0.0240))
        for z in (-0.0115, 0.0115):
            mesh.cylinder(add(lower, mul(lateral_axis, z)), add(upper, mul(lateral_axis, z)), 0.00046, 12)

    center = mesh.recenter()
    launch_points = {
        missile: [sub(point, center) for point in points]
        for missile, points in launch_points.items()
    }
    return mesh, launch_points


def write_obj(path: Path) -> None:
    port_launcher, port_points = build_launcher(-1)
    starboard_launcher, starboard_points = build_launcher(1)
    meshes = (
        ("bofors_platform_port", build_platform(-1)),
        ("bofors_platform_starboard", build_platform(1)),
        ("hf_launcher_port", port_launcher),
        ("hf_launcher_starboard", starboard_launcher),
    )
    vertex_offset = 0
    with path.open("w", encoding="ascii", newline="\n") as output:
        output.write("# ROCN Cheng Kung-class additive 40 mm gun platforms\n")
        output.write("# Sea Power scale: 1 model unit = 100 metres\n")
        for name, mesh in meshes:
            output.write(f"\no {name}\ng {name}\nusemtl usn_parts\n")
            for x, y, z in mesh.vertices:
                output.write(f"v {x:.7f} {y:.7f} {z:.7f}\n")
            current_smoothing = None
            for face, smoothing in mesh.faces:
                if smoothing != current_smoothing:
                    output.write("s 1\n" if smoothing else "s off\n")
                    current_smoothing = smoothing
                output.write("f " + " ".join(str(index + vertex_offset) for index in face) + "\n")
            vertex_offset += len(mesh.vertices)
    print("Port launcher points:", port_points)
    print("Starboard launcher points:", starboard_points)


if __name__ == "__main__":
    write_obj(OUTPUT)
    print(f"Generated {OUTPUT}")
