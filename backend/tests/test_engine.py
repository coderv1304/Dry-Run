"""Engine determinism, transition, pressure, and termination tests."""

from __future__ import annotations

import ast
import itertools
from pathlib import Path
from random import Random
from types import SimpleNamespace

from hypothesis import given
from hypothesis import settings as hypothesis_settings
from hypothesis import strategies as st

from app.engine.engine import create_initial_state, step
from app.engine.replay import replay
from app.engine.types import (
    EndReason,
    EngineEvent,
    EventKind,
    Label,
    Stage,
)

SCENARIO = SimpleNamespace(max_turns=12)
ALL = list(Label)


def run(labels: list[Label], max_turns: int = 12):
    """Run a start event followed by labels until terminal."""
    scenario = SimpleNamespace(max_turns=max_turns)
    state, effects = step(
        create_initial_state(), EngineEvent(EventKind.START), scenario, Random(1)
    )
    assert state.turn_index == 0
    assert effects[1].kind == "request_line"
    for label in labels:
        if state.status == "ended":
            break
        state, _ = step(state, EngineEvent(EventKind.PARTICIPANT, label), scenario, Random(1))
    return state


def test_start_emits_one_line_and_record() -> None:
    state, effects = step(
        create_initial_state(), EngineEvent(EventKind.START), SCENARIO, Random(1)
    )
    assert state.stage is Stage.CONTACT
    assert state.pressure == 0
    assert [effect.kind for effect in effects] == ["record_event", "request_line"]
    assert effects[1].payload["purpose"] == "opening"


def test_refusal_terminates() -> None:
    assert run([Label.P1]).end_reason is EndReason.HUNG_UP


def test_transfer_compliance_terminates() -> None:
    assert run([Label.C4]).end_reason is EndReason.COMPLIED_TRANSFER


def test_verification_deflects_then_escalates_then_ends() -> None:
    scenario = SCENARIO
    state = create_initial_state()
    state, _ = step(state, EngineEvent(EventKind.START), scenario, Random(1))
    state, effects = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P2), scenario, Random(1))
    assert state.verification_count == 1
    assert state.status == "active"
    assert state.pressure == 1
    assert effects[-1].payload["purpose"] == "verify_deflect"
    state, effects = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P2), scenario, Random(1))
    assert state.status == "active"
    assert state.pressure == 2
    assert effects[-1].payload["purpose"] == "verify_escalate"
    state, _ = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P2), scenario, Random(1))
    assert state.status == "ended"
    assert state.end_reason is EndReason.VERIFIED_CALLBACK


def test_hesitation_pressure_capped_without_compliance() -> None:
    state = run([None] * 6)  # type: ignore[list-item]
    assert state.pressure <= 2


def test_compliance_unlocks_pressure_cap_three() -> None:
    scenario = SCENARIO
    state = create_initial_state()
    state, _ = step(state, EngineEvent(EventKind.START), scenario, Random(1))
    state, _ = step(state, EngineEvent(EventKind.PARTICIPANT, Label.C1), scenario, Random(1))
    assert state.complied_once is True
    state, _ = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P3), scenario, Random(1))
    state, _ = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P3), scenario, Random(1))
    assert state.pressure == 3


def test_family_push_purpose() -> None:
    scenario = SCENARIO
    state = create_initial_state()
    state, _ = step(state, EngineEvent(EventKind.START), scenario, Random(1))
    state, effects = step(state, EngineEvent(EventKind.PARTICIPANT, Label.P3), scenario, Random(1))
    assert state.purpose == "family_push"
    assert effects[-1].payload["purpose"] == "family_push"


def test_turn_cap_terminates() -> None:
    state = run([None] * 12)  # type: ignore[list-item]
    assert state.status == "ended"
    assert state.end_reason in {EndReason.TURN_CAP, EndReason.TIMEOUT}


def test_timeout_and_end_events() -> None:
    for event, reason in (
        (EngineEvent(EventKind.TIMEOUT), EndReason.TIMEOUT),
        (EngineEvent(EventKind.END), EndReason.PARTICIPANT_ENDED),
        (EngineEvent(EventKind.END, reason=EndReason.PARTICIPANT_ENDED), EndReason.PARTICIPANT_ENDED),
    ):
        state, effects = step(create_initial_state(), event, SCENARIO, Random(2))
        assert state.end_reason is reason
        assert effects[0].kind == "record_event"


@hypothesis_settings(max_examples=80, deadline=None)
@given(st.lists(st.sampled_from(ALL), min_size=1, max_size=30))
def test_every_path_stays_within_turn_cap(labels: list[Label]) -> None:
    state = run(labels)
    assert state.turn_index <= 12
    assert state.status == "ended" or state.turn_index < 12


@hypothesis_settings(max_examples=40, deadline=None)
@given(st.lists(st.sampled_from(ALL), min_size=0, max_size=8))
def test_any_prefix_then_neutral_inputs_terminates(labels: list[Label]) -> None:
    state = run(labels + [None] * 12)  # type: ignore[list-item]
    assert state.status == "ended"


def test_start_alone_stays_active_until_an_event() -> None:
    state = run([])
    assert state.status == "active"
    assert state.turn_index == 0


def test_determinism() -> None:
    left = run([Label.P2, Label.P3, Label.C1, Label.P4])
    right = run([Label.P2, Label.P3, Label.C1, Label.P4])
    assert left == right


def test_replay_equals_original() -> None:
    events = [EngineEvent(EventKind.START)] + [
        EngineEvent(EventKind.PARTICIPANT, label)
        for label in [Label.P2, Label.P3, Label.C1, Label.P4, Label.C2]
    ]
    first = replay(events, SCENARIO, seed=7)
    second = replay(events, SCENARIO, seed=7)
    assert first == second
    assert first[-1][0].turn_index == 5


def test_exhaustive_short_sequences_terminate() -> None:
    for length in range(1, 4):
        for labels in itertools.product(ALL, repeat=length):
            state = run(list(labels))
            assert state.turn_index <= 12


def test_engine_source_has_no_llm_or_network_imports() -> None:
    forbidden = {"app.llm", "httpx", "openai", "anthropic", "requests", "socket", "urllib"}
    root = Path(__file__).resolve().parents[1] / "app" / "engine"
    for path in root.glob("*.py"):
        tree = ast.parse(path.read_text(encoding="utf-8"))
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    assert alias.name.split(".")[0] not in forbidden
            if isinstance(node, ast.ImportFrom) and node.module:
                assert node.module.split(".")[0] not in forbidden
