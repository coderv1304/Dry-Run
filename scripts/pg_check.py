"""Start compose Postgres, migrate it, and run the Postgres integration suite.

Run from the repository root: ``python scripts/pg_check.py``.
With ``--full`` the entire backend suite runs against Postgres instead of
SQLite. Requires a running Docker daemon.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "backend"
DEFAULT_URL = "postgresql+psycopg://dryrun:dryrun_local_password@localhost:5432/dryrun"
COMPOSE_PEPPER = "pg-check-local-pepper-not-for-production"


def _run(command: list[str], *, cwd: Path, env: dict[str, str]) -> int:
    return subprocess.run(command, cwd=cwd, env=env, check=False).returncode


def _wait_for_postgres(env: dict[str, str]) -> None:
    deadline = time.monotonic() + 90
    while time.monotonic() < deadline:
        result = subprocess.run(
            ["docker", "compose", "exec", "-T", "db", "pg_isready", "-U", "dryrun", "-d", "dryrun"],
            cwd=ROOT,
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0:
            return
        time.sleep(1)
    raise SystemExit("Postgres did not become ready within 90 seconds")


def main() -> None:
    """Run compose, Alembic, and the selected test scope."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database-url", default=os.environ.get("TEST_POSTGRES_URL", DEFAULT_URL))
    parser.add_argument("--full", action="store_true", help="run the whole suite on Postgres")
    args = parser.parse_args()

    env = os.environ.copy()
    env["TOKEN_PEPPER"] = COMPOSE_PEPPER
    env["DATABASE_URL"] = args.database_url
    env["TEST_POSTGRES_URL"] = args.database_url

    docker_ready = subprocess.run(
        ["docker", "info"], cwd=ROOT, env=env, capture_output=True, check=False
    )
    if docker_ready.returncode != 0:
        raise SystemExit("Docker daemon is not available; start Docker and retry")
    if _run(["docker", "compose", "up", "-d", "db"], cwd=ROOT, env=env) != 0:
        raise SystemExit("could not start the compose Postgres service")

    _wait_for_postgres(env)

    if _run([sys.executable, "-m", "alembic", "upgrade", "head"], cwd=BACKEND, env=env) != 0:
        raise SystemExit("Alembic migration failed")

    target = ["tests"] if args.full else ["tests/test_postgres.py"]
    code = _run(
        [sys.executable, "-m", "pytest", *target, "-q", "-p", "no:cacheprovider"],
        cwd=BACKEND,
        env=env,
    )
    if code != 0:
        raise SystemExit(code)
    scope = "full backend suite" if args.full else "Postgres integration suite"
    print(f"Postgres check passed: {scope} against {args.database_url}")


if __name__ == "__main__":
    main()
