# Release runbook

This document covers the Android release build and the two build modes the app
supports: the normal production build and the offline demo build. It does not
cover hosting the web app or the backend.

## Toolchain

- Flutter 3.47.x with Dart 3.13.x (the version pinned by `.github/workflows`).
- Android SDK with build-tools 36 and a JDK that Gradle accepts (Java 17 or
  newer). Android Studio's bundled JBR works.
- GNU make for the repository targets.

`make preflight` checks the Python side of the toolchain. `flutter doctor` is
the quickest way to confirm the Android half.

## Signing

Release builds are signed with a keystore that is generated locally and never
committed. The repository ignores `app/android/key.properties`,
`*.keystore` and `*.jks`.

1. Generate the key once:

   ```sh
   make keystore
   ```

   This runs `tool/make_keystore.py`, which writes:

   - `app/android/dryrun-release.keystore`
   - `app/android/key.properties` (store password, key password, alias, path)

   Running it again is a no-op, so an installed build keeps its signing
   identity.

2. Back both files up somewhere private. If they are lost, Android treats the
   next build as a different app and an update cannot be installed over the
   old one.

3. `app/android/app/build.gradle.kts` reads `key.properties` when it exists and
   otherwise falls back to the debug key. The fallback exists so a contributor
   can still build without the secret; do not ship a fallback build.

4. Confirm the signature before distributing, using `apksigner` from the
   Android SDK build-tools (36 or newer):

   ```sh
   apksigner verify --print-certs \
     app/build/app/outputs/flutter-apk/app-release.apk
   ```

   On Windows the tool lives under
   `%LOCALAPPDATA%\Android\Sdk\build-tools\<version>\`.

## Building the production APK

```sh
make apk
```

That target:

1. generates the local keystore if needed,
2. runs `flutter build apk --release --obfuscate --split-debug-info=build/symbols`,
3. asserts the APK exists.

Output: `app/build/app/outputs/flutter-apk/app-release.apk`.

The Dart symbols written to `app/build/symbols/` are what turns an obfuscated
stack trace back into readable names. Keep the folder that matches the shipped
version; it is not committed.

## What the release build enforces

| Rule | Where |
| --- | --- |
| `minSdk 24` | `app/android/app/build.gradle.kts` |
| `allowBackup=false`, `fullBackupContent=false` | `app/android/app/src/main/AndroidManifest.xml` |
| No cleartext traffic | `usesCleartextTraffic=false` plus `res/xml/network_security_config.xml` |
| Debug-only loopback exception | `app/android/app/src/debug/` (never in release) |
| `INTERNET` permission | main manifest |
| `RECORD_AUDIO` requested only at voice opt-in | main manifest declares it; speech initialization happens after the disclosure |
| Screenshot block on debrief and report | `FLAG_SECURE` in `MainActivity.kt`, driven by `SecureScreenScope` |

`make manifest-check` reads the compiled manifest inside the release APK with
`aapt2` and fails if any of those values are missing or flipped. It also checks
the FLAG_SECURE channel in Kotlin and Dart.

## Demo mode

Demo mode is a build flag, not a runtime toggle:

```sh
cd app
flutter build apk --release --dart-define=DEMO_MODE=true
```

In demo mode the app:

- opens directly on the drill with a fixed, recorded transcript,
- serves a canned debrief from `DemoApi`,
- never constructs a network client request and never calls the backend,
- does not touch the microphone or the speech service.

The demo code lives only in `app/lib/features/demo/`. `main.dart` adds its
provider overrides behind `const bool kDemoMode = bool.fromEnvironment(...)`,
so a production compile folds the branch away.

The demo path is a fixed transcript plus a canned debrief. It does not bundle
the backend scenario files and does not contain a branching engine: branching
in the real product happens on the server, and the app never ships scenario
YAML.

Prove that on the shipped artifact:

```sh
make demo-check
```

`tool/check_demo_strings.py` scans the compiled `libapp.so` inside the release
APK for demo-only sentinels (demo tokens, the fixed transcript marker and the
demo controller names). Any hit fails the check. A debug APK is not a valid
substitute: it keeps every code path, so the tool reports SKIPPED when only a
debug build exists.

## Voice mode

Voice is opt in for each session and is never required.

- The disclosure dialog appears before the app asks for `RECORD_AUDIO`. If the
  participant declines, the microphone is never touched.
- Recognition and speech use the phone's own service. On a Hindi or Hinglish
  invite both use `hi-IN`; English uses `en-IN`.
- Any missing recognizer, missing language voice, denied permission, empty
  transcript, failed reply or timeout returns the participant to text chat with
  calm copy. The composer stays enabled the whole time.
- Nothing spoken or recognized is persisted: the audio stays inside the speech
  service and only the final text becomes a normal chat turn.
- Leaving the drill, or ending it, stops listening and speech before the
  screen changes.
- Debrief and report screens hold `FLAG_SECURE`, so screenshots and the
  recent-tasks preview are blocked.

A real device is still required for the microphone and voice checks in
`docs/HUMAN_TODO.md`.

## Install on a phone

The exact `adb` steps and the real-device checklist are in
`docs/HUMAN_TODO.md`. The short version:

```sh
adb install -r app/build/app/outputs/flutter-apk/app-release.apk
```

## Release checklist

- [ ] `make gate-3b` passes on a clean checkout.
- [ ] `make apk` produced an APK signed with the release key.
- [ ] `make manifest-check` passes against that APK.
- [ ] `make demo-check` reports no demo strings.
- [ ] `build/symbols/` archived with the version.
- [ ] Keystore and `key.properties` backed up, never committed.
- [ ] The real-device items in `docs/HUMAN_TODO.md` are done.
