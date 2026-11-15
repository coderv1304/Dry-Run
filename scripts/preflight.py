"""Run the full preflight check and print a pass/fail table.

This is invoked from the Makefile as `make preflight`.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "app"


def _run_raw(cmd: list[str]) -> tuple[int, str, str]:
    # Resolve script paths relative to ROOT
    resolved = []
    for c in cmd:
        if not os.path.isabs(c) and not c.startswith('/'):
            resolved.append(str(ROOT / c))
        else:
            resolved.append(c)
    result = subprocess.run(resolved, capture_output=True, text=True, cwd=str(ROOT))
    return result.returncode, result.stdout, result.stderr
import os


def main() -> int:
    checks: list[tuple[str, int, str]] = []

    # 1. Doctor
    rc, out, err = _run_raw(["scripts/doctor.py"])
    checks.append(("doctor", rc == 0, out))

    # 2. Tests
    rc, out, err = _run_raw(["make", "test"])
    checks.append(("tests", rc == 0, out))

    # 3. Audit
    rc, out, err = _run_raw(["make", "audit"])
    checks.append(("audit", rc == 0, out))

    # 4. Lint UI
    rc, out, err = _run_raw(["make", "lint-ui"])
    checks.append(("lint-ui", rc == 0, out))

    # 5. Claims lint
    rc, out, err = _run_raw([sys.executable, "scripts/claims_lint.py"])
    checks.append(("claims-lint", rc == 0, out))

    # 6. Contracts
    rc, out, err = _run_raw([sys.executable, "tool/validate_contracts.py"])
    checks.append(("contracts", rc == 0, out))

    # 7. DEMO_MODE widget test (best-effort)
    demo_path = str(APP / "test" / "widget" / "demo_widget_test.dart")
    if Path(demo_path).exists():
        rc, out, err = _run_raw([sys.executable, "-m", "dart", "test", demo_path, "--tb=short"])
        checks.append(("demo-widget", rc == 0, out))
    else:
        checks.append(("demo-widget", False, "widget test file missing"))

    # 8. Scripted backend drill
    rc, out, err = _run_raw([sys.executable, "scripts/drill_check.py"])
    checks.append(("drill-check", rc == 0, out))

    # 8. Secrets scan (best-effort)
    secrets_path = ROOT / "tool" / "secrets_scan.py"
    if secrets_path.exists():
        rc, out, err = _run_raw([sys.executable, str(secrets_path)])
        checks.append(("secrets-scan", rc == 0, out))
    else:
        checks.append(("secrets-scan", False, "script missing: tool/secrets_scan.py"))

    # 9. Offline fallback
    landing_text = (ROOT / "landing" / "content.json").read_text().lower()
    practice_ok = "practice" in landing_text
    protection_ok = "protection" not in landing_text or "not protection" in landing_text
    checks.append(("offline-fallback", practice_ok and protection_ok,
                     f"practice={'yes' if practice_ok else 'no'}, protection ok={'yes' if protection_ok else 'no'}"))

    # 10. Built output scans
    rc, out, err = _run_raw([sys.executable, "tool/check_landing.py"])
    checks.append(("built-output", rc == 0, out))

    # Print table
    all_pass = all(p for _, p, _ in checks)
    print("=== Dry Run Preflight Report ===")
    print(f"{'Check':<25} {'Result':<10} {'Detail'}")
    print("-" * 60)
    for name, passed, detail in checks:
        result = "PASS" if passed else "FAIL"
        if not passed:
            all_pass = False
        detail_show = detail[:60] + ("..." if len(detail) > 60 else "")
        print(f"{name:<25} {result:<10} {detail_show}")
    print("-" * 60)
    print(f"Overall: {'ALL PASSED' if all_pass else 'SOME FAILED'}")
    print(f"Checks: {sum(1 for _, p, _ in checks if p)}/{len(checks)} passed")

    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())