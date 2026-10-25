import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/volcano_model.dart';
import '../data/repositories/volcano_repository.dart';

final volcanoRepositoryProvider = Provider<VolcanoRepository>((ref) {
  return VolcanoRepository();
});

// Search and filter state
final volcanoSearchQueryProvider = StateProvider<String>((ref) => '');
final volcanoLevelFilterProvider = StateProvider<ActivityLevel?>((ref) => null);
final volcanoRegionFilterProvider = StateProvider<VolcanoRegion>((ref) => VolcanoRegion.all);
final showOnlyFavoritesFilterProvider = StateProvider<bool>((ref) => false);

// Favorite Volcanoes Persistence
const String _kFavoriteVolcanoesPrefKey = 'siaga_gunung_favorite_volcanoes';

class FavoriteVolcanoesNotifier extends StateNotifier<Set<String>> {
  bool _isLoaded = false;
  final Set<String> _pendingToggles = {};

  FavoriteVolcanoesNotifier() : super(<String>{}) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_kFavoriteVolcanoesPrefKey);
      final loaded = (savedList ?? []).toSet();

      // Gabungkan aksi user yang terjadi saat storage masih loading
      for (final id in _pendingToggles) {
        if (loaded.contains(id)) {
          loaded.remove(id);
        } else {
          loaded.add(id);
        }
      }
      _pendingToggles.clear();
      _isLoaded = true;
      state = loaded;
    } catch (_) {
      _isLoaded = true;
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (!_isLoaded) {
      _pendingToggles.add(id);
    }
    final updated = Set<String>.from(state);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
    _persist(updated);
  }

  bool isFavorite(String id) => state.contains(id);

  Future<void> _persist(Set<String> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kFavoriteVolcanoesPrefKey, items.toList());
    } catch (_) {}
  }
}

final favoriteVolcanoesProvider =
    StateNotifierProvider<FavoriteVolcanoesNotifier, Set<String>>((ref) {
  return FavoriteVolcanoesNotifier();
});

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
  final regionFilter = ref.watch(volcanoRegionFilterProvider);
  final showOnlyFavorites = ref.watch(showOnlyFavoritesFilterProvider);
  final favorites = ref.watch(favoriteVolcanoesProvider);

  return listAsync.maybeWhen(
    data: (response) {
      return response.volcanoes.where((v) {
        if (showOnlyFavorites && !favorites.contains(v.id)) {
          return false;
        }
        if (levelFilter != null && v.activityLevel != levelFilter) {
          return false;
        }
        if (regionFilter != VolcanoRegion.all && v.region != regionFilter) {
          return false;
        }
        if (searchQuery.isNotEmpty) {
          final matchesSearch = v.name.toLowerCase().contains(searchQuery) ||
              (v.location != null && v.location!.toLowerCase().contains(searchQuery)) ||
              v.region.label.toLowerCase().contains(searchQuery);
          if (!matchesSearch) return false;
        }
        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

// Favorite volcanoes list provider
final favoriteVolcanoesListProvider = Provider<List<VolcanoSummary>>((ref) {
  final listAsync = ref.watch(volcanoListProvider);
  final favorites = ref.watch(favoriteVolcanoesProvider);

  return listAsync.maybeWhen(
    data: (response) {
      return response.volcanoes
          .where((v) => favorites.contains(v.id))
          .toList();
    },
    orElse: () => [],
  );
});
