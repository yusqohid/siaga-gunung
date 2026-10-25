import asyncio
import logging
import re
from datetime import datetime, timezone
from typing import Any

from config import settings
from models.volcano import (
    ActivityLevel,
    LEVEL_LABELS,
    LEVEL_SORT_ORDER,
    VolcanoSummary,
    VolcanoDetail,
    VolcanoListResponse,
    VolcanoDetailResponse,
)
from adapters.base import BaseSourceAdapter
from adapters.magma_scraper import MagmaScraperAdapter
from .cache import CacheStore

logger = logging.getLogger(__name__)

def generate_slug(name: str, location: str | None = None) -> str:
    """Generate deterministic, url-friendly slug from volcano name."""
    clean_name = re.sub(r"[^a-zA-Z0-9\s-]", "", name).strip().lower()
    slug = re.sub(r"[\s_-]+", "-", clean_name)
    if location:
        clean_loc = re.sub(r"[^a-zA-Z0-9\s-]", "", location).strip().lower()
        loc_slug = re.sub(r"[\s_-]+", "-", clean_loc)
        slug = f"{slug}-{loc_slug}"
    return slug

class VolcanoService:
    def __init__(self, adapter: BaseSourceAdapter | None = None):
        self.adapter: BaseSourceAdapter = adapter or MagmaScraperAdapter()
        self.cache: CacheStore = CacheStore()
        self._refresh_lock = asyncio.Lock()
        self._last_warning: str | None = None

    def _normalize_and_resolve_slugs(self, raw_entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
        """Resolve any slug collisions deterministically."""
        # Check initial slugs
        slug_counts: dict[str, int] = {}
        for entry in raw_entries:
            s = generate_slug(entry["name"])
            slug_counts[s] = slug_counts.get(s, 0) + 1

        resolved: list[dict[str, Any]] = []
        for entry in raw_entries:
            base_slug = generate_slug(entry["name"])
            if slug_counts[base_slug] > 1 and entry.get("location"):
                final_slug = generate_slug(entry["name"], entry["location"])
            else:
                final_slug = base_slug
            resolved.append({**entry, "id": final_slug})
        return resolved

    def _sort_volcanoes(self, volcanoes: list[VolcanoSummary]) -> list[VolcanoSummary]:
        """Sort by Level (IV -> III -> II -> I) and then alphabetically by name."""
        return sorted(
            volcanoes,
            key=lambda v: (LEVEL_SORT_ORDER.get(v.activity_level, 99), v.name.lower())
        )

    def _validate_and_build_summaries(
        self, raw_entries: list[dict[str, Any]], fetch_time: datetime
    ) -> list[VolcanoSummary]:
        """Validate raw scraper entries and convert to VolcanoSummary."""
        if not raw_entries:
            raise ValueError("Data sumber kosong (empty entries)")

        resolved_entries = self._normalize_and_resolve_slugs(raw_entries)
        summaries: list[VolcanoSummary] = []
        seen_ids = set()

        for entry in resolved_entries:
            raw_level = entry.get("activity_level")
            name = entry.get("name")
            volcano_id = entry.get("id")

            if not name or not raw_level or not volcano_id:
                logger.warning(f"Skipping malformed entry: {entry}")
                continue

            try:
                level_enum = ActivityLevel(raw_level)
            except ValueError:
                logger.warning(f"Unknown activity level '{raw_level}' for {name}, skipping")
                continue

            if volcano_id in seen_ids:
                logger.warning(f"Duplicate volcano ID '{volcano_id}', skipping")
                continue
            seen_ids.add(volcano_id)

            summaries.append(
                VolcanoSummary(
                    id=volcano_id,
                    name=name,
                    activity_level=level_enum,
                    level_label=LEVEL_LABELS[level_enum],
                    location=entry.get("location"),
                    source_url=entry.get("source_url"),
                    report_time=None,  # Explicitly not provided on list endpoint
                    fetched_at=fetch_time,
                )
            )

        if not summaries:
            raise ValueError("Tidak ada entri gunung yang valid setelah parsing")

        return self._sort_volcanoes(summaries)

    async def refresh_list(self, override_anomaly: bool = False) -> list[VolcanoSummary]:
        """Fetch fresh volcano list, validate, check anomaly, and update cache."""
        async with self._refresh_lock:
            now = datetime.now(timezone.utc)
            raw_entries = await self.adapter.fetch_volcano_list()
            new_summaries = self._validate_and_build_summaries(raw_entries, now)

            # Check > 20% count drop anomaly against existing cache (unless override_anomaly is True)
            existing_cache = await self.cache.get_list()
            if existing_cache and existing_cache.data and not override_anomaly:
                old_count = len(existing_cache.data)
                new_count = len(new_summaries)
                if old_count > 0:
                    drop_ratio = (old_count - new_count) / old_count
                    if drop_ratio > settings.count_drop_threshold_pct:
                        msg = (
                            f"Anomali penurunan jumlah data: turun {drop_ratio:.1%} "
                            f"(dari {old_count} ke {new_count} entri). "
                            "Cache valid sebelumnya dipertahankan untuk pemeriksaan."
                        )
                        logger.error(msg)
                        self._last_warning = msg
                        return existing_cache.data

            await self.cache.set_list(new_summaries)
            self._last_warning = None
            return new_summaries

    async def get_volcano_list(
        self,
        level_filter: ActivityLevel | None = None,
        search_query: str | None = None,
        force_refresh: bool = False,
        override_anomaly: bool = False,
    ) -> VolcanoListResponse:
        """Retrieve volcano list from cache or refresh if needed."""
        cached = await self.cache.get_list()
        should_refresh = (
            force_refresh
            or override_anomaly
            or cached is None
            or cached.is_stale(settings.list_refresh_interval_minutes)
        )

        volcanoes: list[VolcanoSummary] = []
        fetched_at = datetime.now(timezone.utc)
        is_stale = False

        if should_refresh:
            try:
                volcanoes = await self.refresh_list(override_anomaly=override_anomaly)
                cached = await self.cache.get_list()
                if cached:
                    fetched_at = cached.fetched_at
                    is_stale = cached.is_stale(settings.stale_threshold_minutes)
            except Exception as e:
                logger.error(f"Error refreshing volcano list: {e}")
                self._last_warning = f"Pembaruan data dari sumber gagal: {str(e)}"
                if cached and cached.data:
                    volcanoes = cached.data
                    fetched_at = cached.fetched_at
                    is_stale = True
                else:
                    raise RuntimeError("Data aktivitas gunung belum tersedia.") from e
        else:
            volcanoes = cached.data
            fetched_at = cached.fetched_at
            is_stale = cached.is_stale(settings.stale_threshold_minutes)

        # Compute counts by level across all volcanoes (all 4 levels must exist)
        by_level: dict[str, int] = {
            "IV": 0,
            "III": 0,
            "II": 0,
            "I": 0,
        }
        for v in volcanoes:
            by_level[v.activity_level.value] = by_level.get(v.activity_level.value, 0) + 1

        # Apply search and level filtering
        filtered = volcanoes
        if level_filter:
            filtered = [v for v in filtered if v.activity_level == level_filter]
        if search_query:
            query = search_query.strip().lower()
            filtered = [
                v for v in filtered
                if query in v.name.lower() or (v.location and query in v.location.lower())
            ]

        return VolcanoListResponse(
            volcanoes=filtered,
            total_count=len(filtered),
            by_level=by_level,
            fetched_at=fetched_at,
            is_stale=is_stale,
            last_successful_fetch=self.cache.last_successful_fetch,
            warning_message=self._last_warning,
        )

    async def get_volcano_detail(
        self,
        volcano_id: str,
        force_refresh: bool = False,
    ) -> VolcanoDetailResponse:
        """Fetch on-demand detail for a specific volcano using separate detail cache."""
        # First ensure we have the volcano in list cache to find its source_url
        list_resp = await self.get_volcano_list()
        match = next((v for v in list_resp.volcanoes if v.id == volcano_id), None)
        if not match:
            # Check full list in cache in case filtering was applied
            all_cached = await self.cache.get_list()
            if all_cached and all_cached.data:
                match = next((v for v in all_cached.data if v.id == volcano_id), None)

        if not match:
            raise KeyError(f"Gunung dengan ID '{volcano_id}' tidak ditemukan")

        cached_detail = await self.cache.get_detail(volcano_id)
        should_refresh = (
            force_refresh
            or cached_detail is None
            or cached_detail.is_stale(settings.detail_cache_ttl_minutes)
        )

        detail_data: VolcanoDetail
        is_stale = False
        fetched_at = datetime.now(timezone.utc)

        if should_refresh and match.source_url:
            try:
                raw_detail = await self.adapter.fetch_volcano_detail(match.source_url)
                if raw_detail:
                    now = datetime.now(timezone.utc)
                    report_period = raw_detail.get("report_period")
                    detail_data = VolcanoDetail(
                        id=match.id,
                        name=match.name,
                        activity_level=match.activity_level,
                        level_label=match.level_label,
                        location=match.location,
                        source_url=match.source_url,
                        report_period=report_period,
                        report_time_available=bool(report_period),
                        author=raw_detail.get("author"),
                        image_url=raw_detail.get("image_url"),
                        visual_observation=raw_detail.get("visual_observation"),
                        climatology=raw_detail.get("climatology"),
                        seismic_observation=raw_detail.get("seismic_observation"),
                        recommendation=raw_detail.get("recommendation"),
                        other_description=raw_detail.get("other_description"),
                        fetched_at=now,
                    )
                    await self.cache.set_detail(volcano_id, detail_data)
                    fetched_at = now
                elif cached_detail:
                    detail_data = cached_detail.data
                    fetched_at = cached_detail.fetched_at
                    is_stale = True
                else:
                    detail_data = self._build_basic_detail(match)
            except Exception as e:
                logger.error(f"Error fetching detail for {volcano_id}: {e}")
                if cached_detail:
                    detail_data = cached_detail.data
                    fetched_at = cached_detail.fetched_at
                    is_stale = True
                else:
                    detail_data = self._build_basic_detail(match)
        elif cached_detail:
            detail_data = cached_detail.data
            fetched_at = cached_detail.fetched_at
            is_stale = cached_detail.is_stale(settings.stale_threshold_minutes)
        else:
            detail_data = self._build_basic_detail(match)

        return VolcanoDetailResponse(
            volcano=detail_data,
            is_stale=is_stale,
            fetched_at=fetched_at,
        )

    def _build_basic_detail(self, summary: VolcanoSummary) -> VolcanoDetail:
        """Fallback basic detail from summary when detail scrape is unavailable."""
        return VolcanoDetail(
            id=summary.id,
            name=summary.name,
            activity_level=summary.activity_level,
            level_label=summary.level_label,
            location=summary.location,
            source_url=summary.source_url,
            report_period=None,
            report_time_available=False,
            author=None,
            image_url=None,
            visual_observation="Informasi detail laporan belum berhasil diambil dari sumber.",
            climatology=None,
            seismic_observation=None,
            recommendation="Ikuti arahan resmi dari PVMBG dan pihak berwenang setempat.",
            other_description=None,
            fetched_at=summary.fetched_at,
        )

volcano_service = VolcanoService()
