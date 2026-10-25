import 'package:flutter/material.dart';
import '../../features/volcano/data/models/volcano_model.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: level.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: level.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            compact ? level.label : '${level.title} • ${level.label}',
            style: TextStyle(
              color: level.color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
