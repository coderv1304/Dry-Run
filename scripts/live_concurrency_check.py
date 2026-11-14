"""Cross-process concurrency check through a real Uvicorn server.

Run from the repository root::

    python scripts/live_concurrency_check.py --spawn

``--spawn`` migrates and starts Uvicorn against Postgres, then fires racing
HTTP requests from several threads. Without ``--spawn`` pass ``--base-url``
to test an already running server. Exits non-zero on any invariant violation.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import socket
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import httpx
from sqlalchemy import create_engine, text

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "backend"
DEFAULT_URL = "postgresql+psycopg://dryrun:dryrun_local_password@localhost:5432/dryrun"
DEFAULT_PEPPER = "live-check-local-pepper-not-for-production"
WORKERS = 6


def _free_port() -> int:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return int(sock.getsockname()[1])


def _wait_for_server(base_url: str, process: subprocess.Popen[bytes] | None) -> None:
    deadline = time.monotonic() + 45
    while time.monotonic() < deadline:
        if process is not None and process.poll() is not None:
            raise SystemExit("Uvicorn exited before becoming ready")
        try:
            response = httpx.get(f"{base_url}/readyz", timeout=1.0)
            if response.status_code == 200:
                return
        except httpx.HTTPError:
            pass
        time.sleep(0.25)
    raise SystemExit("server did not become ready within 45 seconds")


def _spawn_server(database_url: str, pepper: str) -> tuple[subprocess.Popen[bytes], str]:
    env = os.environ.copy()
    env.update(
        {
            "APP_ENV": "production",
            "DATABASE_URL": database_url,
            "TOKEN_PEPPER": pepper,
            "LLM_ENABLED": "false",
            "VOICE_ENABLED": "false",
            "PURGE_INTERVAL_SECONDS": "0",
            "LOG_LEVEL": "WARNING",
            "INVITE_PER_IP_PER_HOUR": "1000",
            "INVITE_GLOBAL_DAILY_CAP": "1000",
            "TURN_PER_IP_PER_MINUTE": "1000",
            "TURN_PER_TOKEN_PER_MINUTE": "1000",
        }
    )
    migrated = subprocess.run(
        [sys.executable, "-m", "alembic", "upgrade", "head"],
        cwd=BACKEND,
        env=env,
        check=False,
    )
    if migrated.returncode != 0:
        raise SystemExit("Alembic migration failed before server start")

    port = _free_port()
    process = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "uvicorn",
            "app.main:app",
            "--host",
            "127.0.0.1",
            "--port",
            str(port),
            "--log-level",
            "warning",
        ],
        cwd=BACKEND,
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    base_url = f"http://127.0.0.1:{port}"
    _wait_for_server(base_url, process)
    return process, base_url


def _race(
    client: httpx.Client,
    url: str,
    headers: dict[str, str],
    payloads: list[dict[str, object]],
) -> list[httpx.Response]:
    barrier = threading.Barrier(len(payloads))

    def fire(payload: dict[str, object]) -> httpx.Response:
        barrier.wait(timeout=10)
        return client.post(url, headers=headers, json=payload)

    with ThreadPoolExecutor(max_workers=len(payloads)) as pool:
        return list(pool.map(fire, payloads))


def _new_session(client: httpx.Client, base_url: str) -> tuple[str, str, str]:
    invite = client.post(f"{base_url}/v1/invites", json={"language": "en"}).json()["invite_token"]
    created = client.post(
        f"{base_url}/v1/sessions",
        headers={"X-Invite-Token": invite},
        json={"consent": True, "mode": "chat"},
    )
    created.raise_for_status()
    body = created.json()
    return invite, body["session_id"], body["session_token"]


def _scalar(engine, sql: str, **params: object) -> int:
    with engine.connect() as connection:
        return int(connection.scalar(text(sql), params) or 0)


def _check_same_turn(client: httpx.Client, base_url: str, engine) -> dict[str, object]:
    _, session_id, token = _new_session(client, base_url)
    turn_id = "live-race-same"
    payload = {
        "turn_id": turn_id,
        "expected_turn_index": 1,
        "text": "I am not sure what is happening",
    }
    responses = _race(
        client,
        f"{base_url}/v1/sessions/{session_id}/turn",
        {"X-Session-Token": token},
        [payload] * WORKERS,
    )
    statuses = [response.status_code for response in responses]
    bodies = [response.json() for response in responses]
    if statuses != [200] * WORKERS:
        raise SystemExit(f"same-turn race returned statuses {statuses}")
    if any(body != bodies[0] for body in bodies):
        raise SystemExit("same-turn race returned different response bodies")

    events = _scalar(
        engine,
        "SELECT count(*) FROM turn_events WHERE session_id = :session_id "
        "AND turn_id = :turn_id",
        session_id=session_id,
        turn_id=turn_id,
    )
    turn_index = _scalar(
        engine, "SELECT turn_index FROM sessions WHERE id = :session_id", session_id=session_id
    )
    if events != 1 or turn_index != 1:
        raise SystemExit(f"same-turn race persisted events={events} turn_index={turn_index}")
    return {"requests": WORKERS, "identical": True, "events": events, "turn_index": turn_index}


def _check_distinct_turns(client: httpx.Client, base_url: str, engine) -> dict[str, object]:
    _, session_id, token = _new_session(client, base_url)
    payloads = [
        {
            "turn_id": f"live-race-distinct-{index}",
            "expected_turn_index": 1,
            "text": "I am not sure what is happening",
        }
        for index in range(WORKERS)
    ]
    responses = _race(
        client,
        f"{base_url}/v1/sessions/{session_id}/turn",
        {"X-Session-Token": token},
        payloads,
    )
    winners = [response for response in responses if response.status_code == 200]
    conflicts = [response for response in responses if response.status_code == 409]
    if len(winners) != 1 or len(conflicts) != WORKERS - 1:
        statuses = [response.status_code for response in responses]
        raise SystemExit(f"distinct-turn race returned statuses {statuses}")
    if any(response.json()["code"] != "turn_index_mismatch" for response in conflicts):
        raise SystemExit("distinct-turn race returned a non-conflict problem code")

    events = _scalar(
        engine,
        "SELECT count(*) FROM turn_events WHERE session_id = :session_id AND kind = 'participant'",
        session_id=session_id,
    )
    if events != 1:
        raise SystemExit(f"distinct-turn race persisted {events} participant events")
    return {"requests": WORKERS, "winners": len(winners), "conflicts": len(conflicts), "events": events}


def _check_invite_cap(
    client: httpx.Client, base_url: str, engine, pepper: str | None
) -> dict[str, object]:
    invite = client.post(f"{base_url}/v1/invites", json={"language": "en"}).json()["invite_token"]
    barrier = threading.Barrier(8)

    def create() -> httpx.Response:
        barrier.wait(timeout=10)
        return client.post(
            f"{base_url}/v1/sessions",
            headers={"X-Invite-Token": invite},
            json={"consent": True, "mode": "chat"},
        )

    with ThreadPoolExecutor(max_workers=8) as pool:
        responses = list(pool.map(lambda _: create(), range(8)))

    created = [response for response in responses if response.status_code == 201]
    rejected = [response for response in responses if response.status_code == 409]
    if len(created) != 3 or len(rejected) != 5:
        statuses = [response.status_code for response in responses]
        raise SystemExit(f"invite-cap race returned statuses {statuses}")
    if any(response.json()["code"] != "session_limit_reached" for response in rejected):
        raise SystemExit("invite-cap race returned a non-limit problem code")

    stored = 3
    if pepper:
        token_hash = hashlib.sha256(f"{pepper}:{invite}".encode()).hexdigest()
        stored = _scalar(
            engine,
            "SELECT count(*) FROM sessions WHERE invite_id = "
            "(SELECT id FROM invites WHERE token_hash = :token_hash)",
            token_hash=token_hash,
        )
        if stored != 3:
            raise SystemExit(f"invite-cap race persisted {stored} sessions")
    return {"requests": 8, "created": len(created), "rejected": len(rejected), "stored": stored}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database-url", default=os.environ.get("DATABASE_URL", DEFAULT_URL))
    parser.add_argument("--base-url")
    parser.add_argument("--token-pepper", default=os.environ.get("TOKEN_PEPPER"))
    parser.add_argument("--spawn", action="store_true", help="start and stop Uvicorn")
    args = parser.parse_args()

    process: subprocess.Popen[bytes] | None = None
    pepper = args.token_pepper
    base_url = args.base_url
    try:
        if args.spawn:
            pepper = pepper or DEFAULT_PEPPER
            process, base_url = _spawn_server(args.database_url, pepper)
        if not base_url:
            raise SystemExit("pass --base-url or --spawn")
        _wait_for_server(base_url, process)

        engine = create_engine(args.database_url, pool_pre_ping=True)
        try:
            with httpx.Client(timeout=30.0) as client:
                summary = {
                    "same_turn": _check_same_turn(client, base_url, engine),
                    "distinct_turns": _check_distinct_turns(client, base_url, engine),
                    "invite_cap": _check_invite_cap(client, base_url, engine, pepper),
                }
        finally:
            engine.dispose()
        print(json.dumps(summary, sort_keys=True))
        print("live cross-process concurrency check passed")
    finally:
        if process is not None:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()


if __name__ == "__main__":
    main()
