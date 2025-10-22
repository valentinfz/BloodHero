import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_impact_entity.dart';
import 'centers_provider.dart'; // Importamos el provider del repositorio central

// Provider para obtener el perfil del usuario
final userProfileProvider = FutureProvider.autoDispose<UserEntity>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getUserProfile();
});

// Provider para la próxima cita
final nextAppointmentProvider = FutureProvider.autoDispose<AppointmentEntity>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getNextAppointment();
});

// Provider para las alertas cercanas
final nearbyAlertsProvider = FutureProvider.autoDispose<List<AlertEntity>>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getNearbyAlerts();
});

// Provider para el impacto del usuario
final userImpactProvider = FutureProvider.autoDispose<UserImpactEntity>((ref) async {
  // En el futuro, esto también vendría del repositorio.
  // Por ahora, lo simulamos aquí.
  await Future.delayed(const Duration(milliseconds: 1200));
  // TODO: Obtener datos de impacto reales del repositorio cuando se implemente.
  return  UserImpactEntity(
    livesHelped: 6,
    ranking: 'Donador leal',
  );
});

// Provider para obtener UN consejo de donación para mostrar en el Home
final donationTipProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(centersRepositoryProvider);
  final tips = await repository.getDonationTips();
  // Devuelve el primer consejo de la lista, o un mensaje por defecto si no hay ninguno.
  return tips.isNotEmpty ? tips.first : '¡Donar sangre salva vidas!';
});
