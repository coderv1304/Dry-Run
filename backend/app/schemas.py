"""Pydantic request and response models mirroring the OpenAPI contract."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

Language = Literal["en", "hi", "hinglish"]
StageId = Literal["contact", "accusation", "isolation", "urgency", "transfer"]
LabelId = Literal["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]
EndReasonId = Literal[
    "hung_up",
    "verified_callback",
    "complied_transfer",
    "turn_cap",
    "timeout",
    "participant_ended",
]
ProblemCode = Literal[
    "invalid_token",
    "token_expired",
    "session_limit_reached",
    "turn_index_mismatch",
    "rate_limited",
    "payload_too_large",
    "consent_required",
    "session_ended",
    "validation_error",
    "internal",
]


class StrictModel(BaseModel):
    """Base model that rejects unknown fields everywhere."""

    model_config = ConfigDict(extra="forbid")


class ProblemDetail(StrictModel):
    """RFC 9457 style problem payload."""

    type: str
    title: str
    status: int
    detail: str
    code: ProblemCode


class InviteCreateRequest(StrictModel):
    """Body for creating an invite."""

    language: Language
    cohort: str | None = Field(default=None, pattern=r"^[a-z0-9-]{1,24}$")


class InviteResponse(StrictModel):
    """Invite creation response.  The raw token is shown once."""

    invite_token: str
    expires_at: datetime


class CurrentInviteResponse(StrictModel):
    """Inspection response for the current invite."""

    cohort: str | None = None
    language: str
    created_at: datetime
    expires_at: datetime


class SessionCreateRequest(StrictModel):
    """Session creation body with explicit practice consent."""

    consent: bool
    stats_opt_in: bool = False
    mode: Literal["chat", "voice"]


class OfficerLine(StrictModel):
    """The single current officer line."""

    display: str
    speak: str
    language: str


class TurnRequest(StrictModel):
    """Idempotent turn submission."""

    turn_id: str = Field(min_length=1, max_length=64)
    expected_turn_index: int = Field(ge=0)
    text: str = Field(max_length=4096)


class TurnResponse(StrictModel):
    """Turn result, including the only script text ever returned."""

    officer_line: OfficerLine | None = None
    stage_id: StageId
    pressure: int = Field(ge=0, le=3)
    status: Literal["active", "ended"]
    end_reason: EndReasonId | None = None
    turn_index: int
    fallback_used: bool
    pii_warning: bool


class SessionLimits(StrictModel):
    """Per-session limits returned at creation."""

    max_turns: int
    max_duration_seconds: int
    idle_timeout_seconds: int


class SessionCreateResponse(StrictModel):
    """Session creation response."""

    session_id: str
    session_token: str
    first_turn: TurnResponse
    limits: SessionLimits


class SessionEndRequest(StrictModel):
    """Explicit end body."""

    reason: Literal["participant_ended", "timeout"]


class ShareRequest(StrictModel):
    """Share consent body."""

    consent: bool


class ShareResponse(StrictModel):
    """Report token response."""

    report_token: str
    expires_at: datetime


class QuoteReference(StrictModel):
    """Verbatim quote offsets inside redacted participant text."""

    text: str
    start: int = Field(ge=0)
    end: int = Field(ge=0)


class DebriefEvent(StrictModel):
    """One labelled turn in the debrief."""

    turn_index: int
    label: LabelId
    confidence: float = Field(ge=0.0, le=1.0)
    quote: QuoteReference | None


class StatePathItem(StrictModel):
    """Stage reached at a turn index."""

    stage_id: StageId
    turn_index: int


class FirstCompliance(StrictModel):
    """First compliance label, if any."""

    turn_index: int
    stage_id: StageId
    label: LabelId


class DebriefContent(StrictModel):
    """All debrief data; clients render sentences from these ids."""

    quality: Literal["quick", "full"]
    low_confidence: bool
    state_path: list[StatePathItem]
    events: list[DebriefEvent]
    first_compliance: FirstCompliance | None
    did_well_ids: list[str]
    habit_id: Literal["hang_up", "call_back_official", "tell_family"]


class DebriefResponse(StrictModel):
    """Debrief envelope."""

    status: Literal["pending", "ready"]
    quality: Literal["quick", "full"]
    debrief: DebriefContent | None


class ReportResponse(StrictModel):
    """Shared report envelope."""

    report_token: str
    shared_at: datetime
    debrief: DebriefContent


class ConfigFlags(StrictModel):
    """Feature flags exposed to clients."""

    llm_enabled: bool
    voice_enabled: bool


class ConfigLimits(StrictModel):
    """Limits exposed to clients."""

    max_turns: int
    max_duration_seconds: int
    idle_timeout_seconds: int
    max_request_body_bytes: int
    retention_days: int


class ConfigResponse(StrictModel):
    """Public configuration."""

    flags: ConfigFlags
    languages: list[str]
    limits: ConfigLimits


class ScenarioGraphResponse(StrictModel):
    """Graph structure with no script text."""

    stage_ids: list[StageId]
    labels: list[LabelId]


class HealthResponse(StrictModel):
    """Probe response."""

    status: str


class EndResponse(StrictModel):
    """Explicit end response."""

    status: Literal["ended"]
    reason: str


__all__ = [
    "ConfigResponse",
    "CurrentInviteResponse",
    "DebriefContent",
    "DebriefEvent",
    "DebriefResponse",
    "EndResponse",
    "FirstCompliance",
    "HealthResponse",
    "InviteCreateRequest",
    "InviteResponse",
    "OfficerLine",
    "ProblemDetail",
    "QuoteReference",
    "ReportResponse",
    "ScenarioGraphResponse",
    "SessionCreateRequest",
    "SessionCreateResponse",
    "SessionEndRequest",
    "SessionLimits",
    "ShareRequest",
    "ShareResponse",
    "StatePathItem",
    "TurnRequest",
    "TurnResponse",
]
