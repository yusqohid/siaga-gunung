import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/activity_level_badge.dart';
import '../../../shared/widgets/data_freshness_badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/models/volcano_model.dart';
import '../providers/volcano_providers.dart';

class VolcanoDetailScreen extends ConsumerWidget {
  final String volcanoId;

  const VolcanoDetailScreen({super.key, required this.volcanoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(volcanoDetailProvider(volcanoId));
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);
    final isFavorite = favoriteIds.contains(volcanoId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : null,
            ),
            tooltip: isFavorite ? 'Hapus dari Pantauan' : 'Sematkan ke Pantauan (Beranda)',
            onPressed: () {
              ref.read(favoriteVolcanoesProvider.notifier).toggleFavorite(volcanoId);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Dihapus dari Gunung Pantauan.'
                        : 'Disematkan ke Gunung Pantauan di Beranda.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Laporan',
            onPressed: () => ref.read(volcanoDetailProvider(volcanoId).notifier).refresh(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const LoadingView(message: 'Mengambil laporan detail on-demand...'),
        error: (err, _) => ErrorView(
          title: 'Gagal Memuat Detail',
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(volcanoDetailProvider(volcanoId).notifier).refresh(),
        ),
        data: (response) => _buildDetailContent(context, ref, response),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    WidgetRef ref,
    VolcanoDetailResponse response,
  ) {
    final volcano = response.volcano;

    return RefreshIndicator(
      onRefresh: () => ref.read(volcanoDetailProvider(volcanoId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActivityLevelBadge(level: volcano.activityLevel),
                      DataFreshnessBadge(
                        fetchedAt: volcano.fetchedAt,
                        isStale: response.isStale,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    volcano.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (volcano.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            volcano.region.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            volcano.location!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Metadata: Report time vs Fetched time (PRD Requirement Section 9.5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildMetaRow(
                      icon: Icons.event_note_rounded,
                      label: 'Waktu Laporan Sumber:',
                      value: volcano.reportTimeAvailable && volcano.reportPeriod != null
                          ? volcano.reportPeriod!
                          : 'Waktu laporan tidak disediakan oleh sumber',
                      isHighlight: volcano.reportTimeAvailable,
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildMetaRow(
                      icon: Icons.sync_rounded,
                      label: 'Terakhir Diambil Aplikasi:',
                      value: DateFormatter.formatDateTime(volcano.fetchedAt),
                      isHighlight: false,
                    ),
                    if (volcano.author != null) ...[
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildMetaRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Penyusun Laporan:',
                        value: volcano.author!,
                        isHighlight: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Report photo if available from MAGMA
            if (volcano.imageUrl != null && volcano.imageUrl!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    volcano.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],

            // Official recommendations section (Highlighted)
            if (volcano.recommendation != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSectionCard(
                  title: 'Rekomendasi Resmi PVMBG',
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.primary,
                  content: volcano.recommendation!,
                  isAlert: true,
                ),
              ),
            ],

            // Visual observations
            if (volcano.visualObservation != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSectionCard(
                  title: 'Pengamatan Visual',
                  icon: Icons.visibility_outlined,
                  iconColor: AppColors.secondary,
                  content: volcano.visualObservation!,
                ),
              ),
            ],

            // Seismic observations
            if (volcano.seismicObservation != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSectionCard(
                  title: 'Pengamatan Kegempaan',
                  icon: Icons.show_chart_rounded,
                  iconColor: AppColors.levelIII,
                  content: volcano.seismicObservation!,
                ),
              ),
            ],

            // Climatology
            if (volcano.climatology != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSectionCard(
                  title: 'Klimatologi & Cuaca',
                  icon: Icons.wb_cloudy_outlined,
                  iconColor: Colors.blueGrey,
                  content: volcano.climatology!,
                ),
              ),
            ],

            // Other description
            if (volcano.otherDescription != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSectionCard(
                  title: 'Keterangan Lain',
                  icon: Icons.notes_rounded,
                  iconColor: AppColors.textSecondary,
                  content: volcano.otherDescription!,
                ),
              ),
            ],

            // Action button to open official MAGMA report (FR-10 & AC-08)
            if (volcano.sourceUrl != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _openExternalUrl(volcano.sourceUrl!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Buka Laporan Resmi di MAGMA Indonesia'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isHighlight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlight ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    bool isAlert = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? AppColors.primary.withOpacity(0.3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isAlert ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isAlert ? const Color(0xFF7F1D1D) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
