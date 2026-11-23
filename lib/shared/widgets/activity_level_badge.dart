import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/volcano/data/models/volcano_model.dart';
import 'level_style.dart';

class ActivityLevelBadge extends StatelessWidget {
  final ActivityLevel level;
  final bool showDot;
  final bool compact;

  const ActivityLevelBadge({
    super.key,
    required this.level,
    this.showDot = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: level.tintBackground(p),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            compact ? level.label : '${level.title} · ${level.label}',
            style: TextStyle(
              color: level.tintForeground(p),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
