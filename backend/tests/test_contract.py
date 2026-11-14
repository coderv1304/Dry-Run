"""Contract-first checks: generated OpenAPI, examples, and safety surfaces."""

from __future__ import annotations

import json
from pathlib import Path

import jsonschema
import pytest
import yaml
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[2]
CONTRACTS = ROOT / "contracts"
SCHEMA_MAP = {
    "problem_detail": "problem_detail.json",
    "config_response": "config_response.json",
    "scenario_graph": "scenario_graph_response.json",
    "invite_response": "invite_response.json",
    "current_invite_response": "current_invite_response.json",
    "turn_response": "turn_response.json",
    "session_create_response": "session_create_response.json",
    "debrief_response": "debrief_response.json",
    "share_response": "share_response.json",
    "report_response": "report_response.json",
}


def _contract() -> dict:
    return yaml.safe_load((CONTRACTS / "openapi.yaml").read_text(encoding="utf-8"))


def test_generated_openapi_equals_contract(client: TestClient) -> None:
    assert client.get("/openapi.json").json() == _contract()


def test_contract_paths_match_routes(client: TestClient) -> None:
    contract = _contract()["paths"]
    routes = {
        (method.upper(), path)
        for path, operations in contract.items()
        for method in operations
    }
    assert ("GET", "/healthz") in routes
    assert ("POST", "/v1/sessions/{id}/turn") in routes
    assert ("DELETE", "/v1/sessions/{id}") in routes
    assert len(routes) == 13


def test_contract_covers_every_problem_code(client: TestClient) -> None:
    codes = set(_contract()["components"]["schemas"]["ProblemDetail"]["properties"]["code"]["enum"])
    for code in (
        "invalid_token",
        "token_expired",
        "session_limit_reached",
        "turn_index_mismatch",
        "rate_limited",
        "payload_too_large",
        "consent_required",
        "session_ended",
        "validation_error",
        "internal",
    ):
        assert code in codes


def test_contract_documents_session_limit_conflict() -> None:
    create = _contract()["paths"]["/v1/sessions"]["post"]["responses"]
    assert "409" in create
    assert create["409"]["$ref"].endswith("ProblemSessionLimit")


@pytest.mark.parametrize("name", sorted(SCHEMA_MAP))
def test_valid_examples_match_their_schemas(name: str) -> None:
    schema = json.loads((CONTRACTS / "schemas" / SCHEMA_MAP[name]).read_text(encoding="utf-8"))
    examples = sorted(
        path
        for path in CONTRACTS.glob(f"examples/{name}_*.json")
        if "_valid" in path.stem and "_invalid" not in path.stem
    )
    assert examples
    for example in examples:
        jsonschema.validate(
            instance=json.loads(example.read_text(encoding="utf-8")), schema=schema
        )


@pytest.mark.parametrize("name", sorted(SCHEMA_MAP))
def test_invalid_examples_are_rejected(name: str) -> None:
    schema = json.loads((CONTRACTS / "schemas" / SCHEMA_MAP[name]).read_text(encoding="utf-8"))
    examples = sorted(CONTRACTS.glob(f"examples/{name}_invalid.json"))
    assert examples
    for example in examples:
        with pytest.raises(jsonschema.ValidationError):
            jsonschema.validate(
                instance=json.loads(example.read_text(encoding="utf-8")), schema=schema
            )
