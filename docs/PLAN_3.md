# Plan for Prompt 3

## Scope
- Build full Flutter flow for participant & organizer screens.
- Implement pure‑Dart API client with Dio and full contract.
- Contract tests for all examples.
- End‑to‑end numeric test using *scripts/spawn_backend.py*.
- Create `docs/PERF.md` and `.gates/3`.
- Update Makefile target `gate-3` to run all checks.

## Key Deliverables
1. **API client** – add `dio` library, implement all CRUD,  `DebriefResponse` envelope.
2. **Test suite** – contract examples, end‑to‑end test `packages/api_client/test/e2e.dart`.
3. **Flutter module** – routing, Riverpod, go_router, localization, screens, share_plus.
4. **Web hardening assets** – CSP meta, no‑sniff, safe header file.
5. **Documentation** – `docs/PERF.md` with build‑size, launch time.

## Work Partition
- **Task A**: API client implementation + contract tests.
- **Task B**: End‑to‑end test.
- **Task C**: Flutter app build (routing, state, screens).
- **Task D**: Web assets & headers.
- **Task E**: `gate-3` target, `docs/PERF.md`, `.gates/3`.

## Dependencies
- `packages/api_client` needs `dio` (`0.18.0`).
- Flutter 3.47.9, Dart 3.13.7.
- Backend must start with `scripts/spawn_backend.py`.

## Gate Strategy
- Run `scripts/check_gate.sh 2` before starting.
- After each milestone run `make test`.
- Each code change must satisfy `make lint` & `filepath` checks.

## Risks & Mitigations
- **Turn index logic** – use `first_turn.turn_index + 1` exactly.
- **Backend scenario path** – patch `SCENARIO_PATH` to point to `digital_arrest.yaml`.
- **Front‑end token handling** – fragment‑token must be removed via `history.replaceState`.

## Timeline (planned)
- A: 2 h
- B: 1 h
- C: 4 h
- D: 1 h
- E: 1 h

## Notes
- Codename `gate‑3` will be signed under the same commit.
- All commits follow the "Small conventional commits" rule.
- The plan stays in this file only; no other documentation is added at this point.
