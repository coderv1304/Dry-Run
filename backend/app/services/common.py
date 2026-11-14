"""Shared serialization helpers for the service layer."""

from __future__ import annotations

from typing import Any

from app.engine.types import EndReason, EngineState, Stage
from app.models import DrillSession
from app.schemas import OfficerLine, TurnResponse


def state_from_session(session: DrillSession) -> EngineState:
    """Rebuild immutable engine state from a persisted row."""
    return EngineState(
        stage=Stage(session.stage),
        pressure=session.pressure,
        turn_index=session.turn_index,
        status=session.status,  # type: ignore[arg-type]
        end_reason=EndReason(session.end_reason) if session.end_reason else None,
        complied_once=session.complied_once,
        verification_count=session.verification_count,
        family_count=session.family_count,
        hesitation_count=session.hesitation_count,
        last_label=session.last_label,
        purpose=session.purpose,
    )


def apply_state(session: DrillSession, state: EngineState) -> None:
    """Copy engine state back onto the persistence row."""
    session.stage = state.stage.value
    session.pressure = state.pressure
    session.turn_index = state.turn_index
    session.status = state.status
    session.end_reason = state.end_reason.value if state.end_reason else None
    session.complied_once = state.complied_once
    session.verification_count = state.verification_count
    session.family_count = state.family_count
    session.hesitation_count = state.hesitation_count
    session.last_label = state.last_label
    session.purpose = state.purpose


def line_model(line: dict[str, str] | None) -> OfficerLine | None:
    """Convert a line dict into the contract model."""
    if line is None:
        return None
    return OfficerLine(
        display=line["display"],
        speak=line["speak"],
        language=line["language"],
    )


def turn_response(
    state: EngineState,
    officer_line: OfficerLine | None,
    fallback_used: bool,
    pii_warning: bool,
) -> TurnResponse:
    """Build the single-turn response model."""
    return TurnResponse(
        officer_line=officer_line,
        stage_id=state.stage.value,  # type: ignore[arg-type]
        pressure=max(0, min(3, state.pressure)),
        status=state.status,
        end_reason=state.end_reason.value if state.end_reason else None,  # type: ignore[arg-type]
        turn_index=state.turn_index,
        fallback_used=fallback_used,
        pii_warning=pii_warning,
    )


def dump_turn(response: TurnResponse) -> dict[str, Any]:
    """Return an idempotency-safe serialized turn response."""
    return response.model_dump(mode="json", exclude_none=True)


__all__ = [
    "apply_state",
    "dump_turn",
    "line_model",
    "state_from_session",
    "turn_response",
]
