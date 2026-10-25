# Milestones — SiagaGunung (Android + Web)

**Versi:** 1.4  
**Acuan:** PRD SiagaGunung v1.4  
**Platform wajib:** Android dan Web  
**Arsitektur yang direkomendasikan:** Flutter + FastAPI  
**Sumber status awal:** scraper MAGMA tidak resmi yang dipin ke commit tertentu, dengan validasi dan cache

## Ringkasan Milestone

**Cakupan daftar gunung:** tidak dibatasi pada tiga gunung tetap. Daftar mengikuti entri yang dikembalikan sumber dan lolos validasi integritas. Urutan: Level IV, III, II, I; nama alfabetis per level. Level kosong tetap ditampilkan dengan jumlah 0. Jika jumlah turun >20% dibanding cache valid, snapshot baru ditahan untuk pemeriksaan dan cache valid tidak ditimpa otomatis.

| Milestone | Fokus | Hasil utama |
|---|---|---|
| M1 | Validasi sumber dan fondasi | Scraper diuji dari backend lokal; keputusan API/CAP dan arsitektur dicatat; Android/Web berjalan. |
| M2 | Backend dan integrasi data | FastAPI menyajikan data status tervalidasi dengan cache, timestamp, dan error handling. |
| M3 | UI status dan edukasi | Daftar/detail gunung dan halaman edukasi berjalan di Android dan Web. |
| M4 | Checklist dan hardening | Checklist lokal, responsivitas, validasi, serta kondisi gagal diuji. |
| M5 | Pengujian dan demo | Hasil verifikasi sumber, build Android, deployment Web, dan dokumentasi siap. |

---

## M1 — Validasi Sumber dan Fondasi

### Tasks
- [ ] Tinjau repositori [Gabrielbjb/Magma-Indonesia-API](https://github.com/Gabrielbjb/Magma-Indonesia-API), catat hash commit yang benar-benar diuji, lalu vendorkan atau fork snapshot tersebut ke repositori proyek. Jangan mengandalkan branch `main` yang bergerak saat build/demo.
- [ ] Jalankan fungsi scraper yang diperlukan dari kode repo, bukan menganggap paket PyPI identik.
- [ ] Verifikasi sampel daftar level aktivitas dan laporan terhadap halaman resmi MAGMA pada waktu pengujian.
- [ ] Catat field yang benar-benar tersedia untuk daftar dan detail secara terpisah; jangan mengasumsikan `magmalevelonly()` menyediakan `report_time` jika output-nya tidak memilikinya.
- [ ] Tetapkan ID gunung berupa slug deterministik dari nama; tambahkan lokasi bila ada nama yang bertabrakan. Jangan gunakan ID laporan sebagai ID gunung.
- [ ] Verifikasi sumber edukasi dan kunci topik minimum: memahami level aktivitas; persiapan sebelum kejadian; tindakan saat hujan abu/erupsi; tindakan setelah kejadian; tas siaga/perlengkapan dasar. Checklist harus umum dan bersumber resmi.
- [ ] Uji perilaku timeout, HTTP 403, respons kosong, perubahan format data, dan penurunan jumlah >20% jika dapat disimulasikan.
- [ ] Tetapkan parameter awal yang dapat diuji: refresh daftar 30 menit, stale >2 jam, timeout 10 detik, maksimal 2 retry setelah percobaan awal dengan backoff.
- [ ] Periksa apakah dokumentasi dan akses API/CAP resmi MAGMA tersedia serta apakah penggunaan diizinkan; jangan menganggap endpoint internal sebagai API publik.
- [ ] Tetapkan strategi sementara: scraper sebagai adapter prototipe, API/CAP resmi jika terverifikasi.
- [ ] Buat proyek Flutter dan pastikan berjalan di Android serta Web.
- [ ] Buat kerangka backend FastAPI dan endpoint health sederhana.
- [ ] Tetapkan struktur folder, model data internal, konfigurasi, dan variabel lingkungan.

### Deliverables
- Catatan pengujian sumber dan daftar field yang didukung.
- Keputusan sumber data awal dan batasannya.
- Flutter berjalan pada Android dan Web.
- Backend FastAPI lokal dapat dijalankan.

### Acceptance criteria
- [ ] Data sampel dapat diambil dari snapshot scraper yang dipin pada kondisi normal atau kegagalannya tercatat jelas.
- [ ] Hash commit yang diuji dan salinan/fork internal tercatat.
- [ ] ID gunung stabil dan tidak menggunakan ID laporan.
- [ ] Sumber serta topik edukasi minimum telah disepakati.
- [ ] Parameter operasional awal terdokumentasi.
- [ ] Data sampel dibandingkan dengan halaman resmi dan hasil serta waktu verifikasi didokumentasikan.
- [ ] Tim membedakan waktu laporan sumber dengan waktu pengambilan data.
- [ ] Android dan Web dapat dibuka.
- [ ] Tidak ada klaim bahwa scraper adalah API resmi atau menjamin realtime.

---

## M2 — Backend dan Integrasi Data

### Tasks
- [ ] Implementasikan adapter scraper terpisah dari kontrak API internal.
- [ ] Normalisasikan data ke skema internal yang konsisten.
- [ ] Implementasikan endpoint daftar gunung, detail gunung, dan health check.
- [ ] Pastikan endpoint daftar gunung tidak memakai whitelist nama statis; daftar mengikuti entri sumber yang lolos validasi dan pemeriksaan integritas.
- [ ] Urutkan level IV, III, II, I, lalu nama alfabetis dalam tiap level; tampilkan semua kelompok level meskipun jumlahnya nol.
- [ ] Jika jumlah entri turun >20% dari cache valid terakhir, tahan snapshot baru dan jangan mengganti cache sampai pemeriksaan silang selesai.
- [ ] Implementasikan ID slug deterministik dari nama gunung, dengan lokasi sebagai pembeda jika ada nama kembar.
- [ ] Ambil detail secara on-demand per gunung dan gunakan cache detail terpisah; jangan mengambil detail seluruh gunung sekaligus.
- [ ] Tambahkan timeout dan retry terbatas; jangan melakukan retry tanpa batas.
- [ ] Implementasikan cache data terakhir yang valid.
- [ ] Jangan mengganti cache valid jika respons baru kosong atau tidak lolos validasi.
- [ ] Validasi field penting, level yang dikenal, duplikasi, dan perubahan jumlah data yang tidak wajar.
- [ ] Simpan `fetched_at` terpisah dari `report_time` yang berasal dari sumber.
- [ ] Pertahankan URL sumber/laporan jika tersedia.
- [ ] Tambahkan penanganan HTTP 403, timeout, server error, JSON/HTML rusak, dan data kosong.
- [ ] Konfigurasikan refresh daftar 30 menit, stale >2 jam, timeout 10 detik, dan maksimal 2 retry setelah percobaan awal; nilai dapat direvisi setelah M1, tetapi harus tetap terdokumentasi dan dapat diuji.
- [ ] Tambahkan log error yang berguna tanpa mengirim stack trace ke klien.
- [ ] Tulis test untuk normalisasi, validasi, cache, dan error states.

### Deliverables
- Backend FastAPI yang dapat melayani data status.
- Skema respons terdokumentasi.
- Cache dan validasi.
- Tes dasar untuk kondisi normal dan gagal.

### Acceptance criteria
- [ ] Endpoint mengembalikan struktur konsisten ketika sumber normal.
- [ ] `report_time` dan `fetched_at` tidak tercampur; jika `report_time` tidak tersedia, UI menyatakan bahwa waktu laporan tidak disediakan sumber.
- [ ] Penurunan jumlah >20% tidak menimpa cache valid otomatis.
- [ ] Level kosong ditampilkan sebagai kelompok dengan jumlah 0.
- [ ] Endpoint detail tidak memicu pengambilan detail untuk semua gunung.
- [ ] Respons invalid tidak menggantikan cache valid.
- [ ] Jika refresh gagal, backend dapat menyajikan cache valid dengan metadata kesegaran; tanpa cache, status tidak tersedia dinyatakan eksplisit.
- [ ] Error sumber tidak membuat proses backend crash.
- [ ] Endpoint tidak mengklaim bahwa backend adalah API resmi MAGMA.

---

## M3 — UI Status Gunung dan Halaman Edukasi

### Tasks
- [ ] Implementasikan Beranda.
- [ ] Implementasikan daftar gunung dengan level aktivitas dari backend.
- [ ] Render daftar secara dinamis sesuai jumlah entri valid dari backend; jangan membatasi UI ke tiga gunung yang di-hardcode.
- [ ] Tambahkan pencarian nama dan filter level.
- [ ] Tambahkan empty state untuk pencarian/filter tanpa hasil, dengan opsi menghapus pencarian/filter.
- [ ] Implementasikan halaman detail gunung.
- [ ] Tampilkan waktu laporan sumber, waktu data diambil, sumber, dan tautan laporan resmi jika tersedia.
- [ ] Buat loading, empty, error, dan stale-data states yang jelas.
- [ ] Jika data lama ditampilkan, beri label yang terlihat; jangan tampilkan seolah-olah baru.
- [ ] Implementasikan Edukasi, Panduan Tindakan, dan Sumber/Tentang.
- [ ] Cantumkan disclaimer bahwa aplikasi bukan sistem peringatan dini resmi.
- [ ] Pastikan halaman inti dan perilaku data sama di Android dan Web.
- [ ] Uji CORS dan konfigurasi URL backend untuk deployment.

### Deliverables
- UI status gunung di Android dan Web.
- Halaman detail dan tautan sumber.
- Halaman edukasi/panduan.
- State loading, error, kosong, dan data stale.

### Acceptance criteria
- [ ] Daftar status berhasil ditampilkan dari backend pada kedua platform.
- [ ] Urutan level dan alfabetis konsisten; level kosong memiliki empty state.
- [ ] Pencarian/filter tanpa hasil menampilkan empty state yang dapat dipulihkan.
- [ ] Snapshot yang turun >20% ditahan dan tidak menggantikan cache valid.
- [ ] Detail hanya diambil on-demand dan cache detail terpisah dari cache daftar.
- [ ] Urutan level dan alfabetis konsisten; level kosong memiliki empty state.
- [ ] Pencarian/filter tanpa hasil menampilkan empty state yang dapat dipulihkan.
- [ ] Snapshot yang turun >20% ditahan dan tidak menggantikan cache valid.
- [ ] Detail hanya diambil on-demand dan cache detail terpisah dari cache daftar.
- [ ] Detail gunung menampilkan field yang benar-benar tersedia dari sumber.
- [ ] Waktu laporan dibedakan dari waktu pengambilan.
- [ ] Tautan resmi berfungsi jika tersedia.
- [ ] Kegagalan backend menghasilkan pesan yang wajar dan tidak membuat aplikasi crash.
- [ ] Disclaimer dapat ditemukan dengan mudah.

---

## M4 — Checklist dan Hardening

### Tasks
- [ ] Tetapkan item checklist umum berdasarkan sumber resmi yang disetujui; checklist tidak berubah otomatis berdasarkan level aktivitas.
- [ ] Pastikan topik edukasi dan setiap butir checklist memiliki referensi yang dapat ditelusuri.
- [ ] Implementasikan checklist dan status selesai/belum selesai.
- [ ] Tampilkan indikator progres dan reset dengan konfirmasi jika disediakan.
- [ ] Implementasikan penyimpanan lokal Android.
- [ ] Implementasikan penyimpanan lokal Web.
- [ ] Pastikan checklist bertahan setelah aplikasi/browser ditutup dan dibuka kembali.
- [ ] Uji layout Web pada layar ponsel dan desktop.
- [ ] Uji status API: loading, koneksi gagal, cache lama, data kosong, dan data tidak valid.
- [ ] Uji daftar dinamis dengan jumlah entri berbeda dan pastikan tidak ada batas tetap tiga gunung di UI atau backend.
- [ ] Uji urutan level, urutan alfabetis, kelompok level kosong, dan pencarian/filter tanpa hasil.
- [ ] Uji penurunan jumlah >20% dan pastikan cache valid dipertahankan.
- [ ] Uji `report_time` tidak tersedia dan pastikan UI menampilkan teks fallback.
- [ ] Uji timeout, 403, dan kegagalan parser pada backend melalui mock atau skenario uji yang aman.
- [ ] Periksa kontras, ukuran teks, navigasi, dan aksesibilitas dasar.
- [ ] Uji konten offline Android; uji offline Web hanya sesuai strategi cache yang benar-benar dibuat.
- [ ] Pastikan tidak ada informasi status hardcoded yang terlihat seperti status aktual.

### Deliverables
- Checklist yang persisten pada kedua platform.
- UI responsif dan error states yang lebih matang.
- Catatan hasil uji hardening.

### Acceptance criteria
- [ ] Checklist tersimpan secara terpisah pada Android dan Web.
- [ ] Data stale atau tidak tersedia diberi label dengan benar.
- [ ] Data invalid tidak disajikan sebagai status baru yang sah.
- [ ] Fitur inti dapat digunakan di layar ponsel dan desktop.
- [ ] Klaim offline sesuai dengan yang benar-benar diuji.

---

## M5 — Pengujian, Deployment, dan Demonstrasi

### Tasks
- [ ] Jalankan unit test backend dan test UI yang relevan.
- [ ] Uji manual di emulator/perangkat Android.
- [ ] Uji Web di browser desktop dan viewport ponsel.
- [ ] Verifikasi ulang sampel level dan laporan dengan halaman resmi MAGMA pada saat pengujian.
- [ ] Pastikan build/demo menggunakan hash commit scraper yang dipin, bukan menarik branch `main` terbaru otomatis.
- [ ] Uji refresh berhasil dan skenario sumber gagal.
- [ ] Uji cache: pastikan waktu pengambilan tidak berubah seolah-olah baru ketika sumber gagal.
- [ ] Uji daftar, detail, tautan sumber, edukasi, panduan, dan checklist pada kedua platform.
- [ ] Perbaiki bug kritis dan catat keterbatasan yang belum terselesaikan.
- [ ] Deploy backend dengan konfigurasi yang sesuai dan Web ke hosting.
- [ ] Siapkan build Android.
- [ ] Siapkan README berisi cara menjalankan frontend/backend, konfigurasi, dan batasan sumber data.
- [ ] Siapkan skenario demo yang menunjukkan kondisi normal serta fallback saat data gagal.

### Deliverables
- Build Android.
- Web yang dapat diakses untuk demo.
- Backend yang dapat diakses oleh kedua platform.
- Hasil pengujian, daftar keterbatasan, dan instruksi menjalankan proyek.

### Acceptance criteria
- [ ] Android dan Web menggunakan backend yang sama.
- [ ] Fitur wajib diuji pada kedua platform.
- [ ] Data status memiliki sumber dan metadata waktu yang sesuai, termasuk fallback eksplisit saat waktu laporan tidak disediakan.
- [ ] Build/demo menggunakan commit scraper yang dipin.
- [ ] Kondisi gagal tidak membuat aplikasi mengklaim data baru yang belum berhasil diperoleh.
- [ ] Checklist persisten di tiap platform.
- [ ] Tim dapat mendemonstrasikan alur normal dan setidaknya satu skenario kegagalan.

---

## Fitur di Luar MVP

- [ ] Push notification perubahan status.
- [ ] Login dan sinkronisasi checklist.
- [ ] Peta bahaya atau rute evakuasi.
- [ ] Pelacakan lokasi.
- [ ] Prediksi aktivitas gunung.
- [ ] Panel admin/CMS.
- [ ] Dukungan banyak sumber selain MAGMA.

Jangan memulai fitur di luar MVP sebelum status aktual, error handling, Android, dan Web berfungsi.

## Urutan Demonstrasi

1. Buka Web dan tunjukkan daftar gunung serta metadata pembaruan.
2. Buka detail salah satu gunung dan tautan laporan resmi.
3. Tunjukkan loading/error/stale state menggunakan skenario uji yang terkendali.
4. Buka edukasi, panduan, dan sumber.
5. Uji checklist dan reload Web.
6. Buka aplikasi Android dan tunjukkan data inti yang sama dari backend.
7. Uji checklist Android setelah aplikasi dibuka kembali.
8. Jelaskan bahwa status diambil dari sumber MAGMA, scraper tidak resmi dapat berubah, dan aplikasi bukan sistem peringatan dini resmi.

## Definition of Done

MVP selesai jika backend menyajikan status yang tervalidasi dengan cache dan timestamp; Flutter Android dan Web menampilkan daftar/detail status dan tautan sumber; kegagalan dan data lama ditangani secara transparan; edukasi, panduan, serta checklist tersedia; kedua platform diuji; dan dokumentasi menjelaskan keterbatasan scraper serta batasan keselamatan aplikasi.
