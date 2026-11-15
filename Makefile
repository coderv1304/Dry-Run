.PHONY: all test lint ci preflight gate-0 gate-1 gate-2 gate-3 gate-3b gate-4 gate-4b gate-5 \
	audit backend-audit backend-lint backend-test contract-check drill-check bench \
	lint-ui design-tokens design-assets goldens pg-check pg-live web \
	keystore apk apk-debug manifest-check demo-check

PYTHON ?= python
DART ?= dart
FLUTTER ?= flutter

all: gate-0

preflight:
	@echo "Running environment doctor..."
	@$(PYTHON) scripts/doctor.py

test:
	@echo "Running backend skeleton tests..."
	@cd backend && $(PYTHON) -m pytest tests
	@echo "Running API client package tests..."
	@cd packages/api_client && $(DART) test
	@echo "All tests passed."

lint:
	@echo "Validating OpenAPI contracts, schemas, examples, and BANNED_UI..."
	@$(PYTHON) tool/validate_contracts.py
	@echo "Running flutter analyze on app..."
	@cd app && $(FLUTTER) analyze --no-fatal-infos
	@echo "All lints passed."

gate-0: preflight lint test
	@echo "Verifying default asset hashes recorded..."
	@$(PYTHON) -c "import os; assert os.path.exists('tool/default_asset_hashes.txt') and os.path.getsize('tool/default_asset_hashes.txt') > 0, 'default_asset_hashes.txt missing or empty'"
	@echo "Verifying CI configuration exists..."
	@$(PYTHON) -c "import os; assert os.path.exists('.github/workflows/ci.yml'), '.github/workflows/ci.yml missing'"
	@echo "=== Gate 0 Verification PASSED ==="

gate-1: backend-lint backend-test backend-audit contract-check drill-check bench
	@echo "=== Gate 1 Verification PASSED ==="

backend-lint:
	@echo "Running backend lint and types..."
	@cd backend && $(PYTHON) -m ruff check app tests alembic
	@cd backend && $(PYTHON) -m mypy app

backend-test:
	@echo "Running backend tests with coverage..."
	@cd backend && $(PYTHON) -m pytest tests --cov=app --cov-report=term-missing --cov-fail-under=80

backend-audit:
	@echo "Running static security scan and dependency audit..."
	@cd backend && $(PYTHON) -m bandit -q -r app -x app/scenarios
	@cd backend && $(PYTHON) -m pip_audit -r requirements.lock --strict

audit: backend-audit

contract-check:
	@echo "Validating OpenAPI contract and example fixtures..."
	@$(PYTHON) tool/validate_contracts.py
	@cd backend && $(PYTHON) -m pytest tests/test_contract.py -q

drill-check:
	@echo "Running three-language LLM-off drill..."
	@$(PYTHON) scripts/drill_check.py

pg-check:
	@echo "Running Postgres integration suite (starts compose db)..."
	@$(PYTHON) scripts/pg_check.py

pg-live:
	@echo "Running live cross-process concurrency check (starts Uvicorn)..."
	@$(PYTHON) scripts/live_concurrency_check.py --spawn

bench:
	@echo "Benchmarking scripted turn latency..."
	@$(PYTHON) scripts/bench_turns.py

design-tokens:
	@echo "Regenerating design tokens and icons from design/tokens.json..."
	@$(PYTHON) tool/gen_tokens.py
	@$(PYTHON) tool/gen_icons.py

design-assets:
	@echo "Regenerating brand marks from token colours..."
	@$(PYTHON) tool/gen_brand_assets.py

lint-ui:
	@echo "Verifying generated tokens and icons are current..."
	@$(PYTHON) tool/gen_tokens.py --check
	@$(PYTHON) tool/gen_icons.py --check
	@echo "Verifying Poppins Devanagari coverage..."
	@$(PYTHON) tool/font_coverage_check.py
	@echo "Checking WCAG contrast for every declared pairing in both modes..."
	@$(PYTHON) tool/contrast_check.py
	@echo "Running the design lint..."
	@$(PYTHON) tool/design_lint.py
	@echo "Running the design lint unit tests..."
	@$(PYTHON) -m pytest tests/test_design_lint.py -q

goldens:
	@echo "Regenerating component and gallery goldens..."
	@cd app && $(FLUTTER) test --update-goldens

web:
	@echo "Building the web app with self-hosted engine files and bundled fonts..."
	@cd app && $(FLUTTER) build web --release --no-web-resources-cdn --base-href /
	@$(PYTHON) -c "import os; assert os.path.exists('app/build/web/canvaskit/canvaskit.wasm'), 'CanvasKit was not self-hosted'; assert os.path.exists('app/build/web/assets/assets/fonts/Poppins-Regular.ttf'), 'Fonts were not bundled'; assert os.path.exists('app/build/web/_headers'), '_headers was not copied'; print('Web build ready at app/build/web')"

gate-2: lint-ui lint
	@echo "Running Flutter design system tests and goldens..."
	@cd app && $(FLUTTER) test
	@echo "=== Gate 2 Verification PASSED ==="

gate-3: lint-ui lint test
	@echo "Running the full Flutter app suite, including flow and golden tests..."
	@cd app && $(FLUTTER) analyze
	@cd app && $(FLUTTER) test
	@echo "Verifying web hardening files exist..."
	@$(PYTHON) -c "import os; [os.path.exists('app/web/' + name) or (_ for _ in ()).throw(AssertionError('app/web/' + name + ' missing')) for name in ('_headers', '_redirects', 'manifest.json', 'index.html')]"
	@echo "Verifying performance notes exist..."
	@$(PYTHON) -c "import os; assert os.path.exists('docs/PERF.md') and os.path.getsize('docs/PERF.md') > 0, 'docs/PERF.md missing or empty'"
	@echo "=== Gate 3 Verification PASSED ==="

keystore:
	@echo "Generating the local release keystore (gitignored)..."
	@$(PYTHON) tool/make_keystore.py

apk: keystore
	@echo "Building the signed release APK with obfuscation..."
	@cd app && $(FLUTTER) build apk --release --obfuscate --split-debug-info=build/symbols
	@$(PYTHON) -c "import os; path = 'app/build/app/outputs/flutter-apk/app-release.apk'; assert os.path.exists(path) and os.path.getsize(path) > 0, 'release APK missing'; print('Release APK ready: ' + path)"

apk-debug:
	@echo "Building a debug APK for a machine without the Android release toolchain..."
	@cd app && $(FLUTTER) build apk --debug
	@$(PYTHON) -c "import os; path = 'app/build/app/outputs/flutter-apk/app-debug.apk'; assert os.path.exists(path) and os.path.getsize(path) > 0, 'debug APK missing'; print('Debug APK ready: ' + path)"

manifest-check:
	@$(PYTHON) tool/check_android_manifest.py

demo-check:
	@$(PYTHON) tool/check_demo_strings.py

gate-3b: lint-ui
	@echo "Running flutter analyze with infos fatal..."
	@cd app && $(FLUTTER) analyze
	@echo "Running the full Flutter app suite..."
	@cd app && $(FLUTTER) test
	@echo "Building the signed release APK..."
	@$(PYTHON) tool/make_keystore.py
	@cd app && $(FLUTTER) build apk --release --obfuscate --split-debug-info=build/symbols
	@$(PYTHON) -c "import os; path = 'app/build/app/outputs/flutter-apk/app-release.apk'; assert os.path.exists(path) and os.path.getsize(path) > 0, 'release APK missing'"
	@echo "Checking the merged manifest and FLAG_SECURE wiring..."
	@$(PYTHON) tool/check_android_manifest.py
	@echo "Checking the production build has no demo strings..."
	@$(PYTHON) tool/check_demo_strings.py
	@echo "Verifying the release documentation exists..."
	@$(PYTHON) -c "import os; assert os.path.exists('docs/RELEASE.md') and os.path.getsize('docs/RELEASE.md') > 0, 'docs/RELEASE.md missing or empty'"
	@echo "=== Gate 3b Verification PASSED ==="

gate-4: lint-ui lint
	@echo "Running the full Flutter app suite, screenshots and goldens..."
	@cd app && $(FLUTTER) test
	@echo "Checking the evidence screenshots..."
	@$(PYTHON) tool/check_screenshots.py
	@echo "Verifying the gate 4 records exist..."
	@$(PYTHON) -c "import os; [os.path.exists('docs/' + name) or (_ for _ in ()).throw(AssertionError('docs/' + name + ' missing')) for name in ('CHECKLIST_4.md', 'design/DESIGN_DECISIONS.md')]"
	@echo "=== Gate 4 Verification PASSED ==="

gate-4b:
	@echo "owned by Prompt 4b"
	@exit 1

gate-5:
	@echo "owned by Prompt 5"
	@exit 1

ci: gate-0 test lint-ui
	@echo "=== CI Completed Successfully ==="
