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
    if (warningMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.errorBadge.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.errorBadge),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                warningMessage!,
                style: const TextStyle(
                  color: AppColors.errorBadge,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (isStale) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.staleBadge.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 14, color: AppColors.staleBadge),
            const SizedBox(width: 6),
            Text(
              'Data Lama (${DateFormatter.formatRelativeTime(fetchedAt)})',
              style: const TextStyle(
                color: AppColors.staleBadge,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.freshBadge.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.freshBadge),
          const SizedBox(width: 6),
          Text(
            'Sinkron ${DateFormatter.formatRelativeTime(fetchedAt)}',
            style: const TextStyle(
              color: AppColors.freshBadge,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
