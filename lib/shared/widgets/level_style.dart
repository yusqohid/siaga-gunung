import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/volcano/data/models/volcano_model.dart';

/// Shared tint rules for activity-level badges so all four levels keep a
/// readable foreground on their pastel containers in light and dark mode.
extension ActivityLevelTint on ActivityLevel {
  Color tintBackground(AppPalette palette) {
    return Color.lerp(palette.card, color, palette.isDark ? 0.32 : 0.30)!;
  }

  Color tintForeground(AppPalette palette) {
    return Color.lerp(color, palette.ink, palette.isDark ? 0.12 : 0.40)!;
  }
}
