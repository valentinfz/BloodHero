import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_impact_entity.dart';
import 'centers_provider.dart';

final userProfileProvider = FutureProvider.autoDispose<UserEntity>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getUserProfile();
});

// Provider para la próxima cita
final nextAppointmentProvider = FutureProvider.autoDispose<AppointmentEntity>((
  ref,
) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getNextAppointment();
});

// Provider para las alertas cercanas
final nearbyAlertsProvider = FutureProvider.autoDispose<List<AlertEntity>>((
  ref,
) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getNearbyAlerts();
});

// Provider para el impacto del usuario
final userImpactProvider = FutureProvider.autoDispose<UserImpactEntity>((
  ref,
) async {
  // Esto también vendría del repositorio en Firebase pero por ahora lo simulamos
  await Future.delayed(const Duration(milliseconds: 1200));
  return UserImpactEntity(livesHelped: 6, ranking: 'Donador leal');
});
