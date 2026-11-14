"""Debrief rules, reconciliation, quote validation, and fallback tests."""

from __future__ import annotations

import asyncio
import json

import pytest

from app.config import Settings
from app.database import Database
from app.debrief.llm_scoring import (
    RescoredDebrief,
    RescoredEvent,
    RescoredQuote,
    reconcile,
    request_rescore,
)
from app.debrief.rules import (
    TurnView,
    build_content,
    did_well_ids,
    first_compliance,
    habit_id,
)
from app.llm.base_types import LlmResult
from app.llm.budget import BudgetTracker

TEXT = "I want to verify your badge number"


def _turn(index: int = 1, label: str | None = "P2", **overrides) -> TurnView:
    payload = {
        "turn_index": index,
        "label": label,
        "confidence": 0.65,
        "stage_id": "contact",
        "text": TEXT,
        "quote_text": "verify",
        "quote_start": 10,
        "quote_end": 16,
    }
    payload.update(overrides)
    return TurnView(**payload)


def _settings(**overrides: object) -> Settings:
    return Settings(
        env="test",
        database_url="sqlite:///:memory:",
        llm_enabled=True,
        token_pepper="test-pepper-not-for-production",
    ).model_copy(update=overrides)


@pytest.mark.parametrize(
    ("labels", "expected"),
    [
        (["P1"], ["refused_private_call", "refused_money_transfer"]),
        (["P2"], ["asked_badge_number", "refused_money_transfer"]),
        (["P4"], ["recognized_urgency_tactic", "refused_money_transfer"]),
        (["C1"], ["refused_money_transfer"]),
        (["C4"], []),
        ([], []),
    ],
)
def test_did_well_ids_are_deterministic(labels: list[str], expected: list[str]) -> None:
    assert did_well_ids(labels) == expected


@pytest.mark.parametrize(
    ("labels", "habit"),
    [(["P3"], "tell_family"), (["P2"], "call_back_official"), (["P1"], "hang_up"), ([], "hang_up")],
)
def test_habit_id_priority(labels: list[str], habit: str) -> None:
    assert habit_id(labels) == habit


def test_first_compliance_is_earliest_c_label() -> None:
    turns = [_turn(1, "P2"), _turn(2, "C1"), _turn(3, "C2")]
    result = first_compliance(turns)
    assert result is not None
    assert result.turn_index == 2
    assert result.label == "C1"
    assert first_compliance([_turn(1, "P2")]) is None


def test_build_content_quick_and_full_flags() -> None:
    quick = build_content([_turn()], quality="quick")
    full = build_content([_turn()], quality="full", low_confidence=True)
    assert quick.quality == "quick"
    assert quick.low_confidence is False
    assert full.quality == "full"
    assert full.low_confidence is True
    assert quick.events[0].quote is not None
    assert quick.events[0].quote.text == "verify"


def test_invalid_stored_quote_is_dropped() -> None:
    content = build_content([_turn(quote_text="not-in-text")], quality="quick")
    assert content.events[0].quote is None


def test_content_skips_unlabelled_turns_but_keeps_state_path() -> None:
    content = build_content([_turn(1, "P2"), _turn(2, None)], quality="quick")
    assert len(content.events) == 1
    assert len(content.state_path) == 2


def test_reconcile_agreement_averages_confidence_and_keeps_quote() -> None:
    event = RescoredEvent(
        turn_index=1,
        label="P2",
        confidence=0.9,
        quote=RescoredQuote(text="verify", start=12, end=18),
    )
    overrides, low = reconcile([_turn()], {1: event}, attempted=True)
    assert low is False
    assert overrides[1].confidence == 0.78
    assert overrides[1].quote is not None


def test_reconcile_disagreement_keeps_rule_label_and_lowers_confidence() -> None:
    event = RescoredEvent(turn_index=1, label="C3", confidence=0.9)
    overrides, low = reconcile([_turn()], {1: event}, attempted=True)
    assert low is True
    assert overrides[1].label == "P2"
    assert overrides[1].confidence < 0.65


def test_reconcile_unknown_turn_flags_low_confidence() -> None:
    event = RescoredEvent(turn_index=99, label="P2", confidence=0.9)
    overrides, low = reconcile([_turn()], {99: event}, attempted=True)
    assert low is True
    assert overrides == {}


def test_reconcile_missing_events_flags_low_confidence() -> None:
    event = RescoredEvent(turn_index=1, label="P2", confidence=0.9)
    _, low = reconcile([_turn(), _turn(2, "P1")], {1: event}, attempted=True)
    assert low is True


def test_reconcile_no_attempt_and_failed_attempt() -> None:
    assert reconcile([_turn()], None, attempted=False) == ({}, False)
    assert reconcile([_turn()], None, attempted=True) == ({}, True)


def test_reconcile_non_verbatim_quote_falls_back_to_rule_quote() -> None:
    event = RescoredEvent(
        turn_index=1,
        label="P2",
        confidence=0.8,
        quote=RescoredQuote(text="invented words", start=0, end=14),
    )
    overrides, _ = reconcile([_turn()], {1: event}, attempted=True)
    assert overrides[1].quote is not None
    assert overrides[1].quote.text == "verify"


def test_reconcile_corrects_wrong_offsets_to_first_occurrence() -> None:
    event = RescoredEvent(
        turn_index=1,
        label="P2",
        confidence=0.8,
        quote=RescoredQuote(text="verify", start=0, end=6),
    )
    overrides, _ = reconcile([_turn()], {1: event}, attempted=True)
    assert overrides[1].quote.start == 10


class _Provider:
    def __init__(self, response: object) -> None:
        self.response = response
        self.calls = 0

    async def complete(self, **kwargs):
        self.calls += 1
        if isinstance(self.response, Exception):
            raise self.response
        return LlmResult(text=str(self.response), input_tokens=100, output_tokens=50)


class _Budget:
    def __init__(self, available: bool = True) -> None:
        self.is_available = available
        self.recorded = 0

    def available(self) -> bool:
        return self.is_available

    def record(self, input_tokens: int, output_tokens: int) -> float:
        self.recorded += 1
        return 0.0


def _payload() -> str:
    event = RescoredEvent(
        turn_index=1,
        label="P2",
        confidence=0.8,
        quote=RescoredQuote(text="verify", start=12, end=18),
    )
    return json.dumps(RescoredDebrief(events=[event]).model_dump())


def test_rescore_skips_when_disabled_or_no_provider() -> None:
    provider = _Provider(_payload())
    assert asyncio.run(
        request_rescore([_turn()], None, _settings(), _Budget())
    ) == (None, False)
    assert asyncio.run(
        request_rescore([_turn()], provider, _settings(llm_enabled=False), _Budget())
    ) == (None, False)
    assert provider.calls == 0


def test_rescore_skips_on_kill_switch_or_budget() -> None:
    provider = _Provider(_payload())
    assert asyncio.run(
        request_rescore([_turn()], provider, _settings(llm_kill_switch=True), _Budget())
    ) == (None, True)
    assert asyncio.run(
        request_rescore([_turn()], provider, _settings(), _Budget(False))
    ) == (None, True)
    assert provider.calls == 0


def test_rescore_success_records_budget() -> None:
    provider = _Provider(_payload())
    budget = _Budget()
    events, attempted = asyncio.run(
        request_rescore([_turn()], provider, _settings(), budget)
    )
    assert attempted is True
    assert events is not None
    assert events[1].label == "P2"
    assert budget.recorded == 1


def test_rescore_invalid_json_and_provider_error_are_nonfatal() -> None:
    for response in ("not json", RuntimeError("boom")):
        events, attempted = asyncio.run(
            request_rescore([_turn()], _Provider(response), _settings(), _Budget())
        )
        assert events is None
        assert attempted is True


def test_rescore_uses_database_budget_tracker() -> None:
    database = Database("sqlite:///:memory:")
    database.create_all()
    settings = _settings()
    tracker = BudgetTracker(database, settings)
    events, attempted = asyncio.run(
        request_rescore([_turn()], _Provider(_payload()), settings, tracker)
    )
    assert events is not None
    assert attempted is True
    assert tracker.snapshot()["calls"] == 1
    database.dispose()


def test_prompt_fences_transcript_and_skips_neutral_turns() -> None:
    from app.debrief.llm_scoring import _prompt

    prompt = _prompt([_turn(1, "P2"), _turn(2, None, text="neutral chatter")])
    assert "<<<UNTRUSTED_TRANSCRIPT>>>" in prompt
    assert "badge" in prompt
    assert "neutral chatter" not in prompt
