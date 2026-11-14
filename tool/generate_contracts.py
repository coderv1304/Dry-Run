"""Generate JSON Schemas and Example Fixtures for Dry Run contracts."""

import json
import os
import sys

schemas_dir = os.path.abspath("contracts/schemas")
examples_dir = os.path.abspath("contracts/examples")
os.makedirs(schemas_dir, exist_ok=True)
os.makedirs(examples_dir, exist_ok=True)

# 1. ProblemDetail Schema
problem_detail_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ProblemDetail",
    "type": "object",
    "required": ["type", "title", "status", "detail", "code"],
    "properties": {
        "type": {"type": "string"},
        "title": {"type": "string"},
        "status": {"type": "integer"},
        "detail": {"type": "string"},
        "code": {
            "type": "string",
            "enum": [
                "invalid_token", "token_expired", "session_limit_reached",
                "turn_index_mismatch", "rate_limited", "payload_too_large",
                "consent_required", "session_ended", "internal"
            ]
        }
    },
    "additionalProperties": False
}

# 2. ConfigResponse Schema
config_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ConfigResponse",
    "type": "object",
    "required": ["flags", "languages", "limits"],
    "properties": {
        "flags": {
            "type": "object",
            "required": ["llm_enabled", "voice_enabled"],
            "properties": {
                "llm_enabled": {"type": "boolean"},
                "voice_enabled": {"type": "boolean"}
            },
            "additionalProperties": False
        },
        "languages": {
            "type": "array",
            "items": {"type": "string"}
        },
        "limits": {
            "type": "object",
            "required": ["max_turns", "max_duration_seconds", "idle_timeout_seconds", "max_request_body_bytes", "retention_days"],
            "properties": {
                "max_turns": {"type": "integer"},
                "max_duration_seconds": {"type": "integer"},
                "idle_timeout_seconds": {"type": "integer"},
                "max_request_body_bytes": {"type": "integer"},
                "retention_days": {"type": "integer"}
            },
            "additionalProperties": False
        }
    },
    "additionalProperties": False
}

# 3. ScenarioGraphResponse Schema
scenario_graph_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ScenarioGraphResponse",
    "type": "object",
    "required": ["stage_ids", "labels"],
    "properties": {
        "stage_ids": {
            "type": "array",
            "items": {"type": "string", "enum": ["contact", "accusation", "isolation", "urgency", "transfer"]}
        },
        "labels": {
            "type": "array",
            "items": {"type": "string", "enum": ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]}
        }
    },
    "additionalProperties": False
}

# 4. InviteResponse Schema
invite_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "InviteResponse",
    "type": "object",
    "required": ["invite_token", "expires_at"],
    "properties": {
        "invite_token": {"type": "string"},
        "expires_at": {"type": "string"}
    },
    "additionalProperties": False
}

# 5. CurrentInviteResponse Schema
current_invite_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "CurrentInviteResponse",
    "type": "object",
    "required": ["language", "created_at", "expires_at"],
    "properties": {
        "cohort": {"type": "string"},
        "language": {"type": "string"},
        "created_at": {"type": "string"},
        "expires_at": {"type": "string"}
    },
    "additionalProperties": False
}

# 6. TurnResponse Schema
turn_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "TurnResponse",
    "type": "object",
    "required": ["stage_id", "pressure", "status", "turn_index", "fallback_used", "pii_warning"],
    "properties": {
        "officer_line": {
            "type": ["object", "null"],
            "required": ["display", "speak", "language"],
            "properties": {
                "display": {"type": "string"},
                "speak": {"type": "string"},
                "language": {"type": "string"}
            },
            "additionalProperties": False
        },
        "stage_id": {
            "type": "string",
            "enum": ["contact", "accusation", "isolation", "urgency", "transfer"]
        },
        "pressure": {
            "type": "integer",
            "minimum": 0,
            "maximum": 3
        },
        "status": {
            "type": "string",
            "enum": ["active", "ended"]
        },
        "end_reason": {
            "type": "string",
            "enum": ["hung_up", "verified_callback", "complied_transfer", "turn_cap", "timeout", "participant_ended"]
        },
        "turn_index": {"type": "integer"},
        "fallback_used": {"type": "boolean"},
        "pii_warning": {"type": "boolean"}
    },
    "additionalProperties": False
}

# 7. SessionCreateResponse Schema
session_create_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "SessionCreateResponse",
    "type": "object",
    "required": ["session_id", "session_token", "first_turn", "limits"],
    "properties": {
        "session_id": {"type": "string"},
        "session_token": {"type": "string"},
        "first_turn": turn_response_schema,
        "limits": {
            "type": "object",
            "required": ["max_turns", "max_duration_seconds", "idle_timeout_seconds"],
            "properties": {
                "max_turns": {"type": "integer"},
                "max_duration_seconds": {"type": "integer"},
                "idle_timeout_seconds": {"type": "integer"}
            },
            "additionalProperties": False
        }
    },
    "additionalProperties": False
}

# 8. DebriefResponse Schema
debrief_content_schema = {
    "type": "object",
    "required": ["quality", "low_confidence", "state_path", "events", "first_compliance", "did_well_ids", "habit_id"],
    "properties": {
        "quality": {"type": "string", "enum": ["quick", "full"]},
        "low_confidence": {"type": "boolean"},
        "state_path": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["stage_id", "turn_index"],
                "properties": {
                    "stage_id": {"type": "string", "enum": ["contact", "accusation", "isolation", "urgency", "transfer"]},
                    "turn_index": {"type": "integer"}
                },
                "additionalProperties": False
            }
        },
        "events": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["turn_index", "label", "confidence", "quote"],
                "properties": {
                    "turn_index": {"type": "integer"},
                    "label": {"type": "string", "enum": ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]},
                    "confidence": {"type": "number"},
                    "quote": {
                        "type": ["object", "null"],
                        "required": ["text", "start", "end"],
                        "properties": {
                            "text": {"type": "string"},
                            "start": {"type": "integer"},
                            "end": {"type": "integer"}
                        },
                        "additionalProperties": False
                    }
                },
                "additionalProperties": False
            }
        },
        "first_compliance": {
            "type": ["object", "null"],
            "required": ["turn_index", "stage_id", "label"],
            "properties": {
                "turn_index": {"type": "integer"},
                "stage_id": {"type": "string", "enum": ["contact", "accusation", "isolation", "urgency", "transfer"]},
                "label": {"type": "string", "enum": ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]}
            },
            "additionalProperties": False
        },
        "did_well_ids": {
            "type": "array",
            "items": {"type": "string"}
        },
        "habit_id": {
            "type": "string",
            "enum": ["hang_up", "call_back_official", "tell_family"]
        }
    },
    "additionalProperties": False
}

debrief_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "DebriefResponse",
    "type": "object",
    "required": ["status", "quality", "debrief"],
    "properties": {
        "status": {"type": "string", "enum": ["pending", "ready"]},
        "quality": {"type": "string", "enum": ["quick", "full"]},
        "debrief": {
            "oneOf": [
                {"type": "null"},
                debrief_content_schema
            ]
        }
    },
    "additionalProperties": False
}

# 9. ShareResponse Schema
share_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ShareResponse",
    "type": "object",
    "required": ["report_token", "expires_at"],
    "properties": {
        "report_token": {"type": "string"},
        "expires_at": {"type": "string"}
    },
    "additionalProperties": False
}

# 10. ReportResponse Schema
report_response_schema = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ReportResponse",
    "type": "object",
    "required": ["report_token", "shared_at", "debrief"],
    "properties": {
        "report_token": {"type": "string"},
        "shared_at": {"type": "string"},
        "debrief": debrief_content_schema
    },
    "additionalProperties": False
}

schemas = {
    "problem_detail.json": problem_detail_schema,
    "config_response.json": config_response_schema,
    "scenario_graph_response.json": scenario_graph_schema,
    "invite_response.json": invite_response_schema,
    "current_invite_response.json": current_invite_response_schema,
    "turn_response.json": turn_response_schema,
    "session_create_response.json": session_create_response_schema,
    "debrief_response.json": debrief_response_schema,
    "share_response.json": share_response_schema,
    "report_response.json": report_response_schema,
}

for name, s in schemas.items():
    with open(os.path.join(schemas_dir, name), "w", encoding="utf-8") as f:
        json.dump(s, f, indent=2)
    print(f"Generated schema: {name}")

# Now generate VALID and INVALID examples for each response
examples = {
    # Problem detail
    "problem_detail_valid.json": {
        "type": "https://dryrun.in/errors/invalid_token",
        "title": "Invalid Token",
        "status": 401,
        "detail": "Provided session token is invalid or expired.",
        "code": "invalid_token"
    },
    "problem_detail_invalid.json": {
        "type": "https://dryrun.in/errors/unknown",
        "title": "Bad Error",
        "status": "not_an_int",
        "detail": "Missing fields",
        "code": "unrecognized_code"
    },
    # Config
    "config_response_valid.json": {
        "flags": {"llm_enabled": False, "voice_enabled": False},
        "languages": ["en", "hi", "hinglish"],
        "limits": {
            "max_turns": 12,
            "max_duration_seconds": 900,
            "idle_timeout_seconds": 600,
            "max_request_body_bytes": 4096,
            "retention_days": 7
        }
    },
    "config_response_invalid.json": {
        "flags": {"llm_enabled": "not_bool"},
        "languages": ["en"]
    },
    # Scenario graph
    "scenario_graph_valid.json": {
        "stage_ids": ["contact", "accusation", "isolation", "urgency", "transfer"],
        "labels": ["P1", "P2", "P3", "P4", "C1", "C2", "C3", "C4"]
    },
    "scenario_graph_invalid.json": {
        "stage_ids": ["unknown_stage"],
        "labels": ["Z99"]
    },
    # Invite response
    "invite_response_valid.json": {
        "invite_token": "inv_0123456789abcdef0123456789abcdef",
        "expires_at": "2026-11-21T12:00:00Z"
    },
    "invite_response_invalid.json": {
        "token": "missing_required_keys"
    },
    # Current invite response
    "current_invite_response_valid.json": {
        "cohort": "tryout",
        "language": "en",
        "created_at": "2026-11-14T12:00:00Z",
        "expires_at": "2026-11-21T12:00:00Z"
    },
    "current_invite_response_invalid.json": {
        "cohort": 12345
    },
    # Turn response
    "turn_response_valid.json": {
        "officer_line": {
            "display": "Who is speaking?",
            "speak": "Who is speaking?",
            "language": "en"
        },
        "stage_id": "contact",
        "pressure": 0,
        "status": "active",
        "turn_index": 0,
        "fallback_used": False,
        "pii_warning": False
    },
    "turn_response_invalid.json": {
        "stage_id": "not_a_stage",
        "pressure": 99,
        "status": "flying"
    },
    # Session create response
    "session_create_response_valid.json": {
        "session_id": "ses_0123456789abcdef0123456789abcdef",
        "session_token": "tok_0123456789abcdef0123456789abcdef",
        "first_turn": {
            "officer_line": {
                "display": "Identify yourself.",
                "speak": "Identify yourself.",
                "language": "en"
            },
            "stage_id": "contact",
            "pressure": 0,
            "status": "active",
            "turn_index": 0,
            "fallback_used": True,
            "pii_warning": False
        },
        "limits": {
            "max_turns": 12,
            "max_duration_seconds": 900,
            "idle_timeout_seconds": 600
        }
    },
    "session_create_response_invalid.json": {
        "session_id": "ses_123"
    },
    # Debrief response: quick
    "debrief_response_quick_valid.json": {
        "status": "ready",
        "quality": "quick",
        "debrief": {
            "quality": "quick",
            "low_confidence": False,
            "state_path": [{"stage_id": "contact", "turn_index": 0}],
            "events": [
                {
                    "turn_index": 0,
                    "label": "P1",
                    "confidence": 0.95,
                    "quote": {"text": "hello", "start": 0, "end": 5}
                }
            ],
            "first_compliance": None,
            "did_well_ids": ["asked_badge_number"],
            "habit_id": "hang_up"
        }
    },
    # Debrief response: full
    "debrief_response_full_valid.json": {
        "status": "ready",
        "quality": "full",
        "debrief": {
            "quality": "full",
            "low_confidence": False,
            "state_path": [
                {"stage_id": "contact", "turn_index": 0},
                {"stage_id": "accusation", "turn_index": 1}
            ],
            "events": [
                {
                    "turn_index": 1,
                    "label": "C1",
                    "confidence": 0.92,
                    "quote": {"text": "my aadhaar number is", "start": 0, "end": 20}
                }
            ],
            "first_compliance": {
                "turn_index": 1,
                "stage_id": "accusation",
                "label": "C1"
            },
            "did_well_ids": ["refused_money_transfer"],
            "habit_id": "call_back_official"
        }
    },
    # Debrief response: low confidence
    "debrief_response_low_confidence_valid.json": {
        "status": "ready",
        "quality": "full",
        "debrief": {
            "quality": "full",
            "low_confidence": True,
            "state_path": [{"stage_id": "contact", "turn_index": 0}],
            "events": [],
            "first_compliance": None,
            "did_well_ids": ["tell_family"],
            "habit_id": "tell_family"
        }
    },
    "debrief_response_invalid.json": {
        "status": "finished",
        "quality": "medium",
        "debrief": {"unknown_field": True}
    },
    # Share response
    "share_response_valid.json": {
        "report_token": "rep_0123456789abcdef0123456789abcdef",
        "expires_at": "2026-11-21T12:00:00Z"
    },
    "share_response_invalid.json": {
        "token": "rep_123"
    },
    # Report response
    "report_response_valid.json": {
        "report_token": "rep_0123456789abcdef0123456789abcdef",
        "shared_at": "2026-11-14T12:00:00Z",
        "debrief": {
            "quality": "quick",
            "low_confidence": False,
            "state_path": [{"stage_id": "contact", "turn_index": 0}],
            "events": [],
            "first_compliance": None,
            "did_well_ids": ["asked_badge_number"],
            "habit_id": "hang_up"
        }
    },
    "report_response_invalid.json": {
        "report_token": "rep_123"
    }
}

for name, ex in examples.items():
    with open(os.path.join(examples_dir, name), "w", encoding="utf-8") as f:
        json.dump(ex, f, indent=2)
    print(f"Generated example: {name}")

print("\nAll schemas and examples generated successfully.")
