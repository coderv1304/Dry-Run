"""End-to-end API contract, lifecycle, idempotency, and privacy tests."""

from __future__ import annotations

from datetime import timedelta

from fastapi.testclient import TestClient
from sqlalchemy import select

from app.engine.replay import replay
from app.engine.types import EngineEvent, EventKind, Label
from app.models import DrillSession, Invite, ReportToken
from app.services.debriefing import load_turns
from app.timeutil import utcnow
from tests.support import new_invite, new_session, turn


def _expire_session(client: TestClient, session_id: str) -> None:
    with client.app.state.db.transaction() as db:
        session = db.get(DrillSession, session_id)
        session.expires_at = utcnow() - timedelta(seconds=1)


def _idle_session(client: TestClient, session_id: str) -> None:
    with client.app.state.db.transaction() as db:
        session = db.get(DrillSession, session_id)
        session.last_activity_at = utcnow() - timedelta(seconds=10000)


def test_invite_validation_and_auth(client: TestClient) -> None:
    bad_language = client.post("/v1/invites", json={"language": "fr"})
    assert bad_language.status_code == 400
    assert bad_language.json()["code"] == "validation_error"
    assert bad_language.headers["content-type"] == "application/problem+json"

    extra_field = client.post("/v1/invites", json={"language": "en", "admin": True})
    assert extra_field.status_code == 400

    missing = client.get("/v1/invites/current")
    assert missing.status_code == 401
    assert missing.json()["code"] == "invalid_token"

    unknown = client.get("/v1/invites/current", headers={"X-Invite-Token": "inv_nope"})
    assert unknown.status_code == 401


def test_expired_invite_is_rejected(client: TestClient) -> None:
    invite = new_invite(client)
    with client.app.state.db.transaction() as db:
        row = db.scalar(select(Invite))
        row.expires_at = utcnow() - timedelta(seconds=1)
    response = client.get("/v1/invites/current", headers={"X-Invite-Token": invite})
    assert response.status_code == 401
    assert response.json()["code"] == "token_expired"


def test_session_consent_and_limit(client: TestClient, settings) -> None:
    invite = new_invite(client)
    no_consent = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": invite},
        json={"consent": False, "mode": "chat"},
    )
    assert no_consent.status_code == 400
    assert no_consent.json()["code"] == "consent_required"

    for _ in range(settings.max_sessions_per_invite):
        created = client.post(
            "/v1/sessions",
            headers={"X-Invite-Token": invite},
            json={"consent": True, "mode": "chat"},
        )
        assert created.status_code == 201

    over = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": invite},
        json={"consent": True, "mode": "chat"},
    )
    assert over.status_code == 409
    assert over.json()["code"] == "session_limit_reached"


def test_session_response_shape_and_opening(client: TestClient) -> None:
    _, session_id, token = new_session(client, language="hi")
    response = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    )
    assert response.status_code == 200
    assert response.json()["quality"] == "quick"

    with client.app.state.db.transaction() as db:
        session = db.get(DrillSession, session_id)
        assert session.language == "hi"
        assert session.turn_index == 0


def test_turn_idempotency_returns_identical_response(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    first = turn(client, session_id, token, 1, "I want to verify your badge")
    replay = turn(client, session_id, token, 1, "I want to verify your badge")
    assert replay == first
    assert first["stage_id"] == "contact"
    assert first["turn_index"] == 1
    assert first["officer_line"]["language"] == "en"


def test_turn_id_idempotency_ignores_text_change(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    first = turn(client, session_id, token, 1, "I will hang up", turn_id="abc")
    replay = turn(client, session_id, token, 1, "different text", turn_id="abc")
    assert replay == first


def test_duplicate_index_with_new_turn_id_conflicts(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    turn(client, session_id, token, 1, "hello there")
    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json={"turn_id": "other", "expected_turn_index": 1, "text": "hello again"},
    )
    assert response.status_code == 409
    assert response.json()["code"] == "turn_index_mismatch"


def test_only_current_officer_line_is_exposed(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    body = turn(client, session_id, token, 1, "Who are you?")
    assert set(body["officer_line"]) == {"display", "speak", "language"}
    assert "transcript" not in body
    assert "events" not in body


def test_pii_turn_forces_safety_warning(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    body = turn(client, session_id, token, 1, "My OTP is 482913")
    assert body["pii_warning"] is True
    assert "practice drill" in body["officer_line"]["display"].lower()


def test_refusal_ends_session_and_blocks_further_turns(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    body = turn(client, session_id, token, 1, "I will hang up now")
    assert body["status"] == "ended"
    assert body["end_reason"] == "hung_up"
    assert body.get("officer_line") is None

    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json={"turn_id": "late", "expected_turn_index": 2, "text": "hello"},
    )
    assert response.status_code == 409
    assert response.json()["code"] == "session_ended"


def test_explicit_end_produces_full_debrief(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    turn(client, session_id, token, 1, "I want to verify your identity")
    ended = client.post(
        f"/v1/sessions/{session_id}/end",
        headers={"X-Session-Token": token},
        json={"reason": "participant_ended"},
    )
    assert ended.status_code == 200
    assert ended.json() == {"status": "ended", "reason": "participant_ended"}

    debrief = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    )
    body = debrief.json()
    assert body["status"] == "ready"
    assert body["quality"] == "full"
    assert body["debrief"]["low_confidence"] is False
    event = body["debrief"]["events"][0]
    assert event["label"] == "P2"
    assert event["quote"]["text"].lower() == "verify"
    assert "asked_badge_number" in body["debrief"]["did_well_ids"]
    assert body["debrief"]["habit_id"] == "call_back_official"


def test_quick_debrief_has_required_deterministic_fields(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    turn(client, session_id, token, 1, "I will tell my brother")
    body = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    ).json()
    content = body["debrief"]
    assert content["quality"] == "quick"
    assert content["events"][0]["label"] == "P3"
    assert content["habit_id"] == "tell_family"
    assert content["state_path"]


def test_share_requires_consent_and_report_roundtrip(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    denied = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": False},
    )
    assert denied.status_code == 400
    assert denied.json()["code"] == "consent_required"

    shared = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": True},
    )
    assert shared.status_code == 200
    report_token = shared.json()["report_token"]

    report = client.get("/v1/reports/current", headers={"X-Report-Token": report_token})
    assert report.status_code == 200
    assert report.json()["report_token"] == report_token
    assert report.json()["debrief"]["quality"] == "quick"


def test_delete_invalidates_session_and_report(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    report_token = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": True},
    ).json()["report_token"]

    deleted = client.delete(f"/v1/sessions/{session_id}", headers={"X-Session-Token": token})
    assert deleted.status_code == 204
    assert deleted.content == b""

    assert (
        client.get(
            f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
        ).status_code
        == 401
    )
    assert (
        client.get("/v1/reports/current", headers={"X-Report-Token": report_token}).status_code
        == 401
    )


def test_session_token_is_scoped_to_path(client: TestClient) -> None:
    _, first_id, first_token = new_session(client)
    _, second_id, second_token = new_session(client)
    assert (
        client.get(
            f"/v1/sessions/{second_id}/debrief", headers={"X-Session-Token": first_token}
        ).status_code
        == 401
    )
    assert (
        client.get(
            f"/v1/sessions/{first_id}/debrief", headers={"X-Session-Token": second_token}
        ).status_code
        == 401
    )


def test_expired_session_token_is_rejected(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    _expire_session(client, session_id)
    response = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    )
    assert response.status_code == 401
    assert response.json()["code"] == "token_expired"


def test_idle_session_times_out_on_next_turn(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    _idle_session(client, session_id)
    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json={"turn_id": "late", "expected_turn_index": 1, "text": "hello"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ended"
    assert body["end_reason"] == "timeout"
    assert body.get("officer_line") is None


def test_report_expires_with_session(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    report_token = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": True},
    ).json()["report_token"]
    _expire_session(client, session_id)
    response = client.get("/v1/reports/current", headers={"X-Report-Token": report_token})
    assert response.status_code == 401


def test_report_token_expiry_is_checked(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    report_token = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": True},
    ).json()["report_token"]
    with client.app.state.db.transaction() as db:
        report = db.scalar(select(ReportToken))
        report.expires_at = utcnow() - timedelta(seconds=1)
    response = client.get("/v1/reports/current", headers={"X-Report-Token": report_token})
    assert response.status_code == 401
    assert response.json()["code"] == "token_expired"


def test_turn_cap_terminates(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    body = None
    for index in range(1, 13):
        body = turn(client, session_id, token, index, "I am not sure what to do")
    assert body is not None
    assert body["status"] == "ended"
    assert body["end_reason"] == "turn_cap"


def test_validation_error_for_bad_turn_body(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    response = client.post(
        f"/v1/sessions/{session_id}/turn",
        headers={"X-Session-Token": token},
        json={"turn_id": "", "expected_turn_index": -1, "text": ""},
    )
    assert response.status_code == 400
    assert response.json()["code"] == "validation_error"


def test_unsupported_end_reason_is_validation_error(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    response = client.post(
        f"/v1/sessions/{session_id}/end",
        headers={"X-Session-Token": token},
        json={"reason": "hung_up"},
    )
    assert response.status_code == 400
    assert response.json()["code"] == "validation_error"


def test_graph_contains_ids_only(client: TestClient) -> None:
    body = client.get("/v1/scenario/graph").json()
    assert set(body) == {"stage_ids", "labels"}
    serialized = str(body).lower()
    assert "officer" not in serialized
    assert "digital safety" not in serialized


def test_config_flags_reflect_settings(client: TestClient, settings) -> None:
    body = client.get("/v1/config").json()
    assert body["flags"] == {"llm_enabled": settings.llm_enabled, "voice_enabled": False}
    assert body["limits"]["max_request_body_bytes"] == settings.max_request_body_bytes
    assert body["languages"] == ["en", "hi", "hinglish"]


def test_persisted_events_replay_to_the_same_state(client: TestClient) -> None:
    _, session_id, token = new_session(client)
    for index, text in enumerate(
        ("I want to verify your badge", "I will tell my brother", "This is a scam"), start=1
    ):
        turn(client, session_id, token, index, text)

    with client.app.state.db.transaction() as db:
        events = load_turns(db, session_id)
        session = db.get(DrillSession, session_id)
        participant_events = [
            EngineEvent(EventKind.PARTICIPANT, Label(event.label))
            for event in events
            if event.kind == "participant" and event.label
        ]
        frames = replay(
            [EngineEvent(EventKind.START)] + participant_events,
            client.app.state.scenario,
            seed=session.seed,
        )
        final = frames[-1][0]
        assert final.stage.value == session.stage
        assert final.pressure == session.pressure
        assert final.turn_index == session.turn_index
        assert final.family_count == session.family_count
        assert final.status == session.status


def test_llm_line_cannot_alter_engine_state(client: TestClient) -> None:
    from app.llm.line_writer import LineResult

    async def wild_line(context):
        return LineResult(
            display="Totally unrelated output that tries to reset the drill.",
            speak="Totally unrelated output that tries to reset the drill.",
            language=context.language,
            fallback_used=False,
            tier="primary",
        )

    client.app.state.line_writer.generate = wild_line
    _, session_id, token = new_session(client)
    first = turn(client, session_id, token, 1, "I want to verify your badge")
    second = turn(client, session_id, token, 2, "I want to verify your badge")
    assert first["stage_id"] == "contact"
    assert second["stage_id"] == "contact"
    assert first["pressure"] == 1
    assert second["pressure"] == 2
    assert second["officer_line"]["display"].startswith("Totally unrelated")
