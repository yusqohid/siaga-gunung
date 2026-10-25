from fastapi import APIRouter
from .health import router as health_router
from .volcanoes import router as volcanoes_router

api_v1_router = APIRouter(prefix="/api/v1")
api_v1_router.include_router(health_router)
api_v1_router.include_router(volcanoes_router)
