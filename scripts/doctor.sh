#!/usr/bin/env bash
# Dry Run Environment Doctor Script
# Checks python, git, make, flutter, dart, java, Android SDK, docker.
# Missing python, git, make or flutter => exit 1 (STOP).

set -e

echo "=== Dry Run Environment Doctor ==="

STOP=0

# 1. Python check (>= 3.12)
if command -v python3 &>/dev/null; then
  PY_BIN="python3"
elif command -v python &>/dev/null; then
  PY_BIN="python"
else
  echo "[CRITICAL] Python not found in PATH."
  STOP=1
fi

if [ -n "$PY_BIN" ]; then
  PY_VER=$($PY_BIN -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
  PY_MAJOR=$($PY_BIN -c "import sys; print(sys.version_info.major)")
  PY_MINOR=$($PY_BIN -c "import sys; print(sys.version_info.minor)")
  if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 12 ]; }; then
    echo "[CRITICAL] Python version must be >= 3.12, found: $PY_VER"
    STOP=1
  else
    echo "[OK] Python $PY_VER"
  fi
fi

# 2. Git check
if command -v git &>/dev/null; then
  GIT_VER=$(git --version)
  echo "[OK] $GIT_VER"
else
  echo "[CRITICAL] git not found in PATH."
  STOP=1
fi

# 3. Make check
if command -v make &>/dev/null; then
  MAKE_VER=$(make --version | head -n 1)
  echo "[OK] $MAKE_VER"
elif command -v mingw32-make &>/dev/null; then
  MAKE_VER=$(mingw32-make --version | head -n 1)
  echo "[OK] $MAKE_VER (as mingw32-make)"
else
  echo "[CRITICAL] make not found in PATH."
  STOP=1
fi

# 4. Flutter check
if command -v flutter &>/dev/null || [ -f "/c/flutter/bin/flutter" ] || [ -f "C:/flutter/bin/flutter.bat" ]; then
  echo "[OK] Flutter is available"
else
  echo "[CRITICAL] flutter not found in PATH."
  STOP=1
fi

# 5. Dart check
if command -v dart &>/dev/null || [ -f "/c/flutter/bin/dart" ] || [ -f "C:/flutter/bin/cache/dart-sdk/bin/dart.exe" ]; then
  echo "[OK] Dart is available"
else
  echo "[WARNING] dart not found in PATH. See docs/HUMAN_TODO.md"
fi

# 6. Java check
if command -v java &>/dev/null; then
  JAVA_VER=$(java -version 2>&1 | head -n 1)
  echo "[OK] $JAVA_VER"
else
  echo "[WARNING] java not found in PATH. See docs/HUMAN_TODO.md"
fi

# 7. Android SDK check
if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ] || [ -d "$HOME/AppData/Local/Android/Sdk" ] || [ -d "C:/Users/varun/AppData/Local/Android/Sdk" ]; then
  echo "[OK] Android SDK located"
else
  echo "[WARNING] Android SDK not located. See docs/HUMAN_TODO.md"
fi

# 8. Docker check
if command -v docker &>/dev/null; then
  DOCKER_VER=$(docker --version)
  echo "[OK] $DOCKER_VER"
else
  echo "[WARNING] docker not found in PATH. See docs/HUMAN_TODO.md"
fi

echo "=================================="

if [ "$STOP" -ne 0 ]; then
  echo "STOP: Missing required tools (python >=3.12, git, make, or flutter). Resolve before continuing."
  exit 1
fi

echo "Doctor check PASSED."
exit 0
