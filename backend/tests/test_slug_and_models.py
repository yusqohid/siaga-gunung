from models.volcano import ActivityLevel, LEVEL_SORT_ORDER, VolcanoSummary
from services.volcano_service import generate_slug, VolcanoService
from datetime import datetime, timezone

def test_slug_generation():
    assert generate_slug("Gunung Merapi") == "gunung-merapi"
    assert generate_slug("Anak Krakatau") == "anak-krakatau"
    assert generate_slug("Ibu", "Halmahera Barat") == "ibu-halmahera-barat"
    # Special characters removed
    assert generate_slug("Gunung Lewotobi Laki-laki") == "gunung-lewotobi-laki-laki"

def test_slug_collision_resolution():
    service = VolcanoService()
    raw = [
        {"name": "Merapi", "activity_level": "III", "location": "Yogyakarta", "source_url": "url1"},
        {"name": "Merapi", "activity_level": "I", "location": "Sumatera Barat", "source_url": "url2"},
        {"name": "Semeru", "activity_level": "III", "location": "Jawa Timur", "source_url": "url3"},
    ]
    resolved = service._normalize_and_resolve_slugs(raw)
    slugs = [r["id"] for r in resolved]
    assert len(slugs) == 3
    assert len(set(slugs)) == 3  # All distinct
    assert "merapi-yogyakarta" in slugs
    assert "merapi-sumatera-barat" in slugs
    assert "semeru" in slugs

def test_volcano_sorting_order():
    service = VolcanoService()
    now = datetime.now(timezone.utc)
    volcanoes = [
        VolcanoSummary(id="1", name="Sinabung", activity_level=ActivityLevel.LEVEL_II, level_label="Waspada", fetched_at=now),
        VolcanoSummary(id="2", name="Semeru", activity_level=ActivityLevel.LEVEL_III, level_label="Siaga", fetched_at=now),
        VolcanoSummary(id="3", name="Anak Krakatau", activity_level=ActivityLevel.LEVEL_III, level_label="Siaga", fetched_at=now),
        VolcanoSummary(id="4", name="Agung", activity_level=ActivityLevel.LEVEL_I, level_label="Normal", fetched_at=now),
        VolcanoSummary(id="5", name="Awas Sample", activity_level=ActivityLevel.LEVEL_IV, level_label="Awas", fetched_at=now),
    ]
    sorted_v = service._sort_volcanoes(volcanoes)
    
    # Expected order: Level IV first, then Level III (Anak Krakatau then Semeru), Level II, Level I
    assert sorted_v[0].name == "Awas Sample"
    assert sorted_v[1].name == "Anak Krakatau"
    assert sorted_v[2].name == "Semeru"
    assert sorted_v[3].name == "Sinabung"
    assert sorted_v[4].name == "Agung"
