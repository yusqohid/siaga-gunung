# Business Requirements Document — SiagaGunung

Versi: 0.1 — Draf untuk ditinjau  
Tanggal: 13 Oktober 2026  
Konteks: Proyek tugas kuliah  
Status: Belum merupakan spesifikasi aplikasi operasional kebencanaan

## 1. Ringkasan proyek

SiagaGunung adalah prototipe aplikasi kesiapsiagaan dan panduan evakuasi bagi warga serta wisatawan di kawasan sekitar gunung api di Sumatera Barat. Aplikasi membantu pengguna memahami tindakan yang perlu dilakukan, titik kumpul yang dituju, dan jalur yang tersedia setelah menerima peringatan.

Versi pertama mencakup Gunung Marapi, Talang, dan Tandikat (Tandikek), dengan satu kawasan demonstrasi untuk setiap gunung. Nama kawasan, titik kumpul, posko, dan lintasan demonstrasi belum ditentukan. Cakupan ini tidak berarti seluruh wilayah sekitar ketiga gunung telah didukung.

Aplikasi Android melayani pengguna umum tanpa login. Panel web melayani petugas yang login dan hanya dapat mengelola gunung yang ditugaskan kepadanya. Backend menggunakan Firebase. Peristiwa bencana, peringatan, dan data operasional demonstrasi menggunakan data simulasi yang diberi penanda jelas.

## 2. Latar belakang dan masalah

Masalah yang ingin diselesaikan adalah pengguna belum mengetahui apa yang harus dilakukan dan ke mana harus menuju ketika menerima peringatan bahaya gunung api. Informasi status saja belum cukup untuk menjelaskan tindakan, titik kumpul, dan jalur yang relevan bagi kawasan pengguna.

Pernyataan masalah tersebut merupakan hipotesis proyek. Tim belum melakukan wawancara dengan warga, wisatawan, atau petugas setempat. Penelitian dokumen resmi dan pengujian prototipe akan digunakan sebagai dasar awal; keduanya tidak menggantikan validasi kebutuhan dan jalur di lapangan.

## 3. Tujuan dan ukuran keberhasilan

Tujuan bisnis proyek adalah menyediakan pengalaman yang menghubungkan peringatan dengan panduan tindakan dan tujuan evakuasi, sambil membatasi pekerjaan petugas pada pengumuman serta perubahan informasi yang relevan.

Keberhasilan tugas dinilai dari kemampuan mendemonstrasikan alur utama secara utuh:

1. Petugas yang berwenang menerbitkan peringatan simulasi untuk gunung yang ditugaskan.
2. Pengguna yang memantau gunung tersebut menerima notifikasi Android saat aplikasi tidak terbuka, dalam kondisi pengujian yang memenuhi prasyarat notifikasi.
3. Ketukan pada notifikasi membuka detail peringatan yang sesuai.
4. Pengguna menemukan tindakan, titik kumpul, posko, dan jalur yang sesuai dengan kawasan pilihannya.
5. Penutupan jalur dan perubahan status posko oleh petugas tercermin pada informasi pengguna.
6. Pengguna dapat membuka tujuan di Google Maps dan menggunakan checklist kesiagaan.
7. Pengguna tanpa kewenangan tidak dapat mengubah informasi atau menerbitkan peringatan.

Pengujian dengan teman kuliah dapat menilai apakah pengguna mampu menyelesaikan skenario tanpa arahan penguji. Hasil tersebut merupakan bukti kemudahan penggunaan prototipe, bukan bukti efektivitas evakuasi nyata. Jumlah peserta dan target waktu penyelesaian belum ditetapkan.

## 4. Pemangku kepentingan dan role

| Pihak / role    | Kepentingan atau kewenangan                                                         |
|-----------------|-------------------------------------------------------------------------------------|
| Tim mahasiswa   | Mengembangkan, menguji, dan mendemonstrasikan prototipe                             |
| Dosen / penilai | Menilai pemenuhan tujuan tugas dan fungsi utama                                     |
| Warga           | Mengakses informasi, persiapan, dan panduan untuk kawasan yang didukung             |
| Wisatawan       | Mengakses panduan untuk kawasan yang dikunjungi; tidak mencakup evakuasi pendaki    |
| Petugas         | Mengelola pengumuman, ringkasan kondisi, jalur, dan posko untuk gunung penugasannya |

Role petugas disimulasikan dengan akun uji yang disiapkan tim. Keberadaan role ini tidak menyatakan adanya kerja sama atau kewenangan resmi dari instansi. Pengelolaan akun dan penugasan awal dilakukan melalui konfigurasi administratif; panel pengelola akun tersendiri belum masuk cakupan.

## 5. Cakupan

### 5.1 Dalam cakupan versi pertama

- Aplikasi Android pengguna umum tanpa login.
- Panel web petugas dengan login dan pembatasan akses berdasarkan penugasan gunung.
- Tiga gunung: Marapi, Talang, dan Tandikat; satu kawasan demonstrasi per gunung.
- Pemilihan gunung dan kawasan secara manual, dengan bantuan saran berdasarkan lokasi perangkat.
- Ringkasan kondisi gunung, pengumuman lokal, dan peringatan simulasi.
- Push notification dengan suara standar untuk gunung yang dipantau pengguna.
- Panduan tindakan, titik kumpul, posko, dan lintasan evakuasi yang telah disiapkan.
- Informasi ketersediaan jalur dan status buka/tutup posko.
- Pembukaan Google Maps untuk bantuan navigasi.
- Konten edukasi dan checklist kesiagaan.
- Firebase sebagai layanan backend.

### 5.2 Di luar cakupan versi pertama

- Prediksi erupsi atau penetapan status gunung secara mandiri oleh aplikasi.
- Integrasi otomatis dengan laporan resmi atau sensor pemantauan.
- Seismograf live, tekanan gas, suhu, dan dashboard statistik kegempaan terperinci.
- Perhitungan otomatis jalur evakuasi aman dan navigasi belokan demi belokan di dalam aplikasi.
- Pelacakan lokasi pengguna secara terus-menerus.
- Peta offline yang dapat diunduh.
- Web untuk warga, aplikasi iOS, dan evakuasi pendaki.
- Kapasitas posko secara real-time, pelaporan korban, permintaan penyelamatan, dan pengelolaan bantuan pascabencana.
- Pendaftaran mandiri petugas, persetujuan berjenjang, dan panel khusus pengelola akun.
- Pemakaian sebagai sistem peringatan resmi atau operasional sebelum validasi dan koordinasi yang diperlukan.

## 6. Kebutuhan bisnis dan fungsional

Seluruh kebutuhan di bawah menjadi prioritas versi pertama, kecuali yang diberi status usulan. Detail teknis diturunkan pada tahap perancangan.

| ID | Kebutuhan | Hasil yang diharapkan |
|---|---|---|
| BR-01 | Akses informasi tanpa login | Warga dan wisatawan dapat memakai fitur publik tanpa membuat akun |
| BR-02 | Pemilihan gunung dan kawasan | Pengguna dapat memilih konteks yang didukung dan melihat panduan yang sesuai |
| BR-03 | Bantuan lokasi | Setelah izin diberikan, lokasi membantu menyarankan kawasan; pilihan manual tetap tersedia |
| BR-04 | Pemantauan gunung | Pengguna dapat mengaktifkan atau menonaktifkan peringatan untuk gunung pilihannya; pilihan disimpan di perangkat |
| BR-05 | Detail peringatan | Pesan memuat gunung, kawasan sasaran jika relevan, waktu, isi, arahan, penerbit, dan penanda simulasi |
| BR-06 | Notifikasi Android | Peringatan yang diterbitkan dikirim kepada perangkat yang memantau gunung terkait; ketukan membuka detail yang sesuai |
| BR-07 | Panduan tindakan | Pengguna melihat langkah tindakan yang terkait dengan pengumuman atau kawasan |
| BR-08 | Titik kumpul dan posko | Pengguna melihat nama, lokasi, petunjuk, serta status posko yang tersedia |
| BR-09 | Jalur yang disiapkan | Pengguna melihat lintasan, titik awal, titik kontrol, tujuan, status ketersediaan, dan waktu pembaruan |
| BR-10 | Bantuan navigasi eksternal | Pengguna dapat membuka tujuan atau titik kontrol di Google Maps |
| BR-11 | Edukasi | Pengguna dapat membaca materi persiapan dan tindakan dasar yang relevan |
| BR-12 | Checklist | Pengguna dapat menandai perlengkapan kesiagaan; perubahan tersimpan lokal di perangkat |
| BR-13 | Login dan penugasan petugas | Hanya akun petugas yang disiapkan tim dapat mengakses pengelolaan gunung penugasannya |
| BR-14 | Pengelolaan pengumuman | Petugas dapat membuat, meninjau, dan menerbitkan pengumuman untuk gunung penugasannya |
| BR-15 | Pengelolaan kondisi | Petugas dapat memperbarui ringkasan status dengan sumber dan waktu laporan, tanpa kewajiban mengisi statistik pemantauan terperinci |
| BR-16 | Pengelolaan jalur dan posko | Petugas dapat memperbarui informasi serta menutup/membuka jalur dan posko yang dikelolanya |
| BR-17 | Riwayat publikasi | Sistem menyimpan penerbit, waktu, dan isi publikasi agar pembaruan dapat ditelusuri |
| BR-18 | Penandaan simulasi | Informasi operasional dan notifikasi demonstrasi dikenali jelas sebagai simulasi |

Pencarian, bookmark edukasi, tombol berbagi, dan elemen tambahan lain pada desain bukan kebutuhan wajib pada draf ini. Penambahannya memerlukan penetapan kebutuhan tersendiri.

## 7. Aturan bisnis

1. Warga dan wisatawan menggunakan akses publik tanpa login. Petugas wajib login.
2. Hak akses pengelolaan dibatasi pada gunung penugasan petugas dan diperiksa di backend, bukan hanya melalui tampilan.
3. Akun petugas tidak dapat dibuat melalui pendaftaran publik. Penugasan akun tidak dapat diubah sendiri oleh petugas.
4. Petugas dapat menerbitkan setelah melihat pratinjau dan melakukan konfirmasi; tidak ada persetujuan petugas kedua pada versi pertama.
5. Peringatan dikirim berdasarkan gunung yang dipantau pengguna. Jika pengumuman hanya berlaku untuk kawasan tertentu, kawasan sasaran harus disebutkan secara jelas pada pesan.
6. Lokasi perangkat hanya membantu pemilihan konteks. Penolakan izin lokasi tidak menghalangi akses manual.
7. Gunung terdekat atau posko terdekat tidak otomatis menentukan jalur evakuasi. Jalur berasal dari data yang telah disiapkan untuk kawasan.
8. Jalur berstatus ditutup tidak boleh ditampilkan sebagai rekomendasi yang tersedia. Jika tidak ada jalur tersedia, sistem menyatakan kondisi tersebut tanpa membuat rute baru sendiri.
9. Posko tutup tidak boleh ditampilkan sebagai tujuan evakuasi yang tersedia. Dampaknya terhadap jalur terkait harus dijelaskan.
10. Ketika lokasi atau kawasan pengguna tidak didukung, aplikasi menyatakan keterbatasan cakupan dan menawarkan pemilihan kawasan secara manual.
11. Ringkasan kondisi yang merujuk laporan resmi mencantumkan sumber dan waktu laporan. Petugas aplikasi meneruskan informasi, bukan menetapkan status resmi.
12. Nama gunung dan profil dasar dapat memakai data nyata. Data operasional yang belum terverifikasi diberi label simulasi, termasuk pada notifikasi.
13. Rute yang dihasilkan Google Maps tidak boleh disebut sebagai bukti keamanan jalur evakuasi. Lintasan dan titik kontrol yang disiapkan tetap ditampilkan dalam aplikasi.
14. Pembaruan informasi tidak otomatis berarti perintah evakuasi. Jenis pesan dan tindakan yang diminta harus dinyatakan eksplisit.

## 8. Alur utama

### 8.1 Persiapan pengguna

Pengguna membuka aplikasi, memilih gunung dan kawasan secara manual atau menerima saran lokasi, lalu memilih gunung yang ingin dipantau. Pengguna dapat membaca panduan, mengenali titik kumpul, dan mengisi checklist. Saat mengaktifkan peringatan, aplikasi meminta izin notifikasi dan menjelaskan status izinnya.

### 8.2 Penerbitan dan penerimaan peringatan

Petugas login, memilih gunung penugasan, mengisi pengumuman beserta arahan dan kawasan sasaran, lalu meninjau serta mengonfirmasi publikasi. Backend memeriksa kewenangan, menyimpan publikasi, dan memproses pengiriman melalui FCM. Pengguna mengetuk notifikasi untuk membuka detail pesan dan panduan terkait.

Kegagalan pengiriman harus dapat diketahui petugas dan dicoba ulang tanpa menciptakan publikasi baru yang tidak diperlukan. Status pengiriman tidak boleh diartikan sebagai bukti bahwa semua penerima telah membaca pesan.

### 8.3 Penggunaan panduan evakuasi

Pengguna memilih kawasan, membaca arahan, dan melihat jalur yang tersedia menuju titik kumpul atau posko. Detail jalur menampilkan lintasan, titik kontrol, serta waktu pembaruan. Pengguna dapat membuka tujuan atau titik kontrol di Google Maps. Bentuk tautan navigasi dan cara mempertahankan titik kontrol masih perlu ditentukan pada perancangan.

### 8.4 Perubahan kondisi lokal

Petugas memperbarui status jalur atau posko. Aplikasi menampilkan informasi terbaru saat tersinkronisasi. Petugas dapat menerbitkan pengumuman terpisah apabila perubahan perlu diberitahukan kepada pengguna. Tampilan tetap menjelaskan waktu pembaruan agar informasi lama tidak disalahartikan sebagai kondisi terkini.

## 9. Data dan sumber informasi

| Kelompok data | Isi minimum | Pengelolaan |
|---|---|---|
| Gunung | Identitas, nama, koordinat, profil dasar, referensi | Data awal tim |
| Kawasan | Nama, gunung terkait, acuan lokasi, titik kumpul | Data awal tim; cakupan demonstrasi belum dipilih |
| Ringkasan kondisi | Status, ringkasan, sumber, waktu laporan, waktu publikasi, penanda simulasi | Petugas sesuai penugasan |
| Pengumuman | Identitas, gunung, kawasan sasaran, jenis, isi, arahan, penerbit, waktu, penanda simulasi | Petugas sesuai penugasan |
| Jalur | Kawasan, titik awal, lintasan koordinat, titik kontrol, tujuan, ketersediaan, sumber, waktu pembaruan | Tim menyiapkan data awal; petugas mengelola perubahan |
| Posko | Nama, koordinat, deskripsi, status buka/tutup, waktu pembaruan, penanda simulasi | Petugas sesuai penugasan |
| Edukasi | Judul, isi, kategori, sumber | Konten awal tim; editor konten belum masuk cakupan |
| Preferensi perangkat | Gunung/kawasan pilihan, pemantauan notifikasi, checklist | Disimpan pada perangkat; tidak memerlukan identitas warga |
| Petugas | Identitas akun dan penugasan gunung | Konfigurasi administratif tim |

Sumber rujukan kondisi gunung adalah PVMBG/Badan Geologi dan MAGMA Indonesia. Informasi lokal perlu merujuk BPBD atau pemerintah daerah terkait jika dokumennya tersedia. Versi pertama tidak mensyaratkan API resmi, scraping, atau sinkronisasi otomatis.

Jika data jalur atau posko resmi belum diperoleh, data tersebut dibuat untuk simulasi dan tidak dipresentasikan sebagai jalur atau posko resmi. Profil dasar nyata dan skenario simulasi harus dapat dibedakan.

## 10. Kebutuhan nonfungsional

| Area | Kebutuhan |
|---|---|
| Kemudahan penggunaan | Bahasa Indonesia, arahan ringkas, dan akses panduan yang jelas dari detail peringatan |
| Aksesibilitas | Status tidak dibedakan hanya melalui warna; teks dan ikon harus terbaca pada layar Android |
| Keamanan | Akses tulis dibatasi berdasarkan akun dan penugasan; kredensial server tidak disertakan dalam aplikasi atau web |
| Privasi | Tidak meminta login warga atau melacak lokasi terus-menerus; izin lokasi dan notifikasi diminta dengan penjelasan tujuan |
| Kesegaran informasi | Tampilkan waktu laporan/pembaruan; kegagalan sinkronisasi tidak boleh menyatakan informasi sudah terkini |
| Gangguan koneksi | Tampilkan kondisi jaringan dan pilihan mencoba ulang. Penyimpanan konten panduan untuk offline merupakan usulan yang belum disepakati; peta offline di luar cakupan |
| Notifikasi | Diuji saat foreground, background, dan aplikasi tidak berjalan; bergantung pada koneksi, izin, serta kebijakan perangkat |
| Platform | Android untuk pengguna umum; browser desktop untuk panel petugas. Versi OS/browser minimum ditentukan pada tahap teknis |
| Biaya | Batasi pemakaian layanan dan aktifkan pemberitahuan anggaran; seluruh layanan tidak diasumsikan gratis |
| Ketertelusuran | Simpan penerbit dan waktu perubahan penting agar publikasi dapat ditelusuri |

Target numerik performa dan jumlah perangkat pengujian belum ditentukan. Sistem tidak menjanjikan pengiriman notifikasi seketika atau keberhasilan penerimaan pada semua kondisi perangkat.

## 11. Arah solusi teknis

Bagian ini mencatat pilihan teknologi yang telah disepakati dan bukan rancangan implementasi final.

| Komponen | Pilihan |
|---|---|
| Aplikasi warga / wisatawan | Flutter Android |
| Panel petugas | Web; Flutter Web dapat digunakan sesuai keputusan teknis tim |
| Autentikasi petugas | Firebase Authentication |
| Penyimpanan data bersama | Cloud Firestore |
| Pemrosesan publikasi dan pengiriman | Cloud Functions |
| Push notification Android | Firebase Cloud Messaging |
| Hosting panel web | Firebase Hosting |
| Navigasi eksternal | Google Maps melalui Maps URLs |
| Peta dalam aplikasi | Usulan peta berbasis OpenStreetMap; penyedia tile dan pustaka ditentukan kemudian |

Cloud Functions memerlukan paket Firebase Blaze. FCM tersedia tanpa biaya, sedangkan layanan lain mengikuti ketentuan pemakaian dan kuota masing-masing. Pemberitahuan anggaran tidak dianggap sebagai batas pengeluaran otomatis.

Prasyarat demonstrasi notifikasi mencakup perangkat yang mendukung konfigurasi FCM, aplikasi pernah dibuka dan terdaftar, izin notifikasi diberikan jika diperlukan, serta koneksi internet tersedia. Force stop melalui pengaturan Android memerlukan aplikasi dibuka kembali agar penerimaan pesan berjalan kembali. Suara standar mengikuti pengaturan perangkat pengguna.

## 12. Penyesuaian terhadap desain UI awal

Desain pada `docs/design` menjadi referensi visual, bukan daftar fitur yang seluruhnya wajib dibangun. Contoh Merapi pada desain perlu diganti sesuai konteks Sumatera Barat.

| Desain awal | Arah penyesuaian |
|---|---|
| Beranda | Prioritaskan gunung/kawasan pilihan, pengumuman, dan akses tindakan; hilangkan statistik teknis yang tidak diperlukan |
| Kondisi Gunung | Sederhanakan menjadi ringkasan kondisi, sumber, waktu laporan, dan pengumuman; hilangkan seismograf live serta statistik terperinci |
| Peta Bahaya | Fokus pada titik kumpul, posko, dan lintasan demonstrasi; zona bahaya tidak dibuat dari radius rekaan yang diklaim resmi |
| Panduan Evakuasi | Pertahankan arahan, lintasan, titik kontrol, checklist, dan tombol Google Maps; hindari klaim keamanan tanpa sumber |
| Edukasi Siaga | Pertahankan materi dasar; klaim validasi instansi hanya boleh ditampilkan jika ada bukti |
| Panel web petugas | Desain belum tersedia; memerlukan login, daftar gunung penugasan, formulir publikasi, pengelolaan jalur/posko, dan riwayat |

Nomor darurat, kapasitas posko, estimasi waktu perjalanan, serta klaim seperti “bebas lahar” dalam desain belum menjadi data yang terverifikasi atau kebutuhan wajib.

## 13. Kriteria penerimaan utama

| ID | Skenario | Kriteria lulus |
|---|---|---|
| AC-01 | Akses publik | Pengguna dapat melihat panduan tanpa login |
| AC-02 | Izin lokasi ditolak | Pemilihan manual tetap berfungsi dan panduan tersedia |
| AC-03 | Di luar cakupan | Aplikasi menjelaskan kawasan tidak didukung tanpa memberikan rekomendasi lokasi yang tidak sesuai |
| AC-04 | Pembatasan petugas | Percobaan perubahan pada gunung di luar penugasan ditolak oleh backend |
| AC-05 | Publikasi | Pengumuman yang dikonfirmasi tersimpan dengan penerbit, waktu, dan label simulasi serta terlihat oleh pengguna |
| AC-06 | Notifikasi saat aplikasi ditutup | Pada perangkat uji dengan prasyarat terpenuhi dan tanpa force stop, peringatan diterima saat aplikasi tidak terbuka |
| AC-07 | Kesesuaian penerima | Perangkat yang hanya memantau gunung A menerima pesan A; pesan gunung B tidak dikirim kepadanya |
| AC-08 | Membuka notifikasi | Ketukan membuka detail pengumuman yang benar, termasuk setelah aplikasi dijalankan dari keadaan tidak berjalan |
| AC-09 | Jalur ditutup | Jalur tertutup terlihat statusnya dan tidak direkomendasikan sebagai jalur tersedia |
| AC-10 | Tidak ada tujuan tersedia | Aplikasi menyatakan tidak tersedia dan tidak memilih posko tutup atau membuat rute alternatif sendiri |
| AC-11 | Google Maps | Tombol membuka tujuan/titik kontrol yang dipilih; aplikasi tidak menyebut rute eksternal sebagai jaminan keamanan |
| AC-12 | Checklist | Pilihan checklist tetap tersimpan setelah aplikasi dibuka kembali pada perangkat yang sama |
| AC-13 | Penanda simulasi | Pengguna dapat mengenali data operasional demonstrasi dan notifikasi sebagai simulasi |
| AC-14 | Kegagalan jaringan/pengiriman | Sistem menampilkan kegagalan atau status belum terkonfirmasi, menyediakan percobaan ulang, dan tidak memberi kesan pengiriman pasti berhasil |

Kriteria ini merupakan usulan penerimaan draf dan perlu ditinjau bersama tim sebelum ditetapkan sebagai acuan pengujian final.

## 14. Asumsi, risiko, dan ketergantungan

| Hal | Implikasi / penanganan |
|---|---|
| Belum ada wawancara pengguna atau petugas | Kebutuhan dicatat sebagai hipotesis; uji dengan teman kuliah menilai kegunaan prototipe secara terbatas |
| Belum ada jalur dan posko yang tervalidasi | Gunakan data simulasi yang jelas; penggunaan nyata memerlukan validasi lapangan dan pihak berwenang |
| Pembaruan manual bisa menambah beban | Batasi data petugas pada ringkasan dan perubahan lokal; jangan mewajibkan penyalinan statistik harian |
| Internet atau notifikasi bisa terganggu | Jelaskan status koneksi/izin; jangan mengandalkan push sebagai jaminan penerimaan |
| Google Maps dapat memilih lintasan berbeda | Tampilkan lintasan dan titik kontrol aplikasi; tentukan bentuk tautan navigasi pada tahap perancangan |
| Layanan cloud dapat menimbulkan biaya | Gunakan konfigurasi terbatas untuk demonstrasi dan pantau pemakaian |
| Belum ada kerja sama instansi | Akun petugas adalah akun demonstrasi; hindari klaim afiliasi atau validasi resmi |
| Peta membutuhkan penyedia tile | Pilih penyedia dan patuhi atribusi serta ketentuan akses; jangan mengunduh tile publik secara massal untuk offline |

## 15. Keputusan terbuka

1. Kawasan demonstrasi spesifik untuk masing-masing gunung.
2. Nama, koordinat, sumber, dan lintasan simulasi titik kumpul serta posko.
3. Aturan rekomendasi jika sebuah kawasan memiliki beberapa jalur atau tujuan.
4. Model saran lokasi: batas kawasan atau titik acuan dan ambang jarak; jangan hanya memilih gunung terdekat tanpa batas cakupan.
5. Struktur jenis pengumuman, masa berlaku, dan cara mencabut atau mengoreksi pesan yang sudah terbit.
6. Bentuk integrasi Google Maps agar pengguna memahami hubungan tujuan, titik kontrol, dan lintasan aplikasi.
7. Apakah penyimpanan panduan untuk akses offline masuk versi pertama.
8. Penyedia peta, target versi Android/browser, dan ukuran pengujian kegunaan.

Keputusan ini tidak menghalangi penyusunan draf, tetapi harus diselesaikan sebelum implementasi fitur terkait dinyatakan final.

## 16. Referensi

- [Publikasi ESDM mengenai Gunung Marapi](https://esdm.go.id/en/media-center/news-archives/terekam-seismograf-g-marapi-kembali-erupsi-dengan-ketinggian-1500-m).
- [Katalog Badan Geologi mengenai Gunung Talang](https://geologi.esdm.go.id/perpustakaan/?search=Search&subject=%22Foto+Gunung+Talang%22).
- [Katalog Badan Geologi mengenai Gunung Tandikat](https://geologi.esdm.go.id/perpustakaan?search=Search&subject=%22Gunung+Tandikat%22).
- [Profil PVMBG dan MAGMA — Badan Geologi](https://geologi.esdm.go.id/index.php/pvmbg).
- [Penerimaan pesan Flutter — Firebase](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages).
- [Lingkungan server FCM — Firebase](https://firebase.google.com/docs/cloud-messaging/server-environment).
- [Paket harga Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans) dan [rincian harga](https://firebase.google.com/pricing).
- [Maps URLs — Google](https://developers.google.com/maps/documentation/urls/get-started).
- [Kebijakan penggunaan tile OpenStreetMap](https://operations.osmfoundation.org/policies/tiles/).
- Desain lokal: `docs/design/Beranda.png`, `Kondisi Gunung.png`, `Peta Bahaya.png`, `Panduan Evakuasi.png`, dan `Edukasi Siaga.png`.

Referensi digunakan untuk konteks dan batas teknologi. Referensi tersebut tidak memvalidasi jalur atau posko simulasi dan tidak menyatakan status gunung terkini.
