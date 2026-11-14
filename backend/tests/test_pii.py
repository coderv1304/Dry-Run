"""PII detection, Luhn validation, and redaction tests."""

from __future__ import annotations

import pytest

from app.pii import luhn_valid, redact, redact_for_log


def _text(result) -> str:
    return result.text


def test_luhn_accepts_valid_test_card() -> None:
    assert luhn_valid("4111111111111111")
    assert luhn_valid("4242 4242 4242 4242".replace(" ", ""))


@pytest.mark.parametrize("value", ["4111111111111112", "", "abc", "1234"])
def test_luhn_rejects_invalid(value: str) -> None:
    assert not luhn_valid(value)


def test_card_is_redacted_only_when_luhn_passes() -> None:
    valid = redact("my card is 4111 1111 1111 1111 okay")
    assert valid.found
    assert "CARD" in valid.kinds
    assert "4111" not in valid.text
    assert "[REDACTED_CARD]" in valid.text

    invalid = redact("reference 4111 1111 1111 1112 stored")
    assert "CARD" not in invalid.kinds


def test_aadhaar_is_redacted() -> None:
    result = redact("aadhaar 1234 5678 9012")
    assert "AADHAAR" in result.kinds
    assert "1234" not in result.text


def test_pan_ifsc_upi_and_mobile_are_redacted() -> None:
    text = "PAN ABCDE1234F IFSC HDFC0001234 UPI person@okbank phone 9876543210"
    result = redact(text)
    for kind in ("PAN", "IFSC", "UPI", "MOBILE"):
        assert kind in result.kinds
    assert "ABCDE1234F" not in result.text
    assert "HDFC0001234" not in result.text
    assert "person@okbank" not in result.text
    assert "9876543210" not in result.text


def test_otp_with_context_is_redacted() -> None:
    result = redact("My OTP is 482913")
    assert "OTP" in result.kinds
    assert "482913" not in result.text
    assert "[REDACTED_OTP]" in result.text


def test_otp_before_context_word_is_redacted() -> None:
    result = redact("482913 is the verification code")
    assert "OTP" in result.kinds
    assert "482913" not in result.text


def test_account_number_is_redacted() -> None:
    result = redact("account 12345678901")
    assert "ACCOUNT" in result.kinds
    assert "12345678901" not in result.text


def test_named_entities_are_redacted_after_other_rules() -> None:
    result = redact("ABCDE1234F and HDFC0001234")
    assert set(result.kinds) >= {"PAN", "IFSC"}


def test_plain_text_is_untouched() -> None:
    result = redact("I will hang up now")
    assert result.found is False
    assert result.text == "I will hang up now"
    assert result.kinds == ()


def test_multiple_kinds_are_deduplicated() -> None:
    result = redact("OTP 123456 and another OTP 654321")
    assert result.kinds.count("OTP") == 1


def test_log_helper_redacts() -> None:
    assert "482913" not in redact_for_log({"otp": "OTP 482913"})
