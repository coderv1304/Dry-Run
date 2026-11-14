"""Session termination and report sharing services."""

from __future__ import annotations

from collections.abc import Sequence
from datetime import timedelta

from sqlalchemy.orm import Session

from app.config import Settings
from app.errors import ApiProblem
from app.llm import LlmProvider
from app.llm.budget import BudgetTracker
from app.models import DrillSession, ReportToken, TurnEvent
from app.schemas import DebriefContent, EndResponse, ReportResponse, ShareResponse
from app.security import hash_token, new_token
from app.services.debriefing import finalize_debrief, load_turns, report_content
from app.timeutil import ensure_utc, utcnow


async def end_session(
    db: Session,
    session: DrillSession,
    settings: Settings,
    reason: str,
    provider: LlmProvider | None,
    budget: BudgetTracker,
) -> EndResponse:
    """End an active session and produce its full debrief."""
    if session.status != "ended":
        session.status = "ended"
        session.end_reason = reason
        session.purpose = "closing"
        session.ended_at = utcnow()
        await finalize_debrief(db, session, settings, provider, budget)
    return EndResponse(status="ended", reason=session.end_reason or reason)


def create_report(
    db: Session,
    session: DrillSession,
    settings: Settings,
    consent: bool,
) -> ShareResponse:
    """Create a report token after explicit share consent."""
    if not consent:
        raise ApiProblem(
            400,
            "consent_required",
            "Consent required",
            "Explicit share consent is required.",
        )
    session.share_consent = True
    now = utcnow()
    latest = min(
        now + timedelta(days=settings.report_ttl_days),
        ensure_utc(session.expires_at),
    )
    raw = new_token("rep")
    db.add(
        ReportToken(
            token_hash=hash_token(raw, settings.token_pepper),
            session_id=session.id,
            created_at=now,
            shared_at=now,
            expires_at=latest,
        )
    )
    db.flush()
    return ShareResponse(report_token=raw, expires_at=latest)


def report_response(
    db: Session,
    report: ReportToken,
    session: DrillSession,
    raw_token: str,
) -> ReportResponse:
    """Build a report, or refuse when the session is gone or expired."""
    if session.status == "ended" and ensure_utc(session.expires_at) <= utcnow():
        raise ApiProblem(401, "invalid_token", "Invalid token", "This report is no longer available.")
    turns: Sequence[TurnEvent] = load_turns(db, session.id)
    content: DebriefContent = report_content(session, turns)
    return ReportResponse(
        report_token=raw_token,
        shared_at=report.shared_at,
        debrief=content,
    )


__all__ = ["create_report", "end_session", "report_response"]
