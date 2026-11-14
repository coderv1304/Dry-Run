.PHONY: all test lint ci preflight gate-0 gate-1 gate-2 gate-3 gate-3b gate-4 gate-4b gate-5 \
	audit backend-audit backend-lint backend-test contract-check drill-check bench

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

bench:
	@echo "Benchmarking scripted turn latency..."
	@$(PYTHON) scripts/bench_turns.py

gate-2:
	@echo "owned by Prompt 2"
	@exit 1

gate-3:
	@echo "owned by Prompt 3"
	@exit 1

gate-3b:
	@echo "owned by Prompt 3b"
	@exit 1

gate-4:
	@echo "owned by Prompt 4"
	@exit 1

gate-4b:
	@echo "owned by Prompt 4b"
	@exit 1

gate-5:
	@echo "owned by Prompt 5"
	@exit 1

ci: gate-0 test
	@echo "=== CI Completed Successfully ==="
