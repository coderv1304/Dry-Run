"""Security, configuration, middleware, and failure-matrix tests."""

from __future__ import annotations

import logging

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.exc import OperationalError
from starlette.requests import Request

from app.config import Settings
from app.errors import ApiProblem, problem_response
from app.main import create_app
from app.security import (
    RateLimiter,
    client_ip,
    hash_token,
    new_session_id,
    new_token,
    token_matches,
)
from tests.support import new_invite, new_session, turn


class Clock:
    def __init__(self) -> None:
        self.now = 1000.0

    def __call__(self) -> float:
        return self.now


def _request(forwarded: str | None, peer: str = "9.9.9.9") -> Request:
    headers = []
    if forwarded is not None:
        headers.append((b"x-forwarded-for", forwarded.encode()))
    return Request(
        {
            "type": "http",
            "method": "GET",
            "path": "/",
            "headers": headers,
            "client": (peer, 1234),
            "scheme": "https",
            "server": ("testserver", 443),
            "query_string": b"",
        }
    )


def test_rate_limiter_window_and_retry() -> None:
    clock = Clock()
    limiter = RateLimiter(clock)
    assert limiter.allow("k", 2, 60) == (True, 0)
    clock.now += 10
    assert limiter.allow("k", 2, 60) == (True, 0)
    allowed, retry = limiter.allow("k", 2, 60)
    assert allowed is False
    assert 1 <= retry <= 60
    clock.now += 61
    assert limiter.allow("k", 2, 60)[0] is True


def test_rate_limiter_zero_limit_and_reset() -> None:
    limiter = RateLimiter(Clock())
    assert limiter.allow("k", 0, 60) == (False, 60)
    limiter.allow("one", 1, 60)
    limiter.allow("two", 1, 60)
    limiter.reset("one")
    assert limiter.allow("one", 1, 60)[0] is True
    limiter.reset()
    assert limiter.allow("two", 1, 60)[0] is True


def test_client_ip_trusts_configured_proxy_count() -> None:
    request = _request("1.1.1.1, 2.2.2.2")
    assert client_ip(request, 0) == "9.9.9.9"
    assert client_ip(request, 1) == "2.2.2.2"
    assert client_ip(request, 2) == "1.1.1.1"
    assert client_ip(request, 5) == "1.1.1.1"
    assert client_ip(_request(None), 1) == "9.9.9.9"


def test_token_helpers_are_stable_and_opaque() -> None:
    token = new_token("tok")
    assert token.startswith("tok_")
    assert token != new_token("tok")
    assert hash_token(token, "pepper") == hash_token(token, "pepper")
    assert hash_token(token, "pepper") != hash_token(token, "other")
    assert token_matches(token, hash_token(token, "pepper"), "pepper")
    assert not token_matches("wrong", hash_token(token, "pepper"), "pepper")
    assert new_session_id().startswith("ses_")


def test_production_refuses_unsafe_configuration() -> None:
    with pytest.raises(ValueError):
        Settings(env="production", database_url="sqlite:///x.db")
    with pytest.raises(ValueError):
        Settings(
            env="production",
            database_url="postgresql://user:pass@db/app",
            token_pepper="short",
        )
    with pytest.raises(ValueError):
        Settings(
            env="production",
            database_url="postgresql://user:pass@db/app",
            token_pepper="a" * 32,
            llm_enabled=True,
            llm_api_key=None,
        )
    safe = Settings(
        env="production",
        database_url="postgresql://user:pass@db/app",
        token_pepper="a" * 32,
    )
    assert safe.env == "production"


def test_settings_from_env_parses_values() -> None:
    settings = Settings.from_env(
        {
            "APP_ENV": "test",
            "DATABASE_URL": "sqlite:///x.db",
            "LLM_ENABLED": "yes",
            "LLM_TIMEOUT_SECONDS": "2.5",
            "MAX_TURNS": "7",
            "CORS_ORIGINS": "https://a.example, https://b.example",
            "AUTO_CREATE_SCHEMA": "true",
        }
    )
    assert settings.llm_enabled is True
    assert settings.llm_timeout_seconds == 2.5
    assert settings.max_turns == 7
    assert settings.cors_origins == ("https://a.example", "https://b.example")
    assert settings.auto_create_schema is True


def test_problem_response_shape() -> None:
    response = problem_response(ApiProblem(401, "invalid_token", "Invalid token", "No token."))
    assert response.status_code == 401
    assert response.headers["content-type"] == "application/problem+json"


def test_security_headers_and_timing(client: TestClient) -> None:
    invite = new_invite(client)
    response = client.get("/v1/invites/current", headers={"X-Invite-Token": invite})
    assert response.headers["Strict-Transport-Security"].startswith("max-age=31536000")
    assert response.headers["X-Content-Type-Options"] == "nosniff"
    assert response.headers["X-Frame-Options"] == "DENY"
    assert response.headers["Referrer-Policy"] == "no-referrer"
    assert response.headers["Cache-Control"] == "no-store"
    assert response.headers["Server-Timing"].startswith("app;dur=")
    assert response.headers["X-Request-ID"]


def test_request_id_is_echoed(client: TestClient) -> None:
    response = client.get("/healthz", headers={"X-Request-ID": "abc123"})
    assert response.headers["X-Request-ID"] == "abc123"


def test_public_health_has_no_store_exception(client: TestClient) -> None:
    response = client.get("/healthz")
    assert "Cache-Control" not in response.headers


def test_body_limit_returns_413(client: TestClient) -> None:
    response = client.post(
        "/v1/invites",
        content=b'{"language":"en","cohort":"' + b"a" * 5000 + b'"}',
        headers={"Content-Type": "application/json"},
    )
    assert response.status_code == 413
    assert response.json()["code"] == "payload_too_large"


def test_cors_allowlist(client: TestClient) -> None:
    allowed = client.options(
        "/v1/invites",
        headers={
            "Origin": "https://app.example",
            "Access-Control-Request-Method": "POST",
        },
    )
    assert allowed.status_code == 200
    assert allowed.headers["access-control-allow-origin"] == "https://app.example"

    denied = client.options(
        "/v1/invites",
        headers={
            "Origin": "https://evil.example",
            "Access-Control-Request-Method": "POST",
        },
    )
    assert denied.headers.get("access-control-allow-origin") is None


def test_readyz_reports_database_failure(client: TestClient, monkeypatch) -> None:
    def fail() -> None:
        raise OperationalError("select 1", {}, Exception("down"))

    monkeypatch.setattr(client.app.state.db, "check", fail)
    response = client.get("/readyz")
    assert response.status_code == 503
    assert response.json() == {"status": "unavailable"}


def test_database_error_maps_to_503(client: TestClient, monkeypatch) -> None:
    def broken_transaction():
        raise OperationalError("insert", {}, Exception("down"))

    monkeypatch.setattr(client.app.state.db, "transaction", broken_transaction)
    response = client.post("/v1/invites", json={"language": "en"})
    assert response.status_code == 503
    assert response.json()["code"] == "internal"


def test_invite_per_ip_rate_limit() -> None:
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="test-pepper-not-for-production",
        auto_create_schema=True,
        invite_per_ip_per_hour=2,
        invite_global_daily_cap=100,
    )
    with TestClient(create_app(settings)) as client:
        assert client.post("/v1/invites", json={"language": "en"}).status_code == 201
        assert client.post("/v1/invites", json={"language": "en"}).status_code == 201
        blocked = client.post("/v1/invites", json={"language": "en"})
        assert blocked.status_code == 429
        assert blocked.json()["code"] == "rate_limited"
        assert blocked.headers["Retry-After"]


def test_global_daily_invite_cap() -> None:
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="test-pepper-not-for-production",
        auto_create_schema=True,
        invite_per_ip_per_hour=1000,
        invite_global_daily_cap=1,
    )
    with TestClient(create_app(settings)) as client:
        assert client.post("/v1/invites", json={"language": "en"}).status_code == 201
        blocked = client.post("/v1/invites", json={"language": "hi"})
        assert blocked.status_code == 429


def test_turn_per_token_rate_limit() -> None:
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="test-pepper-not-for-production",
        auto_create_schema=True,
        turn_per_ip_per_minute=100,
        turn_per_token_per_minute=1,
    )
    with TestClient(create_app(settings)) as client:
        _, session_id, token = new_session(client)
        assert turn(client, session_id, token, 1, "hello")["status"] == "active"
        blocked = client.post(
            f"/v1/sessions/{session_id}/turn",
            headers={"X-Session-Token": token},
            json={"turn_id": "t2", "expected_turn_index": 2, "text": "again"},
        )
        assert blocked.status_code == 429


def test_logs_never_contain_raw_pii(client: TestClient, caplog) -> None:
    _, session_id, token = new_session(client)
    with caplog.at_level(logging.INFO):
        turn(client, session_id, token, 1, "My OTP is 482913")
    joined = " ".join(record.getMessage() for record in caplog.records)
    for record in caplog.records:
        joined += " " + str(getattr(record, "path", ""))
    assert "482913" not in joined
