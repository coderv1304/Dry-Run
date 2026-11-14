#!/usr/bin/env python3
"""Generate the brand mark into every default favicon and launcher slot.

Colours come from design/tokens.json, so a rebrand only edits the token source.
Mark: a drill timer ring with a gap and a centre dot, flat, no gradient.
"""

from __future__ import annotations

import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import token_model as tm

ROOT = tm.ROOT


def _hex(reference: str) -> str:
    return tm.core_hex(tm.load_tokens(), reference)


def mark(size: int, *, maskable: bool = False) -> Image.Image:
    tokens = tm.load_tokens()
    surface = _hex("Grayscale/870")
    ring = _hex("Primary/500")
    dot = _hex("Grayscale/50")

    scale = 4
    canvas = size * scale
    image = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    corner = int(canvas * (0.5 if maskable else 0.24))
    draw.rounded_rectangle([0, 0, canvas - 1, canvas - 1], radius=corner, fill=surface)

    inset = 0.10 if maskable else 0.0
    pad = int(canvas * (0.18 + inset))
    box = [pad, pad, canvas - 1 - pad, canvas - 1 - pad]
    width = max(2, int(canvas * 0.085))
    draw.arc(box, start=-55, end=235, fill=ring, width=width)

    centre = canvas / 2
    radius = int(canvas * 0.055)
    draw.ellipse(
        [centre - radius, centre - radius, centre + radius, centre + radius],
        fill=dot,
    )
    return image.resize((size, size), Image.LANCZOS)


TARGETS = [
    ("app/web/favicon.png", 32, False),
    ("app/web/icons/Icon-192.png", 192, False),
    ("app/web/icons/Icon-512.png", 512, False),
    ("app/web/icons/Icon-maskable-192.png", 192, True),
    ("app/web/icons/Icon-maskable-512.png", 512, True),
    ("app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48, False),
    ("app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72, False),
    ("app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96, False),
    ("app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144, False),
    ("app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192, False),
]


def main() -> int:
    for relative, size, maskable in TARGETS:
        path = os.path.join(ROOT, relative)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        mark(size, maskable=maskable).save(path, format="PNG", optimize=True)
        print("wrote %s (%dx%d)" % (relative, size, size))

    ico_path = os.path.join(ROOT, "landing", "favicon.ico")
    mark(48).save(ico_path, format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
    print("wrote landing/favicon.ico")
    return 0


if __name__ == "__main__":
    sys.exit(main())
