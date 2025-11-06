import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeedService {
  FirestoreSeedService(
    this._firestore, {
    DateTime? baseDate,
  }) : _baseDate = baseDate ?? DateTime.now();

  final FirebaseFirestore _firestore;
  final DateTime _baseDate;

  Future<void> seed({required String userId}) async {
    await _seedCenters();
    await _seedAvailableSlots();
    await _seedAlerts();
    await _seedTips();
    await _seedAchievements();
    await _seedUser(userId);
    await _seedAppointments(userId);
    await _seedHistory(userId);
  }

  Future<void> _seedCenters() async {
    final centers = [
      {
        'id': 'hospital-central',
        'name': 'Hospital Central',
        'address': 'Av. Siempre Viva 123',
        'distance': '2 km',
        'latitude': -34.6037,
        'longitude': -58.3816,
        'imageUrl': 'https://example.com/central.jpg',
        'schedule': 'Lun a Vie 8:00 - 18:00 · Sáb 9:00 - 13:00',
        'services': [
          'Extracción de sangre',
          'Estacionamiento',
          'Zona de espera con snacks',
        ],
      },
      {
        'id': 'centro-salud-norte',
        'name': 'Centro de Salud Norte',
        'address': 'Calle del Norte 456',
        'distance': '5 km',
        'latitude': -34.561,
        'longitude': -58.456,
        'imageUrl': 'https://example.com/norte.jpg',
        'schedule': 'Lun a Vie 7:30 - 16:00',
        'services': [
          'Extracción de sangre',
          'Atención de urgencias',
        ],
      },
    ];

    for (final center in centers) {
      await _firestore.collection('centers').doc(center['id'] as String).set({
        'name': center['name'],
        'address': center['address'],
        'distance': center['distance'],
        'latitude': center['latitude'],
        'longitude': center['longitude'],
        'imageUrl': center['imageUrl'],
        'schedule': center['schedule'],
        'services': center['services'],
      }, SetOptions(merge: true));
    }
  }

  Future<void> _seedAvailableSlots() async {
    final slots = {
      'hospital-central': {
        _formatDateKey(_baseDate.add(const Duration(days: 2))): [
          '09:00',
          '09:30',
          '10:30',
        ],
      },
      'centro-salud-norte': {
        _formatDateKey(_baseDate.add(const Duration(days: 3))): [
          '08:00',
          '08:30',
          '11:00',
        ],
      },
    };

    for (final entry in slots.entries) {
      final centerId = entry.key;
      for (final slotEntry in entry.value.entries) {
        await _firestore
            .collection('centers')
            .doc(centerId)
            .collection('availableSlots')
            .doc(slotEntry.key)
            .set({'times': slotEntry.value});
      }
    }
  }

  Future<void> _seedAlerts() async {
    final alerts = [
      {
        'id': 'alert-hc',
        'centerName': 'Hospital Central',
        'bloodType': 'O-',
        'expirationText': 'vence hoy',
        'distance': '2 km',
        'urgency': 'Alta',
        'quantityNeeded': '5 donaciones',
        'description': 'Se necesitan donantes O- para casos de emergencia.',
        'contactPhone': '(011) 5555-1111',
        'contactEmail': 'urgencias@hospitalcentral.com',
      },
      {
        'id': 'alert-norte',
        'centerName': 'Centro de Salud Norte',
        'bloodType': 'A+',
        'expirationText': 'vence en 2 días',
        'distance': '5 km',
        'urgency': 'Media',
        'quantityNeeded': '3 donaciones',
        'description': 'Urgencia moderada para reponer plaquetas.',
        'contactPhone': '(011) 5555-2222',
        'contactEmail': 'coordinacion@saludnorte.com',
      },
    ];

    for (final alert in alerts) {
      await _firestore.collection('alerts').doc(alert['id'] as String).set(alert);
    }
  }

  Future<void> _seedTips() async {
    final tips = [
      {
        'id': 'tip-1',
        'text': 'Recordá hidratarte bien antes y después de donar.',
        'priority': 1,
      },
      {
        'id': 'tip-2',
        'text': 'Evitá actividad física intensa el día de la donación.',
        'priority': 2,
      },
    ];

    for (final tip in tips) {
      await _firestore.collection('tips').doc(tip['id'] as String).set(tip);
    }
  }

  Future<void> _seedAchievements() async {
    final achievements = [
      {
        'id': 'Primera Donación',
        'title': 'Primera Donación',
        'description': '¡Gracias por dar el primer paso!',
        'iconName': 'looks_one',
        'priority': 1,
      },
      {
        'id': 'Donador Frecuente',
        'title': 'Donador Frecuente',
        'description': '3 donaciones en los últimos 6 meses',
        'iconName': 'repeat',
        'priority': 2,
      },
      {
        'id': 'Héroe en Emergencia',
        'title': 'Héroe en Emergencia',
        'description': 'Respondiste a 2 alertas urgentes',
        'iconName': 'local_hospital',
        'priority': 3,
      },
    ];

    for (final achievement in achievements) {
      await _firestore
          .collection('achievements')
          .doc(achievement['id'] as String)
          .set(achievement);
    }
  }

  Future<void> _seedUser(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'name': 'Juan Pérez',
      'email': 'juan.perez@example.com',
      'phone': '+54 11 1234-5678',
      'city': 'Buenos Aires',
      'bloodType': 'O-',
      'ranking': 'Donador Leal',
      'livesHelped': 12,
      'totalDonations': 3,
      'pointsEarned': 200,
      'achievementsCount': 3,
    }, SetOptions(merge: true));
  }

  Future<void> _seedAppointments(String userId) async {
    final appointments = [
      {
        'id': 'apt-001',
        'centerName': 'Hospital Central',
        'timestamp': Timestamp.fromDate(_baseDate.add(const Duration(days: 2))),
        'time': '10:30',
        'donationType': 'Sangre total',
        'status': 'scheduled',
        'verificationCode': 'BH-4312',
        'verificationCompleted': false,
        'pointsAwarded': 0,
      },
      {
        'id': 'apt-002',
        'centerName': 'Centro de Salud Norte',
        'timestamp': Timestamp.fromDate(_baseDate.add(const Duration(days: 7))),
        'time': '09:00',
        'donationType': 'Plaquetas',
        'status': 'completed',
        'verificationCode': 'BH-7721',
        'verificationCompleted': true,
        'pointsAwarded': 150,
      },
    ];

    final collection = _firestore.collection('users').doc(userId).collection('appointments');
    for (final appointment in appointments) {
      await collection.doc(appointment['id'] as String).set(appointment);
    }
  }

  Future<void> _seedHistory(String userId) async {
    final historyItems = [
      {
        'id': 'hist-001',
        'centerName': 'Hospital Central',
        'donationType': 'Sangre total',
        'timestamp': Timestamp.fromDate(_baseDate.subtract(const Duration(days: 60))),
        'status': 'completed',
        'pointsAwarded': 80,
      },
      {
        'id': 'hist-002',
        'centerName': 'Clínica San Martín',
        'donationType': 'Plaquetas',
        'timestamp': Timestamp.fromDate(_baseDate.subtract(const Duration(days: 120))),
        'status': 'completed',
        'pointsAwarded': 120,
      },
    ];

    final collection = _firestore.collection('users').doc(userId).collection('history');
    for (final item in historyItems) {
      await collection.doc(item['id'] as String).set(item);
    }
  }

  String _formatDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
