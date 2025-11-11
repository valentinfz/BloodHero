import 'dart:async';
import 'package:bloodhero/data/loaders/centers_loader.dart';
import 'package:flutter/foundation.dart';
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

class FakeCentersRepository implements CentersRepository {
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

  String _formatDateLabel(DateTime date) {
    const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final weekday = weekdays[(date.weekday - 1).clamp(0, 6)];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }

  void _validateBookingDate(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!normalizedDate.isAfter(normalizedToday)) {
      throw Exception('Las donaciones deben agendarse con al menos 1 día de anticipación.');
    }
    if (normalizedDate.weekday == DateTime.sunday) {
      throw Exception('Los turnos no están disponibles los domingos.');
    }
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
        id: foundCenter.id,
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
        image: foundCenter.image ?? '', // Usa la imagen del JSON si existe
        latitude: foundCenter.lat,
        longitude: foundCenter.lng,
      );
    }

    // 4. Si NO se encontró, devuelve datos por defecto (o lanza un error)
    return CenterDetailEntity(
      id: centerName.toLowerCase().replaceAll(' ', '_'),
      name: centerName, // Muestra el nombre que se buscó
      address: 'Dirección no encontrada',
      schedule: 'Horario no disponible',
      services: ['Servicios no disponibles'],
      image: '',
      latitude: -34.6, // Coordenadas genéricas de BA
      longitude: -58.4,
    );
  }

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    return [
      AppointmentEntity(
        id: '1',
        centerId: 'hospital_central',
        date: 'Lun 12/11',
        time: '10:30',
        location: 'Hospital Central',
        donationType: 'Sangre total',
        scheduledAt: now.copyWith(hour: 10, minute: 30),
        status: AppointmentStatus.scheduled,
      ),
      AppointmentEntity(
        id: '2',
        centerId: 'centro_salud_norte',
        date: 'Vie 16/11',
        time: '09:00',
        location: 'Centro de Salud Norte',
        donationType: 'Plaquetas',
        scheduledAt: now.add(const Duration(days: 4)).copyWith(hour: 9),
        status: AppointmentStatus.completed,
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
      centerId: 'hospital_central',
      center: 'Hospital Central',
      date: 'Lunes 12 de Noviembre, 2025',
      time: '10:30 hs',
      donationType: 'Sangre total',
      reminders: [
        'Dormí al menos 6 horas la noche anterior.',
        'Evitá consumir alcohol 24 hs antes.',
        'Desayuná liviano antes de donar.',
      ],
      scheduledAt: DateTime.now().copyWith(hour: 10, minute: 30),
    );
  }

  @override
  Future<List<String>> getAvailableTimes({
    required String centerId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    _validateBookingDate(date);
    await Future.delayed(const Duration(milliseconds: 800));
    final timeParts = time.split(':');
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts.first),
      timeParts.length > 1 ? int.parse(timeParts[1]) : 0,
    );

    final appointment = AppointmentEntity(
      id: 'fake_${scheduledAt.millisecondsSinceEpoch}',
      centerId: centerId,
      date: _formatDateLabel(date),
      time: time,
      location: centerName,
      donationType: donationType,
      scheduledAt: scheduledAt,
      status: AppointmentStatus.scheduled,
    );

    debugPrint(
      'Cita agendada para $centerName ($centerId) el ${appointment.date} a las $time',
    );
    return appointment;
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
    _validateBookingDate(date);
    await Future.delayed(const Duration(milliseconds: 600));
    final newAppointment = await bookAppointment(
      centerId: centerId,
      centerName: centerName,
      date: date,
      time: time,
      donationType: donationType,
    );
    debugPrint(
      'Reprogramamos cita $appointmentId hacia ${newAppointment.date} ${newAppointment.time}',
    );
    return newAppointment;
  }

  @override
  Future<void> logDonation({
    required String appointmentId,
    required bool wasCompleted,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint(
      'Cita $appointmentId registrada como ${wasCompleted ? 'completada' : 'no completada'}. Notas: ${notes ?? 'N/A'}',
    );
    // Lógica FAKE:
    // 1. Buscar la cita en la lista de citas mock.
    // 2. Actualizar su estado a 'completed' o 'cancelled'.
    // 3. Añadir una entrada al historial mock.
    // 4. Si fue completada, simular un incremento en las estadísticas de impacto.
    return;
  }

  @override
  Future<void> cancelAppointment({required String appointmentId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Cita $appointmentId cancelada.');
    // Lógica FAKE:
    // 1. Buscar la cita en la lista de citas mock.
    // 2. Cambiar su estado a 'cancelled'.
    // 3. Opcionalmente, añadir una entrada al historial como 'cancelada'.
    return;
  }

  @override
  Future<AppointmentEntity> getNextAppointment() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final baseDate = DateTime.now().add(const Duration(days: 3));
    final scheduledAt = DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 30);
    return AppointmentEntity(
      id: '1',
      centerId: 'hospital_central',
      date: _formatDateLabel(scheduledAt),
      time: '10:30',
      location: 'Hospital Central',
      donationType: 'Sangre total',
      scheduledAt: scheduledAt,
      status: AppointmentStatus.scheduled,
    );
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      AlertEntity(
        bloodType: 'O-',
        expiration: 'vence hoy',
        distance: '2 km',
        centerName: 'Hospital Central',
        latitude: -34.6037,
        longitude: -58.3816,
      ),
      AlertEntity(
        bloodType: 'A+',
        expiration: 'vence en 2 días',
        distance: '5 km',
        centerName: 'Clínica del Norte',
        latitude: -34.5481,
        longitude: -58.4896,
      ),
      AlertEntity(
        bloodType: 'B-',
        expiration: 'vence en 3 días',
        distance: '8 km',
        centerName: 'Hospital Sur',
        latitude: -34.7206,
        longitude: -58.2620,
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
    final totalDonations = 4;
    final levelInfo = _computeLevel(totalDonations);
    return UserImpactEntity(
      livesHelped: 12,
      ranking: 'Donador Leal',
      totalDonations: totalDonations,
      currentLevel: levelInfo.current,
      nextLevel: levelInfo.next,
      donationsToNextLevel: levelInfo.donationsToNextLevel,
    );
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final inferred = _levels
        .where((level) => level.minDonations <= 4)
        .map(
          (level) => AchievementEntity(
            title: level.name,
            description: level.description,
            iconName: level.badgeEmoji,
          ),
        );

    final merged = {
      for (final achievement in _achievements)
        achievement.title: achievement,
      for (final achievement in inferred)
        achievement.title: achievement,
    };

    return merged.values.toList();
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
        appointmentId: 'hist_1',
        centerId: 'hospital_central',
        date: '12/11/2025',
        center: 'Hospital Central',
        type: 'Sangre total',
        status: AppointmentStatus.completed,
      ),
      HistoryItemEntity(
        appointmentId: 'hist_2',
        centerId: 'banco_sangre_norte',
        date: '05/09/2025',
        center: 'Banco de Sangre Norte',
        type: 'Plaquetas',
        status: AppointmentStatus.completed,
      ),
      HistoryItemEntity(
        appointmentId: 'hist_3',
        centerId: 'clinica_san_martin',
        date: '18/06/2025',
        center: 'Clínica San Martín',
        type: 'Sangre total',
        status: AppointmentStatus.cancelled,
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

class _LevelResult {
  final AchievementLevel? current;
  final AchievementLevel? next;
  final int donationsToNextLevel;

  const _LevelResult({
    required this.current,
    required this.next,
    required this.donationsToNextLevel,
  });
}

_LevelResult _computeLevel(int totalDonations) {
  AchievementLevel? current;
  AchievementLevel? next;
  for (final level in _levels) {
    if (totalDonations >= level.minDonations) {
      current = level;
    } else {
      next ??= level;
      break;
    }
  }

  final donationsToNext = next == null
      ? 0
      : (next.minDonations - totalDonations).clamp(0, next.minDonations);

  return _LevelResult(
    current: current,
    next: next,
    donationsToNextLevel: donationsToNext,
  );
}

const List<AchievementLevel> _levels = [
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
