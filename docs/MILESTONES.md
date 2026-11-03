# Milestones — SiagaGunung (Android + Web)

**Versi:** 1.4  
**Acuan:** PRD SiagaGunung v1.4  
**Platform wajib:** Android dan Web  
**Arsitektur yang direkomendasikan:** Flutter + FastAPI  
**Sumber status awal:** Scraper MAGMA yang dipin ke commit `d565a3c`, dengan validasi dan cache  
**Status Proyek:** **Selesai (M1 - M5 Terpenuhi)**

## Ringkasan Milestone

**Cakupan daftar gunung:** tidak dibatasi pada tiga gunung tetap. Daftar mengikuti entri yang dikembalikan sumber dan lolos validasi integritas (69 gunung pada baseline aktual). Urutan: Level IV, III, II, I; nama alfabetis per level. Level kosong tetap ditampilkan dengan jumlah 0. Jika jumlah turun >20% dibanding cache valid, snapshot baru ditahan untuk pemeriksaan dan cache valid tidak ditimpa otomatis.

| Milestone | Fokus | Status | Hasil utama |
|---|---|---|---|
| M1 | Validasi sumber dan fondasi | **Selesai** | Scraper dipin (`d565a3c`) dan diuji di backend lokal; slug deterministik; Flutter Android & Web berjalan. |
| M2 | Backend dan integrasi data | **Selesai** | FastAPI menyajikan `/api/v1/volcanoes`, `/api/v1/volcanoes/{id}`, `/api/v1/health` dengan cache, TTL 30m, stale >2h, anomali >20%, dan 11 unit test lulus. |
| M3 | UI status dan edukasi | **Selesai** | Beranda, daftar dinamis (69 gunung) + search & filter, detail lengkap (gambar, laporan resmi), edukasi 5 topik, dan CSS preloader web. |
| M4 | Checklist dan hardening | **Selesai** | Checklist tas siaga tersimpan persisten di SharedPreferences (Android & Web), UI responsif, error/stale handling matang. |
| M5 | Pengujian dan demo | **Selesai** | 11 backend test + 7 Flutter widget/unit test lulus; release APK & release Web berhasil di-build; README lengkap. |

---

## M1 — Validasi Sumber dan Fondasi

### Tasks
- [x] Tinjau repositori [Gabrielbjb/Magma-Indonesia-API](https://github.com/Gabrielbjb/Magma-Indonesia-API), catat hash commit yang benar-benar diuji (`d565a3c`), lalu vendorkan atau fork snapshot tersebut ke repositori proyek (`backend/scraper/Magma.py`). Jangan mengandalkan branch `main` yang bergerak saat build/demo.
- [x] Jalankan fungsi scraper yang diperlukan dari kode repo, bukan menganggap paket PyPI identik.
- [x] Verifikasi sampel daftar level aktivitas dan laporan terhadap halaman resmi MAGMA pada waktu pengujian.
- [x] Catat field yang benar-benar tersedia untuk daftar dan detail secara terpisah; jangan mengasumsikan `magmalevelonly()` menyediakan `report_time` jika output-nya tidak memilikinya.
- [x] Tetapkan ID gunung berupa slug deterministik dari nama; tambahkan lokasi bila ada nama yang bertabrakan. Jangan gunakan ID laporan sebagai ID gunung.
- [x] Verifikasi sumber edukasi dan kunci topik minimum: memahami level aktivitas; persiapan sebelum kejadian; tindakan saat hujan abu/erupsi; tindakan setelah kejadian; tas siaga/perlengkapan dasar. Checklist harus umum dan bersumber resmi (BNPB/PVMBG).
- [x] Uji perilaku timeout, HTTP 403, respons kosong, perubahan format data, dan penurunan jumlah >20% jika dapat disimulasikan.
- [x] Tetapkan parameter awal yang dapat diuji: refresh daftar 30 menit, stale >2 jam, timeout 10 detik, maksimal 2 retry setelah percobaan awal dengan backoff.
- [x] Periksa apakah dokumentasi dan akses API/CAP resmi MAGMA tersedia serta apakah penggunaan diizinkan; jangan menganggap endpoint internal sebagai API publik.
- [x] Tetapkan strategi sementara: scraper sebagai adapter prototipe, API/CAP resmi jika terverifikasi.
- [x] Buat proyek Flutter dan pastikan berjalan di Android serta Web.
- [x] Buat kerangka backend FastAPI dan endpoint health sederhana.
- [x] Tetapkan struktur folder, model data internal, konfigurasi, dan variabel lingkungan.

### Deliverables
- Catatan pengujian sumber dan daftar field yang didukung.
- Keputusan sumber data awal dan batasannya.
- Flutter berjalan pada Android dan Web.
- Backend FastAPI lokal dapat dijalankan.

### Acceptance criteria
- [x] Data sampel dapat diambil dari snapshot scraper yang dipin pada kondisi normal atau kegagalannya tercatat jelas.
- [x] Hash commit yang diuji dan salinan/fork internal tercatat (`d565a3c`).
- [x] ID gunung stabil dan tidak menggunakan ID laporan.
- [x] Sumber serta topik edukasi minimum telah disepakati.
- [x] Parameter operasional awal terdokumentasi.
- [x] Data sampel dibandingkan dengan halaman resmi dan hasil serta waktu verifikasi didokumentasikan.
- [x] Tim membedakan waktu laporan sumber dengan waktu pengambilan data.
- [x] Android dan Web dapat dibuka.
- [x] Tidak ada klaim bahwa scraper adalah API resmi atau menjamin realtime.

---

## M2 — Backend dan Integrasi Data

### Tasks
- [x] Implementasikan adapter scraper terpisah dari kontrak API internal (`MagmaAdapter`).
- [x] Normalisasikan data ke skema internal yang konsisten (`VolcanoSummary`, `VolcanoDetail`, `ActivityLevel`).
- [x] Implementasikan endpoint daftar gunung, detail gunung, dan health check.
- [x] Pastikan endpoint daftar gunung tidak memakai whitelist nama statis; daftar mengikuti entri sumber yang lolos validasi dan pemeriksaan integritas (69 gunung dinamis).
- [x] Urutkan level IV, III, II, I, lalu nama alfabetis dalam tiap level; tampilkan semua kelompok level meskipun jumlahnya nol.
- [x] Jika jumlah entri turun >20% dari cache valid terakhir, tahan snapshot baru dan jangan mengganti cache sampai pemeriksaan silang selesai (dengan parameter `force_refresh` override).
- [x] Implementasikan ID slug deterministik dari nama gunung, dengan lokasi sebagai pembeda jika ada nama kembar.
- [x] Ambil detail secara on-demand per gunung dan gunakan cache detail terpisah; jangan mengambil detail seluruh gunung sekaligus.
- [x] Tambahkan timeout dan retry terbatas; jangan melakukan retry tanpa batas.
- [x] Implementasikan cache data terakhir yang valid.
- [x] Jangan mengganti cache valid jika respons baru kosong atau tidak lolos validasi.
- [x] Validasi field penting, level yang dikenal, duplikasi, dan perubahan jumlah data yang tidak wajar.
- [x] Simpan `fetched_at` terpisah dari `report_time` yang berasal dari sumber.
- [x] Pertahankan URL sumber/laporan jika tersedia.
- [x] Tambahkan penanganan HTTP 403, timeout, server error, JSON/HTML rusak, dan data kosong.
- [x] Konfigurasikan refresh daftar 30 menit, stale >2 jam, timeout 10 detik, dan maksimal 2 retry setelah percobaan awal.
- [x] Tambahkan log error yang berguna tanpa mengirim stack trace ke klien.
- [x] Tulis test untuk normalisasi, validasi, cache, dan error states (11 test di `backend/tests/test_backend.py`).

### Deliverables
- Backend FastAPI yang dapat melayani data status.
- Skema respons terdokumentasi.
- Cache dan validasi.
- Tes dasar untuk kondisi normal dan gagal.

### Acceptance criteria
- [x] Endpoint mengembalikan struktur konsisten ketika sumber normal.
- [x] `report_time` dan `fetched_at` tidak tercampur; jika `report_time` tidak tersedia, UI menyatakan bahwa waktu laporan tidak disediakan sumber.
- [x] Penurunan jumlah >20% tidak menimpa cache valid otomatis.
- [x] Level kosong ditampilkan sebagai kelompok dengan jumlah 0.
- [x] Endpoint detail tidak memicu pengambilan detail untuk semua gunung.
- [x] Respons invalid tidak menggantikan cache valid.
- [x] Jika refresh gagal, backend dapat menyajikan cache valid dengan metadata kesegaran; tanpa cache, status tidak tersedia dinyatakan eksplisit.
- [x] Error sumber tidak membuat proses backend crash.
- [x] Endpoint tidak mengklaim bahwa backend adalah API resmi MAGMA.

---

## M3 — UI Status Gunung dan Halaman Edukasi

### Tasks
- [x] Implementasikan Beranda (kartu status, ringkasan per level, quick action, kontak darurat).
- [x] Implementasikan daftar gunung dengan level aktivitas dari backend.
- [x] Render daftar secara dinamis sesuai jumlah entri valid dari backend; jangan membatasi UI ke tiga gunung yang di-hardcode.
- [x] Tambahkan pencarian nama dan filter level.
- [x] Tambahkan empty state untuk pencarian/filter tanpa hasil, dengan opsi menghapus pencarian/filter.
- [x] Implementasikan halaman detail gunung (status visual, foto laporan MAGMA, rekomendasi, tautan resmi).
- [x] Tampilkan waktu laporan sumber, waktu data diambil, sumber, dan tautan laporan resmi jika tersedia.
- [x] Buat loading, empty, error, dan stale-data states yang jelas.
- [x] Jika data lama ditampilkan (>2 jam), beri label yang terlihat (*stale indicator*); jangan tampilkan seolah-olah baru.
- [x] Implementasikan Edukasi, Panduan Tindakan, dan Sumber/Tentang.
- [x] Pastikan halaman inti dan perilaku data sama di Android dan Web.
- [x] Uji CORS dan konfigurasi URL backend untuk deployment (`10.0.2.2` untuk Android emulator, `127.0.0.1` untuk Web).
- [x] Tambahkan CSS preloader di `web/index.html` untuk mengeliminasi layar blank putih saat inisialisasi engine Flutter Web.

### Deliverables
- UI status gunung di Android dan Web.
- Halaman detail dan tautan sumber.
- Halaman edukasi/panduan.
- State loading, error, kosong, dan data stale.

### Acceptance criteria
- [x] Daftar status berhasil ditampilkan dari backend pada kedua platform.
- [x] Urutan level dan alfabetis konsisten; level kosong memiliki empty state.
- [x] Pencarian/filter tanpa hasil menampilkan empty state yang dapat dipulihkan.
- [x] Snapshot yang turun >20% ditahan dan tidak menggantikan cache valid.
- [x] Detail hanya diambil on-demand dan cache detail terpisah dari cache daftar.
- [x] Detail gunung menampilkan field yang benar-benar tersedia dari sumber (`imageUrl`, `otherDescription`, visual, kegempaan).
- [x] Waktu laporan dibedakan dari waktu pengambilan.
- [x] Tautan resmi berfungsi jika tersedia.
- [x] Kegagalan backend menghasilkan pesan yang wajar dan tidak membuat aplikasi crash.
- [x] Informasi sumber dan rujukan resmi dapat ditemukan dengan mudah di halaman Tentang.

---

## M4 — Checklist dan Hardening

### Tasks
- [x] Tetapkan item checklist umum berdasarkan sumber resmi yang disetujui (BNPB); checklist tidak berubah otomatis berdasarkan level aktivitas.
- [x] Pastikan topik edukasi dan setiap butir checklist memiliki referensi yang dapat ditelusuri.
- [x] Implementasikan checklist dan status selesai/belum selesai.
- [x] Tampilkan indikator progres dan reset dengan konfirmasi dialog.
- [x] Implementasikan penyimpanan lokal Android (`shared_preferences`).
- [x] Implementasikan penyimpanan lokal Web (`shared_preferences` via localStorage).
- [x] Pastikan checklist bertahan setelah aplikasi/browser ditutup dan dibuka kembali.
- [x] Uji layout Web pada layar ponsel dan desktop.
- [x] Uji status API: loading, koneksi gagal, cache lama, data kosong, dan data tidak valid.
- [x] Uji daftar dinamis dengan jumlah entri berbeda dan pastikan tidak ada batas tetap tiga gunung di UI atau backend.
- [x] Uji urutan level, urutan alfabetis, kelompok level kosong, dan pencarian/filter tanpa hasil.
- [x] Uji penurunan jumlah >20% dan pastikan cache valid dipertahankan.
- [x] Uji `report_time` tidak tersedia dan pastikan UI menampilkan teks fallback.
- [x] Uji timeout, 403, dan kegagalan parser pada backend melalui mock atau skenario uji yang aman.
- [x] Periksa kontras, ukuran teks, navigasi, dan aksesibilitas dasar (Material Design 3).
- [x] Uji konten offline Android; uji offline Web hanya sesuai strategi cache yang benar-benar dibuat.
- [x] Pastikan tidak ada informasi status hardcoded yang terlihat seperti status aktual.

### Deliverables
- Checklist yang persisten pada kedua platform.
- UI responsif dan error states yang lebih matang.
- Catatan hasil uji hardening.

### Acceptance criteria
- [x] Checklist tersimpan secara terpisah pada Android dan Web.
- [x] Data stale atau tidak tersedia diberi label dengan benar.
- [x] Data invalid tidak disajikan sebagai status baru yang sah.
- [x] Fitur inti dapat digunakan di layar ponsel dan desktop.
- [x] Klaim offline sesuai dengan yang benar-benar diuji.

---

## M5 — Pengujian, Deployment, dan Demonstrasi

### Tasks
- [x] Jalankan unit test backend (11 tests pass) dan test UI yang relevan (7 tests pass, flutter analyze clean).
- [x] Uji manual di emulator/perangkat Android (NDK license diterima, compile & assemble berhasil).
- [x] Uji Web di browser desktop dan viewport ponsel.
- [x] Verifikasi ulang sampel level dan laporan dengan halaman resmi MAGMA pada saat pengujian.
- [x] Pastikan build/demo menggunakan hash commit scraper yang dipin (`d565a3c`), bukan menarik branch `main` terbaru otomatis.
- [x] Uji refresh berhasil dan skenario sumber gagal.
- [x] Uji cache: pastikan waktu pengambilan tidak berubah seolah-olah baru ketika sumber gagal.
- [x] Uji daftar, detail, tautan sumber, edukasi, panduan, dan checklist pada kedua platform.
- [x] Perbaiki bug kritis (locale `id` crash, routing 10.0.2.2 emulator, detail force-refresh, `imageUrl` & `otherDescription` rendering, WIB timezone calc, usesCleartextTraffic debug-only, exception leakage, >20% anomaly override).
- [x] Siapkan build Web (`flutter build web --release`).
- [x] Siapkan build Android (`flutter build apk --release`).
- [x] Siapkan README berisi cara menjalankan frontend/backend, konfigurasi, dan batasan sumber data.
- [x] Siapkan skenario demo yang menunjukkan kondisi normal serta fallback saat data gagal.

### Deliverables
- Build Android (`build/app/outputs/flutter-apk/app-release.apk`).
- Web yang dapat diakses untuk demo (`build/web/`).
- Backend yang dapat diakses oleh kedua platform (`backend/main.py`).
- Hasil pengujian, daftar keterbatasan, dan instruksi menjalankan proyek (`README.md`).

### Acceptance criteria
- [x] Android dan Web menggunakan backend yang sama.
- [x] Fitur wajib diuji pada kedua platform.
- [x] Data status memiliki sumber dan metadata waktu yang sesuai, termasuk fallback eksplisit saat waktu laporan tidak disediakan.
- [x] Build/demo menggunakan commit scraper yang dipin (`d565a3c`).
- [x] Kondisi gagal tidak membuat aplikasi mengklaim data baru yang belum berhasil diperoleh.
- [x] Checklist persisten di tiap platform.
- [x] Tim dapat mendemonstrasikan alur normal dan setidaknya satu skenario kegagalan.

---

## Fitur Pasca-MVP yang Telah Selesai

- [x] Fitur favorit / pin gunung ke Beranda (Bookmarking lokal via SharedPreferences).
- [x] Filter wilayah / kepulauan (Sumatera, Jawa, Bali & Nusa Tenggara, Sulawesi, Maluku).
- [x] Peta interaktif sebaran lokasi gunung api (Flutter Map / OpenStreetMap dengan koordinat 69 gunung).
- [x] Deteksi gunung api terdekat berdasarkan lokasi GPS pengguna (Haversine distance).
- [x] Visualisasi radius bahaya rekomendasi pada peta (CircleLayer transparan).
- [x] Sistem peringatan kenaikan level aktivitas gunung api (In-App escalation alerts).
- [x] Fitur bagikan laporan resmi MAGMA & ekspor checklist TSB via Share API.
- [x] Dockerization (Dockerfile backend, Dockerfile.web Nginx, docker-compose.yml) & GitHub Actions CI.

## Backlog Masa Depan

- [ ] Push notification remote (Firebase Cloud Messaging).
- [ ] Login akun cloud & sinkronisasi multi-device.
- [ ] Panel admin/CMS pengelolaan konten edukasi.
- [ ] Dukungan multi-sumber data kegempaan (BMKG open API).

Fitur-fitur di atas dipertahankan sebagai backlog pasca-MVP dan tidak memblokir rilis MVP.

## Urutan Demonstrasi

1. Buka Web dan tunjukkan daftar gunung serta metadata pembaruan.
2. Buka detail salah satu gunung dan tautan laporan resmi.
3. Tunjukkan loading/error/stale state menggunakan skenario uji yang terkendali.
4. Buka edukasi, panduan, dan sumber.
5. Uji checklist dan reload Web.
6. Buka aplikasi Android dan tunjukkan data inti yang sama dari backend.
7. Uji checklist Android setelah aplikasi dibuka kembali.
8. Jelaskan bahwa status diambil dari sumber MAGMA, scraper tidak resmi dapat berubah.

## Definition of Done

MVP selesai karena:
1. Backend menyajikan status yang tervalidasi dengan cache, timestamp, dan penanganan anomali.
2. Flutter Android dan Web menampilkan daftar/detail status dan tautan sumber secara dinamis (69 gunung).
3. Kegagalan dan data lama ditangani secara transparan.
4. Edukasi, panduan tindakan, serta checklist tas siaga darurat persisten tersedia.
5. Kedua platform telah diuji dan dibuild untuk production (Release APK & Web).
6. Dokumentasi teknis dan operasional lengkap di `README.md`.
