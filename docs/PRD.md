# Product Requirements Document (PRD)

## SiagaGunung — Aplikasi Informasi Aktivitas dan Edukasi Kesiapsiagaan Gunung Api

**Versi:** 1.4  
**Tanggal:** 25 Oktober 2026  
**Status:** Draf untuk pengembangan proyek kuliah  
**Platform:** Android dan Web  
**Frontend yang direkomendasikan:** Flutter untuk Android dan Web  
**Backend yang direkomendasikan:** Python + FastAPI  
**Sumber data status:** MAGMA Indonesia/PVMBG melalui scraper prototipe, sambil memverifikasi opsi API/CAP resmi  
**Batas penting:** SiagaGunung bukan sistem peringatan dini resmi dan bukan pengganti instruksi otoritas.

---

## 1. Ringkasan Produk

SiagaGunung adalah aplikasi informasi aktivitas gunung api dan edukasi kesiapsiagaan. Aplikasi menampilkan daftar gunung beserta level aktivitas yang berhasil diambil dari sumber MAGMA Indonesia, waktu laporan jika tersedia, ringkasan/laporan aktivitas yang didukung sumber, dan tautan menuju halaman resmi. Aplikasi juga menyediakan materi edukasi, panduan tindakan, dan checklist kesiapsiagaan.

Versi 1.4 memperjelas aturan validasi daftar dinamis, identitas gunung, pengambilan detail secara on-demand, parameter operasional awal, dan kriteria pengujian dan mempertahankan perubahan integrasi status aktual dari versi sebelumnya: **status aktivitas gunung yang aktual menjadi fitur inti**, bukan hanya tautan keluar. Kedua platform—Android dan Web—menggunakan backend yang sama agar format dan aturan data konsisten.

Repositori [Gabrielbjb/Magma-Indonesia-API](https://github.com/Gabrielbjb/Magma-Indonesia-API) menjadi kandidat prototipe pengambilan data. Berdasarkan pengujian yang dilaporkan pada 25 Oktober 2026 terhadap kode `main` saat itu, fungsi scraper berhasil mengambil daftar level dan laporan erupsi dari situs MAGMA. Snapshot yang digunakan untuk pengembangan/demo harus dipin ke hash commit tertentu; jangan mengambil `main` terbaru secara otomatis. Namun, proyek tersebut adalah scraper tidak resmi, bukan API resmi dengan jaminan stabilitas. Implementasi harus memiliki validasi, cache, timeout, retry terbatas, penanganan error, serta tautan sumber asli. Tim tetap perlu memeriksa apakah API/CAP resmi MAGMA tersedia dan dapat digunakan.

SiagaGunung menyajikan informasi yang diambil dari sumber, tetapi tidak menjamin pembaruan setiap detik. Aplikasi tidak membuat prediksi, tidak membuat rekomendasi bahaya sendiri, dan tidak mengirim peringatan darurat.

## 2. Latar Belakang dan Masalah

Pengguna perlu cara sederhana untuk memeriksa status aktivitas gunung dan menemukan laporan sumber, sekaligus mempelajari langkah kesiapsiagaan. Informasi aktivitas dapat berubah; karena itu, aplikasi harus menampilkan waktu laporan dan waktu pengambilan data secara terpisah serta menjelaskan ketika data mungkin sudah lama.

Masalah dan manfaat produk ini merupakan hipotesis proyek akademik yang dapat dievaluasi melalui pengujian terbatas dengan calon pengguna. Proyek tidak mengklaim sebagai sistem operasional kebencanaan.

## 3. Tujuan Produk

### 3.1 Tujuan utama

- Menampilkan daftar gunung dan level aktivitas berdasarkan data yang berhasil diperoleh dari MAGMA Indonesia.
- Menyediakan detail aktivitas/laporan terbaru sejauh data sumber tersedia.
- Menampilkan sumber dan waktu laporan serta waktu pengambilan data.
- Mengarahkan pengguna ke halaman resmi MAGMA untuk verifikasi dan konteks lengkap.
- Menyediakan edukasi kesiapsiagaan, panduan tindakan, dan checklist lokal.
- Memberikan pengalaman inti yang konsisten di Android dan Web.
- Menangani data basi, data tidak valid, kegagalan jaringan, dan kegagalan scraper secara transparan.

### 3.2 Bukan tujuan

- Menjadi sistem peringatan dini resmi atau menjamin pengguna menerima peringatan darurat.
- Memprediksi erupsi atau menafsirkan data ilmiah di luar informasi sumber.
- Menggantikan rekomendasi dan instruksi PVMBG/Badan Geologi/BNPB atau otoritas setempat.
- Mengelola operasi evakuasi, petugas, posko, korban, atau bantuan.
- Menghasilkan peta jalur evakuasi atau mengklaim suatu jalur aman.
- Menjamin data selalu realtime atau selalu tersedia.

## 4. Target Pengguna

Warga, wisatawan, mahasiswa, dan pengguna umum yang ingin melihat informasi aktivitas gunung serta mempelajari kesiapsiagaan.

Kebutuhan utama:
- Melihat daftar gunung dan level aktivitas.
- Menemukan gunung tertentu melalui pencarian/filter sederhana.
- Membaca waktu laporan, detail yang tersedia, dan sumber asli.
- Mengetahui apakah data berhasil diperbarui atau mungkin sudah kedaluwarsa.
- Membaca materi kesiapsiagaan dan menggunakan checklist.
- Mengakses fungsi inti di Android dan Web.

## 5. Ruang Lingkup

### 5.1 Termasuk MVP

1. Aplikasi Flutter untuk Android dan Web responsif.
2. Backend FastAPI yang menyajikan data status kepada kedua platform.
3. Integrasi prototipe scraper MAGMA dari repositori GitHub yang ditinjau dan diuji oleh tim.
4. Daftar gunung dinamis yang mencakup semua entri yang dikembalikan sumber dan lolos validasi; tidak dibatasi pada tiga gunung atau daftar nama yang di-hardcode.
5. Pencarian nama gunung dan filter level aktivitas.
6. Halaman detail gunung yang mengambil detail hanya ketika pengguna membuka halaman detail, dengan cache detail terpisah.
7. Timestamp laporan sumber jika tersedia, serta timestamp pengambilan data backend.
8. Tautan menuju halaman/laporan resmi MAGMA.
9. Cache data daftar dan detail terakhir yang valid, dengan label jelas untuk data lama.
10. Validasi respons, aturan penolakan penurunan jumlah yang tidak wajar, dan penanganan error/timeout/403 serta data kosong atau rusak.
11. Materi edukasi dan panduan tindakan sebelum, saat, dan setelah kejadian, dengan sumber tepercaya yang ditinjau.
12. Checklist kesiapsiagaan umum dengan penyimpanan lokal terpisah per platform.
13. Penjelasan batasan produk dan sumber informasi.
14. Pengujian Android dan Web.

**Batas cakupan daftar gunung:** aplikasi tidak menetapkan batas tetap tiga gunung. Cakupan daftar mengikuti data yang berhasil diperoleh dari sumber dan lolos validasi. Ini tidak berarti aplikasi menjamin seluruh gunung api di Indonesia selalu tersedia; kelengkapan bergantung pada sumber dan hasil validasi.

### 5.2 Tidak termasuk MVP

- Login, profil pengguna, dan sinkronisasi cloud.
- Panel admin atau CMS.
- Push notification atau pengiriman peringatan otomatis.
- Prediksi erupsi, analisis sensor sendiri, atau penilaian risiko buatan aplikasi.
- Peta bahaya, penentuan jalur evakuasi, pelacakan lokasi pengguna.
- Pelaporan insiden, manajemen posko, atau operasi penyelamatan.
- Jaminan ketersediaan 24/7 atau SLA produksi.
- Scraping dengan frekuensi tinggi yang membebani situs sumber.

API/CAP resmi dapat menggantikan scraper bila akses dan ketentuannya sudah diverifikasi, tetapi tidak boleh diasumsikan tersedia tanpa pemeriksaan.

## 6. Kebutuhan Fungsional

| ID | Fitur | Kebutuhan | Prioritas |
|---|---|---|---|
| FR-01 | Beranda | Menampilkan ringkasan produk, akses ke daftar gunung, edukasi, panduan, dan checklist. | Must |
| FR-02 | Daftar status gunung | Menampilkan entri gunung yang lolos validasi dan pemeriksaan integritas, tanpa batas tetap tiga gunung atau whitelist nama statis. | Must |
| FR-03 | Pencarian/filter | Mencari nama gunung dan memfilter level aktivitas; menampilkan empty state jika tidak ada hasil. | Must |
| FR-04 | Detail gunung | Mengambil dan menampilkan detail aktivitas/laporan hanya saat halaman detail dibuka; menampilkan waktu laporan, waktu pengambilan, sumber, dan tautan resmi sesuai ketersediaan. | Must |
| FR-05 | Status kesegaran data | Membedakan data terkini menurut ambang aplikasi, data cache yang basi, dan data yang tidak tersedia. | Must |
| FR-06 | Edukasi | Menyediakan materi edukasi yang dikelompokkan berdasarkan topik dan ditinjau terhadap sumber tepercaya. | Must |
| FR-07 | Panduan tindakan | Menampilkan panduan sebelum/saat/setelah kejadian dengan sumber yang jelas. | Must |
| FR-08 | Checklist | Pengguna dapat menandai item checklist umum sebagai selesai/belum selesai. | Must |
| FR-09 | Persistensi checklist | Status checklist tetap ada setelah aplikasi/browser dibuka kembali pada platform yang sama. | Must |
| FR-10 | Sumber resmi | Pengguna dapat membuka halaman atau laporan resmi MAGMA dari aplikasi. | Must |
| FR-11 | Penanganan error | Error backend/sumber tidak membuat aplikasi crash dan tidak disamarkan sebagai data valid. | Must |
| FR-12 | Batasan aplikasi | Menjelaskan bahwa aplikasi bukan sistem peringatan dini resmi. | Must |
| FR-13 | Responsivitas | Fitur inti dapat digunakan di Android, browser ponsel, dan desktop. | Must |
| FR-14 | Push notification | Mengirim notifikasi perubahan status. | Out of scope |

## 7. Perilaku dan Alur Pengguna

### 7.1 Memeriksa status gunung

1. Pengguna membuka aplikasi Android atau Web.
2. Aplikasi meminta daftar status ke backend FastAPI.
3. Backend menggunakan data valid yang tersedia di cache dan menjalankan pembaruan sesuai strategi refresh yang ditetapkan; pengambilan data tidak dilakukan oleh masing-masing klien secara terpisah.
4. Aplikasi menampilkan level aktivitas, waktu laporan jika ada, waktu data terakhir diambil, serta sumber.
5. Pengguna membuka detail gunung dan dapat menuju laporan resmi MAGMA.
6. Jika pembaruan gagal, aplikasi menampilkan data cache dengan label data lama atau pesan tidak tersedia jika belum ada data valid.

### 7.2 Menggunakan checklist

Pengguna membuka checklist, menandai item, dan status disimpan secara lokal. Status Android dan Web tidak disinkronkan.

### 7.3 Membaca edukasi

Pengguna membuka kategori materi atau panduan tindakan. Setiap materi memiliki sumber rujukan yang dapat ditelusuri.

## 8. Struktur Halaman

1. **Beranda:** pengenalan, ringkasan status/data terbaru jika tersedia, navigasi utama, dan catatan batasan.
2. **Daftar Gunung:** nama, level aktivitas, indikator kesegaran data, pencarian/filter dasar.
3. **Detail Gunung:** level, informasi/laporan yang disediakan sumber, waktu laporan, waktu pengambilan data, tautan resmi, serta peringatan data lama bila relevan.
4. **Edukasi:** daftar kategori dan detail materi.
5. **Panduan Tindakan:** materi sebelum, saat, dan setelah kejadian berdasarkan sumber tepercaya.
6. **Checklist:** daftar item, status, progres, dan reset dengan konfirmasi bila disediakan.
7. **Sumber dan Tentang:** identitas sumber, tautan MAGMA, versi aplikasi, penjelasan batasan dan penanganan data.

## 9. Sumber Data dan Integrasi

### 9.1 Sumber utama

- Sumber yang ditampilkan kepada pengguna: MAGMA Indonesia/PVMBG.
- Kandidat pengambil data awal: [Gabrielbjb/Magma-Indonesia-API](https://github.com/Gabrielbjb/Magma-Indonesia-API). Jangan bergantung pada branch `main` yang bergerak untuk build demo; pada M1, pin hash commit yang benar-benar diuji dan vendorkan/fork kode itu ke repositori proyek. Jangan menganggap paket PyPI identik dengan kode repo.
- Kandidat jangka panjang: API atau CAP resmi MAGMA, apabila dokumentasi, akses, dan ketentuan penggunaannya telah diverifikasi.

### 9.2 Prinsip integrasi

- Backend FastAPI menjadi perantara tunggal antara sumber data dan aplikasi Flutter.
- Klien Android/Web tidak melakukan scraping langsung.
- Normalisasikan respons scraper ke model data internal yang konsisten.
- Simpan waktu pengambilan data backend (`fetched_at`) terpisah dari waktu laporan sumber (`report_time` jika tersedia).
- Simpan URL sumber untuk setiap data jika tersedia.
- Gunakan cache dengan kebijakan refresh yang wajar; interval final ditentukan setelah menguji perilaku sumber dan menghindari permintaan berlebihan.
- Tetapkan timeout dan retry terbatas. Jangan melakukan retry tanpa batas.
- Catat error teknis di log backend tanpa membocorkan detail sensitif ke klien.
- Validasi struktur dan isi data sebelum mengganti cache valid.
- Jika jumlah entri baru turun lebih dari 20% dibanding daftar cache valid terakhir, tandai snapshot baru sebagai anomali dan jangan mengganti cache otomatis. Catat anomali untuk pemeriksaan silang terhadap halaman resmi; jangan menampilkan snapshot parsial tersebut sebagai daftar lengkap.
- Jika sumber gagal atau snapshot ditolak, pertahankan cache terakhir yang valid dan tampilkan umurnya serta label bahwa pembaruan gagal/perlu pemeriksaan; jika cache belum ada, tampilkan status tidak tersedia.
- Urutkan daftar menurut level aktivitas dari paling tinggi ke rendah (Level IV/Awas, III/Siaga, II/Waspada, I/Normal); dalam setiap level, urutkan nama gunung secara alfabetis.
- Tampilkan keempat kelompok level secara konsisten. Jika suatu level kosong, tampilkan jumlah 0 dan empty state, bukan error atau penghilangan kelompok secara diam-diam.
- Jangan mengklaim data realtime tanpa definisi dan bukti frekuensi pembaruan.

### 9.3 Validasi minimum

- Respons harus sesuai skema yang diharapkan.
- Nama gunung dan level aktivitas harus ada dan dapat dipetakan ke nilai yang dikenal.
- Deteksi duplikasi dan respons kosong yang tidak wajar.
- Jika jumlah entri turun lebih dari 20% dibanding cache valid terakhir, tolak snapshot baru sebagai daftar pengganti otomatis dan pertahankan cache lama sampai hasil diperiksa silang. Ambang ini merupakan aturan konservatif MVP dan dapat direvisi setelah pengujian.
- Nilai level yang tidak dikenal tidak boleh diam-diam dipetakan ke level lain.
- Detail laporan harus mempertahankan tautan dan waktu asli jika sumber menyediakannya.
- Uji silang sampel status dengan halaman resmi secara manual selama pengembangan dan sebelum demo.

### 9.4 Identitas gunung dan detail on-demand

- Gunakan slug internal yang dinormalisasi dari nama gunung sebagai `id`, bukan ID laporan.
- Jika ada nama yang bertabrakan, tambahkan lokasi/region yang tersedia ke slug. Jika masih bertabrakan, tambahkan suffix deterministik dari kombinasi nama dan lokasi.
- ID laporan pada URL sumber bukan ID gunung stabil dan tidak boleh dipakai sebagai primary ID.
- Endpoint daftar hanya mengambil data ringkas. Pengambilan halaman detail/laporan dilakukan on-demand ketika pengguna membuka detail gunung, lalu disimpan pada cache detail terpisah.
- Jangan melakukan fetch detail untuk semua gunung sekaligus.
- Jika detail gagal diambil, tampilkan data daftar yang tersedia dan jelaskan bahwa detail tidak berhasil diperbarui; jangan menghapus daftar atau cache detail valid sebelumnya.

### 9.5 Definisi kesegaran data

Aplikasi menampilkan setidaknya dua waktu yang berbeda jika tersedia:
- **Waktu laporan sumber:** waktu yang tertera pada laporan MAGMA jika sumber menyediakannya. Jika tidak tersedia, UI menampilkan teks eksplisit: “Waktu laporan tidak disediakan oleh sumber”.
- **Terakhir diambil aplikasi:** waktu backend berhasil mengambil dan memvalidasi data.

Parameter awal MVP yang dapat direvisi setelah pengujian M1: refresh daftar di sisi server setiap 30 menit; label data basi jika keberhasilan pengambilan terakhir berumur lebih dari 2 jam; timeout request sumber 10 detik; maksimal 2 retry setelah percobaan awal dengan backoff. Nilai ini merupakan konfigurasi awal untuk pengujian, bukan jaminan resmi atau SLA. Data lama harus diberi label yang terlihat, bukan ditampilkan seperti data baru.

## 10. Aturan Bisnis dan Keselamatan

1. Level aktivitas dan informasi aktivitas bersumber dari MAGMA/PVMBG atau sumber resmi lain yang jelas dicantumkan.
2. Aplikasi tidak membuat prediksi erupsi atau rekomendasi keselamatan sendiri.
3. Jangan mengubah atau meringkas rekomendasi resmi hingga mengubah maknanya. Jika ringkasan dibuat, pertahankan tautan dan konteks sumber.
4. Waktu laporan dan waktu pengambilan data tidak boleh dicampur.
5. Data cache yang lama harus diberi label; kegagalan mengambil data baru tidak boleh dianggap sebagai konfirmasi bahwa status belum berubah.
6. Jika data tidak tersedia atau tidak valid, nyatakan demikian dengan jelas.
7. Jangan menyebut SiagaGunung sebagai aplikasi resmi MAGMA/PVMBG atau sistem peringatan dini.
8. Pengguna harus dapat membuka laporan resmi untuk informasi lengkap dan instruksi terkini.
9. Jangan mengarang zona bahaya, jalur aman, lokasi posko, nomor darurat, atau instruksi resmi.
10. Materi edukasi memiliki sumber rujukan dan ditinjau sebelum rilis.
11. Checklist bersifat umum, tidak berubah otomatis berdasarkan level aktivitas gunung, dan bukan pengganti instruksi otoritas.
12. Tinjau ketentuan penggunaan situs dan repositori sebelum deployment publik; hindari scraping berlebihan.

## 11. Kebutuhan Nonfungsional

| Area | Kebutuhan |
|---|---|
| Platform | Android dan Web melalui Flutter, kecuali tim memutuskan pendekatan terpisah dengan alasan yang jelas. |
| Bahasa | Bahasa Indonesia yang ringkas, konsisten, dan mudah dipahami. |
| Responsivitas | Web berfungsi di browser ponsel dan desktop. |
| Kinerja | Konten edukasi lokal tidak perlu menunggu backend; daftar status menampilkan loading state yang jelas. |
| Keandalan | Timeout, retry terbatas, validasi respons, cache data valid, dan pesan error yang wajar. |
| Transparansi | Sumber, waktu laporan, waktu pengambilan, dan label data lama ditampilkan jika relevan. |
| Privasi | Tidak memerlukan akun atau lokasi pengguna untuk fitur inti. |
| Keamanan | Backend tidak membocorkan stack trace atau detail internal; CORS dikonfigurasi sesuai deployment. |
| Penyimpanan | Cache status berada di backend; checklist tersimpan lokal dan terpisah pada Android/Web. |
| Offline | Konten edukasi lokal dan checklist dapat digunakan offline sesuai implementasi. Status aktual memerlukan koneksi atau cache backend yang masih dapat diakses; Web offline tidak dijanjikan kecuali benar-benar diterapkan dan diuji. |
| Pemeliharaan | Scraper dan adapter sumber dipisahkan dari model data API internal agar sumber bisa diganti tanpa merombak UI. |

## 12. Data dan Model Internal

Skema aktual menyesuaikan data yang benar-benar tersedia dari scraper. Model minimum yang disarankan:

- `id` — slug internal deterministik dari nama gunung, ditambah lokasi jika diperlukan untuk menghindari tabrakan; bukan ID laporan.
- `name` — nama gunung.
- `activity_level` — level yang berhasil dipetakan dari sumber.
- `report_time` — waktu laporan sumber, nullable jika tidak tersedia; UI harus menjelaskan bila sumber tidak menyediakan waktu laporan.
- `summary` atau `report_items` — hanya field yang benar-benar didukung sumber.
- `source_url` — URL halaman/laporan sumber, jika tersedia.
- `fetched_at` — waktu backend berhasil mengambil dan memvalidasi data.
- `data_age_status` — status internal untuk menandai fresh/stale berdasarkan ambang konfigurasi.

Backend juga perlu menyimpan metadata cache daftar dan detail secara terpisah, waktu keberhasilan terakhir, dan error terakhir untuk observabilitas. Jangan menyajikan field yang tidak didukung sumber sebagai seolah-olah resmi.

Checklist lokal menyimpan ID item dan status selesai/belum selesai. Tidak ada sinkronisasi cloud.

## 13. Rekomendasi Teknologi dan Arsitektur

### Frontend
- Flutter/Dart untuk Android dan Web.
- Klien HTTP untuk memanggil backend.
- State UI untuk loading, sukses, data cache lama, error, dan data kosong.
- Penyimpanan lokal checklist yang kompatibel dengan tiap platform.

### Backend
- Python + FastAPI.
- Modul adapter untuk scraper MAGMA.
- Validasi dan normalisasi data sebelum disajikan.
- Cache data terakhir yang valid; penyimpanan sederhana dapat dipilih berdasarkan kebutuhan MVP.
- Endpoint internal yang disarankan: `GET /api/v1/volcanoes`, `GET /api/v1/volcanoes/{id}`, dan `GET /api/v1/health`. `id` adalah slug gunung stabil, bukan ID laporan. Endpoint detail mengambil data secara on-demand dan menggunakan cache detail terpisah.
- Endpoint refresh tidak perlu diekspos ke publik jika pembaruan dijalankan oleh backend secara terjadwal atau saat cache kedaluwarsa.

### Sumber data
- Mulai dengan snapshot kode scraper yang telah diuji dan dipin ke hash commit spesifik di repositori proyek; jangan mengambil branch `main` terbaru secara otomatis saat build.
- Verifikasi kemungkinan penggunaan API/CAP resmi secara paralel.
- Pisahkan implementasi sumber dari kontrak endpoint backend sehingga migrasi sumber tidak memerlukan perubahan besar pada Flutter.

**Catatan:** API FastAPI yang kita bangun adalah API milik aplikasi SiagaGunung, bukan API resmi MAGMA.

## 14. Kriteria Penerimaan

| ID | Skenario | Kriteria lulus |
|---|---|---|
| AC-01 | Membuka Android | Beranda tampil tanpa login. |
| AC-02 | Membuka Web | Situs dapat digunakan di browser modern tanpa login. |
| AC-03 | Daftar status dinamis | Daftar gunung dan level ditampilkan dari backend dengan format konsisten; aplikasi tidak membatasi daftar ke tiga nama tetap. Urutan level IV, III, II, I; nama dalam tiap level alfabetis. Kelompok level kosong tetap tampil dengan jumlah 0 dan empty state. Snapshot dengan penurunan jumlah >20% dari cache valid terakhir tidak otomatis mengganti cache. |
| AC-04 | Detail gunung | Detail diambil on-demand untuk gunung yang dibuka; waktu laporan ditampilkan jika tersedia. Jika tidak disediakan sumber, UI menyatakan hal itu secara eksplisit. Waktu pengambilan dan tautan sumber tampil dengan benar jika tersedia. ID detail stabil dan tidak memakai ID laporan. |
| AC-05 | Kegagalan sumber | Timeout/403/error tidak membuat aplikasi crash atau menampilkan respons gagal sebagai data baru yang valid. |
| AC-06 | Cache | Cache terakhir yang valid dapat ditampilkan dengan label data lama jika refresh gagal; tanpa cache, tampilkan status tidak tersedia. |
| AC-07 | Validasi | Respons kosong/rusak, field penting hilang, atau level tidak dikenal terdeteksi dan tidak diam-diam mengganti cache valid. |
| AC-08 | Sumber resmi | Pengguna dapat membuka halaman/laporan MAGMA yang terkait jika URL tersedia. |
| AC-09 | Edukasi | Pengguna dapat membaca materi bersumber pada kedua platform. |
| AC-10 | Panduan | Materi dikelompokkan dengan jelas dan menampilkan sumber. |
| AC-11 | Checklist | Pengguna dapat menandai dan membatalkan item di kedua platform. |
| AC-12 | Persistensi | Checklist tetap tersimpan setelah aplikasi/browser dibuka kembali pada platform yang sama. |
| AC-13 | Responsivitas | Fitur inti dapat digunakan pada layar ponsel dan desktop. |
| AC-14 | Batasan aplikasi | Pengguna dapat menemukan penjelasan bahwa aplikasi bukan sumber peringatan resmi. |
| AC-15 | Konsistensi | Android dan Web menggunakan backend dan kontrak data yang sama. |
| AC-16 | Validasi manual | Sampel data level dan laporan dibandingkan dengan halaman resmi pada saat pengujian. |
| AC-17 | Pencarian/filter | Pencarian nama dan filter level bekerja; jika tidak ada hasil, UI menampilkan pesan hasil kosong dan kontrol untuk menghapus filter. |
| AC-18 | Parameter operasional | Refresh daftar awal 30 menit, stale >2 jam, timeout 10 detik, dan maksimal 2 retry setelah percobaan awal dapat dikonfigurasi dan diuji. |
| AC-19 | Penurunan jumlah anomali | Jika daftar baru berkurang >20% dibanding cache valid, cache tidak ditimpa otomatis dan UI/metadata menandai bahwa pembaruan perlu pemeriksaan. |

## 15. Metrik Keberhasilan

- Android dan Web dapat dijalankan dan didemonstrasikan.
- Daftar dan detail status tampil dari backend pada kondisi normal.
- Status sumber, waktu laporan jika tersedia, dan waktu pengambilan ditampilkan dengan benar.
- Kegagalan sumber dan data basi ditangani tanpa klaim palsu bahwa data baru berhasil diambil.
- Sampel data diverifikasi terhadap halaman resmi saat pengujian.
- Konten edukasi memiliki sumber.
- Checklist tersimpan pada platform masing-masing.
- Seluruh kriteria penerimaan wajib diuji.

## 16. Risiko dan Mitigasi

| Risiko | Mitigasi |
|---|---|
| Struktur HTML MAGMA berubah | Pisahkan scraper dalam adapter, buat test parser, catat error, dan siapkan tautan sumber/fallback UI. |
| Request diblokir (mis. 403) | Timeout dan retry terbatas; hormati pembatasan sumber; gunakan cache valid; jangan mencoba mengakali pembatasan akses. |
| Data basi dianggap aktual | Tampilkan `report_time` dan `fetched_at`, tetapkan ambang stale, beri label yang terlihat. |
| Data scraper tidak lengkap/rusak | Validasi skema, deteksi perubahan tidak wajar, dan jangan menimpa cache valid dengan data invalid. |
| API/CAP resmi belum dapat diakses | Lanjutkan prototipe scraper hanya untuk lingkup proyek dengan mitigasi yang jelas; catat batasan dan evaluasi sumber resmi. |
| Scraper tidak dirawat | Pin/catat commit yang diuji, tinjau kode, buat tes internal, dan isolasi adapter agar mudah diganti. |
| Backend tidak tersedia | UI menampilkan error yang wajar; bila cache klien tidak direncanakan, jelaskan bahwa status membutuhkan koneksi ke backend. |
| Pengguna mengira aplikasi memberi peringatan resmi | Tampilkan disclaimer, tautan MAGMA, waktu laporan, dan instruksi mengikuti otoritas. |
| Cakupan melebar | Prioritaskan status gunung, edukasi, checklist, dua platform, dan pengujian. |

## 17. Tahapan Pengerjaan

1. **M1 — Validasi sumber dan fondasi:** buktikan scraper dapat dijalankan dari backend lokal, verifikasi field, periksa opsi API/CAP resmi, tetapkan arsitektur, dan jalankan Flutter di Android/Web.
2. **M2 — Backend dan data status:** buat adapter, model internal, endpoint, cache, validasi, timestamp, dan penanganan error.
3. **M3 — UI status dan halaman edukasi:** daftar gunung, detail, loading/error/stale states, tautan resmi, edukasi, panduan, dan sumber pada Android/Web.
4. **M4 — Checklist dan hardening:** penyimpanan lokal, responsivitas, pengujian error, validasi data, dan aksesibilitas.
5. **M5 — Pengujian dan demo:** verifikasi terhadap MAGMA, uji backend/frontend, deployment Web, build Android, dokumentasi dan demonstrasi.

Lihat `Milestones_SiagaGunung_v1.3.md` untuk tugas rinci dan acceptance criteria setiap milestone.

## 18. Keputusan yang Perlu Ditetapkan Tim

1. Gunung yang dipakai sebagai sampel uji manual; sampel tidak membatasi daftar produk.
2. Konfirmasi atau revisi parameter awal setelah M1: refresh daftar 30 menit, stale >2 jam, timeout 10 detik, maksimal 2 retry setelah percobaan awal.
3. Skema respons backend dan strategi cache daftar/detail terpisah.
4. Hasil verifikasi dokumentasi/akses API atau CAP resmi MAGMA.
5. Hash commit scraper yang dipin dan lokasi salinan/fork internal.
6. Sumber resmi dan topik edukasi/checklist yang disetujui.
7. Versi minimum Android dan browser target.
8. Apakah offline Web akan didukung; jangan menjanjikannya tanpa implementasi.

## 19. Definition of Done

MVP selesai jika aplikasi Android dan Web berfungsi; backend menyajikan data status yang tervalidasi; daftar/detail status, timestamp, sumber, label stale, dan error states berfungsi; materi edukasi dan checklist tersedia; status checklist tersimpan lokal pada masing-masing platform; sampel data dibandingkan dengan halaman resmi; dan batasan produk dijelaskan. MVP tidak boleh dipresentasikan sebagai sistem peringatan dini resmi atau layanan yang menjamin data selalu realtime.

---

**Ringkasan keputusan produk:** SiagaGunung adalah aplikasi Android dan Web dengan daftar gunung dinamis—bukan terbatas pada tiga gunung tetap—untuk melihat status aktivitas gunung yang diambil dari MAGMA, membaca laporan sumber, dan mempelajari kesiapsiagaan. Scraper GitHub merupakan prototipe sumber data yang tidak resmi dan dapat berubah; backend harus memvalidasi serta menyajikan data dengan timestamp, cache, dan penanganan error. API/CAP resmi diprioritaskan jika aksesnya dapat diverifikasi. Aplikasi bukan sistem peringatan dini resmi.
