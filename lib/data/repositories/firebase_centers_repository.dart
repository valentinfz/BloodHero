import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/repository_exception.dart';
import '../../domain/entities/achievement_detail_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/alert_detail_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/center_detail_entity.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/repositories/centers_repository.dart';

class FirebaseCentersRepository implements CentersRepository {
  FirebaseCentersRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    String Function()? codeGenerator,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _generateCode = codeGenerator ?? _defaultCodeGenerator;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String Function() _generateCode;

  static const List<String> _defaultReminders = [
    'Dormí al menos 6 horas la noche anterior.',
    'Evitá consumir alcohol 24 hs antes.',
    'Desayuná liviano antes de donar.',
  ];

  static String _defaultCodeGenerator() {
    final random = Random();
    final value = random.nextInt(9000) + 1000;
    return 'BH-$value';
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('FirebaseCentersRepository.$method error: $error');
      debugPrint(stackTrace.toString());
    }
  }

  String _requireUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw RepositoryException(
        code: 'auth/not-authenticated',
        message: 'Usuario no autenticado.',
      );
    }
    return user.uid;
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final cleaned = time.trim();
    final parts = cleaned.split(':');
    if (parts.length != 2) {
      return date;
    }
    final hours = int.tryParse(parts[0]) ?? date.hour;
    final minutes = int.tryParse(parts[1]) ?? date.minute;
    return DateTime(date.year, date.month, date.day, hours, minutes);
  }

  String _formatDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<String> _findCenterDocumentId(String centerName) async {
    final snapshot = await _firestore
        .collection('centers')
        .where('name', isEqualTo: centerName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return centerName;
    }
    return snapshot.docs.first.id;
  }

  AppointmentEntity _mapAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return AppointmentEntity(
      id: doc.id,
      centerName: data['centerName'] as String? ?? 'Centro desconocido',
      scheduledAt: _parseTimestamp(data['timestamp']),
      status: _statusFromText(data['status'] as String?),
    );
  }

  @override
  Future<List<CenterEntity>> getCenters() async {
    try {
      final snapshot = await _firestore.collection('centers').get();
      if (snapshot.docs.isEmpty) {
        throw RepositoryException(
          code: 'centers/not-found',
          message: 'No se encontraron centros disponibles.',
        );
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CenterEntity(
          name: data['name'] as String? ?? doc.id,
          address: data['address'] as String? ?? 'Dirección no disponible',
          distance: data['distance'] as String?,
          lat: (data['latitude'] as num?)?.toDouble() ?? 0,
          lng: (data['longitude'] as num?)?.toDouble() ?? 0,
          image: data['imageUrl'] as String?,
        );
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      _logError('getCenters', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos cargar los centros. Intentalo nuevamente.',
        cause: e,
      );
    } catch (e, stackTrace) {
      _logError('getCenters', e, stackTrace);
      throw RepositoryException(
        code: 'centers/unknown',
        message: 'Ocurrió un error inesperado al cargar los centros.',
        cause: e,
      );
    }
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    try {
      final snapshot = await _firestore
          .collection('centers')
          .where('name', isEqualTo: centerName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw RepositoryException(
          code: 'centers/not-found',
          message: 'Centro "$centerName" no encontrado.',
        );
      }

      final data = snapshot.docs.first.data();
      return CenterDetailEntity(
        name: data['name'] as String? ?? centerName,
        address: data['address'] as String? ?? 'Dirección no disponible',
        schedule: data['schedule'] as String? ?? 'Horario no disponible',
        services: List<String>.from(data['services'] ?? const <String>[]),
        imageUrl: data['imageUrl'] as String? ?? '',
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getCenterDetails', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los detalles del centro.',
        cause: e,
      );
    } catch (e, stackTrace) {
      _logError('getCenterDetails', e, stackTrace);
      throw RepositoryException(
        code: 'centers/unknown',
        message: 'Ocurrió un error al obtener los detalles del centro.',
        cause: e,
      );
    }
  }

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    final userId = _requireUserId();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .get();

      final appointments = snapshot.docs.map(_mapAppointment).toList();
      appointments.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return appointments;
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAppointments', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener tus citas.',
        cause: e,
      );
    } catch (e, stackTrace) {
      _logError('getAppointments', e, stackTrace);
      throw RepositoryException(
        code: 'appointments/unknown',
        message: 'Ocurrió un error inesperado al cargar tus citas.',
        cause: e,
      );
    }
  }

  @override
  Future<AppointmentDetailEntity> getAppointmentDetails(
    String appointmentId,
  ) async {
    final userId = _requireUserId();
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        throw RepositoryException(
          code: 'appointments/not-found',
          message: 'La cita solicitada no existe.',
        );
      }

      final data = doc.data()!;
      final reminders = (data['reminders'] as List?)?.cast<String>() ??
          _defaultReminders;

      return AppointmentDetailEntity(
        id: doc.id,
        centerName: data['centerName'] as String? ?? 'Centro desconocido',
        scheduledAt: _parseTimestamp(data['timestamp']),
        donationType: data['donationType'] as String? ?? 'No especificado',
        reminders: reminders,
        status: _statusFromText(data['status'] as String?),
        verificationCompleted: data['verificationCompleted'] == true,
        pointsAwarded: (data['pointsAwarded'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAppointmentDetails', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos cargar el detalle de la cita.',
        cause: e,
      );
    } catch (e, stackTrace) {
      _logError('getAppointmentDetails', e, stackTrace);
      throw RepositoryException(
        code: 'appointments/unknown',
        message: 'Ocurrió un error al obtener el detalle de la cita.',
        cause: e,
      );
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    final userId = _requireUserId();
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId);

    try {
      final doc = await docRef.get();
      if (!doc.exists) {
        throw RepositoryException(
          code: 'appointments/not-found',
          message: 'La cita ya no existe.',
        );
      }

      await docRef.update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e, stackTrace) {
      _logError('cancelAppointment', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos cancelar la cita. Intentalo más tarde.',
        cause: e,
      );
    }
  }

  @override
  Future<bool> verifyDonationCode({
    required String appointmentId,
    required String code,
  }) async {
    final userId = _requireUserId();
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data()!;
      final storedCode = data['verificationCode'] as String?;
      if (storedCode != null && storedCode != code) {
        return false;
      }

      if (data['verificationCompleted'] == true) {
        return true;
      }

      final pointsAwarded = (data['pointsAwarded'] as num?)?.toInt() ?? 150;

      await docRef.update({
        'verificationCompleted': true,
        'status': 'completed',
        'pointsAwarded': pointsAwarded,
        'completedAt': FieldValue.serverTimestamp(),
      });

      final historyRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(appointmentId);

      await historyRef.set({
        'centerName': data['centerName'] ?? 'Centro desconocido',
        'donationType': data['donationType'] ?? 'No especificado',
        'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
        'status': 'completed',
        'pointsAwarded': pointsAwarded,
      }, SetOptions(merge: true));

      final userRef = _firestore.collection('users').doc(userId);
      await userRef.set({
        'totalDonations': FieldValue.increment(1),
        'livesHelped': FieldValue.increment(3),
        'pointsEarned': FieldValue.increment(pointsAwarded),
      }, SetOptions(merge: true));

      return true;
    } on FirebaseException catch (e, stackTrace) {
      _logError('verifyDonationCode', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos verificar el código ingresado.',
        cause: e,
      );
    } catch (e, stackTrace) {
      _logError('verifyDonationCode', e, stackTrace);
      throw RepositoryException(
        code: 'appointments/verify-error',
        message: 'Ocurrió un error al verificar el código.',
        cause: e,
      );
    }
  }

  @override
  Future<List<String>> getAvailableTimes(
    String centerName,
    DateTime date,
  ) async {
    try {
      final centerDocId = await _findCenterDocumentId(centerName);
      final doc = await _firestore
          .collection('centers')
          .doc(centerDocId)
          .collection('availableSlots')
          .doc(_formatDateKey(date))
          .get();

      if (!doc.exists) {
        return const <String>[];
      }

      final data = doc.data();
      return List<String>.from(data?['times'] ?? const <String>[]);
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAvailableTimes', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los horarios disponibles.',
        cause: e,
      );
    }
  }

  @override
  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    final userId = _requireUserId();
    try {
      final scheduledAt = _combineDateAndTime(date, time);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .add({
            'centerName': centerName,
            'timestamp': Timestamp.fromDate(scheduledAt),
            'time': time,
            'donationType': 'Sangre total',
            'status': 'scheduled',
            'verificationCode': _generateCode(),
            'verificationCompleted': false,
            'pointsAwarded': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (e, stackTrace) {
      _logError('bookAppointment', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos agendar la cita. Intentalo nuevamente.',
        cause: e,
      );
    }
  }

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    final userId = _requireUserId();
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .where('timestamp', isGreaterThanOrEqualTo: now)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return AppointmentEntity(
          id: 'no-appointment',
          centerName: 'No tenés próximas citas',
          scheduledAt: DateTime.now(),
          status: AppointmentStatus.cancelled,
        );
      }

      return _mapAppointment(snapshot.docs.first);
    } on FirebaseException catch (e, stackTrace) {
      _logError('getNextAppointment', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener la próxima cita.',
        cause: e,
      );
    }
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    try {
      final snapshot = await _firestore.collection('alerts').get();
      if (snapshot.docs.isEmpty) {
        return const <AlertEntity>[];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AlertEntity(
          id: doc.id,
          centerName: data['centerName'] as String? ?? 'Centro sin nombre',
          bloodType: data['bloodType'] as String? ?? '?',
          distance: data['distance'] as String? ?? '?? km',
          expiration: data['expirationText'] as String? ?? 'Pronto',
        );
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      _logError('getNearbyAlerts', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener las alertas cercanas.',
        cause: e,
      );
    }
  }

  @override
  Future<UserEntity> getUserProfile() async {
    final userId = _requireUserId();
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw RepositoryException(
          code: 'users/not-found',
          message: 'Perfil de usuario no encontrado.',
        );
      }

      final data = doc.data()!;
      final dynamicName = data['name'];
      final displayName = _auth.currentUser?.displayName ??
          (dynamicName is String ? dynamicName : null);

      return UserEntity(
        name: displayName ?? 'Usuario',
        email: data['email'] as String? ?? _auth.currentUser?.email ?? 'No email',
        phone: data['phone'] as String? ?? 'No teléfono',
        city: data['city'] as String? ?? 'No ciudad',
        bloodType: data['bloodType'] as String? ?? 'No especificado',
        ranking: data['ranking'] as String? ?? 'Donador',
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getUserProfile', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener el perfil del usuario.',
        cause: e,
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity updatedUser) async {
    final userId = _requireUserId();
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'phone': updatedUser.phone,
        'city': updatedUser.city,
        'bloodType': updatedUser.bloodType,
        'ranking': updatedUser.ranking,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final authUser = _auth.currentUser;
      if (authUser != null && authUser.displayName != updatedUser.name) {
        await authUser.updateDisplayName(updatedUser.name);
      }
    } on FirebaseException catch (e, stackTrace) {
      _logError('updateUserProfile', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos actualizar el perfil del usuario.',
        cause: e,
      );
    }
  }

  @override
  Future<void> registerAlertResponse({required String alertId}) async {
    final userId = _requireUserId();
    try {
      await _firestore.collection('alert_responses').add({
        'alertId': alertId,
        'userId': userId,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      try {
        await _firestore.collection('alerts').doc(alertId).update({
          'responsesCount': FieldValue.increment(1),
        });
      } on FirebaseException catch (e) {
        if (e.code != 'not-found') {
          _logError('registerAlertResponse.updateAlert', e, StackTrace.current);
        }
      }
    } on FirebaseException catch (e, stackTrace) {
      _logError('registerAlertResponse', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos registrar tu intención de ayudar.',
        cause: e,
      );
    }
  }

  @override
  Future<List<String>> getDonationTips() async {
    try {
      final snapshot = await _firestore
          .collection('tips')
          .orderBy('priority', descending: false)
          .get();
      final tips = snapshot.docs
          .map((doc) => doc.data()['text'] as String?)
          .whereType<String>()
          .toList();
      if (tips.isEmpty) {
        return const [
          'Recordá hidratarte bien antes y después de donar.',
        ];
      }
      return tips;
    } on FirebaseException catch (e, stackTrace) {
      _logError('getDonationTips', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los consejos de donación.',
        cause: e,
      );
    }
  }

  @override
  Future<UserImpactEntity> getUserImpactStats() async {
    final userId = _requireUserId();
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw RepositoryException(
          code: 'users/not-found',
          message: 'No encontramos el perfil del usuario.',
        );
      }
      final data = doc.data()!;
      return UserImpactEntity(
        livesHelped: (data['livesHelped'] as num?)?.toInt() ?? 0,
        ranking: data['ranking'] as String? ?? 'Donador',
        achievementsCount: (data['achievementsCount'] as num?)?.toInt(),
        totalDonations: (data['totalDonations'] as num?)?.toInt() ?? 0,
        pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getUserImpactStats', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener las estadísticas de impacto.',
        cause: e,
      );
    }
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .orderBy('priority', descending: false)
          .get();
      if (snapshot.docs.isEmpty) {
        return const <AchievementEntity>[];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AchievementEntity(
          title: data['title'] as String? ?? doc.id,
          description: data['description'] as String? ?? 'Descripción no disponible',
          iconName: (data['iconName'] as String?) ?? 'emoji_events',
        );
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAchievements', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los logros.',
        cause: e,
      );
    }
  }

  @override
  Future<AchievementDetailEntity> getAchievementDetails(String title) async {
    try {
      final doc = await _firestore.collection('achievements').doc(title).get();
      Map<String, dynamic>? data;

      if (doc.exists) {
        data = doc.data();
      } else {
        final query = await _firestore
            .collection('achievements')
            .where('title', isEqualTo: title)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          data = query.docs.first.data();
        }
      }

      if (data == null) {
        throw RepositoryException(
          code: 'achievements/not-found',
          message: 'No encontramos detalles para el logro "$title".',
        );
      }

      return AchievementDetailEntity(
        title: data['title'] as String? ?? title,
        description: data['description'] as String? ?? 'Descripción no disponible',
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAchievementDetails', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los detalles del logro.',
        cause: e,
      );
    }
  }

  @override
  Future<AlertDetailEntity> getAlertDetails(String identifier) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('centerName', isEqualTo: identifier)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        throw RepositoryException(
          code: 'alerts/not-found',
          message: 'No encontramos la alerta solicitada.',
        );
      }
      final data = snapshot.docs.first.data();
      return AlertDetailEntity(
        centerName: data['centerName'] as String? ?? identifier,
        bloodType: data['bloodType'] as String? ?? 'Desconocido',
        urgency: data['urgency'] as String? ?? 'Urgente',
        quantityNeeded: data['quantityNeeded'] as String? ?? 'Sin datos',
        description: data['description'] as String? ?? 'Descripción no disponible',
        contactPhone: data['contactPhone'] as String? ?? 'Sin teléfono',
        contactEmail: data['contactEmail'] as String? ?? 'sin-correo@centro.com',
      );
    } on FirebaseException catch (e, stackTrace) {
      _logError('getAlertDetails', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener los detalles de la alerta.',
        cause: e,
      );
    }
  }

  @override
  Future<List<HistoryItemEntity>> getDonationHistory() async {
    final userId = _requireUserId();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HistoryItemEntity(
          id: doc.id,
          centerName: data['centerName'] as String? ?? 'Centro desconocido',
          donationType: data['donationType'] as String? ?? 'No especificado',
          occurredAt: _parseTimestamp(data['timestamp']),
          status: _statusFromText(data['status'] as String?),
          pointsAwarded: (data['pointsAwarded'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      _logError('getDonationHistory', e, stackTrace);
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'No pudimos obtener tu historial de donaciones.',
        cause: e,
      );
    }
  }

  AppointmentStatus _statusFromText(String? status) {
    switch (status) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.scheduled;
    }
  }
}
