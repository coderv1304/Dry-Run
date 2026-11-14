"""PII detection and redaction used before logging and before LLM calls."""

from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class RedactionResult:
    """Redacted text plus the kinds of PII that were removed."""

    text: str
    found: bool
    kinds: tuple[str, ...]

    @property
    def warning(self) -> bool:
        """Alias used by API responses."""
        return self.found


CARD_CANDIDATE = re.compile(r"(?<!\d)(?:\d[ -]?){12,18}\d(?!\d)")
AADHAAR = re.compile(r"(?<!\d)\d{4}[\s-]?\d{4}[\s-]?\d{4}(?!\d)")
PAN = re.compile(r"\b[A-Z]{5}\d{4}[A-Z]\b")
IFSC = re.compile(r"\b[A-Z]{4}0[A-Z0-9]{6}\b")
UPI = re.compile(r"\b[A-Za-z0-9._-]{2,}@[A-Za-z][A-Za-z.]{1,}\b", re.IGNORECASE)
MOBILE = re.compile(r"(?<!\d)[6-9]\d{9}(?!\d)")
OTP_CONTEXT = re.compile(
    r"(?i)\b(?:otp|one[\s-]?time(?:\s+password)?|verification\s+code)\b[^0-9]{0,20}(\d{4,8})\b"
)
OTP_REVERSE = re.compile(
    r"(?i)\b(\d{4,8})\b[^0-9]{0,20}\b(?:otp|one[\s-]?time(?:\s+password)?|"
    r"(?:verification\s+)?code)\b"
)
ACCOUNT = re.compile(r"(?<!\d)\d{9,18}(?!\d)")


def luhn_valid(digits: str) -> bool:
    """Return whether a digit string passes the Luhn checksum."""
    if not digits.isdigit() or not 13 <= len(digits) <= 19:
        return False
    total = 0
    parity = len(digits) % 2
    for index, char in enumerate(digits):
        value = int(char)
        if index % 2 == parity:
            value *= 2
            if value > 9:
                value -= 9
        total += value
    return total % 10 == 0


def _redact_whole(text: str, pattern: re.Pattern[str], kind: str, kinds: list[str]) -> str:
    """Replace an entire match."""

    def replace(match: re.Match[str]) -> str:
        kinds.append(kind)
        return f"[REDACTED_{kind}]"

    return pattern.sub(replace, text)


def redact(text: str) -> RedactionResult:
    """Remove all supported PII categories from ``text``."""
    kinds: list[str] = []
    result = text

    def card(match: re.Match[str]) -> str:
        digits = re.sub(r"\D", "", match.group(0))
        if luhn_valid(digits):
            kinds.append("CARD")
            return "[REDACTED_CARD]"
        return match.group(0)

    result = CARD_CANDIDATE.sub(card, result)
    result = _redact_whole(result, AADHAAR, "AADHAAR", kinds)
    result = _redact_whole(result, PAN, "PAN", kinds)
    result = _redact_whole(result, IFSC, "IFSC", kinds)
    result = _redact_whole(result, UPI, "UPI", kinds)
    result = _redact_whole(result, MOBILE, "MOBILE", kinds)

    def otp(match: re.Match[str]) -> str:
        kinds.append("OTP")
        return re.sub(r"\d{4,8}", "[REDACTED_OTP]", match.group(0))

    result = OTP_CONTEXT.sub(otp, result)
    result = OTP_REVERSE.sub(otp, result)
    result = _redact_whole(result, ACCOUNT, "ACCOUNT", kinds)
    unique = tuple(dict.fromkeys(kinds))
    return RedactionResult(text=result, found=bool(unique), kinds=unique)


def redact_for_log(value: object) -> str:
    """Return a log-safe string with PII redacted."""
    return redact(str(value)).text


__all__ = ["RedactionResult", "luhn_valid", "redact", "redact_for_log"]
