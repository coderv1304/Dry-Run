"""LLM line-writer tiers, validation rules, budget, and safety tests."""

from __future__ import annotations

import asyncio
import json
from dataclasses import replace
from pathlib import Path

import pytest

from app.config import Settings
from app.database import Database
from app.engine.scenario import Scenario
from app.llm.base_types import LlmResult
from app.llm.budget import BudgetTracker
from app.llm.line_writer import LineContext, LineWriter
from app.llm.validation import (
    OfficerOutput,
    parse_officer_output,
    validate_officer_line,
)

SCENARIO = Scenario.load(
    Path(__file__).resolve().parents[1] / "app" / "scenarios" / "digital_arrest.yaml",
    max_turns=12,
)


class FakeProvider:
    """Deterministic provider that returns queued responses or raises."""

    def __init__(self, responses: list[object]) -> None:
        self.responses = responses
        self.calls: list[dict[str, object]] = []

    async def complete(self, **kwargs):
        self.calls.append(kwargs)
        response = self.responses.pop(0)
        if isinstance(response, Exception):
            raise response
        return LlmResult(text=str(response), input_tokens=10, output_tokens=5)


class StubBudget:
    """Minimal budget double for writer tests."""

    def __init__(self, available: bool = True) -> None:
        self.is_available = available
        self.records: list[tuple[int, int]] = []

    def available(self) -> bool:
        return self.is_available

    def record(self, input_tokens: int, output_tokens: int) -> float:
        self.records.append((input_tokens, output_tokens))
        return 0.0


def _context(language: str = "en", messages: tuple[str, ...] = ("hello",)) -> LineContext:
    return LineContext(
        stage="accusation",
        pressure=1,
        language=language,  # type: ignore[arg-type]
        purpose="reframe",
        messages=messages,
        pii_warning=False,
        seed=7,
    )


def _line(**overrides: str) -> OfficerOutput:
    payload = {
        "display": "Please stay on this line while I check the record.",
        "speak": "Please stay on this line while I check the record.",
        "language": "en",
    }
    payload.update(overrides)
    return OfficerOutput.model_validate(payload)


def _settings(**overrides: object) -> Settings:
    base = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        llm_enabled=True,
        token_pepper="test-pepper-not-for-production",
        llm_timeout_seconds=1.0,
    )
    return base.model_copy(update=overrides)


def _writer(settings: Settings, provider, budget=None) -> LineWriter:
    return LineWriter(settings, SCENARIO, budget or StubBudget(), provider)


def test_parse_plain_fenced_and_invalid_json() -> None:
    payload = json.dumps(
        {"display": "Stay on the line please.", "speak": "Stay on the line.", "language": "en"}
    )
    assert parse_officer_output(payload) is not None
    assert parse_officer_output(f"```json\n{payload}\n```") is not None
    assert parse_officer_output("no json here") is None
    assert parse_officer_output('{"display": "x"}') is None
    assert parse_officer_output('{"display": 1, "speak": 2, "language": 3}') is None


def test_validation_accepts_safe_lines_in_every_language() -> None:
    assert validate_officer_line(_line(), "en") is None
    assert (
        validate_officer_line(
            OfficerOutput(
                display="कृपया इस लाइन पर बने रहें।",
                speak="कृपया इस लाइन पर बने रहें।",
                language="hi",
            ),
            "hi",
        )
        is None
    )
    assert (
        validate_officer_line(
            OfficerOutput(
                display="Please is line par bane rahein.",
                speak="कृपया इस लाइन पर बने रहें।",
                language="hinglish",
            ),
            "hinglish",
        )
        is None
    )


@pytest.mark.parametrize(
    ("mutate", "reason"),
    [
        (lambda line: line.model_copy(update={"language": "hi"}), "wrong_language"),
        (lambda line: line.model_copy(update={"display": "short"}), "too_short"),
        (
            lambda line: line.model_copy(update={"display": "Stay here.\nThen wait."}),
            "control_characters",
        ),
        (
            lambda line: line.model_copy(update={"display": "Stay here\u2014please."}),
            "dash",
        ),
        (
            lambda line: line.model_copy(update={"display": "Stay here please \U0001f600"}),
            "emoji",
        ),
        (
            lambda line: line.model_copy(update={"display": "Stay **here** please."}),
            "markdown",
        ),
        (
            lambda line: line.model_copy(update={"display": "Visit https://bad.example now."}),
            "url",
        ),
        (
            lambda line: line.model_copy(update={"display": "This is the CBI calling you."}),
            "real_entity",
        ),
        (
            lambda line: line.model_copy(update={"display": "We will arrest you today."}),
            "threat",
        ),
        (
            lambda line: line.model_copy(update={"display": "Send me the OTP right now."}),
            "data_request",
        ),
        (
            lambda line: line.model_copy(update={"display": "Call 9876543210 quickly."}),
            "pii",
        ),
        (
            lambda line: line.model_copy(update={"display": "\u0915\u0943\u092a\u092f\u093e \u0930\u0941\u0915\u0947\u0902"}),
            "script",
        ),
    ],
)
def test_validation_rule_reasons(mutate, reason: str) -> None:
    assert validate_officer_line(mutate(_line()), "en") == reason


def test_validation_rejects_hinglish_display_in_devanagari() -> None:
    line = OfficerOutput(
        display="कृपया इस लाइन पर बने रहें।",
        speak="कृपया इस लाइन पर बने रहें।",
        language="hinglish",
    )
    assert validate_officer_line(line, "hinglish") == "script"


def test_safe_context_permits_warning_wording() -> None:
    line = _line()
    line = line.model_copy(
        update={"display": "Never share an OTP or card number with anyone on this call."}
    )
    assert validate_officer_line(line, "en") is None


def test_writer_without_provider_is_scripted() -> None:
    writer = _writer(_settings(llm_enabled=False), None)
    result = asyncio.run(writer.generate(_context()))
    assert result.tier == "scripted"
    assert result.fallback_used is True


def test_writer_uses_primary_tier_and_records_budget() -> None:
    provider = FakeProvider([json.dumps(_line().model_dump())])
    budget = StubBudget()
    writer = _writer(_settings(), provider, budget)
    result = asyncio.run(writer.generate(_context()))
    assert result.tier == "primary"
    assert result.fallback_used is False
    assert budget.records == [(10, 5)]


def test_writer_falls_back_to_cheap_on_invalid_primary() -> None:
    provider = FakeProvider(["not json", json.dumps(_line().model_dump())])
    writer = _writer(_settings(), provider)
    result = asyncio.run(writer.generate(_context()))
    assert result.tier == "cheap"
    assert len(provider.calls) == 2


def test_writer_falls_back_to_scripted_after_both_failures() -> None:
    provider = FakeProvider(["bad", Exception("network")])
    writer = _writer(_settings(), provider)
    result = asyncio.run(writer.generate(_context()))
    assert result.tier == "scripted"
    assert result.fallback_used is True


def test_kill_switch_and_exhausted_budget_skip_provider() -> None:
    provider = FakeProvider([])
    killed = _writer(_settings(llm_kill_switch=True), provider)
    assert asyncio.run(killed.generate(_context())).tier == "scripted"

    exhausted = _writer(_settings(), provider, StubBudget(available=False))
    assert asyncio.run(exhausted.generate(_context())).tier == "scripted"
    assert provider.calls == []


def test_writer_timeout_falls_back() -> None:
    class SlowProvider:
        async def complete(self, **kwargs):
            await asyncio.sleep(0.2)
            return LlmResult(text="{}")

    writer = _writer(_settings(llm_timeout_seconds=0.01), SlowProvider())
    result = asyncio.run(writer.generate(_context()))
    assert result.tier == "scripted"


def test_writer_rejects_wrong_language_output() -> None:
    provider = FakeProvider([json.dumps(_line(language="hi").model_dump())])
    result = asyncio.run(_writer(_settings(), provider).generate(_context("en")))
    assert result.tier == "scripted"


def test_prompt_fences_untrusted_data_and_limits_history() -> None:
    context = _context(messages=("first message", "second message", "third message"))
    prompt = LineWriter._build_prompt(context)
    assert "<<<UNTRUSTED_PARTICIPANT_DATA>>>" in prompt
    assert "<<<END_UNTRUSTED_PARTICIPANT_DATA>>>" in prompt
    assert "first message" not in prompt
    assert "second message" in prompt
    assert "third message" in prompt
    assert "Stage: accusation" in prompt
    assert "Pressure: 1" in prompt
    assert "Language: en" in prompt


def test_line_result_does_not_mutate_context() -> None:
    context = _context()
    before = replace(context)
    provider = FakeProvider([json.dumps(_line().model_dump())])
    asyncio.run(_writer(_settings(), provider).generate(context))
    assert context == before


def test_budget_available_and_exhaustion() -> None:
    database = Database("sqlite:///:memory:")
    database.create_all()
    settings = _settings(daily_llm_budget_usd=0.001)
    tracker = BudgetTracker(database, settings)
    assert tracker.available() is True
    tracker.record(1_000_000, 1_000_000)
    assert tracker.available() is False
    snapshot = tracker.snapshot()
    assert snapshot["calls"] == 1
    assert snapshot["spent_usd"] > 0
    database.dispose()


def test_budget_disabled_and_kill_switch() -> None:
    database = Database("sqlite:///:memory:")
    database.create_all()
    assert BudgetTracker(database, _settings(llm_enabled=False)).available() is False
    assert BudgetTracker(database, _settings(llm_kill_switch=True)).available() is False
    empty = BudgetTracker(database, _settings())
    assert empty.snapshot() == {"spent_usd": 0.0, "calls": 0, "budget_usd": 1.0}
    database.dispose()


def test_pii_warning_uses_scripted_safety_line() -> None:
    provider = FakeProvider([])
    writer = _writer(_settings(), provider)
    context = replace(_context(), pii_warning=True)
    result = writer.scripted(context)
    assert result.tier == "scripted"
    assert "practice drill" in result.display.lower()
    assert provider.calls == []
