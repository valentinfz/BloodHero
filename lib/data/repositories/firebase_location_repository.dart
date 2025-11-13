import 'package:bloodhero/domain/repositories/location_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FirebaseLocationRepository implements LocationRepository {
  // Configuración del stream de Geolocator
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 25, // Actualiza cada 25 metros
  );

  @override
  Future<LatLng?> getLastKnownOrCurrentLocation() async {
    try {

      final (hasPermission, serviceEnabled) = await _checkPermissions();
      if (!hasPermission || !serviceEnabled) {
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LatLng(lastKnown.latitude, lastKnown.longitude);
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return LatLng(currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      // Si hay error (ej. timeout), devolvemos null
      return null;
    }
  }

  @override
  Stream<LatLng?> getLocationStream() async* {
    final (hasPermission, serviceEnabled) = await _checkPermissions();
    if (!hasPermission || !serviceEnabled) {
      yield null;
      return; // Termina el stream si no hay permisos
    }
    try {
      await for (final position in Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      )) {
        yield LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      // Si el stream falla (ej. se desactivó el GPS), emitir null
      yield null;
    }
  }

  /// Helper interno para verificar permisos y servicios de ubicación.
  Future<(bool hasPermission, bool serviceEnabled)> _checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return (false, false);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return (false, serviceEnabled);
    }

    return (true, serviceEnabled);
  }
}
