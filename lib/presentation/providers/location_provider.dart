import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Permite habilitar o deshabilitar el uso de la ubicación desde la UI.
class LocationConsentNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setConsent(bool allow) => state = allow;
}

final locationConsentProvider =
    NotifierProvider<LocationConsentNotifier, bool>(LocationConsentNotifier.new);

// Este provider expone la ubicación actual del usuario como un Stream
final userLocationProvider = StreamProvider.autoDispose<LatLng?>((ref) async* {
  final allowLocation = ref.watch(locationConsentProvider);
  if (!allowLocation) {
    yield null;
    return;
  }

  // Verificar servicios y permisos
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield null; // O lanzar error
    return;
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission != LocationPermission.always &&
      permission != LocationPermission.whileInUse) {
    yield null; // O lanzar error
    return;
  }

  // Obtener posición inicial
  try {
    final lastKnown = await Geolocator.getLastKnownPosition();

    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 25,
        ),
      );
    } catch (_) {
      currentPosition = lastKnown;
    }

    if (currentPosition != null) {
      yield LatLng(currentPosition.latitude, currentPosition.longitude);
    } else {
      yield null;
    }
  } catch (e) {
    yield null; // Error al obtener posición inicial
  }

  // Escuchar cambios de posición
  await for (final position in Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      distanceFilter: 25,
      accuracy: LocationAccuracy.best,
    ),
  )) {
    yield LatLng(position.latitude, position.longitude);
  }
});
