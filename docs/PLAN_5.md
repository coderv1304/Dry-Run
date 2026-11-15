# Plan 5: judge ready, red teamed

Objective: prove each known weakness is handled, then hand over a repo a stranger can run in ten minutes.

## Order

1. `scripts/claims_lint.py` first, because copy fixes ripple through ARB, landing and README.
2. Tests that prove behaviour: engine isolation from LLM output, classifier quotes and confidence, copy rules on debrief text, chaos matrix, rate limits, secret hygiene.
3. Scripts: `scripts/chaos.sh`, `scripts/export_volunteer_stats.py`, `scripts/voice_latency.py`, `tool/secrets_scan.py`, `scripts/preflight.py`.
4. Documents: weakness report, what exists, volunteer protocol, ethics, scope, visual review, build log, runbook, pitch, README.
5. `make preflight`, then `make gate-5`.

## Decisions

- Claims lint treats the disclaimer form as allowed: "not protection" and "practice, not protection" pass, a bare promise fails.
- The heavy suites run once inside `make preflight` and print a pass or fail table, so the judge sees one command and one table.
- Chaos drill is a real pytest module plus a shell wrapper, so a failure is a test failure rather than a printed message.
- No numbers appear in the volunteer export beyond counts, and the script refuses cohorts smaller than three sessions.
- Visual review is a checklist per screenshot rather than prose, so a human can tick it without trusting the author.

## Risk

- Flutter and pip audit are the slow, environment sensitive steps; the table names them separately so a skip is visible.
