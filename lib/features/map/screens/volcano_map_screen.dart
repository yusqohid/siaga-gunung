import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/activity_level_badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../volcano/data/models/volcano_model.dart';
import '../../volcano/providers/volcano_providers.dart';
import '../data/volcano_coordinates.dart';
import '../services/location_service.dart';

class VolcanoMapScreen extends ConsumerStatefulWidget {
  const VolcanoMapScreen({super.key});

  @override
  ConsumerState<VolcanoMapScreen> createState() => _VolcanoMapScreenState();
}

class _VolcanoMapScreenState extends ConsumerState<VolcanoMapScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  VolcanoSummary? _selectedVolcano;
  bool _showLegend = true;

  // Local filter states for map
  VolcanoRegion _selectedRegion = VolcanoRegion.all;
  ActivityLevel? _selectedLevel;
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _selectRegion(VolcanoRegion region) {
    setState(() {
      _selectedRegion = region;
    });

    final targetCentroid = VolcanoCoordinatesData.regionCentroids[region] ??
        const LatLng(-2.5, 118.0);
    final targetZoom = VolcanoCoordinatesData.regionZoomLevels[region] ?? 4.8;
    _animatedMapMove(targetCentroid, targetZoom);
  }

  void _selectVolcano(VolcanoSummary volcano) {
    setState(() {
      _selectedVolcano = volcano;
    });

    final coord = VolcanoCoordinatesData.getCoordinate(
      volcano.name,
      location: volcano.location,
    );
    _animatedMapMove(coord.latLng, 8.5);
  }

  double _getRecommendationRadiusMeters(VolcanoSummary volcano) {
    switch (volcano.activityLevel) {
      case ActivityLevel.levelIV:
        return 7000.0; // 7 km
      case ActivityLevel.levelIII:
        return 5000.0; // 5 km
      case ActivityLevel.levelII:
        return 3000.0; // 3 km
      case ActivityLevel.levelI:
        return 1500.0; // 1.5 km
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(volcanoListProvider);
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);
    final userLocationState = ref.watch(userLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Sebaran Gunung Api'),
        actions: [
          IconButton(
            icon: Icon(
              _showLegend ? Icons.layers_rounded : Icons.layers_outlined,
              color: _showLegend ? AppColors.primary : null,
            ),
            tooltip: _showLegend ? 'Sembunyikan Legenda' : 'Tampilkan Legenda',
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => ref.read(volcanoListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const LoadingView(message: 'Memuat peta sebaran gunung...'),
        error: (err, _) => ErrorView(
          title: 'Gagal Memuat Peta',
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(volcanoListProvider.notifier).refresh(),
        ),
        data: (response) {
          // Filter volcanoes for map
          final visibleVolcanoes = response.volcanoes.where((v) {
            if (_onlyFavorites && !favoriteIds.contains(v.id)) return false;
            if (_selectedLevel != null && v.activityLevel != _selectedLevel) return false;
            if (_selectedRegion != VolcanoRegion.all && v.region != _selectedRegion) return false;
            return true;
          }).toList();

          return Stack(
            children: [
              // Interactive Map Canvas
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(-2.5, 118.0),
                  initialZoom: 4.8,
                  minZoom: 3.5,
                  maxZoom: 14.0,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(-12.5, 93.0),
                      const LatLng(8.5, 142.5),
                    ),
                  ),
                  onTap: (tapPosition, point) {
                    if (_selectedVolcano != null) {
                      setState(() {
                        _selectedVolcano = null;
                      });
                    }
                  },
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.siagagunung.app',
                  ),

                  // Hazard Recommendation Radius Circle for selected volcano
                  if (_selectedVolcano != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: VolcanoCoordinatesData.getCoordinate(
                            _selectedVolcano!.name,
                            location: _selectedVolcano!.location,
                          ).latLng,
                          radius: _getRecommendationRadiusMeters(_selectedVolcano!),
                          useRadiusInMeter: true,
                          color: _selectedVolcano!.activityLevel.color.withOpacity(0.18),
                          borderColor: _selectedVolcano!.activityLevel.color,
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),

                  // Marker Layer for Volcanoes and User Location
                  MarkerLayer(
                    markers: [
                      // User Location marker (GPS)
                      if (userLocationState.latLng != null)
                        Marker(
                          point: userLocationState.latLng!,
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.24),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Volcano pins
                      ...visibleVolcanoes.map((volcano) {
                        final coord = VolcanoCoordinatesData.getCoordinate(
                          volcano.name,
                          location: volcano.location,
                        );
                        final isSelected = _selectedVolcano?.id == volcano.id;
                        final isFav = favoriteIds.contains(volcano.id);
                        final isHighAlert = volcano.activityLevel == ActivityLevel.levelIV ||
                            volcano.activityLevel == ActivityLevel.levelIII;

                        return Marker(
                          point: coord.latLng,
                          width: isSelected ? 52 : (isHighAlert ? 44 : 36),
                          height: isSelected ? 52 : (isHighAlert ? 44 : 36),
                          child: GestureDetector(
                            onTap: () => _selectVolcano(volcano),
                            child: _buildVolcanoMarker(
                              volcano: volcano,
                              isSelected: isSelected,
                              isFav: isFav,
                              isHighAlert: isHighAlert,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Top Filters Overlay
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    // Region Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: VolcanoRegion.values.map((region) {
                            final isSel = _selectedRegion == region;
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ChoiceChip(
                                label: Text(region.label),
                                selected: isSel,
                                onSelected: (_) => _selectRegion(region),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                ),
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceVariant,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide.none,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Level Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Favorites filter chip
                            FilterChip(
                              avatar: Icon(
                                _onlyFavorites ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 16,
                                color: _onlyFavorites ? Colors.white : Colors.amber.shade800,
                              ),
                              label: Text('⭐ Favorit (${favoriteIds.length})'),
                              selected: _onlyFavorites,
                              onSelected: (val) {
                                setState(() {
                                  _onlyFavorites = val;
                                });
                              },
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: _onlyFavorites ? FontWeight.w700 : FontWeight.w500,
                                color: _onlyFavorites ? Colors.white : AppColors.textPrimary,
                              ),
                              selectedColor: Colors.amber.shade800,
                              backgroundColor: AppColors.surfaceVariant,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide.none,
                              ),
                            ),
                            const SizedBox(width: 4),

                            // All levels chip
                            ChoiceChip(
                              label: const Text('Semua Status'),
                              selected: _selectedLevel == null,
                              onSelected: (_) {
                                setState(() {
                                  _selectedLevel = null;
                                });
                              },
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedLevel == null ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedLevel == null ? Colors.white : AppColors.textPrimary,
                              ),
                              selectedColor: AppColors.textPrimary,
                              backgroundColor: AppColors.surfaceVariant,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide.none,
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Level chips
                            ...ActivityLevel.values.map((lvl) {
                              final isSel = _selectedLevel == lvl;
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: ChoiceChip(
                                  label: Text('${lvl.title} (${lvl.label})'),
                                  selected: isSel,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedLevel = isSel ? null : lvl;
                                    });
                                  },
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? Colors.white : lvl.color,
                                  ),
                                  selectedColor: lvl.color,
                                  backgroundColor: AppColors.surfaceVariant,
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide.none,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Map Controls (Zoom in, Zoom out, Recenter, GPS Detect)
              Positioned(
                right: 14,
                bottom: _selectedVolcano != null ? 195 : 20,
                child: Column(
                  children: [
                    _buildMapIconButton(
                      icon: userLocationState.isLoading
                          ? Icons.hourglass_top_rounded
                          : Icons.my_location_rounded,
                      tooltip: 'Cari Gunung Terdekat dari Lokasi Saya',
                      iconColor: userLocationState.position != null ? Colors.blue.shade700 : null,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref.read(userLocationProvider.notifier).detectLocation();
                        final updated = ref.read(userLocationProvider);
                        if (updated.errorMessage != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(updated.errorMessage!),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (updated.nearbyVolcanoes.isNotEmpty) {
                          final closest = updated.nearbyVolcanoes.first;
                          _selectVolcano(closest.volcano);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gunung terdekat: ${closest.volcano.name} (${closest.formattedDistance} dari Anda)',
                              ),
                              duration: const Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapIconButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Perbesar',
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          (currentZoom + 1.0).clamp(3.5, 14.0),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapIconButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Perkecil',
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          (currentZoom - 1.0).clamp(3.5, 14.0),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildMapIconButton(
                      icon: Icons.center_focus_strong_rounded,
                      tooltip: 'Pusatkan Peta Indonesia',
                      onPressed: () {
                        _animatedMapMove(const LatLng(-2.5, 118.0), 4.8);
                      },
                    ),
                  ],
                ),
              ),

              // Floating Collapsible Legend (Bottom-Left)
              if (_showLegend)
                Positioned(
                  left: 14,
                  bottom: _selectedVolcano != null ? 180 : 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Legenda Level Aktivitas',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...ActivityLevel.values.map(
                          (lvl) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: lvl.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${lvl.title} (${lvl.label})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: lvl.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected Volcano Floating Card
              if (_selectedVolcano != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 14,
                  child: _buildSelectedVolcanoCard(
                    context,
                    _selectedVolcano!,
                    favoriteIds.contains(_selectedVolcano!.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVolcanoMarker({
    required VolcanoSummary volcano,
    required bool isSelected,
    required bool isFav,
    required bool isHighAlert,
  }) {
    final color = volcano.activityLevel.color;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Outer halo ring for high alert or selected marker
        if (isHighAlert || isSelected)
          Container(
            width: isSelected ? 48 : 40,
            height: isSelected ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isSelected ? 0.35 : 0.22),
            ),
          ),

        // Main pin bubble
        Container(
          width: isSelected ? 34 : (isHighAlert ? 30 : 26),
          height: isSelected ? 34 : (isHighAlert ? 30 : 26),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            volcano.activityLevel.code,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: isSelected ? 13 : 11,
            ),
          ),
        ),

        // Favorite star badge
        if (isFav)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 11,
                color: Colors.amber,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedVolcanoCard(
    BuildContext context,
    VolcanoSummary volcano,
    bool isFav,
  ) {
    final coord = VolcanoCoordinatesData.getCoordinate(
      volcano.name,
      location: volcano.location,
    );
    final userLocationState = ref.watch(userLocationProvider);
    final nearby = userLocationState.nearbyVolcanoes
        .where((n) => n.volcano.id == volcano.id)
        .firstOrNull;
    final radiusKm = (_getRecommendationRadiusMeters(volcano) / 1000.0).toStringAsFixed(1);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: volcano.activityLevel.color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badges and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ActivityLevelBadge(level: volcano.activityLevel, compact: true),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        volcano.region.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isFav ? Colors.amber.shade700 : AppColors.textMuted,
                        size: 24,
                      ),
                      tooltip: isFav ? 'Hapus dari Pantauan' : 'Sematkan ke Pantauan',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        ref.read(favoriteVolcanoesProvider.notifier).toggleFavorite(volcano.id);
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _selectedVolcano = null;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Volcano Name and Location
            Text(
              volcano.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    volcano.location ?? 'Lokasi tidak disebutkan',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (coord.elevation > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '▲ ${coord.elevation} mdpl',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Radius Bahaya & Jarak dari Pengguna
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: volcano.activityLevel.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: volcano.activityLevel.color.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Radius Bahaya: ~$radiusKm km',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: volcano.activityLevel.color,
                    ),
                  ),
                ),
                if (nearby != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.near_me_rounded, size: 10, color: Colors.blue.shade700),
                        const SizedBox(width: 3),
                        Text(
                          '${nearby.formattedDistance} dari Anda',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Button to Detail
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Buka Detail Aktivitas Lengkap'),
                style: FilledButton.styleFrom(
                  backgroundColor: volcano.activityLevel.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  context.push('/volcanoes/${volcano.id}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required String tooltip,
    Color? iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
