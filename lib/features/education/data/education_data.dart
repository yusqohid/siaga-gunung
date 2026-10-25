class EducationTopic {
  final String id;
  final String title;
  final String category; // 'Tingkat Aktivitas', 'Panduan Evakuasi', 'Protokol Abu', 'Kesiapsiagaan'
  final String summary;
  final String readTimeMinutes;
  final List<String> bulletPoints;
  final String fullContent;
  final String officialSource;

  const EducationTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.readTimeMinutes,
    required this.bulletPoints,
    required this.fullContent,
    required this.officialSource,
  });
}

class EducationData {
  static const List<EducationTopic> topics = [
    EducationTopic(
      id: 'ed-01',
      title: 'Memahami 4 Tingkatan Aktivitas Gunung Api',
      category: 'Tingkat Aktivitas',
      summary: 'Penjelasan resmi makna Level I (Normal) hingga Level IV (Awas) menurut standar PVMBG.',
      readTimeMinutes: '4 mnt',
      officialSource: 'Badan Geologi / PVMBG Kementerian ESDM',
      bulletPoints: [
        'Level I (Normal): Aktivitas visual dan seismik dasar, tidak ada letusan dalam waktu dekat.',
        'Level II (Waspada): Peningkatan aktivitas seismik dan visual di atas level dasar. Aktivitas magma mulai terpantau.',
        'Level III (Siaga): Peningkatan seismik intensif, erupsi mungkin terjadi dalam waktu dekat. Radius bahaya mulai dikosongkan.',
        'Level IV (Awas): Erupsi utama sedang berlangsung atau ancaman bahaya letusan segera terjadi. Warga di zona bahaya wajib evakuasi.',
      ],
      fullContent: '''
Pusat Vulkanologi dan Mitigasi Bencana Geologi (PVMBG) mengklasifikasikan tingkat aktivitas gunung api di Indonesia ke dalam 4 tingkatan:

1. LEVEL I — NORMAL (Hijau)
Berdasarkan hasil pengamatan visual dan instrumental, fluktuasi aktivitas gunung api tidak memperlihatkan peningkatan yang signifikan. Kondisi dasar aman namun masyarakat tetap diimbau tidak mendekati bibir kawah aktif.

2. LEVEL II — WASPADA (Kuning)
Terdapat peningkatan aktivitas seismik dan manifestasi visual di sekitar kawah. Potensi ancaman bahaya erupsi dapat berkembang namun masih terlokalisir di sekitar kawah/puncak.

3. LEVEL III — SIAGA (Jingga / Oranye)
Terjadi peningkatan aktivitas yang sangat nyata secara visual dan seismik. Peningkatan tekanan gas dan migrasi magma berpotensi memicu erupsi besar. Rekomendasi pembatasan radius bahaya diperluas, dan persiapan evakuasi mulai dilakukan oleh BPBD dan warga sekitar.

4. LEVEL IV — AWAS (Merah)
Tingkat tertinggi di mana letusan eksplosif/efusif utama sedang berlangsung atau akan segera terjadi dalam hitungan jam. Kawasan Rawan Bencana (KRB) harus segera disterilkan dan instruksi evakuasi mutlak dipatuhi.
''',
    ),
    EducationTopic(
      id: 'ed-02',
      title: 'Mengenal Ragam Bahaya Erupsi Gunung Api',
      category: 'Kesiapsiagaan',
      summary: 'Memahami ancaman Awan Panas Guguran (APG), lahar hujan, jatuhan abu vulkanik, dan gas beracun.',
      readTimeMinutes: '5 mnt',
      officialSource: 'BNPB & PVMBG Pedoman Mitigasi Bencana',
      bulletPoints: [
        'Awan Panas Guguran (APG): Aliran piroklastik bertemperatur 200°C - 800°C dengan kecepatan ratusan km/jam.',
        'Lahar Dingin / Hujan: Aliran material vulkanik melalui sungai ketika puncak diguyur hujan lebat.',
        'Hujan Abu Vulkanik: Partikel silika tajam yang dapat merusak saluran pernapasan dan membebani atap.',
        'Gas Beracun: CO, CO2, SO2, H2S yang dapat keluar dari solfatara/fumarol tanpa bau mencolok.',
      ],
      fullContent: '''
Erupsi gunung api membawa berbagai macam bahaya primer dan sekunder:

• Awan Panas Guguran (Wedhus Gembel)
Merupakan bahaya paling mematikan. Campuran batuan pijar, gas panas, dan abu meluncur menyusuri lembah sungai dengan kecepatan mencapai lebih dari 100 km/jam. Tidak ada manusia yang dapat bertahan hidup di jalur langsung awan panas.

• Lahar Hujan / Sekunder
Timbunan material pasir dan batu di lereng gunung api yang terdorong oleh air hujan lebat ke daerah hilir sungai. Dapat merusak jembatan, tanggul, dan permukiman bantaran sungai.

• Hujan Abu dan Pasir
Dapat menyebar puluhan hingga ratusan kilometer terbawa angin. Mengakibatkan gangguan pernapasan, iritasi mata, rusaknya vegetasi pertanian, hingga runtuhnya atap bangunan akibat akumulasi beban abu basah.
''',
    ),
    EducationTopic(
      id: 'ed-03',
      title: 'Protokol Menghadapi Hujan Abu & Gas Vulkanik',
      category: 'Protokol Abu',
      summary: 'Langkah melindungi diri dari partikel silika tajam dan menjaga pasokan air bersih keluarga.',
      readTimeMinutes: '4 mnt',
      officialSource: 'Kementerian Kesehatan RI & PVMBG',
      bulletPoints: [
        'Gunakan masker N95, KN95, atau kain berlapis yang dibasahi sedikit air.',
        'Gunakan kacamata pelindung (goggles), hindari memakai lensa kontak (softlens).',
        'Tutup semua tandon air bersih rumah tangga rapat-rapat.',
        'Kenakan pakaian lengan panjang dan celana panjang untuk melindungi kulit.',
      ],
      fullContent: '''
Abu vulkanik bukanlah abu pembakaran biasa, melainkan pecahan kaca silika dan batuan mikroskopis yang bergerigi runcing.

Tindakan Pencegahan:
1. Perlindungan Saluran Napas: Segera gunakan masker berpartikel tinggi (N95/KN95). Jika darurat, gunakan masker bedah atau kain basah.
2. Perlindungan Mata: Abu vulkanik bersifat abrasif. Jangan pernah mengucek mata. Bilas dengan air bersih mengalir jika kelilipan.
3. Air Bersih: Segera tutup semua bak mandi, tandon air, dan sumur terbuka. Air yang tercemar abu vulkanik tidak boleh diminum sebelum disaring dan diuji.
4. Di Dalam Ruangan: Tutup semua ventilasi, jendela, dan celah pintu dengan kain lembap untuk meminimalkan abu masuk ke dalam hunian.
''',
    ),
    EducationTopic(
      id: 'ed-04',
      title: 'Persiapan Sebelum Kejadian (Prabencana)',
      category: 'Panduan Evakuasi',
      summary: 'Kesiapsiagaan mandiri keluarga, identifikasi titik kumpul, dan pengenalan rute aman.',
      readTimeMinutes: '5 mnt',
      officialSource: 'BNPB Buku Saku Tanggap Tangkas Tangguh Menghadapi Bencana',
      bulletPoints: [
        'Kenali zona tinggal Anda: apakah termasuk KRB I, KRB II, atau KRB III.',
        'Ketahui lokasi Tempat Evakuasi Akhir (TEA) dan posko siaga desa terdekat.',
        'Siapkan Tas Siaga Bencana (TSB) keluarga di dekat pintu keluar utama.',
        'Sepakati rencana komunikasi darurat keluarga jika terpisah saat evakuasi.',
      ],
      fullContent: '''
Kunci keselamatan bencana gunung api adalah kesiapan sebelum krisis terjadi:

1. Mengenal Kawasan Rawan Bencana (KRB)
Pahami di mana posisi rumah atau tempat kerja Anda terhadap peta rekomendasi resmi PVMBG. Warga di KRB III harus siap evakuasi paling pertama saat status naik ke Level III/IV.

2. Identifikasi Jalur dan Titik Evakuasi
Pelajari jalur evakuasi resmi yang dipasang oleh BPBD. Hindari merencanakan rute yang memotong alur sungai aktif yang berhulu di kawah.

3. Tas Siaga Bencana (TSB)
Pastikan setiap anggota keluarga memiliki tas ransel kedap air berisi perlengkapan bertahan 3 hari (72 jam). Letakkan di lokasi yang mudah diraih saat gelap atau panik.
''',
    ),
    EducationTopic(
      id: 'ed-05',
      title: 'Tindakan Saat Terjadi Erupsi & Hujan Abu',
      category: 'Panduan Evakuasi',
      summary: 'Instruksi kritis ketika sirene atau instruksi evakuasi otoritas berbunyi.',
      readTimeMinutes: '4 mnt',
      officialSource: 'BNPB & Badan Geologi ESDM',
      bulletPoints: [
        'Segera tinggalkan zona bahaya sesuai rekomendasi radius resmi.',
        'Jauhi lembah sungai yang berhulu di kawah puncak.',
        'Tetap tenang, dampingi lansia, anak-anak, dan kelompok rentan terlebih dahulu.',
        'Pantau informasi resmi melalui radio komunitas, BPBD, atau aplikasi MAGMA/SiagaGunung.',
      ],
      fullContent: '''
Saat status dinaikkan atau letusan eksplosif terjadi:

1. Patuhi Instruksi Evakuasi: Jangan menunda kepindahan demi menjaga harta benda. Nyawa adalah prioritas mutlak.
2. Menghindari Aliran Lembah: Jangan pernah berlindung di dekat jurang atau lembah sungai tempat lewatnya lahar dan awan panas.
3. Mengemudi Saat Hujan Abu: Nyalakan lampu utama kendaraan, kurangi kecepatan, dan jaga jarak aman karena jalanan menjadi sangat licin dan jarak pandang terbatas.
4. Matikan Aliran Listrik dan Gas: Sebelum meninggalkan rumah, putuskan saklar utama listrik dan lepas regulator tabung gas.
''',
    ),
    EducationTopic(
      id: 'ed-06',
      title: 'Tindakan Pascaerupsi (Setelah Kejadian)',
      category: 'Kesiapsiagaan',
      summary: 'Langkah aman kembali ke hunian, bahaya lahar susulan, dan pembersihan endapan abu.',
      readTimeMinutes: '4 mnt',
      officialSource: 'BNPB & BPBD',
      bulletPoints: [
        'Hanya kembali ke rumah jika otoritas resmi menyatakan situasi telah aman.',
        'Bersihkan tumpukan abu tebal di atap rumah sebelum hujan turun (mencegah atap roboh).',
        'Waspadai ancaman banjir lahar hujan di sepanjang bantaran sungai.',
        'Gunakan selalu sepatu bot dan sarung tangan saat membersihkan puing atau abu.',
      ],
      fullContent: '''
Tahapan aman setelah erupsi mereda:

1. Jangan Terburu-buru Pulang: Zona kawah mungkin masih menyimpan energi untuk letusan sekunder atau erupsi freatik susulan. Tunggu pengumuman resmi BPBD.
2. Pembersihan Atap: Abu vulkanik kering memiliki massa jenis tinggi, dan bila terkena air hujan massanya berlipat ganda hingga dapat merobohkan struktur atap. Bersihkan atap dengan hati-hati menggunakan pelindung diri.
3. Bahaya Lahar Dingin Musim Hujan: Meskipun erupsi puncak mereda, ancaman lahar hujan masih dapat bertahan berbulan-bulan selama musim penghujan.
''',
    ),
    EducationTopic(
      id: 'ed-07',
      title: 'Panduan Tas Siaga Bencana (TSB) 72 Jam',
      category: 'Kesiapsiagaan',
      summary: 'Daftar 9 perlengkapan mandiri wajib untuk bertahan hidup minimal 3 hari di pengungsian.',
      readTimeMinutes: '3 mnt',
      officialSource: 'BNPB Pedoman Tas Siaga Bencana Mandiri',
      bulletPoints: [
        'Dokumen penting dalam kantong plastik kedap air (KTP, KK, Ijazah, Surat Tanah).',
        'Air minum minimal 1,5 liter per orang per hari dan makanan kering tahan basi.',
        'Kotak P3K, obat-obatan rutin pribadi, dan cairan antiseptik.',
        'Senter LED, peluit darurat, powerbank terisi penuh, dan masker N95 cadangan.',
      ],
      fullContent: '''
Tas Siaga Bencana (TSB) adalah ransel siap bawa yang dirancang untuk mendukung kebutuhan pokok Anda dan keluarga selama 72 jam pertama setelah bencana sebelum bantuan logistik terkoordinasi penuh.

Barang-Barang Wajib:
1. Dokumen Berharga: Salinan identitas diri, buku tabungan, akta lahir, asuransi dalam wadah plastik ziplock kedap air.
2. P3K & Obat Khusus: Perban, obat merah, obat diare, pereda nyeri, dan obat resep penyakit kronis (diabetes, hipertensi).
3. Air Minum & Pangan Darurat: Biskuit kalori tinggi, makanan kaleng berpembuka praktis, air mineral bersih.
4. Alat Komunikasi & Penerangan: Senter tahan air, baterai cadangan, peluit pemanggil bantuan, powerbank berkapasitas besar.
5. Pakaian Siaga: Baju ganti, jas hujan plastik, jaket hangat, selimut darurat foil.
6. Sanitasi: Sabun cair, tisu basah, pembalut wanita, kantong sampah plastik.
''',
    ),
  ];
}
