import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloodhero/domain/entities/alert_detail_entity.dart';
import 'package:bloodhero/domain/entities/alert_entity.dart';
import 'package:bloodhero/domain/repositories/alerts_repository.dart';

class FirebaseAlertsRepository implements AlertsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .limit(5) // Trae 5 de ejemplo
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AlertEntity(
          id: doc.id,
          bloodType: data['bloodType'] ?? '?',
          expiration: data['expirationText'] ?? 'Pronto',
          distance:
              data['distanceText'] as String? ?? 'Calculando distancia...',
          centerName: data['centerName'] as String?,
          centerId: data['centerId'] as String?,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener alertas cercanas: $e');
    }
  }

  @override
  Future<AlertDetailEntity> getAlertDetails(String identifier) async {
    // Implementación de ejemplo, asumiendo que 'identifier' es el centerName
    // TODO: Ajustar esto si el 'identifier' es un ID de alerta
    await Future.delayed(const Duration(milliseconds: 200)); // Simula carga
    return AlertDetailEntity(
      centerName: identifier,
      bloodType: 'O-', // Debería venir de la alerta real
      urgency: 'Urgente',
      quantityNeeded: '5 donaciones',
      description:
          'Detalles de la alerta para $identifier obtenidos de Firestore.',
      contactPhone: '(011) 5555-5555',
      contactEmail: 'contacto@centro.com',
    );
  }
}
