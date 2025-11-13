import '../entities/alert_detail_entity.dart';
import '../entities/alert_entity.dart';

// Este es el "contrato" para las alertas de sangre.
abstract class AlertsRepository {
  /// Obtiene las alertas cercanas (la lógica de "cercanía" la resuelve el repo).
  Future<List<AlertEntity>> getNearbyAlerts();

  /// Obtiene el detalle de una alerta (ej. datos de contacto).
  Future<AlertDetailEntity> getAlertDetails(String identifier);
}
