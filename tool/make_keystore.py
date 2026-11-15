#!/usr/bin/env python3
"""Create the local Android release keystore.

The keystore and ``app/android/key.properties`` are gitignored and never leave
this machine. Running this again reuses the existing files so an installed
build keeps its signing identity.
"""

from __future__ import annotations

import os
import secrets
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ANDROID = ROOT / "app" / "android"
KEYSTORE = ANDROID / "dryrun-release.keystore"
PROPERTIES = ANDROID / "key.properties"
ALIAS = "dryrun"


def _keytool() -> str:
    configured = os.environ.get("KEYTOOL")
    if configured and Path(configured).exists():
        return configured
    java_home = os.environ.get("JAVA_HOME")
    if java_home:
        name = "keytool.exe" if os.name == "nt" else "keytool"
        candidate = Path(java_home) / "bin" / name
        if candidate.exists():
            return str(candidate)
    found = shutil.which("keytool")
    if found:
        return found
    if os.name == "nt":
        studio = Path(r"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe")
        if studio.exists():
            return str(studio)
    raise SystemExit(
        "keytool was not found. Set KEYTOOL or JAVA_HOME, or install a JDK."
    )


def main() -> int:
    if PROPERTIES.exists() and KEYSTORE.exists():
        print("Release keystore already exists:")
        print("  " + str(KEYSTORE))
        print("  " + str(PROPERTIES))
        return 0
    if PROPERTIES.exists() != KEYSTORE.exists():
        raise SystemExit(
            "Only one of key.properties and dryrun-release.keystore exists. "
            "Remove the leftover file and run again."
        )

    password = secrets.token_urlsafe(24)
    command = [
        _keytool(),
        "-genkeypair",
        "-v",
        "-keystore",
        str(KEYSTORE),
        "-alias",
        ALIAS,
        "-keyalg",
        "RSA",
        "-keysize",
        "2048",
        "-validity",
        "10000",
        "-storepass",
        password,
        "-keypass",
        password,
        "-dname",
        "CN=Dry Run, OU=Community Practice, O=Dry Run, L=India, ST=India, C=IN",
    ]
    print("Generating local release keystore...")
    subprocess.run(command, check=True)
    PROPERTIES.write_text(
        "\n".join(
            [
                "storePassword=" + password,
                "keyPassword=" + password,
                "keyAlias=" + ALIAS,
                "storeFile=../dryrun-release.keystore",
                "",
            ]
        ),
        encoding="utf-8",
    )
    print("Wrote " + str(PROPERTIES))
    print("These files are gitignored. Back them up before shipping an update.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
