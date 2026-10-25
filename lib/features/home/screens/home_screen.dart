import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/activity_level_badge.dart';
import '../../../shared/widgets/data_freshness_badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../volcano/data/models/volcano_model.dart';
import '../../volcano/providers/volcano_providers.dart';
import '../../volcano/providers/status_alert_provider.dart';
import '../../map/services/location_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(volcanoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.volcano_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('SiagaGunung'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Tentang Aplikasi',
            onPressed: () => context.push('/about'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.read(volcanoListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(volcanoListProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              listAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingView(message: 'Mengambil status gunung terkini...'),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ErrorView(
                    title: 'Gagal Memuat Data',
                    message: err.toString().replaceFirst('Exception: ', ''),
                    onRetry: () => ref.read(volcanoListProvider.notifier).refresh(),
                  ),
                ),
                data: (response) => _buildContent(context, ref, response),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    VolcanoListResponse response,
  ) {
    // Highest level volcanoes (Level IV or Level III)
    final highRisk = response.volcanoes
        .where((v) =>
            v.activityLevel == ActivityLevel.levelIV ||
            v.activityLevel == ActivityLevel.levelIII)
        .toList();

    final favorites = ref.watch(favoriteVolcanoesListProvider);
    final alerts = ref.watch(statusAlertProvider);
    final userLocationState = ref.watch(userLocationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Freshness status bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DataFreshnessBadge(
                fetchedAt: response.fetchedAt,
                isStale: response.isStale,
                warningMessage: response.warningMessage,
              ),
              Text(
                'Total ${response.totalCount} Gunung',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Active Status Change Alerts (Escalations)
        if (alerts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: alerts
                  .map((alert) => _buildStatusAlertBanner(context, ref, alert))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // High priority alert card if any
        if (highRisk.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPriorityAlertCard(context, highRisk.first),
          ),
          const SizedBox(height: 16),
        ],

        // Nearby Volcano detection card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildNearbyVolcanoCard(context, ref, userLocationState),
        ),
        const SizedBox(height: 16),

        // Gunung Pantauan Anda (Favorit)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildFavoriteSection(context, ref, favorites),
        ),
        const SizedBox(height: 20),

        // Summary counts by level (Level IV, III, II, I)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Status Aktivitas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      ref,
                      ActivityLevel.levelIV,
                      response.byLevel['IV'] ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      ref,
                      ActivityLevel.levelIII,
                      response.byLevel['III'] ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      ref,
                      ActivityLevel.levelII,
                      response.byLevel['II'] ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      ref,
                      ActivityLevel.levelI,
                      response.byLevel['I'] ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick navigation shortcuts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.map_rounded,
                iconColor: Colors.teal.shade700,
                title: 'Peta Interaktif Sebaran Gunung',
                subtitle: 'Visualisasi posisi geografis & status 69 gunung api se-Indonesia',
                onTap: () => context.go('/map'),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.format_list_bulleted_rounded,
                iconColor: AppColors.primary,
                title: 'Daftar Semua Gunung Api',
                subtitle: 'Pantau status, lokasi, dan detail laporan resmi',
                onTap: () => context.go('/volcanoes'),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.levelIII,
                title: 'Modul Edukasi & Panduan Mitigasi',
                subtitle: 'Protokol hujan abu, panduan evakuasi, dan TSB 72 jam',
                onTap: () => context.go('/education'),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.checklist_rounded,
                iconColor: AppColors.levelI,
                title: 'Checklist Tas Siaga Bencana',
                subtitle: 'Simpan daftar perlengkapan penting secara lokal',
                onTap: () => context.go('/checklist'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Emergency hotlines
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_in_talk_rounded, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Kontak Darurat Nasional (Bebas Pulsa)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHotlineItem('BNPB', '117'),
                    _buildHotlineDivider(),
                    _buildHotlineItem('Basarnas', '115'),
                    _buildHotlineDivider(),
                    _buildHotlineItem('Ambulans', '118'),
                    _buildHotlineDivider(),
                    _buildHotlineItem('Polisi', '110'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityAlertCard(BuildContext context, VolcanoSummary volcano) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: volcano.activityLevel.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: volcano.activityLevel.color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: volcano.activityLevel.color,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'STATUS AKTIF TERKINI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ActivityLevelBadge(level: volcano.activityLevel, compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            volcano.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (volcano.location != null) ...[
            const SizedBox(height: 2),
            Text(
              volcano.location!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/volcanoes/${volcano.id}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: volcano.activityLevel.color,
                side: BorderSide(color: volcano.activityLevel.color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'Lihat Laporan Detail',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    WidgetRef ref,
    ActivityLevel level,
    int count,
  ) {
    return InkWell(
      onTap: () {
        ref.read(volcanoLevelFilterProvider.notifier).state = level;
        context.go('/volcanoes');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: count > 0 ? level.color.withOpacity(0.3) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 36,
              decoration: BoxDecoration(
                color: level.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${level.title} (${level.label})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: count > 0 ? level.color : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildHotlineItem(String label, String number) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse('tel:$number');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildFavoriteSection(
    BuildContext context,
    WidgetRef ref,
    List<VolcanoSummary> favorites,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                const SizedBox(width: 6),
                const Text(
                  'Gunung Pantauan Anda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${favorites.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (favorites.isNotEmpty)
              GestureDetector(
                onTap: () {
                  ref.read(showOnlyFavoritesFilterProvider.notifier).state = true;
                  context.go('/volcanoes');
                },
                child: const Text(
                  'Kelola',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_outline_rounded, size: 22, color: Colors.amber.shade800),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada gunung yang dipantau',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tandai ikon bintang ⭐ pada gunung terdekat untuk melihat statusnya di sini.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () => context.go('/volcanoes'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  child: const Text('Pilih', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 115,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final volcano = favorites[index];
                return _buildFavoriteVolcanoCard(context, ref, volcano);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteVolcanoCard(
    BuildContext context,
    WidgetRef ref,
    VolcanoSummary volcano,
  ) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: volcano.activityLevel.color.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/volcanoes/${volcano.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActivityLevelBadge(level: volcano.activityLevel, compact: true),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        volcano.region.label,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volcano.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      volcano.location ?? 'Indonesia',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: volcano.activityLevel.color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: volcano.activityLevel.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAlertBanner(
    BuildContext context,
    WidgetRef ref,
    StatusAlert alert,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.currentLevel.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: alert.currentLevel.color, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: alert.currentLevel.color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perhatian: Kenaikan Status Gunung Api!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: alert.currentLevel.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.volcanoName} mengalami kenaikan status dari ${alert.previousLevel.title} ke ${alert.currentLevel.title} (${alert.currentLevel.label}).',
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/volcanoes/${alert.volcanoId}'),
                      child: Text(
                        'Periksa Laporan Resmi →',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: alert.currentLevel.color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(statusAlertProvider.notifier)
                          .dismissAlert(alert.volcanoId, alert.currentLevel),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyVolcanoCard(
    BuildContext context,
    WidgetRef ref,
    UserLocationState locationState,
  ) {
    if (locationState.nearbyVolcanoes.isNotEmpty) {
      final closest = locationState.nearbyVolcanoes.first;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.near_me_rounded, size: 20, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Gunung Terdekat: ',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Flexible(
                        child: Text(
                          closest.volcano.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${closest.formattedDistance} dari Anda',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActivityLevelBadge(level: closest.volcano.activityLevel, compact: true),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
              tooltip: 'Lihat di Peta',
              onPressed: () => context.go('/map'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_searching_rounded, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Cari tahu gunung api terdekat dari lokasi Anda',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: locationState.isLoading
                ? null
                : () => ref.read(userLocationProvider.notifier).detectLocation(),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: locationState.isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Deteksi GPS', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
