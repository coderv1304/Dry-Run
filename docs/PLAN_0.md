# Plan 0: Foundation, Scaffolding, Contracts, and Gates

## Goal
Establish repository layout, architectural decisions, contracts, gate tooling, and baseline CI for the Dry Run scam call drill.

## Steps
1. Write docs/PLAN_0.md (this file) and complete docs/ (FACTS.md, REVIEW_NEEDED.md, LICENSES.md, HUMAN_TODO.md, SCOPE_AND_GATES.md, ARCHITECTURE.md section R).
2. Pin Flutter version in app/.flutter-version and generate Flutter app for Android and Web (`flutter create --platforms=android,web`).
3. Record SHA256 hashes of generated icons, favicons, manifests into tool/default_asset_hashes.txt.
4. Set up packages/api_client (pure Dart) with analysis_options and contract models.
5. Set up backend/ with FastAPI skeleton, healthz/readyz, tests, and dependencies.
6. Set up landing/ with static index.html, styles.css, app.js, and content.json.
7. Write contracts/openapi.yaml (3.1), contracts/schemas/*.json, and contracts/examples/*.json (valid and invalid).
8. Write scripts/doctor.sh, scripts/check_gate.sh, and gate validation tools in tool/.
9. Create Makefile with targets (gate-0, test, lint, ci, gate-1..5) and .github/workflows/ci.yml.
10. Verify: doctor passes, openapi validates, schema examples validate, BANNED_UI has 18 items, flutter analyze & backend tests pass.
11. Generate .gates/0, commit, and tag gate-0.
