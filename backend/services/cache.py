import asyncio
from datetime import datetime, timezone
from typing import Any, Generic, TypeVar

T = TypeVar("T")

class CachedItem(Generic[T]):
    def __init__(self, data: T, fetched_at: datetime | None = None):
        self.data: T = data
        self.fetched_at: datetime = fetched_at or datetime.now(timezone.utc)

    def is_stale(self, threshold_minutes: int) -> bool:
        now = datetime.now(timezone.utc)
        age_seconds = (now - self.fetched_at).total_seconds()
        return age_seconds > (threshold_minutes * 60)

    @property
    def age_seconds(self) -> int:
        now = datetime.now(timezone.utc)
        return int((now - self.fetched_at).total_seconds())

class CacheStore:
    def __init__(self):
        self._lock = asyncio.Lock()
        self._list_cache: CachedItem[Any] | None = None
        self._detail_cache: dict[str, CachedItem[Any]] = {}
        self._last_successful_fetch: datetime | None = None

    async def get_list(self) -> CachedItem[Any] | None:
        async with self._lock:
            return self._list_cache

    async def set_list(self, data: Any, fetched_at: datetime | None = None):
        async with self._lock:
            ts = fetched_at or datetime.now(timezone.utc)
            self._list_cache = CachedItem(data=data, fetched_at=ts)
            self._last_successful_fetch = ts

    async def get_detail(self, volcano_id: str) -> CachedItem[Any] | None:
        async with self._lock:
            return self._detail_cache.get(volcano_id)

    async def set_detail(self, volcano_id: str, data: Any):
        async with self._lock:
            self._detail_cache[volcano_id] = CachedItem(
                data=data, fetched_at=datetime.now(timezone.utc)
            )

    @property
    def last_successful_fetch(self) -> datetime | None:
        return self._last_successful_fetch

    @property
    def cached_volcano_count(self) -> int:
        if self._list_cache and isinstance(self._list_cache.data, list):
            return len(self._list_cache.data)
        return 0
