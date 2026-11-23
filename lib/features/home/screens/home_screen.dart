import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../map/services/location_service.dart';
import '../../volcano/data/models/volcano_model.dart';
import '../../volcano/providers/status_alert_provider.dart';
import '../../volcano/providers/volcano_providers.dart';

const Map<ActivityLevel, String> _levelRecommendations = {
  ActivityLevel.levelIV:
      'Ikuti arahan evakuasi BPBD setempat dan segera tinggalkan zona bahaya. Jangan memasuki radius larangan yang ditetapkan PVMBG.',
  ActivityLevel.levelIII:
      'Dilarang beraktivitas di dalam radius yang ditetapkan PVMBG dari pusat erupsi. Waspadai lontaran batu pijar, hujan abu lebat, dan potensi lahar.',
  ActivityLevel.levelII:
      'Pendaki dan wisatawan dilarang mendekati kawah dalam radius aman. Siapkan masker dan tas siaga di rumah.',
  ActivityLevel.levelI:
      'Aktivitas normal; tetap ikuti rambu di kawasan gunung dan pantau perubahan status melalui kanal resmi.',
};

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(volcanoListProvider);

    // Beri tahu pengguna bila refresh gagal namun data lama masih ditampilkan.
    ref.listen<AsyncValue<VolcanoListResponse>>(volcanoListProvider, (prev, next) {
      if (next.hasError && next.hasValue) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui data. Menampilkan data terakhir.'),
            ),
          );
      }
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: listAsync.hasValue
            ? RefreshIndicator(
                onRefresh: () => ref.read(volcanoListProvider.notifier).refresh(),
                child: _buildContent(context, ref, listAsync.requireValue),
              )
            : listAsync.when(
                loading: () => _buildFrame(
                  context,
                  ref,
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: LoadingView(message: 'Mengambil status gunung terkini...'),
                  ),
                ),
                error: (err, _) => _buildFrame(
                  context,
                  ref,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: ErrorView(
                      title: 'Gagal Memuat Data',
                      message: err.toString().replaceFirst('Exception: ', ''),
                      onRetry: () =>
                          ref.read(volcanoListProvider.notifier).refresh(),
                    ),
                  ),
                ),
                data: (response) => _buildContent(context, ref, response),
              ),
      ),
    );
  }

  /// Header shown for loading / error states too.
  Widget _buildFrame(BuildContext context, WidgetRef ref, Widget child) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildHeader(context, ref),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScreenHeader(
      eyebrow: 'Pantauan hari ini,',
      title: 'Gunung Api',
      eyebrowSize: 26,
      titleSize: 30,
      trailingOnTitleRow: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: RoundIconButton(
              key: ValueKey('theme-${isDark ? 'dark' : 'light'}'),
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 42,
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              onPressed: () => ref
                  .read(themeModeProvider.notifier)
                  .toggle(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.sync_rounded,
            accent: true,
            size: 42,
            tooltip: 'Segarkan Data',
            onPressed: () {
              ref.read(volcanoListProvider.notifier).refresh();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data PVMBG diperbarui.')),
              );
            },
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.info_outline_rounded,
            size: 42,
            tooltip: 'Tentang Aplikasi',
            onPressed: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    VolcanoListResponse response,
  ) {
    final p = context.palette;
    final counts = response.byLevel;
    final favorites = ref.watch(favoriteVolcanoesListProvider);
    final alerts = ref.watch(statusAlertProvider);
    final locationState = ref.watch(userLocationProvider);

    final topLevel = ActivityLevel.values.firstWhere(
      (level) => (counts[level.code] ?? 0) > 0,
      orElse: () => ActivityLevel.levelI,
    );
    final topCount = counts[topLevel.code] ?? 0;

    final priority = _pickPriorityVolcano(response.volcanoes);
    final relative = DateFormatter.formatRelativeTime(response.fetchedAt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildHeader(context, ref),

        // Hero: big count + level label
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$topCount',
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
                      'GUNUNG',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      'STATUS ${topLevel.label.toUpperCase()}',
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

        // Sync status + total pill
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: p.amb,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    '${response.totalCount}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.inkOnAmber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TOTAL\nGUNUNG',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkOnAmber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.isStale ? 'Data tersimpan $relative' : 'Sinkron $relative',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    'Level IV (Awas): ${counts['IV'] ?? 0} gunung',
                    style: TextStyle(fontSize: 14, color: p.mut),
                  ),
                  if (response.warningMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        response.warningMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: p.isDark
                              ? const Color(0xFFE57368)
                              : AppColors.levelIV,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Escalation alerts (kept from functional spec)
        if (alerts.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...alerts.map((alert) => _StatusAlertCard(alert: alert)),
        ],

        // Activity distribution
        AppCard(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DistributionBar(counts: counts),
              const SizedBox(height: 14),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _LevelButton(level: ActivityLevel.levelIV, count: counts['IV'] ?? 0)),
                      const SizedBox(width: 8),
                      Expanded(child: _LevelButton(level: ActivityLevel.levelIII, count: counts['III'] ?? 0)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _LevelButton(level: ActivityLevel.levelII, count: counts['II'] ?? 0)),
                      const SizedBox(width: 8),
                      Expanded(child: _LevelButton(level: ActivityLevel.levelI, count: counts['I'] ?? 0)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quick actions
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.my_location_rounded,
                    background: p.lime,
                    caption: 'Terdekat',
                    title: 'Deteksi GPS',
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref.read(userLocationProvider.notifier).detectLocation();
                      final state = ref.read(userLocationProvider);
                      if (state.errorMessage != null) {
                        messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                      } else if (state.nearbyVolcanoes.isNotEmpty) {
                        final closest = state.nearbyVolcanoes.first;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Terdekat: ${closest.volcano.name} (${closest.formattedDistance})',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.star_rounded,
                    background: p.amb.withValues(alpha: 0.3),
                    caption: 'Pantauan',
                    title: '${favorites.length} gunung',
                    onTap: () {
                      ref.read(showOnlyFavoritesFilterProvider.notifier).state = true;
                      context.go('/volcanoes');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Priority warning
        if (priority != null) ...[
          const SizedBox(height: 14),
          _PriorityAlertCard(volcano: priority),
        ],

        // Emergency contacts
        const SectionTitle('Kontak darurat'),
        Row(
          children: [
            Expanded(
              child: _EmergencyTile(
                icon: Icons.phone_in_talk_rounded,
                label: 'BNPB',
                detail: '117',
                onTap: () => _call(context, '117'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EmergencyTile(
                icon: Icons.phone_in_talk_rounded,
                label: 'Basarnas',
                detail: '115',
                onTap: () => _call(context, '115'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EmergencyTile(
                icon: Icons.phone_in_talk_rounded,
                label: 'PVMBG',
                detail: '(022) 7272606',
                onTap: () => _call(context, '0227272606'),
              ),
            ),
          ],
        ),

        if (locationState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Caption(locationState.errorMessage!, color: p.mut),
          ),
      ],
    );
  }

  VolcanoSummary? _pickPriorityVolcano(List<VolcanoSummary> volcanoes) {
    for (final level in ActivityLevel.values) {
      final matches = volcanoes.where((v) => v.activityLevel == level).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      if (matches.isNotEmpty) return matches.first;
    }
    return null;
  }

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _DistributionBar extends StatelessWidget {
  final Map<String, int> counts;

  const _DistributionBar({required this.counts});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final segments = <Widget>[];
    for (final level in ActivityLevel.values) {
      final count = counts[level.code] ?? 0;
      if (count <= 0) continue;
      if (segments.isNotEmpty) {
        segments.add(const SizedBox(width: 3));
      }
      segments.add(
        Expanded(
          flex: count,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: level.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    if (segments.isEmpty) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: p.line,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Row(children: segments);
  }
}

class _LevelButton extends StatelessWidget {
  final ActivityLevel level;
  final int count;

  const _LevelButton({required this.level, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ref = ProviderScope.containerOf(context, listen: false);
    final softSurface = Color.lerp(p.card, p.bg, p.isDark ? 0.45 : 0.5)!;

    return Material(
      color: softSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(volcanoLevelFilterProvider.notifier).state = level;
          context.go('/volcanoes');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              LevelMark(level: level, size: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      height: 1,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    level.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                      color: p.mut,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color background;
  final String caption;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.background,
    required this.caption,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: p.ink),
              ),
              const SizedBox(height: 12),
              Caption(caption),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityAlertCard extends StatelessWidget {
  final VolcanoSummary volcano;

  const _PriorityAlertCard({required this.volcano});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final recommendation = _levelRecommendations[volcano.activityLevel] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.dk,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: p.amb,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '● ${volcano.activityLevel.label.toUpperCase()} · ${volcano.activityLevel.title.toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: AppColors.inkOnAmber,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${volcano.name}. ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: recommendation),
                ],
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () => context.push('/volcanoes/${volcano.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BUKA LAPORAN DETAIL',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                      color: p.amb,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: p.amb),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _EmergencyTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: p.ink),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
              Caption(detail),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusAlertCard extends ConsumerWidget {
  final StatusAlert alert;

  const _StatusAlertCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final color = alert.currentLevel.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kenaikan status gunung api',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color.lerp(p.ink, color, 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.volcanoName}: ${alert.previousLevel.title} → ${alert.currentLevel.title} (${alert.currentLevel.label}).',
                  style: TextStyle(fontSize: 12, color: p.ink),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/volcanoes/${alert.volcanoId}'),
                      child: Text(
                        'Periksa laporan →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(statusAlertProvider.notifier)
                          .dismissAlert(alert.volcanoId, alert.currentLevel),
                      child: Text(
                        'Tutup',
                        style: TextStyle(fontSize: 12, color: p.mut),
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
}
