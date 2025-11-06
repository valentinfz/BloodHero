import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Este provider expone la ubicación actual del usuario como un Stream
final userLocationProvider = StreamProvider.autoDispose<LatLng?>((ref) async* {
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
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    yield LatLng(pos.latitude, pos.longitude);
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
