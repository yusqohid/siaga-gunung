import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/activity_level_badge.dart';
import '../../../shared/widgets/data_freshness_badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/models/volcano_model.dart';
import '../providers/volcano_providers.dart';

class VolcanoListScreen extends ConsumerStatefulWidget {
  const VolcanoListScreen({super.key});

  @override
  ConsumerState<VolcanoListScreen> createState() => _VolcanoListScreenState();
}

class _VolcanoListScreenState extends ConsumerState<VolcanoListScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    final showOnlyFavorites = ref.watch(showOnlyFavoritesFilterProvider);
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);
    final searchQuery = ref.watch(volcanoSearchQueryProvider);

    final isAnyFilterActive = searchQuery.isNotEmpty ||
        selectedLevel != null ||
        selectedRegion != VolcanoRegion.all ||
        showOnlyFavorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Aktivitas Gunung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.read(volcanoListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(volcanoSearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama gunung, lokasi, pulau...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(volcanoSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Filter row 1: Wilayah / Kepulauan
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...VolcanoRegion.values.map(
                        (region) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildFilterChip(
                            label: region.label,
                            isSelected: selectedRegion == region,
                            color: AppColors.primary,
                            onSelected: () {
                              ref.read(volcanoRegionFilterProvider.notifier).state = region;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Filter row 2: Status Level & Favorit
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // ⭐ Favorit filter chip
                      _buildFilterChip(
                        label: '⭐ Favorit (${favoriteIds.length})',
                        isSelected: showOnlyFavorites,
                        color: Colors.amber.shade800,
                        onSelected: () {
                          ref.read(showOnlyFavoritesFilterProvider.notifier).state =
                              !showOnlyFavorites;
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Semua Status',
                        isSelected: selectedLevel == null,
                        onSelected: () {
                          ref.read(volcanoLevelFilterProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 6),
                      ...ActivityLevel.values.map(
                        (level) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildFilterChip(
                            label: '${level.title} (${level.label})',
                            isSelected: selectedLevel == level,
                            color: level.color,
                            onSelected: () {
                              ref.read(volcanoLevelFilterProvider.notifier).state =
                                  selectedLevel == level ? null : level;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Reset filter action if active
                if (isAnyFilterActive) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _resetAllFilters,
                        child: const Row(
                          children: [
                            Icon(Icons.filter_alt_off_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Reset Filter',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body content
          Expanded(
            child: listAsync.when(
              loading: () => const LoadingView(message: 'Memuat daftar gunung...'),
              error: (err, _) => ErrorView(
                title: 'Gagal Memuat Data',
                message: err.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.read(volcanoListProvider.notifier).refresh(),
              ),
              data: (response) => _buildVolcanoList(context, response),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAllFilters() {
    _searchController.clear();
    ref.read(volcanoSearchQueryProvider.notifier).state = '';
    ref.read(volcanoLevelFilterProvider.notifier).state = null;
    ref.read(volcanoRegionFilterProvider.notifier).state = VolcanoRegion.all;
    ref.read(showOnlyFavoritesFilterProvider.notifier).state = false;
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onSelected,
  }) {
    final chipColor = color ?? AppColors.primary;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selectedColor: chipColor,
      backgroundColor: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? chipColor : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildVolcanoList(BuildContext context, VolcanoListResponse response) {
    final searchQuery = ref.watch(volcanoSearchQueryProvider).trim().toLowerCase();
    final selectedLevel = ref.watch(volcanoLevelFilterProvider);
    final selectedRegion = ref.watch(volcanoRegionFilterProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesFilterProvider);
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);

    // Apply client filters
    final filtered = response.volcanoes.where((v) {
      if (showOnlyFavorites && !favoriteIds.contains(v.id)) {
        return false;
      }
      if (selectedLevel != null && v.activityLevel != selectedLevel) {
        return false;
      }
      if (selectedRegion != VolcanoRegion.all && v.region != selectedRegion) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesSearch = v.name.toLowerCase().contains(searchQuery) ||
            (v.location != null && v.location!.toLowerCase().contains(searchQuery)) ||
            v.region.label.toLowerCase().contains(searchQuery);
        if (!matchesSearch) return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return EmptyStateView(
        title: 'Gunung Tidak Ditemukan',
        message: 'Tidak ada hasil untuk filter dan kata kunci saat ini.',
        action: OutlinedButton.icon(
          icon: const Icon(Icons.refresh_rounded, size: 16),
          onPressed: _resetAllFilters,
          label: const Text('Reset Semua Filter'),
        ),
      );
    }

    // If a specific level is filtered, region filtered, or searching, show flat list
    final isFiltering = selectedLevel != null ||
        searchQuery.isNotEmpty ||
        selectedRegion != VolcanoRegion.all ||
        showOnlyFavorites;

    return RefreshIndicator(
      onRefresh: () => ref.read(volcanoListProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Metadata status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DataFreshnessBadge(
                fetchedAt: response.fetchedAt,
                isStale: response.isStale,
                warningMessage: response.warningMessage,
              ),
              Text(
                'Menampilkan ${filtered.length} dari ${response.totalCount}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (isFiltering) ...[
            // Flat list when searching or filtering
            ...filtered.map((v) => _buildVolcanoCard(context, v)),
          ] else ...[
            // Grouped by level: Level IV, III, II, I (PRD Section 9.2 & AC-03)
            // Empty levels must be displayed with count 0 and empty state
            ...ActivityLevel.values.map((level) {
              final levelVolcanoes = response.volcanoes
                  .where((v) => v.activityLevel == level)
                  .toList();
              return _buildLevelGroupSection(context, level, levelVolcanoes);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelGroupSection(
    BuildContext context,
    ActivityLevel level,
    List<VolcanoSummary> volcanoes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level Group Header
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: level.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: level.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${level.title} (${level.label})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: level.color,
                    ),
                  ),
                ],
              ),
              Text(
                '${volcanoes.length} Gunung',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: level.color,
                ),
              ),
            ],
          ),
        ),

        // Group Content: Empty state or List of volcanoes
        if (volcanoes.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Tidak ada gunung api pada ${level.title} (${level.label}) saat ini.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          ...volcanoes.map((v) => _buildVolcanoCard(context, v)),
      ],
    );
  }

  Widget _buildVolcanoCard(BuildContext context, VolcanoSummary volcano) {
    final favorites = ref.watch(favoriteVolcanoesProvider);
    final isFav = favorites.contains(volcano.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/volcanoes/${volcano.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              // Level indicator badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: volcano.activityLevel.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: volcano.activityLevel.color.withOpacity(0.4),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  volcano.activityLevel.code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: volcano.activityLevel.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name, region, and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            volcano.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFav) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            volcano.region.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            volcano.location ?? 'Lokasi tidak disebutkan',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Status tag
              ActivityLevelBadge(
                level: volcano.activityLevel,
                compact: true,
                showDot: false,
              ),

              // Star favorite toggle button
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFav ? Colors.amber.shade700 : AppColors.textMuted,
                  size: 22,
                ),
                tooltip: isFav ? 'Hapus dari Pantauan' : 'Sematkan ke Pantauan (Beranda)',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  ref.read(favoriteVolcanoesProvider.notifier).toggleFavorite(volcano.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${volcano.name} dihapus dari Gunung Pantauan.'
                            : '${volcano.name} disematkan ke Gunung Pantauan di Beranda.',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
