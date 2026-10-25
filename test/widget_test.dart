import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:siaga_gunung/main.dart';
import 'package:siaga_gunung/core/constants/api_constants.dart';
import 'package:siaga_gunung/core/utils/date_formatter.dart';
import 'package:siaga_gunung/features/volcano/data/models/volcano_model.dart';
import 'package:siaga_gunung/features/education/data/education_data.dart';
import 'package:siaga_gunung/features/checklist/data/checklist_data.dart';

void main() {
  setUpAll(() async {
    // Inisialisasi locale id agar DateFormat berjalan tanpa error
    await initializeDateFormatting('id', null);
  });

  testWidgets('SiagaGunungApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SiagaGunungApp()));
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('SiagaGunung'), findsOneWidget);
    // Verify navigation tabs
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Gunung'), findsOneWidget);
    expect(find.text('Edukasi'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
  });

  test('ActivityLevel enum sorting, labels, and unknown level rejection test', () {
    expect(ActivityLevel.levelIV.label, 'Awas');
    expect(ActivityLevel.levelIII.label, 'Siaga');
    expect(ActivityLevel.levelII.label, 'Waspada');
    expect(ActivityLevel.levelI.label, 'Normal');

    expect(ActivityLevel.levelIV.sortOrder, 0);
    expect(ActivityLevel.levelIII.sortOrder, 1);
    expect(ActivityLevel.levelII.sortOrder, 2);
    expect(ActivityLevel.levelI.sortOrder, 3);

    // PRD §9.3: Unknown activity level must NOT silently map to Normal
    expect(() => ActivityLevel.fromString('UNKNOWN_LEVEL'), throwsA(isA<FormatException>()));
    expect(() => ActivityLevel.fromString(null), throwsA(isA<FormatException>()));
  });

  test('DateFormatter formatting test (WIB & Locale ID verification)', () {
    final utcTime = DateTime.utc(2026, 10, 25, 5, 0); // 05:00 UTC = 12:00 WIB
    final formatted = DateFormatter.formatDateTime(utcTime);

    // Must not crash, must contain formatted Indonesian month and WIB
    expect(formatted, contains('Okt'));
    expect(formatted, contains('2026'));
    expect(formatted, contains('12:00'));
    expect(formatted, contains('WIB'));

    expect(DateFormatter.formatRelativeTime(DateTime.now()), 'Baru saja');
    expect(DateFormatter.formatRelativeTime(null), 'Tidak tersedia');
  });

  test('VolcanoDetail model parsing includes imageUrl & otherDescription', () {
    final json = {
      'id': 'merapi',
      'name': 'Merapi',
      'activity_level': 'III',
      'level_label': 'Siaga',
      'location': 'DIY',
      'source_url': 'https://magma.esdm.go.id/report/1',
      'report_period': 'periode 00:00-24:00 WIB',
      'report_time_available': true,
      'author': 'Yulianto',
      'image_url': 'https://magma.esdm.go.id/img/merapi.jpg',
      'visual_observation': 'Asap kawah putih',
      'climatology': 'Cerah',
      'seismic_observation': '64 kali guguran',
      'recommendation': 'Radius 5 km aman',
      'other_description': 'Kondisi kubah stabil',
      'fetched_at': '2026-10-25T05:00:00Z',
    };

    final detail = VolcanoDetail.fromJson(json);
    expect(detail.id, 'merapi');
    expect(detail.imageUrl, 'https://magma.esdm.go.id/img/merapi.jpg');
    expect(detail.otherDescription, 'Kondisi kubah stabil');
    expect(detail.activityLevel, ActivityLevel.levelIII);
  });

  test('ApiConstants defaultBaseUrl returns valid non-empty URL', () {
    expect(ApiConstants.defaultBaseUrl, isNotEmpty);
    expect(ApiConstants.defaultBaseUrl, startsWith('http'));
  });

  test('EducationData minimum required topics test', () {
    expect(EducationData.topics.length, greaterThanOrEqualTo(5));
    final topicIds = EducationData.topics.map((t) => t.id).toSet();
    expect(topicIds.contains('ed-01'), true);
    expect(topicIds.contains('ed-02'), true);
    expect(topicIds.contains('ed-03'), true);
    expect(topicIds.contains('ed-07'), true);
  });

  test('ChecklistData default items test', () {
    expect(ChecklistData.defaultItems.length, greaterThanOrEqualTo(9));
    final categories = ChecklistData.defaultItems.map((i) => i.category).toSet();
    expect(categories.contains('Dokumen Penting'), true);
    expect(categories.contains('Pelindung Diri'), true);
    expect(categories.contains('Logistik'), true);
  });
}
