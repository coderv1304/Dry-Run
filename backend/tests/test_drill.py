"""Full drill in all three languages with LLM disabled, plus latency budget."""

from __future__ import annotations

import time
from pathlib import Path

import pytest
import yaml
from fastapi.testclient import TestClient

from tests.support import new_session, turn

FIXTURES = Path(__file__).resolve().parents[2] / "tests" / "fixtures"


def _utterance(language: str, label: str, index: int = 0) -> str:
    data = yaml.safe_load((FIXTURES / f"utterances_{language}.yaml").read_text(encoding="utf-8"))
    return data["utterances"][label][index]["text"]


@pytest.mark.parametrize("language", ["en", "hi", "hinglish"])
def test_full_drill_returns_quick_then_full_debrief(client: TestClient, language: str) -> None:
    _, session_id, token = new_session(client, language=language)

    first = turn(client, session_id, token, 1, _utterance(language, "P2"))
    assert first["status"] == "active"
    assert first["officer_line"]["language"] == language

    quick = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    ).json()
    assert quick["quality"] == "quick"
    assert quick["debrief"]["quality"] == "quick"

    body = first
    index = 2
    for label in ("P3", "P4", "C1", "C2", "C3", "C4"):
        if body["status"] == "ended":
            break
        body = turn(client, session_id, token, index, _utterance(language, label))
        index += 1

    assert body["status"] == "ended"
    assert body["end_reason"] in {"complied_transfer", "hung_up", "verified_callback"}

    full = client.get(
        f"/v1/sessions/{session_id}/debrief", headers={"X-Session-Token": token}
    ).json()
    assert full["status"] == "ready"
    assert full["quality"] == "full"
    assert full["debrief"]["low_confidence"] is False
    assert full["debrief"]["events"]
    assert full["debrief"]["habit_id"] in {"hang_up", "call_back_official", "tell_family"}

    report_token = client.post(
        f"/v1/sessions/{session_id}/share",
        headers={"X-Session-Token": token},
        json={"consent": True},
    ).json()["report_token"]
    report = client.get("/v1/reports/current", headers={"X-Report-Token": report_token}).json()
    assert report["debrief"]["quality"] == "full"


def test_scripted_turn_latency_p95_under_budget(client: TestClient) -> None:
    samples: list[float] = []
    for _session in range(4):
        _, session_id, token = new_session(client)
        for index in range(1, 11):
            started = time.perf_counter()
            response = client.post(
                f"/v1/sessions/{session_id}/turn",
                headers={"X-Session-Token": token},
                json={
                    "turn_id": f"lat-{index}",
                    "expected_turn_index": index,
                    "text": "I am not sure",
                },
            )
            samples.append((time.perf_counter() - started) * 1000)
            assert response.status_code == 200
            if response.json()["status"] == "ended":
                break
    assert len(samples) >= 30
    samples.sort()
    p95 = samples[int(0.95 * (len(samples) - 1))]
    assert p95 < 300, f"p95={p95:.1f}ms"
