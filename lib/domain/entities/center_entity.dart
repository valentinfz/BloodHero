import 'package:bloodhero/data/loaders/centers_loader.dart';

class CenterEntity {
  final String name;
  final String address;
  final String? distance; // Lo hacemos opcional, lo calcularemos después
  final double lat;
  final double lng;
  final String? image;

  const CenterEntity({
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
       name: mapCenter.name,
       address: mapCenter.address,
       lat: mapCenter.lat,
       lng: mapCenter.lng,
       image: mapCenter.image,
       distance: distance,
     );
   }
}
