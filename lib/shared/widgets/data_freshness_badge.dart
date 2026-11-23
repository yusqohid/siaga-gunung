import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

class DataFreshnessBadge extends StatelessWidget {
  final DateTime? fetchedAt;
  final bool isStale;
  final String? warningMessage;

  const DataFreshnessBadge({
    super.key,
    this.fetchedAt,
    required this.isStale,
    this.warningMessage,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (warningMessage != null) {
      return _pill(
        context,
        Icons.warning_amber_rounded,
        warningMessage!,
        p.isDark ? const Color(0xFFE57368) : AppColors.levelIV,
      );
    }

    if (isStale) {
      return _pill(
        context,
        Icons.history_rounded,
        'Data lama (${DateFormatter.formatRelativeTime(fetchedAt)})',
        AppColors.levelIII,
      );
    }

    return _pill(
      context,
      Icons.check_circle_outline_rounded,
      'Sinkron ${DateFormatter.formatRelativeTime(fetchedAt)}',
      AppColors.levelI,
    );
  }

  Widget _pill(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color.lerp(context.palette.ink, color, 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
