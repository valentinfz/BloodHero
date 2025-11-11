class AlertEntity {
  final String id;
  final String bloodType;
  final String expiration;
  final double? latitude;
  final double? longitude;
  final String? centerId;
  final String? centerName;
  final String distance;

  const AlertEntity({
    required this.id,
    required this.bloodType,
    required this.expiration,
    this.latitude,
    this.longitude,
    this.centerId,
    this.centerName,
    this.distance = 'Distancia no disponible',
  });

  AlertEntity copyWith({
    String? id,
    String? distance,
    double? latitude,
    double? longitude,
    String? centerId,
    String? centerName,
    String? expiration,
    String? bloodType,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      bloodType: bloodType ?? this.bloodType,
      expiration: expiration ?? this.expiration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      distance: distance ?? this.distance,
    );
  }
}
