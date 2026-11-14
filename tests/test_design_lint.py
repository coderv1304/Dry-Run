"""Unit tests for the design lint: one deliberately bad fixture per rule."""

import hashlib
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.join(ROOT, "tool"))

import design_lint  # noqa: E402

FIXTURES = os.path.join(ROOT, "tests", "fixtures", "design_lint")

EXPECTED_RULES = {
    "r01_raw_color": "raw-color",
    "r02_off_scale_spacing": "off-scale-spacing",
    "r03_off_scale_radius": "off-scale-radius",
    "r04_off_scale_font_size": "off-scale-font-size",
    "r05_italic": "italic",
    "r06_gradient": "gradient",
    "r07_blur": "blur",
    "r08_one_sided_border": "one-sided-border",
    "r09_banned_icons": "banned-icon-set",
    "r10_ai_glyph": "ai-glyph",
    "r11_banned_font": "banned-font",
    "r12_emoji": "emoji",
    "r13_dash": "dash",
    "r14_placeholder_copy": "placeholder-copy",
    "r15_unresolved_placeholder": "unresolved-placeholder",
    "r16_hover_animation": "hover-animation",
    "r17_banned_word": "banned-word",
    "r18_banned_filler": "banned-filler",
    "r19_page_title": "page-title",
}


def rules_for(directory: str) -> set[str]:
    path = os.path.join(FIXTURES, directory)
    violations = design_lint.scan([path], include_default_assets=False)
    return {violation.rule for violation in violations}


def test_every_rule_has_one_bad_fixture():
    for directory, rule in EXPECTED_RULES.items():
        assert rules_for(directory) == {rule}, "%s should trigger exactly %s" % (directory, rule)


def test_clean_fixtures_pass():
    assert rules_for("clean") == set()


def test_default_asset_rule_flags_a_recorded_hash():
    path = os.path.join(FIXTURES, "r20_default_asset", "bad.png")
    with open(path, "rb") as handle:
        digest = hashlib.sha256(handle.read()).hexdigest()
    violations = design_lint.default_asset_violations([path], {digest})
    assert [violation.rule for violation in violations] == ["default-asset"]
    assert design_lint.default_asset_violations([path], set()) == []


def test_gradient_is_allowed_only_in_the_hero_file():
    hero = os.path.join(ROOT, "app", "lib", "design", "components", "dr_hero_heading.dart")
    other = os.path.join(ROOT, "app", "lib", "design", "components", "dr_button.dart")
    source = "final ShaderMask shader = ShaderMask(shaderCallback: callback);"
    assert design_lint.lint_file(hero, source) == []
    assert {violation.rule for violation in design_lint.lint_file(other, source)} == {"gradient"}


def test_scale_comes_from_the_token_source():
    tokens, scale, radii, _ = design_lint.tokens_for_lint()
    assert scale == [int(value) for value in tokens["spacing"]]
    assert 96.0 in scale and 0.0 in scale
    assert radii == [float(value) for key, value in tokens["radius"].items() if key != "full"]


def test_emoji_rule_ignores_digits_and_devanagari():
    sample = "1 2 3 ४ ५ ६ अ आ इ क्ष हिन्दी"
    assert design_lint._is_emoji("४") is False
    assert design_lint._is_emoji("क") is False
    assert design_lint._is_emoji("7") is False
    assert design_lint._is_emoji("\U0001F680") is True
    path = os.path.join(FIXTURES, "clean", "clean.arb")
    assert design_lint.lint_file(path, '{"title": "%s"}' % sample) == []
