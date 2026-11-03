import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/volcano_model.dart';
import 'volcano_providers.dart';

const String _kPreviousLevelsPrefKey = 'siaga_gunung_previous_activity_levels';
const String _kDismissedAlertsPrefKey = 'siaga_gunung_dismissed_alerts';

class StatusAlert {
  final String volcanoId;
  final String volcanoName;
  final ActivityLevel previousLevel;
  final ActivityLevel currentLevel;
  final DateTime detectedAt;

  const StatusAlert({
    required this.volcanoId,
    required this.volcanoName,
    required this.previousLevel,
    required this.currentLevel,
    required this.detectedAt,
  });

  bool get isEscalated => currentLevel.sortOrder < previousLevel.sortOrder;
}

class StatusAlertNotifier extends StateNotifier<List<StatusAlert>> {
  final Ref _ref;
  bool _initialized = false;

  StatusAlertNotifier(this._ref) : super(const []) {
    _initAndCheckAlerts();
  }

  Future<void> _initAndCheckAlerts() async {
    if (_initialized) return;
    _initialized = true;

    final listAsync = _ref.watch(volcanoListProvider);
    listAsync.whenData((response) async {
      await _checkLevelChanges(response.volcanoes);
    });
  }

  Future<void> _checkLevelChanges(List<VolcanoSummary> volcanoes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final previousJson = prefs.getString(_kPreviousLevelsPrefKey);
      final dismissedIds = prefs.getStringList(_kDismissedAlertsPrefKey)?.toSet() ?? <String>{};

      final Map<String, String> previousMap = {};
      if (previousJson != null) {
        final decoded = jsonDecode(previousJson) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          previousMap[key] = value.toString();
        });
      }

      final currentMap = <String, String>{};
      final newAlerts = <StatusAlert>[];

      for (final v in volcanoes) {
        currentMap[v.id] = v.activityLevel.code;
        final prevCode = previousMap[v.id];

        if (prevCode != null && prevCode != v.activityLevel.code) {
          try {
            final prevLevel = ActivityLevel.fromString(prevCode);
            final alert = StatusAlert(
              volcanoId: v.id,
              volcanoName: v.name,
              previousLevel: prevLevel,
              currentLevel: v.activityLevel,
              detectedAt: DateTime.now(),
            );

            // Jika kenaikan level dan belum di-dismiss
            if (alert.isEscalated && !dismissedIds.contains('${v.id}_${v.activityLevel.code}')) {
              newAlerts.add(alert);
            }
          } catch (_) {}
        }
      }

      // Simpan status terkini sebagai baseline berikutnya
      await prefs.setString(_kPreviousLevelsPrefKey, jsonEncode(currentMap));

      state = newAlerts;
    } catch (_) {}
  }

  Future<void> dismissAlert(String volcanoId, ActivityLevel currentLevel) async {
    final alertKey = '${volcanoId}_${currentLevel.code}';
    state = state.where((a) => a.volcanoId != volcanoId).toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = prefs.getStringList(_kDismissedAlertsPrefKey) ?? <String>[];
      if (!dismissedList.contains(alertKey)) {
        dismissedList.add(alertKey);
        await prefs.setStringList(_kDismissedAlertsPrefKey, dismissedList);
      }
    } catch (_) {}
  }
}

final statusAlertProvider =
    StateNotifierProvider<StatusAlertNotifier, List<StatusAlert>>((ref) {
  return StatusAlertNotifier(ref);
});
