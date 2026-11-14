# Scope, Gates, and Feature Flags

## Shipped Path Requirements
Per Standing Rule 3 (CLAUDE.md), no TODOs, stubs, `pass` bodies, fake data, or commented-out code may exist on shipped paths. Unfinished optional work is disabled behind feature flags and documented below.

## Gates Definition

| Gate ID | Target Name | Owner | Verification Scope | Status |
| :--- | :--- | :--- | :--- | :--- |
| `0` | `gate-0` | Prompt 0 | Scaffolding, contracts, gates, docs, doctor, skeleton tests | IN PROGRESS |
| `1` | `gate-1` | Prompt 1 | Pure engine state machine, deterministic rules, replay without LLM | Owned by Prompt 1 |
| `2` | `gate-2` | Prompt 2 | Backend API endpoints, session auth, turn processing, sqlite/postgres | Owned by Prompt 2 |
| `3` | `gate-3` | Prompt 3 | LLM provider adapters, fallback lines, daily budget enforcement | Owned by Prompt 3 |
| `3b` | `gate-3b` | Prompt 3b | Debrief scoring engine, quote extraction, rule vs LLM agreement | Owned by Prompt 3b |
| `4` | `gate-4` | Prompt 4 | Flutter app (Android + Web), pure Dart API client, UI flows | Owned by Prompt 4 |
| `4b` | `gate-4b` | Prompt 4b | Voice input/output integration, OS share sheet, Web SPA token cleanup | Owned by Prompt 4b |
| `5` | `gate-5` | Prompt 5 | Landing page, self-serve drill runner, end-to-end integration | Owned by Prompt 5 |

## Feature Flags

| Flag | Layer | Allowed Values | Default | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `LLM_ENABLED` | Backend (env) | `true`, `false` | `false` | When false, service layer uses pre-scripted officer dialogue lines |
| `VOICE_ENABLED` | Backend (env) | `true`, `false` | `false` | When false, server returns chat mode text exclusively |
| `DEMO_MODE` | Flutter App (build flag) | `true`, `false` | `false` | APP BUILD FLAG ONLY; never exists on backend |
| `STATS_OPT_IN` | Backend / Client | `true`, `false` | `false` | Enables anonymous aggregate drill statistics collection |
