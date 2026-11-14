#!/usr/bin/env python3
"""Flatten the vendored Phosphor SVGs into Dart contours.

Icons are vendored as SVG (the only permitted icon sets) and flattened here so
the app paints them without a runtime font or network fetch.

Usage:
    python tool/gen_icons.py
    python tool/gen_icons.py --check
    python tool/gen_icons.py --preview build/icon_preview.png
"""

from __future__ import annotations

import math
import os
import re
import struct
import sys
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ICON_DIR = os.path.join(ROOT, "app", "assets", "icons")
OUT_PATH = os.path.join(ROOT, "app", "lib", "design", "icons.g.dart")

DART_HEADER = """// GENERATED FILE - DO NOT EDIT.
// Source: app/assets/icons/*.svg (Phosphor Icons, MIT)
// Regenerate: python tool/gen_icons.py
// Flattened at 256 units so the app needs no icon font and no network fetch.

"""

NUMBER = re.compile(r"[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?")
COMMAND = re.compile(r"[MmLlHhVvCcSsQqTtAaZz]")
CURVE_STEPS = 10
ARC_STEPS = 20


def tokenize(path_data: str) -> list[str]:
    return [match.group(0) for match in re.finditer(r"[MmLlHhVvCcSsQqTtAaZz]|[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?", path_data)]


def arc_points(x0: float, y0: float, rx: float, ry: float, rotation: float, large: int, sweep: int, x1: float, y1: float) -> list[tuple[float, float]]:
    if rx == 0 or ry == 0 or (x0 == x1 and y0 == y1):
        return [(x1, y1)]
    rx, ry = abs(rx), abs(ry)
    phi = math.radians(rotation)
    cos_phi, sin_phi = math.cos(phi), math.sin(phi)
    dx2, dy2 = (x0 - x1) / 2.0, (y0 - y1) / 2.0
    x1p = cos_phi * dx2 + sin_phi * dy2
    y1p = -sin_phi * dx2 + cos_phi * dy2
    scale = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
    if scale > 1:
        factor = math.sqrt(scale)
        rx *= factor
        ry *= factor
    numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
    denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p
    factor = math.sqrt(max(0.0, numerator / denominator)) if denominator else 0.0
    if large == sweep:
        factor = -factor
    cxp = factor * rx * y1p / ry
    cyp = -factor * ry * x1p / rx
    cx = cos_phi * cxp - sin_phi * cyp + (x0 + x1) / 2.0
    cy = sin_phi * cxp + cos_phi * cyp + (y0 + y1) / 2.0

    def angle(ux: float, uy: float, vx: float, vy: float) -> float:
        dot = ux * vx + uy * vy
        norm = math.hypot(ux, uy) * math.hypot(vx, vy)
        if norm == 0:
            return 0.0
        value = max(-1.0, min(1.0, dot / norm))
        sign = -1.0 if (ux * vy - uy * vx) < 0 else 1.0
        return sign * math.acos(value)

    start = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    delta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not sweep and delta > 0:
        delta -= 2 * math.pi
    elif sweep and delta < 0:
        delta += 2 * math.pi

    points = []
    for step in range(1, ARC_STEPS + 1):
        theta = start + delta * step / ARC_STEPS
        px = cos_phi * rx * math.cos(theta) - sin_phi * ry * math.sin(theta) + cx
        py = sin_phi * rx * math.cos(theta) + cos_phi * ry * math.sin(theta) + cy
        points.append((px, py))
    return points


def flatten(path_data: str) -> list[list[tuple[float, float]]]:
    tokens = tokenize(path_data)
    contours: list[list[tuple[float, float]]] = []
    current: list[tuple[float, float]] = []
    index = 0
    command = ""
    x, y = 0.0, 0.0
    start_x, start_y = 0.0, 0.0
    last_control: tuple[float, float] | None = None
    last_kind = ""

    def read() -> float:
        nonlocal index
        value = float(tokens[index])
        index += 1
        return value

    while index < len(tokens):
        token = tokens[index]
        if COMMAND.fullmatch(token):
            command = token
            index += 1
            if command in "Zz":
                if current and current[0] != (x, y):
                    current.append((x, y))
                if current:
                    contours.append(current)
                current = []
                x, y = start_x, start_y
                last_control = None
                last_kind = "Z"
                continue
        elif not command:
            raise ValueError("Path data starts without a command: %s" % path_data[:40])

        upper = command.upper()
        relative = command.islower()

        if upper == "M":
            mx, my = read(), read()
            x, y = (x + mx, y + my) if relative else (mx, my)
            if current:
                contours.append(current)
            current = [(x, y)]
            start_x, start_y = x, y
            command = "l" if relative else "L"
            last_control = None
            last_kind = "M"
        elif upper == "L":
            lx, ly = read(), read()
            x, y = (x + lx, y + ly) if relative else (lx, ly)
            current.append((x, y))
            last_control = None
            last_kind = "L"
        elif upper == "H":
            hx = read()
            x = x + hx if relative else hx
            current.append((x, y))
            last_control = None
            last_kind = "L"
        elif upper == "V":
            vy = read()
            y = y + vy if relative else vy
            current.append((x, y))
            last_control = None
            last_kind = "L"
        elif upper in ("C", "S", "Q", "T"):
            if upper == "C":
                cx1, cy1 = read(), read()
                cx1, cy1 = (x + cx1, y + cy1) if relative else (cx1, cy1)
                cx2, cy2 = read(), read()
                cx2, cy2 = (x + cx2, y + cy2) if relative else (cx2, cy2)
                ex, ey = read(), read()
                ex, ey = (x + ex, y + ey) if relative else (ex, ey)
            elif upper == "S":
                if last_kind in ("C", "S") and last_control:
                    cx1 = 2 * x - last_control[0]
                    cy1 = 2 * y - last_control[1]
                else:
                    cx1, cy1 = x, y
                cx2, cy2 = read(), read()
                cx2, cy2 = (x + cx2, y + cy2) if relative else (cx2, cy2)
                ex, ey = read(), read()
                ex, ey = (x + ex, y + ey) if relative else (ex, ey)
            elif upper == "Q":
                qx, qy = read(), read()
                qx, qy = (x + qx, y + qy) if relative else (qx, qy)
                ex, ey = read(), read()
                ex, ey = (x + ex, y + ey) if relative else (ex, ey)
                cx1 = x + 2.0 / 3.0 * (qx - x)
                cy1 = y + 2.0 / 3.0 * (qy - y)
                cx2 = ex + 2.0 / 3.0 * (qx - ex)
                cy2 = ey + 2.0 / 3.0 * (qy - ey)
                last_control = (qx, qy)
            else:
                if last_kind in ("Q", "T") and last_control:
                    qx = 2 * x - last_control[0]
                    qy = 2 * y - last_control[1]
                else:
                    qx, qy = x, y
                ex, ey = read(), read()
                ex, ey = (x + ex, y + ey) if relative else (ex, ey)
                cx1 = x + 2.0 / 3.0 * (qx - x)
                cy1 = y + 2.0 / 3.0 * (qy - y)
                cx2 = ex + 2.0 / 3.0 * (qx - ex)
                cy2 = ey + 2.0 / 3.0 * (qy - ey)
                last_control = (qx, qy)
            if upper in ("C", "S"):
                last_control = (cx2, cy2)
            for step in range(1, CURVE_STEPS + 1):
                t = step / CURVE_STEPS
                mt = 1 - t
                px = mt ** 3 * x + 3 * mt * mt * t * cx1 + 3 * mt * t * t * cx2 + t ** 3 * ex
                py = mt ** 3 * y + 3 * mt * mt * t * cy1 + 3 * mt * t * t * cy2 + t ** 3 * ey
                current.append((px, py))
            x, y = ex, ey
            last_kind = upper
        elif upper == "A":
            rx, ry = read(), read()
            rotation = read()
            large, sweep = int(read()), int(read())
            ex, ey = read(), read()
            ex, ey = (x + ex, y + ey) if relative else (ex, ey)
            for point in arc_points(x, y, rx, ry, rotation, large, sweep, ex, ey):
                current.append(point)
            x, y = ex, ey
            last_control = None
            last_kind = "A"
        else:
            raise ValueError("Unsupported path command: %s" % command)

    if current:
        contours.append(current)
    return contours


def icon_name(file_name: str) -> str:
    parts = file_name.replace(".svg", "").split("-")
    return parts[0] + "".join(part[:1].upper() + part[1:] for part in parts[1:])


def load_icons() -> dict[str, list[list[tuple[float, float]]]]:
    icons = {}
    for file_name in sorted(os.listdir(ICON_DIR)):
        if not file_name.endswith(".svg"):
            continue
        with open(os.path.join(ICON_DIR, file_name), "r", encoding="utf-8") as handle:
            svg = handle.read()
        match = re.search(r'<path[^>]*d="([^"]+)"', svg)
        if not match:
            raise SystemExit("%s has no path data" % file_name)
        icons[icon_name(file_name)] = flatten(match.group(1))
    return icons


def render_dart(icons: dict[str, list[list[tuple[float, float]]]]) -> str:
    out = [DART_HEADER, "import 'package:flutter/widgets.dart';\n\n"]
    out.append("/// One flattened Phosphor glyph. Coordinates live in a 256 unit box.\n")
    out.append("final class DrIconData {\n")
    out.append("  const DrIconData(this.name, this.contours);\n\n")
    out.append("  final String name;\n")
    out.append("  final List<List<double>> contours;\n\n")
    out.append("  static const double viewBox = 256;\n\n")
    out.append("  Path toPath(double size) {\n")
    out.append("    final double factor = size / viewBox;\n")
    out.append("    final Path path = Path()..fillType = PathFillType.nonZero;\n")
    out.append("    for (final List<double> contour in contours) {\n")
    out.append("      path.moveTo(contour[0] * factor, contour[1] * factor);\n")
    out.append("      for (int index = 2; index < contour.length; index += 2) {\n")
    out.append("        path.lineTo(contour[index] * factor, contour[index + 1] * factor);\n")
    out.append("      }\n")
    out.append("      path.close();\n")
    out.append("    }\n")
    out.append("    return path;\n")
    out.append("  }\n")
    out.append("}\n\n")
    out.append("/// Vendored Phosphor glyphs, flattened at generation time.\n")
    out.append("abstract final class DrIcons {\n")
    for name, contours in icons.items():
        flat = []
        for contour in contours:
            values = []
            for point in contour:
                values.append("%.2f" % point[0])
                values.append("%.2f" % point[1])
            flat.append("<double>[%s]" % ", ".join(values))
        out.append("  static const DrIconData %s = DrIconData('%s', <List<double>>[\n    %s,\n  ]);\n" % (name, name, ",\n    ".join(flat)))
    out.append("}\n")
    return "".join(out)


def write_png(path: str, width: int, height: int, pixels: bytearray) -> None:
    raw = bytearray()
    stride = width * 4
    for row in range(height):
        raw.append(0)
        raw.extend(pixels[row * stride : (row + 1) * stride])

    def chunk(tag: bytes, body: bytes) -> bytes:
        return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    with open(path, "wb") as handle:
        handle.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b""))


def preview(icons: dict[str, list[list[tuple[float, float]]]], path: str) -> None:
    cell, columns = 96, 5
    rows = (len(icons) + columns - 1) // columns
    width, height = cell * columns, cell * rows
    pixels = bytearray([24, 24, 24, 255] * (width * height))
    for position, (_, contours) in enumerate(icons.items()):
        origin_x = (position % columns) * cell
        origin_y = (position // columns) * cell
        for contour in contours:
            points = [(origin_x + 16 + x * 64 / 256, origin_y + 16 + y * 64 / 256) for x, y in contour]
            for index in range(1, len(points)):
                steps = int(max(abs(points[index][0] - points[index - 1][0]), abs(points[index][1] - points[index - 1][1]))) + 1
                for step in range(steps + 1):
                    t = step / steps
                    px = points[index - 1][0] + (points[index][0] - points[index - 1][0]) * t
                    py = points[index - 1][1] + (points[index][1] - points[index - 1][1]) * t
                    for dx in (0, 1):
                        for dy in (0, 1):
                            ix, iy = int(px) + dx, int(py) + dy
                            if 0 <= ix < width and 0 <= iy < height:
                                offset = (iy * width + ix) * 4
                                pixels[offset : offset + 4] = bytes([250, 251, 251, 255])
    write_png(path, width, height, pixels)


def main(argv: list[str]) -> int:
    icons = load_icons()
    if not icons:
        raise SystemExit("No vendored icons found in app/assets/icons")
    if "--preview" in argv:
        target = argv[argv.index("--preview") + 1]
        os.makedirs(os.path.dirname(os.path.abspath(target)), exist_ok=True)
        preview(icons, target)
        print("wrote %s" % target)
        return 0
    content = render_dart(icons)
    current = None
    if os.path.exists(OUT_PATH):
        with open(OUT_PATH, "r", encoding="utf-8", newline="") as handle:
            current = handle.read()
    if "--check" in argv:
        if current != content:
            print("app/lib/design/icons.g.dart is stale. Run python tool/gen_icons.py")
            return 1
        print("Icon generation is reproducible: %d icons current." % len(icons))
        return 0
    with open(OUT_PATH, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(content)
    print("wrote app/lib/design/icons.g.dart (%d icons)" % len(icons))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
