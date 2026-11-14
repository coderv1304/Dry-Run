"""Shared pytest fixtures for the backend test suite."""

from __future__ import annotations

from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.config import Settings
from app.main import create_app


@pytest.fixture()
def settings(tmp_path: Path) -> Settings:
    """Isolated SQLite database with high limits unless a test overrides them."""
    return Settings(
        env="test",
        database_url=f"sqlite:///{(tmp_path / 'dryrun.db').as_posix()}",
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
