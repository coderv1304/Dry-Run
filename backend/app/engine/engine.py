"""Deterministic drill reducer.

``step`` is a pure function.  It never renders dialogue, touches a network,
or reads a clock.  The service layer executes the returned effects.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import replace
from random import Random

from app.engine.types import (
    STAGE_TRANSITIONS,
    Effect,
    EndReason,
    EngineEvent,
    EngineState,
    EventKind,
    Label,
    ScenarioLike,
    Stage,
)


def create_initial_state() -> EngineState:
    """Return the state used before the opening officer line."""
    return EngineState(stage=Stage.CONTACT, pressure=0, turn_index=0, purpose="opening")


def _raise_pressure(state: EngineState) -> EngineState:
    """Raise pressure but never exceed the compliance-dependent cap."""
    cap = 3 if state.complied_once else 2
    return replace(state, pressure=min(state.pressure + 1, cap))


def _advance(state: EngineState) -> EngineState:
    """Move one rung on the explicit stage table."""
    return replace(state, stage=STAGE_TRANSITIONS[state.stage])


def _end(state: EngineState, reason: EndReason) -> EngineState:
    """Return a terminal state."""
    return replace(
        state,
        status="ended",
        end_reason=reason,
        purpose="closing",
    )


def _on_refusal(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """P1: the participant hangs up or plainly refuses."""
    del scenario
    return _end(state, EndReason.HUNG_UP)


def _on_verification(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """P2: deflect once, escalate once, then allow a verified callback."""
    del scenario
    count = state.verification_count + 1
    raised = _raise_pressure(state)
    if count == 1:
        return replace(raised, verification_count=count, purpose="verify_deflect")
    if count == 2:
        return replace(raised, verification_count=count, purpose="verify_escalate")
    return _end(
        replace(raised, verification_count=count),
        EndReason.VERIFIED_CALLBACK,
    )


def _on_family(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """P3: a family mention triggers a confidentiality push."""
    del scenario
    raised = _raise_pressure(state)
    return replace(
        raised,
        family_count=state.family_count + 1,
        purpose="family_push",
    )


def _on_awareness(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """P4: the officer reframes and pushes the story forward."""
    del scenario
    advanced = _advance(state)
    if advanced.stage is Stage.TRANSFER:
        advanced = _raise_pressure(advanced)
    return replace(advanced, purpose="reframe")


def _on_compliance(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """C1-C3: compliance advances the story and unlocks the higher cap."""
    del scenario
    unlocked = replace(state, complied_once=True)
    advanced = _advance(unlocked)
    return replace(_raise_pressure(advanced), purpose="compliance")


def _on_transfer(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """C4: the participant complied with the transfer request."""
    del scenario
    return _end(replace(state, complied_once=True), EndReason.COMPLIED_TRANSFER)


def _on_hesitation(state: EngineState, scenario: ScenarioLike) -> EngineState:
    """Neutral input raises pressure; sustained hesitation advances a stage."""
    del scenario
    count = state.hesitation_count + 1
    raised = _raise_pressure(replace(state, hesitation_count=count))
    if count % 2 == 0:
        raised = _advance(raised)
    return replace(raised, purpose="hesitation")


# The complete label-to-handler transition table.
TRANSITIONS: dict[Label, Callable[[EngineState, ScenarioLike], EngineState]] = {
    Label.P1: _on_refusal,
    Label.P2: _on_verification,
    Label.P3: _on_family,
    Label.P4: _on_awareness,
    Label.C1: _on_compliance,
    Label.C2: _on_compliance,
    Label.C3: _on_compliance,
    Label.C4: _on_transfer,
}


def _record(kind: str, state: EngineState, **extra: object) -> Effect:
    """Build a record_event effect."""
    payload: dict[str, object] = {
        "kind": kind,
        "stage_id": state.stage.value,
        "pressure": state.pressure,
        "turn_index": state.turn_index,
        "status": state.status,
    }
    payload.update(extra)
    return Effect("record_event", payload)


def _request_line(state: EngineState) -> Effect:
    """Build a request_line effect for the current state."""
    return Effect(
        "request_line",
        {
            "stage_id": state.stage.value,
            "pressure": state.pressure,
            "purpose": state.purpose,
            "turn_index": state.turn_index,
        },
    )


def step(
    state: EngineState,
    event: EngineEvent,
    scenario: ScenarioLike,
    rng: Random,
) -> tuple[EngineState, list[Effect]]:
    """Reduce one event into new state and effects.

    The reducer is the only component allowed to decide stage, pressure,
    status, and end reason.  The random source is accepted for replay
    compatibility and is intentionally unused for state decisions.
    """
    del rng
    if state.status == "ended":
        return state, []

    if event.kind is EventKind.START:
        opened = create_initial_state()
        effects = [_record("start", opened), _request_line(opened)]
        return opened, effects

    if event.kind is EventKind.END:
        reason = event.reason or EndReason.PARTICIPANT_ENDED
        ended = _end(state, reason)
        return ended, [_record("end", ended, end_reason=reason.value)]

    if event.kind is EventKind.TIMEOUT:
        ended = _end(state, EndReason.TIMEOUT)
        return ended, [_record("timeout", ended, end_reason=EndReason.TIMEOUT.value)]

    next_state = replace(
        state,
        turn_index=state.turn_index + 1,
        last_label=event.label.value if event.label else None,
    )
    handler = TRANSITIONS.get(event.label, _on_hesitation)  # type: ignore[arg-type]
    next_state = handler(next_state, scenario)
    effects = [
        _record(
            "participant",
            next_state,
            label=event.label.value if event.label else "neutral",
        )
    ]
    if next_state.status == "ended":
        effects.append(
            _record("end", next_state, end_reason=next_state.end_reason.value)  # type: ignore[union-attr]
        )
        return next_state, effects

    if next_state.turn_index >= scenario.max_turns:
        capped = _end(next_state, EndReason.TURN_CAP)
        effects.append(_record("end", capped, end_reason=EndReason.TURN_CAP.value))
        return capped, effects

    effects.append(_request_line(next_state))
    return next_state, effects
