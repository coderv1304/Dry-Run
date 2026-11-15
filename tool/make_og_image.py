"""Renders the branded Open Graph image and the touch icon for landing/.

Run after changing the brand copy in landing/content.json:
    python tool/make_og_image.py
`--check` only verifies that the files exist at the right sizes.
"""

from __future__ import annotations

import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
LANDING = ROOT / "landing"
FONTS = ROOT / "app" / "assets" / "fonts"
SURFACE = (20, 22, 26)
INK = (250, 251, 251)
MUTED = (168, 177, 180)
ACCENT = (29, 113, 124)
OG_SIZE = (1200, 630)
ICON_SIZE = (180, 180)


def build_og() -> None:
    image = Image.new("RGB", OG_SIZE, SURFACE)
    draw = ImageDraw.Draw(image)
    draw.rectangle((96, 150, 216, 158), fill=ACCENT)

    headline_font = ImageFont.truetype(str(FONTS / "Poppins-SemiBold.ttf"), 78)
    footnote_font = ImageFont.truetype(str(FONTS / "Poppins-Regular.ttf"), 34)
    mark_font = ImageFont.truetype(str(FONTS / "Poppins-Medium.ttf"), 30)

    draw.text((96, 76), "DRY RUN", font=mark_font, fill=MUTED)
    draw.text((96, 196), "Rehearse the call", font=headline_font, fill=INK)
    draw.text((96, 296), "before it finds you", font=headline_font, fill=INK)
    draw.text((96, 470), "Practice, not protection.", font=footnote_font, fill=MUTED)
    draw.text((96, 528), "A 90 second drill for digital arrest scam calls.", font=footnote_font, fill=MUTED)

    image.save(LANDING / "og-image.png", optimize=True)


def build_touch_icon() -> None:
    source = Image.open(ROOT / "app" / "web" / "icons" / "Icon-512.png").convert("RGBA")
    source.resize(ICON_SIZE, Image.LANCZOS).save(LANDING / "apple-touch-icon.png", optimize=True)


def main(argv: list[str]) -> int:
    if "--check" in argv:
        problems = []
        for name, size in (("og-image.png", OG_SIZE), ("apple-touch-icon.png", ICON_SIZE)):
            path = LANDING / name
            if not path.exists():
                problems.append(f"landing/{name} missing")
                continue
            with Image.open(path) as image:
                if image.size != size:
                    problems.append(f"landing/{name} is {image.size}, expected {size}")
        if problems:
            for problem in problems:
                print("  " + problem)
            return 1
        print("BRAND IMAGE CHECK PASSED: og image 1200x630, touch icon 180x180")
        return 0
    build_og()
    build_touch_icon()
    print("wrote landing/og-image.png and landing/apple-touch-icon.png")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
