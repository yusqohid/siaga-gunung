from fastapi import APIRouter
from config import settings
from models.volcano import HealthResponse
from services.volcano_service import volcano_service

router = APIRouter()

@router.get("/health", response_model=HealthResponse)
async def check_health():
    cached_list = await volcano_service.cache.get_list()
    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=settings.app_version,
        source_healthy=cached_list is not None,
        last_successful_fetch=volcano_service.cache.last_successful_fetch,
        cache_entry_count=volcano_service.cache.cached_volcano_count,
    )
