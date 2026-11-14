"""Shared pytest fixtures for the backend test suite."""

from __future__ import annotations

import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text

from app.config import Settings
from app.database import Database
from app.main import create_app
from app.models import Base
from tests.support import assert_safe_test_database

# Setting TEST_POSTGRES_URL runs the entire API suite against Postgres.
# tests/test_postgres.py additionally asserts the Alembic schema and
# cross-request locking semantics.
POSTGRES_TEST_URL = os.environ.get("TEST_POSTGRES_URL")

TRUNCATE_SQL = (
    "TRUNCATE TABLE turn_events, report_tokens, sessions, invites, llm_budget "
    "RESTART IDENTITY CASCADE"
)


def _reset_postgres(url: str) -> None:
    """Create missing tables and empty every row for test isolation."""
    assert_safe_test_database(url)
    database = Database(url)
    Base.metadata.create_all(database.engine)
    with database.engine.begin() as connection:
        connection.execute(text(TRUNCATE_SQL))
    database.dispose()


@pytest.fixture()
def settings(tmp_path: Path) -> Settings:
    """Isolated database with high limits unless a test overrides them."""
    database_url = POSTGRES_TEST_URL or f"sqlite:///{(tmp_path / 'dryrun.db').as_posix()}"
    if POSTGRES_TEST_URL:
        _reset_postgres(POSTGRES_TEST_URL)
    return Settings(
        env="test",
        database_url=database_url,
        token_pepper="test-pepper-not-for-production",
        auto_create_schema=True,
        invite_per_ip_per_hour=1000,
        invite_global_daily_cap=1000,
        turn_per_ip_per_minute=1000,
        turn_per_token_per_minute=1000,
        cors_origins=("https://app.example",),
    )


@pytest.fixture()
def app(settings: Settings):
    """Create an application instance with isolated state."""
    return create_app(settings)


@pytest.fixture()
def client(app):
    """Test client with lifespan management."""
    with TestClient(app) as test_client:
        yield test_client
