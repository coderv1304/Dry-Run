"""Small helpers shared by API tests."""

from __future__ import annotations

from urllib.parse import urlparse

from fastapi.testclient import TestClient


def assert_safe_test_database(url: str) -> None:
    """Refuse to truncate anything that is not clearly a local test database."""
    parsed = urlparse(url)
    host = (parsed.hostname or "").lower()
    name = (parsed.path or "").lstrip("/")
    if host in {"localhost", "127.0.0.1", "::1"} or "test" in name.lower():
        return
    raise RuntimeError(
        "refusing to truncate a non-local database; use a localhost Postgres "
        "or a database whose name contains 'test'"
    )


def new_invite(client: TestClient, language: str = "en", cohort: str | None = "tryout") -> str:
    """Create an invite and return its raw token."""
    body: dict[str, str] = {"language": language}
    if cohort is not None:
        body["cohort"] = cohort
    response = client.post("/v1/invites", json=body)
    assert response.status_code == 201, response.text
    return response.json()["invite_token"]


def new_session(
    client: TestClient, language: str = "en", mode: str = "chat"
) -> tuple[str, str, str]:
    """Create a session and return (invite, session_id, session_token)."""
    invite = new_invite(client, language)
    response = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": invite},
        json={"consent": True, "mode": mode},
    )
    assert response.status_code == 201, response.text
    body = response.json()
    return invite, body["session_id"], body["session_token"]


def turn(
    client: TestClient,
    session_id: str,
    token: str,
    index: int,
    text: str,
    turn_id: str | None = None,
) -> dict:
    """Submit one turn and return JSON."""
    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json={
            "turn_id": turn_id or f"turn-{index}",
            "expected_turn_index": index,
            "text": text,
        },
    )
    assert response.status_code == 200, response.text
    return response.json()
