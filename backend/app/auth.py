"""Header-only token resolution with expiry and ownership checks."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from fastapi import Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import Settings
from app.errors import ApiProblem
from app.models import DrillSession, Invite, ReportToken
from app.security import token_matches
from app.timeutil import ensure_utc, utcnow


def header(request: Request, name: str) -> str:
    """Read a required token header, refusing query-string transport."""
    value = request.headers.get(name, "").strip()
    if not value:
        raise ApiProblem(401, "invalid_token", "Invalid token", f"{name} header is required.")
    return value


def _expired(value: datetime) -> bool:
    return ensure_utc(value) <= utcnow()


@dataclass(frozen=True, slots=True)
class InviteContext:
    """A verified invite and its raw token."""

    invite: Invite
    raw_token: str


@dataclass(frozen=True, slots=True)
class SessionContext:
    """A verified session and its raw token."""

    session: DrillSession
    raw_token: str


def resolve_invite(db: Session, raw: str, settings: Settings) -> Invite:
    """Resolve an invite token or raise a 401 problem."""
    invite = db.scalar(select(Invite).where(Invite.token_hash == _hash(raw, settings)))
    if invite is None or not token_matches(raw, invite.token_hash, settings.token_pepper):
        raise ApiProblem(401, "invalid_token", "Invalid token", "Invite token is invalid.")
    if _expired(invite.expires_at):
        raise ApiProblem(401, "token_expired", "Token expired", "Invite token has expired.")
    return invite


def resolve_session(
    db: Session, session_id: str, raw: str, settings: Settings
) -> DrillSession:
    """Resolve a session token scoped to the path session id."""
    session = db.get(DrillSession, session_id)
    if session is None or not token_matches(raw, session.token_hash, settings.token_pepper):
        raise ApiProblem(401, "invalid_token", "Invalid token", "Session token is invalid.")
    if _expired(session.expires_at):
        raise ApiProblem(401, "token_expired", "Token expired", "Session token has expired.")
    return session


def resolve_report(db: Session, raw: str, settings: Settings) -> ReportToken:
    """Resolve a report token and ensure its session still exists."""
    report = db.scalar(
        select(ReportToken).where(ReportToken.token_hash == _hash(raw, settings))
    )
    if report is None or not token_matches(raw, report.token_hash, settings.token_pepper):
        raise ApiProblem(401, "invalid_token", "Invalid token", "Report token is invalid.")
    if _expired(report.expires_at):
        raise ApiProblem(401, "token_expired", "Token expired", "Report token has expired.")
    session = db.get(DrillSession, report.session_id)
    if session is None or _expired(session.expires_at):
        raise ApiProblem(401, "invalid_token", "Invalid token", "This report is no longer available.")
    return report


def _hash(raw: str, settings: Settings) -> str:
    from app.security import hash_token

    return hash_token(raw, settings.token_pepper)


__all__ = [
    "InviteContext",
    "SessionContext",
    "header",
    "resolve_invite",
    "resolve_report",
    "resolve_session",
]
