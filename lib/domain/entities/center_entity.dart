import 'package:bloodhero/data/loaders/centers_loader.dart';

class CenterEntity {
  final String id;
  final String name;
  final String address;
  final String? distance; // Lo hacemos opcional, lo calcularemos después
  final double lat;
  final double lng;
  final String? image;

  const CenterEntity({
    required this.id,
    required this.name,
    required this.address,
    this.distance,
    required this.lat,
    required this.lng,
    this.image,
  });

   // Helper para crear desde MapCenter (opcional)
   factory CenterEntity.fromMapCenter(MapCenter mapCenter, {String? distance}) {
     return CenterEntity(
       id: mapCenter.id,
       name: mapCenter.name,
       address: mapCenter.address,
       lat: mapCenter.lat,
       lng: mapCenter.lng,
       image: mapCenter.image,
       distance: distance,
     );
   }

  CenterEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? distance,
    double? lat,
    double? lng,
    String? image,
  }) {
    return CenterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      image: image ?? this.image,
    );
  }
}
