from abc import ABC, abstractmethod
from typing import Any

class BaseSourceAdapter(ABC):
    @abstractmethod
    async def fetch_volcano_list(self) -> list[dict[str, Any]]:
        """Fetch raw list of active volcanoes and their alert levels."""
        pass

    @abstractmethod
    async def fetch_volcano_detail(self, source_url: str) -> dict[str, Any] | None:
        """Fetch on-demand detail report for a single volcano."""
        pass
