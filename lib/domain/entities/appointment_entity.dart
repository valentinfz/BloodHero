// class AppointmentEntity {
//   final String date;
//   final String time;
//   final String location;
//
//   AppointmentEntity({
//     required this.date,
//     required this.time,
//     required this.location,
//     required String id,
//   });
// }

enum AppointmentStatus { scheduled, completed, cancelled }

class AppointmentEntity {
  AppointmentEntity({
    required this.id,
    required this.centerName,
    required this.scheduledAt,
    this.status = AppointmentStatus.scheduled,
  });

  final String id;
  final String centerName;
  final DateTime scheduledAt;
  final AppointmentStatus status;

  String get dateLabel {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final prefix = days[(scheduledAt.weekday - 1) % days.length];
    final day = scheduledAt.day.toString().padLeft(2, '0');
    final month = scheduledAt.month.toString().padLeft(2, '0');
    return '$prefix $day/$month';
  }

  String get timeLabel {
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minutes = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minutes';
  }

  String get location => centerName;

  bool get isCompleted => status == AppointmentStatus.completed;

  AppointmentEntity copyWith({
    String? id,
    String? centerName,
    DateTime? scheduledAt,
    AppointmentStatus? status,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      centerName: centerName ?? this.centerName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
    );
  }
}
