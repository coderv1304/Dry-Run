"""Validation tool for OpenAPI contract, JSON schemas, examples, and BANNED_UI."""

import json
import os
import re
import sys
import yaml
import jsonschema

root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
contracts_dir = os.path.join(root_dir, "contracts")
schemas_dir = os.path.join(contracts_dir, "schemas")
examples_dir = os.path.join(contracts_dir, "examples")
banned_ui_path = os.path.join(root_dir, "docs", "design", "BANNED_UI.md")


def validate_openapi() -> bool:
    openapi_path = os.path.join(contracts_dir, "openapi.yaml")
    if not os.path.exists(openapi_path):
        print("FAIL: openapi.yaml not found")
        return False

    with open(openapi_path, "r", encoding="utf-8") as f:
        spec = yaml.safe_load(f)

    if not spec.get("openapi", "").startswith("3.1"):
        print(f"FAIL: openapi version must be 3.1.x, got {spec.get('openapi')}")
        return False

    required_paths = [
        "/healthz",
        "/readyz",
        "/v1/config",
        "/v1/scenario/graph",
        "/v1/invites",
        "/v1/invites/current",
        "/v1/sessions",
        "/v1/sessions/{id}/turn",
        "/v1/sessions/{id}/end",
        "/v1/sessions/{id}/debrief",
        "/v1/sessions/{id}/share",
        "/v1/sessions/{id}",
        "/v1/reports/current",
    ]

    for p in required_paths:
        if p not in spec.get("paths", {}):
            print(f"FAIL: Missing required path in openapi: {p}")
            return False

    print("PASS: openapi.yaml is valid OpenAPI 3.1 with all required paths.")
    return True


def validate_examples() -> bool:
    schema_map = {
        "problem_detail": "problem_detail.json",
        "config_response": "config_response.json",
        "scenario_graph": "scenario_graph_response.json",
        "invite_response": "invite_response.json",
        "current_invite_response": "current_invite_response.json",
        "turn_response": "turn_response.json",
        "session_create_response": "session_create_response.json",
        "debrief_response_quick": "debrief_response.json",
        "debrief_response_full": "debrief_response.json",
        "debrief_response_low_confidence": "debrief_response.json",
        "debrief_response": "debrief_response.json",
        "share_response": "share_response.json",
        "report_response": "report_response.json",
    }

    loaded_schemas = {}
    for s_name in set(schema_map.values()):
        s_path = os.path.join(schemas_dir, s_name)
        if not os.path.exists(s_path):
            print(f"FAIL: Schema missing: {s_path}")
            return False
        with open(s_path, "r", encoding="utf-8") as f:
            loaded_schemas[s_name] = json.load(f)

    all_passed = True
    example_files = os.listdir(examples_dir)

    for ex_file in sorted(example_files):
        if not ex_file.endswith(".json"):
            continue

        ex_path = os.path.join(examples_dir, ex_file)
        with open(ex_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Find matching schema
        matched_schema = None
        for prefix, s_file in schema_map.items():
            if ex_file.startswith(prefix):
                matched_schema = loaded_schemas[s_file]
                break

        if not matched_schema:
            print(f"FAIL: No matching schema for example: {ex_file}")
            all_passed = False
            continue

        is_valid_example = "_valid" in ex_file
        try:
            jsonschema.validate(instance=data, schema=matched_schema)
            if not is_valid_example:
                print(f"FAIL: Invalid example {ex_file} unexpectedly passed schema validation!")
                all_passed = False
            else:
                print(f"PASS: Valid example {ex_file} correctly validated.")
        except jsonschema.ValidationError:
            if is_valid_example:
                print(f"FAIL: Valid example {ex_file} failed schema validation!")
                all_passed = False
            else:
                print(f"PASS: Invalid example {ex_file} correctly failed schema validation.")

    return all_passed


def validate_banned_ui() -> bool:
    if not os.path.exists(banned_ui_path):
        print(f"FAIL: BANNED_UI.md not found at {banned_ui_path}")
        return False

    with open(banned_ui_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Match numbered items 1. through 18.
    items = re.findall(r"^\s*(\d+)\.\s+(.+)$", content, re.MULTILINE)
    count = len(items)

    expected_topics = [
        "purple gradients",
        "lucide icons",
        "sparkle icons",
        "3 cards in a row",
        "bento grids",
        "glass cards",
        "glowing orbs",
        "colour stripe on cards",
        "inter or geist font",
        "emojis in headings",
        "em dashes everywhere",
        "3 pricing tiers",
        "fake testimonials",
        "dot grid backgrounds",
        "hover animations",
        '"vite + react" tab',
        "default favicon",
        "lorem ipsum live",
    ]

    if count != 18:
        print(f"FAIL: BANNED_UI.md must have exactly 18 items, found {count}")
        return False

    for idx, (num_str, text) in enumerate(items, start=1):
        if int(num_str) != idx:
            print(f"FAIL: Numbering out of order in BANNED_UI.md: item {num_str} expected {idx}")
            return False

    print("PASS: BANNED_UI.md has exactly 18 items properly numbered.")
    return True


def main():
    ok_openapi = validate_openapi()
    ok_examples = validate_examples()
    ok_banned_ui = validate_banned_ui()

    if not (ok_openapi and ok_examples and ok_banned_ui):
        print("\nGATE VALIDATION FAILED")
        sys.exit(1)

    print("\nALL CONTRACT AND UI AUDITS PASSED")
    sys.exit(0)


if __name__ == "__main__":
    main()
