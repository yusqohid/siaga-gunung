import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/ui_kit.dart';
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

  VolcanoRegion _selectedRegion = VolcanoRegion.all;
  ActivityLevel? _selectedLevel;
  double _fittedZoom = 4.0;

  static const LatLng _indonesiaCenter = LatLng(-2.5, 118.0);

  double _zoomForWidth(double width) {
    // Fit roughly 48 degrees of longitude across the map width.
    const longitudeSpan = 48.0;
    final worldPixels = width * 360 / longitudeSpan;
    final zoom = math.log(worldPixels / 256) / math.ln2;
    return zoom.clamp(3.0, 6.0);
  }

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
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final animation = CurvedAnimation(
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
    setState(() => _selectedRegion = region);
    final target = VolcanoCoordinatesData.regionCentroids[region] ??
        const LatLng(-2.5, 118.0);
    final zoom = VolcanoCoordinatesData.regionZoomLevels[region] ?? 4.8;
    _animatedMapMove(target, zoom);
  }

  void _selectVolcano(VolcanoSummary volcano) {
    setState(() => _selectedVolcano = volcano);
    final coord = VolcanoCoordinatesData.getCoordinate(
      volcano.name,
      location: volcano.location,
    );
    _animatedMapMove(coord.latLng, 8.5);
  }

  double _recommendationRadiusMeters(VolcanoSummary volcano) {
    switch (volcano.activityLevel) {
      case ActivityLevel.levelIV:
        return 7000.0;
      case ActivityLevel.levelIII:
        return 5000.0;
      case ActivityLevel.levelII:
        return 3000.0;
      case ActivityLevel.levelI:
        return 1500.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(volcanoListProvider);
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ScreenHeader(eyebrow: 'Sebaran', title: 'Peta Gunung Api'),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  PillChip(
                    label: 'Semua',
                    selected: _selectedLevel == null,
                    onTap: () => setState(() => _selectedLevel = null),
                  ),
                  for (final level in ActivityLevel.values) ...[
                    const SizedBox(width: 8),
                    PillChip(
                      label: '${level.code} ${level.label}',
                      selected: _selectedLevel == level,
                      onTap: () => setState(() => _selectedLevel = level),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (var i = 0; i < VolcanoRegion.values.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    PillChip(
                      label: VolcanoRegion.values[i].label,
                      selected: _selectedRegion == VolcanoRegion.values[i],
                      onTap: () => _selectRegion(VolcanoRegion.values[i]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: p.card,
                    child: listAsync.when(
                      loading: () =>
                          const LoadingView(message: 'Memuat peta sebaran gunung...'),
                      error: (err, _) => ErrorView(
                        title: 'Gagal Memuat Peta',
                        message: err.toString().replaceFirst('Exception: ', ''),
                        onRetry: () =>
                            ref.read(volcanoListProvider.notifier).refresh(),
                      ),
                      data: (response) => _buildMap(context, response),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Wrap(
                spacing: 14,
                runSpacing: 6,
                children: ActivityLevel.values
                    .map(
                      (level) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: level.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${level.code} ${level.label}',
                            style: TextStyle(fontSize: 13, color: p.mut),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: Caption('Geser peta · ketuk penanda untuk detail'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, VolcanoListResponse response) {
    final favoriteIds = ref.watch(favoriteVolcanoesProvider);
    final userLocationState = ref.watch(userLocationProvider);

    final visible = response.volcanoes.where((v) {
      if (_selectedLevel != null && v.activityLevel != _selectedLevel) return false;
      if (_selectedRegion != VolcanoRegion.all && v.region != _selectedRegion) {
        return false;
      }
      return true;
    }).toList();

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            _fittedZoom = _zoomForWidth(constraints.maxWidth);
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _indonesiaCenter,
                initialZoom: _fittedZoom,
                minZoom: 3.0,
                maxZoom: 14.0,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(-12.5, 93.0),
                    const LatLng(8.5, 142.5),
                  ),
                ),
                onTap: (tapPosition, point) {
                  if (_selectedVolcano != null) {
                    setState(() => _selectedVolcano = null);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.siagagunung.app',
                ),
                if (_selectedVolcano != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: VolcanoCoordinatesData.getCoordinate(
                          _selectedVolcano!.name,
                          location: _selectedVolcano!.location,
                        ).latLng,
                        radius: _recommendationRadiusMeters(_selectedVolcano!),
                        useRadiusInMeter: true,
                        color:
                            _selectedVolcano!.activityLevel.color.withValues(alpha: 0.18),
                        borderColor: _selectedVolcano!.activityLevel.color,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (userLocationState.latLng != null)
                      Marker(
                        point: userLocationState.latLng!,
                        width: 36,
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.24),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    ...visible.map((volcano) {
                      final coord = VolcanoCoordinatesData.getCoordinate(
                        volcano.name,
                        location: volcano.location,
                      );
                      final isSelected = _selectedVolcano?.id == volcano.id;
                      final isFav = favoriteIds.contains(volcano.id);

                      return Marker(
                        point: coord.latLng,
                        width: isSelected ? 46 : 36,
                        height: isSelected ? 46 : 36,
                        child: GestureDetector(
                          onTap: () => _selectVolcano(volcano),
                          child: _VolcanoMarker(
                            volcano: volcano,
                            isSelected: isSelected,
                            isFavorite: isFav,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),

        // Map controls
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _MapControlButton(
                icon: userLocationState.isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.my_location_rounded,
                tooltip: 'Gunung terdekat dari lokasi saya',
                highlighted: userLocationState.position != null,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(userLocationProvider.notifier).detectLocation();
                  final updated = ref.read(userLocationProvider);
                  if (updated.errorMessage != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(updated.errorMessage!)),
                    );
                  } else if (updated.nearbyVolcanoes.isNotEmpty) {
                    final closest = updated.nearbyVolcanoes.first;
                    _selectVolcano(closest.volcano);
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
              const SizedBox(height: 6),
              _MapControlButton(
                icon: Icons.add_rounded,
                tooltip: 'Perbesar',
                onPressed: () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    (zoom + 1).clamp(3.5, 14.0),
                  );
                },
              ),
              const SizedBox(height: 6),
              _MapControlButton(
                icon: Icons.remove_rounded,
                tooltip: 'Perkecil',
                onPressed: () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    (zoom - 1).clamp(3.5, 14.0),
                  );
                },
              ),
              const SizedBox(height: 6),
              _MapControlButton(
                icon: Icons.center_focus_strong_rounded,
                tooltip: 'Pusatkan Indonesia',
                onPressed: () => _animatedMapMove(_indonesiaCenter, _fittedZoom),
              ),
            ],
          ),
        ),

        // Selected volcano sheet
        if (_selectedVolcano != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _SelectedVolcanoCard(
              volcano: _selectedVolcano!,
              onClose: () => setState(() => _selectedVolcano = null),
            ),
          ),
      ],
    );
  }
}

class _VolcanoMarker extends StatelessWidget {
  final VolcanoSummary volcano;
  final bool isSelected;
  final bool isFavorite;

  const _VolcanoMarker({
    required this.volcano,
    required this.isSelected,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = volcano.activityLevel.color;
    final size = isSelected ? 32.0 : 26.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (isSelected)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.28),
            ),
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            volcano.activityLevel.code,
            style: TextStyle(
              color: volcano.activityLevel == ActivityLevel.levelII ? p.ink : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSelected ? 12 : 10,
            ),
          ),
        ),
        if (isFavorite)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, size: 10, color: AppColors.amber),
            ),
          ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool highlighted;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: highlighted ? Colors.blue.shade700 : p.ink,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _SelectedVolcanoCard extends StatelessWidget {
  final VolcanoSummary volcano;
  final VoidCallback onClose;

  const _SelectedVolcanoCard({required this.volcano, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final subtitle = volcano.location?.trim().isNotEmpty == true
        ? volcano.location!
        : volcano.region.label;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              LevelMark(level: volcano.activityLevel, size: 36),
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
              GestureDetector(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded, size: 18, color: p.mut),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => context.push('/volcanoes/${volcano.id}'),
              child: const Text('LIHAT DETAIL'),
            ),
          ),
        ],
      ),
    );
  }
}
