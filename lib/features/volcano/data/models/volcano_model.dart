import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum ActivityLevel {
  levelIV('IV', 'Level IV', 'Awas'),
  levelIII('III', 'Level III', 'Siaga'),
  levelII('II', 'Level II', 'Waspada'),
  levelI('I', 'Level I', 'Normal');

  final String code;
  final String title;
  final String label;

  const ActivityLevel(this.code, this.title, this.label);

  static ActivityLevel fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'IV':
        return ActivityLevel.levelIV;
      case 'III':
        return ActivityLevel.levelIII;
      case 'II':
        return ActivityLevel.levelII;
      case 'I':
        return ActivityLevel.levelI;
      default:
        throw FormatException('Tingkat aktivitas tidak dikenal: $val');
    }
  }

  Color get color {
    switch (this) {
      case ActivityLevel.levelIV:
        return AppColors.levelIV;
      case ActivityLevel.levelIII:
        return AppColors.levelIII;
      case ActivityLevel.levelII:
        return AppColors.levelII;
      case ActivityLevel.levelI:
        return AppColors.levelI;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ActivityLevel.levelIV:
        return AppColors.levelIVBg;
      case ActivityLevel.levelIII:
        return AppColors.levelIIIBg;
      case ActivityLevel.levelII:
        return AppColors.levelIIBg;
      case ActivityLevel.levelI:
        return AppColors.levelIBg;
    }
  }

  int get sortOrder {
    switch (this) {
      case ActivityLevel.levelIV:
        return 0;
      case ActivityLevel.levelIII:
        return 1;
      case ActivityLevel.levelII:
        return 2;
      case ActivityLevel.levelI:
        return 3;
    }
  }
}

enum VolcanoRegion {
  all('all', 'Semua Wilayah'),
  sumatera('sumatera', 'Sumatera'),
  jawa('jawa', 'Jawa'),
  baliNusaTenggara('bali_nusa_tenggara', 'Bali & Nusa Tenggara'),
  sulawesi('sulawesi', 'Sulawesi'),
  maluku('maluku', 'Maluku');

  final String id;
  final String label;

  const VolcanoRegion(this.id, this.label);

  static VolcanoRegion fromLocation(String? location) {
    if (location == null) return VolcanoRegion.all;
    final loc = location.toLowerCase();
    if (loc.contains('aceh') ||
        loc.contains('sumatera') ||
        loc.contains('bengkulu') ||
        loc.contains('jambi') ||
        loc.contains('lampung')) {
      return VolcanoRegion.sumatera;
    }
    if (loc.contains('jawa') || loc.contains('yogyakarta')) {
      return VolcanoRegion.jawa;
    }
    if (loc.contains('bali') || loc.contains('nusa tenggara')) {
      return VolcanoRegion.baliNusaTenggara;
    }
    if (loc.contains('sulawesi')) {
      return VolcanoRegion.sulawesi;
    }
    if (loc.contains('maluku')) {
      return VolcanoRegion.maluku;
    }
    return VolcanoRegion.all;
  }
}

class VolcanoSummary {
  final String id;
  final String name;
  final ActivityLevel activityLevel;
  final String levelLabel;
  final String? location;
  final String? sourceUrl;
  final String? reportTime;
  final DateTime fetchedAt;

  const VolcanoSummary({
    required this.id,
    required this.name,
    required this.activityLevel,
    required this.levelLabel,
    this.location,
    this.sourceUrl,
    this.reportTime,
    required this.fetchedAt,
  });

  VolcanoRegion get region => VolcanoRegion.fromLocation(location);

  factory VolcanoSummary.fromJson(Map<String, dynamic> json) {
    return VolcanoSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      activityLevel: ActivityLevel.fromString(json['activity_level'] as String?),
      levelLabel: json['level_label'] as String? ?? 'Normal',
      location: json['location'] as String?,
      sourceUrl: json['source_url'] as String?,
      reportTime: json['report_time'] as String?,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );
  }
}

class VolcanoListResponse {
  final List<VolcanoSummary> volcanoes;
  final int totalCount;
  final Map<String, int> byLevel;
  final DateTime fetchedAt;
  final bool isStale;
  final DateTime? lastSuccessfulFetch;
  final String? warningMessage;
  final String sourceDisclaimer;

  const VolcanoListResponse({
    required this.volcanoes,
    required this.totalCount,
    required this.byLevel,
    required this.fetchedAt,
    required this.isStale,
    this.lastSuccessfulFetch,
    this.warningMessage,
    required this.sourceDisclaimer,
  });

  factory VolcanoListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['volcanoes'] as List<dynamic>?)
            ?.map((e) => VolcanoSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final byLevelMap = <String, int>{
      'IV': 0,
      'III': 0,
      'II': 0,
      'I': 0,
    };
    if (json['by_level'] != null) {
      (json['by_level'] as Map<String, dynamic>).forEach((key, val) {
        byLevelMap[key] = (val as num).toInt();
      });
    }

    return VolcanoListResponse(
      volcanoes: list,
      totalCount: (json['total_count'] as num?)?.toInt() ?? list.length,
      byLevel: byLevelMap,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      isStale: json['is_stale'] as bool? ?? false,
      lastSuccessfulFetch: json['last_successful_fetch'] != null
          ? DateTime.parse(json['last_successful_fetch'] as String)
          : null,
      warningMessage: json['warning_message'] as String?,
      sourceDisclaimer: json['source_disclaimer'] as String? ?? '',
    );
  }
}

class VolcanoDetail {
  final String id;
  final String name;
  final ActivityLevel activityLevel;
  final String levelLabel;
  final String? location;
  final String? sourceUrl;
  final String? reportPeriod;
  final bool reportTimeAvailable;
  final String? author;
  final String? imageUrl;
  final String? visualObservation;
  final String? climatology;
  final String? seismicObservation;
  final String? recommendation;
  final String? otherDescription;
  final DateTime fetchedAt;

  const VolcanoDetail({
    required this.id,
    required this.name,
    required this.activityLevel,
    required this.levelLabel,
    this.location,
    this.sourceUrl,
    this.reportPeriod,
    required this.reportTimeAvailable,
    this.author,
    this.imageUrl,
    this.visualObservation,
    this.climatology,
    this.seismicObservation,
    this.recommendation,
    this.otherDescription,
    required this.fetchedAt,
  });

  VolcanoRegion get region => VolcanoRegion.fromLocation(location);

  factory VolcanoDetail.fromJson(Map<String, dynamic> json) {
    return VolcanoDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      activityLevel: ActivityLevel.fromString(json['activity_level'] as String?),
      levelLabel: json['level_label'] as String? ?? 'Normal',
      location: json['location'] as String?,
      sourceUrl: json['source_url'] as String?,
      reportPeriod: json['report_period'] as String?,
      reportTimeAvailable: json['report_time_available'] as bool? ?? false,
      author: json['author'] as String?,
      imageUrl: json['image_url'] as String?,
      visualObservation: json['visual_observation'] as String?,
      climatology: json['climatology'] as String?,
      seismicObservation: json['seismic_observation'] as String?,
      recommendation: json['recommendation'] as String?,
      otherDescription: json['other_description'] as String?,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );
  }
}

class VolcanoDetailResponse {
  final VolcanoDetail volcano;
  final bool isStale;
  final DateTime fetchedAt;
  final String sourceDisclaimer;

  const VolcanoDetailResponse({
    required this.volcano,
    required this.isStale,
    required this.fetchedAt,
    required this.sourceDisclaimer,
  });

  factory VolcanoDetailResponse.fromJson(Map<String, dynamic> json) {
    return VolcanoDetailResponse(
      volcano: VolcanoDetail.fromJson(json['volcano'] as Map<String, dynamic>),
      isStale: json['is_stale'] as bool? ?? false,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      sourceDisclaimer: json['source_disclaimer'] as String? ?? '',
    );
  }
}
