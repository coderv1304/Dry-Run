# Plan 2: Design System, Tokens, Components, Enforcement

1. Read CLAUDE.md, ARCHITECTURE.md, BANNED_UI.md, and both design skill files; record decisions.
2. Author `design/tokens.json`: spacing, radius, type, two-layer colors, motion, contrast pairings.
3. Generate Flutter `app/lib/design/*.g.dart` and `landing/tokens.css` from tokens; prove reproducibility.
4. Vendor Poppins (400/500/600/700), Noto Sans Devanagari fallback, and Phosphor icon assets.
5. Build Flutter theme overrides, token-based components, and Light/Dark design gallery.
6. Add golden tests for every component in both modes and gallery snapshots.
7. Add `tool/contrast_check.py` over every declared token/surface pairing.
8. Add `tool/design_lint.py` plus one bad fixture per rule and unit tests.
9. Wire landing page to generated tokens and vendored fonts/icons; remove unverified data.
10. Run both skill checklists, fix or log every failure, write `docs/CHECKLIST_2.md`.
11. Run `make gate-2`, write `.gates/2`, commit, tag `gate-2`, report.
