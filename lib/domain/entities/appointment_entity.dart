/// Representa el estado del ciclo de vida de una cita.
enum AppointmentStatus {
  scheduled, // Agendada por el usuario.
  completed, // El usuario asistió y la donación se completó.
  cancelled, // El usuario o el sistema la cancelaron.
  missed, // El usuario no asistió.
}

class AppointmentEntity {
  final String id;
  final String centerId;
  final String date;
  final String time;
  final String location;
  final String donationType;
  final DateTime? scheduledAt;
  final DateTime? updatedAt;
  final AppointmentStatus status;

  const AppointmentEntity({
    required this.id,
    required this.centerId,
    required this.date,
    required this.time,
    required this.location,
    this.donationType = 'Sangre total',
    this.scheduledAt,
    this.updatedAt,
    this.status = AppointmentStatus.scheduled, // Valor por defecto
  });

  AppointmentEntity copyWith({
    String? id,
    String? centerId,
    String? date,
    String? time,
    String? location,
    String? donationType,
    DateTime? scheduledAt,
    DateTime? updatedAt,
    AppointmentStatus? status,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      donationType: donationType ?? this.donationType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
