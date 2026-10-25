import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from api.v1.router import api_v1_router
from services.volcano_service import volcano_service

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("siaga_gunung")

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("SiagaGunung backend starting up...")
    # Attempt initial background fetch if source is reachable
    try:
        await volcano_service.refresh_list()
        logger.info(f"Initial volcano data loaded: {volcano_service.cache.cached_volcano_count} entries")
    except Exception as e:
        logger.warning(f"Could not load initial data on startup: {e}")
    yield
    logger.info("SiagaGunung backend shutting down...")

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Backend API untuk SiagaGunung — Aplikasi Informasi Aktivitas & Edukasi Kesiapsiagaan Gunung Api",
    lifespan=lifespan,
)

# CORS middleware for Flutter Android & Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_v1_router)

@app.get("/", tags=["root"])
async def root():
    return {
        "app": settings.app_name,
        "version": settings.app_version,
        "status": "online",
        "docs": "/docs",
        "source": "MAGMA Indonesia / PVMBG",
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
