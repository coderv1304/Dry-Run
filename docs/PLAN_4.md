# Plan 4: Product Polish and Evidence

1. Read CLAUDE.md, docs/ARCHITECTURE.md, docs/design/BANNED_UI.md and the design decisions.
2. Add two components through the design system: `DrRevealGroup` (staggered opacity and transform on the base curve, reduced motion respected) and `DrCallStatus` (ringing, answering, live, badge always visible, calm static waveform). Both get gallery specimens.
3. Debrief hero: reveal the state path and the timeline step by step; rewrite the first compliance line as one kind sentence; keep the habit card as the close.
4. Call screen: map drill state to ringing, answering and live; stack the header when large text needs it; scroll the drill page instead of clipping at large scales.
5. States: replace every remaining off token Material text style with DrType tokens; keep skeletons, empty states and inline errors; no spinners, no alert dialogs for errors.
6. Detail: Android haptics at send, officer reply, end of drill and debrief ready; one icon family; both modes checked.
7. Evidence: capture the six key screens at 390 wide in light and dark into `docs/screenshots` from a golden test, and gate them with `tool/check_screenshots.py`.
8. Wire `make gate-4`, run both skill checklists into `docs/CHECKLIST_4.md`, then commit, write `.gates/4` and tag `gate-4`.
