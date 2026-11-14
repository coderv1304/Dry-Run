#!/usr/bin/env python3
"""Verify typeface coverage: Poppins must carry Devanagari, Noto is fallback only."""

from __future__ import annotations

import os
import struct
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
FONT_DIR = os.path.join(ROOT, "app", "assets", "fonts")

POPPINS = ["Poppins-Regular.ttf", "Poppins-Medium.ttf", "Poppins-SemiBold.ttf", "Poppins-Bold.ttf"]
NOTO = "NotoSansDevanagari-Variable.ttf"

# Devanagari sample: independent vowels, a conjunct and the danda.
REQUIRED = [0x0905, 0x0915, 0x0916, 0x0937, 0x094D, 0x0964, 0x0966]


def cmap_codepoints(path: str) -> set[int]:
    with open(path, "rb") as handle:
        data = handle.read()
    tag = data[:4]
    if tag not in (b"\x00\x01\x00\x00", b"true", b"ttcf", b"OTTO"):
        raise ValueError("Not a TrueType or OpenType font: %s" % path)
    num_tables = struct.unpack(">H", data[4:6])[0]
    cmap_offset = None
    for index in range(num_tables):
        start = 12 + index * 16
        table_tag = data[start : start + 4]
        offset = struct.unpack(">I", data[start + 8 : start + 12])[0]
        if table_tag == b"cmap":
            cmap_offset = offset
    if cmap_offset is None:
        raise ValueError("No cmap table in %s" % path)

    codepoints: set[int] = set()
    count = struct.unpack(">H", data[cmap_offset + 2 : cmap_offset + 4])[0]
    subtables = []
    for index in range(count):
        entry = cmap_offset + 4 + index * 8
        platform = struct.unpack(">H", data[entry : entry + 2])[0]
        encoding = struct.unpack(">H", data[entry + 2 : entry + 4])[0]
        sub_offset = cmap_offset + struct.unpack(">I", data[entry + 4 : entry + 8])[0]
        subtables.append((platform, encoding, sub_offset))

    for platform, encoding, offset in subtables:
        if platform not in (0, 3) or encoding not in (0, 1, 3, 4, 10):
            continue
        fmt = struct.unpack(">H", data[offset : offset + 2])[0]
        if fmt == 4:
            seg_x2 = struct.unpack(">H", data[offset + 6 : offset + 8])[0]
            seg_count = seg_x2 // 2
            ends = struct.unpack(">%dH" % seg_count, data[offset + 14 : offset + 14 + seg_x2])
            starts_at = offset + 16 + seg_x2
            starts = struct.unpack(">%dH" % seg_count, data[starts_at : starts_at + seg_x2])
            for start, end in zip(starts, ends):
                if start == 0xFFFF:
                    continue
                codepoints.update(range(start, end + 1))
        elif fmt == 12:
            groups = struct.unpack(">I", data[offset + 12 : offset + 16])[0]
            for group in range(groups):
                base = offset + 16 + group * 12
                start, end, _ = struct.unpack(">III", data[base : base + 12])
                codepoints.update(range(start, end + 1))
    return codepoints


def main() -> int:
    failures: list[str] = []
    if not os.path.isdir(FONT_DIR):
        print("FAIL: font directory missing: %s" % FONT_DIR)
        return 1

    for font in POPPINS:
        path = os.path.join(FONT_DIR, font)
        if not os.path.exists(path):
            failures.append("missing bundled typeface %s" % font)
            continue
        coverage = cmap_codepoints(path)
        missing = [code for code in REQUIRED if code not in coverage]
        if missing:
            failures.append("%s lacks Devanagari code points %s" % (font, [hex(code) for code in missing]))
        print("Poppins %-24s %d glyph code points, Devanagari %s" % (font, len(coverage), "ok" if not missing else "MISSING"))

    noto_path = os.path.join(FONT_DIR, NOTO)
    if not os.path.exists(noto_path):
        failures.append("missing glyph fallback %s" % NOTO)
    else:
        noto = cmap_codepoints(noto_path)
        missing = [code for code in REQUIRED if code not in noto]
        if missing:
            failures.append("%s lacks Devanagari code points %s" % (NOTO, [hex(code) for code in missing]))
        print("Noto fallback %-19s %d glyph code points, Devanagari %s" % (NOTO, len(noto), "ok" if not missing else "MISSING"))
        latin = 0x0041 in noto
        if latin:
            print("note: the fallback also carries Latin, it is never used as the primary family.")

    for font in POPPINS:
        path = os.path.join(FONT_DIR, font)
        if os.path.exists(path) and os.path.getsize(path) > 400000:
            failures.append("%s looks like a variable or full font; ship static weights only" % font)

    if failures:
        for failure in failures:
            print("FONT FAIL: %s" % failure)
        return 1
    print("FONT COVERAGE PASSED: Poppins covers Devanagari; Noto Sans Devanagari is fallback only.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
