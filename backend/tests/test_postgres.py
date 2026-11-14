"""Postgres-only integration checks: migrations, locking, and idempotency.

These tests are skipped unless ``TEST_POSTGRES_URL`` points at a Postgres
database with the Alembic schema applied (``alembic upgrade head``). The
``pg-check`` make target starts compose Postgres, migrates, and runs them.
"""

from __future__ import annotations

import os
import threading
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import pytest
from alembic.config import Config
from alembic.script import ScriptDirectory
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import func, select, text
from sqlalchemy.exc import ProgrammingError

from app.config import Settings
from app.main import create_app
from app.models import DrillSession, Invite, TurnEvent
from tests.support import assert_safe_test_database, new_invite, new_session

POSTGRES_URL = os.environ.get("TEST_POSTGRES_URL")

pytestmark = pytest.mark.skipif(
    POSTGRES_URL is None,
    reason="set TEST_POSTGRES_URL to run Postgres integration tests",
)

BACKEND_ROOT = Path(__file__).resolve().parents[1]
TRUNCATE_SQL = (
    "TRUNCATE TABLE turn_events, report_tokens, sessions, invites, llm_budget "
    "RESTART IDENTITY CASCADE"
)


def _settings() -> Settings:
    """Production-style settings that skip auto schema creation."""
    assert POSTGRES_URL is not None
    return Settings(
        env="production",
        database_url=POSTGRES_URL,
        token_pepper="postgres-integration-pepper-0123456789",
        auto_create_schema=False,
        purge_interval_seconds=0,
        log_level="WARNING",
        invite_per_ip_per_hour=1000,
        invite_global_daily_cap=1000,
        turn_per_ip_per_minute=1000,
        turn_per_token_per_minute=1000,
    )


@pytest.fixture()
def app() -> FastAPI:
    """Migrated Postgres app with empty tables for each test."""
    application = create_app(_settings())
    assert POSTGRES_URL is not None
    assert_safe_test_database(POSTGRES_URL)
    try:
        with application.state.db.engine.begin() as connection:
            connection.execute(text(TRUNCATE_SQL))
    except ProgrammingError as exc:  # pragma: no cover - only on a bare database
        pytest.fail(
            "Postgres schema missing; run `python -m alembic upgrade head` "
            f"with DATABASE_URL set before these tests ({exc})"
        )
    return application


@pytest.fixture()
def client(app: FastAPI):
    """Test client with lifespan management."""
    with TestClient(app) as test_client:
        yield test_client


def _migration_head() -> str:
    config = Config(str(BACKEND_ROOT / "alembic.ini"))
    config.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    head = ScriptDirectory.from_config(config).get_current_head()
    assert head is not None
    return head


def test_database_is_postgres_and_schema_is_current(client: TestClient) -> None:
    """The suite really runs on Postgres and Alembic is at head."""
    db = client.app.state.db
    assert db.engine.dialect.name == "postgresql"
    with db.engine.connect() as connection:
        version = connection.scalar(text("SELECT version_num FROM alembic_version"))
    assert version == _migration_head()


def _post_turn(
    client: TestClient,
    session_id: str,
    token: str,
    payload: dict[str, object],
) -> tuple[int, dict[str, object]]:
    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json=payload,
    )
    return response.status_code, response.json()


def _race(client: TestClient, payloads: list[dict[str, object]], session_id: str, token: str):
    """Fire every payload at the same instant from separate threads."""
    barrier = threading.Barrier(len(payloads))

    def fire(payload: dict[str, object]) -> tuple[int, dict[str, object]]:
        barrier.wait(timeout=10)
        return _post_turn(client, session_id, token, payload)

    with ThreadPoolExecutor(max_workers=len(payloads)) as pool:
        return list(pool.map(fire, payloads))


def test_concurrent_same_turn_id_returns_one_persisted_event(client: TestClient) -> None:
    """A duplicate turn id race yields identical responses and one event row."""
    _, session_id, token = new_session(client)
    payload = {
        "turn_id": "race-identical",
        "expected_turn_index": 1,
        "text": "I am not sure what is happening",
    }
    results = _race(client, [payload] * 4, session_id, token)

    assert [status for status, _ in results] == [200, 200, 200, 200]
    bodies = [body for _, body in results]
    assert all(body == bodies[0] for body in bodies)

    with client.app.state.db.transaction() as db:
        count = db.scalar(
            select(func.count())
            .select_from(TurnEvent)
            .where(TurnEvent.session_id == session_id, TurnEvent.turn_id == "race-identical")
        )
        assert count == 1
        session = db.get(DrillSession, session_id)
        assert session is not None
        assert session.turn_index == 1


def test_concurrent_distinct_turn_ids_allow_exactly_one(client: TestClient) -> None:
    """Distinct turn ids racing for the same index: one wins, the rest get 409."""
    _, session_id, token = new_session(client)
    payloads = [
        {
            "turn_id": f"race-distinct-{index}",
            "expected_turn_index": 1,
            "text": "I am not sure what is happening",
        }
        for index in range(4)
    ]
    results = _race(client, payloads, session_id, token)

    statuses = sorted(status for status, _ in results)
    assert statuses == [200, 409, 409, 409]
    for status, body in results:
        if status == 409:
            assert body["code"] == "turn_index_mismatch"
            assert "detail" in body

    with client.app.state.db.transaction() as db:
        count = db.scalar(
            select(func.count())
            .select_from(TurnEvent)
            .where(TurnEvent.session_id == session_id, TurnEvent.kind == "participant")
        )
        assert count == 1


def test_concurrent_session_creation_respects_invite_limit(client: TestClient) -> None:
    """The invite row lock keeps the three-session limit under a race."""
    invite = new_invite(client)
    limit = client.app.state.settings.max_sessions_per_invite
    barrier = threading.Barrier(8)

    def create() -> int:
        barrier.wait(timeout=10)
        response = client.post(
            "/v1/sessions",
            headers={"X-Invite-Token": invite},
            json={"consent": True, "mode": "chat"},
        )
        return response.status_code

    with ThreadPoolExecutor(max_workers=8) as pool:
        statuses = list(pool.map(lambda _: create(), range(8)))

    assert statuses.count(201) == limit
    assert statuses.count(409) == 8 - limit

    with client.app.state.db.transaction() as db:
        stored = db.scalar(select(func.count()).select_from(DrillSession))
        row = db.scalar(select(Invite))
        assert stored == limit
        assert row is not None
        assert row.session_count == limit
