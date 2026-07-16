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
    return mesh


def write_obj(path: Path) -> None:
    meshes = (
        ("bofors_platform_port", build_platform(-1)),
        ("bofors_platform_starboard", build_platform(1)),
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


if __name__ == "__main__":
    write_obj(OUTPUT)
    print(f"Generated {OUTPUT}")
