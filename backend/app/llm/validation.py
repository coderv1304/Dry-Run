"""Strict validation for LLM-generated officer lines."""

from __future__ import annotations

import json
import re
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.pii import redact

Language = Literal["en", "hi", "hinglish"]

DEVANAGARI = re.compile(r"[\u0900-\u097F]")
LATIN = re.compile(r"[A-Za-z]")
EMOJI = re.compile(
    "[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF]"
)
MARKDOWN = re.compile(r"[*_`#>\[\]{}]")
URL = re.compile(r"https?://|www\.", re.IGNORECASE)
REAL_ENTITIES = re.compile(
    r"(?i)\b(?:cbi|enforcement\s+directorate|rbi|income\s+tax|nia|police|"
    r"crime\s+branch|sbi|hdfc|icici|axis\s+bank|kotak|pnb|bank\s+of\s+baroda|"
    r"canara|union\s+bank|paytm|phonepe|google\s+pay|gpay|bhim)\b"
)
THREATS = re.compile(
    r"(?i)\b(?:kill|hurt|harm|beat|violence|jail|prison|detain|arrest\s+you|"
    r"your\s+family\s+will|we\s+will\s+arrest)\b"
)
DATA_REQUEST = re.compile(
    r"(?i)\b(?:otp|one[\s-]?time\s+password|card\s+number|cvv|pin|password|"
    r"aadhaar\s+number|account\s+number|ifsc|upi\s+id)\b"
)
SAFE_CONTEXT = re.compile(r"(?i)\b(?:never|do\s+not|don'?t|avoid|not\s+share)\b")


class OfficerOutput(BaseModel):
    """The only shape accepted from the line-writing model."""

    model_config = ConfigDict(extra="forbid")

    display: str = Field(min_length=1, max_length=320)
    speak: str = Field(min_length=1, max_length=320)
    language: str


def _devanagari_ratio(text: str) -> float:
    letters = [char for char in text if DEVANAGARI.match(char) or LATIN.match(char)]
    if not letters:
        return 0.0
    return sum(1 for char in letters if DEVANAGARI.match(char)) / len(letters)


def parse_officer_output(raw: str) -> OfficerOutput | None:
    """Extract and validate the JSON object from a model response."""
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```[a-zA-Z]*\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)
    start, end = cleaned.find("{"), cleaned.rfind("}")
    if start < 0 or end <= start:
        return None
    try:
        return OfficerOutput.model_validate(json.loads(cleaned[start : end + 1]))
    except ValueError:
        return None


def validate_officer_line(line: OfficerOutput, expected_language: Language) -> str | None:
    """Return a rejection reason, or None when the line is safe."""
    if line.language != expected_language:
        return "wrong_language"
    combined = f"{line.display} {line.speak}"
    if len(line.display.strip()) < 8:
        return "too_short"
    if "\n" in combined or "\t" in combined:
        return "control_characters"
    if "\u2014" in combined or "\u2013" in combined:
        return "dash"
    if EMOJI.search(combined):
        return "emoji"
    if MARKDOWN.search(combined):
        return "markdown"
    if URL.search(combined):
        return "url"
    if REAL_ENTITIES.search(combined):
        return "real_entity"
    if THREATS.search(combined):
        return "threat"
    if DATA_REQUEST.search(combined) and not SAFE_CONTEXT.search(combined):
        return "data_request"
    pii = redact(combined)
    if pii.found:
        return "pii"
    if re.search(r"\b\d{10,}\b", combined):
        return "long_number"
    if expected_language == "en":
        if DEVANAGARI.search(combined):
            return "script"
    elif expected_language == "hi":
        if _devanagari_ratio(combined) < 0.45:
            return "script"
    else:
        if _devanagari_ratio(line.speak) < 0.45:
            return "script"
        if _devanagari_ratio(line.display) > 0.35:
            return "script"
    return None


__all__ = ["OfficerOutput", "parse_officer_output", "validate_officer_line"]
