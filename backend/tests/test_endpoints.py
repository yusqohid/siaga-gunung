import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from main import app
from services.volcano_service import volcano_service
from models.volcano import ActivityLevel, VolcanoSummary
from datetime import datetime, timezone

@pytest_asyncio.fixture(autouse=True)
async def setup_test_cache():
    now = datetime.now(timezone.utc)
    test_volcanoes = [
        VolcanoSummary(id="merapi", name="Merapi", activity_level=ActivityLevel.LEVEL_III, level_label="Siaga", location="DIY", source_url="http://magma.test/merapi", fetched_at=now),
        VolcanoSummary(id="anak-krakatau", name="Anak Krakatau", activity_level=ActivityLevel.LEVEL_III, level_label="Siaga", location="Lampung", source_url="http://magma.test/krakatau", fetched_at=now),
        VolcanoSummary(id="sinabung", name="Sinabung", activity_level=ActivityLevel.LEVEL_II, level_label="Waspada", location="Sumut", source_url="http://magma.test/sinabung", fetched_at=now),
        VolcanoSummary(id="agung", name="Agung", activity_level=ActivityLevel.LEVEL_I, level_label="Normal", location="Bali", source_url="http://magma.test/agung", fetched_at=now),
    ]
    await volcano_service.cache.set_list(test_volcanoes)

@pytest.mark.asyncio
async def test_health_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "ok"
        assert data["source_healthy"] is True
        assert data["cache_entry_count"] == 4

@pytest.mark.asyncio
async def test_list_volcanoes_all():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/volcanoes")
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_count"] == 4
        # All 4 levels must exist in by_level, even if count is 0
        assert "IV" in data["by_level"]
        assert data["by_level"]["IV"] == 0
        assert data["by_level"]["III"] == 2
        assert data["by_level"]["II"] == 1
        assert data["by_level"]["I"] == 1

@pytest.mark.asyncio
async def test_list_volcanoes_filter_level():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/volcanoes?level=III")
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_count"] == 2
        for v in data["volcanoes"]:
            assert v["activity_level"] == "III"

@pytest.mark.asyncio
async def test_list_volcanoes_search():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/volcanoes?search=merapi")
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_count"] == 1
        assert data["volcanoes"][0]["name"] == "Merapi"

@pytest.mark.asyncio
async def test_get_volcano_detail_not_found():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/volcanoes/non-existent-volcano")
        assert resp.status_code == 404
        assert "tidak ditemukan" in resp.json()["detail"]

@pytest.mark.asyncio
async def test_list_volcanoes_override_anomaly_param():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get("/api/v1/volcanoes?override_anomaly=true")
        assert resp.status_code == 200
