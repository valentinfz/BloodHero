import '../entities/alert_detail_entity.dart';
import '../entities/alert_entity.dart';
import '../entities/appointment_detail_entity.dart';
import '../entities/appointment_entity.dart';
import '../entities/center_detail_entity.dart';
import '../entities/center_entity.dart';
import '../entities/history_item_entity.dart';
import '../entities/user_entity.dart';
import '../entities/user_impact_entity.dart';
import '../entities/achievement_entity.dart';
import '../entities/achievement_detail_entity.dart';

// Este es el "contrato" que cualquier repositorio de datos debe cumplir.
abstract class CentersRepository {
  // Métodos para Centros
  Future<List<CenterEntity>> getCenters();
  Future<CenterDetailEntity> getCenterDetails(String centerIdentifier);

  // Métodos para Citas
  Future<List<AppointmentEntity>> getAppointments();
  Future<AppointmentDetailEntity> getAppointmentDetails(String appointmentId);
  Future<List<String>> getAvailableTimes({
    required String centerId,
    required DateTime date,
  });

  Future<AppointmentEntity> bookAppointment({
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  });

  Future<AppointmentEntity> rescheduleAppointment({
    required String appointmentId,
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  });

  /// Registra el resultado de una cita de donación (si se completó o no).
  ///
  /// Debería actualizar el historial del usuario y, si se completó,
  /// sus estadísticas de impacto (total de donaciones, vidas ayudadas, etc.).
  Future<void> logDonation({
    required String appointmentId,
    required bool wasCompleted,
    String? notes,
  });

  /// Cancela una cita agendada.
  ///
  /// Debería cambiar el estado de la cita y potencialmente liberar el cupo.
  Future<void> cancelAppointment({required String appointmentId});

  // Métodos para el Home
  Future<AppointmentEntity> getNextAppointment();
  Future<List<AlertEntity>> getNearbyAlerts();
  Future<UserEntity> getUserProfile();
  Future<List<String>> getDonationTips();

  // Métodos para el Impacto y logros del usuario
  Future<UserImpactEntity> getUserImpactStats();
  Future<List<AchievementEntity>> getAchievements();
  Future<AchievementDetailEntity> getAchievementDetails(String title);

  // Métodos para Alertas (Detalle)
  Future<AlertDetailEntity> getAlertDetails(String identifier);

  // Método para el Historial
  Future<List<HistoryItemEntity>> getDonationHistory();
}
