"""Initial Dry Run schema.

Revision ID: 0001
Revises:
Create Date: 2026-11-14
"""

from __future__ import annotations

import sqlalchemy as sa

from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create every table used by the drill."""
    op.create_table(
        "invites",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("token_hash", sa.String(length=128), nullable=False, unique=True),
        sa.Column("language", sa.String(length=16), nullable=False),
        sa.Column("cohort", sa.String(length=24), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("session_count", sa.Integer(), nullable=False, server_default="0"),
    )
    op.create_index("ix_invites_token_hash", "invites", ["token_hash"], unique=True)

    op.create_table(
        "sessions",
        sa.Column("id", sa.String(length=48), primary_key=True),
        sa.Column(
            "invite_id",
            sa.Integer(),
            sa.ForeignKey("invites.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("token_hash", sa.String(length=128), nullable=False, unique=True),
        sa.Column("language", sa.String(length=16), nullable=False),
        sa.Column("mode", sa.String(length=16), nullable=False),
        sa.Column("stats_opt_in", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("share_consent", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("seed", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False, server_default="active"),
        sa.Column("stage", sa.String(length=16), nullable=False, server_default="contact"),
        sa.Column("pressure", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("turn_index", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("complied_once", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("verification_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("family_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("hesitation_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_label", sa.String(length=8), nullable=True),
        sa.Column("purpose", sa.String(length=32), nullable=False, server_default="opening"),
        sa.Column("pii_warning", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_activity_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("end_reason", sa.String(length=32), nullable=True),
        sa.Column("debrief_quick", sa.JSON(), nullable=True),
        sa.Column("debrief_full", sa.JSON(), nullable=True),
        sa.Column("full_status", sa.String(length=16), nullable=False, server_default="pending"),
        sa.Column("low_confidence", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.create_index("ix_sessions_invite_id", "sessions", ["invite_id"])
    op.create_index("ix_sessions_token_hash", "sessions", ["token_hash"], unique=True)

    op.create_table(
        "turn_events",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "session_id",
            sa.String(length=48),
            sa.ForeignKey("sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("turn_id", sa.String(length=64), nullable=False),
        sa.Column("turn_index", sa.Integer(), nullable=False),
        sa.Column("kind", sa.String(length=16), nullable=False, server_default="participant"),
        sa.Column("participant_text", sa.Text(), nullable=False, server_default=""),
        sa.Column("label", sa.String(length=8), nullable=True),
        sa.Column("confidence", sa.Float(), nullable=False, server_default="0.5"),
        sa.Column("quote_text", sa.Text(), nullable=True),
        sa.Column("quote_start", sa.Integer(), nullable=True),
        sa.Column("quote_end", sa.Integer(), nullable=True),
        sa.Column("stage_id", sa.String(length=16), nullable=False),
        sa.Column("pressure", sa.Integer(), nullable=False),
        sa.Column("officer_display", sa.Text(), nullable=True),
        sa.Column("officer_speak", sa.Text(), nullable=True),
        sa.Column("officer_language", sa.String(length=16), nullable=True),
        sa.Column("fallback_used", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("pii_warning", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("status", sa.String(length=16), nullable=False, server_default="active"),
        sa.Column("end_reason", sa.String(length=32), nullable=True),
        sa.Column("state_json", sa.JSON(), nullable=True),
        sa.Column("response_json", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("session_id", "turn_id", name="uq_turn_session_turn_id"),
        sa.UniqueConstraint("session_id", "turn_index", name="uq_turn_session_turn_index"),
    )
    op.create_index("ix_turn_events_session_id", "turn_events", ["session_id"])

    op.create_table(
        "report_tokens",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("token_hash", sa.String(length=128), nullable=False, unique=True),
        sa.Column(
            "session_id",
            sa.String(length=48),
            sa.ForeignKey("sessions.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("shared_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_report_tokens_token_hash", "report_tokens", ["token_hash"], unique=True)
    op.create_index("ix_report_tokens_session_id", "report_tokens", ["session_id"])

    op.create_table(
        "llm_budget",
        sa.Column("day", sa.Date(), primary_key=True),
        sa.Column("spent_usd", sa.Float(), nullable=False, server_default="0"),
        sa.Column("calls", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )


def downgrade() -> None:
    """Drop every table in dependency order."""
    op.drop_table("llm_budget")
    op.drop_table("report_tokens")
    op.drop_table("turn_events")
    op.drop_table("sessions")
    op.drop_table("invites")
