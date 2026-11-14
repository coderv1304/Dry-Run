"""Dry Run Backend FastAPI Application Skeleton."""

from typing import Any, Dict, List, Optional
from fastapi import FastAPI, Header, HTTPException, Request, Response, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

app = FastAPI(
    title="Dry Run API",
    version="1.0.0",
    description="Backend service for Dry Run digital arrest scam simulation drill.",
)

# Constants & Enums
STAGE_IDS = ["contact", "accusation", "isolation", "urgency", "transfer"]
LABELS = ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]
END_REASONS = [
    "hung_up",
    "verified_callback",
    "complied_transfer",
    "turn_cap",
    "timeout",
    "participant_ended",
]
HABIT_IDS = ["hang_up", "call_back_official", "tell_family"]
DID_WELL_IDS = [
    "asked_badge_number",
    "refused_private_call",
    "refused_money_transfer",
    "recognized_urgency_tactic",
]


class ProblemDetail(BaseModel):
    type: str = "about:blank"
    title: str
    status: int
    detail: str
    code: str


def problem_response(status_code: int, title: str, detail: str, code: str) -> JSONResponse:
    content = ProblemDetail(
        type=f"https://dryrun.in/errors/{code}",
        title=title,
        status=status_code,
        detail=detail,
        code=code,
    ).model_dump()
    return JSONResponse(
        status_code=status_code,
        content=content,
        media_type="application/problem+json",
    )


# Health checks
@app.get("/healthz", status_code=status.HTTP_200_OK)
def healthz() -> Dict[str, str]:
    return {"status": "ok"}


@app.get("/readyz", status_code=status.HTTP_200_OK)
def readyz() -> Dict[str, str]:
    return {"status": "ready"}


# Config
@app.get("/v1/config", status_code=status.HTTP_200_OK)
def get_config() -> Dict[str, Any]:
    return {
        "flags": {
            "llm_enabled": False,
            "voice_enabled": False,
        },
        "languages": ["en", "hi", "hinglish"],
        "limits": {
            "max_turns": 12,
            "max_duration_seconds": 900,
            "idle_timeout_seconds": 600,
            "max_request_body_bytes": 4096,
            "retention_days": 7,
        },
    }


# Scenario graph
@app.get("/v1/scenario/graph", status_code=status.HTTP_200_OK)
def get_scenario_graph() -> Dict[str, Any]:
    return {
        "stage_ids": STAGE_IDS,
        "labels": LABELS,
    }


# Schemas for endpoints
class InviteCreateRequest(BaseModel):
    language: str = Field(..., pattern="^(en|hi|hinglish)$")
    cohort: Optional[str] = Field(None, pattern="^[a-z0-9-]{1,24}$")


class SessionCreateRequest(BaseModel):
    consent: bool = Field(..., description="Practice drill consent")
    stats_opt_in: bool = False
    mode: str = Field(..., pattern="^(chat|voice)$")


class TurnRequest(BaseModel):
    turn_id: str
    expected_turn_index: int
    text: str


class SessionEndRequest(BaseModel):
    reason: str = Field(..., pattern="^(participant_ended|timeout)$")


class ShareRequest(BaseModel):
    consent: bool


# Invite endpoints
@app.post("/v1/invites", status_code=status.HTTP_201_CREATED)
def create_invite(req: InviteCreateRequest) -> Dict[str, Any]:
    return {
        "invite_token": "inv_0123456789abcdef0123456789abcdef",
        "expires_at": "2026-11-21T12:00:00Z",
    }


@app.get("/v1/invites/current")
def get_current_invite(x_invite_token: Optional[str] = Header(None, alias="X-Invite-Token")) -> Any:
    if not x_invite_token:
        return problem_response(401, "Invalid Token", "X-Invite-Token header is required", "invalid_token")
    return {
        "cohort": "tryout",
        "language": "en",
        "created_at": "2026-11-14T12:00:00Z",
        "expires_at": "2026-11-21T12:00:00Z",
    }


# Session endpoints
@app.post("/v1/sessions", status_code=status.HTTP_201_CREATED)
def create_session(
    req: SessionCreateRequest,
    x_invite_token: Optional[str] = Header(None, alias="X-Invite-Token"),
) -> Any:
    if not x_invite_token:
        return problem_response(401, "Invalid Token", "X-Invite-Token header is required", "invalid_token")
    if not req.consent:
        return problem_response(400, "Consent Required", "Participant consent is required to start a drill", "consent_required")

    return {
        "session_id": "ses_0123456789abcdef0123456789abcdef",
        "session_token": "tok_0123456789abcdef0123456789abcdef",
        "first_turn": {
            "officer_line": {
                "display": "Namaskar, this is Inspector Sharma from Crime Branch. Can you confirm your identity?",
                "speak": "Namaskar, this is Inspector Sharma from Crime Branch. Can you confirm your identity?",
                "language": "hinglish",
            },
            "stage_id": "contact",
            "pressure": 0,
            "status": "active",
            "turn_index": 0,
            "fallback_used": True,
            "pii_warning": False,
        },
        "limits": {
            "max_turns": 12,
            "max_duration_seconds": 900,
            "idle_timeout_seconds": 600,
        },
    }


@app.post("/v1/sessions/{session_id}/turn")
def post_turn(
    session_id: str,
    req: TurnRequest,
    x_session_token: Optional[str] = Header(None, alias="X-Session-Token"),
) -> Any:
    if not x_session_token:
        return problem_response(401, "Invalid Token", "X-Session-Token header is required", "invalid_token")
    if req.expected_turn_index != 1:
        return problem_response(409, "Turn Index Mismatch", "Expected turn index does not match server state", "turn_index_mismatch")

    return {
        "officer_line": {
            "display": "Your Aadhaar card was used to register a SIM card linked to illegal financial transactions.",
            "speak": "Your Aadhaar card was used to register a SIM card linked to illegal financial transactions.",
            "language": "en",
        },
        "stage_id": "accusation",
        "pressure": 1,
        "status": "active",
        "turn_index": 1,
        "fallback_used": True,
        "pii_warning": False,
    }


@app.post("/v1/sessions/{session_id}/end")
def end_session(
    session_id: str,
    req: SessionEndRequest,
    x_session_token: Optional[str] = Header(None, alias="X-Session-Token"),
) -> Any:
    if not x_session_token:
        return problem_response(401, "Invalid Token", "X-Session-Token header is required", "invalid_token")
    return {"status": "ended", "reason": req.reason}


@app.get("/v1/sessions/{session_id}/debrief")
def get_debrief(
    session_id: str,
    x_session_token: Optional[str] = Header(None, alias="X-Session-Token"),
) -> Any:
    if not x_session_token:
        return problem_response(401, "Invalid Token", "X-Session-Token header is required", "invalid_token")
    return {
        "status": "ready",
        "quality": "quick",
        "debrief": {
            "quality": "quick",
            "low_confidence": False,
            "state_path": [
                {"stage_id": "contact", "turn_index": 0},
                {"stage_id": "accusation", "turn_index": 1},
            ],
            "events": [
                {
                    "turn_index": 1,
                    "label": "C1",
                    "confidence": 0.88,
                    "quote": {
                        "text": "my aadhaar is",
                        "start": 0,
                        "end": 13,
                    },
                }
            ],
            "first_compliance": {
                "turn_index": 1,
                "stage_id": "accusation",
                "label": "C1",
            },
            "did_well_ids": ["asked_badge_number"],
            "habit_id": "hang_up",
        },
    }


@app.post("/v1/sessions/{session_id}/share")
def share_session(
    session_id: str,
    req: ShareRequest,
    x_session_token: Optional[str] = Header(None, alias="X-Session-Token"),
) -> Any:
    if not x_session_token:
        return problem_response(401, "Invalid Token", "X-Session-Token header is required", "invalid_token")
    if not req.consent:
        return problem_response(400, "Consent Required", "Explicit share consent is required", "consent_required")
    return {
        "report_token": "rep_0123456789abcdef0123456789abcdef",
        "expires_at": "2026-11-21T12:00:00Z",
    }


@app.delete("/v1/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_session(
    session_id: str,
    x_session_token: Optional[str] = Header(None, alias="X-Session-Token"),
) -> Response:
    if not x_session_token:
        return problem_response(401, "Invalid Token", "X-Session-Token header is required", "invalid_token")
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@app.get("/v1/reports/current")
def get_report(
    x_report_token: Optional[str] = Header(None, alias="X-Report-Token"),
) -> Any:
    if not x_report_token:
        return problem_response(401, "Invalid Token", "X-Report-Token header is required", "invalid_token")
    return {
        "report_token": x_report_token,
        "shared_at": "2026-11-14T12:00:00Z",
        "debrief": {
            "quality": "quick",
            "low_confidence": False,
            "state_path": [
                {"stage_id": "contact", "turn_index": 0},
            ],
            "events": [],
            "first_compliance": None,
            "did_well_ids": ["asked_badge_number"],
            "habit_id": "hang_up",
        },
    }
