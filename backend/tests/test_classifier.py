"""Classifier fixture, normalisation, negation, and confidence tests."""

from __future__ import annotations

from pathlib import Path

import pytest
import yaml

from app.engine.classifier import Classification, classify, normalise
from app.engine.types import Label

FIXTURES = Path(__file__).resolve().parents[2] / "tests" / "fixtures"
LABELS = [label.value for label in Label]


def _fixture(language: str) -> dict:
    return yaml.safe_load((FIXTURES / f"utterances_{language}.yaml").read_text(encoding="utf-8"))


@pytest.mark.parametrize("language", ["en", "hi", "hinglish"])
def test_fixture_shape_and_review_flag(language: str) -> None:
    data = _fixture(language)
    assert data["meta"]["synthetic"] is True
    assert data["meta"]["human_review"] == "pending"
    assert "never cite" in data["meta"]["warning"].lower()
    for label in LABELS:
        items = data["utterances"][label]
        assert len(items) >= 30, label
        assert len({item["id"] for item in items}) == len(items)
        for item in items:
            assert item["text"].strip()
            assert item["id"].startswith(language)


@pytest.mark.parametrize("language", ["en", "hi", "hinglish"])
def test_fixtures_classify_as_labelled(language: str) -> None:
    data = _fixture(language)
    for expected, items in data["utterances"].items():
        for item in items:
            result = classify(item["text"], language)
            if expected == "neutral":
                assert result.label is None, (language, item["id"], result)
            else:
                assert result.label is Label(expected), (language, item["id"], result)


def test_normalise_applies_nfkc_and_collapses_whitespace() -> None:
    assert normalise("  I\u00a0will\t\r\n hang  up  ") == "I will hang up"
    assert normalise("ＡＢＣ") == "ABC"


def test_empty_text_is_neutral_unknown_confidence() -> None:
    result = classify("   \n\t ")
    assert result == Classification(None, 0.5)


def test_independent_words_score_and_raise_confidence() -> None:
    weak = classify("badge")
    strong = classify("badge and identity card and verify")
    assert weak.label is Label.P2
    assert strong.label is Label.P2
    assert strong.confidence > weak.confidence


def test_negated_compliance_becomes_refusal() -> None:
    result = classify("I will not share my OTP")
    assert result.label is Label.P1
    assert result.confidence >= 0.8


def test_negation_in_hindi_and_hinglish() -> None:
    assert classify("मैं ओटीपी नहीं दूंगा").label is Label.P1
    assert classify("main otp nahi bhejunga").label is Label.P1


def test_unmatched_text_is_neutral() -> None:
    assert classify("the weather is pleasant today").label is None


def test_quote_offsets_are_verbatim_in_original_text() -> None:
    text = "  Please  STOP calling me right now!"
    result = classify(text)
    assert result.quote is not None
    assert result.start is not None and result.end is not None
    assert text[result.start : result.end] == result.quote


def test_tie_is_neutral() -> None:
    assert classify("family scam").label is None


def test_language_argument_does_not_change_rules() -> None:
    text = "I want to verify your badge"
    assert classify(text, "en") == classify(text, "hi") == classify(text, "hinglish")


def test_deterministic() -> None:
    for _ in range(3):
        assert classify("This is a scam") == classify("This is a scam")


def test_every_label_has_patterns() -> None:
    from app.engine.patterns import PATTERNS

    assert set(PATTERNS) == set(Label)
    for patterns in PATTERNS.values():
        assert patterns
