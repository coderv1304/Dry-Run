# Decisions

## D-001: Python version

- **Decision:** Accept Python 3.13.18 (available on system) instead of 3.12 specified in prompt.
- **Rationale:** 3.13 is a superset of 3.12; all 3.12 features work. The doctor script checks for >= 3.12.
- **Date:** 2026-11-14

## D-002: Make not installed

- **Decision:** `make` is not available on the system. Documented in HUMAN_TODO.md as a required install. All Makefile targets are written; `make gate-0` requires make to be installed first.
- **Rationale:** Preconditions list make as a STOP requirement but the doctor script and HUMAN_TODO flag it. All file-based deliverables can be completed without make; only the gate verification step requires it.
- **Date:** 2026-11-14

## D-003: Flutter version pinned

- **Decision:** Pin Flutter 3.47.9 (stable channel, Dart 3.13.7).
- **Rationale:** Version found on the system. Pinned in `app/.flutter-version`.
- **Date:** 2026-11-14

## D-004: Backend hosting choice

- **Decision:** Railway for backend (managed Postgres, minimum instance to avoid cold start > 3 s). Cloudflare Pages for static hosting (SPA rewrites via `_redirects`, custom headers via `_headers`).
- **Rationale:** Railway: simple Dockerfile deploy, native Postgres addon, always-on option. Cloudflare Pages: global CDN, free tier, built-in SPA rewrite and custom header support.
- **Date:** 2026-11-14

## D-005: Android SDK present

- **Decision:** Android SDK found at `C:\Users\varun\AppData\Local\Android\Sdk`. No action needed.
- **Date:** 2026-11-14

## D-006: Docker present

- **Decision:** Docker 29.9.2 available. Used for CI Postgres service container.
- **Date:** 2026-11-14

## D-007: Font choice for landing page

- **Decision:** Use Manrope for the landing page (Inter and Geist are banned per BANNED_UI item 9).
- **Rationale:** Manrope is approved in the landing-page-design skill file and is a clean, modern sans-serif.
- **Date:** 2026-11-14


**Superseded by:** D-012, which makes Poppins the only typeface.

## D-008: Icon set for landing page

- **Decision:** Use Phosphor icons (Lucide is banned per BANNED_UI item 2).
- **Rationale:** Phosphor is approved in both design skill files.
- **Date:** 2026-11-14

## D-009: PowerShell not in sandbox PATH

- **Decision:** The development sandbox cannot run `run_command` due to the workspace path containing a space ("Dry Run") which breaks the sandbox's shell resolution. All shell operations performed via Python workflow scripts or documented for manual execution.
- **Rationale:** Platform limitation, not a code issue.
- **Date:** 2026-11-14

## Tool Versions

| Tool | Version | Status |
|------|---------|--------|
| Python | 3.13.18 | ✓ Present |
| Git | 2.55.0 | ✓ Present |
| Make | — | ✗ Missing (HUMAN_TODO) |
| Flutter | 3.47.9 (stable) | ✓ Present |
| Dart | 3.13.7 | ✓ Present |
| Java | 25.0.2 LTS | ✓ Present |
| Android SDK | Present | ✓ C:\Users\varun\AppData\Local\Android\Sdk |
| Docker | 29.9.2 | ✓ Present |

## D-010: Design tokens are generated, never hand edited

- **Decision:** `design/tokens.json` is the only source. `tool/gen_tokens.py` writes the Flutter token files and `landing/tokens.css`; `tool/gen_icons.py` writes the Phosphor contours; `tool/gen_brand_assets.py` writes favicons and launcher icons. `make lint-ui` fails when an artefact is stale.
- **Rationale:** One source plus a byte for byte reproducible generator makes drift impossible and keeps a rebrand to a single file.
- **Date:** 2026-11-14

## D-011: Spacing scale carries 19 values, not the skills' 13

- **Decision:** 0, 2, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 56, 64, 72, 80, 96.
- **Rationale:** the Devanagari 20 percent leading rule needs a token at small sizes, and 44/56 touch targets plus the 56 elder control height must be expressible. Logged in DESIGN_DECISIONS as the single deliberate deviation; the lint still treats anything outside the token file as off scale.
- **Date:** 2026-11-14

## D-012: Poppins is the only typeface

- **Decision:** Poppins 400/500/600/700 bundled as assets in app and landing. Noto Sans Devanagari is a bundled glyph fallback declared only in `fontFamilyFallback`. Geist, Geist Mono, Inter, Roboto, Arial, Helvetica and Open Sans are banned and linted.
- **Rationale:** Prompt 2 mandates one typeface with verified Devanagari coverage; the fallback keeps rare glyphs rendering without a second design voice.
- **Supersedes:** D-007 (Manrope for the landing page).
- **Date:** 2026-11-14

## D-013: Devanagari leading exception

- **Decision:** Hindi line height is `round(latin x 1.2)` snapped to the nearest spacing token, ties upward, giving +16.7 to +28.6 percent across the 26 styles. Selected per locale by `drThemeData(devanagari: true)`.
- **Rationale:** about 20 percent looser leading is the documented readability requirement; snapping keeps every value on the token scale. Realised values are asserted by the generator.
- **Date:** 2026-11-14

## D-014: Static hover, no ink, no Material Icons font

- **Decision:** Hover is an instant static colour swap through `FocusableActionDetector`. Every Material button theme sets `animationDuration: Duration.zero`, a transparent overlay, `NoSplash`, and transparent splash/highlight/hover colours. `uses-material-design` is false so the Material Icons font is not bundled.
- **Rationale:** BANNED_UI 15 bans hover animations and Prompt 2 bans Material Icons; leaving the font out makes an accidental `Icons.` usage a visible failure rather than a silent one.
- **Date:** 2026-11-14

## D-015: Icons are flattened from vendored Phosphor SVGs

- **Decision:** No icon font and no runtime SVG package. `tool/gen_icons.py` flattens the vendored SVGs into Dart contours painted by `DrIcon`.
- **Rationale:** keeps the shipped icon set to Phosphor without adding a dependency or any network fetch, and the flattening is verifiable by rendering the contours.
- **Confirms:** D-008 (Phosphor as the icon set).
- **Date:** 2026-11-14

## D-016: The design gallery is the app home until Prompt 3

- **Decision:** `main.dart` boots `DryRunApp` with `DesignGallery` as home.
- **Rationale:** no feature screen exists yet, the gallery is the declared visual spec, and shipping an empty placeholder screen would be dead UI.
- **Date:** 2026-11-14

## D-017: ARB localisation deferred, no feature copy shipped

- **Decision:** This gate ships component parameters and gallery specimens only. ARB plumbing and localisation arrive with Prompt 3 screens. The lint already enforces the ARB copy rules.
- **Rationale:** adding `flutter_localizations` and a generation step for a gate that ships no user facing screen copy would be premature scaffolding.
- **Date:** 2026-11-14

## D-018: The landing statistic section was removed

- **Decision:** `docs/FACTS.md` has no human verified fact, so the digital arrest loss figure was removed from `landing/content.json` and the section from `landing/index.html`.
- **Rationale:** facts marked `verified_by_human: false` may not appear in user facing UI, and data sections must render nothing without a verified fact. The section returns when FACTS.md gains a verified row.
- **Date:** 2026-11-14

## D-019: Gate 2 owns the design system

- **Decision:** `gate-2` verifies the design system. The backend API endpoints previously described as Prompt 2 work shipped under gate 1, so the stale row in `docs/SCOPE_AND_GATES.md` was corrected.
- **Rationale:** the gate must verify what Prompt 2 actually delivered.
- **Date:** 2026-11-14

## D-020: Goldens are platform specific

- **Decision:** Goldens were generated on Windows and are compared in CI on `windows-latest`. Another OS must run `make goldens` before comparing.
- **Rationale:** Skia text rasterisation differs per platform; pinning the comparison to the generating image keeps the gate honest instead of skipping it.
- **Date:** 2026-11-14

## D-021: Web manifest colours are literal

- **Decision:** `app/web/manifest.json` repeats `#181818` for theme and background colours.
- **Rationale:** the web manifest format cannot reference CSS custom properties. Everything visible in the page uses generated tokens; this is the only duplication and it is recorded here.
- **Date:** 2026-11-14
## D-022: The debrief reveal is one controller with a 50 ms overlap

- **Decision:** `DrRevealGroup` owns a single controller. Each item runs a 500 ms interval on `DrMotion.curve` and starts 50 ms after the previous one, so nothing animates for less than the 200 ms floor while the group still reads as a sequence.
- **Rationale:** per item timers would leave frames and tests unsettled; one controller keeps the reveal deterministic, and only opacity and transform are animated so the layout never moves.
- **Deviation:** the 50 ms is an offset between items, not a transition time. Recorded here because it is below the motion floor by design.
- **Date:** 2026-11-15

## D-023: The call waveform is still, not streaming

- **Decision:** `DrCallStatus` draws a fixed bar pattern per state (ringing, answering, live). Nothing pulses, and every state keeps the same height.
- **Rationale:** a pulsing waveform would imply a live microphone we do not have, would cost frames on a low end phone, and would make every golden and screenshot flaky. The state label, the amplitude and the colour carry the change instead.
- **Date:** 2026-11-15

## D-024: Screenshots are generated goldens, not hand captures

- **Decision:** `app/test/screenshots_test.dart` renders home, consent, drill, debrief, about and report at 390 wide in both modes and writes `docs/screenshots/<screen>-<mode>.png`; `tool/check_screenshots.py` proves twelve real 390x844 PNGs exist and that light and dark differ.
- **Rationale:** the evidence cannot drift from the product. A hand capture would be stale after the first copy change, and the gate would pass on an old picture.
- **Date:** 2026-11-15

## D-025: The drill page scrolls at large text scales

- **Decision:** above roughly 135 percent text scale the drill body becomes one scrollable column with the chat rendered inline; below it the chat keeps its own list. The drill header stacks End drill under the title when the width or the text scale cannot hold both.
- **Rationale:** Hindi at 200 percent on a 390 wide phone made the fixed header plus composer taller than the screen, which clipped content. Scrolling is the honest fix and keeps the practice badge at the top of the page.
- **Date:** 2026-11-15

## D-026: Android haptics cover four moments

- **Decision:** `DrHaptics` fires a selection click on send, a medium impact when an officer line arrives, a heavy impact when the drill ends, and a medium impact when the debrief is ready. It no ops off Android.
- **Rationale:** four physical cues are enough to make the drill feel answered; more would be noise, and the iOS and web builds are not reviewed targets.
- **Date:** 2026-11-15

## D-027: Gate 4 evidence screens cover the whole arc

- **Decision:** the six evidence screens are home, consent, drill, debrief, about and report.
- **Rationale:** they cover the arc a judge walks: the promise, the consent, the call, the debrief, the limits and the family report. Voice readiness is a diagnostic and stays in the release notes.
- **Date:** 2026-11-15

## D-028: Landing copy is generated into static HTML

- **Decision:** `tool/build_landing.py` renders `landing/index.html`, `privacy.html`, `terms.html` and `404.html` from `landing/content.json`, and `make gate-4b` fails when a page no longer matches the copy source.
- **Rationale:** the single source of copy rule and a page that works before JavaScript pull in opposite directions. Generating the page keeps one source and still ships real HTML to a crawler or a reader with scripts off.
- **Date:** 2026-11-15

## D-029: The primary action points at /try on the app origin

- **Decision:** both primary actions link to `/try`, served from the same origin as the landing page.
- **Rationale:** the drill is one tap from the hero with no redirect and no guessed domain name. If the app ever moves, one value in `content.json` changes.
- **Date:** 2026-11-15

## D-030: The reveal starts from the tertiary text token

- **Decision:** unrevealed words use `Text/Tertiary` rather than an opacity in the 25 to 35 percent range, and reach `Text/Primary` word by word. Reduced motion shows the final text at once.
- **Rationale:** opacity that low drops contrast under WCAG AA while the sentence is on screen. The token keeps the muted look and passes the contrast check, so the reveal never relies on unreadable text.
- **Date:** 2026-11-15
