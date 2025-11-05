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
        image: foundCenter.image ?? '', // Usa la imagen del JSON si existe
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
      image: '',
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
      AlertEntity(bloodType: 'O-', distance: '2 km', expiration: 'vence hoy'),
      AlertEntity(
        bloodType: 'A+',
        distance: '5 km',
        expiration: 'vence en 2 días',
      ),
      AlertEntity(
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
