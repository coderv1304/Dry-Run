"""Retention purge tests."""

from __future__ import annotations

from datetime import timedelta

from sqlalchemy import func, select

from app.config import Settings
from app.database import Database
from app.models import DrillSession, Invite, LlmBudget, ReportToken, TurnEvent
from app.purge import purge_expired
from app.security import hash_token, new_token
from app.timeutil import utcnow


def _database() -> tuple[Database, Settings]:
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="test-pepper-not-for-production",
        retention_days=7,
    )
    database = Database(settings.database_url)
    database.create_all()
    return database, settings


def _seed(database: Database, settings: Settings, *, expired: bool) -> None:
    now = utcnow()
    offset = timedelta(days=-30) if expired else timedelta(days=1)
    with database.transaction() as db:
        invite = Invite(
            token_hash=hash_token(new_token("inv"), settings.token_pepper),
            language="en",
            created_at=now + offset,
            expires_at=now + offset,
            session_count=1,
        )
        db.add(invite)
        db.flush()
        session = DrillSession(
            id=f"ses_{'old' if expired else 'new'}",
            invite_id=invite.id,
            token_hash=hash_token(new_token("tok"), settings.token_pepper),
            language="en",
            mode="chat",
            seed=1,
            created_at=now + offset,
            last_activity_at=now + offset,
            expires_at=now + offset,
            ended_at=now + offset,
            status="ended",
        )
        db.add(session)
        db.flush()
        db.add(
            TurnEvent(
                session_id=session.id,
                turn_id="start",
                turn_index=0,
                stage_id="contact",
                pressure=0,
            )
        )
        db.add(
            ReportToken(
                token_hash=hash_token(new_token("rep"), settings.token_pepper),
                session_id=session.id,
                created_at=now + offset,
                shared_at=now + offset,
                expires_at=now + offset,
            )
        )
        db.add(
            LlmBudget(
                day=(now + timedelta(days=-40 if expired else 0)).date(),
                spent_usd=1.0,
                calls=2,
            )
        )


def test_purge_removes_expired_rows_and_keeps_fresh_ones() -> None:
    database, settings = _database()
    _seed(database, settings, expired=True)
    _seed(database, settings, expired=False)
    counts = purge_expired(database, settings)
    assert counts["reports"] >= 1
    assert counts["sessions"] >= 1
    assert counts["invites"] >= 1
    assert counts["budget_rows"] >= 1
    with database.transaction() as db:
        assert db.get(DrillSession, "ses_old") is None
        assert db.get(DrillSession, "ses_new") is not None
        assert db.scalar(select(func.count()).select_from(TurnEvent)) == 1
        assert db.scalar(select(func.count()).select_from(ReportToken)) == 1
    database.dispose()


def test_purge_is_idempotent() -> None:
    database, settings = _database()
    _seed(database, settings, expired=True)
    first = purge_expired(database, settings)
    second = purge_expired(database, settings)
    assert first["sessions"] >= 1
    assert second["sessions"] == 0
    database.dispose()
