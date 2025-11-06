import 'dart:async';
import 'package:bloodhero/data/loaders/centers_loader.dart';
import '../../domain/entities/alert_detail_entity.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/center_detail_entity.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/achievement_detail_entity.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/repositories/centers_repository.dart';

/*class FakeCentersRepository implements CentersRepository {
  // --- Lista Estática de Logros ---
  static const List<AchievementEntity> _achievements = [
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
    ),
    AchievementEntity(
      title: 'Constancia de Acero',
      description: '5 donaciones realizadas',
      iconName: 'shield',
    ),
    AchievementEntity(
      title: 'Embajador',
      description: 'Invitaste a 5 amigos a donar',
      iconName: 'group',
    ),
    AchievementEntity(
      title: 'Donador Leal',
      description: 'Más de 10 donaciones en total',
    ),
  ];

  @override
  Future<List<CenterEntity>> getCenters() async {
    final mapCenters = await loadCentersFromAsset(
      'assets/data/centers_ba.json',
    );
    return mapCenters.map((mc) => CenterEntity.fromMapCenter(mc)).toList();
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula carga

    // 1. Carga todos los centros desde el JSON
    final allMapCenters = await loadCentersFromAsset(
      'assets/data/centers_ba.json',
    );

    // --- CORRECCIÓN ---
    // 2. Busca el centro específico por nombre
    // Se añade el tipo explícito 'MapCenter?' para permitir que 'orElse' devuelva null.
    MapCenter? foundCenter = allMapCenters.cast<MapCenter?>().firstWhere(
      (mc) => mc?.name == centerName,
      orElse: () => null as MapCenter?,
    );
    // --- FIN CORRECCIÓN ---

    // 3. Si se encontró el centro en el JSON, usa sus datos
    if (foundCenter != null) {
      // Usamos los datos reales del JSON, pero mantenemos horarios/servicios hardcodeados por ahora
      return CenterDetailEntity(
        name: foundCenter.name,
        address: foundCenter.address,
        schedule:
            'Lun a Vie 8:00 - 18:00 · Sáb 9:00 - 13:00', // Horario genérico
        services: [
          // Servicios genéricos
          'Extracción de sangre',
          foundCenter.name.contains('Hospital')
              ? 'Estacionamiento'
              : 'Zona de espera',
        ],
        imageUrl: foundCenter.image ?? '', // Usa la imagen del JSON si existe
        latitude: foundCenter.lat,
        longitude: foundCenter.lng,
      );
    }

    // 4. Si NO se encontró, devuelve datos por defecto (o lanza un error)
    return CenterDetailEntity(
      name: centerName, // Muestra el nombre que se buscó
      address: 'Dirección no encontrada',
      schedule: 'Horario no disponible',
      services: ['Servicios no disponibles'],
      imageUrl: '',
      latitude: -34.6, // Coordenadas genéricas de BA
      longitude: -58.4,
    );
  }

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      AppointmentEntity(
        id: '1',
        date: 'Lun 12/11',
        time: '10:30',
        location: 'Hospital Central',
      ),
      AppointmentEntity(
        id: '2',
        date: 'Vie 16/11',
        time: '09:00',
        location: 'Centro de Salud Norte',
      ),
    ];
  }

  @override
  Future<AppointmentDetailEntity> getAppointmentDetails(
    String appointmentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AppointmentDetailEntity(
      id: '1',
      center: 'Hospital Central',
      date: 'Lunes 12 de Noviembre, 2025',
      time: '10:30 hs',
      donationType: 'Sangre total',
      reminders: [
        'Dormí al menos 6 horas la noche anterior.',
        'Evitá consumir alcohol 24 hs antes.',
        'Desayuná liviano antes de donar.',
      ],
    );
  }

  @override
  Future<List<String>> getAvailableTimes(
    String centerName,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
  }

  @override
  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint(
      'Cita agendada para $centerName el ${date.day}/${date.month} a las $time',
    );
    return;
  }

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AppointmentEntity(
      id: '1',
      date: 'Lun 12/11',
      time: '10:30',
      location: 'Hospital Central',
    );
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      const AlertEntity(
        id: 'alert-1',
        centerName: 'Hospital Central',
        bloodType: 'O-',
        distance: '2 km',
        expiration: 'vence hoy',
      ),
      const AlertEntity(
        id: 'alert-2',
        centerName: 'Clínica del Norte',
        bloodType: 'A+',
        distance: '5 km',
        expiration: 'vence en 2 días',
      ),
      const AlertEntity(
        id: 'alert-3',
        centerName: 'Sanatorio del Sur',
        bloodType: 'B-',
        distance: '8 km',
        expiration: 'vence en 3 días',
      ),
    ];
  }

  @override
  Future<UserEntity> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserEntity(
      name: 'Usuario',
      email: 'usuario@email.com',
      phone: '1122334455',
      city: 'Buenos Aires',
      bloodType: 'O-',
      ranking: 'Donador leal',
    );
  }

  @override
  Future<List<String>> getDonationTips() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'Recordá hidratarte bien antes y después de donar.',
      'Avisá al personal si te sentís mareado en algún momento.',
      'Evitá hacer actividad física intensa el día de la donación.',
    ];
  }

  @override
  Future<UserImpactEntity> getUserImpactStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserImpactEntity(livesHelped: 12, ranking: 'Donador Leal');
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _achievements;
  }

  @override
  Future<AlertDetailEntity> getAlertDetails(String identifier) async {
    await Future.delayed(const Duration(milliseconds: 300));
    String bloodTypeNeeded = 'O-';
    if (identifier.toLowerCase().contains('norte')) {
      bloodTypeNeeded = 'A+';
    } else if (identifier.toLowerCase().contains('sur')) {
      bloodTypeNeeded = 'B-';
    }
    return AlertDetailEntity(
      centerName: identifier,
      bloodType: bloodTypeNeeded,
      urgency: 'Dentro de ${bloodTypeNeeded == 'O-' ? 12 : 24} horas',
      quantityNeeded: '${bloodTypeNeeded == 'O-' ? 5 : 3} donaciones',
      description:
          'Se necesita sangre $bloodTypeNeeded para pacientes en $identifier. Tu donación puede hacer la diferencia.',
      contactPhone: '(011) 4${identifier.length}34-5${identifier.length}78',
      contactEmail:
          'donaciones@${identifier.toLowerCase().replaceAll(' ', '')}.com',
    );
  }

  @override
  Future<List<HistoryItemEntity>> getDonationHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      HistoryItemEntity(
        date: '12/11/2025',
        center: 'Hospital Central',
        type: 'Sangre total',
        wasCompleted: true,
      ),
      HistoryItemEntity(
        date: '05/09/2025',
        center: 'Banco de Sangre Norte',
        type: 'Plaquetas',
        wasCompleted: true,
      ),
      HistoryItemEntity(
        date: '18/06/2025',
        center: 'Clínica San Martín',
        type: 'Sangre total',
        wasCompleted: false,
      ),
    ];
  }

  @override
  Future<AchievementDetailEntity> getAchievementDetails(String title) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final achievement = FakeCentersRepository._achievements.firstWhere(
      (ach) => ach.title == title,
      orElse: () => const AchievementEntity(
        title: 'Logro Desconocido',
        description: 'No se encontraron detalles.',
      ),
    );
    return AchievementDetailEntity(
      title: achievement.title,
      description: achievement.description,
    );
  }
}
*/

class FakeCentersRepository implements CentersRepository {
  FakeCentersRepository() {
    _resetState();
  }

  static const List<AchievementEntity> _achievements = [
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
    ),
    AchievementEntity(
      title: 'Constancia de Acero',
      description: '5 donaciones realizadas',
      iconName: 'shield',
    ),
    AchievementEntity(
      title: 'Embajador',
      description: 'Invitaste a 5 amigos a donar',
      iconName: 'group',
    ),
    AchievementEntity(
      title: 'Donador Leal',
      description: 'Más de 10 donaciones en total',
    ),
  ];

  final Map<String, _FakeAppointmentRecord> _appointments = {};
  final List<HistoryItemEntity> _history = <HistoryItemEntity>[];
  UserImpactEntity _impact = const UserImpactEntity(
    livesHelped: 12,
    totalDonations: 3,
    ranking: 'Donador Leal',
  );
  late UserEntity _user;
  int _appointmentSequence = 10;

  void _resetState() {
    _appointments
      ..clear()
      ..addAll({
        'apt-001': _FakeAppointmentRecord(
          entity: AppointmentEntity(
            id: 'apt-001',
            centerName: 'Hospital de Clínicas (UBA)',
            scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
            status: AppointmentStatus.scheduled,
          ),
          donationType: 'Sangre total',
          verificationCode: 'BH-4312',
        ),
        'apt-002': _FakeAppointmentRecord(
          entity: AppointmentEntity(
            id: 'apt-002',
            centerName: 'Centro de Salud Norte',
            scheduledAt: DateTime.now().add(const Duration(days: 7, hours: 1)),
          ),
          donationType: 'Plaquetas',
          verificationCode: 'BH-7721',
          pointsAwarded: 180,
          verificationCompleted: true,
        ),
      });

    _history
      ..clear()
      ..addAll([
        HistoryItemEntity(
          id: 'hist-001',
          centerName: 'Hospital Central',
          donationType: 'Sangre total',
          occurredAt: DateTime.now().subtract(const Duration(days: 60)),
          status: AppointmentStatus.completed,
          pointsAwarded: 80,
        ),
        HistoryItemEntity(
          id: 'hist-002',
          centerName: 'Clínica San Martín',
          donationType: 'Plaquetas',
          occurredAt: DateTime.now().subtract(const Duration(days: 120)),
          status: AppointmentStatus.completed,
          pointsAwarded: 120,
        ),
      ]);

    _impact = const UserImpactEntity(
      livesHelped: 12,
      totalDonations: 3,
      ranking: 'Donador Leal',
      pointsEarned: 200,
    );

    _user = UserEntity(
      name: 'Usuario',
      email: 'usuario@email.com',
      phone: '1122334455',
      city: 'Buenos Aires',
      bloodType: 'O-',
      ranking: 'Donador leal',
    );

    _appointmentSequence = 10;
  }

  void resetForTesting() {
    _resetState();
  }

  @override
  Future<List<CenterEntity>> getCenters() async {
    final mapCenters = await loadCentersFromAsset(
      'assets/data/centers_ba.json',
    );
    return mapCenters.map((mc) => CenterEntity.fromMapCenter(mc)).toList();
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final allMapCenters = await loadCentersFromAsset(
      'assets/data/centers_ba.json',
    );

    MapCenter? foundCenter = allMapCenters.cast<MapCenter?>().firstWhere(
          (mc) => mc?.name == centerName,
          orElse: () => null as MapCenter?,
        );

    if (foundCenter != null) {
      return CenterDetailEntity(
        name: foundCenter.name,
        address: foundCenter.address,
        schedule: 'Lun a Vie 8:00 - 18:00 · Sáb 9:00 - 13:00',
        services: [
          'Extracción de sangre',
          foundCenter.name.contains('Hospital')
              ? 'Estacionamiento'
              : 'Zona de espera',
        ],
        imageUrl: foundCenter.image ?? '',
        latitude: foundCenter.lat,
        longitude: foundCenter.lng,
      );
    }

    return CenterDetailEntity(
      name: centerName,
      address: 'Dirección no encontrada',
      schedule: 'Horario no disponible',
      services: const ['Servicios no disponibles'],
      imageUrl: '',
      latitude: -34.6,
      longitude: -58.4,
    );
  }

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _appointments.values
        .where((record) => record.entity.status != AppointmentStatus.cancelled)
        .map((record) => record.entity)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  @override
  Future<AppointmentDetailEntity> getAppointmentDetails(
    String appointmentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final record = _appointments[appointmentId];
    if (record == null) {
      return AppointmentDetailEntity(
        id: appointmentId,
        centerName: 'Centro desconocido',
        scheduledAt: DateTime.now(),
        donationType: 'No especificado',
        reminders: const [],
      );
    }

    return AppointmentDetailEntity(
      id: record.entity.id,
      centerName: record.entity.centerName,
      scheduledAt: record.entity.scheduledAt,
      donationType: record.donationType,
      reminders: const [
        'Dormí al menos 6 horas la noche anterior.',
        'Evitá consumir alcohol 24 hs antes.',
        'Desayuná liviano antes de donar.',
      ],
      status: record.entity.status,
      verificationCompleted: record.verificationCompleted,
      pointsAwarded: record.pointsAwarded,
    );
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final record = _appointments[appointmentId];
    if (record == null) {
      return;
    }

    record.entity = record.entity.copyWith(
      status: AppointmentStatus.cancelled,
    );

    _history.removeWhere((item) => item.id == record.entity.id);
    _history.add(
      HistoryItemEntity(
        id: record.entity.id,
        centerName: record.entity.centerName,
        donationType: record.donationType,
        occurredAt: record.entity.scheduledAt,
        status: AppointmentStatus.cancelled,
      ),
    );
  }

  @override
  Future<List<String>> getAvailableTimes(
    String centerName,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
  }

  @override
  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final parts = time.split(':');
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9,
      parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );

    final newId = 'apt-${++_appointmentSequence}';
    _appointments[newId] = _FakeAppointmentRecord(
      entity: AppointmentEntity(
        id: newId,
        centerName: centerName,
        scheduledAt: scheduled,
      ),
      donationType: 'Sangre total',
      verificationCode: 'BH-${4000 + _appointmentSequence}',
    );
  }

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    await Future.delayed(const Duration(milliseconds: 180));
    final upcoming = (await getAppointments())
        .where((appt) => appt.scheduledAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return upcoming.isNotEmpty
        ? upcoming.first
        : AppointmentEntity(
            id: 'no-appointment',
            centerName: 'No tenés próximas citas',
            scheduledAt: DateTime.now(),
            status: AppointmentStatus.cancelled,
          );
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      const AlertEntity(
        id: 'alert-1',
        centerName: 'Hospital Central',
        bloodType: 'O-',
        distance: '2 km',
        expiration: 'vence hoy',
      ),
      const AlertEntity(
        id: 'alert-2',
        centerName: 'Clínica del Norte',
        bloodType: 'A+',
        distance: '5 km',
        expiration: 'vence en 2 días',
      ),
      const AlertEntity(
        id: 'alert-3',
        centerName: 'Sanatorio del Sur',
        bloodType: 'B-',
        distance: '8 km',
        expiration: 'vence en 3 días',
      ),
    ];
  }

  @override
  Future<UserEntity> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _user;
  }

  @override
  Future<List<String>> getDonationTips() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return const [
      'Recordá hidratarte bien antes y después de donar.',
      'Avisá al personal si te sentís mareado en algún momento.',
      'Evitá hacer actividad física intensa el día de la donación.',
    ];
  }

  @override
  Future<UserImpactEntity> getUserImpactStats() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _impact;
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _achievements;
  }

  @override
  Future<AlertDetailEntity> getAlertDetails(String identifier) async {
    await Future.delayed(const Duration(milliseconds: 180));
    String bloodTypeNeeded = 'O-';
    if (identifier.toLowerCase().contains('norte')) {
      bloodTypeNeeded = 'A+';
    } else if (identifier.toLowerCase().contains('sur')) {
      bloodTypeNeeded = 'B-';
    }
    return AlertDetailEntity(
      centerName: identifier,
      bloodType: bloodTypeNeeded,
      urgency: 'Dentro de ${bloodTypeNeeded == 'O-' ? 12 : 24} horas',
      quantityNeeded: '${bloodTypeNeeded == 'O-' ? 5 : 3} donaciones',
      description:
          'Se necesita sangre $bloodTypeNeeded para pacientes en $identifier. Tu donación puede hacer la diferencia.',
      contactPhone: '(011) 4${identifier.length}34-5${identifier.length}78',
      contactEmail:
          'donaciones@${identifier.toLowerCase().replaceAll(' ', '')}.com',
    );
  }

  @override
  Future<List<HistoryItemEntity>> getDonationHistory() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<HistoryItemEntity>.from(_history)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  @override
  Future<AchievementDetailEntity> getAchievementDetails(String title) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final achievement = FakeCentersRepository._achievements.firstWhere(
      (ach) => ach.title == title,
      orElse: () => const AchievementEntity(
        title: 'Logro Desconocido',
        description: 'No se encontraron detalles.',
      ),
    );
    return AchievementDetailEntity(
      title: achievement.title,
      description: achievement.description,
    );
  }

  @override
  Future<bool> verifyDonationCode({
    required String appointmentId,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final record = _appointments[appointmentId];
    if (record == null) {
      return false;
    }

    if (record.verificationCode != code) {
      return false;
    }

    if (!record.verificationCompleted) {
      record.markVerified();
      _impact = _impact.copyWith(
        totalDonations: _impact.totalDonations + 1,
        pointsEarned: _impact.pointsEarned + record.pointsAwarded,
      );

      _history.removeWhere((item) => item.id == record.entity.id);
      _history.add(
        HistoryItemEntity(
          id: record.entity.id,
          centerName: record.entity.centerName,
          donationType: record.donationType,
          occurredAt: record.entity.scheduledAt,
          status: AppointmentStatus.completed,
          pointsAwarded: record.pointsAwarded,
        ),
      );
    }

    return true;
  }

  @override
  Future<void> updateUserProfile(UserEntity updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = updatedUser;
  }

  @override
  Future<void> registerAlertResponse({required String alertId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _impact = _impact.copyWith(
      livesHelped: _impact.livesHelped + 1,
      pointsEarned: _impact.pointsEarned + 40,
    );
  }
}

class _FakeAppointmentRecord {
  _FakeAppointmentRecord({
    required this.entity,
    required this.donationType,
    required this.verificationCode,
    this.pointsAwarded = 150,
    this.verificationCompleted = false,
  });

  AppointmentEntity entity;
  final String donationType;
  final String verificationCode;
  final int pointsAwarded;
  bool verificationCompleted;

  void markVerified() {
    verificationCompleted = true;
    entity = entity.copyWith(status: AppointmentStatus.completed);
  }
}
