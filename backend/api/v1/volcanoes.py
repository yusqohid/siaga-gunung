import logging
from fastapi import APIRouter, HTTPException, Query
from models.volcano import ActivityLevel, VolcanoListResponse, VolcanoDetailResponse
from services.volcano_service import volcano_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/volcanoes", tags=["volcanoes"])

@router.get("", response_model=VolcanoListResponse)
async def list_volcanoes(
    level: ActivityLevel | None = Query(None, description="Filter berdasarkan status level: IV, III, II, I"),
    search: str | None = Query(None, description="Pencarian nama gunung atau lokasi"),
    force_refresh: bool = Query(False, description="Paksa pembaruan data dari sumber"),
    override_anomaly: bool = Query(False, description="Abaikan batasan anomali penurunan data >20%"),
):
    try:
        return await volcano_service.get_volcano_list(
            level_filter=level,
            search_query=search,
            force_refresh=force_refresh,
            override_anomaly=override_anomaly,
        )
    except RuntimeError as e:
        logger.warning(f"Layanan gunung tidak tersedia: {e}")
        raise HTTPException(
            status_code=503,
            detail="Layanan data aktivitas gunung saat ini tidak tersedia. Silakan coba beberapa saat lagi.",
        )
    except Exception as e:
        logger.error(f"Internal error pada list_volcanoes: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="Terjadi kesalahan internal pada server. Silakan coba beberapa saat lagi.",
        )

@router.get("/{volcano_id}", response_model=VolcanoDetailResponse)
async def get_volcano_detail(
    volcano_id: str,
    force_refresh: bool = Query(False, description="Paksa pembaruan data detail"),
):
    try:
        return await volcano_service.get_volcano_detail(
            volcano_id=volcano_id,
            force_refresh=force_refresh,
        )
    except KeyError:
        raise HTTPException(
            status_code=404,
            detail=f"Gunung dengan ID '{volcano_id}' tidak ditemukan",
        )
    except RuntimeError as e:
        logger.warning(f"Detail gunung {volcano_id} tidak tersedia: {e}")
        raise HTTPException(
            status_code=503,
            detail="Layanan data detail gunung saat ini tidak tersedia. Silakan coba beberapa saat lagi.",
        )
    except Exception as e:
        logger.error(f"Internal error pada get_volcano_detail ({volcano_id}): {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="Terjadi kesalahan internal pada server. Silakan coba beberapa saat lagi.",
        )
