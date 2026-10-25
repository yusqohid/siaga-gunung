class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final String category;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });
}

class ChecklistData {
  static const List<ChecklistItem> defaultItems = [
    // Dokumen Penting
    ChecklistItem(
      id: 'doc-01',
      title: 'Dokumen Identitas & Berharga',
      description: 'KTP, Kartu Keluarga, Akta Lahir, Surat Tanah, Buku Tabungan dalam plastik ziplock kedap air.',
      category: 'Dokumen Penting',
    ),
    ChecklistItem(
      id: 'doc-02',
      title: 'Uang Tunai Secukupnya',
      description: 'Pecahan kecil untuk transaksi darurat jika jaringan ATM/listrik padam.',
      category: 'Dokumen Penting',
    ),

    // Pelindung Diri & Pakaian
    ChecklistItem(
      id: 'gear-01',
      title: 'Masker Partikel N95 / KN95',
      description: 'Minimal 3 buah per orang untuk menyaring partikel abu vulkanik tajam.',
      category: 'Pelindung Diri',
    ),
    ChecklistItem(
      id: 'gear-02',
      title: 'Kacamata Pelindung (Goggles)',
      description: 'Melindungi kornea mata dari iritasi abrasi abu silika.',
      category: 'Pelindung Diri',
    ),
    ChecklistItem(
      id: 'gear-03',
      title: 'Pakaian Hangat & Jas Hujan',
      description: 'Jaket, celana panjang, baju ganti untuk 3 hari, dan jas hujan plastik.',
      category: 'Pelindung Diri',
    ),

    // P3K & Obat-obatan
    ChecklistItem(
      id: 'med-01',
      title: 'Kotak P3K Standar',
      description: 'Kasa steril, plester, perban elastis, antiseptik, dan gunting kecil.',
      category: 'P3K & Obat',
    ),
    ChecklistItem(
      id: 'med-02',
      title: 'Obat Pribadi Rutin',
      description: 'Stok obat hipertensi, asma, diabetes, atau alergi untuk kebutuhan 7 hari.',
      category: 'P3K & Obat',
    ),

    // Logistik & Konsumsi
    ChecklistItem(
      id: 'food-01',
      title: 'Air Minum Bersih (Min. 1.5L/orang)',
      description: 'Bekal air mineral tertutup rapat untuk mencegah dehidrasi.',
      category: 'Logistik',
    ),
    ChecklistItem(
      id: 'food-02',
      title: 'Makanan Siap Santap / Makanan Kaleng',
      description: 'Biskuit tinggi kalori, roti kering, atau makanan instan tahan lama.',
      category: 'Logistik',
    ),

    // Alat Bantu Darurat
    ChecklistItem(
      id: 'tool-01',
      title: 'Senter LED & Baterai Cadangan',
      description: 'Sumber penerangan utama saat jaringan listrik diputus posko darurat.',
      category: 'Peralatan Darurat',
    ),
    ChecklistItem(
      id: 'tool-02',
      title: 'Peluit Darurat',
      description: 'Alat penanda suara hemat tenaga untuk memanggil tim SAR atau relawan.',
      category: 'Peralatan Darurat',
    ),
    ChecklistItem(
      id: 'tool-03',
      title: 'Powerbank Terisi Penuh & Kabel',
      description: 'Untuk memastikan ponsel tetap aktif memantau informasi dan berkomunikasi.',
      category: 'Peralatan Darurat',
    ),
  ];
}
