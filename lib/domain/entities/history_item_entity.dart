// class HistoryItemEntity {
//   final String date;
//   final String center;
//   final String type;
//   final bool wasCompleted; // Si la donación se realizó o fue cancelada
//
//   const HistoryItemEntity({
//     required this.date,
//     required this.center,
//     required this.type,
//     required this.wasCompleted,
//   });
// }

import 'appointment_entity.dart';

class HistoryItemEntity {
  const HistoryItemEntity({
    required this.id,
    required this.centerName,
    required this.donationType,
    required this.occurredAt,
    required this.status,
    this.pointsAwarded = 0,
  });

  final String id;
  final String centerName;
  final String donationType;
  final DateTime occurredAt;
  final AppointmentStatus status;
  final int pointsAwarded;

  bool get wasCompleted => status == AppointmentStatus.completed;

  String get dateLabel {
    final day = occurredAt.day.toString().padLeft(2, '0');
    final month = occurredAt.month.toString().padLeft(2, '0');
    final year = occurredAt.year;
    return '$day/$month/$year';
  }
}
