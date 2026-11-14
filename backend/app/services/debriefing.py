"""Debrief building, full re-scoring, and report projection."""

from __future__ import annotations

from collections.abc import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import Settings
from app.debrief.llm_scoring import reconcile, request_rescore
from app.debrief.rules import TurnView, build_content
from app.llm import LlmProvider
from app.llm.budget import BudgetTracker
from app.models import DrillSession, TurnEvent
from app.schemas import DebriefContent, DebriefResponse
from app.timeutil import utcnow


def load_turns(db: Session, session_id: str) -> list[TurnEvent]:
    """Load persisted turns in deterministic order."""
    return list(
        db.scalars(
            select(TurnEvent)
            .where(TurnEvent.session_id == session_id)
            .order_by(TurnEvent.turn_index)
        )
    )


def to_views(turns: Sequence[TurnEvent]) -> list[TurnView]:
    """Project ORM rows into the pure debrief input."""
    return [
        TurnView(
            turn_index=turn.turn_index,
            label=turn.label,
            confidence=turn.confidence,
            stage_id=turn.stage_id,
            text=turn.participant_text,
            quote_text=turn.quote_text,
            quote_start=turn.quote_start,
            quote_end=turn.quote_end,
        )
        for turn in turns
    ]


def quick_content(turns: Sequence[TurnEvent]) -> DebriefContent:
    """Build the immediate rule-only debrief."""
    return build_content(to_views(turns), quality="quick")


async def finalize_debrief(
    db: Session,
    session: DrillSession,
    settings: Settings,
    provider: LlmProvider | None,
    budget: BudgetTracker,
) -> None:
    """Persist quick content and one optional full re-score."""
    turns = load_turns(db, session.id)
    views = to_views(turns)
    quick = build_content(views, quality="quick")
    session.debrief_quick = quick.model_dump(mode="json")

    rescored, attempted = await request_rescore(views, provider, settings, budget)
    overrides, low_confidence = reconcile(views, rescored, attempted)
    full = build_content(
        views,
        quality="full",
        low_confidence=low_confidence,
        overrides=overrides,
    )
    session.debrief_full = full.model_dump(mode="json")
    session.full_status = "ready"
    session.low_confidence = low_confidence
    if session.ended_at is None:
        session.ended_at = utcnow()


def debrief_response(session: DrillSession, turns: Sequence[TurnEvent]) -> DebriefResponse:
    """Return full content when ready, otherwise a live quick debrief."""
    if session.status == "ended" and session.debrief_full:
        return DebriefResponse(
            status="ready",
            quality="full",
            debrief=DebriefContent.model_validate(session.debrief_full),
        )
    if session.debrief_quick:
        return DebriefResponse(
            status="ready",
            quality="quick",
            debrief=DebriefContent.model_validate(session.debrief_quick),
        )
    return DebriefResponse(
        status="ready",
        quality="quick",
        debrief=quick_content(turns),
    )


def report_content(session: DrillSession, turns: Sequence[TurnEvent]) -> DebriefContent:
    """Choose the best available debrief for a shared report."""
    if session.debrief_full:
        return DebriefContent.model_validate(session.debrief_full)
    if session.debrief_quick:
        return DebriefContent.model_validate(session.debrief_quick)
    return quick_content(turns)


__all__ = [
    "debrief_response",
    "finalize_debrief",
    "load_turns",
    "quick_content",
    "report_content",
    "to_views",
]
