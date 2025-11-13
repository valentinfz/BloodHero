import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart'; // <- Ya no se usa aquí
import 'package:latlong2/latlong.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';

/// Permite habilitar o deshabilitar el uso de la ubicación desde la UI.
class LocationConsentNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setConsent(bool allow) => state = allow;
}

final locationConsentProvider = NotifierProvider<LocationConsentNotifier, bool>(
  LocationConsentNotifier.new,
);

/// Este provider expone la ubicación actual del usuario como un Stream.
/// Ahora es un provider "limpio": solo delega el trabajo al
/// [locationRepositoryProvider] y reacciona al [locationConsentProvider].
final userLocationProvider = StreamProvider.autoDispose<LatLng?>((ref) async* {
  final allowLocation = ref.watch(locationConsentProvider);
  if (!allowLocation) {
    yield null;
    return;
  }

  // Obtener el repositorio de ubicación
  final locationRepo = ref.watch(locationRepositoryProvider);

  // Emitir la última ubicación conocida RÁPIDAMENTE
  // (Esto llena la UI al instante mientras el stream se activa)
  try {
    final lastKnown = await locationRepo.getLastKnownOrCurrentLocation();
    if (lastKnown != null) {
      yield lastKnown;
    }
  } catch (_) {
    // No hacer nada si falla, el stream principal lo manejará
  }

  // Escuchar el stream de actualizaciones en vivo
  await for (final position in locationRepo.getLocationStream()) {
    yield position;
  }
});
