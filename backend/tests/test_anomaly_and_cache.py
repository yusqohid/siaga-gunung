import pytest
from datetime import datetime, timezone, timedelta
from services.volcano_service import VolcanoService
from adapters.base import BaseSourceAdapter
from models.volcano import ActivityLevel, VolcanoSummary

class MockAdapter(BaseSourceAdapter):
    def __init__(self, raw_data):
        self.raw_data = raw_data

    async def fetch_volcano_list(self):
        return self.raw_data

    async def fetch_volcano_detail(self, source_url: str):
        return {
            "title": "Merapi, 24 Oktober 2026",
            "report_period": "periode 00:00-24:00 WIB",
            "author": "Penyelidik Bumi",
            "image_url": "https://example.com/photo.jpg",
            "visual_observation": "Asap putih kawah tinggi 400m",
            "climatology": "Cerah",
            "seismic_observation": "12 kali gempa",
            "recommendation": "Jauhi radius 5km",
            "other_description": "Normal",
        }

@pytest.mark.asyncio
async def test_drop_anomaly_protection():
    """Verify that a drop > 20% does NOT overwrite valid existing cache."""
    # Step 1: Initial load with 10 volcanoes
    initial_data = [
        {"name": f"Gunung {i}", "activity_level": "II", "location": "Indonesia", "source_url": f"http://{i}"}
        for i in range(10)
    ]
    mock_adapter = MockAdapter(initial_data)
    service = VolcanoService(adapter=mock_adapter)

    initial_list = await service.refresh_list()
    assert len(initial_list) == 10

    # Step 2: Source suddenly drops from 10 to 7 (30% drop, > 20% threshold)
    anomaly_data = [
        {"name": f"Gunung {i}", "activity_level": "II", "location": "Indonesia", "source_url": f"http://{i}"}
        for i in range(7)
    ]
    mock_adapter.raw_data = anomaly_data

    # Refresh should reject the drop and keep the 10 entries
    result_list = await service.refresh_list()
    assert len(result_list) == 10
    assert service._last_warning is not None
    assert "Anomali penurunan jumlah data" in service._last_warning

    # Step 3: Refresh with override_anomaly=True should accept the new data
    override_list = await service.refresh_list(override_anomaly=True)
    assert len(override_list) == 7
    assert service._last_warning is None

@pytest.mark.asyncio
async def test_cache_staleness():
    service = VolcanoService()
    now = datetime.now(timezone.utc)
    old_time = now - timedelta(hours=3)  # 3 hours ago (> 2 hours threshold)

    await service.cache.set_list(
        [
            VolcanoSummary(
                id="merapi",
                name="Merapi",
                activity_level=ActivityLevel.LEVEL_III,
                level_label="Siaga",
                fetched_at=old_time,
            )
        ],
        fetched_at=old_time,
    )
    cached = await service.cache.get_list()
    assert cached is not None
    assert cached.is_stale(120) is True  # > 120 minutes is stale
