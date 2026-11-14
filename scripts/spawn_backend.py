#!/usr/bin/env python3
"""Start a scripted (no-LLM) Dry Run backend on a free local port.

Usage: python scripts/spawn_backend.py [--port PORT]

Returns 0 on success and writes the chosen port to stdout as the last line
so callers can parse it, e.g.:

    port=$(python scripts/spawn_backend.py | tail -1)
"""
from __future__ import annotations

import argparse
import os
import secrets
import socket
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "backend"


def free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return int(s.getsockname()[1])


def wait_for_server(base_url: str, process: subprocess.Popen[bytes], deadline: float) -> None:
    while time.monotonic() < deadline:
        try:
            import urllib.request
            req = urllib.request.Request(f"{base_url}/healthz")
            if urllib.request.urlopen(req, timeout=1).status == 200:
                return
        except Exception:
            pass
        time.sleep(0.3)
    process.terminate()
    raise SystemExit(f"Backend on {base_url} did not become ready")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=free_port(), help="Port to bind on (default: free port)")
    args = parser.parse_args()

    pepper = os.environ.get("TOKEN_PEPPER") or secrets.token_hex(32)
    env = os.environ.copy()
    env.setdefault("APP_ENV", "development")
    env.setdefault("DATABASE_URL", "sqlite:///./dryrun.db")
    env["TOKEN_PEPPER"] = pepper
    env["LLM_ENABLED"] = "false"
    env["VOICE_ENABLED"] = "false"
    env["AUTO_CREATE_SCHEMA"] = "true"
    env["LOG_LEVEL"] = "warning"
    env["INVITE_PER_IP_PER_HOUR"] = "1000"
    env["INVITE_GLOBAL_DAILY_CAP"] = "1000"
    env["TURN_PER_IP_PER_MINUTE"] = "1000"
    env["TURN_PER_TOKEN_PER_MINUTE"] = "1000"
    env["MAX_TURNS"] = "12"
    env["MAX_DURATION_SECONDS"] = "900"
    env["IDLE_TIMEOUT_SECONDS"] = "600"
    env["MAX_REQUEST_BODY_BYTES"] = "4096"
    env["RETENTION_DAYS"] = "7"
    env["INVITE_TTL_DAYS"] = "7"
    env["SESSION_TTL_DAYS"] = "7"
    env["REPORT_TTL_DAYS"] = "7"
    env["SCENARIO_PATH"] = str(ROOT / "backend" / "data" / "scenario.json")

    proc = subprocess.run(
        [sys.executable, "-m", "alembic", "upgrade", "head"],
        cwd=BACKEND,
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if proc.returncode != 0:
        raise SystemExit("Alembic migration failed before server start")

    process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", str(args.port), "--log-level", "warning"],
        cwd=BACKEND,
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    base_url = f"http://127.0.0.1:{args.port}"
    wait_for_server(base_url, process, time.monotonic() + 20)
    print(base_url, flush=True)


if __name__ == "__main__":
    main()
