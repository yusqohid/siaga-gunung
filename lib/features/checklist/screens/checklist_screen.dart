import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../data/checklist_data.dart';
import '../providers/checklist_providers.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final checkedIds = ref.watch(checklistProvider);
    final progress = ref.watch(checklistProgressProvider);

    final categories = <String, List<ChecklistItem>>{};
    for (final item in ChecklistData.defaultItems) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            ScreenHeader(
              eyebrow: 'Kesiapan mandiri',
              title: 'Tas Siaga 72 Jam',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RoundIconButton(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Bagikan Checklist',
                    onPressed: () => _share(context, checkedIds, categories, progress),
                  ),
                  if (checkedIds.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    RoundIconButton(
                      icon: Icons.restart_alt_rounded,
                      tooltip: 'Reset Checklist',
                      onPressed: () => _showResetDialog(context, ref),
                    ),
                  ],
                ],
              ),
            ),

            // Progress hero
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${progress.completed}',
                    style: TextStyle(
                      fontSize: 150,
                      fontWeight: FontWeight.w200,
                      height: 0.9,
                      letterSpacing: -7,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '/ ${progress.total}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                        Text(
                          'TERPENUHI',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                            color: p.mut,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(color: p.line),
                    FractionallySizedBox(
                      widthFactor: progress.percentage,
                      child: Container(color: p.amb),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              progress.percentage >= 1.0
                  ? 'Luar biasa! Seluruh perlengkapan darurat mandiri telah siap.'
                  : 'Masukkan semuanya ke ransel siaga keluarga sebelum keadaan darurat.',
              style: TextStyle(fontSize: 14, color: p.mut),
            ),

            for (final entry in categories.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 10),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
              ),
              ...entry.value.map((item) {
                final isChecked = checkedIds.contains(item.id);
                return _ChecklistRow(
                  item: item,
                  isChecked: isChecked,
                  onTap: () => ref.read(checklistProvider.notifier).toggleItem(item.id),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _share(
    BuildContext context,
    Set<String> checkedIds,
    Map<String, List<ChecklistItem>> categories,
    ChecklistProgress progress,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('📋 Checklist Tas Siaga Bencana (TSB 72 Jam) — SiagaGunung');
    buffer.writeln(
      'Status Kesiapan: ${progress.completed} dari ${progress.total} item terpenuhi (${(progress.percentage * 100).toInt()}%)\n',
    );
    for (final entry in categories.entries) {
      buffer.writeln('【 ${entry.key} 】');
      for (final item in entry.value) {
        final isChecked = checkedIds.contains(item.id);
        buffer.writeln('${isChecked ? '✅ [Siap]' : '⬜ [Belum]'} ${item.title}');
        buffer.writeln('   ${item.description}');
      }
      buffer.writeln();
    }
    buffer.writeln('📞 BNPB: 117 | Basarnas: 115');
    buffer.writeln('Aplikasi SiagaGunung — Selalu Siaga, Kenali Risikonya.');

    Share.share(buffer.toString().trim(), subject: 'Checklist Tas Siaga Bencana');
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset checklist?'),
          content: Text(
            'Seluruh status centang perlengkapan akan dikembalikan ke kondisi awal.',
            style: TextStyle(fontSize: 13, color: p.mut),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: p.mut)),
            ),
            FilledButton(
              onPressed: () {
                ref.read(checklistProvider.notifier).resetAll();
                Navigator.pop(dialogContext);
              },
              child: const Text('RESET'),
            ),
          ],
        );
      },
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final bool isChecked;
  final VoidCallback onTap;

  const _ChecklistRow({
    required this.item,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isChecked ? p.amb : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isChecked ? p.amb : p.line,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isChecked
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.inkOnAmber,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: isChecked ? p.mut : p.ink,
                        ),
                      ),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 13, height: 1.35, color: p.mut),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
