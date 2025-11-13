import 'package:latlong2/latlong.dart';

abstract class LocationRepository {
  /// Obtiene la última ubicación conocida o la actual.
  ///
  /// Debería intentar devolver una ubicación lo más rápido posible,
  /// idealmente la última conocida, o la actual si no hay ninguna.
  /// Puede devolver null si no hay permiso o no se puede obtener.
  Future<LatLng?> getLastKnownOrCurrentLocation();

  /// Expone un Stream con las actualizaciones de la ubicación del usuario.
  ///
  /// Debería manejar internamente la lógica de permisos y servicios.
  /// Si los permisos son denegados o el servicio está apagado,
  /// el stream debería emitir `null` o no emitir nada.
  Stream<LatLng?> getLocationStream();
}
