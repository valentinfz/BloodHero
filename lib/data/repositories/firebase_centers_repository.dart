import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:bloodhero/domain/entities/center_detail_entity.dart';
import 'package:bloodhero/domain/entities/center_entity.dart';
import 'package:bloodhero/domain/repositories/centers_repository.dart';

class FirebaseCentersRepository implements CentersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<List<CenterEntity>> getCenters() async {
    // Ya no usamos el JSON local. Ahora consultamos Firestore.
    try {
      final snapshot = await _firestore
          .collection('centers') // La colección de tu screenshot
          .where(
            'deletedAt',
            isNull: true,
          ) // Opcional: filtrar borrados lógicos
          .get();

      final centers = snapshot.docs.map((doc) {
        final data = doc.data();

        // Mapeamos los datos de Firestore a la entidad
        return CenterEntity(
          // Usamos el campo 'id' de tu documento (ej: "pirovano")
          id: data['id'] as String? ?? doc.id,
          name: data['name'] as String? ?? 'Nombre no disponible',
          address: data['address'] as String? ?? 'Dirección no disponible',
          lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
          lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
          image: data['image'] as String?,
          distance: '?? km', // Esto se calcula después en el provider
        );
      }).toList();

      return centers;
    } catch (e) {
      debugPrint('Error cargando centros desde Firestore: $e');
      throw Exception('Error al cargar los centros.');
    }
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    // Asumiremos que el 'centerName' es el ID del documento en Firestore
    // o que tenemos un campo 'name' para buscar. Usaremos 'name' por ahora.
    try {
      // Intenta buscar por ID primero
      DocumentSnapshot<Map<String, dynamic>> docSnapshot;
      final docRef = _firestore.collection('centerDetails').doc(centerName);
      docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Si no existe por ID, busca por nombre
        final snapshot = await _firestore
            .collection('centerDetails') // Colección para detalles
            .where('name', isEqualTo: centerName)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('Centro "$centerName" no encontrado.');
        }
        docSnapshot = snapshot.docs.first;
      }

      final data = docSnapshot.data()!;
      final centerId = data['id'] as String? ?? docSnapshot.id;
      return CenterDetailEntity(
        id: centerId,
        name: data['name'] ?? 'Nombre no disponible',
        address: data['address'] ?? 'Dirección no disponible',
        schedule: data['schedule'] ?? 'Horario no disponible',
        services: List<String>.from(data['services'] ?? []),
        image: data['imageUrl'] ?? '',
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw Exception('Error al obtener detalles del centro: $e');
    }
  }
}
