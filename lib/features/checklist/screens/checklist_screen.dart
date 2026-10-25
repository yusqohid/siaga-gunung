import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/checklist_data.dart';
import '../providers/checklist_providers.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedIds = ref.watch(checklistProvider);
    final progress = ref.watch(checklistProgressProvider);

    // Group items by category
    final categories = <String, List<ChecklistItem>>{};
    for (final item in ChecklistData.defaultItems) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Barang Siaga'),
        actions: [
          if (checkedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Reset Checklist',
              onPressed: () => _showResetDialog(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress summary header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kesiapan Mandiri (TSB 72 Jam)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${progress.completed} dari ${progress.total} terpenuhi',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.percentage,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.percentage == 1.0 ? AppColors.levelI : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progress.percentage == 1.0
                      ? '🎉 Luar biasa! Seluruh perlengkapan darurat mandiri telah siap.'
                      : 'Pastikan barang-barang di bawah telah dimasukkan ke ransel siaga bencana keluarga.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Categorized checklist items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: categories.entries.map((entry) {
                final categoryName = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final isChecked = checkedIds.contains(item.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(checklistProvider.notifier).toggleItem(item.id);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) {
                                    ref.read(checklistProvider.notifier).toggleItem(item.id);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isChecked
                                              ? AppColors.textMuted
                                              : AppColors.textPrimary,
                                          decoration: isChecked
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isChecked
                                              ? AppColors.textMuted
                                              : AppColors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Checklist?'),
          content: const Text(
            'Seluruh status centang perlengkapan akan dikembalikan ke kondisi awal (belum selesai).',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(checklistProvider.notifier).resetAll();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Reset Sekarang'),
            ),
          ],
        );
      },
    );
  }
}
