import pytest
from adapters import magma_scraper


@pytest.mark.asyncio
async def test_fetch_volcano_list_passes_timeout_to_pinned_scraper(monkeypatch):
    """magmalevelonly harus dipanggil dengan timeout agar tidak menggantung."""
    captured = {}

    def fake_magmalevelonly(timeout=None):
        captured["timeout"] = timeout
        return {"Level II (Waspada)": {"Merapi": {"location": "DIY", "link": "/x"}}}

    monkeypatch.setattr(magma_scraper, "magmalevelonly", fake_magmalevelonly)

    adapter = magma_scraper.MagmaScraperAdapter()
    entries = await adapter.fetch_volcano_list()

    assert captured["timeout"] is not None
    assert entries and entries[0]["name"] == "Merapi"
