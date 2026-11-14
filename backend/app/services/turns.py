"""Turn processing: idempotency, locking, engine, line writing, persistence."""

from __future__ import annotations

import logging
from dataclasses import asdict
from datetime import timedelta
from random import Random

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.config import Settings
from app.engine.classifier import classify
from app.engine.engine import step as engine_step
from app.engine.scenario import Scenario
from app.engine.types import EndReason, EngineEvent, EngineState, EventKind
from app.errors import ApiProblem
from app.llm import LlmProvider
from app.llm.budget import BudgetTracker
from app.llm.line_writer import LineContext, LineResult, LineWriter
from app.models import DrillSession, TurnEvent
from app.pii import redact
from app.schemas import TurnRequest, TurnResponse
from app.services.common import (
    apply_state,
    dump_turn,
    line_model,
    state_from_session,
    turn_response,
)
from app.services.debriefing import finalize_debrief
from app.timeutil import ensure_utc, utcnow

logger = logging.getLogger("dryrun.turns")


def _existing(db: Session, session_id: str, turn_id: str) -> TurnEvent | None:
    return db.scalar(
        select(TurnEvent).where(
            TurnEvent.session_id == session_id,
            TurnEvent.turn_id == turn_id,
        )
    )


def _stored(event: TurnEvent) -> TurnResponse:
    return TurnResponse.model_validate(event.response_json)


def _is_expired(session: DrillSession, settings: Settings) -> bool:
    now = utcnow()
    deadline = ensure_utc(session.created_at) + timedelta(seconds=settings.max_duration_seconds)
    idle = ensure_utc(session.last_activity_at) + timedelta(seconds=settings.idle_timeout_seconds)
    return now >= deadline or now >= idle


async def _write_line(
    writer: LineWriter,
    session: DrillSession,
    state: EngineState,
    messages: tuple[str, ...],
    pii_warning: bool,
) -> LineResult:
    context = LineContext(
        stage=state.stage.value,
        pressure=state.pressure,
        language=session.language,  # type: ignore[arg-type]
        purpose=state.purpose,
        messages=messages,
        pii_warning=pii_warning,
        seed=session.seed,
    )
    if pii_warning:
        return writer.scripted(context)
    return await writer.generate(context)


def _recent_messages(db: Session, session_id: str, current: str) -> tuple[str, ...]:
    rows = list(
        db.scalars(
            select(TurnEvent)
            .where(TurnEvent.session_id == session_id, TurnEvent.kind == "participant")
            .order_by(TurnEvent.turn_index.desc())
            .limit(2)
        )
    )
    texts = [row.participant_text for row in reversed(rows)]
    texts.append(current)
    return tuple(texts[-2:])


def _timeout_response(session: DrillSession) -> TurnResponse:
    return TurnResponse(
        officer_line=None,
        stage_id=session.stage,  # type: ignore[arg-type]
        pressure=max(0, min(3, session.pressure)),
        status="ended",
        end_reason=EndReason.TIMEOUT.value,  # type: ignore[arg-type]
        turn_index=session.turn_index,
        fallback_used=True,
        pii_warning=session.pii_warning,
    )


async def process_participant_turn(
    db: Session,
    session: DrillSession,
    settings: Settings,
    scenario: Scenario,
    writer: LineWriter,
    body: TurnRequest,
    provider: LlmProvider | None,
    budget: BudgetTracker,
) -> TurnResponse:
    """Process one idempotent participant turn."""
    duplicate = _existing(db, session.id, body.turn_id)
    if duplicate is not None:
        return _stored(duplicate)

    locked = db.scalar(
        select(DrillSession).where(DrillSession.id == session.id).with_for_update()
    )
    if locked is not None:
        session = locked

    duplicate = _existing(db, session.id, body.turn_id)
    if duplicate is not None:
        return _stored(duplicate)

    if session.status == "ended":
        raise ApiProblem(
            409,
            "session_ended",
            "Session ended",
            "This drill has already ended.",
        )

    if _is_expired(session, settings):
        session.status = "ended"
        session.end_reason = EndReason.TIMEOUT.value
        session.purpose = "closing"
        session.ended_at = utcnow()
        await finalize_debrief(db, session, settings, provider, budget)
        return _timeout_response(session)

    if body.expected_turn_index != session.turn_index + 1:
        raise ApiProblem(
            409,
            "turn_index_mismatch",
            "Turn index mismatch",
            f"Expected turn index is {session.turn_index + 1}.",
        )

    pii = redact(body.text)
    classification = classify(pii.text, session.language)
    state = state_from_session(session)
    next_state, _effects = engine_step(
        state,
        EngineEvent(kind=EventKind.PARTICIPANT, label=classification.label),
        scenario,
        Random(session.seed),  # nosec B311
    )

    messages = _recent_messages(db, session.id, pii.text)
    officer: LineResult | None = None
    if next_state.status == "active":
        officer = await _write_line(writer, session, next_state, messages, pii.found)

    response = turn_response(
        next_state,
        line_model(
            {
                "display": officer.display,
                "speak": officer.speak,
                "language": officer.language,
            }
        )
        if officer
        else None,
        fallback_used=officer.fallback_used if officer else True,
        pii_warning=pii.found,
    )
    event = TurnEvent(
        session_id=session.id,
        turn_id=body.turn_id,
        turn_index=next_state.turn_index,
        kind="participant",
        participant_text=pii.text,
        label=classification.label.value if classification.label else None,
        confidence=classification.confidence,
        quote_text=classification.quote,
        quote_start=classification.start,
        quote_end=classification.end,
        stage_id=next_state.stage.value,
        pressure=next_state.pressure,
        officer_display=officer.display if officer else None,
        officer_speak=officer.speak if officer else None,
        officer_language=officer.language if officer else None,
        fallback_used=response.fallback_used,
        pii_warning=pii.found,
        status=next_state.status,
        end_reason=next_state.end_reason.value if next_state.end_reason else None,
        state_json=asdict(next_state),
        response_json=dump_turn(response),
    )
    db.add(event)
    apply_state(session, next_state)
    session.last_activity_at = utcnow()
    session.pii_warning = session.pii_warning or pii.found
    if next_state.status == "ended":
        session.ended_at = utcnow()
    try:
        db.flush()
    except IntegrityError:
        db.rollback()
        retry = _existing(db, session.id, body.turn_id)
        if retry is not None:
            return _stored(retry)
        raise ApiProblem(
            409,
            "turn_index_mismatch",
            "Turn conflict",
            "This turn conflicts with a concurrent request.",
        ) from None

    if next_state.status == "ended":
        await finalize_debrief(db, session, settings, provider, budget)
    return response


__all__ = ["process_participant_turn"]
