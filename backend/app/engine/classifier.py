"""Deterministic, dependency-free participant classifier.

The classifier runs on normalised text and returns at most one label.  It is
deliberately conservative: ties and unmatched input are neutral.  Its known
limits are documented in ``docs/CLASSIFIER_LIMITS.md``.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass

from app.engine.patterns import COMPLIANCE_LABELS, NEGATION_RE, PATTERNS
from app.engine.types import Label

_COMPILED: dict[Label, tuple[re.Pattern[str], ...]] = {
    label: tuple(re.compile(pattern, re.IGNORECASE) for pattern in patterns)
    for label, patterns in PATTERNS.items()
}
_NEGATION = re.compile(NEGATION_RE, re.IGNORECASE)


@dataclass(frozen=True, slots=True)
class Classification:
    """One deterministic classification result with a verbatim quote."""

    label: Label | None
    confidence: float
    quote: str | None = None
    start: int | None = None
    end: int | None = None

    @property
    def is_neutral(self) -> bool:
        """Return whether the input was ambiguous or unmatched."""
        return self.label is None


def normalise(text: str) -> str:
    """NFKC-normalise and collapse whitespace without losing word order."""
    return " ".join(unicodedata.normalize("NFKC", text).split())


def _first_match(text: str, label: Label) -> re.Match[str] | None:
    """Return the earliest match for a label."""
    matches = [match for pattern in _COMPILED[label] if (match := pattern.search(text))]
    return min(matches, key=lambda match: match.start()) if matches else None


def _locate(quote: str, original: str) -> tuple[str, int, int] | None:
    """Locate a verbatim quote in the original text, case-insensitively."""
    index = original.casefold().find(quote.casefold())
    if index < 0:
        return None
    return original[index : index + len(quote)], index, index + len(quote)


def classify(text: str, language: str = "auto") -> Classification:
    """Classify participant text into P1-P4, C1-C4, or neutral.

    ``language`` is accepted for call-site symmetry but does not change the
    rules; all three supported languages share one pattern table.
    """
    del language
    raw = text
    original = normalise(text)
    if not original:
        return Classification(None, 0.5)

    scores: dict[Label, int] = {}
    matches: dict[Label, re.Match[str]] = {}
    for label in PATTERNS:
        found = [match for pattern in _COMPILED[label] if (match := pattern.search(original))]
        if found:
            scores[label] = len(found)
            matches[label] = min(found, key=lambda match: match.start())

    if not scores:
        return Classification(None, 0.5)

    ranked = sorted(scores.items(), key=lambda item: (-item[1], item[0].value))
    top_label, top_score = ranked[0]

    if top_label in COMPLIANCE_LABELS:
        match = matches[top_label]
        prefix = original[max(0, match.start() - 35) : match.start()]
        suffix = original[match.end() : min(len(original), match.end() + 22)]
        negated = bool(_NEGATION.search(prefix)) or (
            top_label is Label.C1 and bool(_NEGATION.search(suffix))
        )
        if negated:
            located = _locate(match.group(0), raw)
            label = Label.P1
            if located:
                return Classification(label, 0.86, *located)
            return Classification(label, 0.86)

    if len(ranked) > 1 and ranked[1][1] == top_score:
        return Classification(None, 0.5)

    located = _locate(matches[top_label].group(0), raw)
    confidence = min(0.95, 0.55 + 0.1 * min(top_score, 4))
    if located:
        return Classification(top_label, confidence, *located)
    return Classification(top_label, confidence)


__all__ = ["Classification", "classify", "normalise"]
