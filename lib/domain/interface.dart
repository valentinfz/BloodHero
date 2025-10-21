import 'dart:async';

import 'package:bloodhero/domain/entities/appointment_detail_entity.dart';

import '../domain/entities/center_entity.dart';
import '../domain/entities/center_detail_entity.dart';
import '../domain/entities/appointment_entity.dart';
import '../domain/entities/alert_entity.dart';
import '../domain/entities/user_entity.dart';

// Este es el "contrato" que cualquier repositorio de datos (ya sea el falso o de Firebase) debe cumplir.
abstract class CentersRepository {
  // Métodos para Centros
  Future<List<CenterEntity>> getCenters();
  Future<CenterDetailEntity> getCenterDetails(String centerName);

  // Métodos para Citas
  Future<List<AppointmentEntity>> getAppointments();
  Future<AppointmentDetailEntity> getAppointmentDetails(String appointmentId);
  Future<List<String>> getAvailableTimes(String centerName, DateTime date);

  // Métodos para el Home
  Future<AppointmentEntity> getNextAppointment();
  Future<List<AlertEntity>> getNearbyAlerts();

  // Métodos de Usuario
  Future<UserEntity> getUserProfile();
}
