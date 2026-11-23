from fastapi import APIRouter
from config import settings
from models.volcano import HealthResponse
from services.volcano_service import volcano_service

router = APIRouter()

@router.get("/health", response_model=HealthResponse)
async def check_health():
    cached_list = await volcano_service.cache.get_list()
    last_fetch = volcano_service.cache.last_successful_fetch

    # source_healthy berarti data terakhir masih dalam ambang segar, bukan
    # sekadar ada cache. Cache basi menandakan sumber tidak berhasil diperbarui.
    source_healthy = (
        cached_list is not None
        and last_fetch is not None
        and not cached_list.is_stale(settings.stale_threshold_minutes)
    )

    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=settings.app_version,
        source_healthy=source_healthy,
        last_successful_fetch=last_fetch,
        cache_entry_count=volcano_service.cache.cached_volcano_count,
    )
