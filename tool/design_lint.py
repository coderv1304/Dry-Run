#!/usr/bin/env python3
"""Design lint: automated enforcement of every UI rule.

Scans source Dart, ARB, landing files, app/web and scenario YAML. Never scans
minified bundles, generated token files or documentation.

Usage:
    python tool/design_lint.py                  # scan the repository
    python tool/design_lint.py --root <dir>     # scan a directory (fixtures)
"""

from __future__ import annotations

import hashlib
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import token_model as tm

ROOT = tm.ROOT

TEXT_EXTENSIONS = {".dart", ".arb", ".html", ".css", ".js", ".json", ".yaml", ".yml"}

SCAN_ROOTS = [
    "app/lib",
    "app/web",
    "landing",
    "backend/app/scenarios",
]

SKIP_PARTS = {
    "build",
    ".dart_tool",
    "node_modules",
    ".git",
    ".gates",
    "docs",
    "tool",
    "tests",
    "packages",
    "fonts",
    "icons",
}

GENERATED_ALLOWLIST = [
    "app/lib/design/color_tokens.g.dart",
    "app/lib/design/space_tokens.g.dart",
    "app/lib/design/type_tokens.g.dart",
    "app/lib/design/icons.g.dart",
    "landing/tokens.css",
    "design/tokens.json",
]

BANNED_FONTS = ["Geist Mono", "Geist", "Inter", "Roboto", "Arial", "Helvetica", "Open Sans"]
BANNED_ICON_SETS = ["lucide", "Icons.", "material symbols", "material_symbols", "cupertino_icons"]
AI_GLYPHS = ["sparkle", "sparkles", "auto_awesome", "auto_fix", "magic_wand", "star_burst"]
PLACEHOLDERS = ["lorem", "ipsum", "your headline here"]
PRICING_WORDS = ["pricing", "tier", "tiered", "testimonial"]
FILLER_WORDS = [
    "revolutionize",
    "supercharge",
    "cutting edge",
    "effortless",
    "transform your workflow",
    "take it to the next level",
    "harness the power",
    "world class",
]

PACKAGE_NAME = "dryrun"


class Violation:
    def __init__(self, rule: str, path: str, line: int, message: str) -> None:
        self.rule = rule
        self.path = path
        self.line = line
        self.message = message

    def render(self, base: str = ROOT) -> str:
        rel = os.path.relpath(self.path, base).replace("\\", "/")
        return "%s:%d [%s] %s" % (rel, self.line, self.rule, self.message)


def _line_of(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def _literal_values(raw: str) -> list[float]:
    """Numbers written as standalone arguments, never constants or arithmetic."""
    values: list[float] = []
    for match in re.finditer(r"(?:^|[(:,]\s*)(-?[0-9]+(?:\.[0-9]+)?)(?=\s*[,)]|\s*$)", raw):
        values.append(float(match.group(1)))
    return values


def _spacing_violations(text: str, path: str, scale: list[int]) -> list[Violation]:
    found: list[Violation] = []
    patterns = [
        (r"EdgeInsets\.all\(([^)]*)\)", "EdgeInsets.all"),
        (r"EdgeInsets\.symmetric\(([^)]*)\)", "EdgeInsets.symmetric"),
        (r"EdgeInsets\.only\(([^)]*)\)", "EdgeInsets.only"),
        (r"EdgeInsets\.fromLTRB\(([^)]*)\)", "EdgeInsets.fromLTRB"),
        (r"SizedBox\((?:height|width):\s*([0-9.]+)", "SizedBox"),
        (r"SizedBox\.square\(dimension:\s*([0-9.]+)", "SizedBox.square"),
        (r"\bgap:\s*([0-9.]+)", "gap"),
        (r"\bspacing:\s*([0-9.]+)", "spacing"),
        (r"\brunSpacing:\s*([0-9.]+)", "runSpacing"),
    ]
    for pattern, label in patterns:
        for match in re.finditer(pattern, text):
            for value in _literal_values(match.group(1)):
                if value not in scale:
                    found.append(Violation("off-scale-spacing", path, _line_of(text, match.start()), "%s uses %s, off the spacing scale" % (label, value)))
    if path.endswith(".css"):
        for match in re.finditer(r"\b(?:padding|margin|gap|row-gap|column-gap)(?:-[a-z]+)?:\s*([^;]+);", text):
            for raw in re.findall(r"([0-9.]+)px", match.group(1)):
                value = float(raw)
                if value not in scale:
                    found.append(Violation("off-scale-spacing", path, _line_of(text, match.start()), "CSS spacing uses %spx, off the spacing scale" % raw))
    return found


def _radius_violations(text: str, path: str, radii: list[float]) -> list[Violation]:
    found: list[Violation] = []
    for match in re.finditer(r"(?:BorderRadius|Radius)\.circular\(([0-9.]+)", text):
        value = float(match.group(1))
        if value not in radii:
            found.append(Violation("off-scale-radius", path, _line_of(text, match.start()), "radius %s is off the radius scale" % match.group(1)))
    for match in re.finditer(r"(?:BorderRadius|Radius)\.vertical\(([^)]*)\)", text):
        for value in _literal_values(match.group(1)):
            if value not in radii:
                found.append(Violation("off-scale-radius", path, _line_of(text, match.start()), "radius %s is off the radius scale" % value))
    if path.endswith(".css"):
        for match in re.finditer(r"border-radius:\s*([^;]+);", text):
            if "var(" in match.group(1):
                continue
            for raw in re.findall(r"([0-9.]+)px", match.group(1)):
                value = float(raw)
                if value not in radii and value != 9999:
                    found.append(Violation("off-scale-radius", path, _line_of(text, match.start()), "CSS radius %spx is off the radius scale" % raw))
    return found


def _font_size_violations(text: str, path: str) -> list[Violation]:
    found: list[Violation] = []
    for match in re.finditer(r"fontSize:\s*([0-9.]+)", text):
        value = float(match.group(1))
        if value not in tm.TAILWIND_SIZES:
            found.append(Violation("off-scale-font-size", path, _line_of(text, match.start()), "font size %s is off the Tailwind scale" % match.group(1)))
    if path.endswith(".css"):
        for match in re.finditer(r"font-size:\s*([^;]+);", text):
            if "var(" in match.group(1):
                continue
            for raw, unit in re.findall(r"([0-9.]+)(px|rem)", match.group(1)):
                value = float(raw) * (16 if unit == "rem" else 1)
                if value not in tm.TAILWIND_SIZES:
                    found.append(Violation("off-scale-font-size", path, _line_of(text, match.start()), "CSS font size %s%s is off the Tailwind scale" % (raw, unit)))
    return found


def _is_emoji(char: str) -> bool:
    code = ord(char)
    if 0x0900 <= code <= 0x097F:
        return False
    if 0x30 <= code <= 0x39:
        return False
    if code in (0x20E3, 0x200D, 0x00A9, 0x00AE, 0x2122):
        return False
    ranges = [
        (0x1F000, 0x1FAFF),
        (0x1F1E6, 0x1F1FF),
        (0x2600, 0x27BF),
        (0x2B00, 0x2BFF),
        (0xFE00, 0xFE0F),
        (0x203C, 0x203C),
        (0x2049, 0x2049),
        (0x2139, 0x2139),
        (0x3030, 0x3030),
    ]
    return any(low <= code <= high for low, high in ranges)


def _hover_animation_violations(text: str, path: str) -> list[Violation]:
    found: list[Violation] = []
    if path.endswith(".css"):
        for match in re.finditer(r"([^{}]*:hover[^{}]*)\{([^}]*)\}", text):
            body = match.group(2).lower()
            for banned in ("transition", "transform", "animation", "scale(", "box-shadow"):
                if banned in body:
                    found.append(Violation("hover-animation", path, _line_of(text, match.start(2)), "hover rule contains %s; hover must be an instant static colour swap" % banned))
                    break
    if path.endswith(".dart"):
        for match in re.finditer(r"onHover\s*:", text):
            window = text[match.start() : match.start() + 320]
            if re.search(r"Animated|AnimationController|transition|Tween", window):
                found.append(Violation("hover-animation", path, _line_of(text, match.start()), "hover handler animates a property"))
    return found


def _page_title_violations(text: str, path: str) -> list[Violation]:
    found: list[Violation] = []
    for match in re.finditer(r"<title>([^<]*)</title>", text, re.IGNORECASE):
        title = match.group(1)
        lowered = title.lower()
        if "vite + react" in lowered or "flutter" in lowered or PACKAGE_NAME in lowered:
            found.append(Violation("page-title", path, _line_of(text, match.start()), "page title %r uses a framework, template or package name" % title))
    if path.endswith(".json"):
        for key in ("name", "short_name"):
            for match in re.finditer(r'"%s"\s*:\s*"([^"]*)"' % key, text):
                value = match.group(1)
                lowered = value.lower()
                if "flutter" in lowered or "vite" in lowered or PACKAGE_NAME in lowered:
                    found.append(Violation("page-title", path, _line_of(text, match.start()), "web manifest %s %r uses a framework or package name" % (key, value)))
    return found


def tokens_for_lint() -> tuple[dict, list[int], list[float], list[str]]:
    tokens = tm.load_tokens()
    scale = [float(value) for value in tokens["spacing"]]
    radii = [float(value) for key, value in tokens["radius"].items() if key != "full"]
    allowlist = tokens["lint"]["gradientAllowlist"]
    return tokens, [int(value) for value in scale], radii, allowlist


def lint_file(path: str, text: str) -> list[Violation]:
    _, scale, radii, gradient_allowlist = tokens_for_lint()
    rel = os.path.relpath(path, ROOT).replace("\\", "/")
    generated = rel in GENERATED_ALLOWLIST
    found: list[Violation] = []
    lower = text.lower()

    if not generated:
        boundary = r"(?<![A-Za-z0-9_])"
        for match in re.finditer(
            boundary + r"Color\(0x|" + boundary + r"Color\.fromARGB|" + boundary + r"Colors\.",
            text,
        ):
            found.append(Violation("raw-color", path, _line_of(text, match.start()), "raw colour outside the generated token files"))
        if path.endswith((".css", ".html", ".js")):
            for match in re.finditer(r"#[0-9a-fA-F]{3,8}\b", text):
                found.append(Violation("raw-color", path, _line_of(text, match.start()), "raw hex colour %s outside the generated tokens" % match.group(0)))
        found.extend(_spacing_violations(text, path, scale))
        found.extend(_radius_violations(text, path, radii))
        found.extend(_font_size_violations(text, path))

    for match in re.finditer(r"FontStyle\.italic|font-style:\s*italic|font-style:\s*oblique", text):
        found.append(Violation("italic", path, _line_of(text, match.start()), "italic type is banned"))

    if not any(rel.startswith(allowed) for allowed in gradient_allowlist):
        for match in re.finditer(r"\bLinearGradient\b|\bSweepGradient\b|\bRadialGradient\b|\bShaderMask\b|linear-gradient|radial-gradient|conic-gradient|linearGradient", text):
            found.append(Violation("gradient", path, _line_of(text, match.start()), "gradients are allowed only in the hero heading file"))

    for match in re.finditer(r"BackdropFilter|ImageFilter\.blur|backdrop-filter|MaskFilter\.blur|filter:\s*blur", text):
        found.append(Violation("blur", path, _line_of(text, match.start()), "blur and glass effects are banned"))

    for match in re.finditer(r"Border\(\s*(?:top|bottom|left|right)\s*:|Border(?:Top|Bottom|Left|Right)\(|border-(?:top|bottom|left|right|inline-start|inline-end)\s*:", text):
        found.append(Violation("one-sided-border", path, _line_of(text, match.start()), "borders go all the way around or not at all"))

    for match in re.finditer(r"(?<![A-Za-z0-9_])Icons\.|[Ll]ucide|Material Symbols|material_symbols|cupertino_icons", text):
        found.append(Violation("banned-icon-set", path, _line_of(text, match.start()), "only vendored Phosphor, Solar or Iconamoon icons are allowed"))

    for glyph in AI_GLYPHS:
        for match in re.finditer(re.escape(glyph), lower):
            found.append(Violation("ai-glyph", path, _line_of(text, match.start()), "AI glyph %r is banned" % glyph))

    for font in BANNED_FONTS:
        for match in re.finditer(r"fontFamily:\s*'%s'|fontFamily:\s*\"%s\"|font-family:[^;{}]*\b%s\b" % (re.escape(font), re.escape(font), re.escape(font)), text, re.IGNORECASE):
            found.append(Violation("banned-font", path, _line_of(text, match.start()), "%s is a banned typeface" % font))

    for index, char in enumerate(text):
        if _is_emoji(char):
            found.append(Violation("emoji", path, _line_of(text, index), "emoji %r in shipped copy" % char))
            break

    for match in re.finditer(r"[\u2013\u2014]", text):
        found.append(Violation("dash", path, _line_of(text, match.start()), "em and en dashes are banned in copy"))

    for word in PLACEHOLDERS:
        for match in re.finditer(re.escape(word), lower):
            found.append(Violation("placeholder-copy", path, _line_of(text, match.start()), "placeholder copy %r in a shipped path" % word))

    for match in re.finditer(r"\{\{", text):
        found.append(Violation("unresolved-placeholder", path, _line_of(text, match.start()), "unresolved template placeholder"))

    found.extend(_hover_animation_violations(text, path))

    if path.endswith((".arb", ".json", ".html", ".js", ".yaml", ".yml")):
        for word in PRICING_WORDS:
            for match in re.finditer(r"\b%s\b" % re.escape(word), lower):
                found.append(Violation("banned-word", path, _line_of(text, match.start()), "%r is banned in app and landing copy" % word))

    for word in FILLER_WORDS:
        for match in re.finditer(re.escape(word), lower):
            found.append(Violation("banned-filler", path, _line_of(text, match.start()), "banned filler phrase %r" % word))

    found.extend(_page_title_violations(text, path))
    return found


def iter_source_files(roots: list[str]) -> list[str]:
    files: list[str] = []
    for root in roots:
        absolute = root if os.path.isabs(root) else os.path.join(ROOT, root)
        if not os.path.exists(absolute):
            continue
        for directory, dir_names, file_names in os.walk(absolute):
            dir_names[:] = [name for name in dir_names if name not in SKIP_PARTS]
            for file_name in sorted(file_names):
                if os.path.splitext(file_name)[1] not in TEXT_EXTENSIONS:
                    continue
                files.append(os.path.join(directory, file_name))
    return files


def load_default_hashes() -> set[str]:
    path = os.path.join(ROOT, "tool", "default_asset_hashes.txt")
    hashes: set[str] = set()
    if not os.path.exists(path):
        return hashes
    with open(path, "r", encoding="utf-8") as handle:
        for line in handle:
            parts = line.split()
            if parts:
                hashes.add(parts[0].lower())
    return hashes


def default_asset_violations(paths: list[str], hashes: set[str]) -> list[Violation]:
    found: list[Violation] = []
    if not hashes:
        return found
    for path in paths:
        with open(path, "rb") as handle:
            digest = hashlib.sha256(handle.read()).hexdigest()
        if digest in hashes:
            found.append(Violation("default-asset", path, 1, "file is a recorded default asset; replace it before shipping"))
    return found


def scan(roots: list[str] | None = None, include_default_assets: bool = True) -> list[Violation]:
    violations: list[Violation] = []
    for path in iter_source_files(roots or SCAN_ROOTS):
        with open(path, "r", encoding="utf-8", errors="replace") as handle:
            text = handle.read()
        violations.extend(lint_file(path, text))
    if include_default_assets:
        violations.extend(default_asset_violations(all_repo_files(), load_default_hashes()))
    return violations


def all_repo_files() -> list[str]:
    files: list[str] = []
    for directory, dir_names, file_names in os.walk(ROOT):
        dir_names[:] = [name for name in dir_names if name not in (".git", "build", ".dart_tool", "node_modules", ".freebuff")]
        for file_name in file_names:
            files.append(os.path.join(directory, file_name))
    return files


def main(argv: list[str]) -> int:
    roots = None
    if "--root" in argv:
        roots = [argv[argv.index("--root") + 1]]
    violations = scan(roots, include_default_assets=roots is None)
    if violations:
        for violation in sorted(violations, key=lambda item: (item.path, item.line, item.rule)):
            print(violation.render())
        print("\nDESIGN LINT FAILED with %d violation(s)." % len(violations))
        return 1
    print("DESIGN LINT PASSED: no banned colours, spacing, radii, type, icons, fonts, copy or hover motion.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
