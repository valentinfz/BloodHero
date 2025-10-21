import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MapCenter {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? image; 

  const MapCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.image,
  });

  factory MapCenter.fromJson(Map<String, dynamic> j) => MapCenter(
        id: j['id'] as String,
        name: j['name'] as String,
        address: j['address'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        image: j['image'] as String?,
      );
}

Future<List<MapCenter>> loadCentersFromAsset(String path) async {
  final raw = await rootBundle.loadString(path);
  final List data = jsonDecode(raw) as List;
  return data.map((e) => MapCenter.fromJson(e as Map<String, dynamic>)).toList();
}
