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

### 4a. Install the release APK with adb
1. Enable Developer options and USB debugging on the phone (Android 7.0 / API 24 or newer).
2. Connect it, then confirm the device is visible:
   ```sh
   adb devices
   ```
3. Build and install the signed release APK:
   ```sh
   make apk
   adb install -r app/build/app/outputs/flutter-apk/app-release.apk
   ```
4. Confirm the signature is the release key, not the debug fallback:
   ```sh
   apksigner verify --print-certs \
     app/build/app/outputs/flutter-apk/app-release.apk
   ```
   On Windows, `apksigner` is under
   `%LOCALAPPDATA%\Android\Sdk\build-tools\<version>\`.
5. If `make apk` had to fall back because the Android SDK or a compatible JDK
   is missing, record that here: the APK is not a real release build.

### 4b. Release hardening on a real phone
- [ ] `adb backup` cannot copy app data: backup is disabled.
- [ ] The app still opens with airplane mode on (no accidental cleartext retry loop).
- [ ] A plain `http://` API base fails closed; only HTTPS works in release.
- [ ] Screenshot attempts on the debrief and report screens are blocked.
- [ ] The recent-tasks preview shows a blank surface, not the debrief.
- [ ] Screenshots work again after leaving the debrief.

### 4c. Voice on a real phone
- [ ] Join or start a drill. No microphone prompt appears before tapping `Use voice`.
- [ ] Tapping `Use voice` shows the disclosure first. Declining never opens the system permission prompt.
- [ ] Accepting shows the Android `RECORD_AUDIO` prompt exactly once.
- [ ] English drill: recognition works, the officer line is spoken, and a normal turn appears in the chat.
- [ ] Hindi drill: recognition uses the Hindi model and the reply is spoken with the Hindi voice.
- [ ] Hinglish drill: the same Hindi recognition and voice are used.
- [ ] Deny the microphone in phone settings, reopen the drill: voice shows the calm permission copy and typing still works.
- [ ] Put the phone in airplane mode after opting in: a voice turn fails back to chat.
- [ ] Turn Bluetooth off and on: no extra Bluetooth permission prompt appears.
- [ ] Tap `End drill` while the app is listening or speaking: the drill ends immediately and the debrief opens.
- [ ] Background the app while listening: audio stops and returning to the app never resumes a stale recording.
- [ ] Run the Voice check screen: microphone, English and Hindi recognition, English and Hindi voice, and round trip each show a clear pass or fail.
- [ ] Confirm the phone's speech service is the only thing that receives audio. Nothing recorded by the app survives a restart.

### 4d. Demo build
- [ ] Build with `--dart-define=DEMO_MODE=true`, install it, and turn on airplane mode.
- [ ] The drill opens on the fixed transcript, shows the DEMO banner, and the debrief renders with no network.
- [ ] Confirm `make demo-check` passes for the production APK (no demo strings).
- [ ] Confirm the demo APK does not ask for the microphone.

### 4e. Other hardware checks
- [ ] Test the OS share sheet when a report link is generated.
- [ ] Test on a small 360 px wide screen and with the system font at 200 percent.

## 5. Design System Review
- [ ] **Verify facts before any data section ships**: every row in `docs/FACTS.md` currently has `verified_by_human: false`, so the landing page renders no statistic. Confirm a source, set the flag, then reintroduce the section.
- [ ] **Visual pass of the landing page** at 390, 768 and 1440 px, checking no horizontal overflow and that the primary action sits in the first screen.
- [ ] **Review the design gallery** on a phone and on desktop (`flutter run` opens it): it is the visual spec for every token and state.
- [ ] **CI golden image**: goldens were generated on Windows and are compared on `windows-latest`. If CI moves to another OS, run `make goldens` on that image and commit the result.

## Gate 4

- Review `docs/screenshots/` on a real phone in both modes; the committed set was rasterised on Windows.
- Confirm the four haptics moments feel right on an Android device: send, officer reply, end of drill, debrief ready.
- Walk the drill once with system text at 200 percent in Hindi and check the scrolling page feels natural.
