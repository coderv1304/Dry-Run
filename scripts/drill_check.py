"""Offline three-language drill check with LLM disabled.

Run from the repository root: ``python scripts/drill_check.py``.
Exits non-zero if any language fails to return a quick and then full debrief.
"""

from __future__ import annotations

import sys
from pathlib import Path

import yaml
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.config import Settings  # noqa: E402
from app.main import create_app  # noqa: E402

SEQUENCE = ("P2", "P3", "P4", "C1", "C2", "C3", "C4")
FIXTURES = ROOT / "tests" / "fixtures"


def utterance(language: str, label: str) -> str:
    """Return the first reviewed fixture utterance for a label."""
    data = yaml.safe_load((FIXTURES / f"utterances_{language}.yaml").read_text(encoding="utf-8"))
    return data["utterances"][label][0]["text"]


def run_language(client: TestClient, language: str) -> dict[str, object]:
    """Run one full drill and return a small summary."""
    invite = client.post("/v1/invites", json={"language": language, "cohort": "drill"}).json()[
        "invite_token"
    ]
    created = client.post(
        "/v1/sessions",
        headers={"X-Invite-Token": invite},
        json={"consent": True, "mode": "chat"},
    )
    created.raise_for_status()
    session_id = created.json()["session_id"]
    token = created.json()["session_token"]
    headers = {"X-Session-Token": token}

    body = None
    index = 1
    for label in SEQUENCE:
        response = client.post(
            f"/v1/sessions/{session_id}/turn",
            headers=headers,
            json={
                "turn_id": f"drill-{index}",
                "expected_turn_index": index,
                "text": utterance(language, label),
            },
        )
        response.raise_for_status()
        body = response.json()
        if index == 1:
            quick = client.get(f"/v1/sessions/{session_id}/debrief", headers=headers).json()
            assert quick["status"] == "ready" and quick["quality"] == "quick", quick
        if body["status"] == "ended":
            break
        index += 1

    if body is None or body["status"] != "ended":
        ended = client.post(
            f"/v1/sessions/{session_id}/end",
            headers=headers,
            json={"reason": "participant_ended"},
        )
        ended.raise_for_status()
        reason = ended.json()["reason"]
    else:
        reason = body["end_reason"]

    full = client.get(f"/v1/sessions/{session_id}/debrief", headers=headers).json()
    assert full["status"] == "ready" and full["quality"] == "full", full
    assert full["debrief"]["low_confidence"] is False, full
    return {
        "language": language,
        "end_reason": reason,
        "turns": full["debrief"]["state_path"][-1]["turn_index"],
        "events": len(full["debrief"]["events"]),
        "habit_id": full["debrief"]["habit_id"],
    }


def main() -> None:
    """Run all three languages against an in-process app."""
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="drill-check-pepper-not-production",
        auto_create_schema=True,
        llm_enabled=False,
        log_level="WARNING",
        invite_per_ip_per_hour=100,
        invite_global_daily_cap=100,
        turn_per_ip_per_minute=100,
        turn_per_token_per_minute=100,
    )
    with TestClient(create_app(settings)) as client:
        for language in ("en", "hi", "hinglish"):
            summary = run_language(client, language)
            print(
                f"{language}: ended={summary['end_reason']} turns={summary['turns']} "
                f"events={summary['events']} habit={summary['habit_id']}"
            )
    print("drill check passed for en, hi, hinglish with LLM disabled")


if __name__ == "__main__":
    main()
