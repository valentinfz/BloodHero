import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/appointment_detail_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import 'centers_provider.dart';

final appointmentsProvider =
    FutureProvider.autoDispose<List<AppointmentEntity>>((ref) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAppointments();
    });

// Provider.family para obtener los detalles de UNA cita específica por su ID
final appointmentDetailProvider = FutureProvider.autoDispose
    .family<AppointmentDetailEntity, String>((ref, appointmentId) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAppointmentDetails(appointmentId);
    });

//PROVIDERS PARA EL FLUJO DE AGENDAR CITA:

// 1. Clase auxiliar para pasar múltiples parámetros al provider.family
class AvailableTimesParams {
  final String centerName;
  final DateTime date;

  AvailableTimesParams({required this.centerName, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableTimesParams &&
          runtimeType == other.runtimeType &&
          centerName == other.centerName &&
          date == other.date;

  @override
  int get hashCode => centerName.hashCode ^ date.hashCode;
}

// 2. Provider.family para obtener los horarios disponibles
final availableTimesProvider = FutureProvider.autoDispose
    .family<List<String>, AvailableTimesParams>((ref, params) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAvailableTimes(params.centerName, params.date);
    });

// Enum para manejar los estados del proceso de agendamiento
enum BookingState { initial, loading, success, error }

// Notifier para manejar la lógica de agendar una cita
class AppointmentBookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => BookingState.initial;

  Future<void> bookAppointment({
    required String centerName,
    required DateTime date,
    required String time,
  }) async {
    state = BookingState.loading;
    try {
      final repository = ref.read(centersRepositoryProvider);
      await repository.bookAppointment(
        centerName: centerName,
        date: date,
        time: time,
      );
      state = BookingState.success;
    } catch (e) {
      state = BookingState.error;
    }
  }

  void resetState() {
    state = BookingState.initial;
  }
}

// El NotifierProvider que la UI consumirá
final appointmentBookingProvider =
    NotifierProvider<AppointmentBookingNotifier, BookingState>(() {
      return AppointmentBookingNotifier();
    });
