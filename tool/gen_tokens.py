#!/usr/bin/env python3
"""Generate Flutter design tokens and landing CSS from design/tokens.json.

Usage:
    python tool/gen_tokens.py           # write generated artefacts
    python tool/gen_tokens.py --check   # verify on-disk artefacts are current
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import token_model as tm

DART_HEADER = """// GENERATED FILE - DO NOT EDIT.
// Source: design/tokens.json
// Regenerate: python tool/gen_tokens.py
// Re-running the generator is byte for byte idempotent.

"""

CSS_HEADER = """/* GENERATED FILE - DO NOT EDIT.
   Source: design/tokens.json
   Regenerate: python tool/gen_tokens.py */

"""


def dart_color(hex_value: str, alpha: float) -> str:
    red, green, blue = tm.to_rgb(hex_value)
    return "Color(0x%02X%02X%02X%02X)" % (round(alpha * 255), red, green, blue)


def css_color(hex_value: str, alpha: float) -> str:
    if alpha >= 0.999:
        return hex_value.upper()
    red, green, blue = tm.to_rgb(hex_value)
    return "rgba(%d, %d, %d, %s)" % (red, green, blue, ("%g" % alpha))


def render_colors(tokens: dict) -> str:
    out = [DART_HEADER, "import 'dart:ui';\n\n"]
    out.append("/// Raw palette layer. Never used directly by components.\n")
    out.append("abstract final class DrCore {\n")
    hex_to_member: dict[str, str] = {}
    for palette, shades in tokens["color"]["core"].items():
        out.append("  // %s\n" % palette)
        for shade, value in shades.items():
            member = tm.token_member("%s-%s" % (palette, shade))
            hex_to_member.setdefault(value.upper(), "DrCore.%s" % member)
            out.append("  static const Color %s = %s;\n" % (member, dart_color(value, 1.0)))
        out.append("\n")
    out.pop()
    out.append("\n  static const Map<String, Map<String, Color>> palettes = "
               "<String, Map<String, Color>>{\n")
    for palette, shades in tokens["color"]["core"].items():
        entries = ", ".join(
            "'%s': DrCore.%s" % (shade, tm.token_member("%s-%s" % (palette, shade)))
            for shade in shades
        )
        out.append("    '%s': <String, Color>{%s},\n" % (palette, entries))
    out.append("  };\n}\n\n")

    names = sorted(tokens["color"]["semantic"]["light"].keys())

    out.append("/// Semantic layer. Components bind to these roles only.\n")
    out.append("final class DrColors {\n")
    out.append("  const DrColors({\n")
    for name in names:
        out.append("    required this.%s,\n" % tm.token_member(name))
    out.append("  });\n\n")
    for name in names:
        out.append("  final Color %s;\n" % tm.token_member(name))

    for mode in ("light", "dark"):
        out.append("\n  static const DrColors %s = DrColors(\n" % mode)
        for name in names:
            hex_value, alpha = tm.resolve(tokens, name, mode)
            literal = hex_to_member.get(hex_value.upper()) if alpha >= 0.999 else None
            out.append("    %s: %s,\n" % (tm.token_member(name), literal or dart_color(hex_value, alpha)))
        out.append("  );\n")

    for mode in ("light", "dark"):
        out.append("\n  static const Map<String, Color> %sByName = <String, Color>{\n" % mode)
        for name in names:
            hex_value, alpha = tm.resolve(tokens, name, mode)
            out.append("    '%s': %s,\n" % (name, dart_color(hex_value, alpha)))
        out.append("  };\n")

    out.append("}\n\n")

    out.append("/// The single gradient exception: hero heading text only.\n")
    out.append("abstract final class DrGradients {\n")
    for key, gradient in tokens["color"]["gradients"].items():
        stops = ", ".join(dart_color(stop, 1.0) for stop in gradient["stops"])
        out.append("  static const List<Color> %s = <Color>[%s];\n" % (key, stops))
    out.append("}\n")
    return "".join(out)


def render_space(tokens: dict) -> str:
    out = [DART_HEADER, "import 'package:flutter/animation.dart';\n\n"]

    out.append("/// Spacing scale, 0 to 96.\n")
    out.append("abstract final class DrSpace {\n")
    for value in tokens["spacing"]:
        out.append("  static const double s%s = %s;\n" % (value, float(value)))
    out.append("\n  static const List<double> scale = <double>[%s];\n" % ", ".join(str(float(v)) for v in tokens["spacing"]))
    out.append("}\n\n")

    radius = tokens["radius"]
    rule = tokens["radiusRule"]
    numeric = [value for key, value in radius.items() if key != "full"]
    out.append("/// Corner radius scale plus the nested radius rule.\n")
    out.append("abstract final class DrRadius {\n")
    for key, value in radius.items():
        name = "full" if key == "full" else "r%s" % key
        out.append("  static const double %s = %s;\n" % (name, float(value)))
    out.append("\n  static const List<double> scale = <double>[%s];\n" % ", ".join(str(float(v)) for v in numeric))
    out.append("  static const double _maxGap = %s;\n" % float(rule["maxGapExclusive"]))
    out.append("  static const double _minInner = %s;\n" % float(rule["minInnerExclusive"]))
    out.append(
        "\n  /// inner = outer - gap, snapped down to a radius token; square when the\n"
        "  /// gap is 32 or wider, or when the result is not above 2.\n"
        "  static double nested(double outer, double gap) {\n"
        "    if (gap >= _maxGap) {\n"
        "      return outer;\n"
        "    }\n"
        "    final double inner = outer - gap;\n"
        "    if (inner <= _minInner) {\n"
        "      return 0;\n"
        "    }\n"
        "    double best = 0;\n"
        "    for (final double option in scale) {\n"
        "      if (option <= inner && option > best) {\n"
        "        best = option;\n"
        "      }\n"
        "    }\n"
        "    return best;\n"
        "  }\n"
    )
    out.append("}\n\n")

    out.append("/// Fixed component sizes from the token source.\n")
    out.append("abstract final class DrSize {\n")
    for key, value in tokens["size"].items():
        out.append("  static const double %s = %s;\n" % (key, float(value)))
    out.append("}\n\n")

    out.append("/// Touch targets. Elder facing screens use [elder].\n")
    out.append("abstract final class DrTouch {\n")
    out.append("  static const double minimum = %s;\n" % float(tokens["touch"]["minimum"]))
    out.append("  static const double elder = %s;\n" % float(tokens["touch"]["elder"]))
    out.append("}\n\n")

    motion = tokens["motion"]
    points = ", ".join(str(float(point)) for point in motion["curvePoints"])
    out.append("/// Motion. No duration may sit below [minimum].\n")
    out.append("abstract final class DrMotion {\n")
    out.append("  static const Cubic curve = Cubic(%s);\n" % points)
    out.append("  static const String curveCss = '%s';\n" % motion["curve"])
    out.append("  static const Duration layout = Duration(milliseconds: %d);\n" % motion["durationLayout"])
    out.append("  static const Duration color = Duration(milliseconds: %d);\n" % motion["durationColor"])
    out.append("  static const Duration minimum = Duration(milliseconds: %d);\n" % motion["durationMinimum"])
    out.append("  static const Duration press = Duration(milliseconds: %d);\n" % motion["durationPress"])
    out.append("  static const double pressScale = %s;\n" % float(motion["pressScale"]))
    out.append("}\n")
    return "".join(out)


def _text_style(tokens: dict, entry: dict, line_height: int) -> str:
    height = line_height / float(entry["size"])
    return (
        "TextStyle(fontFamily: DrTypeTheme.fontFamily, fontFamilyFallback: DrTypeTheme.fontFamilyFallback, "
        "fontSize: %s, height: %s, fontWeight: FontWeight.w%d, letterSpacing: %s)"
        % (float(entry["size"]), ("%.4f" % height).rstrip("0").rstrip("."), entry["weight"], float(0))
    )


def render_type(tokens: dict) -> str:
    typography = tokens["typography"]
    styles = typography["styles"]
    out = [DART_HEADER, "import 'package:flutter/material.dart';\n\n"]
    out.append("/// The named text styles, in latin and Devanagari leading variants.\n")
    out.append("final class DrTypeTheme extends ThemeExtension<DrTypeTheme> {\n")
    out.append("  const DrTypeTheme(this.styles);\n\n")
    out.append("  final Map<String, TextStyle> styles;\n\n")
    out.append("  static const String fontFamily = '%s';\n" % typography["fontFamily"])
    out.append("  static const List<String> fontFamilyFallback = <String>[%s];\n\n" % ", ".join("'%s'" % name for name in typography["fontFallback"]))

    for entry in styles:
        out.append("  TextStyle get %s => styles['%s']!;\n" % (tm.style_key(entry), tm.style_css_key(entry)))
    out.append("\n")

    for variant, field in (("latin", "lineHeight"), ("devanagari", "devanagariLineHeight")):
        out.append("  static const DrTypeTheme %s = DrTypeTheme(<String, TextStyle>{\n" % variant)
        for entry in styles:
            out.append("    '%s': %s,\n" % (tm.style_css_key(entry), _text_style(tokens, entry, entry[field])))
        out.append("  });\n\n")

    out.append("  @override\n  DrTypeTheme copyWith({Map<String, TextStyle>? styles}) => DrTypeTheme(styles ?? this.styles);\n\n")
    out.append(
        "  @override\n"
        "  DrTypeTheme lerp(ThemeExtension<DrTypeTheme>? other, double t) {\n"
        "    if (other is! DrTypeTheme) {\n"
        "      return this;\n"
        "    }\n"
        "    return DrTypeTheme(<String, TextStyle>{\n"
        "      for (final String key in styles.keys)\n"
        "        key: TextStyle.lerp(styles[key], other.styles[key], t) ?? styles[key]!,\n"
        "    });\n"
        "  }\n"
    )
    out.append("}\n")
    return "".join(out)


def render_css(tokens: dict) -> str:
    typography = tokens["typography"]
    motion = tokens["motion"]
    out = [CSS_HEADER]

    out.append(":root {\n")
    out.append("  --font-primary: '%s';\n" % typography["fontFamily"])
    out.append("  --font-fallback: '%s';\n\n" % typography["fontFallback"][0])
    for value in tokens["spacing"]:
        out.append("  --space-%s: %spx;\n" % (value, value))
    out.append("\n")
    for key, value in tokens["radius"].items():
        out.append("  --radius-%s: %spx;\n" % (key, value))
    out.append("\n")
    for entry in typography["styles"]:
        slug = tm.style_css_key(entry)
        out.append("  --text-%s-size: %spx;\n" % (slug, entry["size"]))
        out.append("  --text-%s-line: %spx;\n" % (slug, entry["lineHeight"]))
        out.append("  --text-%s-weight: %d;\n" % (slug, entry["weight"]))
    out.append("\n  --ease-base: %s;\n" % motion["curve"])
    out.append("  --duration-layout: %dms;\n" % motion["durationLayout"])
    out.append("  --duration-color: %dms;\n" % motion["durationColor"])
    out.append("  --duration-minimum: %dms;\n" % motion["durationMinimum"])
    out.append("  --touch-minimum: %dpx;\n" % tokens["touch"]["minimum"])
    out.append("  --touch-elder: %dpx;\n" % tokens["touch"]["elder"])
    out.append("  --content-max: %dpx;\n" % tokens["size"]["contentMax"])
    out.append("  --container-max: %dpx;\n\n" % tokens["size"]["containerMax"])

    for palette, shades in tokens["color"]["core"].items():
        for shade, value in shades.items():
            out.append("  --core-%s-%s: %s;\n" % (palette.lower(), shade, value.upper()))
    out.append("\n")
    for key, gradient in tokens["color"]["gradients"].items():
        suffix = "light" if key.endswith("Light") else "dark"
        out.append("  --gradient-hero-%s-from: %s;\n" % (suffix, gradient["stops"][0].upper()))
        out.append("  --gradient-hero-%s-to: %s;\n" % (suffix, gradient["stops"][1].upper()))
    out.append("\n")

    for name in tokens["color"]["semantic"]["light"]:
        hex_value, alpha = tm.resolve(tokens, name, "light")
        out.append("  %s: %s;\n" % (tm.token_css_name(name), css_color(hex_value, alpha)))
    out.append("}\n\n")

    def color_block(selector: str, mode: str) -> str:
        lines = ["%s {\n" % selector]
        for name in tokens["color"]["semantic"][mode]:
            hex_value, alpha = tm.resolve(tokens, name, mode)
            lines.append("  %s: %s;\n" % (tm.token_css_name(name), css_color(hex_value, alpha)))
        lines.append("}\n\n")
        return "".join(lines)

    out.append("@media (prefers-color-scheme: dark) {\n  :root {\n")
    for name in tokens["color"]["semantic"]["dark"]:
        out.append("    %s: %s;\n" % (tm.token_css_name(name), css_color(*tm.resolve(tokens, name, "dark"))))
    out.append("  }\n}\n\n")
    out.append(color_block('[data-theme="dark"]', "dark"))
    out.append(color_block('[data-theme="light"]', "light"))

    for weight, file_name in ((400, "400"), (500, "500"), (600, "600"), (700, "700")):
        out.append(
            "@font-face {\n"
            "  font-family: '%s';\n"
            "  font-style: normal;\n"
            "  font-weight: %d;\n"
            "  font-display: swap;\n"
            "  src: url('fonts/poppins-latin-%s.woff2') format('woff2');\n"
            "}\n\n" % (typography["fontFamily"], weight, file_name)
        )

    for entry in typography["styles"]:
        slug = tm.style_css_key(entry)
        out.append(
            ".%s {\n"
            "  font-family: var(--font-primary), var(--font-fallback);\n"
            "  font-size: var(--text-%s-size);\n"
            "  line-height: var(--text-%s-line);\n"
            "  font-weight: var(--text-%s-weight);\n"
            "  letter-spacing: %spx;\n"
            "}\n\n" % (slug, slug, slug, slug, typography["letterSpacing"])
        )
    return "".join(out)


def build() -> dict[str, str]:
    tokens = tm.load_tokens()
    errors = tm.validate(tokens)
    if errors:
        raise SystemExit("Token invariants failed:\n  - " + "\n  - ".join(errors))
    return {
        os.path.join(tm.ROOT, "app", "lib", "design", "color_tokens.g.dart"): render_colors(tokens),
        os.path.join(tm.ROOT, "app", "lib", "design", "space_tokens.g.dart"): render_space(tokens),
        os.path.join(tm.ROOT, "app", "lib", "design", "type_tokens.g.dart"): render_type(tokens),
        os.path.join(tm.ROOT, "landing", "tokens.css"): render_css(tokens),
    }


def main(argv: list[str]) -> int:
    outputs = build()
    check_only = "--check" in argv
    stale: list[str] = []
    for path, content in outputs.items():
        current = None
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8", newline="") as handle:
                current = handle.read()
        if check_only:
            if current != content:
                stale.append(path)
        else:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8", newline="\n") as handle:
                handle.write(content)
            print("wrote %s" % os.path.relpath(path, tm.ROOT))
    if check_only:
        if stale:
            print("Generated artefacts are stale. Run python tool/gen_tokens.py:")
            for path in stale:
                print("  %s" % os.path.relpath(path, tm.ROOT))
            return 1
        print("Token generation is reproducible: every generated file is current.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
