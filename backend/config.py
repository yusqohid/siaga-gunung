from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "SiagaGunung API"
    app_version: str = "1.0.0"
    debug: bool = False

    # Source settings
    magma_base_url: str = "https://magma.esdm.go.id"
    source_timeout_seconds: int = 10
    max_retries: int = 2
    retry_backoff_seconds: float = 2.0

    # Cache & refresh settings (PRD Section 9.5 & 14.18)
    list_refresh_interval_minutes: int = 30
    detail_cache_ttl_minutes: int = 60
    stale_threshold_minutes: int = 120  # > 2 jam = stale

    # Anomaly protection (PRD Section 9.2 & 14.19)
    count_drop_threshold_pct: float = 0.20  # > 20% penurunan = tahan cache lama

    # CORS settings
    allowed_origins: list[str] = ["*"]



settings = Settings()
