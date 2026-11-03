import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../volcano/data/models/volcano_model.dart';
import '../../volcano/providers/volcano_providers.dart';
import '../data/volcano_coordinates.dart';

class NearbyVolcano {
  final VolcanoSummary volcano;
  final VolcanoCoordinate coordinate;
  final double distanceKm;

  const NearbyVolcano({
    required this.volcano,
    required this.coordinate,
    required this.distanceKm,
  });

  String get formattedDistance {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

class UserLocationState {
  final Position? position;
  final bool isLoading;
  final String? errorMessage;
  final List<NearbyVolcano> nearbyVolcanoes;

  const UserLocationState({
    this.position,
    this.isLoading = false,
    this.errorMessage,
    this.nearbyVolcanoes = const [],
  });

  LatLng? get latLng =>
      position != null ? LatLng(position!.latitude, position!.longitude) : null;

  UserLocationState copyWith({
    Position? position,
    bool? isLoading,
    String? errorMessage,
    List<NearbyVolcano>? nearbyVolcanoes,
  }) {
    return UserLocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      nearbyVolcanoes: nearbyVolcanoes ?? this.nearbyVolcanoes,
    );
  }
}

class UserLocationNotifier extends StateNotifier<UserLocationState> {
  final Ref _ref;

  UserLocationNotifier(this._ref) : super(const UserLocationState());

  Future<void> detectLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Layanan lokasi (GPS) tidak aktif. Silakan aktifkan GPS.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Izin akses lokasi ditolak oleh pengguna.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // Hitung jarak ke seluruh gunung yang ada di cache
      final listAsync = _ref.read(volcanoListProvider);
      final volcanoes = listAsync.maybeWhen(
        data: (resp) => resp.volcanoes,
        orElse: () => <VolcanoSummary>[],
      );

      final nearbyList = <NearbyVolcano>[];
      for (final v in volcanoes) {
        final coord = VolcanoCoordinatesData.getCoordinate(
          v.name,
          location: v.location,
        );
        final distanceMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          coord.latitude,
          coord.longitude,
        );
        nearbyList.add(
          NearbyVolcano(
            volcano: v,
            coordinate: coord,
            distanceKm: distanceMeters / 1000.0,
          ),
        );
      }

      nearbyList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      state = UserLocationState(
        position: position,
        isLoading: false,
        nearbyVolcanoes: nearbyList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mendeteksi lokasi: ${e.toString()}',
      );
    }
  }

  void clearLocation() {
    state = const UserLocationState();
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, UserLocationState>((ref) {
  return UserLocationNotifier(ref);
});
