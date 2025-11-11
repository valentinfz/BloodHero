import 'appointment_entity.dart';

class AppointmentDetailEntity {
  final String id;
  final String centerId;
  final String center;
  final String date;
  final String time;
  final String donationType;
  final List<String> reminders;
  final AppointmentStatus status; // Se añade el estado
  final DateTime? scheduledAt;
  final DateTime? updatedAt;

  AppointmentDetailEntity({
    required this.id,
    required this.centerId,
    required this.center,
    required this.date,
    required this.time,
    required this.donationType,
    required this.reminders,
    this.status = AppointmentStatus.scheduled, // Valor por defecto
    this.scheduledAt,
    this.updatedAt,
  });
}
