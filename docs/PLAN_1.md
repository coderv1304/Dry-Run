# Plan 1: Engine, API, Hardening

1. Read CLAUDE.md, ARCHITECTURE.md, contracts; verified gate 0.
2. Build pure engine package: types, transition table, scenario loader, classifier, replay.
3. Author trilingual scenario YAML plus review catalog and engine docs.
4. Add PII guard, deterministic classifier fixtures, and internal confusion-table script.
5. Add SQLAlchemy models, Alembic migration, token auth, persistence services.
6. Add every contract endpoint with idempotency, expiry, delete, share, report.
7. Add LLM provider adapters, validated line writer, scripted tier, budget kill switch.
8. Add rule debrief plus structured rescoring, reconciliation, quote validation.
9. Add middleware: body cap, security headers, CORS, request ids, JSON logs, timing.
10. Add per-IP and per-token limits, invite daily cap, trusted proxy parsing.
11. Add purge CLI and in-process periodic purge; verify report unreadability.
12. Add tests: engine, invariants, API, adversarial, failure matrix, contract, coverage.
13. Add Docker, compose, hashed lock, audit targets, Railway/keep-warm README.
14. Run make gate-1, drill all languages with LLM off, benchmark p95, write .gates/1.
15. Commit and tag gate-1.
