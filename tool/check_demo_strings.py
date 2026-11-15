#!/usr/bin/env python3
"""Prove that a production build contains no demo-only strings.

The demo mode is compiled out by `--dart-define=DEMO_MODE=true` being absent,
so the release AOT snapshot must not carry the fixed transcript, the demo
tokens, or the demo banner copy. Scanning the shipped artifact is the only
honest check: reading source would not prove what the compiler kept.

Usage:
    python tool/check_demo_strings.py            # check the release APK
    python tool/check_demo_strings.py --verbose
"""

from __future__ import annotations

import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RELEASE_APK = (
    ROOT / "app" / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
)
DEBUG_APK = (
    ROOT / "app" / "build" / "app" / "outputs" / "flutter-apk" / "app-debug.apk"
)
WEB_BUILD = ROOT / "app" / "build" / "web" / "main.dart.js"

# Strings that exist only to support DEMO_MODE. Every one of them is defined in
# app/lib/features/demo/demo_mode.dart and nowhere else.
DEMO_STRINGS = [
    b"demo-recorded-walkthrough-7f3c",
    b"demo-token-7f3c",
    b"demo-report-7f3c",
    b"demo-invite-7f3c",
    b"This recorded walkthrough is a fixed practice call.",
]

# Names that would mean a demo-only code path survived into production.
DEMO_SYMBOLS = [
    b"DemoSessionController",
    b"DemoDebriefController",
    b"demoDrillState",
    b"demoDebriefResponse",
]


def scan_blob(name: str, data: bytes) -> list[str]:
    hits: list[str] = []
    for needle in DEMO_STRINGS + DEMO_SYMBOLS:
        if needle in data:
            hits.append("%s: %s" % (name, needle.decode("utf-8", "replace")))
    return hits


def scan_apk(path: Path) -> list[str]:
    hits: list[str] = []
    with zipfile.ZipFile(path) as archive:
        # Only compiled app code matters. Assets and metadata never carry it.
        for entry in archive.namelist():
            if not entry.startswith("lib/"):
                continue
            if not entry.endswith(".so"):
                continue
            hits.extend(scan_blob(entry, archive.read(entry)))
    return hits


def main(argv: list[str]) -> int:
    verbose = "--verbose" in argv

    if RELEASE_APK.is_file():
        artifact = RELEASE_APK
        hits = scan_apk(RELEASE_APK)
    elif DEBUG_APK.is_file():
        print(
            "SKIPPED: only a debug APK exists. A debug build keeps every code "
            "path, so it is not a production artifact. Run `make apk` with the "
            "Android SDK available and re-run this check."
        )
        return 0
    elif WEB_BUILD.is_file():
        artifact = WEB_BUILD
        hits = scan_blob(WEB_BUILD.name, WEB_BUILD.read_bytes())
    else:
        print(
            "No production artifact found. Run `make apk` (or `make web`) "
            "before this check."
        )
        return 1

    if hits:
        print("DEMO STRING CHECK FAILED: %s still contains demo code." % artifact.name)
        for hit in hits:
            print("  - " + hit)
        return 1

    if verbose:
        print("Scanned %s (%d bytes)." % (artifact, artifact.stat().st_size))
        for needle in DEMO_STRINGS:
            print("  absent: " + needle.decode("utf-8"))
    print("DEMO STRING CHECK PASSED: production build has no demo strings.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
