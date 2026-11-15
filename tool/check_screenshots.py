"""Verifies the reviewed evidence screenshots for gate 4.

Six key screens, each captured at 390 wide in light and dark. Every file must be
a real PNG of that size and the two modes must differ, so a copy pasted or blank
pair can never pass.
"""

from __future__ import annotations

import pathlib
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DIRECTORY = ROOT / "docs" / "screenshots"
SCREENS = ("home", "consent", "drill", "debrief", "about", "report")
MODES = ("light", "dark")
WIDTH = 390
HEIGHT = 844
SIGNATURE = b"\x89PNG\r\n\x1a\n"


def png_size(data: bytes) -> tuple[int, int]:
    if data[:8] != SIGNATURE:
        raise ValueError("not a PNG")
    return struct.unpack(">II", data[16:24])


def main() -> int:
    if not DIRECTORY.is_dir():
        print("SCREENSHOT CHECK FAILED: docs/screenshots is missing")
        return 1
    failures: list[str] = []
    for screen in SCREENS:
        images: dict[str, bytes] = {}
        for mode in MODES:
            path = DIRECTORY / f"{screen}-{mode}.png"
            if not path.is_file():
                failures.append(f"{path.name} is missing")
                continue
            data = path.read_bytes()
            if len(data) < 8_000:
                failures.append(f"{path.name} is too small to be a real screen")
                continue
            try:
                width, height = png_size(data)
            except ValueError:
                failures.append(f"{path.name} is not a PNG")
                continue
            if (width, height) != (WIDTH, HEIGHT):
                failures.append(
                    f"{path.name} is {width}x{height}, expected {WIDTH}x{HEIGHT}"
                )
                continue
            images[mode] = data
        if len(images) == 2 and images["light"] == images["dark"]:
            failures.append(f"{screen}: light and dark are the same image")
    if failures:
        print("SCREENSHOT CHECK FAILED")
        for failure in failures:
            print("  - " + failure)
        return 1
    print(
        f"SCREENSHOT CHECK PASSED: {len(SCREENS) * len(MODES)} screenshots, "
        f"{WIDTH}x{HEIGHT}, light and dark."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
