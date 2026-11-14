# Deploying the Dry Run backend

The backend ships as one non-root container image with Postgres as the only
managed dependency. The image runs Alembic migrations before starting Uvicorn.

## Build and run locally

```sh
cp .env.example .env
python -m venv .venv
.venv/Scripts/activate            # Windows; use source .venv/bin/activate elsewhere
pip install --require-hashes -r backend/requirements-dev.lock
cd backend
python -m alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

Docker Compose brings up Postgres and the API together:

```sh
TOKEN_PEPPER="$(python -c 'import secrets; print(secrets.token_urlsafe(48))')" docker compose up --build
curl http://localhost:8000/healthz
```

## Postgres concurrency verification

SQLite is fine for fast unit tests but does not exercise row locks. With Docker
running, verify the real database path:

```sh
make pg-check    # compose Postgres + Alembic + tests/test_postgres.py
make pg-live     # spawn Uvicorn, race requests from a separate client process
python scripts/pg_check.py --full   # whole backend suite on Postgres
```

The checks assert that a duplicate `turn_id` race returns identical responses
and persists one event, that distinct turn ids racing for one index produce one
200 plus 409 conflicts, and that eight simultaneous session creations still
stop at the three-session invite cap. Locked rows are refreshed with
`populate_existing` so the check cannot pass on a stale in-memory object.

## Railway (recommended)

1. Create a Railway project and add the Postgres plugin.
2. Add this repository as a service. Railway detects `Dockerfile`.
3. Set variables:
   - `APP_ENV=production`
   - `DATABASE_URL=${{Postgres.DATABASE_URL}}`
   - `TOKEN_PEPPER` to at least 32 random characters
   - `CORS_ORIGINS` to the exact client origin
   - `TRUSTED_PROXY_COUNT=1`
   - `LLM_ENABLED=false` unless a provider key and budget are configured
   - `LLM_API_KEY` only when `LLM_ENABLED=true`
4. Deploy. The container runs `alembic upgrade head` then Uvicorn on `$PORT`.
5. Point the platform health check at `/healthz` (cheap, no database I/O).
   Use `/readyz` for deployment gating because it performs `SELECT 1`.
6. Enable an always-on instance (or a minimum of one replica) so the first
   participant of the day does not pay a cold-start penalty. If the platform
   only offers idle sleep, schedule a monitor to GET `/healthz` every 5 minutes.

## Production checklist

- `APP_ENV=production` refuses SQLite, a weak `TOKEN_PEPPER`, or LLM enabled
  without a key.
- Run `python -m app.purge` on a schedule as a second safety net; the app also
  runs an in-process purge loop every `PURGE_INTERVAL_SECONDS`.
- Keep `DAILY_LLM_BUDGET_USD` and the `LLM_KILL_SWITCH` under operator control.
- Terminate TLS at the platform proxy and keep `TRUSTED_PROXY_COUNT` equal to
  the number of proxies that append to `X-Forwarded-For`.
- Never log request bodies. Tokens live only in headers and are stored hashed.
- `/v1/sessions/{id}/debrief` is unreadable after deletion, token expiry, or
  retention purge; shared report tokens stop working at the same time.

## Keep warm

The drill is latency sensitive only for scripted turns, which stay well under
the 300 ms p95 budget once the process is warm. To avoid platform cold starts:

- run at least one always-on instance in production;
- keep the container's `HEALTHCHECK` enabled;
- if the host sleeps idle services, ping `/healthz` every 5 minutes from an
  uptime monitor;
- do not warm up the LLM; when enabled, the first call is bounded by
  `LLM_TIMEOUT_SECONDS` and falls back to reviewed scripted lines.
