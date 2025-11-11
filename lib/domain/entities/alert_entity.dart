class AlertEntity {
  final String bloodType;
  final String expiration;
  final double? latitude;
  final double? longitude;
  final String? centerName;
  final String distance;

  const AlertEntity({
    required this.bloodType,
    required this.expiration,
    this.latitude,
    this.longitude,
    this.centerName,
    this.distance = 'Distancia no disponible',
  });

  AlertEntity copyWith({
    String? distance,
    double? latitude,
    double? longitude,
    String? centerName,
    String? expiration,
    String? bloodType,
  }) {
    return AlertEntity(
      bloodType: bloodType ?? this.bloodType,
      expiration: expiration ?? this.expiration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      centerName: centerName ?? this.centerName,
      distance: distance ?? this.distance,
    );
  }
}
