class CenterDetailEntity {
  final String name;
  final String address;
  final String schedule;
  final List<String> services;
  final String imageUrl; // o local en assets (recomendado)
  final double latitude;
  final double longitude;

  CenterDetailEntity({
    required this.name,
    required this.address,
    required this.schedule,
    required this.services,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}
