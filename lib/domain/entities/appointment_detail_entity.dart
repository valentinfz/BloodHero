class AppointmentDetailEntity {
  final String id;
  final String center;
  final String date;
  final String time;
  final String donationType;
  final List<String> reminders;

  AppointmentDetailEntity({
    required this.id,
    required this.center,
    required this.date,
    required this.time,
    required this.donationType,
    required this.reminders,
  });
}
