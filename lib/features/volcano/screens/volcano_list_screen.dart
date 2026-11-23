import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/ui_kit.dart';
import '../data/models/volcano_model.dart';
import '../providers/volcano_providers.dart';

class VolcanoListScreen extends ConsumerStatefulWidget {
  const VolcanoListScreen({super.key});

  @override
  ConsumerState<VolcanoListScreen> createState() => _VolcanoListScreenState();
}

class _VolcanoListScreenState extends ConsumerState<VolcanoListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(volcanoSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(volcanoListProvider);
    final selectedLevel = ref.watch(volcanoLevelFilterProvider);
    final selectedRegion = ref.watch(volcanoRegionFilterProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ScreenHeader(
                eyebrow: 'Status aktivitas',
                title: 'Daftar Gunung',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SearchField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(volcanoSearchQueryProvider.notifier).state = value;
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(volcanoSearchQueryProvider.notifier).state = '';
                },
              ),
            ),
            const SizedBox(height: 12),
            _ChipRow(
              children: VolcanoRegion.values
                  .map(
                    (region) => PillChip(
                      label: region.label,
                      selected: selectedRegion == region,
                      onTap: () {
                        ref.read(volcanoRegionFilterProvider.notifier).state = region;
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            _ChipRow(
              children: [
                PillChip(
                  label: 'Semua',
                  selected: selectedLevel == null,
                  onTap: () {
                    ref.read(volcanoLevelFilterProvider.notifier).state = null;
                  },
                ),
                ...ActivityLevel.values.map(
                  (level) => PillChip(
                    label: '${level.code} ${level.label}',
                    selected: selectedLevel == level,
                    onTap: () {
                      ref.read(volcanoLevelFilterProvider.notifier).state = level;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: listAsync.when(
                loading: () => const LoadingView(message: 'Memuat daftar gunung...'),
                error: (err, _) => ErrorView(
                  title: 'Gagal Memuat Data',
                  message: err.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.read(volcanoListProvider.notifier).refresh(),
                ),
                data: (response) => _buildList(context, response),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, VolcanoListResponse response) {
    final searchQuery = ref.watch(volcanoSearchQueryProvider).trim().toLowerCase();
    final selectedLevel = ref.watch(volcanoLevelFilterProvider);
    final selectedRegion = ref.watch(volcanoRegionFilterProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesFilterProvider);
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);

    final filtered = response.volcanoes.where((v) {
      if (showOnlyFavorites && !favoriteIds.contains(v.id)) return false;
      if (selectedLevel != null && v.activityLevel != selectedLevel) return false;
      if (selectedRegion != VolcanoRegion.all && v.region != selectedRegion) return false;
      if (searchQuery.isNotEmpty) {
        final matches = v.name.toLowerCase().contains(searchQuery) ||
            (v.location != null && v.location!.toLowerCase().contains(searchQuery)) ||
            v.region.label.toLowerCase().contains(searchQuery);
        if (!matches) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final byLevel = a.activityLevel.sortOrder.compareTo(b.activityLevel.sortOrder);
        return byLevel != 0 ? byLevel : a.name.compareTo(b.name);
      });

    if (filtered.isEmpty) {
      return EmptyStateView(
        title: 'Gunung Tidak Ditemukan',
        message: 'Tidak ada hasil untuk filter dan kata kunci saat ini.',
        action: OutlinedButton.icon(
          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
          onPressed: _resetFilters,
          label: const Text('Reset Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.palette.ink,
            side: BorderSide(color: context.palette.line),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        Caption(
          'Menampilkan ${filtered.length} dari ${response.totalCount}'.toUpperCase(),
        ),
        const SizedBox(height: 10),
        ...filtered.map((volcano) => _VolcanoRow(volcano: volcano)),
      ],
    );
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(volcanoSearchQueryProvider.notifier).state = '';
    ref.read(volcanoLevelFilterProvider.notifier).state = null;
    ref.read(volcanoRegionFilterProvider.notifier).state = VolcanoRegion.all;
    ref.read(showOnlyFavoritesFilterProvider.notifier).state = false;
  }
}

class _ChipRow extends StatelessWidget {
  final List<Widget> children;

  const _ChipRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: p.mut),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: p.ink),
              cursorColor: p.ink,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Cari gunung, provinsi, pulau',
                hintStyle: TextStyle(fontSize: 14, color: p.mut),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 18, color: p.mut),
            ),
        ],
      ),
    );
  }
}

class _VolcanoRow extends ConsumerWidget {
  final VolcanoSummary volcano;

  const _VolcanoRow({required this.volcano});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isFav = ref.watch(favoriteVolcanoesProvider).contains(volcano.id);
    final subtitle = volcano.location?.trim().isNotEmpty == true
        ? volcano.location!
        : volcano.region.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/volcanoes/${volcano.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                LevelMark(level: volcano.activityLevel, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        volcano.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: p.ink,
                        ),
                      ),
                      Text(
                        '${volcano.activityLevel.label} · $subtitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: p.mut),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFav ? 'Hapus dari Pantauan' : 'Pantau',
                  onPressed: () => ref
                      .read(favoriteVolcanoesProvider.notifier)
                      .toggleFavorite(volcano.id),
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 22,
                    color: isFav ? p.amb : p.mut,
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
