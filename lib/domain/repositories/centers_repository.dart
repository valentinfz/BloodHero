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
  Future<CenterDetailEntity> getCenterDetails(String centerName);

  // Métodos para Citas
  Future<List<AppointmentEntity>> getAppointments();
  Future<AppointmentDetailEntity> getAppointmentDetails(String appointmentId);
  Future<List<String>> getAvailableTimes(String centerName, DateTime date);
  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  });

  // Métodos para el Home
  Future<AppointmentEntity> getNextAppointment();
  Future<List<AlertEntity>> getNearbyAlerts();
  Future<UserEntity> getUserProfile();
  Future<List<String>> getDonationTips();

  // Métodos para el Impacto y logros del usuario
  Future<UserImpactEntity> getUserImpactStats();
  Future<List<AchievementEntity>> getAchievements();
  Future<AchievementDetailEntity> getAchievementDetails(String title); // Añadido para detalles de logros
  // --------------------

  // Métodos para Alertas (Detalle)
  Future<AlertDetailEntity> getAlertDetails(String identifier);

  // Método para el Historial
  Future<List<HistoryItemEntity>> getDonationHistory();
}
