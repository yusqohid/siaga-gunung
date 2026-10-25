from enum import Enum
from datetime import datetime
from pydantic import BaseModel, Field

class ActivityLevel(str, Enum):
    LEVEL_IV = "IV"
    LEVEL_III = "III"
    LEVEL_II = "II"
    LEVEL_I = "I"

LEVEL_LABELS = {
    ActivityLevel.LEVEL_IV: "Awas",
    ActivityLevel.LEVEL_III: "Siaga",
    ActivityLevel.LEVEL_II: "Waspada",
    ActivityLevel.LEVEL_I: "Normal",
}

LEVEL_SORT_ORDER = {
    ActivityLevel.LEVEL_IV: 0,
    ActivityLevel.LEVEL_III: 1,
    ActivityLevel.LEVEL_II: 2,
    ActivityLevel.LEVEL_I: 3,
}

class VolcanoSummary(BaseModel):
    id: str  # Deterministic slug
    name: str
    activity_level: ActivityLevel
    level_label: str
    location: str | None = None
    source_url: str | None = None
    report_time: str | None = None  # None on list because magmalevelonly doesn't provide it
    fetched_at: datetime

class VolcanoDetail(BaseModel):
    id: str
    name: str
    activity_level: ActivityLevel
    level_label: str
    location: str | None = None
    source_url: str | None = None
    report_period: str | None = None  # e.g., "Sabtu - 24 Oktober 2026, periode 00:00-24:00 WIB"
    report_time_available: bool = False
    author: str | None = None
    image_url: str | None = None
    visual_observation: str | None = None
    climatology: str | None = None
    seismic_observation: str | None = None
    recommendation: str | None = None
    other_description: str | None = None
    fetched_at: datetime

class VolcanoListResponse(BaseModel):
    volcanoes: list[VolcanoSummary]
    total_count: int
    by_level: dict[str, int] = Field(
        default_factory=lambda: {"IV": 0, "III": 0, "II": 0, "I": 0}
    )
    fetched_at: datetime
    is_stale: bool
    last_successful_fetch: datetime | None = None
    warning_message: str | None = None
    source_disclaimer: str = (
        "Data diambil dari MAGMA Indonesia (PVMBG/Badan Geologi/ESDM)."
    )

class VolcanoDetailResponse(BaseModel):
    volcano: VolcanoDetail
    is_stale: bool
    fetched_at: datetime
    source_disclaimer: str = (
        "Data diambil dari MAGMA Indonesia (PVMBG/Badan Geologi/ESDM)."
    )

class HealthResponse(BaseModel):
    status: str = "ok"
    app: str
    version: str
    source_healthy: bool
    last_successful_fetch: datetime | None = None
    cache_entry_count: int = 0
