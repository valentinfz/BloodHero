import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
      // print("Error cargando centros desde asset (usado temporalmente): $e");
      debugPrint(
        'Error cargando centros desde asset (usado temporalmente): $e',
      );
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

      final docSnapshot = snapshot.docs.first;
      final data = docSnapshot.data();
      final centerId = data['id'] as String? ?? docSnapshot.id;
      return CenterDetailEntity(
        id: centerId,
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
          // --- MEJORA: Ordenar por fecha para consistencia ---
          .orderBy('timestamp', descending: true)
          .get();

      final now = DateTime.now();
      final upcoming = snapshot.docs.map((doc) {
        final data = doc.data();
        // Convertimos Timestamp de Firestore a DateTime, luego a String
        final timestamp = data['timestamp'] as Timestamp?;
        final date = timestamp?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
        final dateString = date != null
            ? _formatDateLabel(date)
            : 'Fecha inv.'; // Formato simple
        final timeString = data['time'] ?? 'Hora inv.';
        final rawCenterId = data['centerId'] as String?;
        final centerId = rawCenterId ?? _slugifyCenterName(data['centerName']);

        // --- Lógica para parsear el estado ---
        final statusString = data['status'] as String? ?? 'scheduled';
        final status = AppointmentStatus.values.firstWhere(
          (e) => e.name == statusString,
          orElse: () => AppointmentStatus.scheduled, // Fallback seguro
        );
        // --- Fin de la lógica de estado ---

        return AppointmentEntity(
          id: doc.id,
          centerId: centerId,
          date: dateString,
          time: timeString,
          location: data['centerName'] ?? 'Centro desconocido',
          donationType: data['donationType'] ?? 'Sangre total',
          scheduledAt: date,
          updatedAt: updatedAt,
          status: status, // Se pasa el estado parseado
        );
      }).where((appointment) {
        if (appointment.status != AppointmentStatus.scheduled) {
          return false;
        }
        final scheduledAt = appointment.scheduledAt;
        if (scheduledAt == null) {
          return true;
        }
        final normalizedNow = DateTime(now.year, now.month, now.day);
        final normalizedScheduled =
            DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
        return normalizedScheduled.isAfter(normalizedNow);
      }).toList();
      return upcoming;
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

      // --- Lógica para parsear el estado (similar a getAppointments) ---
      final statusString = data['status'] as String? ?? 'scheduled';
      final status = AppointmentStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => AppointmentStatus.scheduled,
      );
      // --- Fin de la lógica de estado ---
      final rawCenterId = data['centerId'] as String?;
      final centerId = rawCenterId ?? _slugifyCenterName(data['centerName']);
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

      return AppointmentDetailEntity(
        id: doc.id,
        centerId: centerId,
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
        status: status, // Se pasa el estado parseado
        scheduledAt: date,
        updatedAt: updatedAt,
      );
    } catch (e) {
      throw Exception('Error al obtener detalle de la cita: $e');
    }
  }

  @override
  Future<List<String>> getAvailableTimes({
    required String centerId,
    required DateTime date,
  }) async {
    // Lógica compleja: En una app real, esto consultaría una colección
    // 'availableSlots' filtrando por centro y fecha, y devolviendo los horarios
    // que no estén ya reservados. Por ahora, devolvemos una lista fija.
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simula pequeña demora
    // debugPrint nos permite inspeccionar los parámetros en modo debug.
    debugPrint('Mock horarios disponibles para $centerId en $date');
    return ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
  }

  @override
  Future<AppointmentEntity> bookAppointment({
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      _validateBookingDate(date);
      final timeParts = time.split(':');
      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts.first),
        timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
      );

      final appointmentsCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments');

      final docRef = await appointmentsCollection.add({
        'centerId': centerId,
        'centerName': centerName,
        'timestamp': Timestamp.fromDate(scheduledAt),
        'time': time,
        'donationType': donationType,
        // 'donationType': 'Sangre total', // Valor por defecto (comentado tras normalización)
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppointmentEntity(
        id: docRef.id,
        centerId: centerId,
        date: _formatDateLabel(scheduledAt),
        time: time,
        location: centerName,
        donationType: donationType,
        scheduledAt: scheduledAt,
        status: AppointmentStatus.scheduled,
      );
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  @override
  Future<AppointmentEntity> rescheduleAppointment({
    required String appointmentId,
    required String centerId,
    required String centerName,
    required DateTime date,
    required String time,
    required String donationType,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    _validateBookingDate(date);

    final timeParts = time.split(':');
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts.first),
      timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
    );

    final userRef = _firestore.collection('users').doc(userId);
    final appointmentsCollection = userRef.collection('appointments');
    final existingRef = appointmentsCollection.doc(appointmentId);

    late final String newAppointmentId;

    await _firestore.runTransaction((transaction) async {
      final existingSnapshot = await transaction.get(existingRef);
      if (!existingSnapshot.exists) {
        throw Exception('La cita que querés reprogramar no existe.');
      }

      transaction.update(existingRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
        'cancelReason': 'rescheduled',
        'rescheduledTo': Timestamp.fromDate(scheduledAt),
      });

      final newDoc = appointmentsCollection.doc();
      newAppointmentId = newDoc.id;
      transaction.set(newDoc, {
        'centerId': centerId,
        'centerName': centerName,
        'timestamp': Timestamp.fromDate(scheduledAt),
        'time': time,
        'donationType': donationType,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'rescheduledFrom': appointmentId,
      });
    });

    return AppointmentEntity(
      id: newAppointmentId,
      centerId: centerId,
      date: _formatDateLabel(scheduledAt),
      time: time,
      location: centerName,
      donationType: donationType,
      scheduledAt: scheduledAt,
      status: AppointmentStatus.scheduled,
    );
  }

  @override
  Future<void> logDonation({
    required String appointmentId,
    required bool wasCompleted,
    String? notes,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    // --- COMENTARIO: Uso de Transacción ---
    // Se utiliza una transacción de Firestore para asegurar la atomicidad de la
    // operación. Esto garantiza que todas las operaciones (actualizar cita,
    // estadísticas y desbloquear logros) se completen exitosamente, o ninguna lo haga.
  final userRef = _firestore.collection('users').doc(userId);

  // Usamos la transacción solo para actualizar estado de la cita y las métricas.
  final unlockedTotal = await _firestore.runTransaction<int?>((transaction) async {
    final appointmentRef =
      userRef.collection('appointments').doc(appointmentId);

      // 1. Actualizar el estado de la cita.
      transaction.update(appointmentRef, {
        'status': wasCompleted ? 'completed' : 'missed',
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Si la donación NO fue completada, terminamos la transacción aquí.
      if (!wasCompleted) {
        return null;
      }

      // 3. Si se completó, leer el estado actual del usuario para calcular el nuevo total.
      final userDoc = await transaction.get(userRef);
      final currentDonations = (userDoc.data()?['totalDonations'] as num?)?.toInt() ?? 0;
      final newTotalDonations = currentDonations + 1;

      // 4. Actualizar las estadísticas del usuario con el nuevo total.
      transaction.update(userRef, {
        'totalDonations': newTotalDonations,
        'livesHelped': FieldValue.increment(3), // Asumimos 3 vidas por donación.
      });

      // Devolvemos el nuevo total para usarlo fuera de la transacción.
      return newTotalDonations;
    });

    // Si no se completó la donación no hay logros que evaluar.
    if (unlockedTotal == null) return;

    // --- COMENTARIO: Verificación de logros fuera de la transacción ---
    // Ejecutamos la lógica de logros luego de confirmar la transacción para
    // simplificar la consistencia (y evitar restricciones de Firestore).
    final achievementSnapshot = await _firestore
        .collection('achievements')
        .where('donationsRequired', isEqualTo: unlockedTotal)
        .limit(1)
        .get();

    if (achievementSnapshot.docs.isEmpty) return;

    final achievementDoc = achievementSnapshot.docs.first;
    final achievementId = achievementDoc.id;
    final unlockedAchievementRef =
        userRef.collection('unlockedAchievements').doc(achievementId);

    final existingUnlock = await unlockedAchievementRef.get();
    if (existingUnlock.exists) return;

    await unlockedAchievementRef.set({
      'title': achievementDoc.data()['title'],
      'description': achievementDoc.data()['description'],
      'iconName': achievementDoc.data()['iconName'],
      'unlockedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelAppointment({required String appointmentId}) async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // Simplemente actualizamos el estado de la cita a 'cancelled'.
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'status': 'cancelled',
            'updatedAt': FieldValue.serverTimestamp(),
            'cancelledAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error al cancelar la cita: $e');
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
          centerId: 'none',
          date: 'No tenés',
          time: 'próximas citas',
          location: '',
          donationType: 'Sangre total',
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
      final rawCenterId = data['centerId'] as String?;
      final centerId = rawCenterId ?? _slugifyCenterName(data['centerName']);
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

      return AppointmentEntity(
        id: doc.id,
        centerId: centerId,
        date: dateString,
        time: data['time'] ?? 'Hora inv.',
        location: data['centerName'] ?? 'Centro desconocido',
        donationType: data['donationType'] ?? 'Sangre total',
        scheduledAt: date,
        updatedAt: updatedAt,
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
          expiration: data['expirationText'] ?? 'Pronto',
          // La distancia se calculará posteriormente usando la ubicación del usuario.
          distance: data['distanceText'] as String? ?? 'Calculando distancia...',
          centerName: data['centerName'] as String?,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
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
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Perfil de usuario no encontrado para estadísticas.');
      }
      final data = doc.data()!;

      // --- COMENTARIO: Lectura de estadísticas desde Firestore ---
      // Se leen los campos 'livesHelped' y 'totalDonations' del documento
      // del usuario. Se proveen valores por defecto (0) si los campos no existen.
      final livesHelped = (data['livesHelped'] as num?)?.toInt() ?? 0;
      final totalDonations = (data['totalDonations'] as num?)?.toInt() ?? 0;
      final ranking = data['ranking'] as String? ?? 'Donador';

      return UserImpactEntity(
        livesHelped: livesHelped,
        totalDonations: totalDonations,
        ranking: ranking,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas de impacto: $e');
    }
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    final userId = _userId;
    if (userId == null) {
      // Si no hay usuario, no hay logros que mostrar.
      return [];
    }

    try {
      // Primero buscamos estadísticas para inferir logros basados en niveles.
      final statsDoc = await _firestore.collection('users').doc(userId).get();
      final totalDonations =
          (statsDoc.data()?['totalDonations'] as int?) ?? 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('unlockedAchievements')
          .orderBy('unlockedAt', descending: true)
          .get();

      final existing = snapshot.docs.map((doc) {
        final data = doc.data();
        final unlockedAtTimestamp = data['unlockedAt'] as Timestamp?;

        return AchievementEntity(
          title: data['title'] ?? 'Logro sin título',
          description: data['description'] ?? 'Sin descripción',
          iconName: data['iconName'],
          unlockedAt: unlockedAtTimestamp?.toDate(),
        );
      }).toList();

      // Añadimos logros basados en la escala BloodHero si aún no están.
      final inferred = _levels
          .where((level) => totalDonations >= level.minDonations)
          .map(
            (level) => AchievementEntity(
              title: level.name,
              description: level.description,
              iconName: level.badgeEmoji,
            ),
          );

      final merged = {
        for (final achievement in existing) achievement.title: achievement,
        for (final achievement in inferred) achievement.title: achievement,
      };

      return merged.values.toList()..sort(
          (a, b) => (b.unlockedAt ?? DateTime.now())
              .compareTo(a.unlockedAt ?? DateTime.now()),
        );
    } catch (e) {
      // Manejo de errores, por si la colección no existe o hay problemas de permisos.
      // ignore: avoid_print
      // print('Error fetching achievements: $e');
      debugPrint('Error fetching achievements: $e');
      return [];
    }
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
        // --- Lógica para parsear el estado ---
        final statusString = data['status'] as String? ?? 'scheduled';
        final status = AppointmentStatus.values.firstWhere(
          (e) => e.name == statusString,
          orElse: () => AppointmentStatus.scheduled, // Fallback seguro
        );
        // --- Fin de la lógica de estado ---
        final rawCenterId = data['centerId'] as String?;
        final centerId = rawCenterId ?? _slugifyCenterName(data['centerName']);
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        return HistoryItemEntity(
          appointmentId: doc.id,
          centerId: centerId,
          date: dateString,
          center: data['centerName'] ?? 'Centro desconocido',
          type: data['donationType'] ?? 'No especificado',
          // Se pasa el estado parseado en lugar del booleano
          status: status,
          scheduledAt: date,
          updatedAt: updatedAt,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener historial de donaciones: $e');
    }
  }

  // --- Helper Functions (Ejemplos) ---
  String _formatDateLabel(DateTime date) {
    final weekday = _dayOfWeekToString(date.weekday);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }

  void _validateBookingDate(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!normalizedDate.isAfter(normalizedToday)) {
      throw Exception(
        'Las donaciones deben agendarse con al menos 1 día de anticipación.',
      );
    }
    if (normalizedDate.weekday == DateTime.sunday) {
      throw Exception('Los turnos no están disponibles los domingos.');
    }
  }

  String _slugifyCenterName(Object? rawCenter) {
    final value = (rawCenter ?? 'centro_desconocido').toString();
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

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

  static const List<AchievementLevel> _levels = [
    AchievementLevel(
      level: 1,
      name: 'Primer Héroe',
      title: '🩸 Nivel 1 – Donante Inicial',
      minDonations: 1,
      reward: 'Badge + mensaje de bienvenida',
      description:
          'Tu primera donación puede salvar hasta 3 vidas. ¡Bienvenido a la comunidad BloodHero!',
      badgeEmoji: '🩸',
    ),
    AchievementLevel(
      level: 2,
      name: 'Segundo Pulso',
      title: '❤️ Nivel 2 – Donante Comprometido',
      minDonations: 3,
      reward: 'Insignia + contador visible',
      description: 'Tu compromiso comienza a marcar la diferencia.',
      badgeEmoji: '❤️',
    ),
    AchievementLevel(
      level: 3,
      name: 'Corazón Constante',
      title: '💪 Nivel 3 – Donante Frecuente',
      minDonations: 5,
      reward: 'Fondo especial de perfil',
      description:
          'Gracias por donar de manera regular. ¡Sos ejemplo de constancia!',
      badgeEmoji: '💪',
    ),
    AchievementLevel(
      level: 4,
      name: 'Río de Vida',
      title: '🏅 Nivel 4 – Donante Avanzado',
      minDonations: 10,
      reward: 'Descuento o prioridad en eventos solidarios',
      description: 'Tu constancia fluye como la vida misma.',
      badgeEmoji: '🏅',
    ),
    AchievementLevel(
      level: 5,
      name: 'Guardian del Plasma',
      title: '🕊️ Nivel 5 – Donante Solidario',
      minDonations: 15,
      reward: 'Badge dorada + reconocimiento en ranking local',
      description:
          'Sos parte esencial de cada historia que ayudás a escribir.',
      badgeEmoji: '🕊️',
    ),
    AchievementLevel(
      level: 6,
      name: 'Embajador BloodHero',
      title: '🌟 Nivel 6 – Donante Elite',
      minDonations: 20,
      reward: 'Certificado digital + mención en redes / leaderboard',
      description:
          'Inspirás a otros a salvar vidas. ¡Gracias por tu ejemplo!',
      badgeEmoji: '🌟',
    ),
    AchievementLevel(
      level: 7,
      name: 'Corazón de Platino',
      title: '💎 Nivel 7 – Donante Legendario',
      minDonations: 30,
      reward: 'Reconocimiento legendario en la comunidad BloodHero',
      description:
          'Tu legado salva vidas una y otra vez. ¡Gracias por tu compromiso legendario!',
      badgeEmoji: '💎',
    ),
  ];

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
        // --- COMENTARIO: Inicialización de estadísticas ---
        // Se inicializan las estadísticas de donaciones y vidas ayudadas en 0
        // al momento de crear el usuario. Esto es crucial para que los
        // incrementos atómicos funcionen correctamente desde la primera donación.
        'totalDonations': 0,
        'livesHelped': 0,
        // --- FIN DEL COMENTARIO ---
      });
    } catch (e) {
      throw Exception('Error al guardar datos del usuario en Firestore: $e');
    }
  }
}
