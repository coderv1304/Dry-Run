"""SQLAlchemy models for invites, sessions, turns, reports, and budget."""

from __future__ import annotations

from datetime import date, datetime
from typing import Any

from sqlalchemy import (
    JSON,
    BigInteger,
    Boolean,
    Date,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

from app.timeutil import utcnow


class Base(DeclarativeBase):
    """Declarative base shared by the app and Alembic."""


class Invite(Base):
    """A single-use invite that may start up to three sessions."""

    __tablename__ = "invites"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    language: Mapped[str] = mapped_column(String(16))
    cohort: Mapped[str | None] = mapped_column(String(24), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    session_count: Mapped[int] = mapped_column(Integer, default=0)

    sessions: Mapped[list[DrillSession]] = relationship(back_populates="invite")


class DrillSession(Base):
    """One practice drill and its deterministic engine state."""

    __tablename__ = "sessions"

    id: Mapped[str] = mapped_column(String(48), primary_key=True)
    invite_id: Mapped[int] = mapped_column(ForeignKey("invites.id", ondelete="CASCADE"), index=True)
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    language: Mapped[str] = mapped_column(String(16))
    mode: Mapped[str] = mapped_column(String(16))
    stats_opt_in: Mapped[bool] = mapped_column(Boolean, default=False)
    share_consent: Mapped[bool] = mapped_column(Boolean, default=False)
    seed: Mapped[int] = mapped_column(BigInteger)

    status: Mapped[str] = mapped_column(String(16), default="active")
    stage: Mapped[str] = mapped_column(String(16), default="contact")
    pressure: Mapped[int] = mapped_column(Integer, default=0)
    turn_index: Mapped[int] = mapped_column(Integer, default=0)
    complied_once: Mapped[bool] = mapped_column(Boolean, default=False)
    verification_count: Mapped[int] = mapped_column(Integer, default=0)
    family_count: Mapped[int] = mapped_column(Integer, default=0)
    hesitation_count: Mapped[int] = mapped_column(Integer, default=0)
    last_label: Mapped[str | None] = mapped_column(String(8), nullable=True)
    purpose: Mapped[str] = mapped_column(String(32), default="opening")
    pii_warning: Mapped[bool] = mapped_column(Boolean, default=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    last_activity_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    end_reason: Mapped[str | None] = mapped_column(String(32), nullable=True)

    debrief_quick: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    debrief_full: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    full_status: Mapped[str] = mapped_column(String(16), default="pending")
    low_confidence: Mapped[bool] = mapped_column(Boolean, default=False)

    invite: Mapped[Invite] = relationship(back_populates="sessions")
    turns: Mapped[list[TurnEvent]] = relationship(
        back_populates="session", cascade="all, delete-orphan", order_by="TurnEvent.turn_index"
    )
    reports: Mapped[list[ReportToken]] = relationship(
        back_populates="session", cascade="all, delete-orphan"
    )


class TurnEvent(Base):
    """An immutable turn record: redacted input, labels, and officer output."""

    __tablename__ = "turn_events"
    __table_args__ = (
        UniqueConstraint("session_id", "turn_id", name="uq_turn_session_turn_id"),
        UniqueConstraint("session_id", "turn_index", name="uq_turn_session_turn_index"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.id", ondelete="CASCADE"), index=True
    )
    turn_id: Mapped[str] = mapped_column(String(64))
    turn_index: Mapped[int] = mapped_column(Integer)
    kind: Mapped[str] = mapped_column(String(16), default="participant")
    participant_text: Mapped[str] = mapped_column(Text, default="")
    label: Mapped[str | None] = mapped_column(String(8), nullable=True)
    confidence: Mapped[float] = mapped_column(Float, default=0.5)
    quote_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    quote_start: Mapped[int | None] = mapped_column(Integer, nullable=True)
    quote_end: Mapped[int | None] = mapped_column(Integer, nullable=True)
    stage_id: Mapped[str] = mapped_column(String(16))
    pressure: Mapped[int] = mapped_column(Integer)
    officer_display: Mapped[str | None] = mapped_column(Text, nullable=True)
    officer_speak: Mapped[str | None] = mapped_column(Text, nullable=True)
    officer_language: Mapped[str | None] = mapped_column(String(16), nullable=True)
    fallback_used: Mapped[bool] = mapped_column(Boolean, default=True)
    pii_warning: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[str] = mapped_column(String(16), default="active")
    end_reason: Mapped[str | None] = mapped_column(String(32), nullable=True)
    state_json: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    response_json: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    session: Mapped[DrillSession] = relationship(back_populates="turns")


class ReportToken(Base):
    """A share token that becomes unusable when the session disappears."""

    __tablename__ = "report_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    session_id: Mapped[str] = mapped_column(
        ForeignKey("sessions.id", ondelete="CASCADE"), index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    shared_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    session: Mapped[DrillSession] = relationship(back_populates="reports")


class LlmBudget(Base):
    """Daily LLM spend and call counter, shared by every request."""

    __tablename__ = "llm_budget"

    day: Mapped[date] = mapped_column(Date, primary_key=True)
    spent_usd: Mapped[float] = mapped_column(Float, default=0.0)
    calls: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


__all__ = ["Base", "DrillSession", "Invite", "LlmBudget", "ReportToken", "TurnEvent"]
