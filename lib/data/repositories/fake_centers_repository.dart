import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/center_detail_entity.dart';
import '../../domain/entities/user_impact_entity.dart'; // Importamos entidad de impacto
import '../../domain/entities/achievement_entity.dart'; // Importamos entidad de logros
import '../../domain/repositories/centers_repository.dart';

// Esta clase es la implementación "real" (pero con datos falsos) de nuestro contrato.
class FakeCentersRepository implements CentersRepository {
  @override
  Future<List<CenterEntity>> getCenters() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const CenterEntity(
        'Centro de Salud Norte',
        '2.5 km',
        'Av. Siempre Viva 123',
      ),
      const CenterEntity('Hospital Central', '4.2 km', 'Calle Principal 456'),
      const CenterEntity('Banco de Sangre Sur', '5.7 km', 'Boulevard Paz 789'),
    ];
  }

  @override
  Future<CenterDetailEntity> getCenterDetails(String centerName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (centerName == 'Hospital Central') {
      return CenterDetailEntity(
        name: 'Hospital Central',
        address: 'Calle Principal 456, CABA',
        schedule: 'Lun a Vie 8:00 - 20:00',
        services: [
          'Extracción de sangre y plasma',
          'Estacionamiento sin cargo',
          'Cafetería',
        ],
        imageUrl: '',
        latitude: -34.6037,
        longitude: -58.3816,
      );
    }
    return CenterDetailEntity(
      name: centerName,
      address: 'Av. Siempre Viva 123, CABA',
      schedule: 'Lun a Vie 8:00 - 18:00',
      services: ['Extracción de sangre y plasma'],
      imageUrl: '',
      latitude: -34.6090,
      longitude: -58.3845,
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
      name: 'Sebastián',
      email: 'sebastian@email.com',
      phone: '1122334455',
      city: 'Buenos Aires',
      bloodType: 'O-',
      ranking: 'Donador leal',
    );
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
    // El ranking podría venir del perfil de usuario. Aca esta fijo usamos valores fijos.
    return UserImpactEntity(livesHelped: 12, ranking: 'Donador Leal');
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 900));
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
  }
}
