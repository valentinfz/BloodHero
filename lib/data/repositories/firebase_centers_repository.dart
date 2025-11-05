import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/alert_detail_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/center_detail_entity.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/achievement_detail_entity.dart';
import '../../domain/repositories/centers_repository.dart';
import 'package:bloodhero/data/loaders/centers_loader.dart';

// Cloud Firestore:
class FirebaseCentersRepository implements CentersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper para obtener el UID del usuario actual (o null si no está logueado)
  String? get _userId => _auth.currentUser?.uid;

  // --- Métodos para Centros ---

  @override
  Future<List<CenterEntity>> getCenters() async {
    // NOTA: Temporalmente, seguimos usando el JSON local porque no tenemos
    // una colección "centers" en Firestore con lat/lng/image.
    // Cuando creemos esa colección, cambiaremos esta lógica.
    try {
      final mapCenters = await loadCentersFromAsset(
        'assets/data/centers_ba.json',
      );
      // TODO: Calcular distancia real si tenemos ubicación del usuario
      return mapCenters
          .map((mc) => CenterEntity.fromMapCenter(mc, distance: '?? km'))
          .toList();
    } catch (e) {
      print("Error cargando centros desde asset (usado temporalmente): $e");
      throw Exception('Error al cargar los centros.');
    }

    /* LÓGICA FUTURA CON FIRESTORE (EJEMPLO):
    try {
      final snapshot = await _firestore.collection('centers').get();
      final centers = snapshot.docs.map((doc) {
        final data = doc.data();
        // TODO: Calcular distancia si tenemos ubicación del usuario
        return CenterEntity(
          name: data['name'] ?? 'Nombre no disponible',
          address: data['address'] ?? 'Dirección no disponible',
          lat: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          lng: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          image: data['imageUrl'] as String?,
          distance: '?? km', // Calcular distancia
        );
      }).toList();
      return centers;
    } catch (e) {
      throw Exception('Error al obtener centros de Firestore: $e');
    }
    */
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    // Asumiremos que el 'centerName' es el ID del documento en Firestore
    // o que tenemos un campo 'name' para buscar. Usaremos 'name' por ahora.
    try {
      final snapshot = await _firestore
          .collection('centerDetails') // Colección para detalles
          .where('name', isEqualTo: centerName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Centro "$centerName" no encontrado.');
      }

      final data = snapshot.docs.first.data();
      return CenterDetailEntity(
        name: data['name'] ?? 'Nombre no disponible',
        address: data['address'] ?? 'Dirección no disponible',
        schedule: data['schedule'] ?? 'Horario no disponible',
        // Firestore guarda arrays directamente
        services: List<String>.from(data['services'] ?? []),
        image: data['imageUrl'] ?? '',
        // Asumimos que lat/lng también están en los detalles
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw Exception('Error al obtener detalles del centro: $e');
    }
  }

  // --- Métodos para Citas ---

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          // Podríamos ordenar por fecha: .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convertimos Timestamp de Firestore a DateTime, luego a String
        final timestamp = data['timestamp'] as Timestamp?;
        final date = timestamp?.toDate();
        final dateString = date != null
            ? '${date.day}/${date.month}'
            : 'Fecha inv.'; // Formato simple
        final timeString = data['time'] ?? 'Hora inv.';

        return AppointmentEntity(
          id: doc.id,
          date: dateString,
          time: timeString,
          location: data['centerName'] ?? 'Centro desconocido',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener citas: $e');
    }
  }

  @override
  Future<AppointmentDetailEntity> getAppointmentDetails(
    String appointmentId,
  ) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        throw Exception('Cita no encontrada.');
      }

      final data = doc.data()!;
      final timestamp = data['timestamp'] as Timestamp?;
      final date = timestamp?.toDate();
      // Formato de fecha más completo para el detalle
      final dateString = date != null
          ? '${date.day} de ${_monthToString(date.month)}, ${date.year}'
          : 'Fecha inválida';

      return AppointmentDetailEntity(
        id: doc.id,
        center: data['centerName'] ?? 'Centro desconocido',
        date: dateString,
        time: data['time'] ?? 'Hora inválida',
        donationType: data['donationType'] ?? 'No especificado',
        // Los recordatorios podrían ser fijos o venir de Firestore
        reminders: [
          'Dormí al menos 6 horas la noche anterior.',
          'Evitá consumir alcohol 24 hs antes.',
          'Desayuná liviano antes de donar.',
        ],
      );
    } catch (e) {
      throw Exception('Error al obtener detalle de la cita: $e');
    }
  }

  @override
  Future<List<String>> getAvailableTimes(
    String centerName,
    DateTime date,
  ) async {
    // Lógica compleja: En una app real, esto consultaría una colección
    // 'availableSlots' filtrando por centro y fecha, y devolviendo los horarios
    // que no estén ya reservados. Por ahora, devolvemos una lista fija.
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simula pequeña demora
    return ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
  }

  @override
  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // Creamos un nuevo documento en la subcolección 'appointments' del usuario
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .add({
            'centerName': centerName,
            'timestamp': Timestamp.fromDate(date), // Guardamos como Timestamp
            'time': time,
            'donationType': 'Sangre total', // Valor por defecto
            'status': 'confirmed', // Estado inicial
            'createdAt': FieldValue.serverTimestamp(), // Fecha de creación
          });
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  // --- Métodos para el Home ---

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    // Similar a getAppointments, pero ordenando por fecha y tomando la primera futura
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .where('timestamp', isGreaterThanOrEqualTo: now) // Solo citas futuras
          .orderBy(
            'timestamp',
            descending: false,
          ) // Ordena por fecha ascendente
          .limit(1) // Toma solo la más próxima
          .get();

      if (snapshot.docs.isEmpty) {
        // Si no hay citas futuras, podemos devolver una "vacía" o lanzar error
        // Devolvemos una indicando que no hay
        return AppointmentEntity(
          id: '',
          date: 'No tenés',
          time: 'próximas citas',
          location: '',
        );
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      final date = timestamp?.toDate();
      // Formato de fecha simple para el Home
      final dateString = date != null
          ? '${_dayOfWeekToString(date.weekday)} ${date.day}/${date.month}'
          : 'Fecha inv.';

      return AppointmentEntity(
        id: doc.id,
        date: dateString,
        time: data['time'] ?? 'Hora inv.',
        location: data['centerName'] ?? 'Centro desconocido',
      );
    } catch (e) {
      throw Exception('Error al obtener la próxima cita: $e');
    }
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    // Lógica compleja: En una app real, esto podría usar GeoQueries de Firestore
    // o filtrar alertas por cercanía a la ubicación del usuario (si la tenemos).
    // Por ahora, devolvemos una lista fija leída de una colección 'alerts'.
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .limit(5)
          .get(); // Trae 5 de ejemplo
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AlertEntity(
          bloodType: data['bloodType'] ?? '?',
          // La distancia se calcularía en base a la ubicación del usuario
          distance: '?? km',
          // La expiración podría ser una fecha o un texto
          expiration: data['expirationText'] ?? 'Pronto',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener alertas cercanas: $e');
    }
  }

  @override
  Future<UserEntity> getUserProfile() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Perfil de usuario no encontrado.');
      }
      final data = doc.data()!;
      // Obtenemos el nombre de Firebase Auth si está disponible, sino de Firestore
      final displayName = _auth.currentUser?.displayName ?? data['name'];

      return UserEntity(
        // id: userId, // La entidad no tiene ID ahora
        name: displayName ?? 'Usuario',
        email: data['email'] ?? _auth.currentUser?.email ?? 'No email',
        phone: data['phone'] ?? 'No teléfono',
        city: data['city'] ?? 'No ciudad',
        bloodType: data['bloodType'] ?? 'No especificado',
        ranking:
            data['ranking'] ?? 'Donador', // Podría venir de aquí o calcularse
      );
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: $e');
    }
  }

  @override
  Future<List<String>> getDonationTips() async {
    // Podríamos leerlos de una colección 'tips' en Firestore
    await Future.delayed(const Duration(milliseconds: 100)); // Simula carga
    return [
      'Recordá hidratarte bien antes y después de donar.',
      'Avisá al personal si te sentís mareado en algún momento.',
      'Evitá hacer actividad física intensa el día de la donación.',
    ];
  }

  // --- Métodos para Impacto ---

  @override
  Future<UserImpactEntity> getUserImpactStats() async {
    // Estos datos podrían estar en el documento del usuario o calcularse
    await Future.delayed(const Duration(milliseconds: 200)); // Simula carga
    // Podríamos leer el ranking del UserEntity si lo trajimos antes
    return const UserImpactEntity(livesHelped: 12, ranking: 'Donador Leal');
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    // Podríamos leerlos de una colección 'achievements' o una subcolección del usuario
    await Future.delayed(const Duration(milliseconds: 300)); // Simula carga
    return const [
      AchievementEntity(
        title: 'Primera Donación',
        description: '¡Gracias por dar el primer paso!',
        iconName: 'looks_one',
      ),
      AchievementEntity(
        title: 'Donador Frecuente',
        description: '3 donaciones en los últimos 6 meses',
      ),
      AchievementEntity(
        title: 'Héroe en Emergencia',
        description: 'Respondiste a 2 alertas urgentes',
        iconName: 'local_hospital',
      ) /* ... otros ... */,
    ];
  }

  @override
  Future<AchievementDetailEntity> getAchievementDetails(String title) async {
    // Buscaría el logro por título en una colección 'achievements'
    await Future.delayed(const Duration(milliseconds: 150)); // Simula carga
    // Lógica similar a FakeRepo, pero leyendo de Firestore
    return AchievementDetailEntity(
      title: title,
      description: 'Detalles del logro $title obtenidos de Firestore.',
    );
  }

  // --- Métodos para Alertas ---

  @override
  Future<AlertDetailEntity> getAlertDetails(String identifier) async {
    // Podríamos buscar la alerta por ID o por nombre del centro en 'alerts'
    await Future.delayed(const Duration(milliseconds: 200)); // Simula carga
    return AlertDetailEntity(
      centerName: identifier,
      bloodType: 'O-',
      urgency: 'Urgente',
      quantityNeeded: '5 donaciones',
      description:
          'Detalles de la alerta para $identifier obtenidos de Firestore.',
      contactPhone: '(011) 5555-5555',
      contactEmail: 'contacto@centro.com',
    );
  }

  // --- Métodos para Historial ---

  @override
  Future<List<HistoryItemEntity>> getDonationHistory() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments') // Usamos la misma colección de citas
          .orderBy(
            'timestamp',
            descending: true,
          ) // Ordenamos por fecha descendente
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final date = timestamp?.toDate();
        final dateString = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : 'Fecha inv.'; // Formato completo
        final status =
            data['status'] ??
            'unknown'; // 'confirmed', 'completed', 'cancelled'

        return HistoryItemEntity(
          date: dateString,
          center: data['centerName'] ?? 'Centro desconocido',
          type: data['donationType'] ?? 'No especificado',
          // Mapeamos el estado a si fue completada o no
          wasCompleted: status == 'completed',
          // Podríamos añadir el estado real si quisiéramos mostrar "Cancelada"
          // status: status,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener historial de donaciones: $e');
    }
  }

  // --- Helper Functions (Ejemplos) ---
  String _monthToString(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  String _dayOfWeekToString(int day) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[day - 1];
  }

  // --- Método crucial que faltaba en FirebaseAuthRepository ---
  // Debería estar allí, pero lo ponemos aquí temporalmente para que compile
  // y para ilustrar cómo se guardan los datos del usuario en Firestore.
  Future<void> saveUserDataToFirestore(
    String userId,
    String name,
    String phone,
    String bloodType,
    String city,
    String email,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email, // Guardamos email aquí también
        'phone': phone,
        'bloodType': bloodType,
        'city': city,
        'ranking': 'Nuevo Donador', // Ranking inicial
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al guardar datos del usuario en Firestore: $e');
    }
  }
}
