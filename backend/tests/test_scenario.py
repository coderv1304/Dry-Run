"""Scenario content, fictional-entity, language, and review-catalog tests."""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from app.engine.scenario import DEFAULT_SCENARIO, LANGUAGES, Scenario

ROOT = Path(__file__).resolve().parents[2]
DEVANAGARI = re.compile(r"[\u0900-\u097F]")
LATIN = re.compile(r"[A-Za-z]")
BANNED = re.compile(
    r"(?i)\b(?:CBI|RBI|NIA|ED|enforcement\s+directorate|income\s+tax|crime\s+branch|"
    r"police|SBI|HDFC|ICICI|Axis|Kotak|PNB|Paytm|PhonePe|GPay|1930|"
    r"cybercrime\.gov\.in)\b"
)


@pytest.fixture()
def scenario() -> Scenario:
    return Scenario.load(DEFAULT_SCENARIO, max_turns=12)


def test_scenario_is_fictional_and_complete(scenario: Scenario) -> None:
    assert scenario.data.fictional is True
    assert scenario.stage_ids == ["contact", "accusation", "isolation", "urgency", "transfer"]
    assert scenario.data.languages == list(LANGUAGES)
    assert scenario.data.agency["name"] == "National Digital Safety Cell"
    assert scenario.data.agency["officer"]


def test_every_stage_has_three_language_forms(scenario: Scenario) -> None:
    for stage in scenario.data.stages.values():
        for line in (stage.opening, stage.default):
            for language in LANGUAGES:
                form = line.for_language(language)
                assert form.display.strip()
                assert form.speak.strip()


def test_hindi_and_hinglish_speak_use_devanagari(scenario: Scenario) -> None:
    for stage in scenario.data.stages.values():
        for line in (stage.opening, stage.default):
            assert DEVANAGARI.search(line.hi.display)
            assert DEVANAGARI.search(line.hi.speak)
            assert DEVANAGARI.search(line.hinglish.speak)
            assert LATIN.search(line.hinglish.display)


def test_global_lines_cover_every_purpose(scenario: Scenario) -> None:
    assert set(scenario.data.global_lines) == {
        "verify_deflect",
        "verify_escalate",
        "family_push",
        "hesitation",
        "reframe",
        "pii_warning",
    }
    for line in scenario.data.global_lines.values():
        assert DEVANAGARI.search(line.hinglish.speak)


def test_no_real_agency_bank_or_contact_details() -> None:
    raw = DEFAULT_SCENARIO.read_text(encoding="utf-8")
    assert not BANNED.search(raw), BANNED.search(raw)


def test_line_selection_is_deterministic_and_language_specific(scenario: Scenario) -> None:
    from random import Random

    first = scenario.line_for("contact", 0, "hi", "opening", Random(1))
    second = scenario.line_for("contact", 0, "hi", "opening", Random(2))
    assert first == second
    assert first["language"] == "hi"
    assert DEVANAGARI.search(first["display"])


def test_pii_warning_overrides_purpose(scenario: Scenario) -> None:
    from random import Random

    line = scenario.line_for("transfer", 3, "en", "compliance", Random(1), pii_warning=True)
    assert "never share" in line["display"].lower()


def test_unknown_stage_raises(scenario: Scenario) -> None:
    from random import Random

    with pytest.raises(KeyError):
        scenario.line_for("unknown", 0, "en", "reframe", Random(1))


def test_review_entries_cover_all_hi_and_hinglish_lines(scenario: Scenario) -> None:
    entries = scenario.review_entries()
    languages = {entry["language"] for entry in entries}
    assert languages == {"hi", "hinglish"}
    assert len(entries) % 2 == 0
    for entry in entries:
        assert entry["id"] and entry["display"] and entry["speak"]


def test_review_document_lists_every_scenario_line(scenario: Scenario) -> None:
    review = (ROOT / "docs" / "REVIEW_NEEDED.md").read_text(encoding="utf-8")
    for entry in scenario.review_entries():
        assert entry["display"] in review, entry["id"]
        assert entry["speak"] in review, entry["id"]


def test_review_document_has_no_real_entities() -> None:
    review = (ROOT / "docs" / "REVIEW_NEEDED.md").read_text(encoding="utf-8")
    assert not BANNED.search(review), BANNED.search(review)
