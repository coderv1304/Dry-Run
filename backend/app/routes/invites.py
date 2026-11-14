"""Invite creation and inspection routes."""

from __future__ import annotations

from fastapi import APIRouter, Request, status

from app.auth import header, resolve_invite
from app.deps import enforce_invite_limits, enforce_ip_limit, settings_of
from app.schemas import CurrentInviteResponse, InviteCreateRequest, InviteResponse
from app.services.sessions import create_invite_row

router = APIRouter(prefix="/v1/invites", tags=["invites"])


@router.post("", response_model=InviteResponse, status_code=status.HTTP_201_CREATED)
def create_invite(request: Request, body: InviteCreateRequest) -> InviteResponse:
    """Create an invite after per-IP and global daily checks."""
    enforce_invite_limits(request)
    settings = settings_of(request)
    with request.app.state.db.transaction() as db:
        invite, raw = create_invite_row(db, settings, body.language, body.cohort)
        return InviteResponse(invite_token=raw, expires_at=invite.expires_at)


@router.get("/current", response_model=CurrentInviteResponse)
def current_invite(request: Request) -> CurrentInviteResponse:
    """Inspect the invite token supplied in the header."""
    enforce_ip_limit(request, "invite_current")
    settings = settings_of(request)
    raw = header(request, "X-Invite-Token")
    with request.app.state.db.transaction() as db:
        invite = resolve_invite(db, raw, settings)
        return CurrentInviteResponse(
            cohort=invite.cohort,
            language=invite.language,
            created_at=invite.created_at,
            expires_at=invite.expires_at,
        )


__all__ = ["router"]
