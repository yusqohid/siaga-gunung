import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siaga_gunung/features/volcano/data/models/volcano_model.dart';
import 'package:siaga_gunung/features/volcano/data/repositories/volcano_repository.dart';
import 'package:siaga_gunung/features/volcano/providers/volcano_providers.dart';

class _FakeRepository extends VolcanoRepository {
  bool shouldFail = false;
  int calls = 0;

  VolcanoListResponse _response() => VolcanoListResponse(
        volcanoes: [
          VolcanoSummary(
            id: 'merapi',
            name: 'Merapi',
            activityLevel: ActivityLevel.levelIII,
            levelLabel: 'Siaga',
            fetchedAt: DateTime.now(),
          ),
        ],
        totalCount: 1,
        byLevel: const {'IV': 0, 'III': 1, 'II': 0, 'I': 0},
        fetchedAt: DateTime.now(),
        isStale: false,
        sourceDisclaimer: 'test',
      );

  @override
  Future<VolcanoListResponse> getVolcanoList({
    ActivityLevel? level,
    String? search,
    bool forceRefresh = false,
  }) async {
    calls++;
    if (shouldFail) throw Exception('jaringan gagal');
    return _response();
  }
}

void main() {
  test('Refresh gagal harus mempertahankan data lama, bukan mengosongkan layar', () async {
    final repo = _FakeRepository();
    final notifier = VolcanoListNotifier(repo);

    // Initial load
    await notifier.loadVolcanoes();
    expect(notifier.state.hasValue, true);
    expect(notifier.state.requireValue.totalCount, 1);

    // Refresh gagal
    repo.shouldFail = true;
    await notifier.refresh();

    // Data lama tetap tersedia dan error tercatat
    expect(notifier.state.hasValue, true);
    expect(notifier.state.requireValue.totalCount, 1);
    expect(notifier.state.hasError, true);
  });

  test('Load pertama yang gagal tanpa cache harus menjadi error murni', () async {
    final repo = _FakeRepository()..shouldFail = true;
    final notifier = VolcanoListNotifier(repo);

    await notifier.loadVolcanoes();

    expect(notifier.state.hasError, true);
    expect(notifier.state.hasValue, false);
  });
}
