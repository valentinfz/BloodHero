import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:bloodhero/domain/entities/appointment_detail_entity.dart';
import 'package:bloodhero/domain/entities/appointment_entity.dart';
import 'package:bloodhero/domain/repositories/appointment_repository.dart';

class FirebaseAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<String> _baseTimes = <String>[
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
  ];

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .orderBy('timestamp', descending: true)
          .get();

      final now = DateTime.now();
      final upcoming = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final timestamp = data['timestamp'] as Timestamp?;
            final date = timestamp?.toDate();
            final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
            final dateString = date != null
                ? _formatDateLabel(date)
                : 'Fecha inv.';
            final timeString = data['time'] ?? 'Hora inv.';
            final rawCenterId = data['centerId'] as String?;
            final centerId =
                rawCenterId ?? _slugifyCenterName(data['centerName']);

            final statusString = data['status'] as String? ?? 'scheduled';
            final status = AppointmentStatus.values.firstWhere(
              (e) => e.name == statusString,
              orElse: () => AppointmentStatus.scheduled,
            );

            return AppointmentEntity(
              id: doc.id,
              centerId: centerId,
              date: dateString,
              time: timeString,
              location: data['centerName'] ?? 'Centro desconocido',
              donationType: data['donationType'] ?? 'Sangre total',
              scheduledAt: date,
              updatedAt: updatedAt,
              status: status,
            );
          })
          .where((appointment) {
            // Filtro para mostrar solo citas agendadas Y futuras
            if (appointment.status != AppointmentStatus.scheduled) {
              return false;
            }
            final scheduledAt = appointment.scheduledAt;
            if (scheduledAt == null) {
              return true; // Si no tiene fecha (??) mejor mostrarlo
            }
            final normalizedNow = DateTime(now.year, now.month, now.day);
            final normalizedScheduled = DateTime(
              scheduledAt.year,
              scheduledAt.month,
              scheduledAt.day,
            );

            // Muestra si es hoy o después de hoy
            return normalizedScheduled.isAfter(normalizedNow) ||
                normalizedScheduled.isAtSameMomentAs(normalizedNow);
          })
          .toList();

      // Re-ordenar por fecha ascendente para 'Mis Citas'
      upcoming.sort((a, b) {
        if (a.scheduledAt == null || b.scheduledAt == null) return 0;
        return a.scheduledAt!.compareTo(b.scheduledAt!);
      });

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
      final dateString = date != null
          ? '${date.day} de ${_monthToString(date.month)}, ${date.year}'
          : 'Fecha inválida';

      final statusString = data['status'] as String? ?? 'scheduled';
      final status = AppointmentStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => AppointmentStatus.scheduled,
      );
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
        reminders: [
          'Dormí al menos 6 horas la noche anterior.',
          'Evitá consumir alcohol 24 hs antes.',
          'Desayuná liviano antes de donar.',
        ],
        status: status,
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
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final bookedSnapshot = await _firestore
        .collection('centers')
        .doc(centerId)
        .collection('bookedSlots')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(dayEnd))
        .get();

    final occupied = <String>{};
    final staleRefs = <DocumentReference<Map<String, dynamic>>>[];
    final userStatusCache = <String, bool>{};

    for (final doc in bookedSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp == null) {
        staleRefs.add(doc.reference);
        continue;
      }

      final userId = data['userId'] as String?;
      if (userId == null) {
        staleRefs.add(doc.reference);
        continue;
      }

      // Optimización: No chequear usuarios si el slot es del usuario actual
      // (permitiendo la reprogramación en el mismo slot)
      if (userId == _userId) {
        final slotTime = timestamp.toDate();
        occupied.add(_formatTime(slotTime));
        continue;
      }

      final cachedStatus = userStatusCache[userId];
      bool isActiveUser;
      if (cachedStatus != null) {
        isActiveUser = cachedStatus;
      } else {
        final userSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        isActiveUser =
            userSnapshot.exists && (userSnapshot.data()?['deletedAt'] == null);
        userStatusCache[userId] = isActiveUser;
      }

      if (!isActiveUser) {
        staleRefs.add(doc.reference);
        continue;
      }

      final slotTime = timestamp.toDate();
      occupied.add(_formatTime(slotTime));
    }

    if (staleRefs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final ref in staleRefs) {
        batch.delete(ref);
      }
      // No esperamos a que termine, es limpieza en segundo plano
      batch.commit().catchError((e) {
        debugPrint("Error limpiando slots: $e");
      });
    }

    return _baseTimes.where((time) => !occupied.contains(time)).toList();
  }

  @override
  Future<Set<DateTime>> getFullyBookedDays({
    required String centerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('centers')
        .doc(centerId)
        .collection('bookedSlots')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(normalizedEnd))
        .get();

    final counts = <DateTime, int>{};
    final staleRefs = <DocumentReference<Map<String, dynamic>>>[];
    final userStatusCache = <String, bool>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp == null) {
        staleRefs.add(doc.reference);
        continue;
      }

      final userId = data['userId'] as String?;
      if (userId == null) {
        staleRefs.add(doc.reference);
        continue;
      }

      // Optimización: No chequear usuarios si el slot es del usuario actual
      if (userId == _userId) {
        final slotDate = timestamp.toDate();
        final normalizedDate = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
        );
        counts[normalizedDate] = (counts[normalizedDate] ?? 0) + 1;
        continue;
      }

      final cachedStatus = userStatusCache[userId];
      bool isActiveUser;
      if (cachedStatus != null) {
        isActiveUser = cachedStatus;
      } else {
        final userSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        isActiveUser =
            userSnapshot.exists && (userSnapshot.data()?['deletedAt'] == null);
        userStatusCache[userId] = isActiveUser;
      }

      if (!isActiveUser) {
        staleRefs.add(doc.reference);
        continue;
      }

      final slotDate = timestamp.toDate();
      final normalizedDate = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
      );
      counts[normalizedDate] = (counts[normalizedDate] ?? 0) + 1;
    }

    if (staleRefs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final ref in staleRefs) {
        batch.delete(ref);
      }
      // No esperamos a que termine, es limpieza en segundo plano
      batch.commit().catchError((e) {
        debugPrint("Error limpiando slots: $e");
      });
    }

    return counts.entries
        .where((entry) => entry.value >= _baseTimes.length)
        .map((entry) => entry.key)
        .toSet();
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
      final newAppointmentRef = appointmentsCollection.doc();
      final slotRef = _bookingSlotRef(centerId, scheduledAt);

      await _firestore.runTransaction((transaction) async {
        final slotSnapshot = await transaction.get(slotRef);
        if (slotSnapshot.exists) {
          throw Exception(
            'Ese horario ya está reservado. Por favor, elegí otro.',
          );
        }

        transaction.set(slotRef, {
          'appointmentId': newAppointmentRef.id,
          'userId': userId,
          'centerId': centerId,
          'timestamp': Timestamp.fromDate(scheduledAt),
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(newAppointmentRef, {
          'centerId': centerId,
          'centerName': centerName,
          'timestamp': Timestamp.fromDate(scheduledAt),
          'time': time,
          'donationType': donationType,
          'status': 'scheduled',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'slotId': slotRef.id,
        });
      });

      return AppointmentEntity(
        id: newAppointmentRef.id,
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

      final existingData = existingSnapshot.data()!;
      final previousTimestamp = (existingData['timestamp'] as Timestamp?)
          ?.toDate();
      final String previousCenterId =
          (existingData['centerId'] as String?) ??
          _slugifyCenterName(existingData['centerName']);
      final previousSlotId =
          existingData['slotId'] as String? ??
          (previousTimestamp != null ? _slotId(previousTimestamp) : null);

      final newSlotRef = _bookingSlotRef(centerId, scheduledAt);
      final newSlotSnapshot = await transaction.get(newSlotRef);

      final isSameSlot =
          previousSlotId != null &&
          previousSlotId == newSlotRef.id &&
          previousCenterId == centerId;

      if (newSlotSnapshot.exists && !isSameSlot) {
        final ownerId = newSlotSnapshot.data()?['userId'];
        // Si el dueño del slot no soy yo, está ocupado
        if (ownerId != userId) {
          throw Exception(
            'El horario seleccionado ya está reservado por otra persona.',
          );
        }
      }

      if (previousSlotId != null && !isSameSlot) {
        final previousSlotRef = _firestore
            .collection('centers')
            .doc(previousCenterId)
            .collection('bookedSlots')
            .doc(previousSlotId);
        transaction.delete(previousSlotRef);
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
        'updatedAt': FieldValue.serverTimestamp(),
        'rescheduledFrom': appointmentId,
        'slotId': newSlotRef.id,
      });

      transaction.set(newSlotRef, {
        'appointmentId': newDoc.id,
        'userId': userId,
        'centerId': centerId,
        'timestamp': Timestamp.fromDate(scheduledAt),
        'createdAt': FieldValue.serverTimestamp(),
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

    final userRef = _firestore.collection('users').doc(userId);

    final unlockedTotal = await _firestore.runTransaction<int?>((
      transaction,
    ) async {
      final appointmentRef = userRef
          .collection('appointments')
          .doc(appointmentId);

      transaction.update(appointmentRef, {
        'status': wasCompleted ? 'completed' : 'missed',
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!wasCompleted) {
        return null;
      }

      final userDoc = await transaction.get(userRef);
      final currentDonations =
          (userDoc.data()?['totalDonations'] as num?)?.toInt() ?? 0;
      final newTotalDonations = currentDonations + 1;

      transaction.update(userRef, {
        'totalDonations': newTotalDonations,
        'livesHelped': FieldValue.increment(3),
      });

      return newTotalDonations;
    });

    if (unlockedTotal == null) return;

    // Verificar logros fuera de la transacción
    final achievementSnapshot = await _firestore
        .collection(
          'achievements',
        ) // Asumiendo que tienes una colección 'achievements'
        .where('donationsRequired', isEqualTo: unlockedTotal)
        .limit(1)
        .get();

    if (achievementSnapshot.docs.isEmpty) return;

    final achievementDoc = achievementSnapshot.docs.first;
    final achievementId = achievementDoc.id;
    final unlockedAchievementRef = userRef
        .collection('unlockedAchievements')
        .doc(achievementId);

    final existingUnlock = await unlockedAchievementRef.get();
    if (existingUnlock.exists) return; // Ya lo tiene

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
      final appointmentRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(appointmentRef);
        if (!snapshot.exists) {
          throw Exception('Cita no encontrada.');
        }

        final data = snapshot.data()!;
        final centerId =
            (data['centerId'] as String?) ??
            _slugifyCenterName(data['centerName']);
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final slotId =
            data['slotId'] as String? ??
            (timestamp != null ? _slotId(timestamp) : null);

        transaction.update(appointmentRef, {
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        if (slotId != null) {
          final slotRef = _firestore
              .collection('centers')
              .doc(centerId)
              .collection('bookedSlots')
              .doc(slotId);
          transaction.delete(slotRef);
        }
      });
    } catch (e) {
      throw Exception('Error al cancelar la cita: $e');
    }
  }

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .where('status', isEqualTo: 'scheduled') // Solo citas agendadas
          .where('timestamp', isGreaterThanOrEqualTo: now) // Solo citas futuras
          .orderBy('timestamp', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return AppointmentEntity(
          id: '',
          centerId: 'none',
          date: 'No tenés',
          time: 'próximas citas',
          location: '',
          donationType: 'Sangre total',
          status:
              AppointmentStatus.cancelled, // Un estado que no sea 'scheduled'
        );
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      final date = timestamp?.toDate();
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
        status: AppointmentStatus.scheduled,
      );
    } catch (e) {
      throw Exception('Error al obtener la próxima cita: $e');
    }
  }

  // --- Helpers ---
  String _formatDateLabel(DateTime date) {
    final weekday = _dayOfWeekToString(date.weekday);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }

  String _formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
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

  DocumentReference<Map<String, dynamic>> _bookingSlotRef(
    String centerId,
    DateTime scheduledAt,
  ) {
    final slotId = _slotId(scheduledAt);
    return _firestore
        .collection('centers')
        .doc(centerId)
        .collection('bookedSlots')
        .doc(slotId);
  }

  String _slotId(DateTime date) =>
      date.toUtc().millisecondsSinceEpoch.toString();
}
