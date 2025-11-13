import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repos de Firebase (Implementaciones)
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_centers_repository.dart';
import '../../data/repositories/firebase_appointment_repository.dart';
import '../../data/repositories/firebase_alerts_repository.dart';
import '../../data/repositories/firebase_impact_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../data/repositories/firebase_content_repository.dart';
import '../../data/repositories/firebase_location_repository.dart';

// Contratos (Interfaces)
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/centers_repository.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../../domain/repositories/impact_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/location_repository.dart';

/// Provider para la lógica de Autenticación (login, registro, logout).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Provider para los datos del Usuario (perfil, historial, actualizar).
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

/// Provider para los Centros de Donación (lista, detalles).
final centersRepositoryProvider = Provider<CentersRepository>((ref) {
  return FirebaseCentersRepository();
});

/// Provider para las Citas (agendar, cancelar, ver, horarios).
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return FirebaseAppointmentRepository();
});

/// Provider para las Alertas.
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return FirebaseAlertsRepository();
});

/// Provider para el Impacto (logros, estadísticas).
final impactRepositoryProvider = Provider<ImpactRepository>((ref) {
  return FirebaseImpactRepository();
});

/// Provider para Contenido (tips, etc.).
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return FirebaseContentRepository();
});

/// Provider para el servicio de Ubicación (GPS).
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  // Corregido: La implementación se llama GeolocatorLocationRepository
  return FirebaseLocationRepository();
});
