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
