import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_impact_entity.dart';

// Provider para obtener el perfil del usuario
final userProfileProvider = FutureProvider.autoDispose<UserEntity>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  debugPrint("Provider: Obteniendo perfil de usuario...");
  return repository.getUserProfile();
});

// Provider para la próxima cita
final nextAppointmentProvider = FutureProvider.autoDispose<AppointmentEntity>((
  ref,
) {
  final repository = ref.watch(centersRepositoryProvider);
  debugPrint("Provider: Obteniendo próxima cita...");
  return repository.getNextAppointment();
});

// Provider para las alertas cercanas
final nearbyAlertsProvider = FutureProvider.autoDispose<List<AlertEntity>>((
  ref,
) async {
  final repository = ref.watch(centersRepositoryProvider);
  debugPrint("Provider: Obteniendo alertas cercanas...");
  try {
    final alerts = await repository.getNearbyAlerts();
    debugPrint("Provider: Alertas obtenidas: ${alerts.length} alertas.");
    return alerts;
  } catch (e) {
    debugPrint("Provider: ERROR al obtener alertas: $e");
    rethrow;
  }
});

// Provider para el impacto del usuario
final userImpactProvider = FutureProvider.autoDispose<UserImpactEntity>((
  ref,
) async {
  debugPrint("Provider: Obteniendo impacto de usuario...");
  final repository = ref.watch(centersRepositoryProvider);
  final impactStats = await repository.getUserImpactStats();
  final achievements = await repository.getAchievements();

  debugPrint("Provider: Impacto y logros obtenidos.");
  return impactStats.copyWith(
    achievementsCount: achievements.length,
  );
});

// Provider para el consejo de donación
final donationTipProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(centersRepositoryProvider);
  debugPrint("Provider: Obteniendo consejo de donación...");
  final tips = await repository.getDonationTips();
  debugPrint(
    "Provider: Consejos obtenidos: ${tips.length}. Mostrando el primero.",
  );
  if (tips.isEmpty) {
    return '¡Gracias por ser un héroe!';
  }
  return tips.first;
});
