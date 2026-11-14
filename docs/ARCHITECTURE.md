# Architecture

## System Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CLIENTS                                     │
│                                                                      │
│  ┌─────────────┐   ┌──────────────┐   ┌──────────────────────────┐  │
│  │ Flutter App  │   │ Flutter Web  │   │ Landing Page             │  │
│  │ (Android)    │   │ (SPA, path   │   │ (static HTML/CSS/JS,     │  │
│  │              │   │  URL strat.) │   │  no framework)           │  │
│  └──────┬───────┘   └──────┬───────┘   └──────────┬───────────────┘  │
│         │                  │                       │                  │
│         └──────────┬───────┘                       │                  │
│                    │                               │                  │
│         ┌──────────▼──────────┐                    │                  │
│         │ packages/api_client │                    │                  │
│         │ (pure Dart)         │                    │                  │
│         └──────────┬──────────┘                    │                  │
└────────────────────┼───────────────────────────────┼──────────────────┘
                     │  HTTPS                        │ HTTPS
                     ▼                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        BACKEND (FastAPI)                             │
│                                                                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐   │
│  │  API Layer  │  │  Service   │  │  Engine    │  │  Providers   │   │
│  │  (routes,   │  │  Layer     │  │  (pure fn) │  │  (LLM iface) │   │
│  │  auth, val.)│  │  (effects) │  │  step()    │  │  openai_compat│  │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  │  anthropic   │   │
│        │               │               │          │  scripted    │   │
│        │               │               │          └──────┬───────┘   │
│        ▼               ▼               ▼                 │           │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                    Database (SQLite / Postgres)               │    │
│  │                    Alembic migrations                         │    │
│  └──────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

## Decisions

### A. Engine

`step(state, event, scenario, rng) -> (new_state, effects)` is a pure function. Seeded RNG per session. Effects like `request_line` are executed by the service layer; the produced officer line is persisted as an event, so replaying a session NEVER calls an LLM. **Rationale:** deterministic replay enables testing, debugging, and auditability without LLM costs.

### B. Live Path

Turn classification is DETERMINISTIC rules (pattern matching, keyword detection). The LLM only writes the officer line with a 1.5 s budget and scripted template fallback. **Rationale:** classification must be reproducible and testable without an LLM; fallback ensures the drill never stalls.

### C. Debrief

Instant baseline from rule labels (quality "quick"); at session end an LLM re-scoring job returns ONLY structured labels, confidences, and quote offsets (quality "full"). The debrief contains NO free text: sentences are rendered by clients from ids (label ids, did_well ids, one habit id from a fixed catalog: `hang_up`, `call_back_official`, `tell_family`) using reviewed ARB or YAML templates. Quotes must be verbatim substrings of the redacted participant text, else dropped. Rule vs LLM disagreement sets `low_confidence`. **Rationale:** no unreviewed LLM prose reaches the user; all text is pre-approved.

### D. Auth Model

Three token types, all 128-bit random, hashed at rest, constant-time compare, sent ONLY in headers or request bodies, never in paths or query strings:
- **Invite token** (X-Invite-Token): created by organizer, used by participant to start a session.
- **Session token** (X-Session-Token): returned at session creation, required on every session endpoint.
- **Report token** (X-Report-Token): created when participant shares, used by organizer to view report.

**Rationale:** tokens in URLs leak via referrer headers and server logs; header-only transport avoids this.

### E. Share Flow

Participant taps "Send report" → backend creates a report token → app opens OS share sheet with a report link (token in the URL fragment) → organizer opens that link. Participant can DELETE the session at any time, which invalidates the report. **Rationale:** URL fragment is not sent to the server in HTTP requests, giving an extra layer of privacy.

### F. Try It Yourself

Landing page and app offer a self-serve path that creates an invite (cohort `tryout`) and starts consent immediately, so a single person can run a drill alone. **Rationale:** removes barrier to trying the product.

### G. Consent

Four separate consent points:
1. **Practice call consent** — required before starting a session.
2. **stats_opt_in** — optional, for anonymous aggregate counts only.
3. **Share consent** — separate explicit consent at share time.
4. **Voice opt-in** — separate opt-in with disclosure that the phone's speech service may send audio to its provider.

**Rationale:** granular consent; each data use has its own opt-in.

### H. Limits

| Limit | Value |
|-------|-------|
| Max turns | 12 |
| Max session duration | 15 minutes |
| Idle timeout | 10 minutes |
| Max request body | 4 KB |
| Data retention | RETENTION_DAYS env var (default 7) |

**Rationale:** bounded resource use; short retention minimizes stored personal data.

### I. Turn Protocol

Client sends `turn_id` (UUID) and `expected_turn_index`. Repeating a `turn_id` returns the stored response and never advances state (unique constraint on `session_id + turn_id`; row lock on the session). Index mismatch returns 409 with the current index. **Rationale:** idempotent turns handle retries and network failures without corrupting state.

### J. Data

`DATABASE_URL` env var. SQLite for dev and tests, managed Postgres for production. Alembic migrations. CI runs tests on BOTH databases; locally, Postgres tests skip loudly if unavailable. **Rationale:** SQLite is zero-setup for development; Postgres for production reliability.

### K. Single Instance

Single backend instance assumption (documented). Daily LLM budget counter lives in the DB; rate limit counters may be in-memory. Client IP comes from `X-Forwarded-For` only when `TRUSTED_PROXY_COUNT` is set. **Rationale:** simplicity; no distributed coordination needed for the expected scale.

### L. Web

Path URL strategy (not hash). Token in the URL fragment, removed with `history.replaceState` after reading, kept in memory only. The static host needs an SPA rewrite rule. Self-host everything: no CDN for Flutter engine files or fonts. **Rationale:** path URLs are clean and SEO-friendly; fragment tokens are never sent to the server; self-hosting avoids third-party requests.

### M. Providers

Provider interface with two adapters:
1. `openai_compatible` — OpenAI chat completions API format.
2. `anthropic` — Anthropic messages API format.

Selected only by env: `LLM_PROVIDER`, `LLM_MODEL_PRIMARY`, `LLM_MODEL_CHEAP`, API keys, `DAILY_LLM_BUDGET_USD`.

Third tier: scripted mode with no LLM.

Backend flags: `LLM_ENABLED`, `VOICE_ENABLED`. `DEMO_MODE` is an APP BUILD FLAG ONLY (never on the backend).

**Rationale:** env-only config means no code changes to switch providers; scripted mode enables offline development and testing.

### N. Performance Budgets

| Metric | Target |
|--------|--------|
| Scripted turn p95 (server) | < 300 ms |
| LLM turn p95 (server) | < 2.0 s |
| Quick debrief p95 | < 500 ms |
| Flutter web interactive | < 6 s on mid-range phone over 4G |
| Flutter web loading state | Branded, shown immediately |

**Rationale:** these are targets to measure and report honestly, not guarantees.

### O. Failure Matrix

| Failure | Designed Behaviour |
|---------|-------------------|
| LLM provider down | Fall back to scripted template lines; set `fallback_used: true` on turn response |
| DB down | Return 503 on all endpoints; healthz reports unhealthy |
| Voice unavailable | Return chat-mode response; client shows text fallback |
| Client offline | Client queues turn locally; retries with same `turn_id` on reconnect |
| LLM budget exhausted | Switch to scripted mode for rest of day; log warning |
| Duplicate turn_id | Return stored response; do not advance state |
| Out-of-order turn_index | Return 409 with current index; client resyncs |

### P. Hosting

**Backend:** Railway (managed Postgres, no cold start with minimum instance, deploy via Dockerfile). **Rationale:** simple deploy, managed Postgres addon, always-on option.

**Static (Flutter web + landing):** Cloudflare Pages (SPA rewrite support via `_redirects`, custom headers via `_headers`, free tier). **Rationale:** global CDN, SPA rewrite built in, custom headers for CSP.

Account creation is in `docs/HUMAN_TODO.md`. Exact deploy steps documented there.

### Q. Non-Goals

Not in scope: accounts, payments, pricing, history, admin dashboards, push notifications, iOS, real call interception, analytics or third-party scripts, more than one scenario.

### R. Reference and Verification Documents

- `docs/FACTS.md`: Table of verifiable facts, values, sources, and verification status. Only human-verified facts may appear in any UI. Seeded with digital arrest scam loss estimates.
- `docs/REVIEW_NEEDED.md`: Catalog of Hindi and Hinglish phrases, translations, and officer lines awaiting native speaker review.
- `docs/LICENSES.md`: Software and asset licenses for all third-party dependencies and fonts.
- `docs/HUMAN_TODO.md`: Track tasks requiring human intervention (cloud accounts, device tests, native audio validation).
- `docs/DECISIONS.md`: Log of all architectural, tooling, and environment decisions made during project development.

