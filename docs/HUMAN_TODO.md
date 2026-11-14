# Human Todo List

Tasks that require human credentials, physical hardware, or manual account configuration that automated tooling cannot perform.

## 1. Infrastructure and Hosting Accounts
- [ ] **Railway Account Setup**:
  1. Create account on [railway.app](https://railway.app/).
  2. Set up project `dry-run-backend`.
  3. Provision Managed PostgreSQL database addon.
  4. Configure environment variables in Railway dashboard:
     - `DATABASE_URL` (connected to Postgres addon)
     - `LLM_PROVIDER` (`openai_compatible` or `anthropic`)
     - `LLM_MODEL_PRIMARY`
     - `LLM_MODEL_CHEAP`
     - `API_KEY` for chosen LLM provider
     - `DAILY_LLM_BUDGET_USD`
     - `RETENTION_DAYS` (default 7)
     - `TRUSTED_PROXY_COUNT` (1)
  5. Deploy backend from GitHub repository via Dockerfile.

- [ ] **Cloudflare Pages Setup**:
  1. Create account on [cloudflare.com](https://cloudflare.com/).
  2. Create Pages project for static assets (Flutter Web & Landing page).
  3. Connect GitHub repository and configure build output directory.
  4. Verify `_redirects` for SPA fallback rule (`/* /index.html 200`).
  5. Verify `_headers` for Content-Security-Policy and cache control headers.

## 2. Environment and Tooling
- [ ] **GNU Make Installation**:
  - `mingw32-make.exe` is currently copied as `make.exe` in `~/.local/bin`.
  - For standard Linux/macOS environments, ensure `make` is installed via standard package manager (`apt-get install build-essential` or `brew install make`).

## 3. Localization and Audio
- [ ] **Review Hindi & Hinglish Phrases**:
  - Review items in `docs/REVIEW_NEEDED.md` with a native speaker of Hindi and Hinglish.
  - Approve terminology for scam scenario prompts and debrief advice.

## 4. Hardware Verification
- [ ] **Android Physical Device Testing**:
  - Install debug APK on target Android 11+ device.
  - Test voice recognition opt-in and system audio loopback.
  - Test OS share sheet launch when report token link is generated.

## 5. Design System Review
- [ ] **Verify facts before any data section ships**: every row in `docs/FACTS.md` currently has `verified_by_human: false`, so the landing page renders no statistic. Confirm a source, set the flag, then reintroduce the section.
- [ ] **Visual pass of the landing page** at 390, 768 and 1440 px, checking no horizontal overflow and that the primary action sits in the first screen.
- [ ] **Review the design gallery** on a phone and on desktop (`flutter run` opens it): it is the visual spec for every token and state.
- [ ] **CI golden image**: goldens were generated on Windows and are compared on `windows-latest`. If CI moves to another OS, run `make goldens` on that image and commit the result.
