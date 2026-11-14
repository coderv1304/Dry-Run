"""Shared loader, resolver and invariant checks for design/tokens.json."""

from __future__ import annotations

import colorsys
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TOKENS_PATH = os.path.join(ROOT, "design", "tokens.json")

TAILWIND_SIZES = [12, 14, 16, 18, 20, 24, 30, 36, 48, 60, 72, 96, 128]
ALLOWED_WEIGHTS = [400, 500, 600, 700]
RADIUS_KEYS = ["0", "2", "4", "6", "8", "12", "16", "24", "full"]
MOTION_CURVE = "cubic-bezier(0.22, 1, 0.36, 1)"


def load_tokens(path: str = TOKENS_PATH) -> dict:
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def core_hex(tokens: dict, reference: str) -> str:
    palette, shade = reference.split("/")
    core = tokens["color"]["core"]
    if palette not in core:
        raise KeyError("Unknown core palette: %s" % reference)
    if shade not in core[palette]:
        raise KeyError("Unknown core shade: %s" % reference)
    return core[palette][shade]


def resolve(tokens: dict, name: str, mode: str) -> tuple[str, float]:
    """Resolve a semantic token to (hex, alpha)."""
    value = tokens["color"]["semantic"][mode][name]
    if value.startswith("Alpha/"):
        key = value.split("/", 1)[1]
        section = "transparent" if key == "transparent" else "overlay"
        entry = tokens["color"]["alpha"][section]
        if section == "transparent":
            return core_hex(tokens, entry["base"]), float(entry["opacity"])
        slug = key.split("-", 1)[1] if key.startswith("overlay-") else key
        entry = entry[slug]
        return core_hex(tokens, entry["base"]), float(entry["opacity"])
    return core_hex(tokens, value), 1.0


def to_rgb(hex_value: str) -> tuple[int, int, int]:
    raw = hex_value.lstrip("#")
    if len(raw) != 6:
        raise ValueError("Colour must be #RRGGBB: %s" % hex_value)
    return int(raw[0:2], 16), int(raw[2:4], 16), int(raw[4:6], 16)


def _channel(value: int) -> float:
    channel = value / 255.0
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def luminance(hex_value: str) -> float:
    red, green, blue = to_rgb(hex_value)
    return 0.2126 * _channel(red) + 0.7152 * _channel(green) + 0.0722 * _channel(blue)


def composite(foreground: str, alpha: float, background: str) -> str:
    if alpha >= 0.999:
        return foreground
    fr, fg, fb = to_rgb(foreground)
    br, bg, bb = to_rgb(background)
    mixed = (
        round(fr * alpha + br * (1 - alpha)),
        round(fg * alpha + bg * (1 - alpha)),
        round(fb * alpha + bb * (1 - alpha)),
    )
    return "#%02X%02X%02X" % mixed


def contrast_ratio(foreground: str, background: str) -> float:
    light = max(luminance(foreground), luminance(background))
    dark = min(luminance(foreground), luminance(background))
    return (light + 0.05) / (dark + 0.05)


def hue_saturation(hex_value: str) -> tuple[float, float]:
    red, green, blue = (channel / 255.0 for channel in to_rgb(hex_value))
    hue, saturation, _ = colorsys.rgb_to_hsv(red, green, blue)
    return hue * 360.0, saturation * 100.0


def snap_spacing(spacing: list[int], value: float) -> int:
    """Nearest spacing token; ties resolve to the larger token."""
    best = spacing[0]
    best_delta = abs(value - best)
    for token in spacing:
        delta = abs(value - token)
        if delta < best_delta or (delta == best_delta and token > best):
            best = token
            best_delta = delta
    return best


def snap_radius_down(tokens: dict, value: float) -> float:
    """Largest radius token not greater than value."""
    options = [float(entry) for key, entry in tokens["radius"].items() if key != "full"]
    best = 0.0
    for option in options:
        if option <= value + 1e-9:
            best = max(best, option)
    return best


def nested_radius(tokens: dict, outer: float, gap: float) -> float:
    rule = tokens["radiusRule"]
    if gap >= rule["maxGapExclusive"]:
        return outer
    inner = outer - gap
    if inner <= rule["minInnerExclusive"]:
        return 0.0
    return snap_radius_down(tokens, inner)


def style_key(entry: dict) -> str:
    group = entry["group"]
    rest = entry["name"].split("/", 1)[1]
    if rest.startswith(group):
        rest = rest[len(group):].strip()
    parts = re.split(r"[^A-Za-z0-9]+", (group + "-" + rest).strip("-"))
    camel = parts[0].lower() + "".join(part[:1].upper() + part[1:] for part in parts[1:])
    return camel


def style_css_key(entry: dict) -> str:
    group = entry["group"]
    rest = entry["name"].split("/", 1)[1]
    if rest.startswith(group):
        rest = rest[len(group):].strip()
    slug = re.sub(r"[^a-z0-9]+", "-", (group + "-" + rest).lower()).strip("-")
    return slug


def token_member(name: str) -> str:
    parts = re.split(r"[^A-Za-z0-9]+", name)
    return parts[0].lower() + "".join(part[:1].upper() + part[1:] for part in parts[1:])


def token_css_name(name: str) -> str:
    return "--color-" + re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def validate(tokens: dict) -> list[str]:
    """Return a list of invariant violations. Empty means the source is sound."""
    errors: list[str] = []

    spacing = tokens["spacing"]
    if spacing[0] != 0 or spacing[-1] != 96:
        errors.append("spacing must run from 0 to 96, got %s..%s" % (spacing[0], spacing[-1]))
    if spacing != sorted(set(spacing)):
        errors.append("spacing must be strictly increasing with no duplicates")
    if any(value % 2 != 0 for value in spacing):
        errors.append("spacing values must be even numbers")

    if sorted(tokens["radius"].keys(), key=lambda key: tokens["radius"][key]) != RADIUS_KEYS:
        errors.append("radius keys must be exactly %s" % ", ".join(RADIUS_KEYS))

    typography = tokens["typography"]
    if typography["fontFamily"] != "Poppins":
        errors.append("the only typeface is Poppins")
    if typography["fontFallback"] != ["Noto Sans Devanagari"]:
        errors.append("Noto Sans Devanagari is the only documented glyph fallback")
    if typography["weights"] != ALLOWED_WEIGHTS:
        errors.append("weights must be 400, 500, 600 and 700 only")
    if typography["letterSpacing"] != 0:
        errors.append("letter spacing is 0")
    for entry in typography["styles"]:
        if entry["size"] not in TAILWIND_SIZES:
            errors.append("%s is off the Tailwind type scale (%s)" % (entry["name"], entry["size"]))
        if entry["weight"] not in ALLOWED_WEIGHTS:
            errors.append("%s uses a banned weight (%s)" % (entry["name"], entry["weight"]))
        for key, value in entry.items():
            if isinstance(value, str) and "italic" in value.lower():
                errors.append("%s declares an italic style" % entry["name"])
        expected = snap_spacing(spacing, round(entry["lineHeight"] * typography["devanagari"]["lineHeightMultiplier"]))
        if entry["devanagariLineHeight"] != expected:
            errors.append(
                "%s devanagari line height is %s, the documented rule yields %s"
                % (entry["name"], entry["devanagariLineHeight"], expected)
            )
        if entry["devanagariLineHeight"] < entry["lineHeight"]:
            errors.append("%s devanagari line height must be looser than the latin value" % entry["name"])

    motion = tokens["motion"]
    if motion["curve"] != MOTION_CURVE:
        errors.append("motion curve must be %s" % MOTION_CURVE)
    if motion["curvePoints"] != [0.22, 1.0, 0.36, 1.0]:
        errors.append("motion curve points must be 0.22, 1, 0.36, 1")
    if motion["durationLayout"] != 500 or motion["durationColor"] != 300:
        errors.append("layout motion is 500 ms and colour motion is 300 ms")
    if motion["durationMinimum"] < 200:
        errors.append("no motion token may be shorter than 200 ms")
    if motion["durationPress"] < motion["durationMinimum"]:
        errors.append("press feedback must respect the 200 ms floor")

    if tokens["touch"]["minimum"] < 44:
        errors.append("minimum touch target is 44")
    if tokens["touch"]["elder"] < 56:
        errors.append("elder touch target is 56")

    core = tokens["color"]["core"]
    for palette, shades in core.items():
        if len(shades) < 10:
            errors.append("core palette %s has fewer than 10 shades" % palette)

    light = tokens["color"]["semantic"]["light"]
    dark = tokens["color"]["semantic"]["dark"]
    if set(light.keys()) != set(dark.keys()):
        errors.append("light and dark semantics must expose the same tokens")
    for mode, semantic in (("light", light), ("dark", dark)):
        for name in semantic:
            try:
                resolve(tokens, name, mode)
            except KeyError as error:
                errors.append("%s/%s does not resolve: %s" % (mode, name, error))

    allowlist = [value.upper() for value in tokens["color"]["darkSurfaceAllowlist"]]
    for name, value in dark.items():
        if not (name.startswith("Surface/") or name.startswith("Action/Tertiary")):
            continue
        resolved, alpha = resolve(tokens, name, "dark")
        if name == "Surface/Transparent":
            continue
        if alpha < 0.999:
            errors.append("%s must be an opaque surface" % name)
        elif resolved.upper() not in allowlist:
            errors.append("%s resolves to %s, outside the dark background allowlist" % (name, resolved))

    for palette in tokens["accent"]["palettes"]:
        hue, saturation = hue_saturation(core[palette]["500"])
        if not tokens["accent"]["minHue"] <= hue <= tokens["accent"]["maxHue"]:
            errors.append("%s/500 hue %0.1f is outside %s..%s" % (palette, hue, tokens["accent"]["minHue"], tokens["accent"]["maxHue"]))
        if saturation >= tokens["accent"]["maxSaturation"]:
            errors.append("%s/500 saturation %0.1f must stay under %s" % (palette, saturation, tokens["accent"]["maxSaturation"]))

    gradients = tokens["color"]["gradients"]
    if sorted(gradients.keys()) != ["heroDark", "heroLight"]:
        errors.append("the hero heading gradient is the only gradient in the system")
    for name, gradient in gradients.items():
        if len(gradient["stops"]) != 2:
            errors.append("%s must have exactly two stops" % name)

    return errors
