import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/volcano_model.dart';
import '../data/repositories/volcano_repository.dart';

final volcanoRepositoryProvider = Provider<VolcanoRepository>((ref) {
  return VolcanoRepository();
});

// Search and filter state
final volcanoSearchQueryProvider = StateProvider<String>((ref) => '');
final volcanoLevelFilterProvider = StateProvider<ActivityLevel?>((ref) => null);

// Volcano list state notifier
class VolcanoListNotifier extends StateNotifier<AsyncValue<VolcanoListResponse>> {
  final VolcanoRepository _repository;

  VolcanoListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadVolcanoes();
  }

  Future<void> loadVolcanoes({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getVolcanoList(forceRefresh: forceRefresh);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadVolcanoes(forceRefresh: true);
}

final volcanoListProvider =
    StateNotifierProvider<VolcanoListNotifier, AsyncValue<VolcanoListResponse>>((ref) {
  final repo = ref.watch(volcanoRepositoryProvider);
  return VolcanoListNotifier(repo);
});

// Volcano detail provider family with force refresh capability
class VolcanoDetailNotifier
    extends FamilyAsyncNotifier<VolcanoDetailResponse, String> {
  @override
  Future<VolcanoDetailResponse> build(String arg) async {
    final repo = ref.watch(volcanoRepositoryProvider);
    return repo.getVolcanoDetail(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(volcanoRepositoryProvider);
      return repo.getVolcanoDetail(arg, forceRefresh: true);
    });
  }
}

final volcanoDetailProvider = AsyncNotifierProvider.family<
    VolcanoDetailNotifier,
    VolcanoDetailResponse,
    String>(VolcanoDetailNotifier.new);

// Filtered volcanoes provider
final filteredVolcanoesProvider = Provider<List<VolcanoSummary>>((ref) {
  final listAsync = ref.watch(volcanoListProvider);
  final searchQuery = ref.watch(volcanoSearchQueryProvider).trim().toLowerCase();
  final levelFilter = ref.watch(volcanoLevelFilterProvider);

  return listAsync.maybeWhen(
    data: (response) {
      return response.volcanoes.where((v) {
        final matchesLevel = levelFilter == null || v.activityLevel == levelFilter;
        final matchesSearch = searchQuery.isEmpty ||
            v.name.toLowerCase().contains(searchQuery) ||
            (v.location != null && v.location!.toLowerCase().contains(searchQuery));
        return matchesLevel && matchesSearch;
      }).toList();
    },
    orElse: () => [],
  );
});
