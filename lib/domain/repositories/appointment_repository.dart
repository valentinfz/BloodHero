import '../entities/appointment_detail_entity.dart';
import '../entities/appointment_entity.dart';

// Este es el "contrato" para todo lo relacionado con citas.
abstract class AppointmentRepository {
  /// Obtiene la lista de citas agendadas (futuras).
  Future<List<AppointmentEntity>> getAppointments();

  /// Obtiene el detalle de una cita específica.
  Future<AppointmentDetailEntity> getAppointmentDetails(String appointmentId);

  /// Obtiene la próxima cita más cercana.
  Future<AppointmentEntity> getNextAppointment();

  /// Obtiene los horarios disponibles para un centro en una fecha.
  Future<List<String>> getAvailableTimes({
    required String centerId,
    required DateTime date,
  });

  /// Obtiene los días que ya no tienen turnos en un rango.
  Future<Set<DateTime>> getFullyBookedDays({
    required String centerId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Agenda una nueva cita.
  Future<AppointmentEntity> bookAppointment({
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  });

  /// Reprograma una cita existente.
  Future<AppointmentEntity> rescheduleAppointment({
    required String appointmentId,
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  });

  /// Registra el resultado de una cita (completada o ausente).
  Future<void> logDonation({
    required String appointmentId,
    required bool wasCompleted,
    String? notes,
  });

  /// Cancela una cita agendada.
  Future<void> cancelAppointment({required String appointmentId});
}
