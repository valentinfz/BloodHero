import 'dart:math';
import 'package:bloodhero/presentation/providers/location_provider.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/user_entity.dart';

// Provider para obtener el perfil del usuario
final userProfileProvider = FutureProvider.autoDispose<UserEntity>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  debugPrint("Provider: Obteniendo perfil de usuario...");
  return repository.getUserProfile();
});

// Provider para la próxima cita
final nextAppointmentProvider = FutureProvider.autoDispose<AppointmentEntity>((
  ref,
) {
  final repository = ref.watch(appointmentRepositoryProvider);
  debugPrint("Provider: Obteniendo próxima cita...");
  return repository.getNextAppointment();
});

// Provider para las alertas cercanas
final nearbyAlertsProvider = FutureProvider.autoDispose<List<AlertEntity>>((
  ref,
) async {
  final repository = ref.watch(alertsRepositoryProvider);
  final locationAsync = ref.watch(userLocationProvider);
  debugPrint("Provider: Obteniendo alertas cercanas...");
  try {
    final alerts = await repository.getNearbyAlerts();
    final userLocation = locationAsync.asData?.value;
    if (userLocation == null) {
      debugPrint(
        "Provider: Alertas obtenidas: ${alerts.length} (sin ubicación para calcular distancia)",
      );
      return alerts;
    }

    const distance = Distance();
    final decorated = alerts.map((alert) {
      if (alert.latitude == null || alert.longitude == null) {
        return alert;
      }
      final meters = distance(
        LatLng(userLocation.latitude, userLocation.longitude),
        LatLng(alert.latitude!, alert.longitude!),
      );
      final distanceText = meters >= 1000
          ? '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km'
          : '${meters.round()} m';
      return alert.copyWith(distance: distanceText);
    }).toList();

    debugPrint("Provider: Alertas obtenidas: ${decorated.length} alertas.");
    return decorated;
  } catch (e) {
    debugPrint("Provider: ERROR al obtener alertas: $e");
    rethrow;
  }
});

// Provider para el consejo de donación
final donationTipProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  debugPrint("Provider: Obteniendo consejo de donación...");
  final tips = await repository.getDonationTips();

  if (tips.isEmpty) {
    debugPrint("Provider: No se encontraron tips. Mostrando fallback.");
    return '¡Gracias por ser un héroe!';
  }

  // Lógica para seleccionar uno al azar
  final random = Random();
  final index = random.nextInt(tips.length);
  final randomTip = tips[index];

  debugPrint(
    "Provider: Consejos obtenidos: ${tips.length}. Mostrando el tip $index: \"$randomTip\"",
  );

  return randomTip;
});
