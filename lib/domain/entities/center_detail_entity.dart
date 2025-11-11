class CenterDetailEntity {
  final String id;
  final String name;
  final String address;
  final String schedule;
  final List<String> services;
  final String image;
  final double latitude;
  final double longitude;

  CenterDetailEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.schedule,
    required this.services,
    required this.image,
    required this.latitude,
    required this.longitude,
  });
}
