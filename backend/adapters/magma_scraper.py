import asyncio
import logging
import re
from typing import Any
import requests
from bs4 import BeautifulSoup

from config import settings
from scraper.Magma import magmalevelonly
from .base import BaseSourceAdapter

logger = logging.getLogger(__name__)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "id,en-US;q=0.9,en;q=0.8",
}

class MagmaScraperAdapter(BaseSourceAdapter):
    """Adapter wrapping PVMBG / MAGMA Indonesia web scraping with resilience."""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update(HEADERS)

    def _sync_get(self, url: str) -> requests.Response:
        """Execute HTTP GET with timeout."""
        return self.session.get(
            url,
            timeout=settings.source_timeout_seconds,
        )

    async def _execute_with_retry(self, url: str) -> requests.Response:
        """Run HTTP GET in a thread with bounded retries and exponential backoff."""
        last_exception = None
        for attempt in range(settings.max_retries + 1):
            try:
                loop = asyncio.get_running_loop()
                response = await loop.run_in_executor(None, self._sync_get, url)
                if response.status_code == 200:
                    return response
                logger.warning(
                    f"GET {url} returned HTTP {response.status_code} on attempt {attempt + 1}"
                )
            except Exception as e:
                last_exception = e
                logger.warning(
                    f"GET {url} error on attempt {attempt + 1}: {e}"
                )

            if attempt < settings.max_retries:
                backoff = settings.retry_backoff_seconds * (2 ** attempt)
                await asyncio.sleep(backoff)

        if last_exception:
            raise last_exception
        raise RuntimeError(f"Failed to fetch {url} after {settings.max_retries + 1} attempts")

    def _parse_level(self, level_header: str) -> str | None:
        """Map text like 'Level III (Siaga)' to 'III'."""
        text = level_header.upper()
        if "LEVEL IV" in text or "AWAS" in text:
            return "IV"
        if "LEVEL III" in text or "SIAGA" in text:
            return "III"
        if "LEVEL II" in text or "WASPADA" in text:
            return "II"
        if "LEVEL I" in text or "NORMAL" in text:
            return "I"
        return None

    async def fetch_volcano_list(self) -> list[dict[str, Any]]:
        """Scrape list of all volcanoes using vendored pinned Magma.py with fallback."""
        loop = asyncio.get_running_loop()
        try:
            # Pinned upstream scraper from Gabrielbjb/Magma-Indonesia-API
            raw_dict = await loop.run_in_executor(None, magmalevelonly)
            entries: list[dict[str, Any]] = []
            for level_header, volcanoes in raw_dict.items():
                parsed_level = self._parse_level(level_header)
                if not parsed_level:
                    continue
                for name, info in volcanoes.items():
                    link = info.get("link")
                    if link and link.startswith("/"):
                        link = f"{settings.magma_base_url}{link}"
                    entries.append({
                        "name": name,
                        "activity_level": parsed_level,
                        "location": info.get("location"),
                        "source_url": link,
                    })
            if entries:
                return entries
        except Exception as e:
            logger.warning(f"magmalevelonly error: {e}. Menggunakan fallback parser internal.")

        # Fallback parser if magmalevelonly encounters any network/session issue
        url = f"{settings.magma_base_url}/v1/gunung-api/tingkat-aktivitas"
        response = await self._execute_with_retry(url)
        soup = BeautifulSoup(response.text, "html.parser")

        table_divs = soup.find_all("div", class_="table-responsive")
        if not table_divs:
            logger.error("No table-responsive div found on MAGMA page")
            return []

        tbody = table_divs[0].find("tbody")
        if not tbody:
            logger.error("No tbody found in MAGMA table")
            return []

        entries: list[dict[str, Any]] = []
        current_level: str | None = None

        for tr in tbody.find_all("tr"):
            tds = tr.find_all("td")
            if not tds:
                continue

            for td in tds:
                # Check if this cell is a level header
                header_link = td.find("a", class_="tx-inverse")
                if header_link:
                    header_text = header_link.get_text(strip=True)
                    parsed_level = self._parse_level(header_text)
                    if parsed_level:
                        current_level = parsed_level
                    continue

                # Check if this cell is a volcano entry
                cell_text = td.get_text(strip=True)
                if not cell_text or cell_text.isnumeric():
                    continue

                if "Lihat laporan" in cell_text or " - " in cell_text:
                    cleaned_text = cell_text.replace("Lihat laporan", "").strip()
                    parts = cleaned_text.split(" - ")
                    volcano_name = parts[0].strip()
                    location = parts[1].strip() if len(parts) > 1 else None

                    # Extract report link
                    link_elem = td.find("a", href=True)
                    source_url = None
                    if link_elem:
                        href = link_elem["href"]
                        if href.startswith("/"):
                            source_url = f"{settings.magma_base_url}{href}"
                        else:
                            source_url = href

                    if volcano_name and current_level:
                        entries.append({
                            "name": volcano_name,
                            "activity_level": current_level,
                            "location": location,
                            "source_url": source_url,
                        })

        return entries

    async def fetch_volcano_detail(self, source_url: str) -> dict[str, Any] | None:
        """Fetch report detail on-demand from a specific report URL."""
        if not source_url:
            return None

        response = await self._execute_with_retry(source_url)
        soup = BeautifulSoup(response.text, "html.parser")

        # Container
        content_div = soup.find("div", class_="col-lg-12")
        if not content_div:
            content_div = soup

        # Title & Subtitle
        title_el = content_div.find("h5", class_="card-title")
        title_text = title_el.get_text(strip=True) if title_el else None

        subtitle_el = content_div.find("p", class_="card-subtitle")
        author = None
        if subtitle_el:
            sub_text = subtitle_el.get_text(strip=True)
            if "Dibuat oleh" in sub_text:
                parts = sub_text.split(",")
                author = parts[-1].strip() if len(parts) > 1 else sub_text.replace("Dibuat oleh", "").strip()
            else:
                author = sub_text

        # Extract period from title if present
        # e.g., "Merapi, Sabtu - 24 Oktober 2026, periode 00:00-24:00 WIB"
        report_period = None
        if title_text:
            if "periode" in title_text.lower():
                parts = title_text.split(",", 1)
                if len(parts) > 1:
                    report_period = parts[1].strip()
                else:
                    report_period = title_text
            else:
                report_period = title_text

        # Image
        img_el = content_div.find("img", class_="img-fluid")
        image_url = img_el["src"] if img_el and img_el.get("src") else None
        if image_url and image_url.startswith("/"):
            image_url = f"{settings.magma_base_url}{image_url}"

        # Sections in cards
        cards = content_div.find_all("div", class_="card")
        visual_obs = None
        climatology = None
        seismic_obs = None
        recommendation = None
        other_desc = None

        for card in cards:
            text = card.get_text(separator="\n", strip=True)
            lower_text = text.lower()
            if "pengamatan visual" in lower_text:
                visual_obs = text.replace("Pengamatan Visual", "").strip()
            elif "klimatologi" in lower_text:
                climatology = text.replace("Klimatologi", "").strip()
            elif "pengamatan kegempaan" in lower_text:
                seismic_obs = text.replace("Pengamatan Kegempaan", "").strip()
            elif "rekomendasi" in lower_text:
                recommendation = text.replace("Rekomendasi", "").strip()
            elif "keterangan lain" in lower_text or "lainnya" in lower_text:
                other_desc = text

        # Media body fallback for visual observation if not in cards
        if not visual_obs:
            media_body = content_div.find("div", class_="media-body")
            if media_body:
                p = media_body.find("p")
                if p:
                    visual_obs = p.get_text(strip=True)

        return {
            "title": title_text,
            "report_period": report_period,
            "author": author,
            "image_url": image_url,
            "visual_observation": visual_obs,
            "climatology": climatology,
            "seismic_observation": seismic_obs,
            "recommendation": recommendation,
            "other_description": other_desc,
        }
