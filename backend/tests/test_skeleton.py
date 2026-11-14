"""Backend skeleton tests."""

import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_healthz():
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_readyz():
    resp = client.get("/readyz")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ready"}


def test_config():
    resp = client.get("/v1/config")
    assert resp.status_code == 200
    data = resp.json()
    assert "flags" in data
    assert "languages" in data
    assert "limits" in data
    assert data["limits"]["max_turns"] == 12


def test_scenario_graph():
    resp = client.get("/v1/scenario/graph")
    assert resp.status_code == 200
    data = resp.json()
    assert data["stage_ids"] == ["contact", "accusation", "isolation", "urgency", "transfer"]
    assert "P1" in data["labels"]
    assert "C1" in data["labels"]


def test_invites_flow():
    # Create invite
    resp = client.post("/v1/invites", json={"language": "en", "cohort": "test-cohort"})
    assert resp.status_code == 201
    data = resp.json()
    assert "invite_token" in data
    token = data["invite_token"]

    # Current invite requires header
    resp_unauth = client.get("/v1/invites/current")
    assert resp_unauth.status_code == 401
    assert resp_unauth.headers["content-type"] == "application/problem+json"

    # Current invite with header
    resp_auth = client.get("/v1/invites/current", headers={"X-Invite-Token": token})
    assert resp_auth.status_code == 200
    assert "language" in resp_auth.json()


def test_session_lifecycle():
    # Missing consent fails
    resp_no_consent = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": "test_invite"},
        json={"consent": False, "mode": "chat"},
    )
    assert resp_no_consent.status_code == 400
    assert resp_no_consent.json()["code"] == "consent_required"

    # Create session
    resp = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": "test_invite"},
        json={"consent": True, "stats_opt_in": False, "mode": "chat"},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert "session_id" in data
    assert "session_token" in data
    assert "first_turn" in data
    session_id = data["session_id"]
    session_token = data["session_token"]

    # Turn submission with index mismatch
    resp_turn_mismatch = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": session_token},
        json={"turn_id": "turn-1", "expected_turn_index": 99, "text": "hello"},
    )
    assert resp_turn_mismatch.status_code == 409
    assert resp_turn_mismatch.json()["code"] == "turn_index_mismatch"

    # Turn submission valid
    resp_turn = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": session_token},
        json={"turn_id": "turn-1", "expected_turn_index": 1, "text": "Who is this?"},
    )
    assert resp_turn.status_code == 200
    assert resp_turn.json()["status"] == "active"

    # Debrief
    resp_debrief = client.get(
        f"/v1/sessions/{session_id}/debrief",
        headers={"X-Session-Token": session_token},
    )
    assert resp_debrief.status_code == 200
    assert resp_debrief.json()["quality"] == "quick"

    # Share
    resp_share = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": session_token},
        json={"consent": True},
    )
    assert resp_share.status_code == 200
    assert "report_token" in resp_share.json()

    # Delete session
    resp_del = client.delete(
        f"/v1/sessions/{session_id}",
        headers={"X-Session-Token": session_token},
    )
    assert resp_del.status_code == 204
