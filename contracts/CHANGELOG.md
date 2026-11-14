# Contracts Changelog

All changes to the OpenAPI contract, schemas, and example fixtures must be documented here.

## [1.0.0] - 2026-11-14

### Added
- Initial OpenAPI 3.1 specification (`contracts/openapi.yaml`).
- Stable error codes using `application/problem+json`:
  - `invalid_token`
  - `token_expired`
  - `session_limit_reached`
  - `turn_index_mismatch`
  - `rate_limited`
  - `payload_too_large`
  - `consent_required`
  - `session_ended`
  - `internal`
- Endpoints:
  - `POST /v1/invites`
  - `GET /v1/invites/current`
  - `POST /v1/sessions`
  - `POST /v1/sessions/{id}/turn`
  - `POST /v1/sessions/{id}/end`
  - `GET /v1/sessions/{id}/debrief`
  - `POST /v1/sessions/{id}/share`
  - `DELETE /v1/sessions/{id}`
  - `GET /v1/reports/current`
  - `GET /v1/scenario/graph`
  - `GET /v1/config`
  - `GET /healthz`
  - `GET /readyz`
- Stage IDs: `contact`, `accusation`, `isolation`, `urgency`, `transfer`.
- Participant labels: `P1`, `P2`, `P3`, `P4`.
- Compliance labels: `C1`, `C2`, `C3`, `C4`.
- End reasons: `hung_up`, `verified_callback`, `complied_transfer`, `turn_cap`, `timeout`, `participant_ended`.
- Habits: `hang_up`, `call_back_official`, `tell_family`.
- JSON Schemas in `contracts/schemas/`.
- Valid and invalid example fixtures in `contracts/examples/`.
