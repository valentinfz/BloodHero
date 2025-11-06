// class AppointmentDetailEntity {
//   final String id;
//   final String center;
//   final String date;
//   final String time;
//   final String donationType;
//   final List<String> reminders;
//
//   AppointmentDetailEntity({
//     required this.id,
//     required this.center,
//     required this.date,
//     required this.time,
//     required this.donationType,
//     required this.reminders,
//   });
// }

import 'appointment_entity.dart';

class AppointmentDetailEntity {
  AppointmentDetailEntity({
    required this.id,
    required this.centerName,
    required this.scheduledAt,
    required this.donationType,
    required this.reminders,
    this.status = AppointmentStatus.scheduled,
    this.verificationCompleted = false,
    this.pointsAwarded = 0,
  });

  final String id;
  final String centerName;
  final DateTime scheduledAt;
  final String donationType;
  final List<String> reminders;
  final AppointmentStatus status;
  final bool verificationCompleted;
  final int pointsAwarded;

  String get dateLabel {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final day = scheduledAt.day;
    final month = months[(scheduledAt.month - 1) % months.length];
    final year = scheduledAt.year;
    return '$day de $month, $year';
  }

  String get timeLabel {
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minutes = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minutes';
  }

  bool get isVerified => verificationCompleted;

  AppointmentDetailEntity copyWith({
    AppointmentStatus? status,
    bool? verificationCompleted,
    int? pointsAwarded,
  }) {
    return AppointmentDetailEntity(
      id: id,
      centerName: centerName,
      scheduledAt: scheduledAt,
      donationType: donationType,
      reminders: reminders,
      status: status ?? this.status,
      verificationCompleted: verificationCompleted ?? this.verificationCompleted,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }
}
