"""Session lifecycle and turn routes."""

from __future__ import annotations

from fastapi import APIRouter, Request, Response, status
from sqlalchemy import select

from app.auth import header, resolve_invite, resolve_session
from app.deps import enforce_ip_limit, enforce_turn_limits, settings_of
from app.models import DrillSession, Invite
from app.schemas import (
    DebriefResponse,
    EndResponse,
    SessionCreateRequest,
    SessionCreateResponse,
    SessionEndRequest,
    ShareRequest,
    ShareResponse,
    TurnRequest,
    TurnResponse,
)
from app.services.debriefing import debrief_response, load_turns
from app.services.session_lifecycle import create_report, end_session
from app.services.sessions import create_session_row
from app.services.turns import process_participant_turn

router = APIRouter(prefix="/v1/sessions", tags=["sessions"])


@router.post("", response_model=SessionCreateResponse, status_code=status.HTTP_201_CREATED)
def create_session(request: Request, body: SessionCreateRequest) -> SessionCreateResponse:
    """Create a drill session bound to the invite token."""
    enforce_ip_limit(request, "session_create")
    settings = settings_of(request)
    raw = header(request, "X-Invite-Token")
    with request.app.state.db.transaction() as db:
        invite = resolve_invite(db, raw, settings)
        invite = db.scalar(select(Invite).where(Invite.id == invite.id).with_for_update()) or invite
        return create_session_row(
            db,
            settings,
            request.app.state.scenario,
            request.app.state.line_writer,
            invite,
            body,
        )


@router.post(
    "/{id}/turn",
    response_model=TurnResponse,
    response_model_exclude_none=True,
)
async def submit_turn(id: str, request: Request, body: TurnRequest) -> TurnResponse:
    """Submit one idempotent participant turn."""
    raw = header(request, "X-Session-Token")
    enforce_turn_limits(request, raw)
    settings = settings_of(request)
    with request.app.state.db.transaction() as db:
        drill = resolve_session(db, id, raw, settings)
        return await process_participant_turn(
            db,
            drill,
            settings,
            request.app.state.scenario,
            request.app.state.line_writer,
            body,
            request.app.state.provider,
            request.app.state.budget,
        )


@router.post("/{id}/end", response_model=EndResponse)
async def finish_session(id: str, request: Request, body: SessionEndRequest) -> EndResponse:
    """Explicitly end a drill."""
    enforce_ip_limit(request, "session_end")
    settings = settings_of(request)
    raw = header(request, "X-Session-Token")
    with request.app.state.db.transaction() as db:
        drill = resolve_session(db, id, raw, settings)
        drill = (
            db.scalar(select(DrillSession).where(DrillSession.id == id).with_for_update())
            or drill
        )
        return await end_session(
            db,
            drill,
            settings,
            body.reason,
            request.app.state.provider,
            request.app.state.budget,
        )


@router.get("/{id}/debrief", response_model=DebriefResponse)
def get_debrief(id: str, request: Request) -> DebriefResponse:
    """Return the quick debrief while active and the full one after end."""
    enforce_ip_limit(request, "session_debrief")
    settings = settings_of(request)
    raw = header(request, "X-Session-Token")
    with request.app.state.db.transaction() as db:
        drill = resolve_session(db, id, raw, settings)
        return debrief_response(drill, load_turns(db, drill.id))


@router.post("/{id}/share", response_model=ShareResponse)
def share_session(id: str, request: Request, body: ShareRequest) -> ShareResponse:
    """Create a report token after explicit share consent."""
    enforce_ip_limit(request, "session_share")
    settings = settings_of(request)
    raw = header(request, "X-Session-Token")
    with request.app.state.db.transaction() as db:
        drill = resolve_session(db, id, raw, settings)
        return create_report(db, drill, settings, body.consent)


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_session(id: str, request: Request) -> Response:
    """Delete a session, its turns, and every report token."""
    enforce_ip_limit(request, "session_delete")
    settings = settings_of(request)
    raw = header(request, "X-Session-Token")
    with request.app.state.db.transaction() as db:
        drill = resolve_session(db, id, raw, settings)
        db.delete(drill)
        db.flush()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


__all__ = ["router"]
