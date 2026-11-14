"""Dry Run Environment Doctor.
Checks python >= 3.12, git, make, flutter, dart, java, Android SDK, docker.
Missing python, git, make or flutter => exit 1 (STOP).
"""

import os
import shutil
import subprocess
import sys


def check():
    print("=== Dry Run Environment Doctor ===")
    stop = False

    # 1. Python
    py_ver = sys.version_info
    if py_ver.major < 3 or (py_ver.major == 3 and py_ver.minor < 12):
        print(f"[CRITICAL] Python must be >= 3.12, found: {sys.version.split()[0]}")
        stop = True
    else:
        print(f"[OK] Python {py_ver.major}.{py_ver.minor}.{py_ver.micro}")

    # 2. Git
    git_bin = shutil.which("git")
    if git_bin:
        res = subprocess.run([git_bin, "--version"], capture_output=True, text=True)
        print(f"[OK] {res.stdout.strip()}")
    else:
        print("[CRITICAL] git not found in PATH")
        stop = True

    # 3. Make
    make_bin = shutil.which("make") or shutil.which("mingw32-make")
    if make_bin:
        res = subprocess.run([make_bin, "--version"], capture_output=True, text=True)
        first_line = res.stdout.strip().split("\n")[0]
        print(f"[OK] {first_line}")
    else:
        print("[CRITICAL] make not found in PATH")
        stop = True

    # 4. Flutter
    flutter_bin = shutil.which("flutter") or (r"C:\flutter\bin\flutter.bat" if os.path.exists(r"C:\flutter\bin\flutter.bat") else None)
    if flutter_bin:
        print(f"[OK] Flutter found at {flutter_bin}")
    else:
        print("[CRITICAL] flutter not found in PATH")
        stop = True

    # 5. Dart
    dart_bin = shutil.which("dart") or (r"C:\flutter\bin\cache\dart-sdk\bin\dart.exe" if os.path.exists(r"C:\flutter\bin\cache\dart-sdk\bin\dart.exe") else None)
    if dart_bin:
        print(f"[OK] Dart found at {dart_bin}")
    else:
        print("[WARNING] dart not found in PATH. See docs/HUMAN_TODO.md")

    # 6. Java
    java_bin = shutil.which("java")
    if java_bin:
        res = subprocess.run([java_bin, "-version"], capture_output=True, text=True)
        first_line = (res.stdout + res.stderr).strip().split("\n")[0]
        print(f"[OK] {first_line}")
    else:
        print("[WARNING] java not found in PATH. See docs/HUMAN_TODO.md")

    # 7. Android SDK
    android_home = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if not android_home:
        candidate = os.path.expanduser(r"~\AppData\Local\Android\Sdk")
        if os.path.exists(candidate):
            android_home = candidate
    if android_home and os.path.exists(android_home):
        print(f"[OK] Android SDK at {android_home}")
    else:
        print("[WARNING] Android SDK not found. See docs/HUMAN_TODO.md")

    # 8. Docker
    docker_bin = shutil.which("docker")
    if docker_bin:
        res = subprocess.run([docker_bin, "--version"], capture_output=True, text=True)
        print(f"[OK] {res.stdout.strip()}")
    else:
        print("[WARNING] docker not found in PATH. See docs/HUMAN_TODO.md")

    print("==================================")
    if stop:
        print("STOP: Missing critical prerequisite (python >=3.12, git, make, or flutter).")
        sys.exit(1)

    print("Doctor check PASSED.")
    sys.exit(0)


if __name__ == "__main__":
    check()
