import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/checklist_data.dart';

const String _kChecklistPrefKey = 'siaga_gunung_checklist_checked';

class ChecklistNotifier extends StateNotifier<Set<String>> {
  bool _isLoaded = false;
  final Set<String> _pendingToggles = {};

  ChecklistNotifier() : super(<String>{}) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_kChecklistPrefKey);
      final validIds = ChecklistData.defaultItems.map((e) => e.id).toSet();
      final loaded = (savedList ?? []).where(validIds.contains).toSet();

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

  Future<void> toggleItem(String id) async {
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

  Future<void> resetAll() async {
    _pendingToggles.clear();
    state = <String>{};
    _persist(<String>{});
  }

  Future<void> _persist(Set<String> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kChecklistPrefKey, items.toList());
    } catch (_) {}
  }
}

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, Set<String>>((ref) {
  return ChecklistNotifier();
});

class ChecklistProgress {
  final int completed;
  final int total;
  final double percentage;

  const ChecklistProgress({
    required this.completed,
    required this.total,
    required this.percentage,
  });
}

final checklistProgressProvider = Provider<ChecklistProgress>((ref) {
  final checked = ref.watch(checklistProvider);
  final validIds = ChecklistData.defaultItems.map((e) => e.id).toSet();
  final completed = checked.where(validIds.contains).length;
  final total = ChecklistData.defaultItems.length;
  final percentage = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

  return ChecklistProgress(
    completed: completed,
    total: total,
    percentage: percentage,
  );
});
