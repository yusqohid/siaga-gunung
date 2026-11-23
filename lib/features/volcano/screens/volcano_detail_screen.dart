import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../../map/data/volcano_coordinates.dart';
import '../data/models/volcano_model.dart';
import '../providers/volcano_providers.dart';

class VolcanoDetailScreen extends ConsumerStatefulWidget {
  final String volcanoId;

  const VolcanoDetailScreen({super.key, required this.volcanoId});

  @override
  ConsumerState<VolcanoDetailScreen> createState() => _VolcanoDetailScreenState();
}

class _VolcanoDetailScreenState extends ConsumerState<VolcanoDetailScreen> {
  int _tab = 0;

  static const List<String> _tabs = ['Rekomendasi', 'Visual', 'Kegempaan', 'Cuaca'];

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(volcanoDetailProvider(widget.volcanoId));

    return Scaffold(
      body: detailAsync.when(
        loading: () => _buildShell(
          const LoadingView(message: 'Mengambil laporan detail on-demand...'),
        ),
        error: (err, _) => _buildShell(
          ErrorView(
            title: 'Gagal Memuat Detail',
            message: err.toString().replaceFirst('Exception: ', ''),
            onRetry: () =>
                ref.read(volcanoDetailProvider(widget.volcanoId).notifier).refresh(),
          ),
        ),
        data: (response) => _buildDetail(context, response),
      ),
    );
  }

  Widget _buildShell(Widget child) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
                const Text('Detail Aktivitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, VolcanoDetailResponse response) {
    final p = context.palette;
    final volcano = response.volcano;
    final isFavorite = ref.watch(favoriteVolcanoesProvider).contains(volcano.id);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 110 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, volcano, topInset),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gunung',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          height: 1.1,
                          color: p.mut,
                        ),
                      ),
                      Text(
                        volcano.name,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          letterSpacing: -0.6,
                          color: p.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            leading: LevelMark(level: volcano.activityLevel, size: 22),
                            text: 'Level ${volcano.activityLevel.code} · ${volcano.activityLevel.label}',
                          ),
                          _InfoPill(
                            leading: Icon(Icons.location_on_outlined, size: 16, color: p.mut),
                            text: volcano.location ?? volcano.region.label,
                          ),
                          _InfoPill(
                            leading: Icon(Icons.schedule_rounded, size: 16, color: p.mut),
                            text: volcano.reportPeriod ?? 'Laporan terbaru',
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _buildTabs(context),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.02),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_tab),
                          child: _buildTabBody(context, response),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Caption(
                        'Laporan ${volcano.reportPeriod ?? 'terbaru'} · diambil ${DateFormatter.formatRelativeTime(volcano.fetchedAt)}'
                            .toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: bottomInset + 18,
          child: _buildCta(context, volcano, isFavorite),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, VolcanoDetail volcano, double topInset) {
    final p = context.palette;
    final level = volcano.activityLevel;
    final startColor = Color.lerp(p.bg, level.color, 0.4)!;

    return Container(
      height: 230 + topInset,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [startColor, p.bg],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            bottom: 30,
            child: Text(
              level.code,
              style: TextStyle(
                fontSize: 150,
                fontWeight: FontWeight.w200,
                height: 1,
                letterSpacing: -6,
                color: level.color.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            top: topInset + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.ios_share_rounded,
                      tooltip: 'Bagikan',
                      onPressed: () => _share(volcano),
                    ),
                    const SizedBox(width: 8),
                    RoundIconButton(
                      icon: Icons.sync_rounded,
                      tooltip: 'Segarkan Laporan',
                      onPressed: () => ref
                          .read(volcanoDetailProvider(widget.volcanoId).notifier)
                          .refresh(),
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

  Widget _buildTabs(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w400,
                          color: _tab == i ? p.ink : p.mut,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: _tab == i ? 22 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: p.amb,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBody(BuildContext context, VolcanoDetailResponse response) {
    final volcano = response.volcano;

    switch (_tab) {
      case 0:
        final recommendation = volcano.recommendation?.trim() ?? '';
        final lines = recommendation.isEmpty
            ? <String>[]
            : recommendation
                .split(RegExp(r'\n+'))
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty)
                .map(_stripListPrefix)
                .toList();

        return Column(
          children: [
            if (lines.isEmpty)
              const _ParagraphRow(text: 'Rekomendasi resmi belum tersedia untuk laporan ini.')
            else
              for (var i = 0; i < lines.length; i++)
                _NumberedRow(index: '${i + 1}', text: lines[i]),
            _NumberedRow(
              icon: Icons.phone_in_talk_rounded,
              text: 'PVMBG (022) 7272606, Bandung',
            ),
          ],
        );
      case 1:
        final visual = volcano.visualObservation?.trim();
        return Column(
          children: [
            if (volcano.imageUrl != null && volcano.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    volcano.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        color: context.palette.bg,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            _ParagraphRow(
              text: visual?.isNotEmpty == true
                  ? visual!
                  : 'Pengamatan visual belum tersedia untuk laporan ini.',
            ),
          ],
        );
      case 2:
        final seismic = volcano.seismicObservation?.trim();
        return _ParagraphRow(
          text: seismic?.isNotEmpty == true
              ? seismic!
              : 'Data kegempaan belum tersedia untuk laporan ini.',
        );
      default:
        final climate = volcano.climatology?.trim();
        final other = volcano.otherDescription?.trim();
        return Column(
          children: [
            _ParagraphRow(
              text: climate?.isNotEmpty == true
                  ? climate!
                  : 'Data cuaca & klimatologi belum tersedia untuk laporan ini.',
            ),
            if (other != null && other.isNotEmpty)
              _NumberedRow(icon: Icons.notes_rounded, text: other),
          ],
        );
    }
  }

  Widget _buildCta(
    BuildContext context,
    VolcanoDetail volcano,
    bool isFavorite,
  ) {
    final p = context.palette;
    final canOpen = volcano.sourceUrl != null && volcano.sourceUrl!.isNotEmpty;

    return Row(
      children: [
        Material(
          color: p.dk,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => ref
                .read(favoriteVolcanoesProvider.notifier)
                .toggleFavorite(volcano.id),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                size: 26,
                color: isFavorite ? p.amb : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: canOpen ? () => _openUrl(volcano.sourceUrl!) : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('LAPORAN RESMI MAGMA'),
              style: FilledButton.styleFrom(
                backgroundColor: p.amb,
                foregroundColor: AppColors.inkOnAmber,
                disabledBackgroundColor: p.line,
                disabledForegroundColor: p.mut,
                elevation: 0,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _stripListPrefix(String line) {
    return line
        .replaceFirst(RegExp(r'^\s*\d+\s*[\.\)]\s*'), '')
        .replaceFirst(RegExp(r'^\s*[-•*]\s*'), '');
  }

  void _share(VolcanoDetail v) {
    final coordinate = VolcanoCoordinatesData.getCoordinate(v.name, location: v.location);
    final text = '''
🌋 Status Gunung ${v.name} — SiagaGunung
• Tingkat Aktivitas: ${v.activityLevel.title} (${v.activityLevel.label})
• Wilayah: ${v.region.label} (${v.location ?? '-'})
• Ketinggian: ▲ ${coordinate.elevation} mdpl
• Periode Laporan: ${v.reportPeriod ?? 'Terbaru'}
• Rekomendasi: ${v.recommendation ?? '-'}

Sumber Resmi: MAGMA Indonesia (PVMBG)
${v.sourceUrl ?? ''}
''';
    Share.share(text.trim(), subject: 'Status Gunung ${v.name}');
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoPill extends StatelessWidget {
  final Widget leading;
  final String text;

  const _InfoPill({required this.leading, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: p.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedRow extends StatelessWidget {
  final String? index;
  final IconData? icon;
  final String text;

  const _NumberedRow({this.index, this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: icon != null
                ? Icon(icon, size: 16, color: p.mut)
                : Text(
                    index ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: p.mut,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, height: 1.4, color: p.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParagraphRow extends StatelessWidget {
  final String text;

  const _ParagraphRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, height: 1.45, color: p.ink),
      ),
    );
  }
}
