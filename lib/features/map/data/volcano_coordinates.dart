import 'package:latlong2/latlong.dart';
import '../../volcano/data/models/volcano_model.dart';

class VolcanoCoordinate {
  final String name;
  final LatLng latLng;
  final int elevation;
  final String province;

  const VolcanoCoordinate({
    required this.name,
    required this.latLng,
    required this.elevation,
    required this.province,
  });

  double get latitude => latLng.latitude;
  double get longitude => latLng.longitude;
}

class VolcanoCoordinatesData {
  VolcanoCoordinatesData._();

  static const Map<String, VolcanoCoordinate> allCoordinates = {
    'Agung': VolcanoCoordinate(
      name: 'Agung',
      latLng: LatLng(-8.343, 115.508),
      elevation: 3142,
      province: 'Bali',
    ),
    'Ambang': VolcanoCoordinate(
      name: 'Ambang',
      latLng: LatLng(0.75, 124.42),
      elevation: 1795,
      province: 'Sulawesi Utara',
    ),
    'Anak Krakatau': VolcanoCoordinate(
      name: 'Anak Krakatau',
      latLng: LatLng(-6.102, 105.423),
      elevation: 157,
      province: 'Lampung',
    ),
    'Anak Ranakah': VolcanoCoordinate(
      name: 'Anak Ranakah',
      latLng: LatLng(-8.62, 120.52),
      elevation: 2250,
      province: 'Nusa Tenggara Timur',
    ),
    'Arjuno Welirang': VolcanoCoordinate(
      name: 'Arjuno Welirang',
      latLng: LatLng(-7.725, 112.58),
      elevation: 3339,
      province: 'Jawa Timur',
    ),
    'Awu': VolcanoCoordinate(
      name: 'Awu',
      latLng: LatLng(3.67, 125.45),
      elevation: 1320,
      province: 'Sulawesi Utara',
    ),
    'Banda Api': VolcanoCoordinate(
      name: 'Banda Api',
      latLng: LatLng(-4.525, 129.871),
      elevation: 640,
      province: 'Maluku',
    ),
    'Batur': VolcanoCoordinate(
      name: 'Batur',
      latLng: LatLng(-8.242, 115.375),
      elevation: 1717,
      province: 'Bali',
    ),
    'Batutara': VolcanoCoordinate(
      name: 'Batutara',
      latLng: LatLng(-7.792, 123.579),
      elevation: 748,
      province: 'Nusa Tenggara Timur',
    ),
    'Bromo': VolcanoCoordinate(
      name: 'Bromo',
      latLng: LatLng(-7.942, 112.95),
      elevation: 2329,
      province: 'Jawa Timur',
    ),
    'Bur Ni Telong': VolcanoCoordinate(
      name: 'Bur Ni Telong',
      latLng: LatLng(4.77, 96.82),
      elevation: 2600,
      province: 'Aceh',
    ),
    'Ciremai': VolcanoCoordinate(
      name: 'Ciremai',
      latLng: LatLng(-6.892, 108.4),
      elevation: 3078,
      province: 'Jawa Barat',
    ),
    'Colo': VolcanoCoordinate(
      name: 'Colo',
      latLng: LatLng(-0.17, 121.608),
      elevation: 507,
      province: 'Sulawesi Tengah',
    ),
    'Dempo': VolcanoCoordinate(
      name: 'Dempo',
      latLng: LatLng(-4.03, 103.13),
      elevation: 3173,
      province: 'Sumatera Selatan',
    ),
    'Dieng': VolcanoCoordinate(
      name: 'Dieng',
      latLng: LatLng(-7.2, 109.92),
      elevation: 2565,
      province: 'Jawa Tengah',
    ),
    'Dukono': VolcanoCoordinate(
      name: 'Dukono',
      latLng: LatLng(1.693, 127.894),
      elevation: 1335,
      province: 'Maluku Utara',
    ),
    'Ebulobo': VolcanoCoordinate(
      name: 'Ebulobo',
      latLng: LatLng(-8.823, 121.19),
      elevation: 2124,
      province: 'Nusa Tenggara Timur',
    ),
    'Egon': VolcanoCoordinate(
      name: 'Egon',
      latLng: LatLng(-8.67, 122.45),
      elevation: 1703,
      province: 'Nusa Tenggara Timur',
    ),
    'Galunggung': VolcanoCoordinate(
      name: 'Galunggung',
      latLng: LatLng(-7.25, 108.058),
      elevation: 2168,
      province: 'Jawa Barat',
    ),
    'Gamalama': VolcanoCoordinate(
      name: 'Gamalama',
      latLng: LatLng(0.8, 127.33),
      elevation: 1715,
      province: 'Maluku Utara',
    ),
    'Gamkonora': VolcanoCoordinate(
      name: 'Gamkonora',
      latLng: LatLng(1.38, 127.53),
      elevation: 1635,
      province: 'Maluku Utara',
    ),
    'Gede': VolcanoCoordinate(
      name: 'Gede',
      latLng: LatLng(-6.78, 106.98),
      elevation: 2958,
      province: 'Jawa Barat',
    ),
    'Guntur': VolcanoCoordinate(
      name: 'Guntur',
      latLng: LatLng(-7.143, 107.84),
      elevation: 2249,
      province: 'Jawa Barat',
    ),
    'Hobal': VolcanoCoordinate(
      name: 'Hobal',
      latLng: LatLng(-8.37, 123.58),
      elevation: 0,
      province: 'Nusa Tenggara Timur',
    ),
    'Ibu': VolcanoCoordinate(
      name: 'Ibu',
      latLng: LatLng(1.488, 127.63),
      elevation: 1325,
      province: 'Maluku Utara',
    ),
    'Ijen': VolcanoCoordinate(
      name: 'Ijen',
      latLng: LatLng(-8.058, 114.242),
      elevation: 2386,
      province: 'Jawa Timur',
    ),
    'Ile Werung': VolcanoCoordinate(
      name: 'Ile Werung',
      latLng: LatLng(-8.53, 123.57),
      elevation: 1018,
      province: 'Nusa Tenggara Timur',
    ),
    'Ili Boleng': VolcanoCoordinate(
      name: 'Ili Boleng',
      latLng: LatLng(-8.342, 123.255),
      elevation: 1659,
      province: 'Nusa Tenggara Timur',
    ),
    'Ili Lewotolok': VolcanoCoordinate(
      name: 'Ili Lewotolok',
      latLng: LatLng(-8.272, 123.505),
      elevation: 1423,
      province: 'Nusa Tenggara Timur',
    ),
    'Inielika': VolcanoCoordinate(
      name: 'Inielika',
      latLng: LatLng(-8.73, 120.98),
      elevation: 1559,
      province: 'Nusa Tenggara Timur',
    ),
    'Inierie': VolcanoCoordinate(
      name: 'Inierie',
      latLng: LatLng(-8.875, 120.95),
      elevation: 2245,
      province: 'Nusa Tenggara Timur',
    ),
    'Iya': VolcanoCoordinate(
      name: 'Iya',
      latLng: LatLng(-8.897, 121.645),
      elevation: 637,
      province: 'Nusa Tenggara Timur',
    ),
    'Kaba': VolcanoCoordinate(
      name: 'Kaba',
      latLng: LatLng(-3.52, 102.62),
      elevation: 1952,
      province: 'Bengkulu',
    ),
    'Karangetang': VolcanoCoordinate(
      name: 'Karangetang',
      latLng: LatLng(2.78, 125.4),
      elevation: 1784,
      province: 'Sulawesi Utara',
    ),
    'Kelimutu': VolcanoCoordinate(
      name: 'Kelimutu',
      latLng: LatLng(-8.77, 121.82),
      elevation: 1639,
      province: 'Nusa Tenggara Timur',
    ),
    'Kelud': VolcanoCoordinate(
      name: 'Kelud',
      latLng: LatLng(-7.93, 112.308),
      elevation: 1731,
      province: 'Jawa Timur',
    ),
    'Kerinci': VolcanoCoordinate(
      name: 'Kerinci',
      latLng: LatLng(-1.697, 101.264),
      elevation: 3805,
      province: 'Jambi, Sumatera Barat',
    ),
    'Kie Besi': VolcanoCoordinate(
      name: 'Kie Besi',
      latLng: LatLng(0.32, 127.4),
      elevation: 1357,
      province: 'Maluku Utara',
    ),
    'Lamongan': VolcanoCoordinate(
      name: 'Lamongan',
      latLng: LatLng(-7.979, 113.342),
      elevation: 1651,
      province: 'Jawa Timur',
    ),
    'Lereboleng': VolcanoCoordinate(
      name: 'Lereboleng',
      latLng: LatLng(-8.36, 122.84),
      elevation: 1117,
      province: 'Nusa Tenggara Timur',
    ),
    'Lewotobi Laki-laki': VolcanoCoordinate(
      name: 'Lewotobi Laki-laki',
      latLng: LatLng(-8.538, 122.775),
      elevation: 1584,
      province: 'Nusa Tenggara Timur',
    ),
    'Lewotobi Perempuan': VolcanoCoordinate(
      name: 'Lewotobi Perempuan',
      latLng: LatLng(-8.553, 122.785),
      elevation: 1703,
      province: 'Nusa Tenggara Timur',
    ),
    'Lokon': VolcanoCoordinate(
      name: 'Lokon',
      latLng: LatLng(1.358, 124.792),
      elevation: 1580,
      province: 'Sulawesi Utara',
    ),
    'Mahawu': VolcanoCoordinate(
      name: 'Mahawu',
      latLng: LatLng(1.35, 124.86),
      elevation: 1311,
      province: 'Sulawesi Utara',
    ),
    'Marapi': VolcanoCoordinate(
      name: 'Marapi',
      latLng: LatLng(-0.381, 100.473),
      elevation: 2891,
      province: 'Sumatera Barat',
    ),
    'Merapi': VolcanoCoordinate(
      name: 'Merapi',
      latLng: LatLng(-7.54, 110.446),
      elevation: 2968,
      province: 'Daerah Istimewa Yogyakarta dan Jawa Tengah',
    ),
    'Papandayan': VolcanoCoordinate(
      name: 'Papandayan',
      latLng: LatLng(-7.32, 107.73),
      elevation: 2665,
      province: 'Jawa Barat',
    ),
    'Peut Sague': VolcanoCoordinate(
      name: 'Peut Sague',
      latLng: LatLng(4.914, 96.329),
      elevation: 2801,
      province: 'Aceh',
    ),
    'Raung': VolcanoCoordinate(
      name: 'Raung',
      latLng: LatLng(-8.125, 114.056),
      elevation: 3332,
      province: 'Jawa Timur',
    ),
    'Rinjani': VolcanoCoordinate(
      name: 'Rinjani',
      latLng: LatLng(-8.42, 116.47),
      elevation: 3726,
      province: 'Nusa Tenggara Barat',
    ),
    'Rokatenda': VolcanoCoordinate(
      name: 'Rokatenda',
      latLng: LatLng(-8.32, 121.708),
      elevation: 875,
      province: 'Nusa Tenggara Timur',
    ),
    'Ruang': VolcanoCoordinate(
      name: 'Ruang',
      latLng: LatLng(2.30, 125.37),
      elevation: 725,
      province: 'Sulawesi Utara',
    ),
    'Salak': VolcanoCoordinate(
      name: 'Salak',
      latLng: LatLng(-6.72, 106.73),
      elevation: 2211,
      province: 'Jawa Barat',
    ),
    'Sangeangapi': VolcanoCoordinate(
      name: 'Sangeangapi',
      latLng: LatLng(-8.2, 119.07),
      elevation: 1949,
      province: 'Nusa Tenggara Barat',
    ),
    'Semeru': VolcanoCoordinate(
      name: 'Semeru',
      latLng: LatLng(-8.108, 112.922),
      elevation: 3676,
      province: 'Jawa Timur',
    ),
    'Seulawah Agam': VolcanoCoordinate(
      name: 'Seulawah Agam',
      latLng: LatLng(5.448, 95.658),
      elevation: 1810,
      province: 'Aceh',
    ),
    'Sinabung': VolcanoCoordinate(
      name: 'Sinabung',
      latLng: LatLng(3.17, 98.392),
      elevation: 2460,
      province: 'Sumatera Utara',
    ),
    'Sirung': VolcanoCoordinate(
      name: 'Sirung',
      latLng: LatLng(-8.508, 124.13),
      elevation: 862,
      province: 'Nusa Tenggara Timur',
    ),
    'Slamet': VolcanoCoordinate(
      name: 'Slamet',
      latLng: LatLng(-7.242, 109.208),
      elevation: 3428,
      province: 'Jawa Tengah',
    ),
    'Soputan': VolcanoCoordinate(
      name: 'Soputan',
      latLng: LatLng(1.108, 124.73),
      elevation: 1785,
      province: 'Sulawesi Utara',
    ),
    'Sorikmarapi': VolcanoCoordinate(
      name: 'Sorikmarapi',
      latLng: LatLng(0.686, 99.622),
      elevation: 2145,
      province: 'Sumatera Utara',
    ),
    'Sumbing': VolcanoCoordinate(
      name: 'Sumbing',
      latLng: LatLng(-7.384, 110.07),
      elevation: 3371,
      province: 'Jawa Tengah',
    ),
    'Sundoro': VolcanoCoordinate(
      name: 'Sundoro',
      latLng: LatLng(-7.3, 109.992),
      elevation: 3136,
      province: 'Jawa Tengah',
    ),
    'Talang': VolcanoCoordinate(
      name: 'Talang',
      latLng: LatLng(-0.978, 100.679),
      elevation: 2597,
      province: 'Sumatera Barat',
    ),
    'Tambora': VolcanoCoordinate(
      name: 'Tambora',
      latLng: LatLng(-8.25, 117.97),
      elevation: 2850,
      province: 'Nusa Tenggara Barat',
    ),
    'Tandikat': VolcanoCoordinate(
      name: 'Tandikat',
      latLng: LatLng(-0.433, 100.317),
      elevation: 2438,
      province: 'Sumatera Barat',
    ),
    'Tangkoko': VolcanoCoordinate(
      name: 'Tangkoko',
      latLng: LatLng(1.52, 125.20),
      elevation: 1149,
      province: 'Sulawesi Utara',
    ),
    'Tangkuban Parahu': VolcanoCoordinate(
      name: 'Tangkuban Parahu',
      latLng: LatLng(-6.77, 107.60),
      elevation: 2084,
      province: 'Jawa Barat',
    ),
    'Wurlali': VolcanoCoordinate(
      name: 'Wurlali',
      latLng: LatLng(-7.125, 128.675),
      elevation: 868,
      province: 'Maluku',
    ),
  };

  /// Mendapatkan koordinat gunung api berdasarkan nama, atau perkiraan berdasarkan lokasi/wilayah jika nama belum tercatat.
  static VolcanoCoordinate getCoordinate(String name, {String? location}) {
    final direct = allCoordinates[name];
    if (direct != null) return direct;

    // Normalisasi pencarian nama (case-insensitive & trim)
    final cleanName = name.trim().toLowerCase();
    for (final entry in allCoordinates.entries) {
      if (entry.key.toLowerCase() == cleanName) {
        return entry.value;
      }
    }

    // Fallback berdasarkan region lokasi
    final region = VolcanoRegion.fromLocation(location);
    final fallbackLatLng = regionCentroids[region] ?? const LatLng(-2.5, 118.0);

    return VolcanoCoordinate(
      name: name,
      latLng: fallbackLatLng,
      elevation: 1500,
      province: location ?? region.label,
    );
  }

  /// Titik pusat kamera dan level zoom rekomendasi untuk setiap wilayah di Indonesia
  static const Map<VolcanoRegion, LatLng> regionCentroids = {
    VolcanoRegion.all: LatLng(-2.5, 118.0),
    VolcanoRegion.sumatera: LatLng(-0.5, 101.5),
    VolcanoRegion.jawa: LatLng(-7.5, 110.5),
    VolcanoRegion.baliNusaTenggara: LatLng(-8.5, 120.5),
    VolcanoRegion.sulawesi: LatLng(1.2, 124.5),
    VolcanoRegion.maluku: LatLng(0.5, 128.0),
  };

  static const Map<VolcanoRegion, double> regionZoomLevels = {
    VolcanoRegion.all: 4.8,
    VolcanoRegion.sumatera: 6.2,
    VolcanoRegion.jawa: 7.2,
    VolcanoRegion.baliNusaTenggara: 6.8,
    VolcanoRegion.sulawesi: 6.5,
    VolcanoRegion.maluku: 6.2,
  };
}
