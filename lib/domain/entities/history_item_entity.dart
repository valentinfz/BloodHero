import '../entities/appointment_entity.dart';

class HistoryItemEntity {
  final String appointmentId;
  final String centerId;
  final String date;
  final String center;
  final String type;
  // final bool wasCompleted; // Si la donación se realizó o fue cancelada
  final AppointmentStatus status;
  final DateTime? scheduledAt;
  final DateTime? updatedAt;

  const HistoryItemEntity({
    required this.appointmentId,
    required this.centerId,
    required this.date,
    required this.center,
    required this.type,
    // required this.wasCompleted,
    required this.status,
    this.scheduledAt,
    this.updatedAt,
  });
}
