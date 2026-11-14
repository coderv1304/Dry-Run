"""Invite and session creation services."""

from __future__ import annotations

import secrets
from dataclasses import asdict
from datetime import timedelta
from random import Random

from sqlalchemy.orm import Session

from app.config import Settings
from app.engine.engine import step as engine_step
from app.engine.scenario import Scenario
from app.engine.types import EngineEvent, EngineState, EventKind
from app.errors import ApiProblem
from app.llm.line_writer import LineContext, LineResult, LineWriter
from app.models import DrillSession, Invite, TurnEvent
from app.schemas import (
    SessionCreateRequest,
    SessionCreateResponse,
    SessionLimits,
)
from app.security import hash_token, new_session_id, new_token
from app.services.common import dump_turn, line_model, turn_response
from app.timeutil import utcnow


def create_invite_row(
    db: Session,
    settings: Settings,
    language: str,
    cohort: str | None,
) -> tuple[Invite, str]:
    """Create and persist an invite, returning the raw token once."""
    raw = new_token("inv")
    now = utcnow()
    invite = Invite(
        token_hash=hash_token(raw, settings.token_pepper),
        language=language,
        cohort=cohort,
        created_at=now,
        expires_at=now + timedelta(days=settings.invite_ttl_days),
        session_count=0,
    )
    db.add(invite)
    db.flush()
    return invite, raw


def _opening_line(
    scenario: Scenario, writer: LineWriter, language: str, seed: int
) -> LineResult:
    """Use a reviewed scripted opening on the first turn."""
    context = LineContext(
        stage="contact",
        pressure=0,
        language=language,  # type: ignore[arg-type]
        purpose="opening",
        messages=(),
        pii_warning=False,
        seed=seed,
    )
    return writer.scripted(context)


def create_session_row(
    db: Session,
    settings: Settings,
    scenario: Scenario,
    writer: LineWriter,
    invite: Invite,
    body: SessionCreateRequest,
) -> SessionCreateResponse:
    """Create a session, its opening event, and the first turn response."""
    if not body.consent:
        raise ApiProblem(
            400,
            "consent_required",
            "Consent required",
            "Practice call consent is required to start a drill.",
        )
    if invite.session_count >= settings.max_sessions_per_invite:
        raise ApiProblem(
            409,
            "session_limit_reached",
            "Session limit reached",
            "This invite has reached its session limit.",
        )

    seed = secrets.randbits(63)
    raw_token = new_token("tok")
    session_id = new_session_id()
    now = utcnow()
    session = DrillSession(
        id=session_id,
        invite_id=invite.id,
        token_hash=hash_token(raw_token, settings.token_pepper),
        language=invite.language,
        mode=body.mode,
        stats_opt_in=body.stats_opt_in,
        seed=seed,
        created_at=now,
        last_activity_at=now,
        expires_at=now + timedelta(days=settings.session_ttl_days),
        status="active",
        stage="contact",
        pressure=0,
        turn_index=0,
        purpose="opening",
        full_status="pending",
    )
    db.add(session)
    invite.session_count += 1
    db.flush()

    state = engine_step(
        session_state(session),
        EngineEvent(kind=EventKind.START),
        scenario,
        Random(seed),  # nosec B311
    )[0]
    opening = _opening_line(scenario, writer, session.language, seed)
    response = turn_response(
        state,
        line_model(
            {
                "display": opening.display,
                "speak": opening.speak,
                "language": opening.language,
            }
        ),
        fallback_used=True,
        pii_warning=False,
    )
    event = TurnEvent(
        session_id=session.id,
        turn_id="start",
        turn_index=0,
        kind="start",
        participant_text="",
        label=None,
        confidence=0.5,
        stage_id=state.stage.value,
        pressure=state.pressure,
        officer_display=opening.display,
        officer_speak=opening.speak,
        officer_language=opening.language,
        fallback_used=True,
        pii_warning=False,
        status="active",
        state_json=_state_dict(state),
        response_json=dump_turn(response),
    )
    db.add(event)
    db.flush()
    return SessionCreateResponse(
        session_id=session.id,
        session_token=raw_token,
        first_turn=response,
        limits=SessionLimits(
            max_turns=settings.max_turns,
            max_duration_seconds=settings.max_duration_seconds,
            idle_timeout_seconds=settings.idle_timeout_seconds,
        ),
    )


def session_state(session: DrillSession) -> EngineState:
    """Local import avoids a cycle with the common helpers."""
    from app.services.common import state_from_session

    return state_from_session(session)


def _state_dict(state: EngineState) -> dict[str, object]:
    return asdict(state)


__all__ = ["create_invite_row", "create_session_row", "session_state"]
