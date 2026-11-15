#!/usr/bin/env python3
"""Verify the shipped Android manifest and FLAG_SECURE wiring.

Reads the signed release APK when it exists, so the check sees the merged
manifest rather than the source fragments. Falls back to the merged manifest
that Gradle leaves in ``app/build`` and finally to the source manifest, which
keeps the check useful on a machine without the Android SDK.

Exit code 0 means every hardening rule holds. Any miss prints a message that
names the file and the rule.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "app"
APK = APP / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
APK_DEBUG = APP / "build" / "app" / "outputs" / "flutter-apk" / "app-debug.apk"
MAIN_MANIFEST = APP / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
NETWORK_CONFIG = (
    APP / "android" / "app" / "src" / "main" / "res" / "xml"
    / "network_security_config.xml"
)
MAIN_ACTIVITY = (
    APP / "android" / "app" / "src" / "main" / "kotlin"
    / "in" / "dryrun" / "dryrun" / "MainActivity.kt"
)
SECURE_SCREEN = APP / "lib" / "core" / "secure_screen.dart"

failures: list[str] = []


def fail(message: str) -> None:
    failures.append(message)


def find_aapt2() -> str | None:
    """Locate the newest aapt2 in the Android SDK."""
    roots = [
        Path(value)
        for value in (
            os.environ.get("ANDROID_HOME"),
            os.environ.get("ANDROID_SDK_ROOT"),
            Path.home() / "AppData" / "Local" / "Android" / "Sdk",
            Path.home() / "Android" / "Sdk",
        )
        if value
    ]
    candidates: list[Path] = []
    for root in roots:
        build_tools = root / "build-tools"
        if build_tools.is_dir():
            candidates.extend(build_tools.glob("*/aapt2.exe"))
            candidates.extend(build_tools.glob("*/aapt2"))
    if not candidates:
        found = shutil.which("aapt2")
        return found
    candidates.sort(key=lambda path: path.parent.name, reverse=True)
    return str(candidates[0])


def aapt_dump(apk: Path) -> str | None:
    aapt2 = find_aapt2()
    if not aapt2:
        return None
    result = subprocess.run(
        [aapt2, "dump", "xmltree", "--file", "AndroidManifest.xml", str(apk)],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        fail("aapt2 could not read %s: %s" % (apk.name, result.stderr.strip()))
        return None
    return result.stdout


def _manifest_flag(text: str, name: str) -> bool | None:
    """Return True when a compiled boolean attribute is false, None if absent."""
    match = re.search(
        r"android:%s\([^)]*\)=(false|true|\(type [^)]*\)(0x[0-9a-fA-F]+))" % name,
        text,
    )
    if match is None:
        return None
    if match.group(1) == "false":
        return True
    if match.group(1) == "true":
        return False
    return int(match.group(3), 16) == 0


def check_compiled_manifest(text: str, source: str) -> None:
    """Assert the binary manifest tree carries the hardening flags."""
    if "android.permission.INTERNET" not in text:
        fail("%s: INTERNET permission is missing" % source)
    if "android.permission.RECORD_AUDIO" not in text:
        fail("%s: RECORD_AUDIO permission is missing" % source)

    backup = _manifest_flag(text, "allowBackup")
    if backup is None:
        fail("%s: allowBackup is not set explicitly" % source)
    elif backup is False:
        fail("%s: allowBackup must be false" % source)

    cleartext = _manifest_flag(text, "usesCleartextTraffic")
    if cleartext is None:
        fail("%s: usesCleartextTraffic is not set explicitly" % source)
    elif cleartext is False:
        fail("%s: usesCleartextTraffic must be false" % source)

    if "android:networkSecurityConfig" not in text:
        fail("%s: networkSecurityConfig is missing" % source)


def check_manifest_xml() -> None:
    if not MAIN_MANIFEST.is_file():
        fail("missing %s" % MAIN_MANIFEST.relative_to(ROOT))
        return
    text = MAIN_MANIFEST.read_text(encoding="utf-8")
    rules = {
        'android:allowBackup="false"': "allowBackup must be false",
        'android:fullBackupContent="false"': "fullBackupContent must be false",
        'android:usesCleartextTraffic="false"': "cleartext must be disabled",
        'android:networkSecurityConfig="@xml/network_security_config"': (
            "the network security config must be referenced"
        ),
        'android.permission.INTERNET': "INTERNET permission is missing",
        'android.permission.RECORD_AUDIO': "RECORD_AUDIO permission is missing",
    }
    for needle, message in rules.items():
        if needle not in text:
            fail("AndroidManifest.xml: %s" % message)


def check_network_config() -> None:
    if not NETWORK_CONFIG.is_file():
        fail("missing %s" % NETWORK_CONFIG.relative_to(ROOT))
        return
    text = NETWORK_CONFIG.read_text(encoding="utf-8")
    if 'cleartextTrafficPermitted="false"' not in text:
        fail("network_security_config.xml must disallow cleartext")
    if 'cleartextTrafficPermitted="true"' in text:
        fail("network_security_config.xml must never allow cleartext")


def check_flag_secure() -> None:
    if not MAIN_ACTIVITY.is_file():
        fail("missing %s" % MAIN_ACTIVITY.relative_to(ROOT))
    else:
        text = MAIN_ACTIVITY.read_text(encoding="utf-8")
        if "FLAG_SECURE" not in text:
            fail("MainActivity.kt does not set FLAG_SECURE")
        if "in.dryrun/secure_screen" not in text:
            fail("MainActivity.kt does not expose the secure screen channel")
    if not SECURE_SCREEN.is_file():
        fail("missing %s" % SECURE_SCREEN.relative_to(ROOT))
    else:
        text = SECURE_SCREEN.read_text(encoding="utf-8")
        if "in.dryrun/secure_screen" not in text:
            fail("secure_screen.dart does not use the secure screen channel")


def main() -> int:
    check_manifest_xml()
    check_network_config()
    check_flag_secure()

    apk: Path | None = None
    for candidate in (APK, APK_DEBUG):
        if candidate.is_file():
            apk = candidate
            break

    if apk is None:
        print(
            "No release APK found. Run `make apk` to build one; the merged "
            "manifest was not inspected."
        )
    else:
        with zipfile.ZipFile(apk) as archive:
            if "AndroidManifest.xml" not in archive.namelist():
                fail("%s has no AndroidManifest.xml" % apk.name)
        text = aapt_dump(apk)
        if text is None:
            print(
                "aapt2 was not found, so the compiled manifest could not be "
                "read. The source manifest checks still ran."
            )
        else:
            check_compiled_manifest(text, apk.name)

    if failures:
        print("ANDROID MANIFEST CHECK FAILED")
        for message in failures:
            print("  - " + message)
        return 1
    print("ANDROID MANIFEST CHECK PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
