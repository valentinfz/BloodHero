class AlertDetailEntity {
  final String centerName;
  final String bloodType;
  final String urgency;
  final String quantityNeeded;
  final String description;
  final String contactPhone;
  final String contactEmail;

  const AlertDetailEntity({
    required this.centerName,
    required this.bloodType,
    required this.urgency,
    required this.quantityNeeded,
    required this.description,
    required this.contactPhone,
    required this.contactEmail,
  });
}
