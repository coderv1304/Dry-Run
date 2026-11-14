"""Environment-only configuration for the Dry Run backend.

Every value comes from an environment variable.  Production startup is
refused when any required secret or safety-critical setting is missing.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, model_validator

Environment = Literal["development", "test", "production"]


def _bool(value: str | None, default: bool = False) -> bool:
    """Parse a permissive boolean environment value."""
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _int(value: str | None, default: int) -> int:
    """Parse an integer environment value."""
    if value is None or value.strip() == "":
        return default
    return int(value)


def _float(value: str | None, default: float) -> float:
    """Parse a float environment value."""
    if value is None or value.strip() == "":
        return default
    return float(value)


class Settings(BaseModel):
    """Validated runtime settings."""

    model_config = ConfigDict(extra="forbid", frozen=True)

    env: Environment = "development"
    database_url: str = "sqlite:///./dryrun.db"
    token_pepper: str = "development-only-pepper-change-me"

    llm_enabled: bool = False
    voice_enabled: bool = False
    llm_provider: Literal["openai_compatible", "anthropic"] = "openai_compatible"
    llm_base_url: str = "https://api.openai.com/v1"
    llm_api_key: str | None = None
    llm_model_primary: str = "gpt-4o-mini"
    llm_model_cheap: str = "gpt-4o-mini"
    llm_timeout_seconds: float = 1.5
    llm_rescore_timeout_seconds: float = 8.0
    llm_max_output_tokens: int = 120
    llm_rescore_max_tokens: int = 700
    llm_input_cost_per_mtok: float = 0.15
    llm_output_cost_per_mtok: float = 0.60
    daily_llm_budget_usd: float = 1.0
    llm_kill_switch: bool = False

    max_turns: int = 12
    max_duration_seconds: int = 900
    idle_timeout_seconds: int = 600
    max_request_body_bytes: int = 4096
    retention_days: int = 7
    invite_ttl_days: int = 7
    session_ttl_days: int = 7
    report_ttl_days: int = 7
    max_sessions_per_invite: int = 3

    trusted_proxy_count: int = 0
    cors_origins: tuple[str, ...] = ()
    invite_per_ip_per_hour: int = 10
    invite_global_daily_cap: int = 100
    turn_per_ip_per_minute: int = 60
    turn_per_token_per_minute: int = 30

    purge_interval_seconds: int = 300
    auto_create_schema: bool = False
    scenario_path: str | None = None
    log_level: str = "INFO"

    @model_validator(mode="after")
    def _production_requirements(self) -> Settings:
        """Refuse unsafe production configuration."""
        if self.env != "production":
            return self
        missing: list[str] = []
        if "change-me" in self.token_pepper or len(self.token_pepper) < 24:
            missing.append("TOKEN_PEPPER")
        if self.database_url.startswith("sqlite"):
            missing.append("DATABASE_URL (managed Postgres required)")
        if self.llm_enabled and not self.llm_api_key:
            missing.append("LLM_API_KEY")
        if missing:
            raise ValueError("missing required production settings: " + ", ".join(missing))
        return self

    @classmethod
    def from_env(cls, environ: dict[str, str] | None = None) -> Settings:
        """Build settings from an environment mapping (defaults to os.environ)."""
        import os

        env = os.environ if environ is None else environ
        payload: dict[str, object] = {
            "env": env.get("APP_ENV", "development"),
            "database_url": env.get("DATABASE_URL", "sqlite:///./dryrun.db"),
            "token_pepper": env.get("TOKEN_PEPPER", "development-only-pepper-change-me"),
            "llm_enabled": _bool(env.get("LLM_ENABLED")),
            "voice_enabled": _bool(env.get("VOICE_ENABLED")),
            "llm_provider": env.get("LLM_PROVIDER", "openai_compatible"),
            "llm_base_url": env.get("LLM_BASE_URL", "https://api.openai.com/v1"),
            "llm_api_key": env.get("LLM_API_KEY") or None,
            "llm_model_primary": env.get("LLM_MODEL_PRIMARY", "gpt-4o-mini"),
            "llm_model_cheap": env.get("LLM_MODEL_CHEAP", "gpt-4o-mini"),
            "llm_timeout_seconds": _float(env.get("LLM_TIMEOUT_SECONDS"), 1.5),
            "llm_rescore_timeout_seconds": _float(env.get("LLM_RESCORE_TIMEOUT_SECONDS"), 8.0),
            "llm_max_output_tokens": _int(env.get("LLM_MAX_OUTPUT_TOKENS"), 120),
            "llm_rescore_max_tokens": _int(env.get("LLM_RESCORE_MAX_TOKENS"), 700),
            "llm_input_cost_per_mtok": _float(env.get("LLM_INPUT_COST_PER_MTOK"), 0.15),
            "llm_output_cost_per_mtok": _float(env.get("LLM_OUTPUT_COST_PER_MTOK"), 0.60),
            "daily_llm_budget_usd": _float(env.get("DAILY_LLM_BUDGET_USD"), 1.0),
            "llm_kill_switch": _bool(env.get("LLM_KILL_SWITCH")),
            "max_turns": _int(env.get("MAX_TURNS"), 12),
            "max_duration_seconds": _int(env.get("MAX_DURATION_SECONDS"), 900),
            "idle_timeout_seconds": _int(env.get("IDLE_TIMEOUT_SECONDS"), 600),
            "max_request_body_bytes": _int(env.get("MAX_REQUEST_BODY_BYTES"), 4096),
            "retention_days": _int(env.get("RETENTION_DAYS"), 7),
            "invite_ttl_days": _int(env.get("INVITE_TTL_DAYS"), 7),
            "session_ttl_days": _int(env.get("SESSION_TTL_DAYS"), 7),
            "report_ttl_days": _int(env.get("REPORT_TTL_DAYS"), 7),
            "max_sessions_per_invite": _int(env.get("MAX_SESSIONS_PER_INVITE"), 3),
            "trusted_proxy_count": _int(env.get("TRUSTED_PROXY_COUNT"), 0),
            "cors_origins": tuple(
                part.strip() for part in env.get("CORS_ORIGINS", "").split(",") if part.strip()
            ),
            "invite_per_ip_per_hour": _int(env.get("INVITE_PER_IP_PER_HOUR"), 10),
            "invite_global_daily_cap": _int(env.get("INVITE_GLOBAL_DAILY_CAP"), 100),
            "turn_per_ip_per_minute": _int(env.get("TURN_PER_IP_PER_MINUTE"), 60),
            "turn_per_token_per_minute": _int(env.get("TURN_PER_TOKEN_PER_MINUTE"), 30),
            "purge_interval_seconds": _int(env.get("PURGE_INTERVAL_SECONDS"), 300),
            "auto_create_schema": _bool(env.get("AUTO_CREATE_SCHEMA")),
            "scenario_path": env.get("SCENARIO_PATH") or None,
            "log_level": env.get("LOG_LEVEL", "INFO"),
        }
        return cls.model_validate(payload)

    @property
    def max_body_bytes(self) -> int:
        """Alias used by middleware and contract responses."""
        return self.max_request_body_bytes


__all__ = ["Settings"]
