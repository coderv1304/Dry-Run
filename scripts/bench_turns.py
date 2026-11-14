"""Benchmark scripted turn latency through the real HTTP stack.

Run from the repository root: ``python scripts/bench_turns.py``.
Fails when p95 exceeds 300 ms with the LLM disabled.
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.config import Settings  # noqa: E402
from app.main import create_app  # noqa: E402

BUDGET_MS = 300.0
SAMPLES = 120


def main() -> None:
    """Measure scripted turns and print p50/p95/max."""
    settings = Settings(
        env="test",
        database_url="sqlite:///:memory:",
        token_pepper="bench-pepper-not-production",
        auto_create_schema=True,
        llm_enabled=False,
        log_level="WARNING",
        invite_per_ip_per_hour=1000,
        invite_global_daily_cap=1000,
        turn_per_ip_per_minute=1000,
        turn_per_token_per_minute=1000,
    )
    durations: list[float] = []
    with TestClient(create_app(settings)) as client:
        while len(durations) < SAMPLES:
            invite = client.post("/v1/invites", json={"language": "en"}).json()["invite_token"]
            created = client.post(
                "/v1/sessions",
                headers={"X-Invite-Token": invite},
                json={"consent": True, "mode": "chat"},
            ).json()
            session_id = created["session_id"]
            token = created["session_token"]
            for index in range(1, 11):
                started = time.perf_counter()
                response = client.post(
                    f"/v1/sessions/{session_id}/turn",
                    headers={"X-Session-Token": token},
                    json={
                        "turn_id": f"bench-{index}",
                        "expected_turn_index": index,
                        "text": "I am not sure what is happening",
                    },
                )
                durations.append((time.perf_counter() - started) * 1000)
                response.raise_for_status()
                if response.json()["status"] == "ended":
                    break
    ordered = sorted(durations)
    result = {
        "samples": len(ordered),
        "p50_ms": round(ordered[len(ordered) // 2], 2),
        "p95_ms": round(ordered[int(0.95 * (len(ordered) - 1))], 2),
        "max_ms": round(ordered[-1], 2),
        "budget_ms": BUDGET_MS,
    }
    print(json.dumps(result, sort_keys=True))
    if result["p95_ms"] >= BUDGET_MS:
        raise SystemExit(f"scripted turn p95 {result['p95_ms']}ms exceeded {BUDGET_MS}ms")


if __name__ == "__main__":
    main()
